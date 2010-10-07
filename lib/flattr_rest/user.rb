module FlattrRest

  class User < Model
    @@fields = [
      :username,:description,:thingcount, :country,:city, :email,
      :language,:firstname,:lastname,:description, :gravatar
    ]
    attr_accessor :user_id, :username, :description, :thingcount, :gravatar, :email,
                  :city, :country, :language, :firstname, :lastname,:description

    def self.from_node(node)
      prms = auto_parse(node,@@fields)
      user_id = safe_parse('id',node)
      prms[:user_id] = user_id.to_i if user_id
      self.new(prms)
    end
  end

end
