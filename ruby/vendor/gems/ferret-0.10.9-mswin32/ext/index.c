#include "index.h"
#include "similarity.h"
#include "helper.h"
#include "array.h"
#include "priorityqueue.h"
#include <string.h>
#include <limits.h>

#define GET_LOCK(lock, name, store, err_msg) do {\
    lock = store->open_lock(store, name);\
    if (!lock->obtain(lock)) {\
        RAISE(LOCK_ERROR, err_msg);\
    }\
} while(0)

#define RELEASE_LOCK(lock, store) do {\
    lock->release(lock);\
    store->close_lock(lock);\
} while (0)

const char *INDEX_EXTENSIONS[] = {
    "fdx", "fdt", "tfx", "tix", "tis", "frq", "prx", "del"
};

const char *COMPOUND_EXTENSIONS[] = {
    "frq", "prx", "fdx", "fdt", "tfx", "tix", "tis"
};

const Config default_config = {
    0x100000,       /* chunk size is 1Mb */
    0x1000000,      /* Max memory used for buffer is 16 Mb */
    INDEX_INTERVAL, /* index interval */
    SKIP_INTERVAL,  /* skip interval */
    10,             /* default merge factor */
    10000,          /* max_buffered_docs */
    INT_MAX,        /* max_merged_docs */
    10000,          /* maximum field length (number of terms) */
    true            /* use compound file by default */
};

static void ste_reset(TermEnum *te);
static char *ste_next(TermEnum *te);

/***************************************************************************
 *
 * CacheObject
 *
 ***************************************************************************/

static unsigned long co_hash(const void *key)
{
    return (unsigned long)key;
}

static int co_eq(const void *key1, const void *key2)
{
    return (key1 == key2);
}

void co_destroy(CacheObject *self)
{
    h_rem(self->ref_tab1, self->ref2, false);
    h_rem(self->ref_tab2, self->ref1, false);
    self->destroy(self->obj);
    free(self);
}

CacheObject *co_create(HashTable *ref_tab1, HashTable *ref_tab2,
                       void *ref1, void *ref2, free_ft destroy, void *obj)
{
    CacheObject *self = ALLOC(CacheObject);
    h_set(ref_tab1, ref2, self);
    h_set(ref_tab2, ref1, self);
    self->ref_tab1 = ref_tab1;
    self->ref_tab2 = ref_tab2;
    self->ref1 = ref1;
    self->ref2 = ref2;
    self->destroy = destroy;
    self->obj = obj;
    return self;
}

HashTable *co_hash_create()
{
    return h_new(&co_hash, &co_eq, (free_ft)NULL, (free_ft)&co_destroy);
}

/****************************************************************************
 *
 * FieldInfo
 *
 ****************************************************************************/

 __inline void fi_set_store(FieldInfo *fi, int store)
{
    switch (store) {
        case STORE_NO:
            break;
        case STORE_YES:
            fi->bits |= FI_IS_STORED_BM;
            break;
        case STORE_COMPRESS:
            fi->bits |= FI_IS_COMPRESSED_BM | FI_IS_STORED_BM;
            break;
    }
}

__inline void fi_set_index(FieldInfo *fi, int index)
{
    switch (index) {
        case INDEX_NO:
            break;
        case INDEX_YES:
            fi->bits |= FI_IS_INDEXED_BM | FI_IS_TOKENIZED_BM;
            break;
        case INDEX_UNTOKENIZED:
            fi->bits |= FI_IS_INDEXED_BM;
            break;
        case INDEX_YES_OMIT_NORMS:
            fi->bits |= FI_OMIT_NORMS_BM | FI_IS_INDEXED_BM |
                FI_IS_TOKENIZED_BM;
            break;
        case INDEX_UNTOKENIZED_OMIT_NORMS:
            fi->bits |= FI_OMIT_NORMS_BM | FI_IS_INDEXED_BM;
            break;
    }
}

__inline void fi_set_term_vector(FieldInfo *fi, int term_vector)
{
    switch (term_vector) {
        case TERM_VECTOR_NO:
            break;
        case TERM_VECTOR_YES:
            fi->bits |= FI_STORE_TERM_VECTOR_BM;
            break;
        case TERM_VECTOR_WITH_POSITIONS:
            fi->bits |= FI_STORE_TERM_VECTOR_BM | FI_STORE_POSITIONS_BM;
            break;
        case TERM_VECTOR_WITH_OFFSETS:
            fi->bits |= FI_STORE_TERM_VECTOR_BM | FI_STORE_OFFSETS_BM;
            break;
        case TERM_VECTOR_WITH_POSITIONS_OFFSETS:
            fi->bits |= FI_STORE_TERM_VECTOR_BM | FI_STORE_POSITIONS_BM |
                FI_STORE_OFFSETS_BM;
            break;
    }
}

static void fi_check_params(int store, int index, int term_vector)
{
    (void)store;
    if ((index == INDEX_NO) && (term_vector != TERM_VECTOR_NO)) {
        RAISE(ARG_ERROR,
              "You can't store the term vectors of an unindexed field");
    }
}

FieldInfo *fi_new(const char *name,
                  enum StoreValues store,
                  enum IndexValues index,
                  enum TermVectorValues term_vector)
{
    FieldInfo *fi = ALLOC(FieldInfo);
    fi_check_params(store, index, term_vector);
    fi->name = estrdup(name);
    fi->boost = 1.0;
    fi->bits = 0;
    fi_set_store(fi, store);
    fi_set_index(fi, index);
    fi_set_term_vector(fi, term_vector);
    fi->ref_cnt = 1;
    return fi;
}

void fi_deref(FieldInfo *fi)
{
    if (--(fi->ref_cnt) == 0) {
        free(fi->name);
        free(fi);
    }
}

char *fi_to_s(FieldInfo *fi)
{
    char *str = ALLOC_N(char, strlen(fi->name) + 200);
    char *s = str;
    sprintf(str, "[\"%s\":(%s%s%s%s%s%s%s%s", fi->name,
            fi_is_stored(fi) ? "is_stored, " : "",
            fi_is_compressed(fi) ? "is_compressed, " : "",
            fi_is_indexed(fi) ? "is_indexed, " : "",
            fi_is_tokenized(fi) ? "is_tokenized, " : "",
            fi_omit_norms(fi) ? "omit_norms, " : "",
            fi_store_term_vector(fi) ? "store_term_vector, " : "",
            fi_store_positions(fi) ? "store_positions, " : "",
            fi_store_offsets(fi) ? "store_offsets, " : "");
    s += (int)strlen(str) - 2;
    if (*s != ',') {
        s += 2;
    }
    sprintf(s, ")]");
    return str;
}

/****************************************************************************
 *
 * FieldInfos
 *
 ****************************************************************************/

#define FIELDS_FILENAME "fields"
#define TEMPORARY_FIELDS_FILENAME "fields.new"

FieldInfos *fis_new(int store, int index, int term_vector)
{
    FieldInfos *fis = ALLOC(FieldInfos);
    fi_check_params(store, index, term_vector);
    fis->field_dict = h_new_str((free_ft)NULL, (free_ft)&fi_deref);
    fis->size = 0;
    fis->capa = FIELD_INFOS_INIT_CAPA;
    fis->fields = ALLOC_N(FieldInfo *, fis->capa);
    fis->store = store;
    fis->index = index;
    fis->term_vector = term_vector;
    fis->ref_cnt = 1;
    return fis;
}

FieldInfo *fis_add_field(FieldInfos *fis, FieldInfo *fi)
{
    if (fis->size == fis->capa) {
        fis->capa <<= 1;
        REALLOC_N(fis->fields, FieldInfo *, fis->capa);
    }
    if (!h_set_safe(fis->field_dict, fi->name, fi)) {
        RAISE(ARG_ERROR,
              "Field :%s already exists", fi->name);
    }
    fi->number = fis->size;
    fis->fields[fis->size] = fi;
    fis->size++;
    return fi;
}

FieldInfo *fis_get_field(FieldInfos *fis, const char *name)
{
    return h_get(fis->field_dict, name);
}

int fis_get_field_num(FieldInfos *fis, const char *name)
{
    FieldInfo *fi = h_get(fis->field_dict, name);
    if (fi) {
        return fi->number;
    }
    else {
        return -1;
    }
}

FieldInfo *fis_get_or_add_field(FieldInfos *fis, const char *name)
{
    FieldInfo *fi = h_get(fis->field_dict, name);
    if (!fi) {
        fi = fi_new(name, fis->store, fis->index, fis->term_vector);
        fis_add_field(fis, fi);
    }
    return fi;
}

FieldInfo *fis_by_number(FieldInfos *fis, int num)
{
    if (num >= 0 && num < fis->size) {
        return fis->fields[num];
    }
    else {
        return NULL;
    }
}

FieldInfos *fis_read(Store *store)
{
    int store_val, index_val, term_vector_val;
    int i;
    union { f_u32 i; float f; } tmp;
    FieldInfo *fi;
    FieldInfos *fis;
    InStream *is = store->open_input(store, FIELDS_FILENAME);

    store_val = is_read_vint(is);
    index_val = is_read_vint(is);
    term_vector_val = is_read_vint(is);
    fis = fis_new(store_val, index_val, term_vector_val);
    for (i = is_read_vint(is); i > 0; i--) {
        fi = ALLOC(FieldInfo);
        fi->name = is_read_string(is);
        tmp.i = is_read_u32(is);
        fi->boost = tmp.f;
        fi->bits = is_read_vint(is);
        fis_add_field(fis, fi);
        fi->ref_cnt = 1;
    }
    is_close(is);

    return fis; 
}

void fis_write(FieldInfos *fis, Store *store)
{
    int i;
    union { f_u32 i; float f; } tmp;
    FieldInfo *fi;
    OutStream *os = store->new_output(store, TEMPORARY_FIELDS_FILENAME);
    const int fis_size = fis->size;

    os_write_vint(os, fis->store);
    os_write_vint(os, fis->index);
    os_write_vint(os, fis->term_vector);
    os_write_vint(os, fis->size);
    for (i = 0; i < fis_size; i++) {
        fi = fis->fields[i];
        os_write_string(os, fi->name);
        tmp.f = fi->boost;
        os_write_u32(os, tmp.i);
        os_write_vint(os, fi->bits);
    }
    os_close(os);

    store->rename(store, TEMPORARY_FIELDS_FILENAME, FIELDS_FILENAME);
}

static const char *store_str[] = {
    ":no",
    ":yes",
    "",
    ":compressed"
};

static const char *fi_store_str(FieldInfo *fi)
{
    return store_str[fi->bits & 0x3];
}

static const char *index_str[] = {
    ":no",
    ":untokenized",
    "",
    ":yes",
    "",
    ":untokenized_omit_norms",
    "",
    ":yes_omit_norms"
};

static const char *fi_index_str(FieldInfo *fi)
{
    return index_str[(fi->bits >> 2) & 0x7];
}

static const char *term_vector_str[] = {
    ":no",
    ":yes",
    "",
    ":with_positions",
    "",
    ":with_offsets",
    "",
    ":with_positions_offsets"
};

static const char *fi_term_vector_str(FieldInfo *fi)
{
    return term_vector_str[(fi->bits >> 5) & 0x7];
}

char *fis_to_s(FieldInfos *fis)
{
    int i, pos, capa = 200 + fis->size * 120;
    char *buf = ALLOC_N(char, capa);
    FieldInfo *fi;
    const int fis_size = fis->size;

    sprintf(buf, 
            "default:\n"
            "  store: %s\n"
            "  index: %s\n"
            "  term_vector: %s\n"
            "fields:\n",
            store_str[fis->store], index_str[fis->index],
            term_vector_str[fis->term_vector]);
    pos = (int)strlen(buf);
    for (i = 0; i < fis_size; i++) {
        fi = fis->fields[i];
        sprintf(buf + pos, 
                "  %s:\n"
                "    boost: %f\n"
                "    store: %s\n"
                "    index: %s\n"
                "    term_vector: %s\n", 
                fi->name, fi->boost, fi_store_str(fi),
                fi_index_str(fi), fi_term_vector_str(fi));

        pos += strlen(buf + pos);
    }

    return buf;
}

void fis_deref(FieldInfos *fis)
{
    if (--(fis->ref_cnt) == 0) {
        h_destroy(fis->field_dict);
        free(fis->fields);
        free(fis);
    }
}

static bool fis_has_vectors(FieldInfos *fis)
{
    int i;
    const int fis_size = fis->size;

    for (i = 0; i < fis_size; i++) {
        if (fi_store_term_vector(fis->fields[i])) {
            return true;
        }
    }
    return false;
}

/****************************************************************************
 *
 * SegmentInfo
 *
 ****************************************************************************/

SegmentInfo *si_new(char *name, int doc_cnt, Store *store)
{
    SegmentInfo *si = ALLOC(SegmentInfo);
    si->name = name;
    si->doc_cnt = doc_cnt;
    si->store = store;
    return si;
}

void si_destroy(SegmentInfo *si)
{
    free(si->name);
    free(si);
}

bool si_has_deletions(SegmentInfo *si)
{
    char del_file_name[SEGMENT_NAME_MAX_LENGTH];
    sprintf(del_file_name, "%s.del", si->name);
    return si->store->exists(si->store, del_file_name);
}

bool si_uses_compound_file(SegmentInfo *si)
{
    char compound_file_name[SEGMENT_NAME_MAX_LENGTH];
    sprintf(compound_file_name, "%s.cfs", si->name);
    return si->store->exists(si->store, compound_file_name);
}

struct NormTester {
    bool has_norm_file;
    int norm_file_pattern_len;
    char norm_file_pattern[SEGMENT_NAME_MAX_LENGTH];
};

static void is_norm_file(char *file_name, struct NormTester *nt)
{
    if (strncmp(file_name, nt->norm_file_pattern,
                nt->norm_file_pattern_len) == 0) {
        nt->has_norm_file = true;
    }
}

bool si_has_separate_norms(SegmentInfo *si)
{
    struct NormTester nt;
    sprintf(nt.norm_file_pattern, "%s.s", si->name);
    nt.norm_file_pattern_len = strlen(nt.norm_file_pattern);
    nt.has_norm_file = false;
    si->store->each(si->store, (void (*)(char *file_name, void *arg))&is_norm_file, &nt);

    return nt.has_norm_file;
}


/****************************************************************************
 *
 * SegmentInfos
 *
 ****************************************************************************/

#include <time.h>
#define FORMAT 0
#define SEGMENTS_FILENAME "segments"
#define TEMPORARY_SEGMENTS_FILENAME "segments.new"
#define MAX_EXT_LEN 10

static const char base36_digitmap[] = "0123456789abcdefghijklmnopqrstuvwxyz";

static char *new_segment(f_u64 counter) 
{
    char file_name[SEGMENT_NAME_MAX_LENGTH];
    int i;

    file_name[SEGMENT_NAME_MAX_LENGTH - 1] = '\0';
    for (i = SEGMENT_NAME_MAX_LENGTH - 2; i > MAX_EXT_LEN; i--) {
        file_name[i] = base36_digitmap[counter%36];
        counter /= 36;
        if (counter == 0) {
            break;
        }
    }
    if (i == MAX_EXT_LEN) {
        RAISE(EXCEPTION, "Max length of segment filename has been reached. "
              "Time to re-index.\n");
    }
    i--;
    file_name[i] = '_';
    return estrdup(&file_name[i]);
}

SegmentInfos *sis_new()
{
    SegmentInfos *sis = ALLOC(SegmentInfos);
    sis->format = FORMAT;
    sis->version = (f_u64)time(NULL);
    sis->size = 0;
    sis->counter = 0;
    sis->capa = 4;
    sis->segs = ALLOC_N(SegmentInfo *, sis->capa);
    return sis;
}

SegmentInfo *sis_new_segment(SegmentInfos *sis, int doc_cnt, Store *store)
{
    return sis_add_si(sis, si_new(new_segment(sis->counter++), doc_cnt,
                                     store));
}

void sis_destroy(SegmentInfos *sis)
{
    int i;
    const int sis_size = sis->size;
    for (i = 0; i < sis_size; i++) {
        si_destroy(sis->segs[i]);
    }
    free(sis->segs);
    free(sis);
}

SegmentInfo *sis_add_si(SegmentInfos *sis, SegmentInfo *si)
{
    if (sis->size >= sis->capa) {
        sis->capa = sis->size * 2;
        REALLOC_N(sis->segs, SegmentInfo *, sis->capa);
    }
    sis->segs[sis->size] = si;
    sis->size++;
    return si;
}

void sis_del_at(SegmentInfos *sis, int at)
{
    int i;
    const int sis_size = --(sis->size);
    si_destroy(sis->segs[at]);
    for (i = at; i < sis_size; i++) {
        sis->segs[i] = sis->segs[i+1];
    }
}

void sis_del_from_to(SegmentInfos *sis, int from, int to)
{
    int i, num_to_del = to - from;
    const int sis_size = sis->size -= num_to_del;
    for (i = from; i < to; i++) {
        si_destroy(sis->segs[i]);
    }
    for (i = from; i < sis_size; i++) {
        sis->segs[i] = sis->segs[i+num_to_del];
    }
}

void sis_clear(SegmentInfos *sis)
{
    int i;
    const int sis_size = sis->size;
    for (i = 0; i < sis_size; i++) {
        si_destroy(sis->segs[i]);
    }
    sis->size = 0;
}

SegmentInfos *sis_read(Store *store)
{
    int doc_cnt;
    int seg_cnt;
    int i;
    char *name;
    InStream *is = store->open_input(store, SEGMENTS_FILENAME);
    SegmentInfos *sis = ALLOC(SegmentInfos);
    sis->store = store;

    sis->format = is_read_u32(is); /* do nothing. it's the first version */
    sis->version = is_read_u64(is);
    sis->counter = is_read_u64(is);
    seg_cnt = is_read_vint(is);

    /* allocate space for segments */
    for (sis->capa = 4; sis->capa < seg_cnt; sis->capa <<= 1) {
    }
    sis->size = 0;
    sis->segs = ALLOC_N(SegmentInfo *, sis->capa);

    for (i = 0; i < seg_cnt; i++) {
        name = is_read_string(is);
        doc_cnt = is_read_vint(is);
        sis_add_si(sis, si_new(name, doc_cnt, store));
    }
    is_close(is);

    return sis;
}

void sis_write(SegmentInfos *sis, Store *store)
{
    int i;
    SegmentInfo *si;
    OutStream *os = store->new_output(store, TEMPORARY_SEGMENTS_FILENAME);
    const int sis_size = sis->size;

    os_write_u32(os, FORMAT);
    os_write_u64(os, ++(sis->version)); /* every write changes the index */
    os_write_u64(os, sis->counter);
    os_write_vint(os, sis->size); 
    for (i = 0; i < sis_size; i++) {
        si = sis->segs[i];
        os_write_string(os, si->name);
        os_write_vint(os, si->doc_cnt);
    }
    os_close(os);

    /* install new segment info */
    store->rename(store, TEMPORARY_SEGMENTS_FILENAME, SEGMENTS_FILENAME);
}

f_u64 sis_read_current_version(Store *store)
{
    InStream *is;
    f_u32 format = 0;
    f_u64 version = 0;

    if (!store->exists(store, SEGMENTS_FILENAME)) {
        return 0;
    }
    is = store->open_input(store, SEGMENTS_FILENAME);

    TRY
        format = is_read_u32(is);
        version = is_read_u64(is);
    XFINALLY
        is_close(is);
    XENDTRY

    return version;
}

/****************************************************************************
 *
 * LazyDocField
 *
 ****************************************************************************/

static LazyDocField *lazy_df_new(const char *name, const int size)
{
    LazyDocField *self = ALLOC(LazyDocField);
    self->name = estrdup(name);
    self->size = size;
    self->data = ALLOC_AND_ZERO_N(LazyDocFieldData, size);
    return self;
}

static void lazy_df_destroy(LazyDocField *self)
{
    int i;
    for (i = self->size - 1; i >= 0; i--) {
        if (self->data[i].text) {
            free(self->data[i].text);
         }
    }
    free(self->name);
    free(self->data);
    free(self);
}

char *lazy_df_get_data(LazyDocField *self, int i)
{
    char *text = NULL;
    if (i < self->size && i >= 0) {
        text = self->data[i].text;
        if (text == NULL) {
            const int read_len = self->data[i].length + 1;
            self->data[i].text = text = ALLOC_N(char, read_len);
            is_seek(self->doc->fields_in, self->data[i].start);
            is_read_bytes(self->doc->fields_in, (uchar *)text, read_len);
            text[read_len - 1] = '\0';
        }
    }

    return text;
}

void lazy_df_get_bytes(LazyDocField *self, char *buf, int start, int len)
{
    if (start < 0 || start >= self->len) {
        RAISE(IO_ERROR, "start out of range in LazyDocField#get_bytes. %d "
              "is not between 0 and %d", start, self->len);
    }
    if (len <= 0) {
        RAISE(IO_ERROR, "len = %d, but should be greater than 0", len);
    }
    if (start + len > self->len) {
        RAISE(IO_ERROR, "Tried to read past end of field. Field is only %d "
              "bytes long but tried to read to %d", self->len, start + len);
    }
    is_seek(self->doc->fields_in, self->data[0].start + start);
    is_read_bytes(self->doc->fields_in, (uchar *)buf, len);
}

/****************************************************************************
 *
 * LazyDoc
 *
 ****************************************************************************/

static LazyDoc *lazy_doc_new(int size, InStream *fdt_in)
{
    LazyDoc *self = ALLOC(LazyDoc);
    self->field_dict = h_new_str(NULL, (free_ft)&lazy_df_destroy);
    self->size = size;
    self->fields = ALLOC_AND_ZERO_N(LazyDocField *, size);
    self->fields_in = is_clone(fdt_in);
    return self;
}

void lazy_doc_close(LazyDoc *self)
{
    h_destroy(self->field_dict);
    is_close(self->fields_in);
    free(self->fields);
    free(self);
}

static void lazy_doc_add_field(LazyDoc *self, LazyDocField *lazy_df, int i)
{
    self->fields[i] = lazy_df;
    h_set(self->field_dict, lazy_df->name, lazy_df);
    lazy_df->doc = self;
}

/****************************************************************************
 *
 * FieldsReader
 *
 ****************************************************************************/

#define FIELDS_IDX_PTR_SIZE 12

