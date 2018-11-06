class UsersController < ApplicationController
  
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy,
                                        :following, :followers]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: :destroy
  
  def index
    @users = User.where(activated: true).paginate(page: params[:page]).search(params[:search])
  end
  
  def show
    @user = User.find(params[:id])
    # 検索拡張機能として.search(params[:search])を追加    
    # @microposts = @user.microposts.paginate(page: params[:page]).search(params[:search])
    if @flag != nil 
      @atten_times = Atten_time.new(user_id: @user.id, arrival_time: Date.current)
      @atten_times.save
    end
    
    if params[:piyo] == nil
       # params[:piyo]が存在しない(つまりデフォルト時)
       # ▼月初(今月の1日, 00:00:00)を取得します
       @first_day = Time.current.beginning_of_month
    else
       # ▼params[:piyo]が存在する(つまり切り替えボタン押下時)
       #  paramsの中身は"文字列"で送られてくるので注意
       #  文字列を時間の型に直すときはparseメソッドを使うか、
      # @first_day = Time.parse(params[:piyo])
       #  もしくはto_datetimeメソッドとかで型を変えてあげるといいと思います
       @first_day = params[:piyo].to_date 
    end
      # ▼月末(30or31日, 23:59:59)を取得します
      @first_day.end_of_month
  end
  
  def new
    @user = User.new
  end


   def create
    @user = User.new(user_params)
    # debugger
    # if @user.save
    #   @user.send_activation_email
    #   flash[:info] = "入力したアドレスにメールを送信しました。アカウントを有効にしてください"
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
