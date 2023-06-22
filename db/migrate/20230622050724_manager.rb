class Manager < ActiveRecord::Migration[7.0]
  def change
  create_table :articles do |t|
    t.string :name
    t.string :email
    t.string :phoneNumber
    t.string :employee_id
  end
  end
end
