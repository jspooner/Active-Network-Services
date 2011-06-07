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
      if @options[:m]
        @options[:m] += "+AND+meta:startDate:daterange:01-01-2000..+"
      else
        @options[:m] = "meta:startDate:daterange:01-01-2000..+"
      end
      "http://search.active.com/search?" + URI.escape(@options.collect{|k,v| "#{k}=#{v}"}.join('&'))
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
