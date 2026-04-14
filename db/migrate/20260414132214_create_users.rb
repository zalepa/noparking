class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :email
      t.string :phone
      t.string :password_digest, null: false

      t.timestamps
    end

    add_index :users, :email, unique: true, where: "email IS NOT NULL"
    add_index :users, :phone, unique: true, where: "phone IS NOT NULL"
  end
end
