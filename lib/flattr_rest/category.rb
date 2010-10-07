module FlattrRest

  class Category < Model
    attr_accessor :category_id, :name
    def self.from_node(node)
      prms = auto_parse(node,[:id, :name])
      prms[:category_id] = prms[:id]
      #puts "creat based on #{prms.inspect} | #{node}"
      self.new(prms)
    end
  end

end
