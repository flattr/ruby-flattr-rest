module FlattrRest
  class Base

    @@default_params = {
        :site => 'https://api.flattr.com',
        :authorize_path => '/oauth/authenticate',
        :callback_url => 'http://localhost',
        :key => nil,
        :sescret => nil,
        :api_version => "0.0.1",
        :debug => false,
        :logger => nil #Rails.logger
    }

    attr_accessor :secret,
                  :key,
                  :site,
                  :callback_url,
                  :logger,
                  :errors,
                  :authorize_path,
                  :request_token,
                  :access_token,
                  :api_version,
                  :debug,
                  :oauth_token,
                  :oauth_token_secret,
                  :oauth_verifier



    def initialize( params = {} )
      if defined?(Rails)
        params[:logger] = Rails.logger unless params[:logger]
      end
      params = @@default_params.merge(params)
      params.each do |k, v|
        self.instance_variable_set("@#{k}".to_sym, v) if v
      end
      @consumer = OAuth::Consumer.new(
        key,
        secret,
        :site => site,
        :authorize_path => authorize_path
      )
    end

    def request_token
      @request_token ||= @consumer.get_request_token(:oauth_callback => self.callback_url)
    end

    def access_token
      unless @access_token
        if @access_token_params
          @access_token = OAuth::AccessToken.from_hash(@consumer, @access_token_params)
        else
          @access_token = request_token.access_token(:oauth_verifier => self.oauth_verifier)
        end
      end
      @access_token
    end

    def access_token_params
      unless @access_token
        access_token
      end
      {:oauth_token => @access_token.token, :oauth_token_secret => @access_token.secret}
    end

    def authorize_url
      request_token.authorize_url
    end

    def user_info user_id = 'me'
      unless user_id.eql? 'me'
        user_id = "get/id/#{user_id}"
      end
        resp = get "/user/#{user_id}"
      parse_response(resp.body,'user')
    end

    def user_things
      things
    end

    def categories 
      resp = get '/feed/categories'
      parse_response(resp.body,'categories')
    end

    def languages
      resp = get '/feed/languages'
      parse_response(resp.body,'languages')
    end

    def things( params = {} )
      if params.empty?
        resp = get "/thing/listbyuser/id/"
        parse_response(resp.body, "things")
      elsif params[:user_id]
        resp = get "/thing/listbyuser/id/#{params[:user_id]}"
        parse_response(resp.body, "things")
      elsif params[:id]
        resp = get "/thing/get/id/#{params[:id]}"
        parse_response(resp.body, "thing")
      else
        raise FlattrRest::Exception, "could not determine which path to get"
      end
    end

    def get( path )
      resp = access_token.get "/rest/#{api_version}#{path}"
      logger.info "get #{path} resulted in #{resp.class}: #{resp.body}" if debug?
      resp
    end

    def parse_response( xml_string, parse_type )
      begin
        doc = Nokogiri::XML.parse(xml_string)
      rescue
        raise FlattrRest::Exception, "unable to parse response"
      end

      result = nil
      case parse_type
      when 'user'
        User.from_node doc.xpath('flattr/user').first

      when 'thing'
        Thing.from_node doc.xpath("flattr/thing").first

      when 'things'
        doc.xpath("flattr/thing").collect do |node|
          Thing.from_node node
        end

      when 'languages'
        doc.xpath("flattr/languages/language").collect do |node|
          Language.from_node node
        end

      when 'categories'
        doc.xpath("flattr/categories/category").collect do |node|
          Category.from_node node
        end

      else
        raise FlattrRest::Exception, "unable to reconize the parse_type"
      end
    end

    def debug?
      self.debug
    end

  end

end
