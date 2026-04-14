class CreateResolutionTypes < ActiveRecord::Migration[8.1]
  def change
    create_table :resolution_types do |t|
      t.string  :name, null: false
      t.integer :position, null: false, default: 0
      t.boolean :active, null: false, default: true
      t.timestamps
    end
    add_index :resolution_types, "LOWER(name)", unique: true
  end
end
