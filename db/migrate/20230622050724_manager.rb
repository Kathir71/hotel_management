class Manager < ActiveRecord::Migration[7.0]
  def change
  create_table :managers do |t|
    t.string :name
    t.string :email
    t.string :phoneNumber
    t.string :password_digest
    t.string :employee_id
  end
  end
end
