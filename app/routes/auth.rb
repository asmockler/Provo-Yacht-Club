get '/login' do
  if session["admin"]
   redirect '/Manager'
 else
   erb :login
 end
end

post '/login' do
  @user = User.first(:email => params[:email])

  if @user
    if @user.authenticate params[:password]
      session["admin"] = @user.admin 
      session['logged_in'] = true
      session['user_id'] = @user.id
      redirect '/Manager'
    else
      flash[:loginerror] = true
      redirect '/login'
    end
  else
    flash[:loginerror] = true
    redirect '/login' 
  end
end

get '/logout' do
  session.clear
  redirect '/'
end

get '/new_user' do
  erb :new_user
end

post '/new_user' do
  user = User.create! first_name: params["first_name"], last_name: params["last_name"], email: params["email"], password: params["password"], password_confirmation: params["password"]
  if user.save
    redirect '/'
  else
    flash[:bad_email] = true
    redirect '/new_user'
  end
end