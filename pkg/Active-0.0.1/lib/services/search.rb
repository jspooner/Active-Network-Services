require 'net/http'
require 'json'
require 'cgi'
require 'rubygems'
require 'mysql' 
require 'active_record'

module Active
  module Services
    
    class Sort
      def self.DATE_ASC 
        "date_asc"
      end
      def self.DATE_DESC
        "date_desc"
      end
      def self.RELEVANCE
        "relevance"
      end
    end
    
    class Facet
      def self.ACTIVITIES
        "activities"
      end
    end
    

    
    class Search
      # attr_accessor :location, :category, :channels, :daterange, :keywords, :radius, :limit, :sort, :page, :offset,
      #               :asset_type_id, :api_key, :num_results, :view, :facet, :sort
      # 
      SEARCH_URL      = "http://search.active.com"
      DEFAULT_TIMEOUT = 5
      # @page           = 1
      # @num_results    = 10
      # @api_key        = ""
      # @location       = "San Diego, CA, US"
      # @view           = "json"
      # @facet          = Facet.ACTIVITIES
      # @sort           = Sort.DATE_ASC
      
      # http://developer.active.com/docs/Activecom_Search_API_Reference
      # 
      def self.search(data=nil)
        searchurl         = URI.parse(construct_url(data))
        req               = Net::HTTP::Get.new(searchurl.path)
        http              = Net::HTTP.new(searchurl.host, searchurl.port)
        http.read_timeout = DEFAULT_TIMEOUT

        res = http.start { |http|
          http.get("#{searchurl.path}?#{searchurl.query}")
        }
        
        if res.code == '200'
          parsed_json = JSON.parse(res.body)
          parsed_json['_results'].collect { |a| Activity.new(a) }          
        else
          raise RuntimeError, "Active Search responded with a #{res.code} for your query."
        end
      end
      
      def self.construct_url(arg_options={})
        options = {
          :api_key => "",
          :view => "json",
          :facet => Facet.ACTIVITIES,
          :sort => Sort.DATE_ASC,
          :radius => "10",
          :meta => "",
          :num_results => "10",
          :page => "1",
          :location => "",
          :search => "",
          :keywords => [],
          :channels => nil,
          :start_date => "today",
          :end_date => "+"
        }
        options.merge!(arg_options)
        
        options[:location] = CGI.escape(options[:location]) if options[:location]
        
        if options[:keywords].class == String
          options[:keywords] = options[:keywords].split(",")
          options[:keywords].each { |k| k.strip! }
        end
        
        channels_str = "" 
               
        if options[:channels] != nil          
          channels_a = options[:channels].collect { |channel|
            "meta:channel=#{URI.escape(URI.escape(channel, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]")),Regexp.new("[^#{URI::PATTERN::UNRESERVED}]")).gsub(/\-/,"%252D")}"            
          }
        end

        meta_data  = ""
        meta_data  = channels_a.join("+OR+") if channels_a

        meta_data += "+AND+" unless meta_data == ""
        if options[:start_date].class == Date
          options[:start_date] = URI.escape(options[:start_date].strftime("%m/%d/%Y")).gsub(/\//,"%2F")
        end

        if options[:end_date].class == Date
          options[:end_date] = URI.escape(options[:end_date].strftime("%m/%d/%Y")).gsub(/\//,"%2F")
        end
        meta_data += "meta:startDate:daterange:#{options[:start_date]}..#{options[:end_date]}"

        # 
        # if @asset_type_id!=nil
        #   @meta = @meta + "+AND+" if @meta!=""
        #   @meta = @meta + "inmeta:assetTypeId=#{@asset_type_id}" 
        # end
        # 
        url = "#{SEARCH_URL}/search?api_key=#{options[:api_key]}&num=#{options[:num_results]}&page=#{options[:page]}&l=#{options[:location]}&f=#{options[:facet]}&v=#{options[:view]}&r=#{options[:radius]}&s=#{options[:sort]}&k=#{options[:keywords].join("+")}&m=#{meta_data}"
        puts url
        url
      end
      
      
      
      
    end
  end
end