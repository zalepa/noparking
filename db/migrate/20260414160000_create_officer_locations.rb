class CreateOfficerLocations < ActiveRecord::Migration[8.1]
  def change
    create_table :officer_locations do |t|
      t.references :user, null: false, foreign_key: true
      t.decimal :latitude,  precision: 10, scale: 6, null: false
      t.decimal :longitude, precision: 10, scale: 6, null: false
      t.float   :accuracy_meters
      t.datetime :recorded_at, null: false
      t.datetime :created_at,  null: false
    end
    add_index :officer_locations, [ :user_id, :recorded_at ]
  end
end
