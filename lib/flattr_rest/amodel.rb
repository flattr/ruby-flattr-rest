module FlattrRest

  class Amodel

    def initialize(params = {})
      params.each do |k, v|
        self.instance_variable_set("@#{k}".to_sym, v) if v
      end
    end

    def self.safe_parse(field, node)
      begin
        node.xpath(field).first.text.strip
      rescue
        nil
      end
    end

    def self.auto_parse(node, fields = [])
      prms = {}
      fields.each do |field|
        v = safe_parse(field.to_s,node)
        prms[field] = v if v
      end
      prms
    end

  end

end
