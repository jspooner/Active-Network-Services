module Active
  module Services

    class ActivityFindError < StandardError; end

    class Activity < IActivity
      REG_CENTER_ASSET_TYPE_ID="EA4E860A-9DCD-4DAA-A7CA-4A77AD194F65"
      REG_CENTER_ASSET_TYPE_ID2="3BF82BBE-CF88-4E8C-A56F-78F5CE87E4C6"
      ACTIVE_WORKS_ASSET_TYPE_ID="DFAA997A-D591-44CA-9FB7-BF4A4C8984F1"

      attr_accessor :primary, :gsa, :ats
      
      # data is a GSA object              
      def initialize(data)
        if data.respond_to?(:source)
          @ats     = data if data.source == :ats
          @gsa     = data if data.source == :gsa
          @primary = data if data.source == :primary
          
          @asset_id = @ats.asset_id if @ats!=nil
          @asset_id = @gsa.asset_id if @gsa!=nil
          @asset_id = @primary.asset_id if @primary!=nil

          @ats = ATS.find_by_id(@asset_id) if @ats==nil
      		@gsa = Search.search({:asset_id=>@asset_id, :start_date=>"01/01/2000"}).results.first if @gsa==nil

          if @primary==nil
            if @ats.asset_type_id==REG_CENTER_ASSET_TYPE_ID ||  @ats.asset_type_id==REG_CENTER_ASSET_TYPE_ID2
              @primary= RegCenter.find_by_id(@ats.substitutionUrl)
            elsif @ats.asset_type_id==ACTIVE_WORKS_ASSET_TYPE_ID
              @primary= ActiveWorks.find_by_id(@ats.substitutionUrl)
            end
          end


        end
      end

      
      def asset_id=(value)        
        @asset_id = (value.class==Array) ? value[0] : value
      end

      def title
        return @primary.title unless @primary.nil?
        return @ats.title     unless @ats.nil?
        return @gsa.title     unless @gsa.nil?
        return @title if @title
        return ""
      end

      def asset_type_id
        return @primary.asset_type_id unless @primary.nil?
        return @ats.asset_type_id     unless @ats.nil?
        return @gsa.asset_type_id     unless @gsa.nil?
        return @asset_type_id      if @asset_type_id
        return nil
      end

      def url
        #prefer seo a2 url first, then non seo a2 url, then primary url
        sources = [@ats,@primary,@gsa]
        sources.each do |source|
          return source.url if source.url.downcase.index("www.active.com") && !source.url.downcase.index("detail")
        end
        sources.each do |source|
          return source.url if source.url.downcase.index("www.active.com")
        end
            
        return @primary.url unless @primary.nil?
        return @ats.url     unless @ats.nil?
        return @gsa.url     unless @gsa.nil?
        return @url      if @url
        return nil
      end

      def categories
        return @primary.categories unless @primary.nil?
        return @ats.categories     unless @ats.nil?
        return @gsa.categories     unless @gsa.nil?
        return @categories      if @categories
        return []
      end

      def asset_id
        return @primary.asset_id unless @primary.nil?
        return @ats.asset_id     unless @ats.nil?
        return @gsa.asset_id     unless @gsa.nil?
        return @asset_id      if @asset_id
        return nil
      end

      def primary_category
        return @primary.primary_category unless @primary.nil?
        return @ats.primary_category     unless @ats.nil?
        return @gsa.primary_category     unless @gsa.nil?
        return @primary_category      if @primary_category
        return categories.first
      end

      def address
        return @primary.address unless @primary.nil?
        return @ats.address     unless @ats.nil?
        return @gsa.address     unless @gsa.nil?
        return @address      if @address
        return nil
      end

      def start_date
        return @primary.start_date unless @primary.nil?
        return @ats.start_date     unless @ats.nil?
        return @gsa.start_date     unless @gsa.nil?
        return @start_date      if @start_date
        return nil
      end

      def start_time
        return @primary.start_time unless @primary.nil?
        return @ats.start_time     unless @ats.nil?
        return @gsa.start_time     unless @gsa.nil?
        return @start_time      if @start_time
        return nil
      end

      def end_date
        return @primary.end_date unless @primary.nil?
        return @ats.end_date     unless @ats.nil?
        return @gsa.end_date     unless @gsa.nil?
        return @end_date      if @end_date
        return nil
      end

      def end_time
        return @primary.end_time unless @primary.nil?
        return @ats.end_time     unless @ats.nil?
        return @gsa.end_time     unless @gsa.nil?
        return @end_time      if @end_date
        return nil
      end

      def category
        return @primary.category unless @primary.nil?
        return @ats.category     unless @ats.nil?
        return @gsa.category     unless @gsa.nil?
        return @category      if @category
        primary_category
      end

      def contact_name
        return @primary.contact_name unless @primary.nil?
        return @ats.contact_name     unless @ats.nil?
        return @gsa.contact_name     unless @gsa.nil?
        return @contact_name      if @contact_name
        return nil
      end

      def contact_email
        return @primary.contact_email unless @primary.nil?
        return @ats.contact_email     unless @ats.nil?
        return @gsa.contact_email     unless @gsa.nil?
        return @contact_email      if @contact_email
        return nil
      end

      def desc
        return @primary.desc unless @primary.nil?
        return @ats.desc     unless @ats.nil?
        return @gsa.desc     unless @gsa.nil?
        return @desc      if @desc
        return nil
      end
      
      def substitutionUrl
        return @primary.substitutionUrl unless @primary.nil?
        return @ats.substitutionUrl     unless @ats.nil?
        return @gsa.substitutionUrl     unless @gsa.nil?
        return @substitutionUrl      if @substitutionUrl
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