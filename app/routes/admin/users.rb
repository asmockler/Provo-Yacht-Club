get '/admin/users' do
  @user = User.all
  erb :'Admin/partials/users'
end

post '/admin/users/make_admin/:email' do
  @user = User.first(:email => params[:email])
  @user.set(:admin => true)
end

post '/admin/users/remove_admin/:email' do
  @user = User.first(:email => params[:email])
  @user.set(:admin => nil)
end

# GET delete confirmation modal
get '/admin/users/delete/:id' do
  id = params[:id]
  @user = User.find(id)
  erb :'Admin/partials/user_delete'
end

# DELETE user record
delete '/admin/users/delete/:id' do 
  id = params[:id]
  User.destroy(id)
end