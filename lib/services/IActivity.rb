# require './defaultDriver.rb'

module Active
  module Services
   
   class IActivity
     
     attr_accessor 
     
     attr_accessor :title, :url, :categories, :address, :start_date, :start_time, :end_time, :end_date, :category, :desc,
                   :asset_id, :asset_id_type, :data
     
     attr_reader :asset_type_id
     
     def source
      raise StandardError, "You must override this method"
     end
     
   end 
   
  end
end