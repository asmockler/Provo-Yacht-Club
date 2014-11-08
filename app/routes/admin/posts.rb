get '/admin/posts' do
  @song = Song.limit(10).find_each(:order => :created_at.desc)
  erb :'Admin/partials/posts'
end

get '/admin/posts/more_results/:batch' do |batch|
  num_to_skip = batch.to_i
  @song = Song.skip(num_to_skip).limit(10).find_each(:order => :created_at.desc)
  erb :'Admin/partials/post'
end

post '/admin/posts/new/save' do
  params[:published] = false
  song = Song.new(params)
  song.save
  @song = Song.limit(1).find_each(:order => :created_at.desc)
  erb :'Admin/partials/post'
end

post '/admin/posts/new/publish' do
  params[:published] = true
  song = Song.new(params)
  song.save
  @song = Song.limit(1).find_each(:order => :created_at.desc)
  erb :'Admin/partials/post'
end

get "/admin/posts/delete/:id" do
  id = BSON::ObjectId.from_string(params[:id])
  @song = Song.find(id)
  erb :'Admin/partials/post_delete'
end

delete '/admin/posts/delete/:id' do
  id = BSON::ObjectId.from_string(params[:id])
  Song.destroy(id)
end

get '/admin/posts/edit/:id' do
  id = params[:id]
  @song = Song.find(id)
  erb :'Admin/partials/post_edit'
end

post '/admin/posts/edit/:action/:id' do
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
  erb :'Admin/partials/posts'
end