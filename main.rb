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

############## Mongo Mapper Classes ###################

  class User
    include MongoMapper::Document
    include ActiveModel::SecurePassword

    has_secure_password
    key :first_name,          String
    key :last_name,           String
    key :email,               String, :unique => true
    key :admin,               Boolean
    key :password_digest,     String
  end

  class Song 
    include MongoMapper::Document
    
    key :soundcloud_url, String
    key :title, String
    key :artist, String
    key :album, String
    key :album_art, String
    key :tag_1, String
    key :tag_2, String
    key :is_local, Boolean
    key :author, String
    key :has_blog_post, Boolean
    key :blog_title, String
    key :blog_post, String
    key :published, Boolean

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

    # Stuff for Logging Out
      get '/logout' do
        session.clear
        redirect '/'
      end

    # New User Page

      # Getting the Page
        get '/new_user' do
          erb :new_user
        end

      # Saving w/ email validation
        post '/new_user' do
          user = User.create! first_name: params["first_name"], last_name: params["last_name"], email: params["email"], password: params["password"], password_confirmation: params["password"]
          if user.save
            redirect '/'
          else
            flash[:bad_email] = true
            redirect '/new_user'
          end
        end

############ Manager ############
  
  get '/Manager' do
    if session["admin"]
      @user = User.find(session["user_id"])
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
      @song = Song.limit(10).find_each(:order => :created_at.desc)
      erb :post_manager
    end

        # Expanding the Table

          get '/Manager/moreResults/:batch' do |batch|
            num_to_skip = batch.to_i
            @song = Song.skip(num_to_skip).limit(10).find_each(:order => :created_at.desc)
            erb :manage_table
          end


        # Saving and Publishing new posts

          post '/NewPost/save' do
            params[:published] = false
            song = Song.new(params)
            song.save
            @song = Song.limit(1).find_each(:order => :created_at.desc)
            erb :manage_table
          end

          post '/NewPost/publish' do
            params[:published] = true
            song = Song.new(params)
            song.save
            @song = Song.limit(1).find_each(:order => :created_at.desc)
            erb :manage_table
          end


        # Deleting A Post
          # Modal
            get "/Manager/delete/:id" do
              id = BSON::ObjectId.from_string(params[:id])
              @song = Song.find(id)
              erb :manager_delete_confirm
            end

          # Delete
            get '/delete/:id' do
              id = BSON::ObjectId.from_string(params[:id])
              Song.destroy(id)
            end


        # Editing A Post

          # Modal
            get '/Manager/edit-modal/:id' do
              id = params[:id]
              @song = Song.find(id)
              erb :manager_edit_form
            end

          # Saving
              

          # Publishing
            post '/edit/:action/:id' do
              action = params.delete("action")

              song = Song.find(params[:id])

              if action == "publish"
                params[:published] = true
              elsif action == "unpublish"
                params[:published] = false
              else
                params[:published] = song.published
              end

              song.update_attributes(params)

              song.reload
              @song = song
              erb :manage_table
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

    get '/delete_user_confirm/:id' do
      id = params[:id]
      @user = User.find(id)
      erb :user_delete_confirm
    end

    get '/delete_user/:id' do 
      id = params[:id]
      User.destroy(id)
    end


##################################################


# Status Alerts - this needs finishing? - May be replaced.

  get '/StatusAlert' do
    erb :status_alerts
  end


########### Home Page ############
get '/' do
  @total_songs = Song.count
  @number = 0
  @songs = Song.limit(12).find_each(:published => true, :order => :created_at.desc)

  erb :NewHome
end

get '/sort/:category' do |category|
  cat = category.to_s
  @number = 0
  @songs = Song.limit(12).find_each(:published => true, :order => :created_at.desc, :tag_1 => cat || :tag_2 => cat)
  erb :song_thumbs
end

get '/load_blog' do
  @posts = Song.limit(5).find_each(:has_blog_post => true, :order => :created_at.desc)
  erb :blog
end

get '/load_about' do
  erb :about
end

get '/load_more_songs/:number/:category' do
  number = params[:number].to_i
  category = params[:category]
  @songs = Song.where(:order => :created_at.desc)
  unless category.nil? || category == ""
   @songs.where(:tag_1 => category || :tag_2 => category)
  end
  @songs.skip(number).limit(9)
  erb :song_thumbs
end

get '/more_blog_posts/:batch' do |batch|
  skip = batch.to_i * 5
 @posts = Song.limit(5).skip(skip).find_each(:has_blog_post => true, :order => :created_at.desc) 

 erb :blog_post
end

########### BOOTY CALL SNAPCHAT ############

["/bcsc", "/bootycallsnapchat", "/booty_call_snapchat"].each do |path|
  get path do
    erb :'bootycallsnapchat/booty_call_snapchat'
  end
end


=begin
To Do:
*favicon
*Mobile Layout
    *Include ads
*Finish Square Profile & Launch Space
*Finish Facebook Page
*Playlist feature?
*Figure Out why there is an error when making/removing admins
*Fix Error on post delete...?
=end
