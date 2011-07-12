require 'hashie'
require 'json'

module Active
  class Asset < Hashie::Mash
    
    # * No punctuation: Returns the value of the hash for that key, or nil if none exists.
    # * Assignment (<tt>=</tt>): Sets the attribute of the given method name.
    # * Existence (<tt>?</tt>): Returns true or false depending on whether that key has been set.
    # * Bang (<tt>!</tt>): Forces the existence of this key, used for deep Mashes. Think of it as "touch" for mashes.
    #
    # == Basic Example
    #
    #   mash = Mash.new
    #   mash.name? # => false
    #   mash.name = "Bob"
    #   mash.name # => "Bob"
    #   mash.name? # => true
    #
    # == Hash Conversion  Example
    #
    #   hash = {:a => {:b => 23, :d => {:e => "abc"}}, :f => [{:g => 44, :h => 29}, 12]}
    #   mash = Mash.new(hash)
    #   mash.a.b # => 23
    #   mash.a.d.e # => "abc"
    #   mash.f.first.g # => 44
    #   mash.f.last # => 12
    #
    # == Bang Example
    #
    #   mash = Mash.new
    #   mash.author # => nil
    #   mash.author! # => <Mash>
    #
    #   mash = Mash.new
    #   mash.author!.name = "Michael Bleigh"
    #   mash.author # => <Mash name="Michael Bleigh">
    #
    def title
      return @title if @title
      if self.title?
        # Notice we have to use self['hash'] to get the original value so we don't stackoverflow
        @title = self['title']
        @title = @title.split("|")[0].strip if @title.include?("|")
        @title = @title.gsub(/<\/?[^>]*>/, "")
        @title = @title.gsub("...", "")
      end
      @title 
    end

    def start_date
      if self.meta!.startDate?
        Date.parse(self.meta.startDate)
      else
        nil
      end
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

      # Active::Activity.find_by_url("http://www.active.com#{request.fullpath}")
      # url = http://search.active.com/search?v=list&m=site:www.active.com/running/san-diego-ca/americas-finest-city-half-marathon-and-5k-2011
      def find_by_url(url)
        raise Active::InvalidOption, "Couldn't find Asset without a url" if url.nil?
        query                = Active::Query.new
        query.options[:m] << "site:#{url}"
puts "query #{query.to_query}"
        # Executes the actual search API call
        res = query.search
        if res['numberOfResults'].to_i < 1
          raise Active::RecordNotFound, "Couldn't find record with asset_id: #{url}"
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
