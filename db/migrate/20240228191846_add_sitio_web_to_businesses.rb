class AddSitioWebToBusinesses < ActiveRecord::Migration[7.1]
  def change
    add_column :businesses, :sitio_web, :string 
  end
end
