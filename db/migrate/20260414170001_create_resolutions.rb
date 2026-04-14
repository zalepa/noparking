class CreateResolutions < ActiveRecord::Migration[8.1]
  def change
    create_table :resolutions do |t|
      t.references :issue, null: false, foreign_key: true, index: { unique: true }
      t.references :resolution_type, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text   :note
      t.string :citation_number
      t.timestamps
    end
  end
end
