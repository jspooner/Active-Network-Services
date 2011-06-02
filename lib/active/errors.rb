module Active
  
  class ActiveError < StandardError; end
  
  class RecordNotFound < ActiveError; end
  
  class InvalidOption < ActiveError; end
  
end