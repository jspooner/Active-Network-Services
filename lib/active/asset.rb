module Active
  class Asset
    
    extend Active::QueryMethods::ClassMethods
    
    include Active::FinderMethods
    extend Active::FinderMethods::ClassMethods
    
    attr_accessor :data ## should be an instance of our DataKlass
    
  end
end
