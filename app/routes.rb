require_relative 'routes/home'
require_relative 'routes/admin'
require_relative 'routes/auth'
require_relative 'routes/extras'
require_relative 'routes/admin/posts'
require_relative 'routes/admin/users'

get '/error/404' do
	"That isn't a valid page"
end