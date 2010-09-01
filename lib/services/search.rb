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

      def self.CHANNELS 
        {
        :corporate                                               => "corporate",
        :nochannel                                               => "nochannel",
        :action_sports                                           => "action_sports",
        :auto_racing                                             => "auto_racing",
        :baseball                                                => "baseball",
        :little_league_baseball                                  => "baseball%5Clittle_league_baseball",
        :tee_ball                                                => "baseball%5Ctee_ball",
        :littleleague                                            => "baseball%5Clittleleague",
        :basketball                                              => "basketball",
        :bmx                                                     => "bmx",
        :cheerleading                                            => "cheerleading",
        :cycling                                                 => "cycling",
        :tourofca                                                => "cycling%5Ctourofca",
        :gift_guide                                              => "cycling%5Cgift_guide",
        :dirt_bike_racing                                        => "dirt_bike_racing",
        :field_hockey                                            => "field_hockey",
        :football                                                => "football",
        :flag_football                                           => "football%5Cflag_football",
        :football_au                                             => "football%5Cfootball_au",
        :pop_warner                                              => "football%5Cpop_warner",
        :golf                                                    => "golf",
        :ice_hockey                                              => "ice_hockey",
        :lacrosse                                                => "lacrosse",
        :motocross                                               => "motocross",
        :motorcycle_racing                                       => "motorcycle_racing",
        :mountain_biking                                         => "mountain_biking",
        :outdoors                                                => "outdoors",
        :canoeing                                                => "outdoors%5Ccanoeing",
        :climbing                                                => "outdoors%5Cclimbing",
        :hiking                                                  => "outdoors%5Chiking",
        :kayaking                                                => "outdoors%5Ckayaking",
        :orienteering                                            => "outdoors%5Corienteering",
        :outrigging                                              => "outdoors%5Coutrigging",
        :rafting                                                 => "outdoors%5Crafting",
        :gift_guide                                              => "outdoors%5Cgift_guide",
        :running                                                 => "running",
        :cross_country                                           => "running%5Ccross_country",
        :track_and_field                                         => "running%5Ctrack_and_field",
        :trail_running                                           => "running%5Ctrail_running",
        :gift_guide                                              => "running%5Cgift_guide",
        :jinglebell                                              => "running%5Cjinglebell",
        :spiritofthemarathon                                     => "running%5Cspiritofthemarathon",
        :stpatricksday                                           => "running%5Cstpatricksday",
        :marathonmania                                           => "running%5Cmarathonmania",
        :newbierunners                                           => "running%5Cnewbierunners",
        :sailing                                                 => "sailing",
        :skateboarding                                           => "skateboarding",
        :skiing                                                  => "skiing",
        :skydiving                                               => "skydiving",
        :snowboarding                                            => "snowboarding",
        :snowshoeing                                             => "snowshoeing",
        :soccer                                                  => "soccer",
        :softball                                                => "softball",
        :dixie                                                   => "softball%5Cdixie",
        :fastpitch                                               => "softball%5Cfastpitch",
        :slowpitch                                               => "softball%5Cslowpitch",
        :little_league                                           => "softball%5Clittle_league",
        :surfing                                                 => "surfing",
        :swimming                                                => "swimming",
        :diving                                                  => "swimming%5Cdiving",
        :open_water_swimming                                     => "swimming%5Copen_water_swimming",
        :masters                                                 => "swimming%5Cmasters",
        :tennis                                                  => "tennis",
        :usta                                                    => "tennis%5Custa",
        :college                                                 => "tennis%5Ccollege",
        :triathlon                                               => "triathlon",
        :ironblog                                                => "triathlon%5Cironblog",
        :gift_guide                                              => "triathlon%5Cgift_guide",
        :volleyball                                              => "volleyball",
        :walking                                                 => "walking",
        :wake_kite_boarding                                      => "wake%2Fkite_boarding",
        :water_skiing                                            => "water_skiing",
        :wind_surfing                                            => "wind_surfing",
        :water_sports                                            => "water_sports",
        :more_sports                                             => "more_sports",
        :adventure_racing                                        => "more_sports%5Cadventure_racing",
        :archery                                                 => "more_sports%5Carchery",
        :badminton                                               => "more_sports%5Cbadminton",
        :billiards                                               => "more_sports%5Cbilliards",
        :bowling                                                 => "more_sports%5Cbowling",
        :cricket                                                 => "more_sports%5Ccricket",
        :croquet                                                 => "more_sports%5Ccroquet",
        :curling                                                 => "more_sports%5Ccurling",
        :dance                                                   => "more_sports%5Cdance",
        :disc_sports                                             => "more_sports%5Cdisc_sports",
        :dodgeball                                               => "more_sports%5Cdodgeball",
        :duathlon                                                => "more_sports%5Cduathlon",
        :equestrian                                              => "more_sports%5Cequestrian",
        :fencing                                                 => "more_sports%5Cfencing",
        :figure_skating                                          => "more_sports%5Cfigure_skating",
        :fishing                                                 => "more_sports%5Cfishing",
        :gymnastics                                              => "more_sports%5Cgymnastics",
        :inline_hockey                                           => "more_sports%5Cinline_hockey",
        :kickball                                                => "more_sports%5Ckickball",
        :martial_arts                                            => "more_sports%5Cmartial_arts",
        :paintball                                               => "more_sports%5Cpaintball",
        :polo                                                    => "more_sports%5Cpolo",
        :racquetball                                             => "more_sports%5Cracquetball",
        :rowing                                                  => "more_sports%5Crowing",
        :rugby                                                   => "more_sports%5Crugby",
        :scuba_diving                                            => "more_sports%5Cscuba_diving",
        :skating                                                 => "more_sports%5Cskating",
        :squash                                                  => "more_sports%5Csquash",
        :ultimate_frisbee                                        => "more_sports%5Cultimate_frisbee",
        :water_polo                                              => "more_sports%5Cwater_polo",
        :wrestling                                               => "wrestling",
        :nutrition                                               => "nutrition",
        :fitness                                                 => "fitness",
        :body_building                                           => "fitness%5Cbody_building",
        :boxing                                                  => "fitness%5Cboxing",
        :weight_lifting                                          => "fitness%5Cweight_lifting",
        :wellness                                                => "fitness%5Cwellness",
        :gymnastics_centers                                      => "fitness%5Cgymnastics_centers",
        :martial_arts_centers                                    => "fitness%5Cmartial_arts_centers",
        :massage                                                 => "fitness%5Cmassage",
        :chiropractors                                           => "fitness%5Cchiropractors",
        :therapy                                                 => "fitness%5Ctherapy",
        :travel                                                  => "travel",
        :marinas                                                 => "travel%5Cmarinas",
        :campgrounds_and_rv_parks                                => "travel%5Ccampgrounds_and_rv_parks",
        :state_muni_hunting_and_fishing_licensing                => "travel%5Cstate_muni_hunting_and_fishing_licensing",
        :boat_licensing_departments                              => "travel%5Cboat_licensing_departments",
        :lodges_bandbs_country_inns_hostels                      => "travel%5Clodges_bandbs_country_inns_hostels",
        :hotels_resorts_motels                                   => "travel%5Chotels_resorts_motels",
        :condo_rental_time_share                                 => "travel%5Ccondo_rental_time_share",
        :charters_tours                                          => "travel%5Ccharters_tours",
        :cruises                                                 => "travel%5Ccruises",
        :gear                                                    => "gear",
        :sony_gps                                                => "gear%5Csony_gps",
        :mind_and_body                                           => "mind_and_body",
        :meditation                                              => "mind_and_body%5Cmeditation",
        :pilates                                                 => "mind_and_body%5Cpilates",
        :yoga                                                    => "mind_and_body%5Cyoga",
        :women                                                   => "women",
        :gift_guide                                              => "women%5Cgift_guide",
        :fit_pregnancy                                           => "women%5Cfit_pregnancy",
        :lifestyle_vehicles                                      => "lifestyle_vehicles",
        :community_services                                      => "community_services",
        :parks_and_recs                                          => "community_services%5Cparks_and_recs",
        :private_gated_community_rec                             => "community_services%5Cprivate_gated_community_rec",
        :summer_and_day_camps                                    => "community_services%5Csummer_and_day_camps",
        :military_recreation                                     => "community_services%5Cmilitary_recreation",
        :libraries                                               => "community_services%5Clibraries",
        :business_training_professional_and_personal_development => "community_services%5Cbusiness_training_professional_and_personal_development",
        :art_music_voice_dance_acting                            => "community_services%5Cart_music_voice_dance_acting",
        :flea_markets_swap_meets                                 => "community_services%5Cflea_markets_swap_meets",
        :non_profit_services                                     => "non_profit_services",
        :ymca_jcc_boys_and_girls_clubs                           => "non_profit_services%5Cymca_jcc_boys_and_girls_clubs",
        :boy_scouts_girls_scouts                                 => "non_profit_services%5Cboy_scouts_girls_scouts",
        :religious                                               => "non_profit_services%5Creligious",
        :giving_and_fundraising                                  => "giving_and_fundraising",
        :health_and_disease                                      => "giving_and_fundraising%5Chealth_and_disease",
        :political                                               => "giving_and_fundraising%5Cpolitical",
        :environment                                             => "giving_and_fundraising%5Cenvironment",
        :faith                                                   => "giving_and_fundraising%5Cfaith",
        :animals                                                 => "giving_and_fundraising%5Canimals",
        :educational_support                                     => "giving_and_fundraising%5Ceducational_support",
        :international                                           => "giving_and_fundraising%5Cinternational",
        :other                                                   => "giving_and_fundraising%5Cother",
        :attractions                                             => "attractions",
        :aquatic_parks                                           => "attractions%5Caquatic_parks",
        :amusement_parks                                         => "attractions%5Camusement_parks",
        :zoos                                                    => "attractions%5Czoos",
        :aquariums                                               => "attractions%5Caquariums",
        :science_and_nature_centers                              => "attractions%5Cscience_and_nature_centers",
        :museums                                                 => "attractions%5Cmuseums",
        :general_admission_concerts_and_events                   => "attractions%5Cgeneral_admission_concerts_and_events",
        :ski_resorts                                             => "attractions%5Cski_resorts",
        :carnivals                                               => "attractions%5Ccarnivals",
        :miniature_golf                                          => "attractions%5Cminiature_golf",
        :education                                               => "education",
        :universities                                            => "education%5Cuniversities",
        :community_junior_colleges                               => "education%5Ccommunity_junior_colleges",
        :public_school_boards                                    => "education%5Cpublic_school_boards",
        :continuing_education_departments                        => "education%5Ccontinuing_education_departments",
        :high_schools                                            => "education%5Chigh_schools",
        :private_schools                                         => "education%5Cprivate_schools",
        :pre_schools                                             => "education%5Cpre_schools",
        :youth_academic_extracurricular                          => "education%5Cyouth_academic_extracurricular",
        :government                                              => "government",
        :city_hall                                               => "government%5Ccity_hall",
        :parking                                                 => "government%5Cparking",
        :animal_licensing                                        => "government%5Canimal_licensing",
        :municipal_business_licensing                            => "government%5Cmunicipal_business_licensing",
        :traffic_ticketing                                       => "government%5Ctraffic_ticketing",
        :utility_billing                                         => "government%5Cutility_billing",
        :building_permits                                        => "government%5Cbuilding_permits",
        :taxes                                                   => "government%5Ctaxes",
        :state_dmvs                                              => "government%5Cstate_dmvs",
        :federal_government                                      => "government%5Cfederal_government",
        :business_and_commerce                                   => "business_and_commerce",
        :corporations                                            => "business_and_commerce%5Ccorporations",
        :conferences_and_conventions                             => "business_and_commerce%5Cconferences_and_conventions",
        :affinity_groups                                         => "business_and_commerce%5Caffinity_groups",
        :counseling_therapy                                      => "business_and_commerce%5Ccounseling_therapy",
        :pet_care                                                => "business_and_commerce%5Cpet_care",
        :beauty_and_personal_care                                => "business_and_commerce%5Cbeauty_and_personal_care",
        :restaurants                                             => "business_and_commerce%5Crestaurants",
        :high_school                                             => "high_school",
        :hs_activities                                           => "high_school%5Chs_activities",
        :hs_varsity_sports_club_sports                           => "high_school%5Chs_varsity_sports_club_sports",
        :continuing_education                                    => "high_school%5Ccontinuing_education",
        :scouts                                                  => "scouts",
        :bsa                                                     => "scouts%5Cbsa",
        :gsus4h                                                  => "scouts%5Cgsus4h",
        :'4h'                                                    => "scouts%5C4h",
        :campfire                                                => "scouts%5Ccampfire",
        :sea_scouts                                              => "scouts%5Csea_scouts",
        :fccla                                                   => "scouts%5Cfccla",
        :reunions                                                => "reunions",
        :teams                                                   => "teams",
        :gift_guide                                              => "teams%5Cgift_guide",
        :golf_tennis                                             => "golf_tennis",
        :gift_guide                                              => "golf_tennis%5Cgift_guide"
        }
      end


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