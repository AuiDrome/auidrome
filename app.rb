require 'thin'
require 'em-websocket'
require 'sinatra/base'
require 'rack-flash'
require 'omniauth-twitter'
require 'pry'
require 'json'
require_relative 'lib/auidrome'

EM.run do
  class App < Sinatra::Base
    set :bind, '0.0.0.0'
    enable :sessions
    use Rack::Flash
    use Rack::Logger

    def self.config
      @config ||= Auidrome::Config.new(ARGV[0])
    end


    configure do
      use OmniAuth::Builder do
        provider :twitter, ENV['CONSUMER_KEY'], ENV['CONSUMER_SECRET']
      end
    end

    helpers do
      def logger
        request.logger
      end

      def current_user
        session[:provider] && session[session[:provider]]
      end

      def file_request?
        request.path_info =~ /\/(?:images)|(?:favicon\.ico$)/
      end
    end

    before do
      logger.info "Proccessing #{request.path_info}" unless file_request?
      pass unless request.path_info =~ /^\/admin/
    
      # /auth/twitter is captured by omniauth:
      # when the path info matches /auth/twitter, omniauth will redirect to twitter
      unless current_user
        session[:return_to] = request.path_info
        redirect to('/auth/twitter')
      end
    end

    def return_to path, message
      session[:return_to] = nil
      flash[:notice] = "───┤ #{message} ├───"
      redirect to(path || '/')
    end

    get '/auth/twitter/callback' do
      session[:uid] = env['omniauth.auth']['uid']
      session[:provider] = :twitter
      session[:twitter] = env['omniauth.auth']['info']['nickname']

      return_to session[:return_to], "Twitter session started as <strong>@#{session[:twitter]}</strong>."
    end

    get '/auth/failure' do
      return_to session[:return_to], "Sorry, something was wrong with your authentication. :("
    end

    get "/" do
      @tuits_submitted = Auidrome::Tuit.current_stored_tuits.invert.to_json
      erb :index
    end

    post "/tuits" do
      puts "Somebody has shouted: ¡¡¡#{params[:piido]}!!!"
      current_tuits = Auidrome::Tuit.current_stored_tuits
      if current_tuits[params[:piido]]
        puts "  ... but #{params[:piido]} have been shouted before. :("
        # TODO: some kind of feedback to the user
      else
        current_tuits[params[:piido]] = Time.now.utc
        Auidrome::Tuit.store_these current_tuits
      end
      redirect to('/')
    end

    get "/tuits/:auido" do
      @human = Auidrome::Human.new(params[:auido])
      erb :tuit
    end

    get "/admin" do
      erb :admin
    end

    get "/admin/its-me/:auido" do
      auido = params['auido']
      human = Auidrome::Human.read(auido)
      if human['identities'].include? current_user
        msg = '<span class="warning">Yes, you definitely are <strong>' + auido + '</strong> :)</span>.'
      else
        human['identities'] << current_user 
        Auidrome::Human.store human
        msg = "Added <strong>#{current_user}</strong> as identity of <strong>" + auido + '</strong>.'
      end
      return_to 'tuits/' + auido, msg
    end

    get "/admin/amadrinate/:auido" do
      auido = params['auido']
      human = Auidrome::Human.read(auido)
      if human['madrinos'].include? current_user
        msg = '<span class="warning">You already was madrino of <strong>' + auido + '</strong></span>.'
      else
        human['madrinos'] << current_user 
        Auidrome::Human.store human
        msg = "Now you are a madrino of <strong>" + auido + '</strong>. GREAT!!!'
      end
      return_to 'tuits/' + auido, msg
    end
  end

  @clients = []
  EM::WebSocket.start(:host => '0.0.0.0', :port => App.config.port_base + 1) do |ws|
    ws.onopen do |handshake|
      puts "WebSocket#onopen"
      @clients << ws
    end

    ws.onclose do
      puts "WebSocket#onclose"
      ws.send "Closed."
      @clients.delete ws
    end

    ws.onmessage do |liveAuido|
      puts "WebSocket#onmessage: #{liveAuido}"
      @clients.each do |socket|
        socket.send(liveAuido)
      end
    end
  end

  App.run! :port => App.config.port_base
end
