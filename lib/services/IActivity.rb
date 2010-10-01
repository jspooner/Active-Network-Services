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

        returnAddress["zip"] = Validators.valid_zip(returnAddress["zip"])
        returnAddress["state"] = Validators.valid_state(returnAddress["state"])

        # ensure no nil
        returnAddress.keys.each do |key|
          returnAddress[key] = "" if returnAddress[key].nil?
        end
        returnAddress
      end

      def source
        raise StandardError, "You must override this method"
      end

    end

  end


  class Validators

    STATES = [
      [ "Alabama", "AL" ],
      [ "Alaska", "AK" ],
      [ "Arizona", "AZ" ],
      [ "Arkansas", "AR" ],
      [ "California", "CA" ],
      [ "Colorado", "CO" ],
      [ "Connecticut", "CT" ],
      [ "Delaware", "DE" ],
      [ "District Of Columbia", "DC" ],
      [ "Florida", "FL" ],
      [ "Georgia", "GA" ],
      [ "Hawaii", "HI" ],
      [ "Idaho", "ID" ],
      [ "Illinois", "IL" ],
      [ "Indiana", "IN" ],
      [ "Iowa", "IA" ],
      [ "Kansas", "KS" ],
      [ "Kentucky", "KY" ],
      [ "Louisiana", "LA" ],
      [ "Maine", "ME" ],
      [ "Maryland", "MD" ],
      [ "Massachusetts", "MA" ],
      [ "Michigan", "MI" ],
      [ "Minnesota", "MN" ],
      [ "Mississippi", "MS" ],
      [ "Missouri", "MO" ],
      [ "Montana", "MT" ],
      [ "Nebraska", "NE" ],
      [ "Nevada", "NV" ],
      [ "New Hampshire", "NH" ],
      [ "New Jersey", "NJ" ],
      [ "New Mexico", "NM" ],
      [ "New York", "NY" ],
      [ "North Carolina", "NC" ],
      [ "North Dakota", "ND" ],
      [ "Ohio", "OH" ],
      [ "Oklahoma", "OK" ],
      [ "Oregon", "OR" ],
      [ "Pennsylvania", "PA" ],
      [ "Rhode Island", "RI" ],
      [ "South Carolina", "SC" ],
      [ "South Dakota", "SD" ],
      [ "Tennessee", "TN" ],
      [ "Texas", "TX" ],
      [ "Utah", "UT" ],
      [ "Vermont", "VT" ],
      [ "Virginia", "VA" ],
      [ "Washington", "WA" ],
      [ "West Virginia", "WV" ],
      [ "Wisconsin", "WI" ],
      [ "Wyoming", "WY" ]
    ]

    def self.full_name(abbr)
      STATES.find do |i|
        if i[1] == abbr.upcase
          return i[0]
        end
      end
      return nil
    end

    def self.valid_state(name)
      STATES.find do |i|
        if i[0].upcase==name.strip.upcase
          return i[0]
        elsif i[1] == name.upcase
          return i[0]
        end
      end
      return ""
    end

    def self.valid_zip(zip)
      # (http://geekswithblogs.net/MainaD/archive/2007/12/03/117321.aspx)
      if zip!="00000" && zip.to_s.strip=~/(^\d{5}(-\d{4})?$)|(^[ABCEGHJKLMNPRSTVXY]{1}\d{1}[A-Z]{1} *\d{1}[A-Z]{1}\d{1}$)/
        zip.to_s.strip
      else
        ""
      end
    end

  end
end
