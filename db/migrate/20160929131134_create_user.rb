class CreateUser < ActiveRecord::Migration
  def change
   create_table :users do |t|
     t.string :name
     t.string :slackid
     t.string :username
     t.timestamps null: false
   end
  end
end
