class CreateBusinesses < ActiveRecord::Migration[7.1]
  def change
    create_table :businesses do |t|
      t.string :nombre
      t.string :correo_electronico
      t.string :ciudad
      t.string :servicios

      t.timestamps
    end
  end
end
