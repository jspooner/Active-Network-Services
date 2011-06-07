require 'net/http'
require 'json'

module Active::QueryMethods
  
  module InstanceMethods
    
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

    def to_query
      # TODO: Figure out why URI.espace works but CGI.escape does not
      
      # Add in the date range.
      opts = @options.deep_copy
      opts[:meta][:startDate] = "daterange:01-01-2000.."
      
      # Extract :meta and turn it into a single string for :m
      # Nested options inside meta get joined as OR
      # Top-level options get joined with AND
      puts JSON.pretty_generate @options
      puts "<br>"
      opts[:m] = opts[:meta].collect{ |k,v|
        if v.kind_of?(Array)
          # Second-level options get joined with OR
          v.collect{ |v2| "meta:#{k}=#{v2}" }.join('+OR+')
        else
          "meta:#{k}:#{v}"
        end
      }.join('+AND+')
      puts JSON.pretty_generate opts
      puts "<br>"
      opts.delete(:meta)
      opts.delete_if { |k, v| v.nil? || v.to_s.empty? } # Remove all blank keys
      puts JSON.pretty_generate opts
      puts "<br>"
      puts "http://search.active.com/search?" + URI.escape(opts.collect{|k,v| "#{k}=#{v}"}.join('&'))
      puts "<br>______________<br>"
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
