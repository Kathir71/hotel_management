class CreateRatingsTable < ActiveRecord::Migration[7.0]
  def change
    create_table :ratings do |t|
        t.references :booking , foreign_key:true
        t.integer :rating
      t.timestamps
    end
  end
end
