class UsersController < ApplicationController
  
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy,
                                        :following, :followers]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: :destroy
  
  def basic_info
    @user = User.find(current_user.id)
  end
  
  def ba_info_edit
    @user = User.find(current_user.id)
    if @user.update_attributes(user_params)
      # 更新に成功した場合を扱う。
      flash[:success] = "基本情報を修正しました"
      redirect_to @user
    else
      render 'edit'
    end
  end

  def work
    if params[:flag] == "arrival_flag" #出勤ボタンを押下
          savetime = Time.new(Time.current.year,Time.current.month,Time.current.day,Time.current.hour,Time.current.min,00)
          date = Date.current
          # byebug
          if Attendance.find_by(attendance_date: date, user_id: params[:id]) == nil
            save = Attendance.new(user_id: params[:id], arrival: savetime, attendance_date: date)
            save.save
          else
            save = Attendance.find_by(attendance_date: date, user_id: params[:id])
            save.update(arrival: savetime)
          end
        flash[:success] = '今日も１日頑張りましょう。'
        params[:flag] = "" #フラグが内部保持されてしまうのでリセット → リセットしないと画面更新すると出勤イベントが反応してしまう為
    end
      
      if params[:flag] == "departure_flag" #退勤ボタンを押下
        savetime = Time.new(Time.current.year,Time.current.month,Time.current.day,Time.current.hour,Time.current.min,00)
        date = Date.current
        save = Attendance.find_by(attendance_date: date, user_id: params[:id])
        if save.present?
          save.update(departure: savetime)
          params[:flag] == "" #フラグが内部保持されてしまうのでリセット → リセットしないと画面更新すると退勤イベントが反応してしまう為
        end
      flash[:success] = '今日も１日お疲れ様でした。'
      end
    redirect_to '/users/show'
  end
  
  def attend_update
    @user = User.find_by(id: params[:id])
    error_count = 0
    message = ""
    
    works_params.each do |id, item|
          attendance = Attendance.find(current_user.id)
          
          #出社時間と退社時間の両方の存在を確認
          if item["arrival"].blank? && item["departure"].blank?
            message = '一部編集が無効となった項目があります。'
            
            # 当日以降の編集はadminユーザのみ
          elsif attendance.attendance_date > Date.current && !current_user.admin?
            message = '明日以降の勤怠編集は出来ません。'
            error_count += 1
          
          #出社時間 > 退社時間ではないか
          elsif item["arrival"].to_s > item["departure"].to_s
            message = '出社時間より退社時間が早い項目がありました'
            error_count += 1
          end
    end #eachの締め
    
    if error_count > 0
      flash[:warning] = message
    else
      works_params.each do |id, item|
          attendance = Attendance.find(id)
          
          # 当日以降の編集はadminユーザのみ
          if item["arrival"].blank? && item["departure"].blank?
          
          else
            attendance.update_attributes(item)
            flash[:success] = '勤怠時間を更新しました。'
          end
      end #eachの締め
    end
    redirect_to("/users/attend_edit")
  end
  
  def attend_edit
    @user = User.find(current_user.id)
    # @attendance = Attendance.find_by(user_id: @user.id)
    @y_m_d = Date.current
    @youbi = %w[日 月 火 水 木 金 土]    

    @first_day = params[:first_day].to_date
    # ▼月末(30or31日, 23:59:59)を取得します
    @last_day = @first_day.end_of_month
    @to = DateTime.current.next_month.beginning_of_month
  end
  
  def index
    @users = User.all.paginate(page: params[:page])
  end
  
  def show
  @user = User.find_by(id: params[:id])
  if @user == nil
    @user = User.find(current_user.id)
  end
  @y_m_d = Date.current
  @youbi = %w[日 月 火 水 木 金 土]
    
    if params[:piyo] == nil
       # params[:piyo]が存在しない(つまりデフォルト時)
       # ▼月初(今月の1日, 00:00:00)を取得します
       @first_day = Date.new(Date.today.year, Date.today.month)
    else
       # ▼params[:piyo]が存在する(つまり切り替えボタン押下時)
       #  paramsの中身は"文字列"で送られてくるので注意
       #  文字列を時間の型に直すときはparseメソッドを使うか、
      # @first_day = Time.parse(params[:piyo])
       #  もしくはto_datetimeメソッドとかで型を変えてあげるといいと思います
       @first_day = params[:piyo].to_date
    end
  # ▼月末(30or31日, 23:59:59)を取得します
  @last_day = @first_day.end_of_month
  #byebug
  # 次月の初日未満（初日は含まない）
  # https://h3poteto.hatenablog.com/entry/2013/12/08/140934
  # @to = Date.today.next_month.beginning_of_month
  @to = Date.current.next_month.beginning_of_month
  #特定idデータにおける一ヶ月分（必要な分だけのデータ）の出退勤情報を抽出　←　全部の勤怠データを渡してしまうと時間経過とともにデータが肥大化してしまうから。
  @attendance = Attendance.where(created_at: @first_day...@to, user_id: @user.id)
  # @attendance = @attendance.find_by(user_id: @user.id)
    (@first_day..@last_day).each do |temp_day|
      comparison_date = Date.new(Date.current.year,Date.current.month,temp_day.day)
    	if Attendance.find_by(attendance_date: comparison_date, user_id: @user.id).nil?
    		work = Attendance.new(attendance_date: comparison_date, user_id: @user.id)
    		work.save
    	end
  	end
  	
	@PWK = @user.pointing_work_time.strftime("%H : %M") if @user.pointing_work_time.present?
