["/bcsc", "/bootycallsnapchat", "/booty_call_snapchat"].each do |path|
  get path do
    erb :'bootycallsnapchat/booty_call_snapchat'
  end
end

get '/update/database/slugs' do 
  @songs = Song.all

  @songs.each do |song|
    # Generate the base slug
    @genereated_slug = sluggify(song.title)
    $n = 0

    def check_for_duplicate ( slug )
      duplicate = Song.first(:slug => slug)

      if duplicate
        $n = $n + 1
        new_slug = @genereated_slug + "-" + $n.to_s
        check_for_duplicate(new_slug)
      else
        @genereated_slug = slug
      end
    end

    check_for_duplicate(@genereated_slug)
    song.slug = @genereated_slug
    song.save
  end

  "Values updated"
end

get '/update/database/number' do
  @songs = Song.find_each(:order => :created_at.asc)
  @n = 1

  @songs.each do |song|
    song.number = @n
    song.save
    @n = @n + 1
  end

  "Updated"
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
  @total_songs = Song.count
  @unpublished_songs = Song.where(:number.gt => song.number, :published => false).count
  if (@total_songs - (song.number + @unpublished_songs) - 2) > 0
    @num_to_skip = @total_songs - (song.number + @unpublished_songs) - 2
  else
    @num_to_skip = 0
  end
  @songs = Song.limit(20).skip(@num_to_skip).find_each(:published => true, :order => :created_at.desc)
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
  number = params[:number]
  @number = number.to_i
  @songs = Song.limit(10).skip(@number).find_each(:published => true, :order => :created_at.desc)
  erb :'Index/partials/song_thumb'
end

get '/load_previous_songs/:number' do
  number = params[:number].to_i
  @songs = Song.limit(10).find_each(:number.gt => number, :published => true, :order => :created_at.desc)
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