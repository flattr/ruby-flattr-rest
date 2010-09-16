module FlattrRest

  class Thing < Amodel
    attr_accessor :thing_id, :created_at, :language, :url, :title, :story, :user, :category

    def self.from_node(node)
      prms = auto_parse(node,[:language,:url,:title,:story])
      unless prms.empty?
        prms[:created_at] = safe_parse('created',node)
        thing_id = safe_parse('id',node)
        prms[:thing_id] = thing_id.to_i if thing_id 
        self.new prms
      end
    end

  end

end
