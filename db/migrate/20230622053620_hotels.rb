class Hotels < ActiveRecord::Migration[7.0]
  def change
    create_table :hotels do |t|
      t.references :manager , foreign_key: true
      t.string :name
      t.string :address
      t.string :description
    end
  end
end