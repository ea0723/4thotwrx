class CreateConversions < ActiveRecord::Migration
  def change
    create_table :conversions do |t|
      t.string :convert_me
      t.float :credits

      t.timestamps
    end
  end
end
