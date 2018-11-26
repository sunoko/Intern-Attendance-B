class AddDateToAttendance < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :attendance_date, :date
  end
end
