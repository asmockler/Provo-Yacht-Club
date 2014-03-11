require 'rubygems'
require 'sinatra'
require 'erb'
require 'mongo'
require 'sinatra/flash'

include Mongo

enable :sessions

configure do
 db = URI.parse(ENV['MONGOHQ_URL'])
 db_name = db.path.gsub(/^\//,'')
 conn = Mongo::Connection.new(db.host, db.port).db(db_name)
 conn.authenticate(db.user, db.password) unless (db.user.nil? || db.password.nil?)
 set :mongo_db, conn
end

# Calling the main view
get '/' do
  erb :index
end

# A Page for dumb experiments because I'm dumb
get '/testingstuff' do
  erb :testtime
end

# Calling the Post Manager
get '/Manager' do
  @posts = settings.mongo_db["Posts"].find().sort({_id: -1}).limit(2)
  erb :Manager
end

# Saving new posts
post '/NewPost' do
  params[:entrytime] = Time.new.strftime("%I:%M%p %Z on %A, %B %d, %Y")
  settings.mongo_db["Posts"].insert params

  if settings.mongo_db['Posts'].find({:_id => params[:id]})
    flash[:postSuccess] = true
  else
    flash[:postError] = true
  end

  redirect '/Manager'
end

# Delete a record
get '/delete/:id' do
  id = BSON::ObjectId.from_string(params[:id])
  settings.mongo_db["Posts"].remove({:_id => id})

  if settings.mongo_db['Posts'].remove({:_id => id})
    flash[:deleteSuccess] = true
  else
    flash[:deleteError] = true
  end

  redirect '/Manager'
end

# Submit edited entry
post '/edit/:id' do
  @id = BSON::ObjectId.from_string(params[:id])
  settings.mongo_db["Posts"].update({:_id => @id}, params )

  if settings.mongo_db["Posts"].update({:_id => @id}, params )
    flash[:editSuccess] = true
  else
    flash[:editError] = true
  end

  redirect '/Manager'
end

get '/update' do
  Time.now.to_s
end

get '/Manager/moreResults/:batch' do |batch|
  num_to_skip = 2 * batch.to_i
  @posts = settings.mongo_db["Posts"].find().sort({_id: -1}).skip(num_to_skip).limit(2)
  erb :manage_table

  #erb template just for table rows

  #jquery onclick make an ajax call $.get and .append with the result

  #keep track of the _id. On the table, have a data attribute (data-last-read); keep track on the first one and on the result
end


=begin

THIS IS ALL OF THE OLD CODE FROM BEFORE. I AM LEAVING IT HERE FOR REFERENCE.

#  Basic Authentication
use Rack::Auth::Basic, "Restricted Area" do |username, password|
    [username, password] == ['admin', 'password']
end

# Getting the login page
get '/login' do
  erb :login_register
end

# Checking User Credentials
post '/login' do
  if settings.mongo_db["users"].find_one(:username => params[:username]) and settings.mongo_db["users"].find_one(:password => params[:password])
    user = settings.mongo_db["users"].find_one(:username => params[:username])
    session["user_id"] = user["_id"]
    session["username"] = user["username"]
    session["first_name"] = user["first_name"]
    session["last_name"] = user["last_name"]
    session["email"] = user["email"]
    session["admin"] = user["admin"]
    session["user"] = true
    redirect '/'
  else
    flash[:loginerror] = true
    redirect '/login'
  end
end

# New User
post '/register' do
  settings.mongo_db["users"].insert params
  flash[:newuser] = true
  redirect '/login'
end

# Get Landing Page
get '/' do
  if session["user"]
	 erb :index
  else
   redirect '/login'
  end
end

# New Record
post '/' do
	params[:entrytime] = Time.new.strftime("%I:%M%p %Z on %A, %B %d, %Y")
  settings.mongo_db["testcollection"].insert params
	redirect '/'
end

# Delete a record
get '/delete/:id' do
	id = BSON::ObjectId.from_string(params[:id])
	settings.mongo_db["testcollection"].remove({:_id => id})

	redirect '/'
end

# Edit Page
get '/edit/:id' do
  @id = BSON::ObjectId.from_string(params[:id])
  @database = settings.mongo_db["testcollection"]
	erb :edit
end

# Submit edited entry
post '/edit/:id' do
  @id = BSON::ObjectId.from_string(params[:id])
  params[:entrytime] = Time.new.strftime("%I:%M%p %Z on %A, %B %d, %Y")
  settings.mongo_db["testcollection"].update({:_id => @id}, params )

  if settings.mongo_db["testcollection"].update({:_id => @id}, params )
    flash[:editsuccess] = true
  else
    flash[:editerror] = true
  end

  redirect '/'
end

# Log Out
get '/logout' do
  session["user"] = false
  redirect '/login'
end

# Get Admin Dashboard
get '/admin' do
  erb :admin
end

# Get the User Approval Page
get '/admin_approve' do
  erb :admin_approve
end

# Approve Users
post '/admin_approve' do
  settings.mongo_db["users"].update({:username => params[:username]}, '$set' => {:approved => params[:approved]} )

  redirect '/admin'
end

get '/admin_management' do
  erb :admin_management
end

post '/admin_management' do
  settings.mongo_db["users"].update({:username => params[:username]}, '$set' => {:admin => "true"} )

  redirect '/admin'
end

get '/test' do
  erb :test
end


# Urgent todos:
# replace edit and submit names with user submitted information
# Admin Management

# Project todos:
#  *Fix Times (updated v. created time as well)
#  *Sort Abilities
#  *Restyle to Taste (make "in-progress" checkbox which determines color of panel)
#  *fix text/numbers in inputs

=end
