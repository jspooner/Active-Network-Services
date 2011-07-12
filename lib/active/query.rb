require 'net/http'
require 'json'

module Active
  class Query
    
    attr_accessor :options
    
    def initialize(options={})
      @options = {
        :s => "relevance",
        :f => options[:facet],
        :meta => {},
        :m => [],
        :v => 'json'
      }
    end
        
    def page(value=1)
      raise Active::InvalidOption if value.to_i <= 0
      @options[:page] = value
      self
    end

    def limit(value)
      @options[:num] = value
      self
    end
    alias per_page limit
      
    # s = sort
    # The default sort for results is by relevance.  The available values are:
    #     date_asc
    #     date_desc
    #     relevance
    def sort(value)
      @options[:s] = value
      self
    end
    alias order sort
    
    # LatLngBounds(sw?:LatLng, ne?:LatLng)
    # Constructs a rectangle from the points at its south-west and north-east corners.
    def bounding_box(box)
      latitude1  = box[:sw].split(",").first.to_f+90
      latitude2  = box[:ne].split(",").first.to_f+90
      longitude1 = box[:sw].split(",").last.to_f+180
      longitude2 = box[:ne].split(",").last.to_f+180      
      options[:meta][:latitudeShifted]  = "#{latitude1}..#{latitude2}"
      options[:meta][:longitudeShifted] = "#{longitude1}..#{longitude2}"
      self
    end
    
    def near(value)
      raise Active::InvalidOption unless value[:latitude] and value[:longitude] and value[:radius]
      @options[:l] = "#{value[:latitude]},#{value[:longitude]}"
      @options[:r] = value[:radius]
      self
    end

    def location(value)
      if value.kind_of?(Hash)        
        options[:meta].merge!(value)
      elsif value.kind_of?(String)
        @options[:l] = value
      end
      self
    end

    def keywords(value)
      if value.kind_of?(Array)        
        @options[:k] = value.join("+")
      elsif value.kind_of?(String)
        @options[:k] = value
      end
      self
    end
    
    def date_range(start_date,end_date)
      if start_date.class == Date
        start_date = URI.escape(start_date.strftime("%m/%d/%Y")).gsub(/\//,"%2F")
      end
      if end_date.class == Date
        end_date = URI.escape(end_date.strftime("%m/%d/%Y")).gsub(/\//,"%2F")
      end
      options[:meta][:startDate] = "daterange:#{start_date}..#{end_date}"
      self
    end
    
    def future
      options[:meta][:startDate] = "daterange:today..+"
      self
    end

    def past
      options[:meta][:startDate] = "daterange:..#{Date.today}"
      self
    end
    
    def today
      options[:meta][:startDate] = Date.today
      self
    end
        
    [:state, :city, :category, :channel, :splitMediaType, :zip, :dma].each do |method_name|
      define_method(method_name) do |val|
        
        options[:meta][method_name] ||= []
        if val.kind_of?(Array)
          options[:meta][method_name] += val
        elsif val.kind_of?(Hash)
          options[:meta].merge!(val)
        else
          options[:meta][method_name] << val
        end
         self
      end
    end
    alias zips zip
    
    def to_query
      opts = @options.deep_copy
      
      # Extract :meta and turn it into a single string for :m
      # Nested options inside meta get joined as OR
      # Top-level options get joined with AND
      opts[:m] += opts[:meta].collect { |k,v|
        next unless v 
        if v.kind_of?(Array)
          # Second-level options get joined with OR
          v.collect do |v2| 
            # clean out empty values
            if v2.nil?
              next
            elsif v2.kind_of?(String) and v2.empty?
              next
            elsif k == :assetId
              "meta:#{k}=#{single_encode(v2)}"
            else
              "meta:#{k}=#{double_encode(v2)}"
            end
          end.join('+OR+')
        else
          # these keys need meta :
          if k == :latitudeShifted or k == :longitudeShifted or k == :startDate
            # encoding works for longitudeShifted
            if k == :latitudeShifted or k == :longitudeShifted
              double_encode("meta:#{k}:#{v}") # WTF  encode the : ? and we don't have to encode it for assetId?
            else
              # encoding doesn't work for asset_id, daterange
              "meta:#{k}:#{v}"
            end
          else# these keys need meta=
            "meta:#{k}=#{double_encode(v)}"
          end
        end
      }
      
      opts[:m] << double_encode("meta:startDate:daterange:01-01-2000..") if opts[:meta][:startDate].nil?
      # clean out empty values
      opts[:m] = opts[:m].compact.reject { |s| s.nil? or s.empty? }
      opts[:m] = opts[:m].join('+AND+')      
      opts.delete(:meta)
      opts.delete_if { |k, v| v.nil? || v.to_s.empty? } # Remove all blank keys
      "http://search.active.com/search?" + opts.collect{|k,v| "#{k}=#{v}"}.join('&')
    end

    def search
      searchurl = URI.parse(to_query)
      http = Net::HTTP.new(searchurl.host, searchurl.port)
    
      res = http.start do |http|
        http.get("#{searchurl.path}?#{searchurl.query}")
      end
    
      if (200..307).include?(res.code.to_i)
# TODO HANDLE JSON PARSE ERROR
        return JSON.parse(res.body)
      else
        raise Active::ActiveError, "Active Search responded to your query with code: #{res.code}"
      end
    end
    
    def results
      return @a if @a
      @res ||= search
      @a   ||= Active::Results.new()
      # GSA will only return 1000 events but will give us a number larger then 1000.      
      @a.number_of_results = (@res['numberOfResults'] <= 1000) ? @res['numberOfResults'] : 1000
      @a.end_index         = @res['endIndex']
      @a.page_size         = @res['pageSize']
      @a.search_time       = @res['searchTime']

      @res['_results'].collect do |d|
        t = Active::Asset.factory(d)
        @a << t
      end
      @a
    end
    
    private
      # good for assetId only.. maybe
      def single_encode(str)
        str = URI.escape(str, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
        str.gsub!(/\-/,"%252D")
        str        
      end
      # good for all other values like city and state
      def double_encode(str)
        str = str.to_s
        str = URI.escape(str, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
        str = URI.escape(str, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
        str.gsub!(/\-/,"%252D")
        str
      end
    
  end
end