FieldsReader *fr_open(Store *store, const char *segment, FieldInfos *fis)
{
    FieldsReader *fr = ALLOC(FieldsReader);
    InStream *fdx_in;
    char file_name[SEGMENT_NAME_MAX_LENGTH];
    size_t segment_len = strlen(segment);

    memcpy(file_name, segment, segment_len);

    fr->fis = fis;

    strcpy(file_name + segment_len, ".fdt");
    fr->fdt_in = store->open_input(store, file_name);
    strcpy(file_name + segment_len, ".fdx");
    fdx_in = fr->fdx_in = store->open_input(store, file_name);
    fr->size = is_length(fdx_in) / FIELDS_IDX_PTR_SIZE;
    fr->store = store;

    return fr;
}

FieldsReader *fr_clone(FieldsReader *orig)
{
    FieldsReader *fr = ALLOC(FieldsReader);

    memcpy(fr, orig, sizeof(FieldsReader));
    fr->fdx_in = is_clone(orig->fdx_in);
    fr->fdt_in = is_clone(orig->fdt_in);
    
    return fr;
}

void fr_close(FieldsReader *fr)
{
    is_close(fr->fdt_in);
    is_close(fr->fdx_in);
    free(fr);
}

static DocField *fr_df_new(char *name, int size)
{
    DocField *df = ALLOC(DocField);
    df->name = estrdup(name);
    df->capa = df->size = size;
    df->data = ALLOC_N(char *, df->capa);
    df->lengths = ALLOC_N(int, df->capa);
    df->destroy_data = true;
    df->boost = 1.0;
    return df;
}

Document *fr_get_doc(FieldsReader *fr, int doc_num)
{
    int i, j;
    FieldInfo *fi;
    off_t pos;
    int stored_cnt, field_num, df_size;
    DocField *df;
    Document *doc = doc_new();
    InStream *fdx_in = fr->fdx_in;
    InStream *fdt_in = fr->fdt_in;

    is_seek(fdx_in, doc_num * FIELDS_IDX_PTR_SIZE);
    pos = (off_t)is_read_u64(fdx_in);
    is_seek(fdt_in, pos);
    stored_cnt = is_read_vint(fdt_in);

    for (i = 0; i < stored_cnt; i++) {
        field_num = is_read_vint(fdt_in);
        fi = fr->fis->fields[field_num];
        df_size = is_read_vint(fdt_in);
        df = fr_df_new(fi->name, df_size);

        for (j = 0; j < df_size; j++) {
            df->lengths[j] = is_read_vint(fdt_in);
        }

        for (j = 0; j < df_size; j++) {
            const int read_len = df->lengths[j] + 1;
            df->data[j] = ALLOC_N(char, read_len);
            is_read_bytes(fdt_in, (uchar *)df->data[j], read_len);
            df->data[j][read_len - 1] = '\0';
        }
        doc_add_field(doc, df);
    }

    return doc;
}

LazyDoc *fr_get_lazy_doc(FieldsReader *fr, int doc_num)
{
    int i, j;
    FieldInfo *fi;
    off_t pos;
    int stored_cnt, field_num;
    LazyDocField *lazy_df;
    LazyDoc *lazy_doc;
    InStream *fdx_in = fr->fdx_in;
    InStream *fdt_in = fr->fdt_in;

    is_seek(fdx_in, doc_num * FIELDS_IDX_PTR_SIZE);
    pos = (off_t)is_read_u64(fdx_in);
    is_seek(fdt_in, pos);
    stored_cnt = is_read_vint(fdt_in);
    lazy_doc = lazy_doc_new(stored_cnt, fdt_in);

    for (i = 0; i < stored_cnt; i++) {
        int start = 0, end, data_cnt;
        field_num = is_read_vint(fdt_in);
        fi = fr->fis->fields[field_num];
        data_cnt = is_read_vint(fdt_in);
        lazy_df = lazy_df_new(fi->name, data_cnt);

        /* get the starts relative positions this time around */
        for (j = 0; j < data_cnt; j++) {
            lazy_df->data[j].start = start;
            start += 1 + (lazy_df->data[j].length = is_read_vint(fdt_in));
        }
        end = is_pos(fdt_in) + start;
        lazy_df->len = start - 1;

        /* correct the starts to their correct absolute positions */
        start = is_pos(fdt_in);
        for (j = 0; j < data_cnt; j++) {
            lazy_df->data[j].start += start;
        }

        lazy_doc_add_field(lazy_doc, lazy_df, i);
        is_seek(fdt_in, end);
    }

    return lazy_doc;
}

TermVector *fr_read_term_vector(FieldsReader *fr, int field_num)
{
    TermVector *tv = ALLOC_AND_ZERO(TermVector);
    InStream *fdt_in = fr->fdt_in;
    FieldInfo *fi = fr->fis->fields[field_num];
    const int num_terms = is_read_vint(fdt_in);
    
    tv->field_num = field_num;
    tv->field = estrdup(fi->name);

    if (num_terms > 0) {
        int i, j, delta_start, delta_len, total_len, freq;
        int store_positions = fi_store_positions(fi);
        int store_offsets = fi_store_offsets(fi);
        uchar buffer[MAX_WORD_SIZE];
        TVTerm *term;

        tv->term_cnt = num_terms;
        tv->terms = ALLOC_AND_ZERO_N(TVTerm, num_terms);

        for (i = 0; i < num_terms; i++) {
            term = &(tv->terms[i]);
            /* read delta encoded term */
            delta_start = is_read_vint(fdt_in);
            delta_len = is_read_vint(fdt_in);
            total_len = delta_start + delta_len;
            is_read_bytes(fdt_in, buffer + delta_start, delta_len);
            buffer[total_len++] = '\0';
            term->text = memcpy(ALLOC_N(char, total_len), buffer, total_len);

            /* read freq */
            freq = term->freq = is_read_vint(fdt_in);

            /* read positions if necessary */
            if (store_positions) {
                int *positions = term->positions = ALLOC_N(int, freq);
                int pos = 0;
                for (j = 0; j < freq; j++) {
                    positions[j] = pos += is_read_vint(fdt_in);
                }
            }

            /* read offsets if necessary */
        }
        if (store_offsets) {
            int num_positions = tv->offset_cnt = is_read_vint(fdt_in);
            Offset *offsets = tv->offsets = ALLOC_N(Offset, num_positions);
            int offset = 0;
            for (i = 0; i < num_positions; i++) {
                offsets[i].start = offset += is_read_vint(fdt_in);
                offsets[i].end = offset += is_read_vint(fdt_in);
            }
        }
    }
    return tv;
}

HashTable *fr_get_tv(FieldsReader *fr, int doc_num)
{
    HashTable *term_vectors = h_new_str((free_ft)NULL, (free_ft)&tv_destroy);
    int i;
    InStream *fdx_in = fr->fdx_in;
    InStream *fdt_in = fr->fdt_in;
    off_t data_ptr, field_index_ptr;
    int field_cnt;
    int *field_nums;

    if (doc_num >= 0 && doc_num < fr->size) {
        is_seek(fdx_in, FIELDS_IDX_PTR_SIZE * doc_num);

        data_ptr = (off_t)is_read_u64(fdx_in);
        field_index_ptr = data_ptr += (off_t)is_read_u32(fdx_in);

        /* scan fields to get position of field_num's term vector */
        is_seek(fdt_in, field_index_ptr);

        field_cnt = is_read_vint(fdt_in);
        field_nums = ALLOC_N(int, field_cnt);

        for (i = field_cnt - 1; i >= 0; i--) {
            int tv_size;
            field_nums[i] = is_read_vint(fdt_in);
            tv_size = is_read_vint(fdt_in);
            data_ptr -= tv_size;
        }
        is_seek(fdt_in, data_ptr);

        for (i = 0; i < field_cnt; i++) {
            TermVector *tv = fr_read_term_vector(fr, field_nums[i]);
            h_set(term_vectors, tv->field, tv);
        }
        free(field_nums);
    }
    return term_vectors;
}

TermVector *fr_get_field_tv(FieldsReader *fr, int doc_num, int field_num)
{
    TermVector *tv = NULL;

    if (doc_num >= 0 && doc_num < fr->size) {
        int i, fnum = -1;
        off_t field_index_ptr;
        int field_cnt;
        int offset = 0;
        InStream *fdx_in = fr->fdx_in;
        InStream *fdt_in = fr->fdt_in;

        is_seek(fdx_in, FIELDS_IDX_PTR_SIZE * doc_num);

        field_index_ptr =  (off_t)is_read_u64(fdx_in);
        field_index_ptr += (off_t)is_read_u32(fdx_in);

        /* scan fields to get position of field_num's term vector */
        is_seek(fdt_in, field_index_ptr);

        field_cnt = is_read_vint(fdt_in);
        for (i = field_cnt - 1; i >= 0 && fnum != field_num; i--) {
            fnum = is_read_vint(fdt_in);
            offset += is_read_vint(fdt_in); /* space taken by field */
        }

        if (fnum == field_num) {
            /* field was found */
            is_seek(fdt_in, field_index_ptr - (off_t)offset);
            tv = fr_read_term_vector(fr, field_num);
        }
    }
    return tv;
}

/****************************************************************************
 *
 * FieldsWriter
 *
 ****************************************************************************/

FieldsWriter *fw_open(Store *store, const char *segment, FieldInfos *fis)
{
    FieldsWriter *fw = ALLOC(FieldsWriter);
    char file_name[SEGMENT_NAME_MAX_LENGTH];
    size_t segment_len = strlen(segment);

    memcpy(file_name, segment, segment_len);

    strcpy(file_name + segment_len, ".fdt");
    fw->fdt_out = store->new_output(store, file_name);

    strcpy(file_name + segment_len, ".fdx");
    fw->fdx_out = store->new_output(store, file_name);

    fw->fis = fis;
    fw->tv_fields = ary_new_type_capa(TVField, TV_FIELD_INIT_CAPA);

    return fw;
}

void fw_close(FieldsWriter *fw)
{
    os_close(fw->fdt_out);
    os_close(fw->fdx_out);
    ary_free(fw->tv_fields);
    free(fw);
}

static __inline void save_data(OutStream *fdt_out, char *data, int dlen)
{
    os_write_vint(fdt_out, dlen);
    os_write_bytes(fdt_out, (uchar *)data, dlen);
}

void fw_add_doc(FieldsWriter *fw, Document *doc)
{
    int i, j, stored_cnt = 0;
    DocField *df;
    FieldInfo *fi;
    OutStream *fdt_out = fw->fdt_out, *fdx_out = fw->fdx_out;
    const int doc_size = doc->size;

    for (i = 0; i < doc_size; i++) {
        df = doc->fields[i];
        if (fi_is_stored(fis_get_or_add_field(fw->fis, df->name))) {
            stored_cnt++;
        }
    }

    fw->start_ptr = os_pos(fdt_out);
    ary_size(fw->tv_fields) = 0;
    os_write_u64(fdx_out, fw->start_ptr);
    os_write_vint(fdt_out, stored_cnt);

    for (i = 0; i < doc_size; i++) {
        df = doc->fields[i];
        fi = fis_get_field(fw->fis, df->name);
        if (fi_is_stored(fi)) {
            const int df_size = df->size;
            os_write_vint(fdt_out, fi->number);
            os_write_vint(fdt_out, df->size);
            /**
             * TODO: add compression
             */
            for (j = 0; j < df_size; j++) {
                os_write_vint(fdt_out, df->lengths[j]);
            }
            for (j = 0; j < df_size; j++) {
                os_write_bytes(fdt_out, (uchar *)df->data[j], df->lengths[j]);
                /* leave a space between fields as that is how they are
                 * analyzed */
                os_write_byte(fdt_out, ' ');
            }
        }
    }
}

void fw_write_tv_index(FieldsWriter *fw)
{
    int i;
    const int tv_cnt = ary_size(fw->tv_fields);
    OutStream *fdt_out = fw->fdt_out;
    os_write_u32(fw->fdx_out, (f_u32)(os_pos(fdt_out) - fw->start_ptr));
    os_write_vint(fdt_out, tv_cnt);
    /* write in reverse order so we can count back from the start position to
     * the beginning of the TermVector's data */
    for (i = tv_cnt - 1; i >= 0; i--) {
        os_write_vint(fdt_out, fw->tv_fields[i].field_num);
        os_write_vint(fdt_out, fw->tv_fields[i].size);
    }
}

void fw_add_postings(FieldsWriter *fw,
                     int field_num,
                     PostingList **plists,
                     int posting_count,
                     Offset *offsets,
                     int offset_count)
{
    int i, delta_start, delta_length;
    const char *last_term = EMPTY_STRING;
    OutStream *fdt_out = fw->fdt_out;
    off_t fdt_start_pos = os_pos(fdt_out);
    PostingList *plist;
    Posting *posting;
    Occurence *occ;
    FieldInfo *fi = fw->fis->fields[field_num];
    int store_positions = fi_store_positions(fi);

    ary_grow(fw->tv_fields);
    ary_last(fw->tv_fields).field_num = field_num;

    os_write_vint(fdt_out, posting_count);
    for (i = 0; i < posting_count; i++) {
        plist = plists[i];
        posting = plist->last;
        delta_start = hlp_string_diff(last_term, plist->term);
        delta_length = plist->term_len - delta_start;

        os_write_vint(fdt_out, delta_start);  /* write shared prefix length */
        os_write_vint(fdt_out, delta_length); /* write delta length */
        /* write delta chars */
        os_write_bytes(fdt_out,
                       (uchar *)(plist->term + delta_start),
                       delta_length);
        os_write_vint(fdt_out, posting->freq);
        last_term = plist->term;

        if (store_positions) {
            /* use delta encoding for positions */
            int last_pos = 0;
            for (occ = posting->first_occ; occ; occ = occ->next) {
                os_write_vint(fdt_out, occ->pos - last_pos);
                last_pos = occ->pos;
            }
        }

    }

    if (fi_store_offsets(fi)) {
        /* use delta encoding for offsets */
        int last_end = 0;
        os_write_vint(fdt_out, offset_count);  /* write shared prefix length */
        for (i = 0; i < offset_count; i++) {
            int start = offsets[i].start;
            int end = offsets[i].end;
            os_write_vint(fdt_out, start - last_end);
            os_write_vint(fdt_out, end - start);
            last_end = end;
        }
    }
    ary_last(fw->tv_fields).size = os_pos(fdt_out) - fdt_start_pos;
}

/****************************************************************************
 *
 * TermEnum
 *
 ****************************************************************************/

#define TE(ste) ((TermEnum *)ste)

char *te_get_term(TermEnum *te)
{
    return memcpy(ALLOC_N(char, te->curr_term_len + 1),
                  te->curr_term, te->curr_term_len + 1);
}

TermInfo *te_get_ti(TermEnum *te)
{
    return memcpy(ALLOC(TermInfo), &(te->curr_ti), sizeof(TermInfo));
}

char *te_skip_to(TermEnum *te, const char *term)
{
    char *curr_term = te->curr_term;
    if (strcmp(curr_term, term) < 0) {
        while (((curr_term = te->next(te)) != NULL) &&
               (strcmp(curr_term, term) < 0)) {
        }
    }
    return curr_term;
}

/****************************************************************************
 *
 * SegmentTermEnum
 *
 ****************************************************************************/

#define STE(te) ((SegmentTermEnum *)te)

/****************************************************************************
 * SegmentTermIndex
 ****************************************************************************/

static void sti_destroy(SegmentTermIndex *sti)
{
    if (sti->index_terms) {
        int i;
        const int sti_index_size = sti->index_size;
        for (i = 0; i < sti_index_size; i++) {
            free(sti->index_terms[i]);
        }
        free(sti->index_terms);
        free(sti->index_term_lens);
        free(sti->index_term_infos);
        free(sti->index_ptrs);
    }
    free(sti);
}

static void sti_ensure_index_is_read(SegmentTermIndex *sti,
                                     TermEnum *index_te)
{
    if (sti->index_terms == NULL) {
        int i;
        int index_size = sti->index_size;
        off_t index_ptr = 0;
        ste_reset(index_te);
        is_seek(STE(index_te)->is, sti->index_ptr);
        STE(index_te)->size = sti->index_size;
        
        sti->index_terms = ALLOC_N(char *, index_size);
        sti->index_term_lens = ALLOC_N(int, index_size);
        sti->index_term_infos = ALLOC_N(TermInfo, index_size);
        sti->index_ptrs = ALLOC_N(off_t, index_size);
        
        for (i = 0; NULL != ste_next(index_te); i++) {
#ifdef DEBUG
            if (i >= index_size) {
                RAISE(FERRET_ERROR, "index term enum read too many terms");
            }
#endif
            sti->index_terms[i] = te_get_term(index_te);
            sti->index_term_lens[i] = index_te->curr_term_len;
            sti->index_term_infos[i] = index_te->curr_ti;
            index_ptr += is_read_voff_t(STE(index_te)->is);
            sti->index_ptrs[i] = index_ptr;
        }
    }
}

static int sti_get_index_offset(SegmentTermIndex *sti, const char *term)
{
    int lo = 0;
    int hi = sti->index_size - 1;
    int mid, delta;
    char **index_terms = sti->index_terms;

    while (hi >= lo) {
        mid = (lo + hi) >> 1;
        delta = strcmp(term, index_terms[mid]);
        if (delta < 0) {
            hi = mid - 1;
        }
        else if (delta > 0) {
            lo = mid + 1;
        }
        else {
            return mid;
        }
    }
    return hi;
}

/****************************************************************************
 * SegmentFieldIndex
 ****************************************************************************/

#define SFI_ENSURE_INDEX_IS_READ(sfi, sti) do {\
    if (sti->index_terms == NULL) {\
        mutex_lock(&sfi->mutex);\
        sti_ensure_index_is_read(sti, sfi->index_te);\
        mutex_unlock(&sfi->mutex);\
    }\
} while (0)

SegmentFieldIndex *sfi_open(Store *store, const char *segment)
{
    int field_count;
    SegmentFieldIndex *sfi = ALLOC(SegmentFieldIndex);
    char file_name[SEGMENT_NAME_MAX_LENGTH];
    InStream *is;

    mutex_init(&sfi->mutex, NULL);

    sprintf(file_name, "%s.tfx", segment);
    is = store->open_input(store, file_name);
    field_count = (int)is_read_u32(is);
    sfi->index_interval = is_read_vint(is);
    sfi->skip_interval = is_read_vint(is);

    sfi->field_dict = h_new_int((free_ft)&sti_destroy);

    for (; field_count > 0; field_count--) {
        int field_num = is_read_vint(is);
        SegmentTermIndex *sti = ALLOC_AND_ZERO(SegmentTermIndex);
        sti->index_ptr = is_read_voff_t(is);
        sti->ptr = is_read_voff_t(is);
        sti->index_size = is_read_vint(is);
        sti->size = is_read_vint(is);
        h_set_int(sfi->field_dict, field_num, sti);
    }
    is_close(is);

    sprintf(file_name, "%s.tix", segment);
    is = store->open_input(store, file_name);
    sfi->index_te = ste_new(is, NULL);
    return sfi;
}

void sfi_close(SegmentFieldIndex *sfi)
{
    mutex_destroy(&sfi->mutex);
    ste_close(sfi->index_te);
    h_destroy(sfi->field_dict);
    free(sfi);
}

/****************************************************************************
 * SegmentTermEnum
 ****************************************************************************/

static __inline int term_read(char *buf, InStream *is)
{
    int start = (int)is_read_vint(is);
    int length = (int)is_read_vint(is);
    int total_length = start + length;
    is_read_bytes(is, (uchar *)(buf + start), length);
    buf[total_length] = '\0';
    return total_length;
}

static char *ste_next(TermEnum *te)
{
    TermInfo *ti;
    InStream *is = STE(te)->is;

    STE(te)->pos++;
    if (STE(te)->pos >= STE(te)->size) {
        te->curr_term[0] = '\0';
        te->curr_term_len = 0;
        return NULL;
    }

    memcpy(te->prev_term, te->curr_term, te->curr_term_len + 1);
    te->curr_term_len = term_read(te->curr_term, is);

    ti = &(te->curr_ti);
    ti->doc_freq = is_read_vint(is);     /* read doc freq */
    ti->frq_ptr += is_read_voff_t(is);/* read freq ptr */
    ti->prx_ptr += is_read_voff_t(is);/* read prox ptr */
    if (ti->doc_freq >= STE(te)->skip_interval) {
        ti->skip_offset = is_read_voff_t(is);
    }

    return te->curr_term;
}

static void ste_reset(TermEnum *te)
{
    STE(te)->pos = -1;
    te->curr_term[0] = '\0';
    te->curr_term_len = 0;
    ZEROSET(&(te->curr_ti), TermInfo);
}

static TermEnum *ste_set_field(TermEnum *te, int field_num)
{
    SegmentTermIndex *sti = h_get_int(STE(te)->sfi->field_dict, field_num);
    ste_reset(te);
    te->field_num = field_num;
    if (sti) {
        STE(te)->size = sti->size;
        is_seek(STE(te)->is, sti->ptr);
    }
    else {
        STE(te)->size = 0;
    }
    return te;
}

static void ste_index_seek(TermEnum *te, SegmentTermIndex *sti, int idx_offset)
{
    int term_len = sti->index_term_lens[idx_offset];
    is_seek(STE(te)->is, sti->index_ptrs[idx_offset]);
    STE(te)->pos = STE(te)->sfi->index_interval * idx_offset - 1;
    memcpy(te->curr_term,
           sti->index_terms[idx_offset],
           term_len + 1);
    te->curr_term_len = term_len;
    te->curr_ti = sti->index_term_infos[idx_offset];
}

static char *ste_scan_to(TermEnum *te, const char *term)
{
    SegmentFieldIndex *sfi = STE(te)->sfi;
    SegmentTermIndex *sti = h_get_int(sfi->field_dict, te->field_num);
    if (sti && sti->size > 0) {
        SFI_ENSURE_INDEX_IS_READ(sfi, sti);
        if (term[0] == '\0') {
            ste_index_seek(te, sti, 0);
            return ste_next(te);;
        }
        /* if current term is less than seek term */
        if (STE(te)->pos < STE(te)->size && strcmp(te->curr_term, term) <= 0) {
            int enum_offset = (int)(STE(te)->pos / sfi->index_interval) + 1;
            /* if we are at the end of the index or before the next index
             * ptr then a simple scan suffices */
            if (sti->index_size == enum_offset ||
                strcmp(term, sti->index_terms[enum_offset]) < 0) { 
                return te_skip_to(te, term);
            }
        }
        ste_index_seek(te, sti, sti_get_index_offset(sti, term));
        return te_skip_to(te, term);
    }
    else {
        return NULL;
    }
}

