require 'json'
#require 'active_support/core_ext/array/conversions'

module Active::FinderMethods
  module ClassMethods
    # this code smells
    def find(asset_ids=nil)
      raise Active::InvalidOption, "Couldn't find Asset without an ID" if asset_ids.nil?
      finder    = Active::Query.new
      ids       = asset_ids.kind_of?(Array) ? asset_ids : [asset_ids]
      meta_data = []
      ids.each do |id|
        meta_data << "meta:assetId=#{id.gsub("-","%2d")}"
      end
      
      finder.options[:m] = meta_data.join('+OR+')      
      
      res = finder.search
      
      # Ensure we have found all of the IDs requested, otherwise raise an error
      # that includes which ID(s) are missing.
      if res['numberOfResults'] != ids.length
        missing_ids = Array.new(ids)
        res['_results'].each do |r|
          found_id = r['meta']['assetId'] & missing_ids
          missing_ids -= found_id
        end
        raise Active::RecordNotFound, "Couldn't find record with asset_id: #{missing_ids.join(',')}"
      end
      

      a = []
      res['_results'].collect do |d|        
        t      = self.new(d)
        a << t
      end
      
      if a.length == 1
        return a.first
      else
        return a
      end
    end
  end
end