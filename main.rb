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
    @posts = settings.mongo_db["Posts"].find({:publish => true}).sort({_id: -1}).limit(5)
    @recentposts = settings.mongo_db["Posts"].find({:publish => true}).sort('_id','descending').limit(6)
    @feature = settings.mongo_db["Features"].find({:publish => true}).sort({_id: -1}).limit(1)
    erb :index
  end

  get '/moreResults/:batch' do |batch|
    num_to_skip = 3 * batch.to_i
    @posts = settings.mongo_db["Posts"].find({:publish => true}).sort({_id: -1}).skip(num_to_skip).limit(3)
    erb :posts_long_front
  end

    # Sorting
      get '/Big Beats' do
        @posts = settings.mongo_db["Posts"].find({:$and => [{:publish => true}, {:$or => [{:tag => "Big Beats"}, {:tag2 => "Big Beats"}]} ] }).sort({_id: -1}).limit(3)
        @recentposts = settings.mongo_db["Posts"].find({:$and => [{:publish => true}, {:$or => [{:tag => "Big Beats"}, {:tag2 => "Big Beats"}]} ] }).limit(6)
        erb :index
      end

      get '/Dance' do
        @posts = settings.mongo_db["Posts"].find({:$and => [{:publish => true}, {:$or => [{:tag => "Dance"}, {:tag2 => "Dance"}]} ] }).sort({_id: -1}).limit(3)
        @recentposts = settings.mongo_db["Posts"].find({:$and => [{:publish => true}, {:$or => [{:tag => "Dance"}, {:tag2 => "Dance"}]} ] }).sort('_id','descending').limit(6)
        erb :index
      end

      get '/Chill' do
        @posts = settings.mongo_db["Posts"].find({:$and => [{:publish => true}, {:$or => [{:tag => "Chill"}, {:tag2 => "Chill"}]} ] }).sort({_id: -1}).limit(3)
        @recentposts = settings.mongo_db["Posts"].find({:$and => [{:publish => true}, {:$or => [{:tag => "Chill"}, {:tag2 => "Chill"}]} ] }).sort('_id','descending').limit(6)
        erb :index
      end

      get '/Revival' do
        @posts = settings.mongo_db["Posts"].find({:$and => [{:publish => true}, {:$or => [{:tag => "Revival"}, {:tag2 => "Revival"}]} ] }).sort({_id: -1}).limit(3)
        @recentposts = settings.mongo_db["Posts"].find({:$and => [{:publish => true}, {:$or => [{:tag => "Revival"}, {:tag2 => "Revival"}]} ] }).sort('_id','descending').limit(6)
        erb :index
      end

      get '/Etc.' do
        @posts = settings.mongo_db["Posts"].find({:$and => [{:publish => true}, {:$or => [{:tag => "Etc."}, {:tag2 => "Etc."}]} ] }).sort({_id: -1}).limit(3)
        @recentposts = settings.mongo_db["Posts"].find({:$and => [{:publish => true}, {:$or => [{:tag => "Etc."}, {:tag2 => "Etc."}]} ] }).sort('_id','descending').limit(6)
        erb :index
      end



# Calling the Manager
  
  get '/Manager' do
    if session["user"]
      erb :NewManager
    else
      redirect '/login'
    end
  end

  # Stuff for Posts
    get '/Manager/PostManager' do
      @posts = settings.mongo_db["Posts"].find().sort({_id: -1}).limit(5)
      erb :post_manager
    end

        # Expanding the Table
          get '/Manager/moreResults/:batch' do |batch|
            num_to_skip = batch.to_i
            @posts = settings.mongo_db["Posts"].find().sort({_id: -1}).skip(num_to_skip).limit(5)
            erb :manage_table
          end

        # Saving and Publishing new posts

          post '/NewPost/save' do
            params[:entrytime] = Time.new.strftime("%I:%M%p %Z on %A, %B %d, %Y")
            params[:publish] = false
            settings.mongo_db["Posts"].insert(params)
            @posts = [params]
            erb :manage_table
          end


          post '/NewPost/publish' do
            params[:entrytime] = Time.new.strftime("%I:%M%p %Z on %A, %B %d, %Y")
            params[:publish] = true
            settings.mongo_db["Posts"].insert params
            @posts = [params]
            erb :manage_table
          end

        # Deleting A Post
          # Modal
            get "/Manager/delete/:id" do |id|
              @post = settings.mongo_db["Posts"].find_one({_id: BSON::ObjectId(id)})
              erb :manager_delete_confirm
            end

          # Delete
            get '/delete/:id' do
              id = BSON::ObjectId.from_string(params[:id])
              settings.mongo_db["Posts"].remove({:_id => id})
            end


        # Editing A Post

          # Modal
            get '/Manager/edit-modal/:id' do |id|
              @post = settings.mongo_db["Posts"].find_one({_id: BSON::ObjectId(id)})
              erb :manager_edit_form
            end

          # Publishing
            post '/edit/publish/:id' do
              params[:publish] = true
              @id = BSON::ObjectId.from_string(params[:id])
              settings.mongo_db["Posts"].update({:_id => @id}, params )

              if settings.mongo_db["Posts"].update({:_id => @id}, params )
                flash[:editSuccess] = true
              else
                flash[:editError] = true
              end
              @posts = [params]
              erb :manage_table
            end

          # Unpublishing
            post '/edit/unpublish/:id' do
              params[:publish] = false
              @id = BSON::ObjectId.from_string(params[:id])
              settings.mongo_db["Posts"].update({:_id => @id}, params )

              if settings.mongo_db["Posts"].update({:_id => @id}, params )
                flash[:editSuccess] = true
              else
                flash[:editError] = true
              end

              @posts = [params]
              erb :manage_table
            end

          # Saving (Doesn't Affect Published or Unpublished)
            post '/edit/save/:id' do
              @id = BSON::ObjectId.from_string(params[:id])
              settings.mongo_db["Posts"].update({:_id => @id}, params )

              if settings.mongo_db["Posts"].update({:_id => @id}, params )
                flash[:editSuccess] = true
              else
                flash[:editError] = true
              end

              @posts = [params]
              erb :manage_table
            end

  # Stuff for Features
    get '/Manager/FeatureManager' do
      @feature = settings.mongo_db["Features"].find().sort({_id: -1}).limit(5)
      erb :feature_manager
    end

  # Logging In and Out

          # Stuff for Logging In
            get '/login' do
              if session["user"]
               @posts = settings.mongo_db["Posts"].find().sort({_id: -1}).limit(5)
               redirect '/Manager'
              else
               erb :login
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

          #Stuff for Logging Out
            get '/logout' do
              session.clear
              redirect '/'
            end



# TEST

  get '/StatusAlert' do
    erb :status_alerts
  end





=begin
Issues:
*Disable inputs with media radio buttons (finish this)

To Do:
*favicon
*enable feature editing
*Finish Square Profile & Launch Space
*Finish Facebook Page
=end
