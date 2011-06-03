require 'json'

module Active::FinderMethods
  module ClassMethods
    def find(asset_ids=nil)
      raise Active::RecordNotFound, "Couldn't find Asset without an ID" if asset_ids.nil?
      finder = Active::Query.new
      ids = asset_ids.kind_of?(Array) ? asset_ids : [asset_ids]
      meta_data = []
      ids.each do |id|
        meta_data << "meta:assetId=#{id.gsub("-","%2d")}"
      end
      
      finder.options[:m] = meta_data.join('+OR+')
      
      a = self.new
      a.data = JSON.parse(finder.search)
      a
    end
  end
end
