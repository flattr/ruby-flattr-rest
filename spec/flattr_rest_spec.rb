require 'spec_helper'

describe FlattrRest do
  before do
    @config = {
      :key => "the key goes here",
      :secret => "the secret goes here",
      :site => 'http://api.flattr.local'
    }
    @sample_xml = {
      :user_info => File.read("spec/sample_data/user_info.xml"),
      :one_thing => File.read("spec/sample_data/one_thing.xml"),
      :sample_things => File.read("spec/sample_data/sample_things.xml")
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
        :callback_url => 'http://flattr-rb.local/new'
      )
      client.site.should eql 'http://api.flattr.local'
      client.callback_url.should eql 'http://flattr-rb.local/new'
      client.authorize_url.should =~ /http:\/\/api.flattr.local\/oauth\/authenticate\?oauth_token=/
    end
  end

  describe "parsing resource xml strings" do
    before do
      @client = FlattrRest::Base.new @config
    end
    it "should parse user_info.xml" do
      result = @client.parse_response(@sample_xml[:user_info])
      result.should be_a_kind_of FlattrRest::User
      result.username.should eql('test303')
      result.user_id.should eql(202)
      result.language.should eql('en_GB')
    end

    it "should parse a thing" do
      result = @client.parse_response(@sample_xml[:one_thing])
      result.should be_a_kind_of FlattrRest::Thing
      result.url.should eql 'http://developers.flattr.net'
      result.title.should eql 'The flattr developer site'
      result.story.should eql 'The developer corner for flattr integration developers.'
    end

    it "should parse many things" do
      result = @client.parse_response(@sample_xml[:sample_things])
      result.should be_a_kind_of Array
      result.first.should be_a_kind_of FlattrRest::Thing
      result.first.url.should eql('http://developers.flattr.net')
    end
  end
end
