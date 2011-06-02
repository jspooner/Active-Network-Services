module Active
  
  class ActiveError < StandardError; end
  
  class RecordNotFound < ActiveError;  end
  
end