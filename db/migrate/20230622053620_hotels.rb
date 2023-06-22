class Hotels < ActiveRecord::Migration[7.0]
  def change
    create_table :hotels do |t|
      t.string :name
      t.string :address
      t.string :description
      t.references :managers , foreign_key: true
    end
  end
end