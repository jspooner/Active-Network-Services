module Active
  
  class Asset
    
    include Active::QueryMethods
    extend Active::QueryMethods::ClassMethods
    
    include Active::FinderMethods
    extend Active::FinderMethods::ClassMethods
    
    attr_accessor :options, :data
    
    def initialize(data={}, options={})
      @options = {
        :s => "relevance",
        :v => "json"
      }
      @options[:f] = options[:facet] if options[:facet]
    end
    
  end
end
