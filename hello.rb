require 'rubygems'
require 'sinatra'
require 'erb'
require 'mongo'

include Mongo

configure do
 db = URI.parse(ENV['MONGOHQ_URL'])
 db_name = db.path.gsub(/^\//,'')
 conn = Mongo::Connection.new(db.host, db.port).db(db_name)
 conn.authenticate(db.user, db.password) unless (db.user.nil? || db.password.nil?)
 set :mongo_db, conn
end


get '/' do
	erb :index
end

post '/' do
	params[:entrytime] = Time.new.strftime("%I:%M%p %Z on %A, %B %d, %Y")
	id = settings.mongo_db["testcollection"].insert params 

	erb :index
end

get '/delete/:id' do
	id = BSON::ObjectId.from_string(params[:id])
	settings.mongo_db["testcollection"].remove({:_id => id})

	redirect '/'
end

get '/edit/:id' do
  @id = BSON::ObjectId.from_string(params[:id])
  @database = settings.mongo_db["testcollection"]
	erb :edit
end

# Project todos:
#  *Add Edit Button
#  *Fix Times 
#  *Sort Abilities
#  *Restyle to Taste (make "in-progress" checkbox which determines color of panel)
#  *users


