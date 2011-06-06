
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
    
    def results
      @res ||= search
      a   = []
      @res['_results'].collect do |d|
        t = Active::Asset.new(d)
        a << t
      end
      a
    end
    
  end
end