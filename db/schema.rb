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

ActiveRecord::Schema.define(:version => 20130330112821) do

  create_table "comments", :force => true do |t|
    t.integer  "author_id",        :null => false
    t.text     "content",          :null => false
    t.integer  "commentable_id",   :null => false
    t.string   "commentable_type", :null => false
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "games", :force => true do |t|
    t.integer  "reported_by_id",                            :null => false
    t.string   "kind"
    t.string   "version"
    t.string   "title",          :default => "Ladder Game", :null => false
    t.string   "era"
    t.string   "map"
    t.integer  "turns"
    t.text     "chat"
    t.string   "replay"
    t.integer  "downloads",      :default => 0,             :null => false
    t.boolean  "parsed",         :default => false,         :null => false
    t.boolean  "revoked",        :default => false,         :null => false
    t.integer  "revoked_by_id"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
  end

  create_table "issues", :force => true do |t|
    t.integer  "user_id",       :null => false
    t.integer  "issuable_id",   :null => false
    t.string   "issuable_type", :null => false
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "news", :force => true do |t|
    t.string   "title",      :null => false
    t.text     "body",       :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "pages", :force => true do |t|
    t.string   "title",                         :null => false
    t.text     "body",                          :null => false
    t.boolean  "menu",       :default => false, :null => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  create_table "sides", :force => true do |t|
    t.integer  "game_id",                 :null => false
    t.integer  "player_id",               :null => false
    t.float    "score",                   :null => false
    t.float    "rating",                  :null => false
    t.float    "rating_before",           :null => false
    t.float    "rating_deviation",        :null => false
    t.float    "rating_deviation_before", :null => false
    t.float    "volatility",              :null => false
    t.float    "volatility_before",       :null => false
    t.string   "kind"
    t.integer  "number"
    t.string   "color"
    t.string   "team"
    t.string   "faction"
    t.string   "leader"
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  add_index "sides", ["game_id"], :name => "index_sides_on_game_id"
  add_index "sides", ["player_id"], :name => "index_sides_on_player_id"

  create_table "users", :force => true do |t|
    t.string   "nick",                                                :null => false
    t.string   "kind",                     :default => "Competitive", :null => false
    t.string   "country"
    t.string   "time_zone"
    t.text     "notifications"
    t.float    "initial_rating",           :default => 1500.0,        :null => false
    t.float    "rating",                   :default => 1500.0,        :null => false
    t.float    "initial_rating_deviation", :default => 350.0,         :null => false
    t.float    "rating_deviation",         :default => 350.0,         :null => false
    t.float    "volatility",               :default => 0.06,          :null => false
    t.boolean  "admin",                    :default => false,         :null => false
    t.boolean  "banned",                   :default => false,         :null => false
    t.string   "email",                    :default => "",            :null => false
    t.string   "encrypted_password",       :default => "",            :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",            :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                          :null => false
    t.datetime "updated_at",                                          :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["nick"], :name => "index_users_on_nick"
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
