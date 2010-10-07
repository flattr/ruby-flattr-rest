module FlattrRest

  class Language < Model
    attr_accessor :language_id, :name
    def self.from_node(node)
      prms = auto_parse(node,[:id, :name])
      prms[:language_id] = prms[:id]
      self.new(prms)
    end
  end

end
