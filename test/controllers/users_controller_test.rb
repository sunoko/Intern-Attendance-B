class UsersControllerTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
    @other_user = users(:archer)
  end
  
  test "should redirect index when not logged in" do
    get users_path
    assert_redirected_to login_url
  end

  test "should get index" do
    log_in_as(@user) 
    get users_url
    assert_response :success
  end

  test "should get new" do
    get new_user_url
    assert_response :success
  end

  # test "should create user" do
  #   assert_difference('User.count') do
  #     post users_url, params: { user: { email: @user.email, name: @user.name } }
  #   end

  #   assert_redirected_to user_url(User.last)
  # end
  
  test "should create user" do
    assert_difference('User.count') do
      post users_url, params: { user: { email: 'another_unique@email.com', name: 'Quiz', password: 'foobar' } }
    end

  assert_redirected_to user_url(User.last)
  end

  test "should show user" do
    log_in_as(@user) 
    get user_url(@user)
    assert_response :success
  end

  test "should get edit" do
    log_in_as(@user) 
    get edit_user_url(@user)
    assert_response :success
  end

  test "should update user" do
    log_in_as(@user) 
    patch user_url(@user), params: { user: { email: @user.email, name: @user.name } }
    assert_redirected_to user_url(@user)
  end

  test "should destroy user" do
    log_in_as(@user) 
    assert_difference('User.count', -1) do
      delete user_url(@user)
    end

    assert_redirected_to users_url
  end
  
  test "should redirect edit when not logged in" do
    get edit_user_path(@user)
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect update when not logged in" do
    patch user_path(@user), params: { user: { name: @user.name,
                                              email: @user.email } }
    assert_not flash.empty?
    assert_redirected_to login_url
  end
  
  test "should redirect edit when logged in as wrong user" do
    log_in_as(@other_user)
    get edit_user_path(@user)
    assert flash.empty?
    assert_redirected_to root_url
  end

  test "should redirect update when logged in as wrong user" do
    log_in_as(@other_user)
    patch user_path(@user), params: { user: { name: @user.name,
                                              email: @user.email } }
    assert flash.empty?
    assert_redirected_to root_url
  end
  
  test "should redirect destroy when not logged in" do
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_redirected_to login_url
  end

  test "should redirect destroy when logged in as a non-admin" do
    log_in_as(@other_user)
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_redirected_to root_url
  end
  
  test "should redirect following when not logged in" do
    get following_user_path(@user)
    assert_redirected_to login_url
  end

  test "should redirect followers when not logged in" do
    get followers_user_path(@user)
    assert_redirected_to login_url
  end
end
