require 'spec_helper'
require 'logger'

require '.credentials.rb' # should define the FLATTR_CONFIG hash.

describe FlattrRest do
  before do
    log = Logger.new STDOUT
    log.level = Logger::DEBUG
    @config = {
      :key => FLATTR_CONFIG[:key],
      :secret => FLATTR_CONFIG[:secret],
      :site => FLATTR_CONFIG[:site],
      :debug => true,
      :logger => log
    }
    @access_token_params = {
      :oauth_token => FLATTR_CONFIG[:access_token],
      :oauth_token_secret => FLATTR_CONFIG[:access_secret]
    }
    @sample_xml = {
      :user_info  => File.read("spec/sample_data/user_info.xml"),
      :one_thing  => File.read("spec/sample_data/one_thing.xml"),
      :things     => File.read("spec/sample_data/things.xml"),
      :categories => File.read("spec/sample_data/categories.xml"),
      :languages  => File.read("spec/sample_data/languages.xml")
    }
  end

  describe "basic functionality" do
    it "should have default params set" do
      client = FlattrRest::Base.new :key => 'default'
      client.site.should eql 'https://api.flattr.com'
      client.key.should eql 'default'
    end

  end

  describe "basic oauth stuff" do
    it "should be able to get a authorize_url" do
      client = FlattrRest::Base.new(
        :key => @config[:key],
        :secret => @config[:secret],
        :site => @config[:site],
        :logger => @config[:logger],
        :debug => @config[:debug],
        :callback_url => 'http://flattr-rb.local/new'
      )
      client.site.should eql 'http://api.flattr.local'
      client.callback_url.should eql 'http://flattr-rb.local/new'
      client.authorize_url.should =~ /http:\/\/api.flattr.local\/oauth\/authenticate\?oauth_token=/
    end
  end

  describe "access token creation" do
    it "should have an access token." do
      client = FlattrRest::Base.new(
        :key => @config[:key],
        :secret => @config[:secret],
        :site => @config[:site],
        :logger => @config[:logger],
        :callback_url => 'http://flattr-rb.local/new',
        :access_token_params => @access_token_params
      )
      client.access_token.token.should_not be_nil
      client.access_token.secret.should_not be_nil
    end
  end

  describe "parsing resource xml strings" do
    before do
      @client = FlattrRest::Base.new @config
    end
    it "should parse user_info.xml" do
      result = @client.parse_response(@sample_xml[:user_info],'user')
      result.should be_a_kind_of FlattrRest::User
      result.user_id.should eql(2)
      result.language.should eql('en_GB')
      result.thingcount.should eql("2")
      result.country.should eql("St. Pierre and Miquelon")
      result.username.should eql('someusername')
      result.firstname.should eql('some_firstname')
      result.lastname.should eql('some_lastname')
      result.description.should eql('description of the user.')
      result.email.should eql('some@email')
      result.gravatar.should =~ /https:\/\/secure.gravatar.com\/avatar/
    end

    it "should parse a thing" do
      result = @client.parse_response(@sample_xml[:one_thing],'thing')
      result.should be_a_kind_of FlattrRest::Thing
      result.url.should eql 'http://developers.flattr.net'
      result.title.should eql 'The flattr developer site'
      result.story.should eql 'The developer corner for flattr integration developers.'
      result.category.category_id.should eql 'rest'
    end

    it "should parse many things" do
      result = @client.parse_response(@sample_xml[:things],'things')
      result.should be_a_kind_of Array
      result.first.should be_a_kind_of FlattrRest::Thing
      result.first.url.should eql('http://developers.flattr.net')
      result.first.thing_id.should eql('e01957d12b703d8fa1e186e7f52c7ff7')
      result.first.story.should eql('The developer corner for flattr integration developers.')
      result.first.category.name.should eql('The rest')
    end

    it "should parse categories" do
      result = @client.parse_response(@sample_xml[:categories],'categories')
      result.should be_a_kind_of Array
      result.first.should be_a_kind_of FlattrRest::Category
      result.first.category_id.should eql("text")
      result.first.name.should eql("Written text")
    end

    it "should parse languages" do
      result = @client.parse_response(@sample_xml[:languages],'languages')
      result.should be_a_kind_of Array
      result.first.should be_a_kind_of FlattrRest::Language
      result.first.language_id.should eql("sq_AL")
      result.first.name.should eql("Albanian")
    end

  end
end
