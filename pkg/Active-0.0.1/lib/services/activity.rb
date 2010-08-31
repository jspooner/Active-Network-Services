module Active
  module Services
    class Activity
      attr_accessor :title, :address, :start_date, :start_time, :end_time, :end_date, :category, :desc
      def initialize data
        data = HashWithIndifferentAccess.new(data)  
        @title = data[:title]

        unless data[:meta].nil?        
          @start_date                  = Date.parse(data[:meta][:startDate])    
          @end_date                    = Date.parse(data[:meta][:endDate])  if data[:meta][:endDate]
          @category                    = data[:meta][:channel]      ||= ""
          @desc                        = data[:meta][:description]  ||= ""
          @start_time                  = data[:meta][:startTime]    ||= ""
          @end_time                    = data[:meta][:endTime]      ||= ""
          @address = {
            :name    => data[:meta][:location],
            # # :address => data[:meta][''],          || ""   ,
            :city    => data[:meta][:city],
            :state   => data[:meta][:state],
            :zip     => data[:meta][:zip],
            :lat     => data[:meta][:latitude],
            :lng     => data[:meta][:longitude],
            :country => data[:meta][:country]
          }
        end
        @onlineDonationAvailable     = data[:meta][:onlineDonationAvailable]
        @onlineRegistrationAvailable = data[:meta][:onlineRegistrationAvailable]
        @onlineMembershipAvailable   = data[:meta][:onlineMembershipAvailable]

      end
    end
  end
end