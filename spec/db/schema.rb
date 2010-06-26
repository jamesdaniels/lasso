ActiveRecord::Schema.define(:version => 1) do
  create_table :simple_oauths, :force => true do |t|
    t.string   "token_a", "token_b", :limit => 999
    t.string   "service", "type", :null => false
    t.string   "owner_type"
    t.integer  "owner_id"
    t.datetime "created_at", "updated_at", :null => false
  end
  create_table :users, :force => true do |t|
    t.string 'login', 'password'
  end
end