static SegmentTermEnum *ste_allocate()
{
    SegmentTermEnum *ste = ALLOC_AND_ZERO(SegmentTermEnum);

    TE(ste)->next = &ste_next;
    TE(ste)->set_field = &ste_set_field;
    TE(ste)->skip_to = &ste_scan_to;
    TE(ste)->close = &ste_close;
    return ste;
}

TermEnum *ste_clone(TermEnum *other_te)
{
    SegmentTermEnum *ste = ste_allocate();

    memcpy(ste, other_te, sizeof(SegmentTermEnum));
    ste->is = is_clone(STE(other_te)->is);
    return TE(ste);
}

void ste_close(TermEnum *te)
{
    is_close(STE(te)->is);
    free(te);
}

/*
static TermInfo *ste_scan_for_term_info(SegmentTermEnum *ste, const char *term)
{
    ste_scan_to(ste, term);

    if (strcmp(TE(ste)->curr_term, term) == 0) {
        return te_get_ti((TermEnum *)ste);
    }
    else {
        return NULL;
    }
}
*/

static char *ste_get_term(TermEnum *te, int pos)
{
    SegmentTermEnum *ste = STE(te);
    if (pos >= ste->size) {
        return NULL;
    }
    else if (pos != ste->pos) {
        int idx_int = ste->sfi->index_interval;
        if ((pos < ste->pos) || pos > (1 + ste->pos / idx_int) * idx_int) {
            SegmentTermIndex *sti = h_get_int(ste->sfi->field_dict,
                                              te->field_num);
            SFI_ENSURE_INDEX_IS_READ(ste->sfi, sti);
            ste_index_seek(te, sti, pos / idx_int);
        }
        while (ste->pos < pos) {
            if (ste_next(te) == NULL) {
                return NULL;
            }
        }

    }
    return te->curr_term;
}

TermEnum *ste_new(InStream *is, SegmentFieldIndex *sfi)
{
    SegmentTermEnum *ste = ste_allocate();

    TE(ste)->field_num = -1;
    ste->is = is;
    ste->size = 0;
    ste->pos = -1;
    ste->sfi = sfi;
    ste->skip_interval = sfi ? sfi->skip_interval : INT_MAX;

    return TE(ste);
}

/****************************************************************************
 * MultiTermEnum
 ****************************************************************************/

#define MTE(te) ((MultiTermEnum *)(te))

typedef struct TermEnumWrapper
{
    int base;
    TermEnum *te;
    int *doc_map;
    IndexReader *ir;
    char *term;
} TermEnumWrapper;

typedef struct MultiTermEnum
{
    TermEnum te;
    int doc_freq;
    PriorityQueue *tew_queue;
    TermEnumWrapper *tews;
    int size;
    int **field_num_map;
} MultiTermEnum;

static bool tew_lt(const TermEnumWrapper *tew1, const TermEnumWrapper *tew2)
{
    int cmpres = strcmp(tew1->term, tew2->term);
    if (cmpres == 0) {
        return tew1->base < tew2->base;
    }
    else {
        return cmpres < 0;
    }
}

/*
static void tew_load_doc_map(TermEnumWrapper *tew)
{
    int j = 0, i;
    IndexReader *ir = tew->ir;
    int max_doc = ir->max_doc(ir);
    int *doc_map = tew->doc_map = ALLOC_N(int, max_doc);

    for (i = 0; i < max_doc; i++) {
        if (ir->is_deleted(ir, i)) {
            doc_map[i] = -1;
        }
        else {
            doc_map[i] = j++;
        }
    }
}
*/

static char *tew_next(TermEnumWrapper *tew)
{
    return (tew->term = tew->te->next(tew->te));
}

static char *tew_skip_to(TermEnumWrapper *tew, const char *term)
{
    return (tew->term = tew->te->skip_to(tew->te, term));
}

static void tew_destroy(TermEnumWrapper *tew)
{
    if (tew->doc_map) {
        free(tew->doc_map);
    }
    tew->te->close(tew->te);
}

TermEnumWrapper *tew_setup(TermEnumWrapper *tew, int base, TermEnum *te,
                           IndexReader *ir)
{
    tew->base = base;
    tew->ir = ir;
    tew->te = te;
    tew->term = te->curr_term;
    tew->doc_map = NULL;
    return tew;
}


static char *mte_next(TermEnum *te)
{
    TermEnumWrapper *top =
        (TermEnumWrapper *)pq_top(MTE(te)->tew_queue);

    if (top == NULL) {
        te->curr_term[0] = '\0';
        te->curr_term_len = 0;
        return false;
    }

    memcpy(te->prev_term, te->curr_term, te->curr_term_len + 1);
    memcpy(te->curr_term, top->term, top->te->curr_term_len + 1);
    te->curr_term_len = top->te->curr_term_len;

    te->curr_ti.doc_freq = 0;

    while ((top != NULL) && (strcmp(te->curr_term, top->term) == 0)) {
        pq_pop(MTE(te)->tew_queue);
        te->curr_ti.doc_freq += top->te->curr_ti.doc_freq;/* increment freq */
        if (tew_next(top)) {
            pq_push(MTE(te)->tew_queue, top); /* restore queue */
        }
        top = (TermEnumWrapper *)pq_top(MTE(te)->tew_queue);
    }
    return te->curr_term;
}

static TermEnum *mte_set_field(TermEnum *te, int field_num)
{
    MultiTermEnum *mte = MTE(te);
    int i;
    const int size = mte->size;
    te->field_num = field_num;
    mte->tew_queue->size = 0;
    for (i = 0; i < size; i++) {
        TermEnumWrapper *tew = &(mte->tews[i]);
        TermEnum *sub_te = tew->te;
        int fnum = mte->field_num_map
            ? mte->field_num_map[i][field_num]
            : field_num;

        if (fnum >= 0) {
            sub_te->set_field(sub_te, fnum);

            if (tew_next(tew)) {
                pq_push(mte->tew_queue, tew); /* initialize queue */
            }
        }
        else {
            sub_te->field_num = -1;
        }

    }
    return te;
}

static char *mte_skip_to(TermEnum *te, const char *term)
{
    MultiTermEnum *mte = MTE(te);
    int i;
    const int size = mte->size;

    mte->tew_queue->size = 0;
    for (i = 0; i < size; i++) {
        TermEnumWrapper *tew = &(mte->tews[i]);

        if (tew->te->field_num >= 0 && tew_skip_to(tew, term)) {
            pq_push(mte->tew_queue, tew); /* initialize queue */
        }
    }
    return mte_next(te);
}

static void mte_close(TermEnum *te)
{
    int i;
    const int size = MTE(te)->size;
    for (i = 0; i < size; i++) {
        tew_destroy(&(MTE(te)->tews[i]));
    }
    free(MTE(te)->tews);
    pq_destroy(MTE(te)->tew_queue);
    free(te);
}

TermEnum *mte_new(MultiReader *mr, int field_num, const char *term)
{
    IndexReader **readers   = mr->sub_readers;
    int *starts             = mr->starts;
    int r_cnt               = mr->r_cnt;
    int i;
    IndexReader *reader;
    MultiTermEnum *mte  = ALLOC_AND_ZERO(MultiTermEnum);

    TE(mte)->field_num  = field_num;
    TE(mte)->next       = &mte_next;
    TE(mte)->set_field  = &mte_set_field;
    TE(mte)->skip_to    = &mte_skip_to;
    TE(mte)->close      = &mte_close;

    mte->size           = r_cnt;
    mte->tews           = ALLOC_AND_ZERO_N(TermEnumWrapper, r_cnt);
    mte->tew_queue      = pq_new(r_cnt, (lt_ft)&tew_lt, (free_ft)NULL);
    mte->field_num_map  = mr->field_num_map;

    for (i = 0; i < r_cnt; i++) {
        int fnum = mr_get_field_num(mr, i, field_num);
        TermEnum *sub_te;
        reader = readers[i];

        if (fnum >= 0) {
            TermEnumWrapper *tew;

            if (term != NULL) {
                sub_te = reader->terms_from(reader, fnum, term);
            }
            else {
                sub_te = reader->terms(reader, fnum);
            }

            tew = tew_setup(&(mte->tews[i]), starts[i], sub_te, reader);
            if (((term == NULL) && tew_next(tew))
                || (tew->term && (tew->term[0] != '\0'))) {
                pq_push(mte->tew_queue, tew);          /* initialize queue */
            }
        } else {
            /* add the term_enum_wrapper just in case */
            sub_te = reader->terms(reader, 0);
            sub_te->field_num = -1;
            tew_setup(&(mte->tews[i]), starts[i], sub_te, reader);
        }
    }

    if ((term != NULL) && (mte->tew_queue->size > 0)) {
        mte_next(TE(mte));
    }

    return TE(mte);
}

/****************************************************************************
 *
 * TermInfosReader
 * (Segment Specific)
 *
 ****************************************************************************/

TermInfosReader *tir_open(Store *store,
                          SegmentFieldIndex *sfi, const char *segment)
{
    TermInfosReader *tir = ALLOC(TermInfosReader);
    char file_name[SEGMENT_NAME_MAX_LENGTH];

    sprintf(file_name, "%s.tis", segment);
    tir->orig_te = ste_new(store->open_input(store, file_name), sfi);
    thread_key_create(&tir->thread_te, NULL);
    tir->te_bucket = ary_new();
    tir->field_num = -1;

    return tir;
}

static __inline TermEnum *tir_enum(TermInfosReader *tir)
{
    TermEnum *te;
    if ((te = thread_getspecific(tir->thread_te)) == NULL) {
        te = ste_clone(tir->orig_te);
        ste_set_field(te, tir->field_num);
        ary_push(tir->te_bucket, te);
        thread_setspecific(tir->thread_te, te);
    }
    return te;
}

TermInfosReader *tir_set_field(TermInfosReader *tir, int field_num)
{
    if (field_num != tir->field_num) {
        ste_set_field(tir_enum(tir), field_num);
        tir->field_num = field_num;
    }
    return tir;
}

TermInfo *tir_get_ti(TermInfosReader *tir, const char *term)
{
    TermEnum *te = tir_enum(tir);
    char *match;

    if ((match = ste_scan_to(te, term)) != NULL && 
        strcmp(match, term) == 0) {
        return &(te->curr_ti);
    }
    return NULL;
}

TermInfo *tir_get_ti_field(TermInfosReader *tir, int field_num,
                           const char *term)
{
    TermEnum *te = tir_enum(tir);
    char *match;

    if (field_num != tir->field_num) {
        ste_set_field(te, field_num);
        tir->field_num = field_num;
    }

    if ((match = ste_scan_to(te, term)) != NULL && 
        strcmp(match, term) == 0) {
        return &(te->curr_ti);
    }
    return NULL;
}

char *tir_get_term(TermInfosReader *tir, int pos)
{ 
    if (pos < 0) {
        return NULL;
    }
    else {
        return ste_get_term(tir_enum(tir), pos);
    }
}

void tir_close(TermInfosReader *tir)
{
    ary_destroy(tir->te_bucket, (free_ft)&ste_close);
    ste_close(tir->orig_te);

    /* fix for some dodgy old versions of pthread */
    thread_setspecific(tir->thread_te, NULL);

    thread_key_delete(tir->thread_te);
    free(tir);
}

/****************************************************************************
 *
 * TermInfosWriter
 *
 ****************************************************************************/

static TermWriter *tw_new(Store *store, char *file_name)
{
    TermWriter *tw = ALLOC_AND_ZERO(TermWriter);
    tw->os = store->new_output(store, file_name);
    tw->last_term = EMPTY_STRING;
    return tw;
}

static void tw_close(TermWriter *tw)
{
    os_close(tw->os);
    free(tw);
}

TermInfosWriter *tiw_open(Store *store,
                          const char *segment,
                          int index_interval,
                          int skip_interval)
{
    char file_name[SEGMENT_NAME_MAX_LENGTH];
    TermInfosWriter *tiw = ALLOC(TermInfosWriter);
    size_t segment_len = strlen(segment);

    memcpy(file_name, segment, segment_len);

    tiw->field_count = 0;
    tiw->index_interval = index_interval;
    tiw->skip_interval = skip_interval;
    tiw->last_index_ptr = 0;

    strcpy(file_name + segment_len, ".tix");
    tiw->tix_writer = tw_new(store, file_name);
    strcpy(file_name + segment_len, ".tis");
    tiw->tis_writer = tw_new(store, file_name);
    strcpy(file_name + segment_len, ".tfx");
    tiw->tfx_out = store->new_output(store, file_name);
    os_write_u32(tiw->tfx_out, 0); /* make space for field_count */

    /* The following two numbers are the first numbers written to the field
     * index when tiw_start_field is called. But they'll be zero to start with
     * so we'll write index interval and skip interval instead. */
    tiw->tix_writer->counter = tiw->index_interval;
    tiw->tis_writer->counter = tiw->skip_interval;

    return tiw;
}

static __inline void tw_write_term(TermWriter *tw,
                                 OutStream *os,
                                 const char *term,
                                 int term_len)
{
    int start = hlp_string_diff(tw->last_term, term);
    int length = term_len - start;

    os_write_vint(os, start);                   /* write shared prefix length */
    os_write_vint(os, length);                  /* write delta length */
    os_write_bytes(os, (uchar *)(term + start), length);   /* write delta chars */

    tw->last_term = term;
}

static void tw_add(TermWriter *tw,
                   const char *term,
                   int term_len,
                   TermInfo *ti)
{
    OutStream *os = tw->os;

#ifdef DEBUG
    if (strcmp(tw->last_term, term) > 0) {
        RAISE(STATE_ERROR, "\"%s\" > \"%s\" %d > %d", tw->last_term, term, *tw->last_term, *term);
    }
    if (ti->frq_ptr < tw->last_term_info.frq_ptr) {
        RAISE(STATE_ERROR, "%"F_OFF_T_PFX"d > %"F_OFF_T_PFX"d", ti->frq_ptr,
              tw->last_term_info.frq_ptr);
    }
    if (ti->prx_ptr < tw->last_term_info.prx_ptr) {
        RAISE(STATE_ERROR, "%"F_OFF_T_PFX"d > %"F_OFF_T_PFX"d", ti->prx_ptr,
              tw->last_term_info.prx_ptr);
    }
#endif

    tw_write_term(tw, os, term, term_len);  /* write term */
    os_write_vint(os, ti->doc_freq);        /* write doc freq */
    os_write_voff_t(os, ti->frq_ptr - tw->last_term_info.frq_ptr);
    os_write_voff_t(os, ti->prx_ptr - tw->last_term_info.prx_ptr);

    tw->last_term_info = *ti;
    tw->counter++;
}

void tiw_add(TermInfosWriter *tiw,
             const char *term,
             int term_len,
             TermInfo *ti)
{
    off_t tis_pos;

    /*
    printf("%s:%d:%d:%d:%d\n", term, term_len, ti->doc_freq,
           ti->frq_ptr, ti->prx_ptr);
    */
    if ((tiw->tis_writer->counter % tiw->index_interval) == 0) {
        /* add an index term */
        tw_add(tiw->tix_writer,
               tiw->tis_writer->last_term,
               strlen(tiw->tis_writer->last_term),
               &(tiw->tis_writer->last_term_info));
        tis_pos = os_pos(tiw->tis_writer->os);
        os_write_voff_t(tiw->tix_writer->os, tis_pos - tiw->last_index_ptr);
        tiw->last_index_ptr = tis_pos;  /* write ptr */
    }

    tw_add(tiw->tis_writer, term, term_len, ti);

    if (ti->doc_freq >= tiw->skip_interval) {
        os_write_voff_t(tiw->tis_writer->os, ti->skip_offset);
    }
}

static __inline void tw_reset(TermWriter *tw)
{
    tw->counter = 0;
    tw->last_term = EMPTY_STRING;
    ZEROSET(&(tw->last_term_info), TermInfo);
}

void tiw_start_field(TermInfosWriter *tiw, int field_num)
{
    OutStream *tfx_out = tiw->tfx_out;
    os_write_vint(tfx_out, tiw->tix_writer->counter);    /* write tix size */
    os_write_vint(tfx_out, tiw->tis_writer->counter);    /* write tis size */
    os_write_vint(tfx_out, field_num);
    os_write_voff_t(tfx_out, os_pos(tiw->tix_writer->os)); /* write tix ptr */
    os_write_voff_t(tfx_out, os_pos(tiw->tis_writer->os)); /* write tis ptr */
    tw_reset(tiw->tix_writer);
    tw_reset(tiw->tis_writer);
    tiw->last_index_ptr = 0;
    tiw->field_count++;
}

void tiw_close(TermInfosWriter *tiw)
{
    OutStream *tfx_out = tiw->tfx_out;
    os_write_vint(tfx_out, tiw->tix_writer->counter);
    os_write_vint(tfx_out, tiw->tis_writer->counter);
    os_seek(tfx_out, 0);
    os_write_u32(tfx_out, tiw->field_count);
    os_close(tfx_out);

    tw_close(tiw->tix_writer);
    tw_close(tiw->tis_writer);

    free(tiw);
}

/****************************************************************************
 *
 * TermDocEnum
 *
 ****************************************************************************/

/****************************************************************************
 * SegmentTermDocEnum
 ****************************************************************************/

#define STDE(tde) ((SegmentTermDocEnum *)(tde))
#define TDE(stde) ((TermDocEnum *)(stde))

#define CHECK_STATE(method) do {\
    if (STDE(tde)->count == 0) {\
        RAISE(STATE_ERROR, "Illegal state of TermDocEnum. You must call #next "\
              "before you call #"method);\
    }\
} while (0)

static void stde_seek_ti(SegmentTermDocEnum *stde, TermInfo *ti)
{
    if (ti == NULL) {
        stde->doc_freq = 0;
    }
    else {
        stde->count = 0;
        stde->doc_freq = ti->doc_freq;
        stde->doc_num = 0;
        stde->skip_doc = 0;
        stde->skip_count = 0;
        stde->num_skips = stde->doc_freq / stde->skip_interval;
        stde->frq_ptr = ti->frq_ptr;
        stde->prx_ptr = ti->prx_ptr;
        stde->skip_ptr = ti->frq_ptr + ti->skip_offset;
        is_seek(stde->frq_in, ti->frq_ptr);
        stde->have_skipped = false;
    }
}

static void stde_seek(TermDocEnum *tde, int field_num, const char *term)
{
    TermInfo *ti = tir_get_ti_field(STDE(tde)->tir, field_num, term);
    stde_seek_ti(STDE(tde), ti);
}

static void stde_seek_te(TermDocEnum *tde, TermEnum *te)
{
#ifdef DEBUG
    if (te->set_field != &ste_set_field) {
        RAISE(ARG_ERROR, "Passed an incorrect TermEnum type");
    }
#endif
    stde_seek_ti(STDE(tde), &(te->curr_ti));
}

static int stde_doc_num(TermDocEnum *tde)
{
    CHECK_STATE("doc_num");
    return STDE(tde)->doc_num;
}

static int stde_freq(TermDocEnum *tde)
{
    CHECK_STATE("freq");
    return STDE(tde)->freq;
}

static bool stde_next(TermDocEnum *tde)
{
    int doc_code;
    SegmentTermDocEnum *stde = STDE(tde);

    while (true) { 
        if (stde->count >= stde->doc_freq) {
            return false;
        }

        doc_code = is_read_vint(stde->frq_in);
        stde->doc_num += doc_code >> 1;    /* shift off low bit */
        if ((doc_code & 1) != 0) {         /* if low bit is set */
            stde->freq = 1;                /* freq is one */
        }
        else {
            stde->freq = (int)is_read_vint(stde->frq_in); /* read freq */
        }

        stde->count++;

        if (stde->deleted_docs == NULL ||
            bv_get(stde->deleted_docs, stde->doc_num) == 0) {
            break; /* We found an undeleted doc so return */
        }

        stde->skip_prox(stde);
    }
    return true;
}

static int stde_read(TermDocEnum *tde, int *docs, int *freqs, int req_num)
{
    SegmentTermDocEnum *stde = STDE(tde);
    int i = 0;
    int doc_code;

    while (i < req_num && stde->count < stde->doc_freq) {
        /* manually inlined call to next() for speed */
        doc_code = is_read_vint(stde->frq_in);
        stde->doc_num += (doc_code >> 1);            /* shift off low bit */
        if ((doc_code & 1) != 0) {                   /* if low bit is set */
            stde->freq = 1;                            /* freq is one */
        }
        else {
            stde->freq = is_read_vint(stde->frq_in);  /* else read freq */
        }

        stde->count++;

        if (stde->deleted_docs == NULL ||
            bv_get(stde->deleted_docs, stde->doc_num) == 0) {
            docs[i] = stde->doc_num;
            freqs[i] = stde->freq;
            i++;
        }
    }
    return i;
}

static bool stde_skip_to(TermDocEnum *tde, int target_doc_num)
{
    SegmentTermDocEnum *stde = STDE(tde);

    if (stde->doc_freq >= stde->skip_interval) { /* optimized case */
        int last_skip_doc;
        int last_frq_ptr;
        int last_prx_ptr;
        int num_skipped;

        if (stde->skip_in == NULL) {
            stde->skip_in = is_clone(stde->frq_in); /* lazily clone */
        }

        if (!stde->have_skipped) {                 /* lazily seek skip stream */
            is_seek(stde->skip_in, stde->skip_ptr);
            stde->have_skipped = true;
        }

        /* scan skip data */
        last_skip_doc = stde->skip_doc;
        last_frq_ptr = is_pos(stde->frq_in);
        last_prx_ptr = -1;
        num_skipped = -1 - (stde->count % stde->skip_interval);

        while (target_doc_num > stde->skip_doc) {
            last_skip_doc = stde->skip_doc;
            last_frq_ptr = stde->frq_ptr;
            last_prx_ptr = stde->prx_ptr;

            if (stde->skip_doc != 0 && stde->skip_doc >= stde->doc_num) {
                num_skipped += stde->skip_interval;
            }

            if (stde->skip_count >= stde->num_skips) {
                break;
            }

            stde->skip_doc += is_read_vint(stde->skip_in);
            stde->frq_ptr += is_read_vint(stde->skip_in);
            stde->prx_ptr += is_read_vint(stde->skip_in);

            stde->skip_count++;
        }

        /* if we found something to skip, so skip it */
        if (last_frq_ptr > is_pos(stde->frq_in)) {
            is_seek(stde->frq_in, last_frq_ptr);
            stde->seek_prox(stde, last_prx_ptr);

            stde->doc_num = last_skip_doc;
            stde->count += num_skipped;
        }
    }

    /* done skipping, now just scan */
    do { 
        if (!tde->next(tde)) {
            return false;
        }
    } while (target_doc_num > stde->doc_num);
    return true;
}

