module Active
  
  class Asset
    
    include Active::QueryMethods
    extend Active::QueryMethods::ClassMethods
    
    attr_accessor :options
    
    def initialize(options={})
      @options = {
        :s => "relevance",
        :v => "json"
      }
      @options[:f] = options[:facet] if options[:facet]
    end
    
    def self.find(asset_ids=nil)
      raise Active::RecordNotFound, "Couldn't find Asset without an ID" if asset_ids.nil?
      finder = self.new
      ids = asset_ids.kind_of?(Array) ? asset_ids : [asset_ids]
      meta_data = []
      ids.each do |id|
        meta_data << "meta:assetId=#{id.gsub("-","%2d")}"
      end
      
      finder.options[:m] = meta_data.join('+OR+')
      finder.search
      Object.new
    end
    
  end
end
