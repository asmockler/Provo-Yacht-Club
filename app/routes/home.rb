["/bcsc", "/bootycallsnapchat", "/booty_call_snapchat"].each do |path|
  get path do
    erb :'bootycallsnapchat/booty_call_snapchat'
  end
end

get '/' do
  @sidebar_state = false
  @total_songs = Song.count
  @number = 0
  @songs = Song.limit(12).find_each(:published => true, :order => :created_at.desc)

  erb :'Index/index'
end

get '/blog/?:id?/?:slug?' do
  @sidebar_state = "sidebar"
  @total_songs = Song.count
  @number = 0
  @songs = Song.limit(12).find_each(:published => true, :order => :created_at.desc)

  erb :'Index/index'
end

get '/about' do
  @sidebar_state = "sidebar"
  @total_songs = Song.count
  @number = 0
  @songs = Song.limit(12).find_each(:published => true, :order => :created_at.desc)

  erb :'Index/index'
end

get '/load_more_songs/:number' do
  number = params[:number]
  @number = number.to_i
  @songs = Song.limit(9).skip(@number).find_each(:published => true, :order => :created_at.desc)
  erb :'Index/partials/song_thumb'
end

get '/api/blog/?:id?' do
  if params[:id]
    @posts = Song.FIND_BY_ID
  else
    @posts = Song.limit(5).find_each(:has_blog_post => true, :order => :created_at.desc)
  end
  
  erb :'Index/blog/blog'
end

get '/api/load_more_blog_posts/:batch' do |batch|
  skip = batch.to_i * 5
 @posts = Song.limit(5).skip(skip).find_each(:has_blog_post => true, :order => :created_at.desc) 

 erb :'Index/blog/blog_post'
end

get '/api/about' do
  erb :'Index/about/about'
end