static void stde_close(TermDocEnum *tde)
{
    is_close(STDE(tde)->frq_in);

    if (STDE(tde)->skip_in != NULL) {
        is_close(STDE(tde)->skip_in);
    }

    free(tde);
}

static void stde_skip_prox(SegmentTermDocEnum *stde)
{ 
    (void)stde;
}

static void stde_seek_prox(SegmentTermDocEnum *stde, int prx_ptr)
{ 
    (void)stde;
    (void)prx_ptr;
}


TermDocEnum *stde_new(TermInfosReader *tir,
                      InStream *frq_in,
                      BitVector *deleted_docs,
                      int skip_interval)
{
    SegmentTermDocEnum *stde = ALLOC_AND_ZERO(SegmentTermDocEnum);
    TermDocEnum *tde         = (TermDocEnum *)stde;

    /* TermDocEnum methods */
    tde->seek                = &stde_seek;
    tde->seek_te             = &stde_seek_te;
    tde->doc_num             = &stde_doc_num;
    tde->freq                = &stde_freq;
    tde->next                = &stde_next;
    tde->read                = &stde_read;
    tde->skip_to             = &stde_skip_to;
    tde->next_position       = NULL;
    tde->close               = &stde_close;

    /* SegmentTermDocEnum methods */
    stde->skip_prox          = &stde_skip_prox;
    stde->seek_prox          = &stde_seek_prox;

    /* Attributes */
    stde->tir                = tir;
    stde->frq_in             = is_clone(frq_in);
    stde->deleted_docs       = deleted_docs;
    stde->skip_interval      = skip_interval;

    return tde;
}

/****************************************************************************
 * SegmentTermPosEnum
 ****************************************************************************/

static void stpe_seek_ti(SegmentTermDocEnum *stde, TermInfo *ti)
{
    if (ti == NULL) {
        stde->doc_freq = 0;
    }
    else {
        stde_seek_ti(stde, ti);
        is_seek(stde->prx_in, ti->prx_ptr);
    }
}

static void stpe_seek(TermDocEnum *tde, int field_num, const char *term)
{
    SegmentTermDocEnum *stde = STDE(tde);
    TermInfo *ti = tir_get_ti_field(stde->tir, field_num, term);
    stpe_seek_ti(stde, ti);
    stde->prx_cnt = 0;
}

bool stpe_next(TermDocEnum *tde)
{
    SegmentTermDocEnum *stde = STDE(tde);
    is_skip_vints(stde->prx_in, stde->prx_cnt);

    /* if super */
    if (stde_next(tde)) {
        stde->prx_cnt = stde->freq;
        stde->position = 0;
        return true;
    }
    else {
        stde->prx_cnt = stde->position = 0;
        return false;
    }
}

int stpe_read(TermDocEnum *tde, int *docs, int *freqs, int req_num)
{
    (void)tde; (void)docs; (void)freqs; (void)req_num;
    RAISE(ARG_ERROR, "TermPosEnum does not handle processing multiple documents"
                     " in one call. Use TermDocEnum instead.");
    return -1;
}

static int stpe_next_position(TermDocEnum *tde)
{
    SegmentTermDocEnum *stde = STDE(tde);
    return (stde->prx_cnt-- > 0) ? stde->position += is_read_vint(stde->prx_in)
                                 : -1;
}

static void stpe_close(TermDocEnum *tde)
{
    is_close(STDE(tde)->prx_in);
    STDE(tde)->prx_in = NULL;
    stde_close(tde);
}

static void stpe_skip_prox(SegmentTermDocEnum *stde)
{
    is_skip_vints(stde->prx_in, stde->freq);
}

static void stpe_seek_prox(SegmentTermDocEnum *stde, int prx_ptr)
{
    is_seek(stde->prx_in, prx_ptr);
    stde->prx_cnt = 0;
}

TermDocEnum *stpe_new(TermInfosReader *tir,
                      InStream *frq_in,
                      InStream *prx_in,
                      BitVector *del_docs,
                      int skip_interval)
{
    TermDocEnum *tde         = stde_new(tir, frq_in, del_docs, skip_interval);
    SegmentTermDocEnum *stde = STDE(tde);

    /* TermDocEnum methods */
    tde->seek                = &stpe_seek;
    tde->next                = &stpe_next;
    tde->read                = &stpe_read;
    tde->next_position       = &stpe_next_position;
    tde->close               = &stpe_close;

    /* SegmentTermDocEnum methods */
    stde->skip_prox          = &stpe_skip_prox;
    stde->seek_prox          = &stpe_seek_prox;

    /* Attributes */
    stde->prx_in             = is_clone(prx_in);
    stde->prx_cnt            = 0;
    stde->position           = 0;

    return tde;
}

/****************************************************************************
 * MultiTermDocEnum
 ****************************************************************************/

#define MTDE(tde) ((MultiTermDocEnum *)(tde))

typedef struct MultiTermDocEnum
{
    TermDocEnum tde;
    int *starts;
    char *term;
    int field_num;
    int base;
    int ptr;
    int ir_cnt;
    int **field_num_map;
    IndexReader **irs;
    TermDocEnum **irs_tde;
    TermDocEnum *curr_tde;
    TermDocEnum *(*reader_tde_i)(IndexReader *ir);
} MultiTermDocEnum;

static TermDocEnum *mtde_reader_tde_i(IndexReader *ir)
{
    return ir->term_docs(ir);
}

static TermDocEnum *mtde_get_tde_i(MultiTermDocEnum *mtde, int i)
{
    if (mtde->term == NULL) {
        return NULL;
    }
    else {
        int fnum = mtde->field_num_map
            ? mtde->field_num_map[i][mtde->field_num]
            : mtde->field_num;

        if (fnum >= 0) {
            TermDocEnum *tde = mtde->irs_tde[i];
            if (tde == NULL) {
                tde = mtde->irs_tde[i] = mtde->reader_tde_i(mtde->irs[i]);
            }

            tde->seek(tde, fnum, mtde->term);
            return tde;
        }
        else {
            return NULL;
        }
    }
}

#define CHECK_CURR_TDE(method) do {\
    if (MTDE(tde)->curr_tde == NULL) {\
        RAISE(STATE_ERROR, "Illegal state of TermDocEnum. You must call #next "\
              "before you call #"method);\
    }\
} while (0)

static void mtde_seek(TermDocEnum *tde, int field_num, const char *term)
{
    MultiTermDocEnum *mtde = MTDE(tde);
    if (mtde->term != NULL) {
        free(mtde->term);
    }
    mtde->term = estrdup(term);
    mtde->field_num = field_num;
    mtde->base = 0;
    mtde->ptr = 0;
    mtde->curr_tde = NULL;
}

static void mtde_seek_te(TermDocEnum *tde, TermEnum *te)
{
    MultiTermDocEnum *mtde = MTDE(tde);
    if (mtde->term != NULL) {
        free(mtde->term);
    }
    mtde->term = estrdup(te->curr_term);
    mtde->field_num = te->field_num;
    mtde->base = 0;
    mtde->ptr = 0;
    mtde->curr_tde = NULL;
}

static int mtde_doc_num(TermDocEnum *tde)
{
    CHECK_CURR_TDE("doc_num");
    return MTDE(tde)->base + MTDE(tde)->curr_tde->doc_num(MTDE(tde)->curr_tde);
}

static int mtde_freq(TermDocEnum *tde)
{
    CHECK_CURR_TDE("freq");
    return MTDE(tde)->curr_tde->freq(MTDE(tde)->curr_tde);
}

static bool mtde_next(TermDocEnum *tde)
{
    MultiTermDocEnum *mtde = MTDE(tde);
    if (mtde->curr_tde != NULL && mtde->curr_tde->next(mtde->curr_tde)) {
        return true;
    }
    else if (mtde->ptr < mtde->ir_cnt) {
        mtde->base = mtde->starts[mtde->ptr];
        mtde->curr_tde = mtde_get_tde_i(mtde, mtde->ptr);
        mtde->ptr++;
        return mtde_next(tde);
    }
    else {
        return false;
    }
}

static int mtde_read(TermDocEnum *tde, int *docs, int *freqs, int req_num)
{
    int i, end = 0, last_end = 0, b;
    MultiTermDocEnum *mtde = MTDE(tde);
    while (true) {
        while (mtde->curr_tde == NULL) {
            if (mtde->ptr < mtde->ir_cnt) { /* try next segment */
                mtde->base = mtde->starts[mtde->ptr];
                mtde->curr_tde = mtde_get_tde_i(mtde, mtde->ptr++);
            }
            else {
                return end;
            }
        }
        end += mtde->curr_tde->read(mtde->curr_tde, docs + last_end,
                                    freqs + last_end, req_num - last_end);
        if (end == last_end) {              /* none left in segment */
            mtde->curr_tde = NULL;
        }
        else {                            /* got some */
            b = mtde->base;                 /* adjust doc numbers */
            for (i = last_end; i < end; i++) {
                docs[i] += b;
            }
            if (end == req_num) {
                return end;
            }
            else {
                last_end = end;
            }
        }
    }
}

static bool mtde_skip_to(TermDocEnum *tde, int target_doc_num)
{
    MultiTermDocEnum *mtde = MTDE(tde);
    TermDocEnum *curr_tde;
    while (mtde->ptr < mtde->ir_cnt) {
        curr_tde = mtde->curr_tde;
        if (curr_tde && (target_doc_num < mtde->starts[mtde->ptr]) &&
            (curr_tde->skip_to(curr_tde, target_doc_num - mtde->base))) {
            return true;
        }

        mtde->base = mtde->starts[mtde->ptr];
        mtde->curr_tde = mtde_get_tde_i(mtde, mtde->ptr);
        mtde->ptr++;
    }

    curr_tde = mtde->curr_tde;
    if (curr_tde) {
        return curr_tde->skip_to(curr_tde, target_doc_num - mtde->base);
    }
    else {
        return false;
    }
}

static void mtde_close(TermDocEnum *tde)
{
    MultiTermDocEnum *mtde = MTDE(tde);
    TermDocEnum *tmp_tde;
    int i = mtde->ir_cnt;
    while (i > 0) {
        i--;
        if ((tmp_tde = mtde->irs_tde[i]) != NULL) {
            tmp_tde->close(tmp_tde);
        }
    }
    if (mtde->term != NULL) {
        free(mtde->term);
    }
    free(mtde->irs_tde);
    free(tde);
}

TermDocEnum *mtde_new(MultiReader *mr)
{
    MultiTermDocEnum *mtde  = ALLOC_AND_ZERO(MultiTermDocEnum);
    TermDocEnum *tde        = TDE(mtde);
    tde->seek               = &mtde_seek;
    tde->seek_te            = &mtde_seek_te;
    tde->doc_num            = &mtde_doc_num;
    tde->freq               = &mtde_freq;
    tde->next               = &mtde_next;
    tde->read               = &mtde_read;
    tde->skip_to            = &mtde_skip_to;
    tde->next_position      = NULL;
    tde->close              = &mtde_close;

    mtde->starts            = mr->starts;
    mtde->ir_cnt            = mr->r_cnt;
    mtde->irs               = mr->sub_readers;
    mtde->field_num_map     = mr->field_num_map;
    mtde->irs_tde           = ALLOC_AND_ZERO_N(TermDocEnum *, mr->r_cnt);
    mtde->reader_tde_i      = &mtde_reader_tde_i;

    return tde;
}

/****************************************************************************
 * MultiTermPosEnum
 ****************************************************************************/

TermDocEnum *mtpe_reader_tde_i(IndexReader *ir)
{
    return ir->term_positions(ir);
}

int mtpe_next_position(TermDocEnum *tde)
{
    CHECK_CURR_TDE("next_position");
    return MTDE(tde)->curr_tde->next_position(MTDE(tde)->curr_tde);
}

TermDocEnum *mtpe_new(MultiReader *mr)
{
    TermDocEnum *tde        = mtde_new(mr);
    tde->next_position      = &mtpe_next_position;
    MTDE(tde)->reader_tde_i = &mtpe_reader_tde_i;
    return tde;
}

/****************************************************************************
 * MultipleTermDocPosEnum
 *
 * This enumerator is used by MultiPhraseQuery
 ****************************************************************************/

#define MTDPE(tde) ((MultipleTermDocPosEnum *)(tde))
#define  MTDPE_POS_QUEUE_INIT_CAPA 8

typedef struct
{
    TermDocEnum tde;
    int doc_num;
    int freq;
    PriorityQueue *pq;
    int *pos_queue;
    int pos_queue_index;
    int pos_queue_capa;
    int field_num;
} MultipleTermDocPosEnum;

static void tde_destroy(TermDocEnum *tde) {
    tde->close(tde);
}

static void mtdpe_seek(TermDocEnum *tde, int field_num, const char *term)
{
    (void)tde;
    (void)field_num;
    (void)term;
    RAISE(UNSUPPORTED_ERROR, "MultipleTermDocPosEnum does not support "
          " the #seek operation");
}

static int mtdpe_doc_num(TermDocEnum *tde)
{
    return MTDPE(tde)->doc_num;
}

static int mtdpe_freq(TermDocEnum *tde)
{
    return MTDPE(tde)->freq;
}

static bool mtdpe_next(TermDocEnum *tde)
{
    TermDocEnum *sub_tde;
    int pos = 0, freq = 0;
    int doc;
    MultipleTermDocPosEnum *mtdpe = MTDPE(tde);

    if (mtdpe->pq->size == 0) {
        return false;
    }

    sub_tde = (TermDocEnum *)pq_top(mtdpe->pq);
    doc = sub_tde->doc_num(sub_tde);

    do {
        freq += sub_tde->freq(sub_tde);
        if (freq > mtdpe->pos_queue_capa) {
            do {
                mtdpe->pos_queue_capa <<= 1;
            } while (freq > mtdpe->pos_queue_capa);
            REALLOC_N(mtdpe->pos_queue, int, mtdpe->pos_queue_capa);
        }

        /* pos starts from where it was up to last time */
        for (; pos < freq; pos++) {
            mtdpe->pos_queue[pos] = sub_tde->next_position(sub_tde);
        }

        if (sub_tde->next(sub_tde)) {
            pq_down(mtdpe->pq);
        }
        else {
            sub_tde = pq_pop(mtdpe->pq);
            sub_tde->close(sub_tde);
        }
        sub_tde = (TermDocEnum *)pq_top(mtdpe->pq);
    } while ((mtdpe->pq->size > 0) && (sub_tde->doc_num(sub_tde) == doc));

    qsort(mtdpe->pos_queue, freq, sizeof(int), &icmp_risky);

    mtdpe->pos_queue_index = 0;
    mtdpe->freq = freq;
    mtdpe->doc_num = doc;

    return true;
}

bool tdpe_less_than(TermDocEnum *p1, TermDocEnum *p2)
{
    return p1->doc_num(p1) < p2->doc_num(p2);
}

bool mtdpe_skip_to(TermDocEnum *tde, int target_doc_num)
{
    TermDocEnum *sub_tde;
    PriorityQueue *mtdpe_pq = MTDPE(tde)->pq;

    while ((sub_tde = (TermDocEnum *)pq_top(mtdpe_pq)) != NULL
           && (target_doc_num > sub_tde->doc_num(sub_tde))) {
        if (sub_tde->skip_to(sub_tde, target_doc_num)) {
            pq_down(mtdpe_pq);
        }
        else {
            sub_tde = pq_pop(mtdpe_pq);
            sub_tde->close(sub_tde);
        }
    }
    return tde->next(tde);
}

static int mtdpe_read(TermDocEnum *tde, int *docs, int *freqs, int req_num)
{
    (void)tde;
    (void)docs;
    (void)freqs;
    RAISE(UNSUPPORTED_ERROR, "MultipleTermDocPosEnum does not support "
          " the #read operation");
    return req_num;
}

static int mtdpe_next_position(TermDocEnum *tde)
{
    return MTDPE(tde)->pos_queue[MTDPE(tde)->pos_queue_index++];
}

static void mtdpe_close(TermDocEnum *tde)
{
    pq_clear(MTDPE(tde)->pq);
    pq_destroy(MTDPE(tde)->pq);
    free(MTDPE(tde)->pos_queue);
    free(tde);
}

TermDocEnum *mtdpe_new(IndexReader *ir, int field_num, char **terms, int t_cnt)
{
    int i;
    MultipleTermDocPosEnum *mtdpe = ALLOC_AND_ZERO(MultipleTermDocPosEnum);
    TermDocEnum *tde = TDE(mtdpe);
    PriorityQueue *pq;

    pq = mtdpe->pq = pq_new(t_cnt, (lt_ft)&tdpe_less_than, (free_ft)&tde_destroy);
    mtdpe->pos_queue_capa = MTDPE_POS_QUEUE_INIT_CAPA;
    mtdpe->pos_queue = ALLOC_N(int, MTDPE_POS_QUEUE_INIT_CAPA);
    mtdpe->field_num = field_num;
    for (i = 0; i < t_cnt; i++) {
        TermDocEnum *tpe = ir->term_positions(ir);
        tpe->seek(tpe, field_num, terms[i]);
        if (tpe->next(tpe)) {
            pq_push(pq, tpe);
        }
        else {
            tpe->close(tpe);
        }
    }
    tde->close          = &mtdpe_close;
    tde->seek           = &mtdpe_seek;
    tde->next           = &mtdpe_next;
    tde->doc_num        = &mtdpe_doc_num;
    tde->freq           = &mtdpe_freq;
    tde->skip_to        = &mtdpe_skip_to;
    tde->read           = &mtdpe_read;
    tde->next_position  = &mtdpe_next_position;

    return tde;
}

/****************************************************************************
 *
 * IndexReader
 *
 ****************************************************************************/

void ir_acquire_not_necessary(IndexReader *ir)
{
    (void)ir;
}

#define I64_PFX POSH_I64_PRINTF_PREFIX
void ir_acquire_write_lock(IndexReader *ir)
{
    if (ir->is_stale) {
        RAISE(STATE_ERROR, "IndexReader out of date and no longer valid for "
                           "delete, undelete, or set_norm operations. To "
                           "perform any of these operations on the index you "
                           "need to close and reopen the index");
    }

    if (ir->write_lock == NULL) {
        ir->write_lock = open_lock(ir->store, WRITE_LOCK_NAME);
        if (!ir->write_lock->obtain(ir->write_lock)) {/* obtain write lock */
            RAISE(LOCK_ERROR, "Could not obtain write lock when trying to "
                              "write changes to the index. Check that there "
                              "are no stale locks in the index. Look for "
                              "files with the \".lck\" prefix. If you know "
                              "there are no processes writing to the index "
                              "you can safely delete these files.");
        }

        /* we have to check whether index has changed since this reader was opened.
         * if so, this reader is no longer valid for deletion */
        if (sis_read_current_version(ir->store) > ir->sis->version) {
            ir->is_stale = true;
            ir->write_lock->release(ir->write_lock);
            close_lock(ir->write_lock);
            ir->write_lock = NULL;
            RAISE(STATE_ERROR, "IndexReader out of date and no longer valid "
                               "for delete, undelete, or set_norm operations. "
                               "The current version is <%"I64_PFX"d>, but this "
                               "readers version is <%"I64_PFX"d>. To perform "
                               "any of these operations on the index you need "
                               "to close and reopen the index",
                               sis_read_current_version(ir->store),
                               ir->sis->version);
        }
    }
}

IndexReader *ir_setup(IndexReader *ir, Store *store, SegmentInfos *sis,
                      FieldInfos *fis, int is_owner)
{
    mutex_init(&ir->mutex, NULL);

    if (store) {
        ir->store = store;
        REF(store);
    }
    ir->sis = sis;
    ir->fis = fis;
    ir->ref_cnt = 1;

    ir->is_owner = is_owner;
    if (is_owner) {
        ir->acquire_write_lock = &ir_acquire_write_lock;
    }
    else {
        ir->acquire_write_lock = &ir_acquire_not_necessary;
    }

    return ir;
}

bool ir_index_exists(Store *store)
{
    return store->exists(store, "segments");
}

int ir_get_field_num(IndexReader *ir, const char *field)
{
    int field_num = fis_get_field_num(ir->fis, field);
    if (field_num < 0) {
        RAISE(ARG_ERROR, "Field :%s does not exist in this index", field);
    }
    return field_num;
}

int ir_doc_freq(IndexReader *ir, const char *field, const char *term)
{
    int field_num = fis_get_field_num(ir->fis, field);
    if (field_num >= 0) {
        return ir->doc_freq(ir, field_num, term);
    }
    else {
        return 0;
    }
}

static void ir_set_norm_i(IndexReader *ir, int doc_num, int field_num, uchar val)
{
    mutex_lock(&ir->mutex);
    ir->acquire_write_lock(ir);
    ir->set_norm_i(ir, doc_num, field_num, val);
    ir->has_changes = true;
    mutex_unlock(&ir->mutex);
}

void ir_set_norm(IndexReader *ir, int doc_num, const char *field, uchar val)
{
    int field_num = fis_get_field_num(ir->fis, field);
    if (field_num >= 0) {
        ir_set_norm_i(ir, doc_num, field_num, val);
    }
}

uchar *ir_get_norms_i(IndexReader *ir, int field_num)
{
    uchar *norms = NULL;
    if (field_num >= 0) {
        norms = ir->get_norms(ir, field_num);
    }
    if (!norms) {
        if (ir->fake_norms == NULL) {
            ir->fake_norms = (uchar *)ecalloc(ir->max_doc(ir));
        }
        norms = ir->fake_norms;
    }
    return norms;
}

uchar *ir_get_norms(IndexReader *ir, const char *field)
{
    int field_num = fis_get_field_num(ir->fis, field);
    return ir_get_norms_i(ir, field_num);
}

uchar *ir_get_norms_into(IndexReader *ir, const char *field, uchar *buf)
{
    int field_num = fis_get_field_num(ir->fis, field);
    if (field_num >= 0) {
        ir->get_norms_into(ir, field_num, buf);
    }
    else {
        memset(buf, 0, ir->max_doc(ir));
    }
    return buf;
}

