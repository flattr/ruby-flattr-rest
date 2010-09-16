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



    def initialize(params = {})
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

    def get_request_token
      @request_token ||= @consumer.get_request_token(:oauth_callback => self.callback_url)
    end

    def get_access_token
      @access_token ||= get_request_token.get_access_token(:oauth_verifier => self.oauth_verifier)
    end

    def authorize_url
      get_request_token.authorize_url
    end

    def user_info
      resp = get '/user/me'
    end

    def user_things
      resp = things
    end

    def things(params = {})
      if params.empty?
        get "/thing/listbyuser/id/"
      elsif params[:user_id]
        get "/thing/listbyuser/id/#{params[:user_id]}"
      elsif params[:id]
        get "/thing/get/id/#{params[:id]}"
      else
        raise FlattrRest::Exception, "could not determine which path to get"
      end
    end


    def get(path)
      resp = get_access_token.get "/rest/#{api_version}#{path}"
      logger.info "get #{path} resulted in #{resp.class}: #{resp.body}" if debug?
      return parse_response(resp.body)
    end

    def parse_response(xml_string)
      doc = Nokogiri::XML.parse(xml_string)

      user_node = doc.xpath "flattr/user"
      if !user_node.empty?
        logger.info "will create a user object based on #{user_node.to_s}" if debug?
        User.from_node(user_node.first)
      else
        things = doc.xpath "flattr/thing"
        unless things.empty?
          if things.size > 1
            things.collect do |t|
              Thing.from_node(t)
            end
          else
            Thing.from_node things.first
          end
        else
          logger.info "unable to find any useful info from #{doc.to_s}" if debug?
        end
      end
    end

    def debug?
      self.debug
    end

  end

end
