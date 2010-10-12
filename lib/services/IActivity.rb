# require './defaultDriver.rb'

module Active
  module Services

    class IActivity

      attr_accessor

      attr_accessor :title, :url, :categories, :address, :start_date, :start_time, :end_time, :end_date, :category, :desc,
      :asset_id, :asset_type_id, :data

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
  
end