void ir_undelete_all(IndexReader *ir)
{
    mutex_lock(&ir->mutex);
    ir->acquire_write_lock(ir);
    ir->undelete_all_i(ir);
    ir->has_changes = true;
    mutex_unlock(&ir->mutex);
}

void ir_delete_doc(IndexReader *ir, int doc_num)
{
    if (doc_num >= 0 && doc_num < ir->max_doc(ir)) {
        mutex_lock(&ir->mutex);
        ir->acquire_write_lock(ir);
        ir->delete_doc_i(ir, doc_num);
        ir->has_changes = true;
        mutex_unlock(&ir->mutex);
    }
}

Document *ir_get_doc_with_term(IndexReader *ir, const char *field,
                               const char *term)
{
    TermDocEnum *tde = ir_term_docs_for(ir, field, term);
    Document *doc = NULL;

    if (tde) {
        if (tde->next(tde)) {
            doc = ir->get_doc(ir, tde->doc_num(tde));
        }
        tde->close(tde);
    }
    return doc;
}

TermEnum *ir_terms(IndexReader *ir, const char *field)
{
    TermEnum *te = NULL;
    int field_num = fis_get_field_num(ir->fis, field);
    if (field_num >= 0) {
        te = ir->terms(ir, field_num);
    }
    return te;
}

TermEnum *ir_terms_from(IndexReader *ir, const char *field,
                           const char *term)
{
    TermEnum *te = NULL;
    int field_num = fis_get_field_num(ir->fis, field);
    if (field_num >= 0) {
        te = ir->terms_from(ir, field_num, term);
    }
    return te;
}

TermDocEnum *ir_term_docs_for(IndexReader *ir, const char *field,
                              const char *term)
{
    int field_num = fis_get_field_num(ir->fis, field);
    TermDocEnum *tde = ir->term_docs(ir);
    if (field_num >= 0) {
        tde->seek(tde, field_num, term);
    }
    return tde;
}

TermDocEnum *ir_term_positions_for(IndexReader *ir, const char *field,
                                   const char *term)
{
    int field_num = fis_get_field_num(ir->fis, field);
    TermDocEnum *tde = ir->term_positions(ir);
    if (field_num >= 0) {
        tde->seek(tde, field_num, term);
    }
    return tde;
}

void ir_commit_i(IndexReader *ir)
{
    if (ir->has_changes && ir->is_owner) {
        Lock *commit_lock;

        mutex_lock(&ir->store->mutex);
        commit_lock = open_lock(ir->store, COMMIT_LOCK_NAME);
        if (!commit_lock->obtain(commit_lock)) { /* obtain write lock */
            RAISE(LOCK_ERROR, "Error trying to commit the index. Commit "
                              "lock already obtained");
        }

        ir->commit_i(ir);
        sis_write(ir->sis, ir->store);

        commit_lock->release(commit_lock);
        close_lock(commit_lock);
        mutex_unlock(&ir->store->mutex);

        if (ir->write_lock != NULL) {
            /* release write lock */
            ir->write_lock->release(ir->write_lock);
            close_lock(ir->write_lock);
            ir->write_lock = NULL;
        }
        ir->has_changes = false;
    }
    else {
        ir->commit_i(ir);
    }
}

void ir_commit(IndexReader *ir)
{
    mutex_lock(&ir->mutex);
    ir_commit_i(ir);
    mutex_unlock(&ir->mutex);
}

void ir_close(IndexReader *ir)
{
    mutex_lock(&ir->mutex);
    if (--(ir->ref_cnt) == 0) {
        ir_commit_i(ir);
        ir->close_i(ir);
        if (ir->store) {
            store_deref(ir->store);
        }
        if (ir->is_owner) {
            sis_destroy(ir->sis);
            fis_deref(ir->fis);
        }
        if (ir->cache) {
            h_destroy(ir->cache);
        }
        if (ir->sort_cache) {
            h_destroy(ir->sort_cache);
        }
        free(ir->fake_norms);

        mutex_destroy(&ir->mutex);
        free(ir);
    } else {
        mutex_unlock(&ir->mutex);
    }

}

/**
 * Don't call this method if the cache already exists
 **/
void ir_add_cache(IndexReader *ir)
{
    if (ir->cache == NULL) {
        ir->cache = co_hash_create();
    }
}

bool ir_is_latest(IndexReader *ir)
{
    volatile bool is_latest = false;

    Lock *commit_lock = open_lock(ir->store, COMMIT_LOCK_NAME);
    if (!commit_lock->obtain(commit_lock)) {
        close_lock(commit_lock);
        RAISE(LOCK_ERROR, "Error detecting if the current index is latest "
              "version. Commit lock currently obtained");
    }
    is_latest = (sis_read_current_version(ir->store) == ir->sis->version);
    commit_lock->release(commit_lock);
    close_lock(commit_lock);

    return is_latest;
}

/****************************************************************************
 * Norm
 ****************************************************************************/

typedef struct Norm {
    int field_num;
    InStream *is;
    uchar *bytes;
    bool is_dirty : 1;
} Norm;

static Norm *norm_create(InStream *is, int field_num)
{
    Norm *norm = ALLOC(Norm);

    norm->is = is;
    norm->field_num = field_num;
    norm->bytes = NULL;
    norm->is_dirty = false;

    return norm;
}

static void norm_destroy(Norm *norm)
{
    is_close(norm->is);
    if (norm->bytes != NULL) {
        free(norm->bytes);
    }
    free(norm);
}

static void norm_rewrite(Norm *norm, Store *store, char *segment,
                  int doc_count, Store *cfs_store)
{
    OutStream *os;
    char tmp_file_name[SEGMENT_NAME_MAX_LENGTH];
    char norm_file_name[SEGMENT_NAME_MAX_LENGTH];

    if (norm == NULL || norm->bytes == NULL) {
        return; /* These norms do not need to be rewritten */
    }

    sprintf(tmp_file_name, "%s.tmp", segment);
    os = store->new_output(store, tmp_file_name);
    os_write_bytes(os, norm->bytes, doc_count);
    os_close(os);

    if (cfs_store) {
        sprintf(norm_file_name, "%s.s%d", segment, norm->field_num);
    }
    else {
        sprintf(norm_file_name, "%s.f%d", segment, norm->field_num);
    }
    store->rename(store, tmp_file_name, norm_file_name);
    norm->is_dirty = false;
}

/****************************************************************************
 * SegmentReader
 ****************************************************************************/

typedef struct SegmentReader {
    IndexReader ir;
    char *segment;
    FieldsReader *fr;
    BitVector *deleted_docs;
    InStream *frq_in;
    InStream *prx_in;
    SegmentFieldIndex *sfi;
    TermInfosReader *tir;
    thread_key_t thread_fr;
    void **fr_bucket;
    HashTable *norms;
    Store *cfs_store;
    bool deleted_docs_dirty : 1;
    bool undelete_all : 1;
    bool norms_dirty : 1;
} SegmentReader;

#define IR(ir) ((IndexReader *)(ir))

#define SR(ir) ((SegmentReader *)(ir))
#define SR_SIZE(ir) (SR(ir)->fr->size)

static __inline FieldsReader *sr_fr(SegmentReader *sr)
{
    FieldsReader *fr;

    if ((fr = thread_getspecific(sr->thread_fr)) == NULL) {
        fr = fr_clone(sr->fr);
        ary_push(sr->fr_bucket, fr);
        thread_setspecific(sr->thread_fr, fr);
    }
    return fr;
}

static __inline bool sr_is_deleted_i(SegmentReader *sr, int doc_num)
{
    return (sr->deleted_docs != NULL && bv_get(sr->deleted_docs, doc_num));
}

static __inline void sr_get_norms_into_i(SegmentReader *sr, int field_num,
                                       uchar *buf)
{
    Norm *norm = h_get_int(sr->norms, field_num);
    if (norm == NULL) {
        memset(buf, 0, SR_SIZE(sr));
    }
    else if (norm->bytes != NULL) { /* can copy from cache */
        memcpy(buf, norm->bytes, SR_SIZE(sr));
    }
    else {
        InStream *norm_in = is_clone(norm->is);
        /* read from disk */
        is_seek(norm_in, 0);
        is_read_bytes(norm_in, buf, SR_SIZE(sr));
        is_close(norm_in);
    }
}

static __inline uchar *sr_get_norms_i(SegmentReader *sr, int field_num)
{
    Norm *norm = h_get_int(sr->norms, field_num);
    if (norm == NULL) {                           /* not an indexed field */
        return NULL;
    }

    if (norm->bytes == NULL) {                    /* value not yet read */
        uchar *bytes = ALLOC_N(uchar, SR_SIZE(sr));
        sr_get_norms_into_i(sr, field_num, bytes);
        norm->bytes = bytes;                        /* cache it */
    }
    return norm->bytes;
}

static void sr_set_norm_i(IndexReader *ir, int doc_num, int field_num, uchar b)
{
    Norm *norm = h_get_int(SR(ir)->norms, field_num);
    if (norm != NULL) { /* has_norms */
        norm->is_dirty = true; /* mark it dirty */
        SR(ir)->norms_dirty = true;
        sr_get_norms_i(SR(ir), field_num)[doc_num] = b;
    }
}

static void sr_delete_doc_i(IndexReader *ir, int doc_num) 
{
    if (SR(ir)->deleted_docs == NULL) {
        SR(ir)->deleted_docs = bv_new();
    }

    SR(ir)->deleted_docs_dirty = true;
    SR(ir)->undelete_all = false;
    bv_set(SR(ir)->deleted_docs, doc_num);
}

static void sr_undelete_all_i(IndexReader *ir)
{
    SR(ir)->undelete_all = true;
    SR(ir)->deleted_docs_dirty = false;
    if (SR(ir)->deleted_docs != NULL) {
        bv_destroy(SR(ir)->deleted_docs);
    }
    SR(ir)->deleted_docs = NULL;
}

static void bv_write(BitVector *bv, Store *store, char *name)
{
    int i;
    OutStream *os = store->new_output(store, name);
    os_write_vint(os, bv->size);
    for (i = (bv->size >> 5); i >= 0; i--) {
        os_write_u32(os, bv->bits[i]);
    }
    os_close(os);
}

static BitVector *bv_read(Store *store, char *name)
{
    int i;
    BitVector *bv = ALLOC_AND_ZERO(BitVector);
    InStream *is = store->open_input(store, name);
    bv->size = (int)is_read_vint(is);
    bv->capa = (bv->size >> 5) + 1;
    bv->bits = ALLOC_AND_ZERO_N(f_u32, bv->capa);
    bv->ref_cnt = 1;
    for (i = (bv->size >> 5); i >= 0; i--) {
        bv->bits[i] = is_read_u32(is);
    }
    is_close(is);
    bv_recount(bv);
    return bv;
}

static void sr_commit_i(IndexReader *ir)
{
    char tmp_file_name[SEGMENT_NAME_MAX_LENGTH];
    char del_file_name[SEGMENT_NAME_MAX_LENGTH];

    sprintf(del_file_name, "%s.del", SR(ir)->segment);

    if (SR(ir)->deleted_docs_dirty) { /* re-write deleted */
        sprintf(tmp_file_name, "%s.tmp", SR(ir)->segment);
        bv_write(SR(ir)->deleted_docs, ir->store, tmp_file_name);
        ir->store->rename(ir->store, tmp_file_name, del_file_name);
    }
    if (SR(ir)->undelete_all && ir->store->exists(ir->store, del_file_name)) {
        ir->store->remove(ir->store, del_file_name);
    }
    if (SR(ir)->norms_dirty) { /* re-write norms */
        int i;
        const int field_cnt = ir->fis->size;
        FieldInfo *fi;
        for (i = 0; i < field_cnt; i++) {
            fi = ir->fis->fields[i];
            if (fi_is_indexed(fi)) {
                norm_rewrite(h_get_int(SR(ir)->norms, fi->number), ir->store,
                             SR(ir)->segment, SR_SIZE(ir), SR(ir)->cfs_store);
            }
        }
    }
    SR(ir)->deleted_docs_dirty = false;
    SR(ir)->norms_dirty = false;
    SR(ir)->undelete_all = false;
}

static void sr_close_i(IndexReader *ir)
{
    SegmentReader *sr = SR(ir);

    fr_close(sr->fr);
    tir_close(sr->tir);
    sfi_close(sr->sfi);

    if (sr->frq_in) {
        is_close(sr->frq_in);
    }
    if (sr->prx_in) {
        is_close(sr->prx_in);
    }

    h_destroy(sr->norms);

    if (sr->fr_bucket) {
        thread_setspecific(sr->thread_fr, NULL);
        thread_key_delete(sr->thread_fr);
        ary_destroy(sr->fr_bucket, (free_ft)&fr_close);
    }
    if (sr->deleted_docs) {
        bv_destroy(sr->deleted_docs);
    }
    if (sr->cfs_store) {
        store_deref(sr->cfs_store);
    }
}

static int sr_num_docs(IndexReader *ir)
{
    int num_docs;

    mutex_lock(&ir->mutex);
    num_docs = SR(ir)->fr->size;
    if (SR(ir)->deleted_docs != NULL) {
        num_docs -= SR(ir)->deleted_docs->count;
    }
    mutex_unlock(&ir->mutex);
    return num_docs;
}

static int sr_max_doc(IndexReader *ir)
{
    return SR(ir)->fr->size;
}

static Document *sr_get_doc(IndexReader *ir, int doc_num)
{
    Document *doc;
    mutex_lock(&ir->mutex);
    if (sr_is_deleted_i(SR(ir), doc_num)) {
        mutex_unlock(&ir->mutex);
        RAISE(STATE_ERROR, "Document %d has already been deleted", doc_num);
    }
    doc = fr_get_doc(SR(ir)->fr, doc_num);
    mutex_unlock(&ir->mutex);
    return doc;
}

static LazyDoc *sr_get_lazy_doc(IndexReader *ir, int doc_num)
{
    LazyDoc *lazy_doc;
    mutex_lock(&ir->mutex);
    if (sr_is_deleted_i(SR(ir), doc_num)) {
        mutex_unlock(&ir->mutex);
        RAISE(STATE_ERROR, "Document %d has already been deleted", doc_num);
    }
    lazy_doc = fr_get_lazy_doc(SR(ir)->fr, doc_num);
    mutex_unlock(&ir->mutex);
    return lazy_doc;
}

static uchar *sr_get_norms(IndexReader *ir, int field_num)
{
    uchar *norms;
    mutex_lock(&ir->mutex);
    norms = sr_get_norms_i(SR(ir), field_num);
    mutex_unlock(&ir->mutex);
    return norms;
}

static uchar *sr_get_norms_into(IndexReader *ir, int field_num,
                              uchar *buf)
{
    mutex_lock(&ir->mutex);
    sr_get_norms_into_i(SR(ir), field_num, buf);
    mutex_unlock(&ir->mutex);
    return buf;
}

static TermEnum *sr_terms(IndexReader *ir, int field_num)
{
    TermEnum *te = SR(ir)->tir->orig_te;
    te = ste_clone(te);
    return ste_set_field(te, field_num);
}

static TermEnum *sr_terms_from(IndexReader *ir, int field_num, const char *term)
{
    TermEnum *te = SR(ir)->tir->orig_te;
    te = ste_clone(te);
    ste_set_field(te, field_num);
    ste_scan_to(te, term);
    return te;
}

static int sr_doc_freq(IndexReader *ir, int field_num, const char *term)
{
    TermInfo *ti = tir_get_ti(tir_set_field(SR(ir)->tir, field_num), term);
    return ti ? ti->doc_freq : 0;
}

static TermDocEnum *sr_term_docs(IndexReader *ir)
{
    return stde_new(SR(ir)->tir, SR(ir)->frq_in, SR(ir)->deleted_docs,
                    STE(SR(ir)->tir->orig_te)->skip_interval);
}

static TermDocEnum *sr_term_positions(IndexReader *ir)
{
    SegmentReader *sr = SR(ir);
    return stpe_new(sr->tir, sr->frq_in, sr->prx_in, sr->deleted_docs,
                    STE(sr->tir->orig_te)->skip_interval);
}

static TermVector *sr_term_vector(IndexReader *ir, int doc_num,
                                  const char *field)
{
    FieldInfo *fi = h_get(ir->fis->field_dict, field);
    FieldsReader *fr;

    if (!fi || !fi_store_term_vector(fi) || !SR(ir)->fr ||
        !(fr = sr_fr(SR(ir)))) {
        return NULL;
    }

    return fr_get_field_tv(fr, doc_num, fi->number);
}

static HashTable *sr_term_vectors(IndexReader *ir, int doc_num)
{
    FieldsReader *fr;
    if (!SR(ir)->fr || (fr = sr_fr(SR(ir))) == NULL) {
        return NULL;
    }

    return fr_get_tv(fr, doc_num);
}

static bool sr_is_deleted(IndexReader *ir, int doc_num)
{
    bool is_del;

    mutex_lock(&ir->mutex);
    is_del = sr_is_deleted_i(SR(ir), doc_num);
    mutex_unlock(&ir->mutex);

    return is_del;
}

static bool sr_has_deletions(IndexReader *ir)
{
    return (SR(ir)->deleted_docs != NULL);
}

static void sr_open_norms(IndexReader *ir, Store *cfs_store)
{
    int i;
    Store *store = ir->store;
    char file_name[SEGMENT_NAME_MAX_LENGTH];
    FieldInfos *fis = ir->fis;
    char *ext_ptr;
    const int field_cnt = fis->size;

    sprintf(file_name, "%s.", SR(ir)->segment);
    ext_ptr = file_name + strlen(file_name);

    for (i = 0; i < field_cnt; i++) {
        if (fi_has_norms(fis->fields[i])) {
            sprintf(ext_ptr, "s%d", i);
            if (!store->exists(store, file_name)) {
                sprintf(ext_ptr, "f%d", i);
                store = cfs_store;
            }
            if (store->exists(store, file_name)) {
                h_set_int(SR(ir)->norms, i,
                          norm_create(store->open_input(store, file_name), i));
            }
        }
    }
    SR(ir)->norms_dirty = false;
}

static IndexReader *sr_setup_i(SegmentReader *sr, SegmentInfo *si)
{
    Store *store = si->store;
    IndexReader *ir = IR(sr);
    char file_name[SEGMENT_NAME_MAX_LENGTH];

    ir->num_docs            = &sr_num_docs;
    ir->max_doc             = &sr_max_doc;
    ir->get_doc             = &sr_get_doc;
    ir->get_lazy_doc        = &sr_get_lazy_doc;
    ir->get_norms           = &sr_get_norms;
    ir->get_norms_into      = &sr_get_norms_into;
    ir->terms               = &sr_terms;
    ir->terms_from          = &sr_terms_from;
    ir->doc_freq            = &sr_doc_freq;
    ir->term_docs           = &sr_term_docs;
    ir->term_positions      = &sr_term_positions;
    ir->term_vector         = &sr_term_vector;
    ir->term_vectors        = &sr_term_vectors;
    ir->is_deleted          = &sr_is_deleted;
    ir->has_deletions       = &sr_has_deletions;

    ir->set_norm_i          = &sr_set_norm_i;
    ir->delete_doc_i        = &sr_delete_doc_i;
    ir->undelete_all_i      = &sr_undelete_all_i;
    ir->commit_i            = &sr_commit_i;
    ir->close_i             = &sr_close_i;

    sr->segment     = si->name;
    sr->cfs_store   = NULL;

    sprintf(file_name, "%s.cfs", sr->segment);
    if (store->exists(store, file_name)) {
        sr->cfs_store = open_cmpd_store(store, file_name);
        store = sr->cfs_store;
    }

    sr->fr = fr_open(store, sr->segment, ir->fis);
    sr->sfi = sfi_open(store, sr->segment);
    sr->tir = tir_open(store, sr->sfi, sr->segment);

    sr->deleted_docs = NULL;
    sr->deleted_docs_dirty = false;
    sr->undelete_all = false;
    if (si_has_deletions(si)) {
        sprintf(file_name, "%s.del", sr->segment);
        sr->deleted_docs = bv_read(si->store, file_name);
    }

    sprintf(file_name, "%s.frq", sr->segment);
    sr->frq_in = store->open_input(store, file_name);
    sprintf(file_name, "%s.prx", sr->segment);
    sr->prx_in = store->open_input(store, file_name);
    sr->norms = h_new_int((free_ft)&norm_destroy);
    sr_open_norms(ir, store);

    if (fis_has_vectors(ir->fis)) {
        thread_key_create(&sr->thread_fr, NULL);
        sr->fr_bucket = ary_new();
    }
    return ir;
}

static IndexReader *sr_open(SegmentInfos *sis, FieldInfos *fis, int si_num,
                            bool is_owner)
{
    SegmentReader *sr = ALLOC_AND_ZERO(SegmentReader);
    SegmentInfo *si = sis->segs[si_num];
    IndexReader *ir = ir_setup(IR(sr), si->store, sis, fis, is_owner);
    return sr_setup_i(SR(ir), si);
}

/****************************************************************************
 * MultiReader
 ****************************************************************************/

#define MR(ir) ((MultiReader *)(ir))

static int mr_reader_index_i(MultiReader *mr, int doc_num)
{
    int lo = 0;                       /* search @starts array */
    int hi = mr->r_cnt - 1;            /* for first element less */
    int mid;
    int mid_value;

    while (hi >= lo) {
        mid = (lo + hi) >> 1;
        mid_value = mr->starts[mid];
        if (doc_num < mid_value) {
            hi = mid - 1;
        }
        else if (doc_num > mid_value) {
            lo = mid + 1;
        }
        else { /* found a match */
            while ((mid+1 < mr->r_cnt) && (mr->starts[mid+1] == mid_value)) {
                mid += 1; /* scan to last match in case we have empty segments */
            }
            return mid;
        }
    }
    return hi;
}

int mr_num_docs(IndexReader *ir)
{
    int i, num_docs;
    mutex_lock(&ir->mutex);
    if (MR(ir)->num_docs_cache == -1) {
        const int mr_reader_cnt = MR(ir)->r_cnt;
        MR(ir)->num_docs_cache = 0;
        for (i = 0; i < mr_reader_cnt; i++) {
            IndexReader *reader = MR(ir)->sub_readers[i];
            MR(ir)->num_docs_cache += reader->num_docs(reader);
        }
    }
    num_docs = MR(ir)->num_docs_cache;
    mutex_unlock(&ir->mutex);

    return num_docs;
}

static int mr_max_doc(IndexReader *ir)
{
    return MR(ir)->max_doc;
}

