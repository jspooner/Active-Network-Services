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
    
    [:category, :channel, :splitMediaType].each do |method_name|
      define_method(method_name) do |val|
        options[:meta][method_name] ||= []
        if val.kind_of?(Array)
          options[:meta][method_name] += val
        else
          options[:meta][method_name] << val
        end
        return self
      end
    end

    def to_query
      # TODO: Figure out why URI.espace works but CGI.escape does not
      
      # Add in the date range.
      opts = @options.deep_copy
      opts[:meta][:startDate] = "daterange:01-01-2000.."
      
      # Extract :meta and turn it into a single string for :m
      # Nested options inside meta get joined as OR
      # Top-level options get joined with AND
      opts[:m] = opts[:meta].collect{ |k,v|
        if v.kind_of?(Array)
          # Second-level options get joined with OR
          v.collect{ |v2| "meta:#{k}=#{v2}" }.join('+OR+')
        else
          "meta:#{k}:#{v}"
        end
      }.join('+AND+')
      opts.delete(:meta)
      opts.delete_if { |k, v| v.nil? || v.to_s.empty? } # Remove all blank keys
      "http://search.active.com/search?" + URI.escape(opts.collect{|k,v| "#{k}=#{v}"}.join('&'))
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
    
  end
end
