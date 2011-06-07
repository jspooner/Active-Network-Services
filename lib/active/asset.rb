require 'hashie'
module Active
  class Asset
    
    extend Active::FinderMethods::ClassMethods
    
    attr_reader :data
    
    def initialize(data)
      @data = Hashie::Mash.new(data)
    end
    
    def method_missing(m, *args, &block)  
      puts "There's no method called #{m.to_s} here -- please try again."
        return @data.send(m.to_s, args, &block)
    end
    
    def title
      # data.title.gsub...
      @data.title
    end
    
    def to_json
      @data.to_json
    end
    
    class << self
      [:sort, :order, :limit, :per_page, :page].each do |method_name|
        define_method(method_name) do |val|
          Active::Query.new(:facet => self.facet).send(method_name, val)
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
