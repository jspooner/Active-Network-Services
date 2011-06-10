
module Active
  class Results < Array
    attr_accessor :end_index, :number_of_results, :page_size, :search_time 
  end
end