#define GET_READER()\
    int i = mr_reader_index_i(MR(ir), doc_num);\
    IndexReader *reader = MR(ir)->sub_readers[i]

static Document *mr_get_doc(IndexReader *ir, int doc_num)
{
    GET_READER();
    return reader->get_doc(reader, doc_num - MR(ir)->starts[i]);
}

static LazyDoc *mr_get_lazy_doc(IndexReader *ir, int doc_num)
{
    GET_READER();
    return reader->get_lazy_doc(reader, doc_num - MR(ir)->starts[i]);
}

int mr_get_field_num(MultiReader *mr, int ir_num, int f_num)
{
    if (mr->field_num_map) {
        return mr->field_num_map[ir_num][f_num];
    }
    else {
        return f_num;
    }
}

static uchar *mr_get_norms(IndexReader *ir, int field_num)
{
    uchar *bytes;

    mutex_lock(&ir->mutex);
    bytes = h_get_int(MR(ir)->norms_cache, field_num);
    if (bytes == NULL) {
        int i;
        const int mr_reader_cnt = MR(ir)->r_cnt;

        bytes = ALLOC_AND_ZERO_N(uchar, MR(ir)->max_doc);

        for (i = 0; i < mr_reader_cnt; i++) {
            int fnum = mr_get_field_num(MR(ir), i, field_num);
            if (fnum >= 0) {
                IndexReader *reader = MR(ir)->sub_readers[i];
                reader->get_norms_into(reader, fnum, bytes + MR(ir)->starts[i]);
            }
        }
        h_set_int(MR(ir)->norms_cache, field_num, bytes); /* update cache */
    }
    mutex_unlock(&ir->mutex);

    return bytes;
}

static uchar *mr_get_norms_into(IndexReader *ir, int field_num, uchar *buf)
{
    uchar *bytes;

    mutex_lock(&ir->mutex);
    bytes = h_get_int(MR(ir)->norms_cache, field_num);
    if (bytes != NULL) {
        memcpy(buf, bytes, MR(ir)->max_doc);
    }
    else {
        int i;
        const int mr_reader_cnt = MR(ir)->r_cnt;
        for (i = 0; i < mr_reader_cnt; i++) {
            int fnum = mr_get_field_num(MR(ir), i, field_num);
            if (fnum >= 0) {
                IndexReader *reader = MR(ir)->sub_readers[i];
                reader->get_norms_into(reader, fnum, buf + MR(ir)->starts[i]);
            }
        }
    }
    mutex_unlock(&ir->mutex);
    return buf;
}

static TermEnum *mr_terms(IndexReader *ir, int field_num)
{
    return mte_new(MR(ir), field_num, NULL);
}

static TermEnum *mr_terms_from(IndexReader *ir, int field_num, const char *term)
{
    return mte_new(MR(ir), field_num, term);
}

static int mr_doc_freq(IndexReader *ir, int field_num, const char *t)
{
    int total = 0;          /* sum freqs in segments */
    int i = MR(ir)->r_cnt;
    for (i = MR(ir)->r_cnt - 1; i >= 0; i--) {
        int fnum = mr_get_field_num(MR(ir), i, field_num);
        if (fnum >= 0) {
            IndexReader *reader = MR(ir)->sub_readers[i];
            total += reader->doc_freq(reader, fnum, t);
        }
    }
    return total;
}

static TermDocEnum *mr_term_docs(IndexReader *ir)
{
    return mtde_new(MR(ir));
}

static TermDocEnum *mr_term_positions(IndexReader *ir)
{
    return mtpe_new(MR(ir));
}

static TermVector *mr_term_vector(IndexReader *ir, int doc_num,
                                  const char *field)
{
    GET_READER();
    return reader->term_vector(reader, doc_num - MR(ir)->starts[i], field);
}

static HashTable *mr_term_vectors(IndexReader *ir, int doc_num)
{
    GET_READER();
    return reader->term_vectors(reader, doc_num - MR(ir)->starts[i]);
}

static bool mr_is_deleted(IndexReader *ir, int doc_num)
{
    GET_READER();
    return reader->is_deleted(reader, doc_num - MR(ir)->starts[i]);
}

static bool mr_has_deletions(IndexReader *ir)
{
    return MR(ir)->has_deletions;
}

static void mr_set_norm_i(IndexReader *ir, int doc_num, int field_num, uchar val)
{
    int i = mr_reader_index_i(MR(ir), doc_num);
    int fnum = mr_get_field_num(MR(ir), i, field_num);
    if (fnum >= 0) {
        IndexReader *reader = MR(ir)->sub_readers[i];
        h_del_int(MR(ir)->norms_cache, fnum);/* clear cache */
        ir_set_norm_i(reader, doc_num - MR(ir)->starts[i], fnum, val);
    }
}

static void mr_delete_doc_i(IndexReader *ir, int doc_num)
{
    GET_READER();
    MR(ir)->num_docs_cache = -1; /* invalidate cache */

    /* dispatch to segment reader */
    reader->delete_doc_i(reader, doc_num - MR(ir)->starts[i]);
    MR(ir)->has_deletions = true;
}

static void mr_undelete_all_i(IndexReader *ir)
{
    int i;
    const int mr_reader_cnt = MR(ir)->r_cnt;

    MR(ir)->num_docs_cache = -1;                     /* invalidate cache */
    for (i = 0; i < mr_reader_cnt; i++) {
        IndexReader *reader = MR(ir)->sub_readers[i];
        reader->undelete_all_i(reader);
    }
    MR(ir)->has_deletions = false;
}

static void mr_commit_i(IndexReader *ir)
{
    int i;
    const int mr_reader_cnt = MR(ir)->r_cnt;
    for (i = 0; i < mr_reader_cnt; i++) {
        IndexReader *reader = MR(ir)->sub_readers[i];
        ir_commit(reader);
    }
}

static void mr_close_i(IndexReader *ir)
{
    int i;
    const int mr_reader_cnt = MR(ir)->r_cnt;
    for (i = 0; i < mr_reader_cnt; i++) {
        IndexReader *reader = MR(ir)->sub_readers[i];
        ir_close(reader);
    }
    free(MR(ir)->sub_readers);
    h_destroy(MR(ir)->norms_cache);
    free(MR(ir)->starts);
}

static IndexReader *mr_new(IndexReader **sub_readers, const int r_cnt)
{
    int i;
    MultiReader *mr = ALLOC_AND_ZERO(MultiReader);
    IndexReader *ir = IR(mr);

    mr->sub_readers         = sub_readers;
    mr->r_cnt               = r_cnt;
    mr->max_doc             = 0;
    mr->num_docs_cache      = -1;
    mr->has_deletions       = false;

    mr->starts              = ALLOC_N(int, (r_cnt+1));

    for (i = 0; i < r_cnt; i++) {
        IndexReader *sub_reader = sub_readers[i];
        mr->starts[i] = mr->max_doc;
        mr->max_doc += sub_reader->max_doc(sub_reader); /* compute max_docs */

        if (sub_reader->has_deletions(sub_reader)) {
            mr->has_deletions = true;
        }
    }
    mr->starts[r_cnt]       = mr->max_doc;
    mr->norms_cache         = h_new_int(&free);

    ir->num_docs            = &mr_num_docs;
    ir->max_doc             = &mr_max_doc;
    ir->get_doc             = &mr_get_doc;
    ir->get_lazy_doc        = &mr_get_lazy_doc;
    ir->get_norms           = &mr_get_norms;
    ir->get_norms_into      = &mr_get_norms_into;
    ir->terms               = &mr_terms;
    ir->terms_from          = &mr_terms_from;
    ir->doc_freq            = &mr_doc_freq;
    ir->term_docs           = &mr_term_docs;
    ir->term_positions      = &mr_term_positions;
    ir->term_vector         = &mr_term_vector;
    ir->term_vectors        = &mr_term_vectors;
    ir->is_deleted          = &mr_is_deleted;
    ir->has_deletions       = &mr_has_deletions;

    ir->set_norm_i          = &mr_set_norm_i;
    ir->delete_doc_i        = &mr_delete_doc_i;
    ir->undelete_all_i      = &mr_undelete_all_i;
    ir->commit_i            = &mr_commit_i;
    ir->close_i             = &mr_close_i;

    return ir;
}

IndexReader *mr_open_i(Store *store,
                       SegmentInfos *sis,
                       FieldInfos *fis,
                       IndexReader **sub_readers,
                       const int r_cnt)
{
    IndexReader *ir = mr_new(sub_readers, r_cnt);
    return ir_setup(ir, store, sis, fis, true);
}

static void mr_close_ext_i(IndexReader *ir)
{
    int **field_num_map = MR(ir)->field_num_map;
    if (field_num_map) {
        int i;
        for (i = MR(ir)->r_cnt - 1; i >= 0; i--) {
            free(field_num_map[i]);
        }
        free(field_num_map);
    }
    fis_deref(ir->fis);
    mr_close_i(ir);
}

IndexReader *mr_open(IndexReader **sub_readers, const int r_cnt)
{
    IndexReader *ir = mr_new(sub_readers, r_cnt);
    MultiReader *mr = MR(ir);
    /* defaults don't matter, this is just for reading fields, not adding */
    FieldInfos *fis = fis_new(0, 0, 0);
    int i, j;
    bool need_field_map = false;

    /* Merge FieldInfos */
    for (i = 0; i < r_cnt; i++) {
        FieldInfos *sub_fis = sub_readers[i]->fis;
        const int sub_fis_size = sub_fis->size;
        for (j = 0; j < sub_fis_size; j++) {
            FieldInfo *fi = sub_fis->fields[j];
            FieldInfo *new_fi = fis_get_or_add_field(fis, fi->name);
            new_fi->bits |= fi->bits;
            if (fi->number != new_fi->number) {
                need_field_map = true;
            }
        }
    }

    /* we only need to build a field map if some of the sub FieldInfos didn't
     * match the new FieldInfos object */
    if (need_field_map) {
        mr->field_num_map = ALLOC_N(int *, r_cnt);
        for (i = 0; i < r_cnt; i++) {
            FieldInfos *sub_fis = sub_readers[i]->fis;
            const int fis_size = fis->size;

            mr->field_num_map[i] = ALLOC_N(int, fis_size);
            for (j = 0; j < fis_size; j++) {
                FieldInfo *fi = fis->fields[j];
                FieldInfo *fi_sub = fis_get_field(sub_fis, fi->name);
                /* set non existant field nums to -1. The MultiReader will
                 * skip readers which don't have needed fields */
                mr->field_num_map[i][j] = fi_sub ? fi_sub->number : -1;
            }
        }
        /* print out the field map 
        for (i = 0; i < r_cnt; i++) {
            for (j = 0; j < fis->size; j++) {
                printf("%d ", mr->field_num_map[i][j]);
            }
            printf("\n");
        }
        */
    }
    else {
        mr->field_num_map = NULL;
    }


    ir->close_i = &mr_close_ext_i;

    return ir_setup(ir, NULL, NULL, fis, false);
}

/****************************************************************************
 * IndexReader
 ****************************************************************************/

/**
 * Will keep a reference to the store. To let this method delete the store
 * make sure you deref the store that you pass to it
 */
IndexReader *ir_open(Store *store)
{
    int i;
    IndexReader *ir;
    SegmentInfos *sis;
    FieldInfos *fis;

    mutex_lock(&store->mutex);
    sis = sis_read(store);
    fis = fis_read(store);
    if (sis->size == 1) {
        ir = sr_open(sis, fis, 0, true);
    }
    else {
        IndexReader **readers = ALLOC_N(IndexReader *, sis->size);
        for (i = sis->size; i > 0;) {
            i--;
            readers[i] = sr_open(sis, fis, i, false);
        }
        ir = mr_open_i(store, sis, fis, readers, sis->size);
    }
    mutex_unlock(&store->mutex);
    return ir;
}

/****************************************************************************
 *
 * Offset
 *
 ****************************************************************************/

Offset *offset_new(int start, int end)
{
    Offset *offset = ALLOC(Offset);
    offset->start = start;
    offset->end = end;
    return offset;
}

/****************************************************************************
 *
 * Occurence
 *
 ****************************************************************************/

static Occurence *occ_new(MemoryPool *mp, int pos)
{
    Occurence *occ = MP_ALLOC(mp, Occurence);
    occ->pos = pos;
    occ->next = NULL;
    return occ;
}

/****************************************************************************
 *
 * Posting
 *
 ****************************************************************************/

Posting *p_new(MemoryPool *mp, int doc_num, int pos)
{
    Posting *p = MP_ALLOC(mp, Posting);
    p->doc_num = doc_num;
    p->first_occ = occ_new(mp, pos);
    p->freq = 1;
    p->next = NULL;
    return p;
}

/****************************************************************************
 *
 * PostingList
 *
 ****************************************************************************/

PostingList *pl_new(MemoryPool *mp, const char *term, int term_len, Posting *p)
{
    PostingList *pl = MP_ALLOC(mp, PostingList);
    pl->term = mp_memdup(mp, term, term_len + 1);
    pl->term_len = term_len;
    pl->first = pl->last = p;
    pl->last_occ = p->first_occ;
    return pl;
}

void pl_add_occ(MemoryPool *mp, PostingList *pl, int pos)
{
    pl->last_occ = pl->last_occ->next = occ_new(mp, pos);
    pl->last->freq++;
}

void pl_add_posting(PostingList *pl, Posting *p)
{
    pl->last = pl->last->next = p;
    pl->last_occ = p->first_occ;
}

int pl_cmp(const PostingList **pl1, const PostingList **pl2)
{
    return strcmp((*pl1)->term, (*pl2)->term);
}

/****************************************************************************
 *
 * FieldInverter
 *
 ****************************************************************************/

static FieldInverter *fld_inv_new(DocWriter *dw, FieldInfo *fi)
{
    FieldInverter *fld_inv = MP_ALLOC(dw->mp, FieldInverter);
    fld_inv->is_tokenized = fi_is_tokenized(fi);
    fld_inv->store_term_vector = fi_store_term_vector(fi);
    fld_inv->store_offsets = fi_store_offsets(fi);
    if ((fld_inv->has_norms = fi_has_norms(fi)) == true) {
        fld_inv->norms = MP_ALLOC_AND_ZERO_N(dw->mp, uchar, dw->max_buffered_docs);
    }
    fld_inv->fi = fi;

    /* this will alloc it's own memory so must be destroyed */
    fld_inv->plists = h_new_str(NULL, NULL);

    return fld_inv;
}

static void fld_inv_destroy(FieldInverter *fld_inv)
{
    h_destroy(fld_inv->plists);
}

/****************************************************************************
 *
 * SkipBuffer
 *
 ****************************************************************************/

typedef struct SkipBuffer
{
    OutStream *buf;
    OutStream *frq_out;
    OutStream *prx_out;
    int last_doc;
    int last_frq_ptr;
    int last_prx_ptr;
} SkipBuffer;

static void skip_buf_reset(SkipBuffer *skip_buf)
{
    ramo_reset(skip_buf->buf);
    skip_buf->last_doc = 0;
    skip_buf->last_frq_ptr = os_pos(skip_buf->frq_out);
    skip_buf->last_prx_ptr = os_pos(skip_buf->prx_out);
}

static SkipBuffer *skip_buf_new(OutStream *frq_out, OutStream *prx_out)
{
    SkipBuffer *skip_buf = ALLOC(SkipBuffer);
    skip_buf->buf = ram_new_buffer();
    skip_buf->frq_out = frq_out;
    skip_buf->prx_out = prx_out;
    return skip_buf;
}

static void skip_buf_add(SkipBuffer *skip_buf, int doc)
{
    int frq_ptr = os_pos(skip_buf->frq_out);
    int prx_ptr = os_pos(skip_buf->prx_out);

    os_write_vint(skip_buf->buf, doc - skip_buf->last_doc);
    os_write_vint(skip_buf->buf, frq_ptr - skip_buf->last_frq_ptr);
    os_write_vint(skip_buf->buf, prx_ptr - skip_buf->last_prx_ptr);

    skip_buf->last_doc = doc;
    skip_buf->last_frq_ptr = frq_ptr;
    skip_buf->last_prx_ptr = prx_ptr;
}

static int skip_buf_write(SkipBuffer *skip_buf)
{
  int skip_ptr = os_pos(skip_buf->frq_out);
  ramo_write_to(skip_buf->buf, skip_buf->frq_out);
  return skip_ptr;
}

static void skip_buf_destroy(SkipBuffer *skip_buf)
{
    ram_destroy_buffer(skip_buf->buf);
    free(skip_buf);
}

/****************************************************************************
 *
 * DocWriter
 *
 ****************************************************************************/

static void dw_write_norms(DocWriter *dw, FieldInverter *fld_inv)
{
    char file_name[SEGMENT_NAME_MAX_LENGTH];
    OutStream *norms_out;
    sprintf(file_name, "%s.f%d", dw->segment, fld_inv->fi->number);
    norms_out = dw->store->new_output(dw->store, file_name);
    os_write_bytes(norms_out, fld_inv->norms, dw->doc_num);
    os_close(norms_out);
}

/* we'll use the postings HashTable's table area to sort the postings as it is
 * going to be zeroset soon anyway */
static PostingList **dw_sort_postings(HashTable *plists_ht)
{
    int i, j;
    HashEntry *he;
    PostingList **plists = (PostingList **)plists_ht->table;
    const int num_entries = plists_ht->mask + 1;
    for (i = 0, j = 0; i < num_entries; i++) {
        he = &plists_ht->table[i];
        if (he->value) {
            plists[j++] = (PostingList *)he->value;
        }
    }

    qsort(plists, plists_ht->size, sizeof(PostingList *),
          (int (*)(const void *, const void *))&pl_cmp);

    return plists;
}

static void dw_flush_streams(DocWriter *dw)
{
    mp_reset(dw->mp);
    fw_close(dw->fw);
    dw->fw = NULL;
    h_clear(dw->fields);
    dw->doc_num = 0;
}

static void dw_flush(DocWriter *dw)
{
    int i, j, last_doc, doc_code, doc_freq, last_pos, posting_count;
    int skip_interval = dw->skip_interval;
    FieldInfos *fis = dw->fis;
    const int fields_count = fis->size;
    FieldInverter *fld_inv;
    FieldInfo *fi;
    PostingList **pls, *pl;
    Posting *p;
    Occurence *occ;
    Store *store = dw->store;
    TermInfosWriter *tiw = tiw_open(store, dw->segment,
                                    dw->index_interval, skip_interval);
    TermInfo ti;
    char file_name[SEGMENT_NAME_MAX_LENGTH];
    OutStream *frq_out, *prx_out;
    SkipBuffer *skip_buf;

    sprintf(file_name, "%s.frq", dw->segment);
    frq_out = store->new_output(store, file_name);
    sprintf(file_name, "%s.prx", dw->segment);
    prx_out = store->new_output(store, file_name);
    skip_buf = skip_buf_new(frq_out, prx_out);

    for (i = 0; i < fields_count; i++) {
        fi = fis->fields[i];
        if (!fi_is_indexed(fi)
            || (fld_inv = h_get_int(dw->fields, fi->number)) == NULL) {
            continue;
        }
        if (!fi_omit_norms(fi)) {
            dw_write_norms(dw, fld_inv);
        }

        pls = dw_sort_postings(fld_inv->plists);
        tiw_start_field(tiw, fi->number);
        posting_count = fld_inv->plists->size;
        for (j = 0; j < posting_count; j++) {
            pl = pls[j];
            ti.frq_ptr = os_pos(frq_out);
            ti.prx_ptr = os_pos(prx_out);
            last_doc = 0;
            doc_freq = 0;
            skip_buf_reset(skip_buf);
            for (p = pl->first; p != NULL; p = p->next) {
                doc_freq++;
                if ((doc_freq % dw->skip_interval) == 0) {
                    skip_buf_add(skip_buf, last_doc);
                }

                doc_code = (p->doc_num - last_doc) << 1;
                last_doc = p->doc_num;

                if (p->freq == 1) {
                    os_write_vint(frq_out, 1|doc_code);
                }
                else {
                    os_write_vint(frq_out, doc_code);
                    os_write_vint(frq_out, p->freq);
                }

                last_pos = 0;
                for (occ = p->first_occ; occ != NULL; occ = occ->next) {
                    os_write_vint(prx_out, occ->pos - last_pos);
                    last_pos = occ->pos;
                }
            }
            ti.skip_offset = skip_buf_write(skip_buf) - ti.frq_ptr;
            ti.doc_freq = doc_freq;
            tiw_add(tiw, pl->term, pl->term_len, &ti);
        }
    }
    os_close(prx_out);
    os_close(frq_out);
    tiw_close(tiw);
    skip_buf_destroy(skip_buf);
    dw_flush_streams(dw);
} 

DocWriter *dw_open(IndexWriter *iw, const char *segment)
{
    Store *store = iw->store;
    MemoryPool *mp = mp_new_capa(iw->config.chunk_size,
        iw->config.max_buffer_memory/iw->config.chunk_size);

    DocWriter *dw = ALLOC(DocWriter);

    dw->mp = mp;
    dw->analyzer = iw->analyzer;
    dw->fis = iw->fis;
    dw->store = store;
    dw->fw = fw_open(store, segment, iw->fis);
    dw->segment = segment;

    dw->curr_plists = h_new_str(NULL, NULL);
    dw->fields = h_new_int((free_ft)fld_inv_destroy);
    dw->doc_num = 0;

    dw->index_interval = iw->config.index_interval;
    dw->skip_interval = iw->config.skip_interval;
    dw->max_field_length = iw->config.max_field_length;
    dw->max_buffered_docs = iw->config.max_buffered_docs;
    
    dw->offsets = ALLOC_AND_ZERO_N(Offset, DW_OFFSET_INIT_CAPA);
    dw->offsets_size = 0;
    dw->offsets_capa = DW_OFFSET_INIT_CAPA;

    dw->similarity = iw->similarity;
    return dw;
}

void dw_new_segment(DocWriter *dw, char *segment)
{
    dw->fw = fw_open(dw->store, segment, dw->fis);
    dw->segment = segment;
}

void dw_close(DocWriter *dw)
{
    if (dw->doc_num) { 
        dw_flush(dw);
    }
    if (dw->fw) {
        fw_close(dw->fw);
    }
    h_destroy(dw->curr_plists);
    h_destroy(dw->fields);
    mp_destroy(dw->mp);
    free(dw->offsets);
    free(dw);
}

