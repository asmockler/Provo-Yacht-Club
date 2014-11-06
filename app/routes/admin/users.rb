get '/Manager/UserManager' do
  @user = User.all
  erb :user_manager
end

post '/Manager/UserManager/make_admin/:email' do
  @user = User.first(:email => params[:email])
  @user.set(:admin => true)
end

post '/Manager/UserManager/remove_admin/:email' do
  @user = User.first(:email => params[:email])
  @user.set(:admin => nil)
end

get '/delete_user_confirm/:id' do
  id = params[:id]
  @user = User.find(id)
  erb :user_delete_confirm
end

get '/delete_user/:id' do 
  id = params[:id]
  User.destroy(id)
end