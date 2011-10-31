class CreateCriteria < ActiveRecord::Migration
  def self.up
    create_table :criteria do |t|
      t.string :type, :null => false
      t.string :model, :null => true
      t.string :property, :null => true
      t.integer :parent_id, :null => true
      t.boolean :negative, :null => false, :default => false
      t.integer :integer_a
      t.integer :integer_b
      t.timestamps
    end
  end

  def self.down
    drop_table :criteria
  end
end
