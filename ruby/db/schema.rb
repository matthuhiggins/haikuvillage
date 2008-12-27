# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20081227191755) do

  create_table "authors", :force => true do |t|
    t.string   "username",                                 :null => false
    t.string   "password",                                 :null => false
    t.integer  "haikus_count_week",     :default => 0,     :null => false
    t.integer  "haikus_count_total",    :default => 0,     :null => false
    t.integer  "favorites_count",       :default => 0,     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email",                 :default => "",    :null => false
    t.integer  "favorited_count_total", :default => 0,     :null => false
    t.integer  "favorited_count_week",  :default => 0,     :null => false
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.string   "twitter_username"
    t.string   "twitter_password"
    t.boolean  "twitter_enabled",       :default => false, :null => false
  end

  add_index "authors", ["haikus_count_total"], :name => "index_authors_on_haikus_count_total"
  add_index "authors", ["haikus_count_week"], :name => "index_authors_on_haikus_count_week"
  add_index "authors", ["username"], :name => "index_authors_on_username"

  create_table "conversations", :force => true do |t|
    t.integer  "haikus_count_week",  :default => 0, :null => false
    t.integer  "haikus_count_total", :default => 0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "inspiration_type"
  end

  add_index "conversations", ["haikus_count_total"], :name => "index_conversations_on_haikus_count_total"
  add_index "conversations", ["haikus_count_week"], :name => "index_conversations_on_haikus_count_week"
  add_index "conversations", ["inspiration_type"], :name => "index_conversations_on_inspiration_type"

  create_table "flickr_inspirations", :force => true do |t|
    t.string   "title",                        :null => false
    t.integer  "conversation_id",              :null => false
    t.integer  "photo_id",        :limit => 8, :null => false
    t.integer  "farm_id",                      :null => false
    t.integer  "server_id",                    :null => false
    t.string   "secret",                       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "flickr_inspirations", ["conversation_id"], :name => "flickr_inspirations_conversation_id_fk"
  add_index "flickr_inspirations", ["created_at"], :name => "index_flickr_inspirations_on_created_at"
  add_index "flickr_inspirations", ["photo_id"], :name => "index_flickr_inspirations_on_photo_id", :unique => true

  create_table "haiku_favorites", :force => true do |t|
    t.integer  "author_id",  :null => false
    t.integer  "haiku_id",   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "haiku_favorites", ["author_id", "haiku_id", "created_at"], :name => "index_haiku_favorites_on_author_id_and_haiku_id_and_created_at"
  add_index "haiku_favorites", ["created_at", "haiku_id"], :name => "index_haiku_favorites_on_created_at_and_haiku_id"
  add_index "haiku_favorites", ["haiku_id", "author_id"], :name => "index_haiku_favorites_on_haiku_id_and_author_id", :unique => true

  create_table "haikus", :force => true do |t|
    t.integer  "author_id",                            :null => false
    t.integer  "favorited_count_week",  :default => 0, :null => false
    t.integer  "favorited_count_total", :default => 0, :null => false
    t.integer  "view_count_week",       :default => 0, :null => false
    t.integer  "view_count_total",      :default => 0, :null => false
    t.text     "text",                                 :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "subject_name"
    t.integer  "subject_id"
    t.integer  "conversation_id"
  end

  add_index "haikus", ["author_id"], :name => "index_haikus_on_author_id"
  add_index "haikus", ["conversation_id"], :name => "haikus_conversation_id_fk"
  add_index "haikus", ["favorited_count_total"], :name => "index_haikus_on_favorited_count_total"
  add_index "haikus", ["favorited_count_week"], :name => "index_haikus_on_favorited_count_week"
  add_index "haikus", ["subject_id", "created_at"], :name => "index_haikus_on_subject_id_and_created_at"
  add_index "haikus", ["view_count_total"], :name => "index_haikus_on_view_count_total"
  add_index "haikus", ["view_count_week"], :name => "index_haikus_on_view_count_week"

  create_table "logged_exceptions", :force => true do |t|
    t.string   "exception_class"
    t.string   "controller_name"
    t.string   "action_name"
    t.text     "message"
    t.text     "backtrace"
    t.text     "environment"
    t.text     "request"
    t.datetime "created_at"
  end

  create_table "subjects", :force => true do |t|
    t.string   "name",                              :null => false
    t.integer  "haikus_count_week",  :default => 0, :null => false
    t.integer  "haikus_count_total", :default => 0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "subjects", ["created_at"], :name => "index_subjects_on_created_at"
  add_index "subjects", ["haikus_count_total"], :name => "index_subjects_on_haikus_count_total"
  add_index "subjects", ["haikus_count_week"], :name => "index_subjects_on_haikus_count_week"
  add_index "subjects", ["name"], :name => "index_subjects_on_name", :unique => true

end
