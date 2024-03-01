class AddTelefonoToBusiness < ActiveRecord::Migration[7.1]
  def change
    add_column :businesses, :telefono, :integer
  end
end
