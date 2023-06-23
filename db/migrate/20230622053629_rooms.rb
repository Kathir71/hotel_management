class Rooms < ActiveRecord::Migration[7.0]
  def change
    create_table :rooms do |t|
      t.references :hotel , foreign_key:true 
      t.string :roomType
      t.float :cost
      t.integer :totalAvailable
    end
  end
end
