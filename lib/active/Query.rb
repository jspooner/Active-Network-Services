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
        :v => 'json'
      }
    end
        
    def page(value)
      v = value || 1
      raise Active::InvalidOption if v <= 0
      @options[:page] = v
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
    
    def bounding_box(box)
      latitude1  = box[:sw].split(",").first.to_f+90
      latitude2  = box[:ne].split(",").first.to_f+90
      longitude1 = box[:sw].split(",").last.to_f+180
      longitude2 = box[:ne].split(",").last.to_f+180      
      options[:meta][:latitudeShifted]  = "#{latitude1}..#{latitude2}"
      options[:meta][:longitudeShifted] = "#{longitude1}..#{longitude2}"
      self
    end
        
    [:location, :state, :city, :category, :channel, :splitMediaType, :zip, :dma].each do |method_name|
      define_method(method_name) do |val|
        options[:meta][method_name] ||= []
        if val.kind_of?(Array)
          options[:meta][method_name] += val
        elsif val.kind_of?(Hash)
          options[:meta].merge!(val)
        else
          options[:meta][method_name] << val
        end
        return self
      end
    end
    alias zips zip
    
    def to_query
      opts = @options.deep_copy
      
      # Extract :meta and turn it into a single string for :m
      # Nested options inside meta get joined as OR
      # Top-level options get joined with AND
      opts[:m] = opts[:meta].collect{ |k,v|
        if v.kind_of?(Array)
          # Second-level options get joined with OR
          v.collect do |v2| 
            if k == :assetId
              "meta:#{k}=#{single_encode(v2)}"
            else              
              "meta:#{k}=#{double_encode(v2)}"
            end            
          end.join('+OR+')
        else
          if k == :latitudeShifted or k == :longitudeShifted
            double_encode("meta:#{k}:#{v}") # WTF  encode the : ? and we don't have to encode it for assetId?
          else
            "meta:#{k}=#{double_encode(v)}"
          end
        end
      }
      # opts[:m] << double_encode("meta:latitudeShifted:127.695141..127.695141+AND+meta:longitudeShifted:56.986343..56.986343")
      
      opts[:m] << double_encode("meta:startDate:daterange:01-01-2000..")
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
      @a   ||= []
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
