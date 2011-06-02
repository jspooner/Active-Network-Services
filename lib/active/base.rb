module Active
  
  class Base
    
    attr_accessor :options
    
    def initialize(options={})
      @options = {
        :s => "relevance",
        :f => options[:facet]
      }
    end
    
    def self.find(asset_ids=nil)
      raise Active::RecordNotFound, "Couldn't find Asset without an ID" if asset_ids.nil?
      Object.new
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

    
    # We have several different types of data in the Search index.  To restrict a search to a particular type, use the facet parameter.  The available values are:
    #     activities - things like running events or camps
    #     results - race results from results.active.com
    #     training - training plans
    #     articles - articles on active.com and ihoops.com
    def facet=(v)
      @options[:f] = v
    end
    def facet
      @options[:f]
    end
    
    def to_query
      "http://search.active.com/search?" + URI.escape(@options.collect{|k,v| "#{k}=#{v}"}.join('&'))
    end
          
    class << self
      [:sort, :order, :limit, :per_page, :page].each do |method_name|
        define_method(method_name) do |val|
          self.new.send(method_name, val)
        end
      end
    end
    
  end
end