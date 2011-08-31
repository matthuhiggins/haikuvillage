# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100929162652) do

  create_table "authors", :force => true do |t|
    t.string   "email",                                             :null => false
    t.string   "username",                                          :null => false
    t.string   "hashed_password"
    t.string   "salt"
    t.string   "remember_token"
    t.integer  "haikus_count_week",                  :default => 0, :null => false
    t.integer  "haikus_count_total",                 :default => 0, :null => false
    t.integer  "favorited_count_total",              :default => 0, :null => false
    t.integer  "favorited_count_week",               :default => 0, :null => false
    t.integer  "favorites_count",                    :default => 0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "latest_haiku_id"
    t.integer  "fb_uid",                :limit => 8
  end

  add_index "authors", ["email"], :name => "index_authors_on_email", :unique => true
  add_index "authors", ["fb_uid"], :name => "index_authors_on_fb_uid", :unique => true
  add_index "authors", ["haikus_count_week"], :name => "index_authors_on_haikus_count_week"
  add_index "authors", ["latest_haiku_id"], :name => "authors_latest_haiku_id_fk"
  add_index "authors", ["username"], :name => "index_authors_on_username", :unique => true

  create_table "conversations", :force => true do |t|
    t.integer  "haikus_count_total",  :default => 0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "inspiration_type"
    t.datetime "latest_haiku_update"
  end

  add_index "conversations", ["haikus_count_total"], :name => "index_conversations_on_haikus_count_total"
  add_index "conversations", ["inspiration_type"], :name => "index_conversations_on_inspiration_type"
  add_index "conversations", ["latest_haiku_update"], :name => "index_conversations_on_latest_haiku_update"

  create_table "favorites", :force => true do |t|
    t.integer  "author_id",  :null => false
    t.integer  "haiku_id",   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "favorites", ["author_id", "haiku_id", "created_at"], :name => "index_favorites_on_author_id_and_haiku_id_and_created_at"
  add_index "favorites", ["created_at", "haiku_id"], :name => "index_favorites_on_created_at_and_haiku_id"
  add_index "favorites", ["haiku_id", "author_id"], :name => "index_favorites_on_haiku_id_and_author_id", :unique => true

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

  create_table "friendships", :force => true do |t|
    t.integer  "friend_id",  :null => false
    t.integer  "author_id",  :null => false
    t.boolean  "mutual",     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "friendships", ["author_id", "friend_id"], :name => "friendships_index", :unique => true
  add_index "friendships", ["friend_id", "author_id"], :name => "index_friendships_on_friend_id_and_author_id"

  create_table "haikus", :force => true do |t|
    t.integer  "author_id",                      :null => false
    t.text     "text",                           :null => false
    t.integer  "favorited_count", :default => 0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "subject_name"
    t.integer  "subject_id"
    t.integer  "conversation_id"
  end

  add_index "haikus", ["author_id"], :name => "haikus_author_id_fk"
  add_index "haikus", ["conversation_id"], :name => "haikus_conversation_id_fk"
  add_index "haikus", ["subject_id", "created_at"], :name => "index_haikus_on_subject_id_and_created_at"

  create_table "messages", :force => true do |t|
    t.integer  "author_id",    :null => false
    t.integer  "sender_id",    :null => false
    t.integer  "recipient_id", :null => false
    t.text     "text",         :null => false
    t.boolean  "unread",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "messages", ["author_id"], :name => "messages_author_id_fk"
  add_index "messages", ["recipient_id"], :name => "messages_recipient_id_fk"
  add_index "messages", ["sender_id"], :name => "messages_sender_id_fk"

  create_table "password_resets", :force => true do |t|
    t.string   "token",      :null => false
    t.integer  "author_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "password_resets", ["author_id"], :name => "password_resets_author_id_fk"
  add_index "password_resets", ["token"], :name => "index_password_resets_on_token", :unique => true

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

  add_foreign_key "authors", "haikus", :name => "authors_latest_haiku_id_fk", :column => "latest_haiku_id", :dependent => :nullify

  add_foreign_key "favorites", "authors", :name => "favorites_author_id_fk"
  add_foreign_key "favorites", "haikus", :name => "favorites_haiku_id_fk"

  add_foreign_key "flickr_inspirations", "conversations", :name => "flickr_inspirations_conversation_id_fk", :dependent => :delete

  add_foreign_key "friendships", "authors", :name => "friendships_author_id_fk"
  add_foreign_key "friendships", "authors", :name => "friendships_friend_id_fk", :column => "friend_id"

  add_foreign_key "haikus", "authors", :name => "haikus_author_id_fk"
  add_foreign_key "haikus", "conversations", :name => "haikus_conversation_id_fk"
  add_foreign_key "haikus", "subjects", :name => "haikus_subject_id_fk"

  add_foreign_key "messages", "authors", :name => "messages_author_id_fk"
  add_foreign_key "messages", "authors", :name => "messages_recipient_id_fk", :column => "recipient_id"
  add_foreign_key "messages", "authors", :name => "messages_sender_id_fk", :column => "sender_id"

  add_foreign_key "password_resets", "authors", :name => "password_resets_author_id_fk"

end
