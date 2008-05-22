# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20080522013302) do

  create_table "haiku_favorites", :force => true do |t|
    t.integer  "user_id",    :limit => 11, :null => false
    t.integer  "haiku_id",   :limit => 11, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "haiku_favorites", ["haiku_id", "user_id"], :name => "index_haiku_favorites_on_haiku_id_and_user_id", :unique => true
  add_index "haiku_favorites", ["user_id", "haiku_id", "created_at"], :name => "index_haiku_favorites_on_user_id_and_haiku_id_and_created_at"
  add_index "haiku_favorites", ["created_at", "haiku_id"], :name => "index_haiku_favorites_on_created_at_and_haiku_id"

  create_table "haikus", :force => true do |t|
    t.integer  "twitter_status_id",     :limit => 11,                :null => false
    t.integer  "user_id",               :limit => 11,                :null => false
    t.integer  "favorited_count_week",  :limit => 11, :default => 0, :null => false
    t.integer  "favorited_count_month", :limit => 11, :default => 0, :null => false
    t.integer  "favorited_count_total", :limit => 11, :default => 0, :null => false
    t.integer  "view_count_week",       :limit => 11, :default => 0, :null => false
    t.integer  "view_count_month",      :limit => 11, :default => 0, :null => false
    t.integer  "view_count_total",      :limit => 11, :default => 0, :null => false
    t.text     "text",                                               :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "haikus", ["user_id"], :name => "index_haikus_on_user_id"
  add_index "haikus", ["favorited_count_week"], :name => "index_haikus_on_favorited_count_week"
  add_index "haikus", ["favorited_count_month"], :name => "index_haikus_on_favorited_count_month"
  add_index "haikus", ["favorited_count_total"], :name => "index_haikus_on_favorited_count_total"
  add_index "haikus", ["view_count_week"], :name => "index_haikus_on_view_count_week"
  add_index "haikus", ["view_count_month"], :name => "index_haikus_on_view_count_month"
  add_index "haikus", ["view_count_total"], :name => "index_haikus_on_view_count_total"

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

  create_table "users", :force => true do |t|
    t.string   "username",                                     :null => false
    t.string   "password",                                     :null => false
    t.integer  "haikus_count",    :limit => 11, :default => 0, :null => false
    t.integer  "favorites_count", :limit => 11, :default => 0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["username"], :name => "index_users_on_username"

end
