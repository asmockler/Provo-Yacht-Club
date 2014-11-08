require_relative 'admin/users'
require_relative 'admin/posts'

get '/admin' do
  if session["admin"]
    @user = User.find(session["user_id"])
    erb :'Admin/admin'
  elsif session["logged_in"]
    flash[:not_admin] = true
    redirect '/login'
  else
    redirect '/login'
  end
end