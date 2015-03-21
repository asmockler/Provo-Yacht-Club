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

helpers do
  def protected!
    return if authorized?
    headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
    halt 401, "Not authorized\n"
  end

  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? and @auth.basic? and @auth.credentials and @auth.credentials == ['asmockler', 'thelistlol123']
  end
end

get "/thelist/send" do
	protected!
	
	@partiers = List.find_each()

	@partiers.each do |partier|

		Pony.mail({
		  :to => partier.email,
		  :via => :smtp,
		  :via_options => {
		    :address              => 'smtp.mandrillapp.com',
		    :port                 => '587',
		    :enable_starttls_auto => true,
		    :user_name            => 'app17320251@heroku.com',
		    :password             => 'eV3Y8KDvRNvZKMITgQhoww',
		    :authentication       => :plain, # :plain, :login, :cram_md5, no auth by default
		    :domain               => "localhost.localdomain" # the HELO domain provided by the client to the server
		  },
		  :from => "noreply@provoyachtclub.com",
		  :html_body => erb(:'special/thelist_email'),

		  :subject => 'THE LIST | Provo Yacht Club'
		});

	end
end