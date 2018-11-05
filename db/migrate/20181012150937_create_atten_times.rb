class CreateAttenTimes < ActiveRecord::Migration[5.1]
  def change
    create_table :atten_times do |t|
      t.time :arrival_time
      t.time :departure_time
      t.integer :user_id
      
      t.timestamps
    end
  end
end