FieldInverter *dw_get_fld_inv(DocWriter *dw, FieldInfo *fi)
{
    FieldInverter *fld_inv = h_get_int(dw->fields, fi->number);

    if (!fld_inv) {
        fld_inv = fld_inv_new(dw, fi);
        h_set_int(dw->fields, fi->number, fld_inv);
    }
    return fld_inv;
}

static void dw_add_posting(MemoryPool *mp,
                           HashTable *curr_plists,
                           HashTable *fld_plists,
                           int doc_num,
                           const char *text,
                           int len,
                           int pos)
{
    HashEntry *pl_he = h_set_ext(curr_plists, text);
    if (pl_he->value) {
        pl_add_occ(mp, pl_he->value, pos);
    }
    else {
        HashEntry *fld_pl_he = h_set_ext(fld_plists, text);
        PostingList *pl = fld_pl_he->value;
        Posting *p =  p_new(mp, doc_num, pos);
        if (!pl) {
            pl = fld_pl_he->value = pl_new(mp, text, len, p);
            pl_he->key = fld_pl_he->key = (char *)pl->term;
        }
        else {
            pl_add_posting(pl, p);
            pl_he->key = (char *)pl->term;
        }
        pl_he->value = pl;
    }
}

static __inline void dw_add_offsets(DocWriter *dw, int pos, int start, int end)
{
    if (pos >= dw->offsets_capa) {
        int old_capa = dw->offsets_capa;
        while (pos >= dw->offsets_capa) {
            dw->offsets_capa <<= 1;
        }
        REALLOC_N(dw->offsets, Offset, dw->offsets_capa);
        ZEROSET_N(dw->offsets + old_capa, Offset, dw->offsets_capa - old_capa);
    }
    dw->offsets[pos].start = start;
    dw->offsets[pos].end = end;
    dw->offsets_size = pos + 1;
}

HashTable *dw_invert_field(DocWriter *dw,
                           FieldInverter *fld_inv,
                           DocField *df)
{
    MemoryPool *mp = dw->mp;
    Analyzer *a = dw->analyzer;
    HashTable *curr_plists = dw->curr_plists;
    HashTable *fld_plists = fld_inv->plists;
    const bool store_offsets = fld_inv->store_offsets;
    int doc_num = dw->doc_num;
    int i;
    const int df_size = df->size;

    if (fld_inv->is_tokenized) {
        Token *tk;
        int pos = -1, num_terms = 0;
        TokenStream *ts = a_get_ts(a, df->name, "");

        for (i = 0; i < df_size; i++) {
            ts->reset(ts, df->data[i]);
            if (store_offsets) {
                while (NULL != (tk = ts->next(ts))) {
                    pos += tk->pos_inc;
                    dw_add_posting(mp, curr_plists, fld_plists, doc_num,
                                   tk->text, tk->len, pos);
                    dw_add_offsets(dw, pos, tk->start, tk->end);
                    if (num_terms++ >= dw->max_field_length) {
                        break;
                    }
                }
            }
            else {
                while (NULL != (tk = ts->next(ts))) {
                    pos += tk->pos_inc;
                    dw_add_posting(mp, curr_plists, fld_plists, doc_num,
                                   tk->text, tk->len, pos);
                    if (num_terms++ >= dw->max_field_length) {
                        break;
                    }
                }
            }
        }
        ts_deref(ts);
        fld_inv->length = num_terms;
    }
    else {
        char buf[MAX_WORD_SIZE];
        buf[MAX_WORD_SIZE - 1] = '\0';
        for (i = 0; i < df_size; i++) {
            int len = df->lengths[i];
            char *data_ptr = df->data[i];
            if (len > MAX_WORD_SIZE) {
                len = MAX_WORD_SIZE - 1;
                data_ptr = memcpy(buf, df->data[i], len);
            }
            dw_add_posting(mp, curr_plists, fld_plists, doc_num, data_ptr,
                           len, i);
            if (store_offsets) {
                dw_add_offsets(dw, i, 0, df->lengths[i]);
            }
        }
        fld_inv->length = i;
    }
    return curr_plists;
}

void dw_reset_postings(HashTable *postings)
{
    ZEROSET_N(postings->table, HashEntry, postings->mask + 1);
    postings->fill = postings->size = 0;
}

void dw_add_doc(DocWriter *dw, Document *doc)
{
    int i;
    float boost;
    DocField *df;
    FieldInverter *fld_inv;
    HashTable *postings;
    FieldInfo *fi;
    const int doc_size = doc->size;

    /* fw_add_doc will add new fields as necessary */
    fw_add_doc(dw->fw, doc);

    for (i = 0; i < doc_size; i++) {
        df = doc->fields[i];
        fi = fis_get_field(dw->fis, df->name);
        if (!fi_is_indexed(fi)) {
            continue;
        }
        fld_inv = dw_get_fld_inv(dw, fi);

        postings = dw_invert_field(dw, fld_inv, df);
        if (fld_inv->store_term_vector) {
            fw_add_postings(dw->fw, fld_inv->fi->number,
                            dw_sort_postings(postings), postings->size,
                            dw->offsets, dw->offsets_size);
        }

        if (fld_inv->has_norms) {
            boost = fld_inv->fi->boost * doc->boost * df->boost *
                sim_length_norm(dw->similarity, fi->name, fld_inv->length);
            fld_inv->norms[dw->doc_num] =
                sim_encode_norm(dw->similarity, boost);
        }
        dw_reset_postings(postings);
        if (dw->offsets_size > 0) {
            ZEROSET_N(dw->offsets, Offset, dw->offsets_size);
            dw->offsets_size = 0;
        }
    }
    fw_write_tv_index(dw->fw);
    dw->doc_num++;
}

/****************************************************************************
 *
 * IndexWriter
 *
 ****************************************************************************/
/****************************************************************************
 * SegmentMergeInfo
 ****************************************************************************/

typedef struct SegmentMergeInfo {
    int base;
    int max_doc;
    int doc_cnt;
    char *segment;
    Store *store;
    Store *orig_store;
    BitVector *deleted_docs;
    SegmentFieldIndex *sfi;
    TermEnum *te;
    TermDocEnum *tde;
    char *term;
    int *doc_map;
    InStream *frq_in;
    InStream *prx_in;
} SegmentMergeInfo;

static bool smi_lt(const SegmentMergeInfo *smi1, const SegmentMergeInfo *smi2)
{
    int cmpres = strcmp(smi1->term, smi2->term);
    if (cmpres == 0) {
        return smi1->base < smi2->base;
    }
    else {
        return cmpres < 0;
    }
}

static void smi_load_doc_map(SegmentMergeInfo *smi)
{
    BitVector *deleted_docs = smi->deleted_docs;
    const int max_doc = smi->max_doc;
    int j = 0, i;

    smi->doc_map = ALLOC_N(int, max_doc);
    for (i = 0; i < max_doc; i++) {
        if (bv_get(deleted_docs, i)) {
            smi->doc_map[i] = -1;
        }
        else {
            smi->doc_map[i] = j++;
        }
    }
    smi->doc_cnt = j;
}

static SegmentMergeInfo *smi_new(int base, Store *store, char *segment)
{
    SegmentMergeInfo *smi = ALLOC_AND_ZERO(SegmentMergeInfo);
    char file_name[SEGMENT_NAME_MAX_LENGTH];
    smi->base = base;
    smi->segment = segment;
    smi->orig_store = smi->store = store;
    sprintf(file_name, "%s.cfs", segment);
    if (store->exists(store, file_name)) {
        smi->store = open_cmpd_store(store, file_name);
    }


    sprintf(file_name, "%s.fdx", segment);
    smi->doc_cnt = smi->max_doc
        = smi->store->length(smi->store, file_name) / FIELDS_IDX_PTR_SIZE;

    sprintf(file_name, "%s.del", segment);
    if (store->exists(store, file_name)) {
        smi->deleted_docs = bv_read(store, file_name);
        smi_load_doc_map(smi);
    }
    return smi;
}

static void smi_load_term_input(SegmentMergeInfo *smi)
{
    Store *store = smi->store;
    char file_name[SEGMENT_NAME_MAX_LENGTH];
    smi->sfi = sfi_open(store, smi->segment);
    sprintf(file_name, "%s.tis", smi->segment);
    smi->te = TE(ste_new(store->open_input(store, file_name), smi->sfi));
    sprintf(file_name, "%s.frq", smi->segment);
    smi->frq_in = store->open_input(store, file_name);
    sprintf(file_name, "%s.prx", smi->segment);
    smi->prx_in = store->open_input(store, file_name);
    smi->tde = stpe_new(NULL, smi->frq_in, smi->prx_in, smi->deleted_docs,
                        STE(smi->te)->skip_interval);
}

static void smi_close_term_input(SegmentMergeInfo *smi)
{
    ste_close(smi->te);
    sfi_close(smi->sfi);
    stpe_close(smi->tde);
    is_close(smi->frq_in);
    is_close(smi->prx_in);
}

static void smi_destroy(SegmentMergeInfo *smi)
{
    if (smi->store != smi->orig_store) {
        store_deref(smi->store);
    }
    if (smi->deleted_docs) {
        bv_destroy(smi->deleted_docs);
        free(smi->doc_map);
    }
    free(smi);
}

static char *smi_next(SegmentMergeInfo *smi)
{
    return (smi->term = ste_next(smi->te));
}

/****************************************************************************
 * SegmentMerger
 ****************************************************************************/

typedef struct SegmentMerger {
    TermInfo ti;
    Store *store;
    FieldInfos *fis;
    char *segment;
    SegmentMergeInfo **smis;
    int seg_cnt;
    int doc_cnt;
    Config *config;
    TermInfosWriter *tiw;
    char *term_buf;
    int term_buf_ptr;
    int term_buf_size;
    PriorityQueue *queue;
    SkipBuffer *skip_buf;
    OutStream *frq_out;
    OutStream *prx_out;
} SegmentMerger;

static SegmentMerger *sm_create(IndexWriter *iw, char *segment,
                                SegmentInfo **seg_infos, const int seg_cnt)
{
    int i;
    SegmentMerger *sm = ALLOC_AND_ZERO_N(SegmentMerger, seg_cnt);
    sm->store = iw->store;
    sm->fis = iw->fis;
    sm->segment = estrdup(segment);
    sm->doc_cnt = 0;
    sm->smis = ALLOC_N(SegmentMergeInfo *, seg_cnt);
    for (i = 0; i < seg_cnt; i++) {
        sm->smis[i] = smi_new(sm->doc_cnt, seg_infos[i]->store,
                              seg_infos[i]->name);
        sm->doc_cnt += sm->smis[i]->doc_cnt;
    }
    sm->seg_cnt = seg_cnt;
    sm->config = &iw->config;
    return sm;
}

static void sm_destroy(SegmentMerger *sm)
{
    int i;
    const int seg_cnt = sm->seg_cnt;
    for (i = 0; i < seg_cnt; i++) {
        smi_destroy(sm->smis[i]);
    }
    free(sm->smis);
    free(sm->segment);
    free(sm);
}

static void sm_merge_fields(SegmentMerger *sm)
{
    int i, j;
    off_t start, end = 0;
    char file_name[SEGMENT_NAME_MAX_LENGTH];
    OutStream *fdt_out, *fdx_out;
    Store *store = sm->store;
    const int seg_cnt = sm->seg_cnt;

    sprintf(file_name, "%s.fdt", sm->segment);
    fdt_out = store->new_output(store, file_name);

    sprintf(file_name, "%s.fdx", sm->segment);
    fdx_out = store->new_output(store, file_name);

    for (i = 0; i < seg_cnt; i++) {
        SegmentMergeInfo *smi = sm->smis[i];
        const int max_doc = smi->max_doc;
        InStream *fdt_in, *fdx_in;
        store = smi->store;
        sprintf(file_name, "%s.fdt", smi->segment);
        fdt_in = store->open_input(store, file_name);
        sprintf(file_name, "%s.fdx", smi->segment);
        fdx_in = store->open_input(store, file_name);

        if (max_doc > 0) {
            end = (off_t)is_read_u64(fdx_in);
        }
        for (j = 0; j < max_doc; j++) {
            f_u32 tv_idx_offset = is_read_u32(fdx_in);
            start = end;
            if (j == max_doc - 1) {
                end = is_length(fdt_in);
            }
            else {
                end = (off_t)is_read_u64(fdx_in);
            }
            /* skip deleted docs */
            if (!smi->deleted_docs || !bv_get(smi->deleted_docs, j)) {
                os_write_u64(fdx_out, os_pos(fdt_out));
                os_write_u32(fdx_out, tv_idx_offset);
                is_seek(fdt_in, start);
                is2os_copy_bytes(fdt_in, fdt_out, end - start);
            }
        }
        is_close(fdt_in);
        is_close(fdx_in);
    }
    os_close(fdt_out);
    os_close(fdx_out);
}

static int sm_append_postings(SegmentMerger *sm, SegmentMergeInfo **matches,
                              const int match_size)
{
    int i;
    int last_doc = 0, base, doc, doc_code, freq;
    int skip_interval = sm->config->skip_interval;
    int *doc_map = NULL;
    int df = 0;            /* number of docs w/ term */
    TermDocEnum *tde;
    SegmentMergeInfo *smi;
    SkipBuffer *skip_buf = sm->skip_buf;
    skip_buf_reset(skip_buf);

    for (i = 0; i < match_size; i++) {
        smi = matches[i];
        base = smi->base;
        doc_map = smi->doc_map;
        tde = smi->tde;
        stpe_seek_ti(STDE(tde), &smi->te->curr_ti);

        /* since we are using copy_bytes below to copy the proximities we use
         * stde_next rather than stpe_next here */
        while (stde_next(tde)) {
            doc = stde_doc_num(tde);
            if (doc_map != NULL) {
                doc = doc_map[doc]; /* work around deletions */
            }
            doc += base;          /* convert to merged space */

#ifdef DEBUG
            if (doc && doc <= last_doc) {
                RAISE(STATE_ERROR, "Docs not ordered, %d < %d", doc, last_doc);
            }
#endif
            df++;

            if ((df % skip_interval) == 0) {
                skip_buf_add(skip_buf, last_doc);
            }

            doc_code = (doc - last_doc) << 1;    /* use low bit to flag freq=1 */
            last_doc = doc;

            freq = stde_freq(tde);
            if (freq == 1) {
                os_write_vint(sm->frq_out, doc_code | 1); /* doc & freq=1 */
            }
            else {
                os_write_vint(sm->frq_out, doc_code); /* write doc */
                os_write_vint(sm->frq_out, freq);     /* write freqency in doc */
            }

            /* copy position deltas */
            is2os_copy_vints(STDE(tde)->prx_in, sm->prx_out, freq);
        }
    }
    return df;
}

static char *sm_cache_term(SegmentMerger *sm, char *term, int term_len)
{
    term = memcpy(sm->term_buf + sm->term_buf_ptr, term, term_len + 1);
    sm->term_buf_ptr += term_len + 1;
    if (sm->term_buf_ptr > sm->term_buf_size) {
        sm->term_buf_ptr = 0;
    }
    return term;
}

static void sm_merge_term_info(SegmentMerger *sm, SegmentMergeInfo **matches,
                               int match_size)
{
    int frq_ptr = os_pos(sm->frq_out);
    int prx_ptr = os_pos(sm->prx_out);

    int df = sm_append_postings(sm, matches, match_size); /* append posting data */

    int skip_ptr = skip_buf_write(sm->skip_buf);

    if (df > 0) {
        /* add an entry to the dictionary with ptrs to prox and freq files */
        SegmentMergeInfo *first_match = matches[0];
        int term_len = first_match->te->curr_term_len;

        ti_set(sm->ti, df, frq_ptr, prx_ptr,
               (skip_ptr - frq_ptr));
        tiw_add(sm->tiw, sm_cache_term(sm, first_match->term, term_len),
                term_len, &sm->ti);
    }
}

static void sm_merge_term_infos(SegmentMerger *sm)
{
    int i, j, match_size;
    SegmentMergeInfo *smi, *top, **matches;
    char *term;
    const int seg_cnt = sm->seg_cnt;
    const int fis_size = sm->fis->size;

    matches = ALLOC_N(SegmentMergeInfo *, seg_cnt);

    for (j = 0; j < seg_cnt; j++) {
        smi_load_term_input(sm->smis[j]);
    }

    for (i = 0; i < fis_size; i++) {
        tiw_start_field(sm->tiw, i);
        for (j = 0; j < seg_cnt; j++) {
            smi = sm->smis[j];
            ste_set_field(smi->te, i);
            if (smi_next(smi) != NULL) {
                pq_push(sm->queue, smi); /* initialize @queue */
            }
        }
        while (sm->queue->size > 0) {
            /*
               for (i = 1; i <= sm->queue->count; i++) {
               printf("<{%s:%s}>", ((SegmentMergeInfo *)sm->queue->heap[i])->tb->field,
               ((SegmentMergeInfo *)sm->queue->heap[i])->tb->text);
               }printf("\n\n");
               */
            match_size = 0;     /* pop matching terms */
            matches[0] = pq_pop(sm->queue);
            match_size++;
            term = matches[0]->term;
            top = pq_top(sm->queue);
            while ((top != NULL) && (strcmp(term, top->term) == 0)) {
                matches[match_size] = pq_pop(sm->queue);
                match_size++;
                top = pq_top(sm->queue);
            }

            /* printf(">%s:%s<\n", matches[0]->tb->field, matches[0]->tb->text); */
            sm_merge_term_info(sm, matches, match_size);/* add new TermInfo */

            while (match_size > 0) {
                match_size--;
                smi = matches[match_size];
                if (smi_next(smi) != NULL) {
                    pq_push(sm->queue, smi);   /* restore queue */
                }
            }
        }
    }
    free(matches);
    for (j = 0; j < seg_cnt; j++) {
        smi_close_term_input(sm->smis[j]);
    }
}

static void sm_merge_terms(SegmentMerger *sm)
{
    char file_name[SEGMENT_NAME_MAX_LENGTH];

    sprintf(file_name, "%s.frq", sm->segment);
    sm->frq_out = sm->store->new_output(sm->store, file_name);
    sprintf(file_name, "%s.prx", sm->segment);
    sm->prx_out = sm->store->new_output(sm->store, file_name);

    sm->tiw = tiw_open(sm->store, sm->segment, sm->config->index_interval,
                       sm->config->skip_interval);
    sm->skip_buf = skip_buf_new(sm->frq_out, sm->prx_out);

    /* terms_buf_ptr holds a buffer of terms since the TermInfosWriter needs
     * to keep the last index_interval terms so that it can compare the last
     * term put in the index with the next one. So the size of the buffer must
     * by index_interval + 2. */
    sm->term_buf_ptr = 0;
    sm->term_buf_size = (sm->config->index_interval + 1) * MAX_WORD_SIZE;
    sm->term_buf = ALLOC_N(char, sm->term_buf_size + MAX_WORD_SIZE);

    sm->queue = pq_new(sm->seg_cnt, (lt_ft)&smi_lt, NULL);

    sm_merge_term_infos(sm);

    os_close(sm->frq_out);
    os_close(sm->prx_out);
    tiw_close(sm->tiw);
    pq_destroy(sm->queue);
    skip_buf_destroy(sm->skip_buf);
    free(sm->term_buf);
}

static void sm_merge_norms(SegmentMerger *sm)
{
    int i, j, k;
    Store *store;
    uchar byte;
    FieldInfo *fi;
    OutStream *os;
    InStream *is;
    char file_name[SEGMENT_NAME_MAX_LENGTH];
    SegmentMergeInfo *smi;
    const int seg_cnt = sm->seg_cnt;
    const int fis_size = sm->fis->size;
    for (i = 0; i < fis_size; i++) {
        fi = sm->fis->fields[i];
        if (fi_has_norms(fi))  {
            sprintf(file_name, "%s.f%d", sm->segment, i);
            os = sm->store->new_output(sm->store, file_name);
            for (j = 0; j < seg_cnt; j++) {
                smi = sm->smis[j];
                store = smi->orig_store;
                sprintf(file_name, "%s.s%d", smi->segment, i);
                if (!store->exists(store, file_name)) {
                    sprintf(file_name, "%s.f%d", smi->segment, i);
                    store = smi->store;
                }
                if (store->exists(store, file_name)) {
                    const int max_doc = smi->max_doc;
                    BitVector *deleted_docs =  smi->deleted_docs;
                    is = store->open_input(store, file_name);
                    if (deleted_docs) {
                        for (k = 0; k < max_doc; k++) {
                            byte = is_read_byte(is);
                            if (!bv_get(deleted_docs, k)) {
                                os_write_byte(os, byte);
                            }
                        }
                    }
                    else {
                        is2os_copy_bytes(is, os, max_doc);
                    }
                    is_close(is);
                }
                else {
                    const int doc_cnt = smi->doc_cnt;
                    for (k = 0; k < doc_cnt; k++) {
                        os_write_byte(os, '\0');
                    }
                }
            }
            os_close(os);
        }
    }
}

static int sm_merge(SegmentMerger *sm)
{
    sm_merge_fields(sm);
    sm_merge_terms(sm);
    sm_merge_norms(sm);
    return sm->doc_cnt;
}


/****************************************************************************
 * IndexWriter
 ****************************************************************************/

/* prepare an index ready for writing */
void index_create(Store *store, FieldInfos *fis)
{
    SegmentInfos *sis = sis_new();
    store->clear_all(store);
    sis_write(sis, store);
    sis_destroy(sis);
    fis_write(fis, store);
}

int iw_doc_count(IndexWriter *iw)
{
    int i, doc_cnt = 0;
    mutex_lock(&iw->mutex);
    for (i = iw->sis->size - 1; i >= 0; i--) {
        doc_cnt += iw->sis->segs[i]->doc_cnt;
    }
    if (iw->dw) {
        doc_cnt += iw->dw->doc_num;
    }
    mutex_unlock(&iw->mutex);
    return doc_cnt;
}

static void delete_files(char **file_names, Store *store)
{
    int i;
    for (i = ary_size(file_names) - 1; i >= 0; i--) {
        store->remove(store, file_names[i]);
    }
    ary_destroy((void **)file_names, &free);
}

