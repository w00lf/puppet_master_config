class CreateNodes < ActiveRecord::Migration
  def self.up
    create_table :nodes do |t|
      t.string :domain
      t.string :ip
      t.string :port
    end
  end
 
  def self.down
    drop_table :nodes
  end
end