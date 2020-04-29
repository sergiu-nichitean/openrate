# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_04_29_134904) do

  create_table "broadcasts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "message_id"
    t.integer "status"
    t.datetime "send_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["message_id"], name: "index_broadcasts_on_message_id"
    t.index ["user_id"], name: "index_broadcasts_on_user_id"
  end

  create_table "custom_fields", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_custom_fields_on_user_id"
  end

  create_table "filters", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.bigint "broadcast_id", null: false
    t.string "type"
    t.string "operator"
    t.string "value"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["broadcast_id"], name: "index_filters_on_broadcast_id"
  end

  create_table "messages", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.text "subject"
    t.text "content"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "from"
    t.integer "audience_size", default: 0
    t.integer "opens", default: 0
    t.integer "clicks", default: 0
    t.integer "unsubscribes", default: 0
    t.integer "emails_sent", default: 0
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "sent_messages", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "message_id"
    t.bigint "subscriber_id"
    t.integer "status"
    t.text "error"
    t.datetime "sent_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["message_id"], name: "index_sent_messages_on_message_id"
    t.index ["subscriber_id"], name: "index_sent_messages_on_subscriber_id"
  end

  create_table "sequence_messages", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "message_id"
    t.bigint "sequence_id"
    t.integer "order"
    t.integer "delay"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["message_id"], name: "index_sequence_messages_on_message_id"
    t.index ["sequence_id"], name: "index_sequence_messages_on_sequence_id"
  end

  create_table "sequence_subscribers", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "sequence_id"
    t.bigint "subscriber_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sequence_id"], name: "index_sequence_subscribers_on_sequence_id"
    t.index ["subscriber_id"], name: "index_sequence_subscribers_on_subscriber_id"
  end

  create_table "sequences", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sequences_on_user_id"
  end

  create_table "subscriber_custom_fields", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "subscriber_id"
    t.bigint "custom_field_id"
    t.text "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["custom_field_id"], name: "index_subscriber_custom_fields_on_custom_field_id"
    t.index ["subscriber_id"], name: "index_subscriber_custom_fields_on_subscriber_id"
  end

  create_table "subscriber_imports", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.bigint "user_id"
    t.string "file_path"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.json "error_messages"
    t.integer "status"
    t.index ["user_id"], name: "index_subscriber_imports_on_user_id"
  end

  create_table "subscribers", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "unsubscribe_token"
    t.index ["user_id"], name: "index_subscribers_on_user_id"
  end

  create_table "subscribers_tags", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.bigint "subscriber_id"
    t.bigint "tag_id"
    t.index ["subscriber_id"], name: "index_subscribers_tags_on_subscriber_id"
    t.index ["tag_id"], name: "index_subscribers_tags_on_tag_id"
  end

  create_table "tags", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_tags_on_user_id"
  end

  create_table "users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "smtp_address"
    t.integer "smtp_port"
    t.string "smtp_user_name"
    t.string "smtp_password"
    t.boolean "use_zapier"
    t.string "api_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "default_from"
    t.string "company_name"
    t.text "email_footer"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "broadcasts", "messages"
  add_foreign_key "broadcasts", "users"
  add_foreign_key "custom_fields", "users"
  add_foreign_key "filters", "broadcasts"
  add_foreign_key "messages", "users"
  add_foreign_key "sent_messages", "messages"
  add_foreign_key "sent_messages", "subscribers"
  add_foreign_key "sequence_messages", "messages"
  add_foreign_key "sequence_messages", "sequences"
  add_foreign_key "sequence_subscribers", "sequences"
  add_foreign_key "sequence_subscribers", "subscribers"
  add_foreign_key "sequences", "users"
  add_foreign_key "subscriber_custom_fields", "custom_fields"
  add_foreign_key "subscriber_custom_fields", "subscribers"
  add_foreign_key "subscribers", "users"
  add_foreign_key "tags", "users"
end
