module FlattrRest

  class User < Amodel
    attr_accessor :user_id, :username, :description, :thingcount, :language
    def self.from_node(node)
      prms = auto_parse(node,[:username, :language])
      user_id = safe_parse('id',node)
      prms[:user_id] = user_id.to_i if user_id
      self.new(prms)
    end
  end

end
