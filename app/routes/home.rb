["/bcsc", "/bootycallsnapchat", "/booty_call_snapchat"].each do |path|
  get path do
    erb :'bootycallsnapchat/booty_call_snapchat'
  end
end

get '/' do
  @total_songs = Song.count
  @songs = Song.limit(20).find_each(:published => true, :order => :created_at.desc)
  @sidebar_state = false
  erb :'Index/index'
end

get '/track/:slug' do
  song = Song.first(:slug => params[:slug], :order => :created_at.desc)
  unless song
    redirect '/error/404'
  end
  @total_songs = Song.last.number
  @unpublished_songs = Song.where(:number.gt => song.number.to_i, :published => false).count
  if (@total_songs - (song.number + @unpublished_songs) - 2) > 0
    @num_to_skip = @total_songs.to_i - (song.number.to_i + @unpublished_songs.to_i) - 2
  else
    @num_to_skip = 0
  end
  @songs = Song.limit(20).skip(@num_to_skip).find_each(:published => true, :order => :created_at.desc)
  @sidebar_state = false

  erb :'Index/index'
end

get '/random' do
  @total_songs = Song.count
  random_number = rand(@total_songs)
  random_number += 10 if random_number < 10
  @songs = Song.limit(15).skip(random_number).find_each(:published => true, :order => :created_at.desc)
  @sidebar_state = false

  erb :'Index/index'
end

get '/blog/?:id?/?:slug?' do
  @sidebar_state = "sidebar"
  @total_songs = Song.count
  @number = 0
  @songs = Song.limit(20).find_each(:published => true, :order => :created_at.desc)

  erb :'Index/index'
end

get '/about' do
  @sidebar_state = "sidebar"
  @total_songs = Song.count
  @number = 0
  @songs = Song.limit(20).find_each(:published => true, :order => :created_at.desc)

  erb :'Index/index'
end

get '/load_more_songs/:number' do
  @total_songs = Song.last.number
  @number = params[:number].to_i
  @songs = Song.limit(10).skip(@total_songs - @number + 1).find_each(:published => true, :order => :created_at.desc)
  erb :'Index/partials/song_thumb'
end

get '/load_previous_songs/:number' do
  @total_songs = Song.last.number
  @number = params[:number].to_i
  if (@total_songs - @number - 10) > 0
    @num_to_skip = @total_songs - @number - 10
  else
    @num_to_skip = 0
  end
  @songs = Song.limit(10).skip(@num_to_skip).find_each(:published => true, :order => :created_at.desc)
  erb :'Index/partials/song_thumb'
end

get '/api/blog/?:id?' do
  if params[:id]
    @posts = Song.FIND_BY_ID
  else
    @posts = Song.limit(10).find_each(:has_blog_post => true, :order => :created_at.desc)
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

get '/event' do
  redirect 'https://www.facebook.com/events/1391500977819394/'
end