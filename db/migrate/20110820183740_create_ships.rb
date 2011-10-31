class CreateShips < ActiveRecord::Migration
  def self.up
    create_table :ships do |t|
      t.integer :dwt
      t.integer :built_year

      t.timestamps
    end
  end

  def self.down
    drop_table :ships
  end
end
