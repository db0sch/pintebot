class CreateReply < ActiveRecord::Migration
  def change
    create_table :replies do |t|
      t.string :text
      t.string :foursquare_result
      t.string :name
      t.string :address
      t.string :distance
      t.references :query, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