<<<<<<<<< saved version
    (@first_day..@last_day).each do |temp_day|
      comparison_date = Date.new(Date.current.year,Date.current.month,temp_day.day)
    	if Attendance.find_by(attendance_date: comparison_date, user_id: @user.id).nil?
    		work = Attendance.new(attendance_date: comparison_date, user_id: @user.id)
    		work.save
    	end
  	end
  	
	@PWK = @user.pointing_work_time.strftime("%H : %M") if @user.pointing_work_time.present?
	@Btime = @user.basic_work_time.strftime("%H : %M") if @user.basic_work_time.present?  	
=========
  # @attendance = @attendance.find_by(user_id: @user.id)
    (@first_day..@last_day).each do |temp_day|
      comparison_date = Date.new(Date.current.year,Date.current.month,temp_day.day)
    	if Attendance.find_by(attendance_date: comparison_date, user_id: @user.id).nil?
    		work = Attendance.new(attendance_date: comparison_date, user_id: @user.id)
    		work.save
    	end
  	end
  	
	@PWK = @user.pointing_work_time.strftime("%H : %M") if @user.pointing_work_time.present?
<<<<<<<<< saved version
    @days.each do |d|
      if d.arrival.present? && d.departure.present?
        second = 0
        second = times(d.arrival,d.departure)
        @total_time = @total_time.to_i + second.to_i
        i = i + 1
      end
    end
  end
    
  #出勤日数表示
  @attendance_sum = @days.where.not(arrival: nil, departure: nil).count
=========
	@Btime = @user.basic_work_time.strftime("%H : %M") if @user.basic_work_time.present?  	
=========
	@PWK = @user.pointing_work_time.strftime("%H : %M") if @user.pointing_work_time.present?
	@Btime = @user.basic_work_time.strftime("%H : %M") if @user.basic_work_time.present? 
	
  # 当月を昇順で取得し@daysへ代入
  @days = @user.attendances.where('attendance_date >= ? and attendance_date <= ?', @first_day, @last_day).order('attendance_date')
  
  if @days.present?
    @total_time = 0
  else
    i = 0
    @days.each do |d|
      if d.arrival.present? && d.departure.present?
        second = 0
        second = times(d.arrival,d.departure)
        @total_time = @total_time.to_i + second.to_i
        i = i + 1
      end
    end
  end
    
  #出勤日数表示
  @attendance_sum = @days.where.not(arrival: nil, departure: nil).count
>>>>>>>>> local version
>>>>>>>>> local version
>>>>>>>>> local version
  end
  
  def new
    @user = User.new
  end


   def create
    @user = User.new(user_params)
    # debugger
    if @user.save
    #   @user.send_activation_email
    #   flash[:info] = "入力したアドレスに��ールを送信しました。アカウントを有効にしてください"
      # render '/layouts/_header'
      redirect_to user_url(@user)
    else
      render 'new'
    end
   end

  def edit
    @user = User.find(params[:id])
      if @user == nil
        @user = User.find(current_user.id)
      end
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = "プロフィールが更新されました"
      redirect_to @user
    else
      render 'edit'
    end
  end
  
  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "ユーザーを削除しました"
    redirect_to users_url
  end
  
  def following
    @title = "フォロー"
    @user  = User.find(params[:id])
    @users = @user.following.paginate(page: params[:page])
    render 'show_follow'
  end

  def followers
    @title = "フォロワー"
    @user  = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow'
  end
  
  private
  # 　def users_basic_params
  # 　 # params.permit(users: [:pointing_work_time, :basic_work_time])[:users]
  # 　 params.require(:user).permit(:pointing_work_time, :basic_work_time)
  # 　end
  
    def works_params
       params.permit(attendances: [:arrival, :departure])[:attendances]
    end

    def user_params
      params.require(:user).permit(:name, :email, :password, :affiliation,
                                   :password_confirmation, :pointing_work_time, :basic_work_time)
    end
    
    # beforeアクション
    
    # 正しいユーザーかどうか確認
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end
    
    # 管理者かどうか確認
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
end
