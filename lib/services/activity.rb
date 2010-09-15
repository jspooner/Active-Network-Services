module Active
  module Services

    class ActivityFindError < StandardError; end

    class Activity < IActivity
      
      # data is a GSA object              
      def initialize(data)
        if data.respond_to?(:source)
          @ats     = data if data.source == :ats
          @gsa     = data if data.source == :gsa
          @primary = data if data.source == :primary
          return
        end
        
        @data          = HashWithIndifferentAccess.new(data)  
        self.title     = @data[:title]
        @url           = @data[:url]
        # @asset_id      = @data[:asset_id]
        # @asset_type_id = @data[:asset_type_id]
        
        unless @data[:meta].nil?  
          @url               = @data[:meta][:seourl]        if @data[:meta][:seourl]
          @url               = @data[:meta][:trackbackurl]  if @data[:meta][:trackbackurl]      
          self.asset_id      = @data[:meta][:assetId]      
          @asset_type_id     = @data[:meta][:assetTypeId]      if @asset_type_id.nil?
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
        @ats_data = {}
        @full_data = {}
      end
      
      # def asset_type_id
      #   if @asset_type_id.nil?
      #     ATS.find_by_id @asset_id
      #   end
      #   @asset_type_id
      # end
      
      def title=(value)
        return unless value
        @title = value.gsub(/<\/?[^>]*>/, "") 
        if value.include?("|")
          @title = @title.split("|")[0].strip!
        end
      end
      def title
        return @primary.title unless @primary.nil?
        return @ats.title     unless @ats.nil?
        return @gsa.title     unless @gsa.nil?
        return @title if @title
        return ""
      end
      
      def asset_id=(value)        
        @asset_id = (value.class==Array) ? value[0] : value
      end
      def asset_id
        return @primary.asset_id unless @primary.nil?
        return @ats.asset_id     unless @ats.nil?
        return @gsa.asset_id     unless @gsa.nil?
        return @asset_id      if @asset_id
        return nil
      end
      
      # Examples
      # Adding the asset type id will improve performance
      # Activity.find_by_asset_id(:asset_id => "A9EF9D79-F859-4443-A9BB-91E1833DF2D5", :asset_type_id => "EA4E860A-9DCD-4DAA-A7CA-4A77AD194F65")
      # Activity.find_by_asset_id(:asset_id => "A9EF9D79-F859-4443-A9BB-91E1833DF2D5")
      #
      def self.find_by_asset_id(data)
        if data.has_key?(:asset_id) and data.has_key?(:asset_type_id) == false
          @asset_id = data[:asset_id]
          begin
            return Activity.new(ATS.find_by_id(@asset_id))  
          rescue ATSError => e
            raise ActivityFindError, "We could not find the activity with the asset_id of #{@asset_id}"
          end
          

          
          
        elsif data.has_key?(:asset_id) and data.has_key?(:asset_type_id)
          puts "look up data form the original source"
           # TODO look up data form the original source"
          return Activity.new(ATS.find_by_id(@asset_id))  
        end
      end

      
    end
  end
end