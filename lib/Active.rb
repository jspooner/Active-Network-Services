require 'active/version'
require 'ext/hash_extensions.rb'

module Active
  # require files in order!
  [
    :errors, :query, :asset, :results,
    :activity, :article, :result, :training
  ].each do |constant|
    require "active/#{constant.to_s}"
  end
end
