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
	id = settings.mongo_db["test.collection"].insert params 

	erb :index
end

get '/:id' do
	settings.mongo_db["testcollection"].remove(params, 1)

	erb :index
end


# Project todos:
#  *Add Delete Button (db.testcollection.remove( { hospital: "IUPUI" } , 1 )) 
#  *Add Update Button
#  *Fix Times 
#  *Sort Abilities
#.  *Make Collapsable?
#  *Restyle to Taste (make "in-progress" checkbox which determines color of panel)


