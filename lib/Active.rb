require 'active/version'
require 'ext/hash_extensions.rb'

module Active
  # require files in order!
  [
    :finder_methods, :query_methods, :errors, :query, :asset,
    :activity, :article, :result, :training
  ].each do |constant|
    require "active/#{constant.to_s}"
  end
end
