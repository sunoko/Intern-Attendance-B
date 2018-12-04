class UsersController < ApplicationController
  
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy,
                                        :following, :followers]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: :destroy
  
  def attend_update
    # works_params.each do |id, value|
    #   work = Attendance.find(id)
    #   work.update_attributes(value)
    # end
    # flash[:notice] = "勤怠時間を編集しました"
    # redirect_to("/users/attend_edit")
    # byebug
    
 
    @user = User.find_by(id: params[:id])
    error_count = 0
    message = ""
    
    works_params.each do |id, item|
          attendance = Attendance.find(id)
          # byebug
          
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
            # attendance.update_attributes(id,item)
            flash[:success] = '勤怠時間を更新しました。'
          end
      end #eachの締め
    end
    redirect_to("/users/attend_edit")
  end
  
  def attend_edit
    @user = User.find(current_user.id)
    @attendance = Attendance.find_by(user_id: @user.id)
    @y_m_d = Time.current
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
    @to = DateTime.current.next_month.beginning_of_month
    #特定idデータにおける一ヶ月分（必要な分だけのデータ）の出退勤情報を抽出　←　全部の勤怠データを渡してしまうと時間経過とともにデータが肥大化してしまうから。
    #@attendance = Attendance.where(created_at: @first_day...@to)
    
    # (@first_day..@last_day).each do |date|
    #   comparison_date = Time.new(Time.current.year,Time.current.month,temp_day)
    #   range = comparison_date.beginning_of_day..comparison_date.end_of_day
    #   #既存レコード無い場合は、Workモデル新規生成。
  		# if Attendance.find_by(attendance_date: range, user_id: current_user.id).nil?
  		# 	work = Attendance.new(attendance_date: range, userid: current_user.id)
  		# 	work.save
  		# #既存レコードある場合は、読み込み。
  		# else
  		# 	work = Attendance.find_by(attendance_date: range, userid: current_user.id)
  		# end
		# end
  end
  
  def index
    @users = User.where(activated: true).paginate(page: params[:page]).search(params[:search])
  end
  
  def show
  @user = User.find(current_user.id)
  @attendance = Attendance.find_by(user_id: @user.id)
  @y_m_d = Date.current
  @youbi = %w[日 月 火 水 木 金 土]
  
    if params[:flag] == "arrival_flag" #出勤ボタンを押下
      # start_today = Time.zone.today.beginning_of_day
      #   end_today = Time.zone.today.end_of_day      

      # @update_id = Attendance.where(arrival: start_today..end_today)
      # if @update_id[1] == nil
      # byebug
        savetime = Time.new(Time.current.year,Time.current.month,Time.current.day,Time.current.hour,Time.current.min,00)
        # byebug
        @attendance = Attendance.new(user_id: @user.id, arrival: savetime, attendance_date: savetime)
        @attendance.save
      # end
      params[:flag] = "" #フラグが内部保持されてしまうのでリセット → リセットしないと画面更新すると出勤イベントが反応してしまう為
    end
    
    if params[:flag] == "departure_flag" #退勤ボタンを押下
    #   start_today = Time.zone.today.beginning_of_day
    #     end_today = Time.zone.today.end_of_day      
    # #退勤時イベントでの上書きするAttendanceのidカラムを取得
    #   @update_id = Attendance.where(arrival: start_today...end_today)
    #   # byebug
      @attendance = Attendance.find_by(attendance_date: @y_m_d)
      if @attendance != nil
        savetime = Time.new(Time.current.year,Time.current.month,Time.current.day,Time.current.hour,Time.current.min,00)
        @attendance.update(departure: savetime)
        params[:flag] == "" #フラグが内部保持されてしまうのでリセット → リセットしないと画面更新すると退勤イベントが反応してしまう為
      end
    end
    
    if params[:piyo] == nil
       # params[:piyo]が存在しない(つまりデフォルト時)
       # ▼月初(今月の1日, 00:00:00)を取得します
       @first_day = Date.current.beginning_of_month
    else
       # ▼params[:piyo]が存在する(つまり切り替えボタン押下時)
       #  paramsの中身は"文字列"で送られてくるので注意
       #  文字列を時間の型に直すときはparseメソッドを使うか、
      # @first_day = Time.parse(params[:piyo])
       #  もしくはto_datetimeメソッドとかで型を変えてあげるといいと思います
       @first_day = params[:piyo].to_date
    end
  # ▼月末(30or31日, 23:59:59)を取得します
  @last_day = @first_day.end_of_month.day
  #byebug
  # 次月の初日未満（初日は含まない）
  # https://h3poteto.hatenablog.com/entry/2013/12/08/140934
  # @to = Date.today.next_month.beginning_of_month
  @to = Date.current.next_month.beginning_of_month
  #特定idデータにおける一ヶ月分（必要な分だけのデータ）の出退勤情報を抽出　←　全部の勤怠データを渡してしまうと時間経過とともにデータが肥大化してしまうから。
  @attendance = Attendance.where(created_at: @first_day...@to)
  
  end
  
  def new
    @user = User.new
  end


   def create
    @user = User.new(user_params)
    # debugger
    # if @user.save
    #   @user.send_activation_email
    #   flash[:info] = "入力したアドレスに��ールを送信しました。アカウントを有効にしてください"
    #   redirect_to user_url(@user)
    # else
      render 'new'
    # end
   end

  def edit
    @user = User.find(params[:id])
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
  
    def works_params
       params.permit(attendances: [:arrival, :departure])[:attendances]
        # params.require(:work).permit(attendances: [:arrival, :departure])[:attendances]      
    end

    def user_params
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation)
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
