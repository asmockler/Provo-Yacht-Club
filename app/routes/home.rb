get '/' do
  @total_songs = Song.count
  @number = 0
  @songs = Song.limit(12).find_each(:published => true, :order => :created_at.desc)

  erb :NewHome
end

get '/load_blog' do
  @posts = Song.limit(5).find_each(:has_blog_post => true, :order => :created_at.desc)
  erb :blog
end

get '/load_about' do
  erb :about
end

get '/load_more_songs/:number' do
  number = params[:number]
  @number = number.to_i
  @songs = Song.limit(9).skip(@number).find_each(:order => :created_at.desc)
  erb :song_thumbs
end

get '/setup' do
  @user = User.first()
  erb :NewManager
end

get '/more_blog_posts/:batch' do |batch|
  skip = batch.to_i * 5
 @posts = Song.limit(5).skip(skip).find_each(:has_blog_post => true, :order => :created_at.desc) 

 erb :blog_post
end