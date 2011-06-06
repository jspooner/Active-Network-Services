require 'hashie'
module Active
  class Asset
    
    extend Active::QueryMethods::ClassMethods
    extend Active::FinderMethods::ClassMethods
    
    attr_reader :data
    
    def initialize(data)
      @data = Hashie::Mash.new(data)
    end
    
    def method_missing(m, *args, &block)  
      puts "There's no method called #{m.to_s} here -- please try again."
        return @data.call(m.to_s)
    end
    
    def title
      # data.title.gsub...
      @data.title
    end
    
    
  end
end
