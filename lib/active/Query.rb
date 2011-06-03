
module Active
  class Query
    
    include Active::QueryMethods::InstanceMethods
    
    attr_accessor :options
    
    def initialize(options={})
      @options = {
        :s => "relevance",
        :f => options[:facet],
        :v => 'json'
      }
    end
    
  end
end