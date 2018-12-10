class AddPointingWorkTimeToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :pointing_work_time, :datetime
    add_column :users, :basic_work_time, :datetime
  end
end
