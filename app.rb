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
      @@config ||= Config.new(ARGV[0])
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
      @drome ||= Drome.new(App)
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

      def referrer_could_be_a_property_value?
        request.referrer != request.url and
        request.referrer != App.config.url and
        (request.referrer =~ /\/better\//).nil? and (request.url =~ /\/better\//).nil? and
        (request.referrer =~ /\/search\?/).nil?
      end

      def get_property_name_from_referrer 
        if referrer_could_be_a_property_value?
          $1 if request.referrer and request.referrer =~ /:(\d+)/
        end
      end

      def get_value_from_referrer 
        if referrer_could_be_a_property_value?
          CGI.unescape($1) if request.referrer and request.referrer =~ /\/([^\/]+)$/
        end
      end

      def warning_span text
        '<span class="warning">' + text + '</span>'
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

    def render_tuit_view image_quality
      @image_quality = image_quality
      @page_title = params[:auido]
      @drome_entry = drome.load_json(params[:auido], current_user, image_quality)
      @property_names_for_autocomplete = Config.property_names_with_associated_drome.map{|p| {value: p}}
      erb :tuit
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
      array = Tuit.current_stored_tuits.to_a
      size = array.length
      @pages = ((size - 1) / TUITS_PER_PAGE.to_f).to_i + 1
      @page = [[params[:page].to_i, 1].max, @pages].min
      from = size - TUITS_PER_PAGE * @page
      to = from + TUITS_PER_PAGE - 1
      tuits = array[([from, 0].max)..to]
      @tuits_submitted = Hash[tuits].invert.to_json
      erb :index
    end

    post "/tuits" do
      piido = params[:piido].strip.to_sym
      puts (current_user || 'Somebody') + " has shouted: ¡¡¡#{piido}!!!"
      current_tuits = Tuit.current_stored_tuits
      if current_tuits[piido] 
        # The piído is in our tuits.json but we still don't know anything about madrinos.
        amadrinated_at = nil
      else
        # We assume current_user exist, so the piido will be "amadrinated" right now.
        amadrinated_at = Time.now.utc
        current_tuits[piido] = amadrinated_at
        Tuit.store_these current_tuits
      end

      piido_link = %@<a href="/tuits/#{piido}">#{piido}</a>@
      if amadrinated_at
        msg = piido_link + ' is now between us!'
      else
        msg = 'We already knew '+piido_link+", thanks!"
      end
      return_to '/', msg
    end

    get "/tuits/:auido.json" do
      auido = params[:auido].to_sym
      if Tuit.exists? auido
        content_type :'application/json'
        tuit = drome.basic_jsonld_for(auido)
        App.save_json! tuit # if we're here then the JSON file is not there
        if pretty?
          JSON.pretty_generate tuit
        else
          tuit.to_json
        end
      elsif App.config.drome_of_humans? and # i'm from the anti-if-campaign but
            drome = People.drome_for(auido) # let's do this only for humans :D
        redirect to(Config.drome(drome).url + request.path)
      else
        raise Sinatra::NotFound
      end
    end

    get '/json-context.json' do
      content_type :'application/json'
      @ports = {}
      @properties = Config.properties_with_drome.inject({}) do |h, (k,v)|
        @ports[v.dromename] ||= v.port_base
        h[k] = v.dromename;
        h
      end

      yml = YAML.load_file('config/json_context.json.yml')
      yml['drome_name'] = App.config.site_name
      yml['drome_item_name'] = App.config.item_name
      yml['drome_item_description'] = App.config.item_description
      yml['dromes_ports'] = @ports
      yml['property_mappings'] = @properties

      pretty? ? JSON.pretty_generate(yml) : yml
    end

    # Search tuits with params[:query] in their auidos/names
    # For example:
    #   $ curl localhost:3003/search.json?query=ALEX
    get "/search.?:format?" do
      if @query = (params[:query]  || params[:piido]) and Auidrome::Search.searchable_text?(@query)
        search = Auidrome::Search.new(@query, App)
        if search.results.any?
          if params[:format] == 'json'
            content_type :'application/json'
            JSON.pretty_generate search.payload
          else
            @search_payload = search.payload.to_json
            erb :index
          end
        else
          raise Sinatra::NotFound
        end
      else
        raise Sinatra::NotFound
      end
    end

    get "/tuits/better/better/better/:auido" do
      render_tuit_view 3 
    end

    get "/tuits/better/better/:auido" do
      render_tuit_view 2 
    end

    get "/tuits/better/:auido" do
      render_tuit_view 1 
    end

    get "/tuits/:auido" do
      render_tuit_view 0 
    end

    get "/admin" do
      erb :admin
    end

    get "/admin/its-me/:auido" do
      auido = params['auido']
      entry = drome.load_json auido
      if entry.identity.include? current_user
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
      auido = params['auido'].to_sym
      unless Tuit.exists?(auido) # Right now then!
        current_tuits = Tuit.current_stored_tuits
        current_tuits[auido] = Time.now.utc
        Tuit.store_these current_tuits
      end
      property_name = params['property_name'].strip.to_sym
      entry = Drome.new(App)
      entry.load_json auido
      if entry.properties.include? property_name
        msg = warning_span("One more value for #{auido}'s #{property_name}")
      else
        msg = "Now we know something about #{auido}'s #{property_name}"
      end
      entry.add_value! property_name, params['property_value']
      return_to "tuits/#{auido}", msg
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

    ws.onmessage do |auido|
      puts "WebSocket#onmessage: #{auido}"
      if Auidrome::Search.searchable_text? auido
        search = Auidrome::Search.new(auido, App)
        ws.send(search.payload.to_json)
      end
    end
  end

  App.run! :port => App.config.port_base
end
