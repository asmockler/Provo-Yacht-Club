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
  @posts = settings.mongo_db["Posts"].find().sort({_id: -1}).limit(3)
  erb :index
end

# A Page for dumb experiments because I'm dumb
get '/testingstuff' do
  erb :testtime
end

# Calling the Post Manager
get '/Manager' do
  @posts = settings.mongo_db["Posts"].find().sort({_id: -1}).limit(5)
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

get '/Manager/moreResults/:batch' do |batch|
  num_to_skip = 5 * batch.to_i
  @posts = settings.mongo_db["Posts"].find().sort({_id: -1}).skip(num_to_skip).limit(5)
  erb :manage_table
end

get '/moreResults/:batch' do |batch|
  num_to_skip = 5 * batch.to_i
  @posts = settings.mongo_db["Posts"].find().sort({_id: -1}).skip(num_to_skip).limit(5)
  erb :post_long_front
end

=begin

Issues:
*Load more posts on homepage
*Make entry time not get deleted on edit
*Disable inputs with media radio buttons (finish this)
*Fix background image sizing
  
=end
