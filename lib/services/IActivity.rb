# require './defaultDriver.rb'

module Active
  module Services
   
   class IActivity
     
     attr_accessor 
     
     attr_accessor :title, :url, :categories, :address, :start_date, :start_time, :end_time, :end_date, :category, :desc,
                   :asset_id, :asset_type_id, :data, :contact_name, :contact_email
     
     attr_reader :asset_type_id
     
     def validated_address(address)
       #ensure a hash with the proper keys
       returnAddress = HashWithIndifferentAccess.new({ :name =>"", :address => "", :city => "", :state => "",:zip => "", :lat => "", :lng => "", :country => ""})
       returnAddress.merge!(address)
       # validations
       returnAddress
     end
     
     def source
      raise StandardError, "You must override this method"
     end
     
   end 
   
  end
end