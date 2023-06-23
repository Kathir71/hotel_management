class Bookings < ActiveRecord::Migration[7.0]
  def change
    create_table :bookings do |t|
      t.references :user , foreign_key: true
      t.references :hotel , foreign_key: true
      t.references :room , foreign_key: true
      t.string :roomType 
      t.integer :numRoomsBooked
      t.float :price
      t.date :checkInDate
      t.date :checkOutDate
      t.boolean :isCancelled
    end
  end
end
