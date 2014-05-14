Bundler.require

include Mongo

enable :sessions
set :session_secret, 'super secret'

configure do
 db = URI.parse(ENV['MONGOHQ_URL'])
 db_name = db.path.gsub(/^\//,'')
 conn = Mongo::Connection.new(db.host, db.port).db(db_name)
 conn.authenticate(db.user, db.password) unless (db.user.nil? || db.password.nil?)
 set :mongo_db, conn
 MongoMapper.setup({'production' => {'uri' => ENV['MONGOHQ_URL']}}, 'production')
end

class User
  include MongoMapper::Document

  key :first_name,   String
  key :last_name,    String
  key :email,        String, :unique => true
  key :admin,        Boolean
  key :password,     String
end

class Song 
  include MongoMapper::Document
  
  key :_id, ObjectId
  key :song_title, String
  key :artist, String
  key :album, String
  key :soundcloud_url, String
  key :album_art, String
  key :tag_1, String
  key :tag_2, String
  key :author, String
  key :has_blog_post, Boolean
  key :blog_post, String

  timestamps!
end

########### New Users, Admins, and Logging in or out ############


  ######### Logging In and Out ########

    # Stuff for Logging In
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
          if params[:password] == @user.password
            session["admin"] = @user.admin 
            session['logged_in'] = true
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

    #Stuff for Logging Out
      get '/logout' do
        session.clear
        redirect '/'
      end


get '/new_user' do
  erb :new_user
end

post '/new_user' do
  user = User.new(params)
  if user.save
    redirect '/'
  else
    flash[:bad_email] = true
    redirect '/new_user'
  end
end

get '/usertest' do
  @users = User.all
  erb :usertest
end


############### Main view ###################
  get '/' do
    @posts = settings.mongo_db["Posts"].find({:publish => true}).sort({_id: -1}).limit(6)
    @recentposts = settings.mongo_db["Posts"].find({:publish => true}).sort('_id','descending').limit(6)
    @feature = settings.mongo_db["Features"].find({:active => true}).sort({_id: -1}).limit(1)
    erb :index
  end

  get '/moreResults/:batch' do |batch|
    num_to_skip = 6 * batch.to_i
    @posts = settings.mongo_db["Posts"].find({:publish => true}).sort({_id: -1}).skip(num_to_skip).limit(6)
    erb :posts_long_front
  end

    ######## Sorting ########
      get '/Big Beats' do
        @posts = settings.mongo_db["Posts"].find({:$and => [{:publish => true}, {:$or => [{:tag => "Big Beats"}, {:tag2 => "Big Beats"}]} ] }).sort({_id: -1}).limit(3)
        @recentposts = settings.mongo_db["Posts"].find({:$and => [{:publish => true}, {:$or => [{:tag => "Big Beats"}, {:tag2 => "Big Beats"}]} ] }).limit(6)
        @feature = settings.mongo_db["Features"].find({:active => true}).sort({_id: -1}).limit(1)
        erb :index
      end

      get '/Dance' do
        @posts = settings.mongo_db["Posts"].find({:$and => [{:publish => true}, {:$or => [{:tag => "Dance"}, {:tag2 => "Dance"}]} ] }).sort({_id: -1}).limit(3)
        @recentposts = settings.mongo_db["Posts"].find({:$and => [{:publish => true}, {:$or => [{:tag => "Dance"}, {:tag2 => "Dance"}]} ] }).sort('_id','descending').limit(6)
        @feature = settings.mongo_db["Features"].find({:active => true}).sort({_id: -1}).limit(1)
        erb :index
      end

      get '/Chill' do
        @posts = settings.mongo_db["Posts"].find({:$and => [{:publish => true}, {:$or => [{:tag => "Chill"}, {:tag2 => "Chill"}]} ] }).sort({_id: -1}).limit(3)
        @recentposts = settings.mongo_db["Posts"].find({:$and => [{:publish => true}, {:$or => [{:tag => "Chill"}, {:tag2 => "Chill"}]} ] }).sort('_id','descending').limit(6)
        @feature = settings.mongo_db["Features"].find({:active => true}).sort({_id: -1}).limit(1)
        erb :index
      end

      get '/Revival' do
        @posts = settings.mongo_db["Posts"].find({:$and => [{:publish => true}, {:$or => [{:tag => "Revival"}, {:tag2 => "Revival"}]} ] }).sort({_id: -1}).limit(3)
        @recentposts = settings.mongo_db["Posts"].find({:$and => [{:publish => true}, {:$or => [{:tag => "Revival"}, {:tag2 => "Revival"}]} ] }).sort('_id','descending').limit(6)
        @feature = settings.mongo_db["Features"].find({:active => true}).sort({_id: -1}).limit(1)
        erb :index
      end

      get '/Etc.' do
        @posts = settings.mongo_db["Posts"].find({:$and => [{:publish => true}, {:$or => [{:tag => "Etc."}, {:tag2 => "Etc."}]} ] }).sort({_id: -1}).limit(3)
        @recentposts = settings.mongo_db["Posts"].find({:$and => [{:publish => true}, {:$or => [{:tag => "Etc."}, {:tag2 => "Etc."}]} ] }).sort('_id','descending').limit(6)
        @feature = settings.mongo_db["Features"].find({:active => true}).sort({_id: -1}).limit(1)
        erb :index
      end



############ Manager ############
  
  get '/Manager' do
    if session["admin"]
      erb :NewManager
    elsif session["logged_in"]
      flash[:not_admin] = true
      redirect '/login'
    else
      redirect '/login'
    end
  end

  #======== Stuff for Posts ========#
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
            params[:entrytime] = Time.new
            params[:publish] = false
            settings.mongo_db["Posts"].insert(params)
            @posts = [params]
            erb :manage_table
          end


          post '/NewPost/publish' do
            params[:entrytime] = Time.new
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
            post '/edit/:action/:id' do
              action = params.delete("action")
              if action == "publish"
                params["publish"] = true
              elsif action == "unpublish"
                params["publish"] = false
              end

              @id = BSON::ObjectId.from_string(params[:id])
              settings.mongo_db["Posts"].update({:_id => @id}, params )

              @posts = [params]
              erb :manage_table
            end


  #======== Stuff for Features ========#
    get '/Manager/FeatureManager' do
      @posts = settings.mongo_db["Features"].find().sort({_id: -1}).limit(5)
      erb :feature_manager
    end

        # New Features
          post '/NewFeat/save' do
            params[:entrytime] = Time.new
            params[:active] = false
            settings.mongo_db["Features"].insert(params)
            @posts = [params]
            erb :manage_feat_table
          end

          post '/NewFeat/activate' do
            settings.mongo_db["Features"].update({:active => true}, '$set' => {:active => false})
            params[:entrytime] = Time.new
            params[:active] = true
            settings.mongo_db["Features"].insert(params)
            @posts = [params]
            erb :manage_feat_table
          end

        # Expanding the Feature Table
          get '/Manager/moreFeatResults/:batch' do |batch|
            num_to_skip = batch.to_i
            @posts = settings.mongo_db["Features"].find().sort({_id: -1}).skip(num_to_skip).limit(5)
            erb :manage_feat_table
          end

        # Deleting A Feature
           # Modal
            get "/Manager/deleteFeat/:id" do |id|
              @post = settings.mongo_db["Features"].find_one({_id: BSON::ObjectId(id)})
              erb :manager_delete_confirm_feature
            end

          # Delete
            get '/delete/feature/:id' do
              id = BSON::ObjectId.from_string(params[:id])
              settings.mongo_db["Features"].remove({:_id => id})
            end

        # Editing a Feature
          # Modal
            get '/Manager/edit-modal-feat/:id' do |id|
              @post = settings.mongo_db["Features"].find_one({_id: BSON::ObjectId(id)})
              erb :manager_edit_form_feat
            end

          # Publishing
            post '/editFeat/:action/:id' do
              action = params.delete("action")
              if action == "activate"
                settings.mongo_db["Features"].update({:active => true}, '$set' => {:active => false})
                params["active"] = true
              elsif action == "deactivate"
                params["active"] = false
              end

              @id = BSON::ObjectId.from_string(params[:id])
              settings.mongo_db["Features"].update({:_id => @id}, params )

              @posts = [params]
              erb :manage_feat_table
            end


  #======== Stuff for Users ========#
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


##################################################


# TEST

  get '/StatusAlert' do
    erb :status_alerts
  end


########### Making the New Layout Work ############
get '/redesign' do
  @posts = settings.mongo_db["Posts"].find({:publish => true}).sort({_id: -1}).limit(6)
  erb :NewHome
end

get '/load_blog' do
  erb :blog
end

get '/load_about' do
  erb :about
end

get '/workaround' do
  erb :NewManager
end

  # ######### Logging In and Out ########

  #         # Stuff for Logging In
  #           get '/login' do
  #             if session["user"]
  #              @posts = settings.mongo_db["Posts"].find().sort({_id: -1}).limit(5)
  #              redirect '/Manager'
  #             else
  #              erb :login
  #             end
  #           end

  #           post '/login' do
  #             if settings.mongo_db["users"].find_one(:username => params[:username]) and settings.mongo_db["users"].find_one(:password => params[:password])
  #               session["user"] = true 
  #               redirect '/Manager'
  #             else
  #               flash[:loginerror] = true
  #               redirect '/login'
  #             end
  #           end

  #         #Stuff for Logging Out
  #           get '/logout' do
  #             session.clear
  #             redirect '/'
  #           end



=begin
To Do:
*favicon
*Sort by date, not ID, and get dates to display properly
*Get AJAX to display properly on append
*Mobile Ads
*Disable inputs with media radio buttons (finish this)
*Finish Square Profile & Launch Space
*Finish Facebook Page
*Playlist feature?
=end
