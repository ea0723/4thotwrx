class ChangeCreditsFromFloatToString < ActiveRecord::Migration
  def change
    change_column( :conversions, :credits, :string )
  end
  
  def revert
    irreversable_migration
  end
  
end
