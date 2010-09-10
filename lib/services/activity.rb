module Active
  module Services
    class Activity
      attr_accessor :title, :url, :category, :address, :start_date, :start_time, :end_time, :end_date, :category, :desc,
                    :asset_id, :asset_type_id,  :data, :endIndex, :pageSize, :searchTime, :numberOfResults
      def initialize data
        @data      = HashWithIndifferentAccess.new(data)  
        self.title = @data[:title]
        @url       = @data[:url]
        @pageSize = @data[:pageSize]
        @searchTime = @data[:searchTime]
        @numberOfResults = @data[:numberOfResults]
  
        unless @data[:meta].nil?  
          self.asset_id = @data[:meta][:assetId]      
          self.asset_type_id = @data[:meta][:assetTypeId]      
          @start_date   = Date.parse(@data[:meta][:startDate])    
          @end_date     = Date.parse(@data[:meta][:endDate])  if @data[:meta][:endDate]
          self.category = @data[:meta][:channel]      ||= ""
          
          @desc                        = @data[:meta][:description]  ||= ""
          @start_time                  = @data[:meta][:startTime]    ||= ""
          @end_time                    = @data[:meta][:endTime]      ||= ""
          @address = {
            :name    => @data[:meta][:locationName],
            :address    => @data[:meta][:location],
            :city    => @data[:meta][:city],
            :state   => @data[:meta][:state],
            :zip     => @data[:meta][:zip],
            :lat     => @data[:meta][:latitude],
            :lng     => @data[:meta][:longitude],
            :country => @data[:meta][:country]
            
            # dma?
            
          }
        end
        @onlineDonationAvailable     = @data[:meta][:onlineDonationAvailable]
        @onlineRegistrationAvailable = @data[:meta][:onlineRegistrationAvailable]
        @onlineMembershipAvailable   = @data[:meta][:onlineMembershipAvailable]

      end
      
      def title=(value)
        @title = value.gsub(/<\/?[^>]*>/, "") 
        if value.include?("|")
          @title = @title.split("|")[0].strip!
        end
      end
      
      # TODO add many channels
      def category=(value)
        @category = (value.class == Array) ? value[0] : value
      end
      
      def asset_id=(value)        
        @asset_id = (value.class==Array) ? value[0] : value
      end
      
    end
  end
end