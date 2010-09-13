module Active
  module Services
    class Activity
      attr_accessor :title, :url, :categories, :address, :start_date, :start_time, :end_time, :end_date, :category, :desc,
                    :asset_id, :asset_type_id,  :data

      def initialize data
        @data      = HashWithIndifferentAccess.new(data)  
        self.title = @data[:title]
        @url       = @data[:url]
  
        unless @data[:meta].nil?  
          @url               = @data[:meta][:seourl]        if @data[:meta][:seourl]
          @url               = @data[:meta][:trackbackurl]  if @data[:meta][:trackbackurl]      
          self.asset_id      = @data[:meta][:assetId]      
          self.asset_type_id = @data[:meta][:assetTypeId]      
          @start_date        = Date.parse(@data[:meta][:startDate]) if @data[:meta][:startDate]    
          @end_date          = Date.parse(@data[:meta][:endDate])  if @data[:meta][:endDate]
          self.categories    = @data[:meta][:channel] 
          
          @desc                        = @data[:meta][:description]  ||= ""
          @start_time                  = @data[:meta][:startTime]    ||= ""
          @end_time                    = @data[:meta][:endTime]      ||= ""
          @address = {
            :name    => @data[:meta][:locationName],
            :address => @data[:meta][:location],
            :city    => @data[:meta][:city],
            :state   => @data[:meta][:state],
            :zip     => @data[:meta][:zip],
            :lat     => @data[:meta][:latitude],
            :lng     => @data[:meta][:longitude],
            :country => @data[:meta][:country]
          }
          @onlineDonationAvailable     = @data[:meta][:onlineDonationAvailable]
          @onlineRegistrationAvailable = @data[:meta][:onlineRegistrationAvailable]
          @onlineMembershipAvailable   = @data[:meta][:onlineMembershipAvailable]
        end

      end
      
      def title=(value)
        return unless value
        @title = value.gsub(/<\/?[^>]*>/, "") 
        if value.include?("|")
          @title = @title.split("|")[0].strip!
        end
      end
      
      def asset_id=(value)        
        @asset_id = (value.class==Array) ? value[0] : value
      end
      
    end
  end
end