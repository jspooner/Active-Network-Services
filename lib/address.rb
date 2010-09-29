module Active
  class Address
    attr_accessor  :name, :state, :city, :state, :zip, :lat, :lng, :country
    def initialize(data={})
      # need to hold on to original data
      @name = data[:name]
      @state = data[:state]
      @city = data[:city]
      @state = data[:state]
      @zip = data[:zip]
      @lat = data[:lat]
      @lng = data[:lng]
      @country = data[:country]
    end
    
  end
end