static char **iw_create_compound_file(Store *store, FieldInfos *fis,
                                      char *segment, char *cfs_file_name)
{
    char **file_names = (char **)ary_new_capa(16);
    CompoundWriter *cw;
    FieldInfo *fi;
    int i;
    char file_name[SEGMENT_NAME_MAX_LENGTH];
    const int fis_size = fis->size;
    int file_names_size;

    cw = open_cw(store, cfs_file_name);
    for (i = 0; i < NELEMS(COMPOUND_EXTENSIONS); i++) {
        sprintf(file_name, "%s.%s",
                segment, COMPOUND_EXTENSIONS[i]);
        ary_push(file_names, estrdup(file_name));
    }

    /* Field norm file_names */
    for (i = 0; i < fis_size; i++) {
        fi = fis->fields[i];
        if (fi_has_norms(fi)) {
            sprintf(file_name, "%s.f%d", segment, i);
            if (!store->exists(store, file_name)) {
                continue;
            }
            ary_push(file_names, estrdup(file_name));
        }
    }

    /* Now merge all added file_names */
    file_names_size = ary_size(file_names);
    for (i = 0; i < file_names_size; i++) {
        cw_add_file(cw, file_names[i]);
    }

    /* Perform the merge */
    cw_close(cw);

    return file_names;
}

static void iw_commit_compound_file(IndexWriter *iw, char *segment,
                                    Lock *commit_lock)
{
    char tmp_name[SEGMENT_NAME_MAX_LENGTH];
    char cfs_name[SEGMENT_NAME_MAX_LENGTH];
    char **files_to_delete;
    sprintf(tmp_name, "%s.tmp", segment);
    sprintf(cfs_name, "%s.cfs", segment);

    files_to_delete =
        iw_create_compound_file(iw->store, iw->fis, segment, tmp_name);
    if (!commit_lock->obtain(commit_lock)) {
        RAISE(LOCK_ERROR,
              "Couldn't obtain commit lock to write compound file");
    }

    delete_files(files_to_delete, iw->store);
    iw->store->rename(iw->store, tmp_name, cfs_name);

    commit_lock->release(commit_lock);
}

#define ADD_IF_EXISTS_FMT(fmt, ext) do {\
    sprintf(file_name, fmt, segment, ext);\
    if (store->exists(store, file_name)) {\
        ary_push(file_names, estrdup(file_name));\
    }\
} while (0)

#define ADD_IF_EXISTS(ext) ADD_IF_EXISTS_FMT("%s.%s", ext)

static char **iw_seg_file_names(FieldInfos *fis, Store *store, char *segment)
{
    char **file_names = (char **)ary_new_capa(16);
    int i;
    char file_name[SEGMENT_NAME_MAX_LENGTH];
    const int fis_size = fis->size;


    sprintf(file_name, "%s.cfs", segment);
    if (store->exists(store, file_name)) {
        ary_push(file_names, estrdup(file_name));
        ADD_IF_EXISTS("del");
        for (i = 0; i < fis_size; i++) {
            if (fi_has_norms(fis->fields[i])) {
                ADD_IF_EXISTS_FMT("%s.s%d", i);
            }
        }
    }
    else {
        for (i = 0; i < NELEMS(INDEX_EXTENSIONS); i++) {
            ADD_IF_EXISTS(INDEX_EXTENSIONS[i]);
        }
        for (i = 0; i < fis_size; i++) {
            if (fi_has_norms(fis->fields[i])) {
                ADD_IF_EXISTS_FMT("%s.f%d", i);
            }
        }
    }
    return file_names;
}

static void iw_merge_segments(IndexWriter *iw, const int min_seg,
                              const int max_seg)
{
    int i;
    Lock *commit_lock;
    SegmentInfos *sis = iw->sis;
    SegmentInfo *si = sis_new_segment(sis, 0, iw->store);

    SegmentMerger *merger = sm_create(iw, si->name, &sis->segs[min_seg],
                                      max_seg - min_seg);

    /* This is where all the action happens. */
    si->doc_cnt = sm_merge(merger);

    mutex_lock(&iw->store->mutex);
    commit_lock = open_lock(iw->store, COMMIT_LOCK_NAME);

    /* *** OBTAIN COMMIT LOCK *** */
    if (!commit_lock->obtain(commit_lock)) {
        RAISE(LOCK_ERROR, "Couldn't obtain commit lock to commit merged segment "
              "%s", si->name);
    }
    /* delete merged segments */
    for (i = min_seg; i < max_seg; i++) {
        delete_files(
            iw_seg_file_names(iw->fis, sis->segs[i]->store, sis->segs[i]->name),
            iw->store);
    }
    sis_del_from_to(sis, min_seg, max_seg);
    /* commit the segments file */
    sis_write(sis, iw->store);
    commit_lock->release(commit_lock);
    /* RELEASE COMMIT LOCK */

    if (iw->config.use_compound_file) {
        iw_commit_compound_file(iw, si->name, commit_lock);
    }

    close_lock(commit_lock);

    mutex_unlock(&iw->store->mutex);

    sm_destroy(merger);
}

static void iw_merge_segments_from(IndexWriter *iw, int min_segment)
{
    iw_merge_segments(iw, min_segment, iw->sis->size);
}

static void iw_maybe_merge_segments(IndexWriter *iw)
{
    int target_merge_docs = iw->config.merge_factor;
    int min_segment, merge_docs;
    SegmentInfo *si;

    while (target_merge_docs > 0
           && target_merge_docs <= iw->config.max_merge_docs) {
        /* find segments smaller than current target size */
        min_segment = iw->sis->size - 1;
        merge_docs = 0;
        while (min_segment >= 0) {
            si = iw->sis->segs[min_segment];
            if (si->doc_cnt >= target_merge_docs) {
                break;
            }
            merge_docs += si->doc_cnt;
            min_segment--;
        }

        if (merge_docs >= target_merge_docs) { /* found a merge to do */
            iw_merge_segments_from(iw, min_segment + 1);
        }
        else if (min_segment <= 0) {
            break;
        }

        target_merge_docs *= iw->config.merge_factor;
    }
}

static void iw_flush_ram_segment(IndexWriter *iw)
{
    SegmentInfos *sis = iw->sis;
    SegmentInfo *si;
    Lock *commit_lock;

    si = sis->segs[sis->size - 1];
    si->doc_cnt = iw->dw->doc_num;
    dw_flush(iw->dw);

    mutex_lock(&iw->store->mutex);
    commit_lock = open_lock(iw->store, COMMIT_LOCK_NAME);

    if (!commit_lock->obtain(commit_lock)) {
        RAISE(LOCK_ERROR, "Couldn't obtain commit lock to write segments file");
    }
    /* commit the segments file and the fields file */
    fis_write(iw->fis, iw->store);
    sis_write(iw->sis, iw->store);
    commit_lock->release(commit_lock);


    if (iw->config.use_compound_file) {
        iw_commit_compound_file(iw, si->name, commit_lock);
    }
    close_lock(commit_lock);
    mutex_unlock(&iw->store->mutex);

    iw_maybe_merge_segments(iw);
}

void iw_add_doc(IndexWriter *iw, Document *doc)
{
    mutex_lock(&iw->mutex);
    if (!iw->dw) {
        iw->dw = dw_open(iw, sis_new_segment(iw->sis, 0, iw->store)->name);
    }
    else if (iw->dw->fw == NULL) {
        dw_new_segment(iw->dw, sis_new_segment(iw->sis, 0, iw->store)->name);
    }
    dw_add_doc(iw->dw, doc);
    if (mp_used(iw->dw->mp) > iw->config.max_buffer_memory
        || iw->dw->doc_num >= iw->config.max_buffered_docs) {
        iw_flush_ram_segment(iw);
    }
    mutex_unlock(&iw->mutex);
}

static void iw_commit_i(IndexWriter *iw)
{
    if (iw->dw && iw->dw->doc_num > 0) {
        iw_flush_ram_segment(iw);
    }
}

void iw_commit(IndexWriter *iw)
{
    mutex_lock(&iw->mutex);
    iw_commit_i(iw);
    mutex_unlock(&iw->mutex);
}

void iw_delete_term(IndexWriter *iw, const char *field, const char *term)
{
    int field_num = fis_get_field_num(iw->fis, field);
    if (field_num >= 0) {
        int i;
        mutex_lock(&iw->mutex);
        iw_commit_i(iw);
        do {
            SegmentInfos *sis = iw->sis;
            const int seg_cnt = sis->size;
            for (i = 0; i < seg_cnt; i++) {
                IndexReader *ir = sr_open(sis, iw->fis, i, false);
                TermDocEnum *tde = ir->term_docs(ir);
                stde_seek(tde, field_num, term);
                while (tde->next(tde)) {
                    sr_delete_doc_i(ir, STDE(tde)->doc_num);
                }
                tde_destroy(tde);
                sr_commit_i(ir);
                ir_close(ir);
            }
        } while (0);
        mutex_unlock(&iw->mutex);
    }
}

static void iw_optimize_i(IndexWriter *iw)
{
    int min_segment;
    iw_commit_i(iw);
    while (iw->sis->size > 1
           || (iw->sis->size == 1
               && (si_has_deletions(iw->sis->segs[0])
                   || (iw->sis->segs[0]->store != iw->store)
                   || (iw->config.use_compound_file
                       && (!si_uses_compound_file(iw->sis->segs[0])
                           || si_has_separate_norms(iw->sis->segs[0])))))) {
        min_segment = iw->sis->size - iw->config.merge_factor;
        iw_merge_segments_from(iw, min_segment < 0 ? 0 : min_segment);
    }
}

void iw_optimize(IndexWriter *iw)
{
    mutex_lock(&iw->mutex);
    iw_optimize_i(iw);
    mutex_unlock(&iw->mutex);
} 

void iw_close(IndexWriter *iw)
{
    mutex_lock(&iw->mutex);
    iw_commit_i(iw);
    if (iw->dw) {
        dw_close(iw->dw);
    }
    a_deref(iw->analyzer);
    sis_destroy(iw->sis);
    fis_deref(iw->fis);
    sim_destroy(iw->similarity);

    iw->write_lock->release(iw->write_lock);
    close_lock(iw->write_lock);
    store_deref(iw->store);

    mutex_destroy(&iw->mutex);
    free(iw);
}

IndexWriter *iw_open(Store *store, Analyzer *analyzer, const Config *config)
{
    IndexWriter *iw = ALLOC_AND_ZERO(IndexWriter);
    mutex_init(&iw->mutex, NULL);
    iw->store = store;
    if (!config) {
        config = &default_config;
    }
    iw->config = *config;

    TRY
        iw->write_lock = open_lock(store, WRITE_LOCK_NAME);
        if (!iw->write_lock->obtain(iw->write_lock)) {
            RAISE(LOCK_ERROR,
                  "Couldn't obtain write lock when opening IndexWriter");
        }


        iw->sis = sis_read(store);
        iw->fis = fis_read(store);
    XCATCHALL
        if (iw->write_lock) {
            iw->write_lock->release(iw->write_lock);
            close_lock(iw->write_lock);
        }
        if (iw->sis) sis_destroy(iw->sis);
        if (iw->fis) fis_deref(iw->fis);
        free(iw);
    XENDTRY

    iw->similarity = sim_create_default();
    iw->analyzer = analyzer ? analyzer : mb_standard_analyzer_new(true);

    REF(store);
    return iw;
}

/*******************/
/*** Add Indexes ***/
/*******************/
static void iw_cp_fields(IndexWriter *iw, SegmentReader *sr,
                         const char *segment, int *map)
{
    char file_name[SEGMENT_NAME_MAX_LENGTH];
    OutStream *fdt_out, *fdx_out;
    InStream *fdt_in, *fdx_in;
    Store *store_in = sr->cfs_store ? sr->cfs_store : sr->ir.store;
    Store *store_out = iw->store;

    sprintf(file_name, "%s.fdt", segment);
    fdt_out = store_out->new_output(store_out, file_name);
    sprintf(file_name, "%s.fdx", segment);
    fdx_out = store_out->new_output(store_out, file_name);

    sprintf(file_name, "%s.fdt", sr->segment);
    fdt_in = store_in->open_input(store_in, file_name);
    sprintf(file_name, "%s.fdx", sr->segment);
    fdx_in = store_in->open_input(store_in, file_name);

    sprintf(file_name, "%s.del", sr->segment);
    if (store_in->exists(store_in, file_name)) {
        OutStream *del_out;
        InStream *del_in = store_in->open_input(store_in, file_name);
        sprintf(file_name, "%s.del", segment);
        del_out = store_out->new_output(store_out, file_name);
        is2os_copy_bytes(del_in, del_out, is_length(del_in));
    }


    if (map) {
        int i;
        const int max_doc = sr_max_doc(IR(sr));
        for (i = 0; i < max_doc; i++) {
            int j;
            const int field_cnt = is_read_vint(fdt_in);
            int tv_cnt;
            off_t doc_start_ptr = os_pos(fdt_out);

            os_write_u64(fdx_out, doc_start_ptr);
            os_write_vint(fdt_out, field_cnt);

            for (j = 0; j < field_cnt; j++) {
                int k;
                const int field_num = map[is_read_vint(fdt_in)];
                const int df_size = is_read_vint(fdt_in);
                int data_len = 0;
                os_write_vint(fdt_out, field_num);
                os_write_vint(fdt_out, df_size);
                /* sum total lengths of DocField */
                for (k = 0; k < df_size; k++) {
                    /* Each field has one ' ' byte so add 1 */
                    const int flen = is_read_vint(fdt_in);
                    os_write_vint(fdt_out, flen);
                    data_len +=  flen + 1;
                }
                is2os_copy_bytes(fdt_in, fdt_out, data_len);
            }

            /* Write TermVectors */
            /* write TVs up to TV index */
            is2os_copy_bytes(fdt_in, fdt_out,
                             (int)(is_read_u64(fdx_in)
                                   + (f_u64)is_read_u32(fdx_in)
                                   - (f_u64)is_pos(fdt_in)));

            /* Write TV index pos */
            os_write_u32(fdx_out, (f_u32)(os_pos(fdt_out) - doc_start_ptr));
            tv_cnt = is_read_vint(fdt_in);
            os_write_vint(fdt_out, tv_cnt);
            for (j = 0; j < tv_cnt; j++) {
                const int field_num = map[is_read_vint(fdt_in)];
                const int tv_size = is_read_vint(fdt_in);
                os_write_vint(fdt_out, field_num);
                os_write_vint(fdt_out, tv_size);
            }
        }
    }
    else {
        is2os_copy_bytes(fdt_in, fdt_out, is_length(fdt_in));
        is2os_copy_bytes(fdx_in, fdx_out, is_length(fdx_in));
    }
    is_close(fdt_in);
    is_close(fdx_in);
    os_close(fdt_out);
    os_close(fdx_out);
}

static void iw_cp_terms(IndexWriter *iw, SegmentReader *sr,
                        const char *segment, int *map)
{
    char file_name[SEGMENT_NAME_MAX_LENGTH];
    OutStream *tix_out, *tis_out, *tfx_out, *frq_out, *prx_out;
    InStream *tix_in, *tis_in, *tfx_in, *frq_in, *prx_in;
    Store *store_out = iw->store;
    Store *store_in = sr->cfs_store ? sr->cfs_store : sr->ir.store;

    sprintf(file_name, "%s.tix", segment);
    tix_out = store_out->new_output(store_out, file_name);
    sprintf(file_name, "%s.tix", sr->segment);
    tix_in = store_in->open_input(store_in, file_name);
    
    sprintf(file_name, "%s.tis", segment);
    tis_out = store_out->new_output(store_out, file_name);
    sprintf(file_name, "%s.tis", sr->segment);
    tis_in = store_in->open_input(store_in, file_name);

    sprintf(file_name, "%s.tfx", segment);
    tfx_out = store_out->new_output(store_out, file_name);
    sprintf(file_name, "%s.tfx", sr->segment);
    tfx_in = store_in->open_input(store_in, file_name);

    sprintf(file_name, "%s.frq", segment);
    frq_out = store_out->new_output(store_out, file_name);
    sprintf(file_name, "%s.frq", sr->segment);
    frq_in = store_in->open_input(store_in, file_name);

    sprintf(file_name, "%s.prx", segment);
    prx_out = store_out->new_output(store_out, file_name);
    sprintf(file_name, "%s.prx", sr->segment);
    prx_in = store_in->open_input(store_in, file_name);

    if (map) {
        int field_cnt = is_read_u32(tfx_in);
        os_write_u32(tfx_out, field_cnt);
        os_write_vint(tfx_out, is_read_vint(tfx_in)); /* index_interval */
        os_write_vint(tfx_out, is_read_vint(tfx_in)); /* skip_interval */

        for (; field_cnt > 0; field_cnt--) {
            os_write_vint(tfx_out, map[is_read_vint(tfx_in)]);/* mapped field */
            os_write_voff_t(tfx_out, is_read_voff_t(tfx_in)); /* index ptr */
            os_write_voff_t(tfx_out, is_read_voff_t(tfx_in)); /* dict ptr */
            os_write_vint(tfx_out, is_read_vint(tfx_in));     /* index size */
            os_write_vint(tfx_out, is_read_vint(tfx_in));     /* dict size */
        }
    }
    else {
        is2os_copy_bytes(tfx_in, tfx_out, is_length(tfx_in));
    }
    is2os_copy_bytes(tix_in, tix_out, is_length(tix_in));
    is2os_copy_bytes(tis_in, tis_out, is_length(tis_in));
    is2os_copy_bytes(frq_in, frq_out, is_length(frq_in));
    is2os_copy_bytes(prx_in, prx_out, is_length(prx_in));

    is_close(tix_in);
    os_close(tix_out);
    is_close(tis_in);
    os_close(tis_out);
    is_close(tfx_in);
    os_close(tfx_out);
    is_close(frq_in);
    os_close(frq_out);
    is_close(prx_in);
    os_close(prx_out);
}

static void iw_cp_norms(IndexWriter *iw, SegmentReader *sr,
                        const char *segment, int *map)
{
    int i;
    FieldInfos *fis = IR(sr)->fis;
    const int field_cnt = fis->size;
    InStream *norms_in;
    OutStream *norms_out;
    Store *store_in = sr->ir.store;
    Store *cfs_store_in = sr->cfs_store;
    Store *store_out = iw->store;
    char file_name_in[SEGMENT_NAME_MAX_LENGTH];
    char *ext_ptr_in;
    char file_name_out[SEGMENT_NAME_MAX_LENGTH];
    char *ext_ptr_out;
    sprintf(file_name_in, "%s.", sr->segment);
    ext_ptr_in = file_name_in + strlen(file_name_in);
    sprintf(file_name_out, "%s.", segment);
    ext_ptr_out = file_name_out + strlen(file_name_out);

    for (i = 0; i < field_cnt; i++) {
        if (fi_has_norms(fis->fields[i])) {
            Store *store = store_in;
            sprintf(ext_ptr_in, "s%d", i);
            if (!store->exists(store, file_name_in)) {
                sprintf(ext_ptr_in, "f%d", i);
                store = cfs_store_in;
            }
            if (store->exists(store, file_name_in)) {
                norms_in = store->open_input(store, file_name_in);
                sprintf(ext_ptr_out, "f%d", map ? map[i] : i);
                norms_out = store_out->new_output(store_out, file_name_out);
                is2os_copy_bytes(norms_in, norms_out, is_length(norms_in));
                os_close(norms_out);
                is_close(norms_in);
            }
        }
    }
}

static void iw_cp_map_files(IndexWriter *iw, SegmentReader *sr,
                            const char *segment)
{
    int i;
    FieldInfos *from_fis = IR(sr)->fis;
    FieldInfos *to_fis = iw->fis;
    const int map_size = from_fis->size;
    int *field_map = ALLOC_N(int, map_size);

    for (i = 0; i < map_size; i++) {
        field_map[i] = fis_get_field_num(to_fis, from_fis->fields[i]->name);
    }

    iw_cp_fields(iw, sr, segment, field_map);
    iw_cp_terms(iw, sr, segment, field_map);
    iw_cp_norms(iw, sr, segment, field_map);

    free(field_map);
}

static void iw_cp_files(IndexWriter *iw, SegmentReader *sr,
                        const char *segment)
{
    iw_cp_fields(iw, sr, segment, NULL);
    iw_cp_terms(iw, sr, segment, NULL);
    iw_cp_norms(iw, sr, segment, NULL);
}

static void iw_add_segment(IndexWriter *iw, SegmentReader *sr)
{
    SegmentInfo *si = sis_new_segment(iw->sis, 0, iw->store);
    FieldInfos *fis = iw->fis;
    FieldInfos *sub_fis = sr->ir.fis;
    int j;
    const int fis_size = sub_fis->size;
    bool must_map_fields = false;

    si->doc_cnt = IR(sr)->max_doc(IR(sr));
    /* Merge FieldInfos */
    for (j = 0; j < fis_size; j++) {
        FieldInfo *fi = sub_fis->fields[j];
        FieldInfo *new_fi = fis_get_field(fis, fi->name);
        if (NULL == new_fi) {
            new_fi = fi_new(fi->name, 0, 0, 0);
            new_fi->bits = fi->bits;
            fis_add_field(fis, new_fi);
        }
        new_fi->bits |= fi->bits;
        if (fi->number != new_fi->number) {
            must_map_fields = true;
        }
    }

    if (must_map_fields) {
        iw_cp_map_files(iw, sr, si->name);
    }
    else {
        iw_cp_files(iw, sr, si->name);
    }
}

static void iw_add_segments(IndexWriter *iw, IndexReader *ir)
{
    if (ir->num_docs == sr_num_docs) {
        iw_add_segment(iw, SR(ir));
    }
    else {
        int i;
        const int r_cnt = MR(ir)->r_cnt;
        IndexReader **readers = MR(ir)->sub_readers;
        for (i = 0; i < r_cnt; i++) {
            iw_add_segments(iw, readers[i]);
        }
    }
}

void iw_add_readers(IndexWriter *iw, IndexReader **readers, const int r_cnt)
{
    int i;
    Lock *commit_lock;

    mutex_lock(&iw->mutex);
    iw_optimize_i(iw);

    for (i = 0; i < r_cnt; i++) {
        iw_add_segments(iw, readers[i]);
    }

    mutex_lock(&iw->store->mutex);
    commit_lock = open_lock(iw->store, COMMIT_LOCK_NAME);

    if (!commit_lock->obtain(commit_lock)) {
        RAISE(LOCK_ERROR, "Couldn't obtain commit lock to write segments file");
    }
    /* commit the segments file and the fields file */
    fis_write(iw->fis, iw->store);
    sis_write(iw->sis, iw->store);
    commit_lock->release(commit_lock);
    close_lock(commit_lock);
    mutex_unlock(&iw->store->mutex);

    iw_optimize_i(iw);
    mutex_unlock(&iw->mutex);
}
