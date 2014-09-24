get '/Manager/PostManager' do
  @song = Song.limit(10).find_each(:order => :created_at.desc)
  erb :post_manager
end

get '/Manager/moreResults/:batch' do |batch|
  num_to_skip = batch.to_i
  @song = Song.skip(num_to_skip).limit(10).find_each(:order => :created_at.desc)
  erb :manage_table
end

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

get "/Manager/delete/:id" do
  id = BSON::ObjectId.from_string(params[:id])
  @song = Song.find(id)
  erb :manager_delete_confirm
end

get '/delete/:id' do
  id = BSON::ObjectId.from_string(params[:id])
  Song.destroy(id)
end

get '/Manager/edit-modal/:id' do
  id = params[:id]
  @song = Song.find(id)
  erb :manager_edit_form
end

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