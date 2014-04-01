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
    @recentposts = settings.mongo_db["Posts"].find.sort('_id','descending').limit(6)
    erb :index
  end

  get '/moreResults/:batch' do |batch|
    num_to_skip = 3 * batch.to_i
    @posts = settings.mongo_db["Posts"].find().sort({_id: -1}).skip(num_to_skip).limit(3)
    erb :posts_long_front
  end

      # Sorting
      get '/Big Beats' do
        @posts = settings.mongo_db["Posts"].find({ :$or => [{:tag => "Big Beats"}, {:tag2 => "Big Beats"}] }).sort({_id: -1}).limit(3)
        @recentposts = settings.mongo_db["Posts"].find({ :$or => [{:tag => "Big Beats"}, {:tag2 => "Big Beats"}] }).limit(6)
        erb :index
      end

      get '/Dance' do
        @posts = settings.mongo_db["Posts"].find({ :$or => [{:tag => "Dance"}, {:tag2 => "Dance"}] }).sort({_id: -1}).limit(3)
        @recentposts = settings.mongo_db["Posts"].find({ :$or => [{:tag => "Dance"}, {:tag2 => "Dance"}] }).sort('_id','descending').limit(6)
        erb :index
      end

      get '/Chill' do
        @posts = settings.mongo_db["Posts"].find({ :$or => [{:tag => "Chill"}, {:tag2 => "Chill"}] }).sort({_id: -1}).limit(3)
        @recentposts = settings.mongo_db["Posts"].find({ :$or => [{:tag => "Chill"}, {:tag2 => "Chill"}] }).sort('_id','descending').limit(6)
        erb :index
      end

      get '/Revival' do
        @posts = settings.mongo_db["Posts"].find({ :$or => [{:tag => "Revival"}, {:tag2 => "Revival"}] }).sort({_id: -1}).limit(3)
        @recentposts = settings.mongo_db["Posts"].find({ :$or => [{:tag => "Revival"}, {:tag2 => "Revival"}] }).sort('_id','descending').limit(6)
        erb :index
      end

      get '/Etc.' do
        @posts = settings.mongo_db["Posts"].find({ :$or => [{:tag => "Etc."}, {:tag2 => "Etc."}] }).sort({_id: -1}).limit(3)
        @recentposts = settings.mongo_db["Posts"].find({ :$or => [{:tag => "Etc."}, {:tag2 => "Etc."}] }).sort('_id','descending').limit(6)
        erb :index
      end



# Calling the Post Manager
  get '/Manager' do
    if session["user"]
     @posts = settings.mongo_db["Posts"].find().sort({_id: -1}).limit(5)
     erb :Manager
    else
     redirect '/login'
    end
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

      get '/Manager/edit-modal/:id' do |id|
        @post = settings.mongo_db["Posts"].find_one({_id: BSON::ObjectId(id)})
        erb :manager_edit_form
      end

      get "/Manager/delete/:id" do |id|
        @post = settings.mongo_db["Posts"].find_one({_id: BSON::ObjectId(id)})
        erb :manager_delete_confirm
      end


# Stuff for Logging In
  get '/login' do
    if session["user"]
     @posts = settings.mongo_db["Posts"].find().sort({_id: -1}).limit(5)
     erb :Manager
    else
     redirect '/login'
    end
  end

  post '/login' do
    if settings.mongo_db["users"].find_one(:username => params[:username]) and settings.mongo_db["users"].find_one(:password => params[:password])
      session["user"] = true 
      redirect '/Manager'
    else
      flash[:loginerror] = true
      redirect '/login'
    end
  end


=begin
Issues:
*Disable inputs with media radio buttons (finish this)
*Fix background image sizing

To Do:
*Styling & Logo
*Finish Square Profile & Launch Space
*Finish Facebook Page
=end
