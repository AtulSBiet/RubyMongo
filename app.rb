require 'erubis'
require 'mongoid'
require 'json'

Mongoid.configure do |config|
  # development
  # config.sessions = {
  #   :default => {
  #   :hosts => ["localhost:27017"], :database => "my_db"
  # }

  # production
  config.sessions = {
    :default => {
    :hosts => ["10.0.2.12:40477"], :database => "t", :username => 'avuxdpj8izsqqrrj', :password => 'eclrsu49fk7lzwulidl8ae3ig18sd4w0'
  }

}
end

class App

  # call method, takes a single hash parameter and returns
  # an array containing the response status code, HTTP response
  # headers and the response body as an array of strings.
  def call env
    $params = nil
    $params = Rack::Utils.parse_nested_query(env["rack.input"].read)
    path = env['PATH_INFO']
    routes = ['index','new', 'data']
    action = path.split("/")
    if action.size > 0 and routes.include? action[1]
      body = User.new.send(action[1])
    elsif action.size == 0
      body = User.new.send('new')
    else
      body = 'Page not found' 
    end
    status = 200
    header = {"Content-Type" => "text/html"}

    [status, header, [body]]
  end
end

# User model that inherit ActiveRecored
class User
  include Mongoid::Document
  
  field :name, type: String
  field :email, type: String
  field :desc, type: String

  def new
    render :file => 'users/new'
  end

  def index
    @users = User.all
    render :file => 'users/index'
  end

  def data
    User.create(:name => $params['name'], :email => $params['email'], :desc => $params['desc'])
    @users = User.all
    render :file => 'users/index'
  end

  def render(option)
    @body = render_erb_file('views/' + option[:file] + '.erb')
  end

  def render_erb_file(file)
    input = File.read(file)
    eruby = Erubis::Eruby.new(input)
    @body = eruby.result(binding())
  end
end