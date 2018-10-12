class CreateAttenTimes < ActiveRecord::Migration[5.1]
  def change
    create_table :atten_times do |t|
      t.time :arrival_time
      t.time :departure_time

      t.timestamps
    end
  end
end
