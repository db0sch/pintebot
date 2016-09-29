class CreateQuery < ActiveRecord::Migration
  def change
    create_table :queries do |t|
      t.string :text
      t.string :timestamp
      t.string :slack_team
      t.string :slack_channel
      t.json :nlp_result
      t.json :geocode
      t.string :drink
      t.references :user, index: true, foreign_key: true
      t.timestamps null: false
  end
end
