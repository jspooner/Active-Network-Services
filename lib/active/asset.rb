require 'hashie'
require 'json'

module Active
  class Asset
    
    attr_reader :data
    
    def initialize(data)
      @data = Hashie::Mash.new(data)
    end
    
    def method_missing(m, *args, &block)
      return @data.send(m.to_s, args, &block)
    end
    
    def title
      # data.title.gsub...
      @data.title
    end
    
    def to_json
      @data.to_json
    end
    
    class << self
      def factory(data)
        begin
        category = data['meta']['category']
        rescue NoMethodError
          category = nil
        end
        
        type = case category
        when 'Activities'
          Active::Activity
        when 'Articles'
          Active::Article
        when 'Training plans'
          Active::Training
        else
          Active::Asset
        end
        type.new(data)
      end
      
      # this code smells
      def find(asset_ids=nil)
        raise Active::InvalidOption, "Couldn't find Asset without an ID" if asset_ids.nil?
        query    = Active::Query.new
        ids       = asset_ids.kind_of?(Array) ? asset_ids : [asset_ids]
        query.options[:meta][:assetId] = ids.collect{ |id| id.gsub("-","%2d") }

        # Executes the actual search API call
        res = query.search

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
      
      [
        :sort, :order, :limit, :per_page, :page,
        :category, :keywords, :channel, :splitMediaType,
        :location, :state, :city, :zip, :zips, :bounding_box, :dma, :near, 
        :date_range, :future, :past, :today
      ].each do |method_name|
        define_method(method_name) do |*val|
          Active::Query.new(:facet => self.facet).send(method_name, *val)
        end
      end
      
      # We have several different types of data in the Search index.  To restrict a search to a particular type, use the facet parameter.  The available values are:
      #     activities - things like running events or camps
      #     results - race results from results.active.com
      #     training - training plans
      #     articles - articles on active.com and ihoops.com
      # This method should be overridden in child classes to return the appropriate type string.
      def facet
        ''
      end
    end
    
  end
end
