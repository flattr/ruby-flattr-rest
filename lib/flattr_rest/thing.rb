module FlattrRest

  class Thing < Model
    attr_accessor :thing_id, :created_at, :language, :url, :title, :story, :user, :category

    def self.from_node(node)
      prms = auto_parse(node,[:language,:url,:title,:story])
      unless prms.empty?
        prms[:created_at] = safe_parse('created',node)
        prms[:thing_id] = safe_parse('id',node)
        prms[:category] = Category.from_node(node.xpath('category').first)
        self.new prms
      end
    end

  end

end
