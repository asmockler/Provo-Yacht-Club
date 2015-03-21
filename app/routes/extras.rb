["/bcsc", "/bootycallsnapchat", "/booty_call_snapchat"].each do |path|
  get path do
    erb :'bootycallsnapchat/booty_call_snapchat'
  end
end

get "/thelist" do
	@count = List.count
	if @count > 149
		@full = true
	else
		@full = false
	end
	erb :'special/list'
end

post "/thelist/:email/:name" do
	unless List.count < 152
		return 403
	end

	@list = List.new(:name => params["name"], :email => params["email"])

	@list.save

	if @list.save
		return 201
	else
		return 409
	end
	
	return 201
end
