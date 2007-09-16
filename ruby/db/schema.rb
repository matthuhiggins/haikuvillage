# This file is autogenerated. Instead of editing this file, please use the
# migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.

ActiveRecord::Schema.define(:version => 3) do

  create_table "group_haikus", :id => false, :force => true do |t|
    t.integer  "group_id",   :null => false
    t.integer  "haiku_id",   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "group_haikus", ["group_id", "haiku_id"], :name => "index_group_haikus_on_group_id_and_haiku_id", :unique => true
  add_index "group_haikus", ["haiku_id", "group_id"], :name => "index_group_haikus_on_haiku_id_and_group_id"

  create_table "group_users", :id => false, :force => true do |t|
    t.integer "group_id",                  :null => false
    t.integer "user_id",                   :null => false
    t.string  "user_type", :default => "", :null => false
  end

  add_index "group_users", ["group_id", "user_id"], :name => "index_group_users_on_group_id_and_user_id", :unique => true
  add_index "group_users", ["user_id", "group_id"], :name => "index_group_users_on_user_id_and_group_id"

  create_table "groups", :force => true do |t|
    t.string   "name",        :limit => 100,  :default => "", :null => false
    t.string   "description", :limit => 1000, :default => "", :null => false
    t.boolean  "isadultonly",                                 :null => false
    t.boolean  "isprivate",                                   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "groups", ["name"], :name => "index_groups_on_name", :unique => true
  add_index "groups", ["created_at"], :name => "index_groups_on_created_at"

  create_table "haiku_comments", :force => true do |t|
    t.integer  "haiku_id",                                   :null => false
    t.integer  "user_id",                                    :null => false
    t.string   "text",       :limit => 1000, :default => "", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "haiku_comments", ["haiku_id", "created_at"], :name => "index_haiku_comments_on_haiku_id_and_created_at"
  add_index "haiku_comments", ["user_id", "created_at"], :name => "index_haiku_comments_on_user_id_and_created_at"

  create_table "haiku_favorites", :id => false, :force => true do |t|
    t.integer  "user_id",    :null => false
    t.integer  "haiku_id",   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "haiku_favorites", ["user_id", "haiku_id"], :name => "index_haiku_favorites_on_user_id_and_haiku_id", :unique => true
  add_index "haiku_favorites", ["haiku_id", "user_id", "created_at"], :name => "index_haiku_favorites_on_haiku_id_and_user_id_and_created_at"
  add_index "haiku_favorites", ["created_at", "haiku_id"], :name => "index_haiku_favorites_on_created_at_and_haiku_id"

  create_table "haiku_tags", :id => false, :force => true do |t|
    t.integer  "haiku_id",   :null => false
    t.integer  "tag_id",     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "haiku_tags", ["tag_id", "haiku_id"], :name => "index_haiku_tags_on_tag_id_and_haiku_id", :unique => true
  add_index "haiku_tags", ["haiku_id", "tag_id"], :name => "index_haiku_tags_on_haiku_id_and_tag_id"
  add_index "haiku_tags", ["created_at", "tag_id"], :name => "index_haiku_tags_on_created_at_and_tag_id"

  create_table "haikus", :force => true do |t|
    t.string   "text",                  :limit => 765, :default => "", :null => false
    t.integer  "user_id",                              :default => 0,  :null => false
    t.integer  "haiku_favorites_count",                :default => 0,  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "haikus", ["user_id"], :name => "index_haikus_on_user_id"
  add_index "haikus", ["created_at"], :name => "index_haikus_on_created_at"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :default => "", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "tags", :force => true do |t|
    t.string   "name",             :limit => 64, :default => "", :null => false
    t.integer  "haiku_tags_count",               :default => 0,  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tags", ["name"], :name => "index_tags_on_name", :unique => true
  add_index "tags", ["haiku_tags_count"], :name => "index_tags_on_haiku_tags_count"
  add_index "tags", ["created_at"], :name => "index_tags_on_created_at"

  create_table "user_logins", :id => false, :force => true do |t|
    t.integer  "user_id",   :null => false
    t.datetime "logindate", :null => false
  end

  add_index "user_logins", ["user_id"], :name => "user_logins_user_id_foreign_key"

  create_table "user_users", :id => false, :force => true do |t|
    t.integer "sourceuser_id", :null => false
    t.integer "targetuser_id", :null => false
    t.boolean "accepted",      :null => false
  end

  add_index "user_users", ["sourceuser_id"], :name => "user_users_sourceuser_id_foreign_key"
  add_index "user_users", ["targetuser_id"], :name => "user_users_targetuser_id_foreign_key"

  create_table "users", :force => true do |t|
    t.string   "alias",           :limit => 100, :default => "", :null => false
    t.string   "email",           :limit => 100, :default => "", :null => false
    t.string   "hashed_password", :limit => 100, :default => "", :null => false
    t.string   "salt",            :limit => 100, :default => "", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true

end
