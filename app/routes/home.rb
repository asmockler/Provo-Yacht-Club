get '/' do
  @total_songs = Song.count
  @number = 0
  @songs = Song.limit(12).find_each(:published => true, :order => :created_at.desc)

  erb :'Index/index'
end

get '/load_more_songs/:number' do
  number = params[:number]
  @number = number.to_i
  @songs = Song.limit(9).skip(@number).find_each(:order => :created_at.desc)
  erb :'Index/partials/song_thumbs'
end

get '/blog' do
  @posts = Song.limit(5).find_each(:has_blog_post => true, :order => :created_at.desc)
  erb :'Index/blog/blog'
end

get '/load_more_blog_posts/:batch' do |batch|
  skip = batch.to_i * 5
 @posts = Song.limit(5).skip(skip).find_each(:has_blog_post => true, :order => :created_at.desc) 

 erb :'Index/blog/blog_post'
end

get '/about' do
  erb :'Index/about/about'
end