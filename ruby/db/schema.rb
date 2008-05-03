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

ActiveRecord::Schema.define(:version => 3) do

  create_table "haiku_favorites", :id => false, :force => true do |t|
    t.integer  "user_id",    :limit => 11, :null => false
    t.integer  "haiku_id",   :limit => 11, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "haiku_favorites", ["user_id", "haiku_id"], :name => "index_haiku_favorites_on_user_id_and_haiku_id", :unique => true
  add_index "haiku_favorites", ["haiku_id", "user_id", "created_at"], :name => "index_haiku_favorites_on_haiku_id_and_user_id_and_created_at"
  add_index "haiku_favorites", ["created_at", "haiku_id"], :name => "index_haiku_favorites_on_created_at_and_haiku_id"

  create_table "haikus", :force => true do |t|
    t.string   "text",                  :limit => 765,                :null => false
    t.integer  "user_id",               :limit => 11,  :default => 0, :null => false
    t.integer  "haiku_favorites_count", :limit => 11,  :default => 0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "haikus", ["user_id"], :name => "index_haikus_on_user_id"
  add_index "haikus", ["created_at"], :name => "index_haikus_on_created_at"

end
