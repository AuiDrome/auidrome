# Copyright 2015 The Cocktail Experience
require 'thin'
require 'em-websocket'
require 'sinatra/base'
require 'rack-flash'
require 'rack/session/cookie'
require 'omniauth-twitter'
require 'pry'
require 'json'
require_relative 'lib/auidrome'

EM.run do
  class App < Sinatra::Base
    include Auidrome
    set :bind, '0.0.0.0'
    use Rack::Logger
    use Rack::Session::Cookie,
      :key => 'rack.session',
      :domain => ENV['AUIDROME_DOMAIN'] || 'localhost',
      :path => '/',
      :expire_after => 3600, # In seconds
      :secret => ENV['CONSUMER_SECRET']
    use Rack::Flash

    def self.config
      @@config ||= Auidrome::Config.new(ARGV[0])
    end

    def self.save_json! hash
      File.open(PUBLIC_TUITS_DIR + "/#{hash[:auido]}.json","w") do |f|
        if config.pretty_json?
          f.write JSON.pretty_generate(hash)
        else
          f.write hash.to_json
        end
      end
    end

    def drome
      @drome ||= Auidrome::Drome.new(App)
    end

    configure :production do
      if ENV['AUIDROME_DOMAIN']
        set(:base_domain, ENV['AUIDROME_DOMAIN'])
      else
        raise "ENV[AUIDROME_DOMAIN] must be set in production"
      end
    end

    configure :development do
      set :base_domain, 'localhost'
    end

    configure do
      puts "AUIDROME: listening with #{App.config.site_name} in #{App.config.url}"
      if App.config.pretty_json?
        puts "Generating pretty JSON."
      end

      puts "Using ENV['CONSUMER_KEY'] and ENV['CONSUMER_SECRET'] for Twitter auth."
      use OmniAuth::Builder do
        provider :twitter, ENV['CONSUMER_KEY'], ENV['CONSUMER_SECRET']
      end
    end

    helpers do
      def logger
        request.logger
      end

      def current_user
        # e.g. "twitter/colgado" or "github/nando" (or nil)
        if session[:provider] && session[session[:provider]]
          "#{session[:provider]}/#{session[session[:provider]]}"
        end
      end

      def file_request?
        request.path_info =~ /\/(?:images)|(?:favicon\.ico$)/
      end

      def title
        @title ||= [
          App.config.site_name,
          @page_title || App.config.site_tagline
        ].join(': ')
      end

      def me_or_by_me_button_text
        App.config.drome_of_humans? ? "It's me!" : "By me"
      end

      def amadrinate_or_authorship_button_text
        App.config.drome_of_humans? ? "Amadrinate" : "By others"
      end

      def pretty?
        App.config.pretty_json? || params[:pretty]
      end

      def get_property_name_from_referrer 
      # TODO: From the port number, vía config yml's, the dromename & from
      #   the config/drome_property_mappings.yml get the possible names.
        $1 if request.referrer and request.referrer =~ /:(\d+)/
      end

      def get_value_from_referrer 
        CGI.unescape($1) if request.referrer and request.referrer =~ /\/([^\/]+)$/
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
      piido = params[:piido]
      puts (current_user || 'Somebody') + " has shouted: ¡¡¡#{piido}!!!"
      current_tuits = Auidrome::Tuit.current_stored_tuits
      if current_tuits[piido] 
        # The piído is in our tuits.json but we still don't know anything about madrinos.
        amadrinated_at = nil
      else
        # We assume current_user exist, so the piido will be "amadrinated" right now.
        amadrinated_at = Time.now.utc
        current_tuits[piido] = amadrinated_at
        Auidrome::Tuit.store_these current_tuits
      end

      if current_user # piído + madrino = (it used to mean) human!!!
        Auidrome::Drome.add_madrino! piido, current_user
        if amadrinated_at
          msg = 'Great, at last <strong>'+piido+'</strong> is here and amadrinated <strong>by you</strong>. Thanks!'
        else
          msg = "We've added you as madrino of <strong>"+piido+"</strong>, thanks!"
        end
        return_to 'tuits/' + piido, msg
      else
        piido_link = %@<a href="/tuits/#{piido}">#{piido}</a>@
        if amadrinated_at
          msg = piido_link + ' is now between us, but <strong>WITH NO MADRINOS</strong> :(...'
        else
          msg = 'We already knew '+piido_link+". Notice you're NOT currently logged."
        end
        return_to '/', '<span class="warning">'+msg+'</span>'
      end
    end

    get "/tuits/:auido.json" do
      content_type :'application/json'
      tuit = drome.basic_jsonld_for(params[:auido])
      App.save_json! tuit # if we're here file is not there
      if pretty?
        JSON.pretty_generate tuit
      else
        tuit.to_json
      end
    end

    get '/json-context.json' do
      content_type :'application/json'
      @ports = {}
      @properties = Auidrome::Config.properties_with_drome.inject({}) do |h, (k,v)|
        @ports[v.site_name] ||= v.port_base
        h[k] = v.site_name;
        h
      end

      yml = YAML.load_file('config/json_context.json.yml')
      yml['auido'].gsub! '{{site_name}}', App.config.site_name
      yml['auido'].gsub! '{{item_description}}', App.config.item_description
      yml['dromes_ports'] = @ports
      yml['property_mappings'] = @properties

      pretty? ? JSON.pretty_generate(yml) : yml
    end

    get "/tuits/better/:auido" do
      @page_title = params[:auido]
      @drome_entry = drome.load_json(params[:auido], current_user, 1) # depth => 1
      erb :tuit
    end

    get "/tuits/:auido" do
      @page_title = params[:auido]
      @drome_entry = drome.load_json(params[:auido], current_user) # depth => 0
      erb :tuit
    end

    get "/admin" do
      erb :admin
    end

    get "/admin/its-me/:auido" do
      auido = params['auido']
      entry = Auidrome::Drome.new(App)
      entry.load_json auido
      if entry.indentity.include? current_user
        msg = '<span class="warning">Yes, we already knew that! :)</span>.'
      else
        entry.add_identity! current_user 
        msg = "Added <strong>#{current_user}</strong> as identity/author of <strong>" + auido + '</strong>.'
      end
      return_to 'tuits/' + auido, msg
    end

    get "/admin/amadrinate/:auido" do
      auido = params['auido']
      entry = drome.load_json(auido)
      if entry.madrino.include? current_user
        msg = '<span class="warning">You already was madrino of <strong>' + auido + '</strong></span>.'
      else
        entry.add_madrino! current_user 
        msg = "Now you are a madrino of <strong>" + auido + '</strong>. GREAT!!!'
      end
      return_to 'tuits/' + auido, msg
    end

    post '/admin/property/:auido' do
      auido = params['auido']
      property_name = params['property_name'] #.downcase'd be nice, but not ready for latin chars yet (e.g. "vía")
      entry = Auidrome::Drome.new(App)
      entry.load_json auido
      if entry.properties.include? property_name
        msg = '<span class="warning">One more value for ' + auido + "'s " + property_name
      else
        msg = 'Now we know something about ' + auido + "'s " + property_name
      end
      entry.add_value! property_name, params['property_value']
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
