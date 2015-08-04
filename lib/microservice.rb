require 'sinatra' unless defined? Sinatra
require 'rest_client'
require 'activesupport/json_encoder'
require 'nokogiri'
require 'envied'

configure{ set :server, :puma }

module Microservice
  class << self
    def build( name, **options, &block )
      Microservice::Dsl.new( name, options ).instance_eval( &block )
    end
  end
end

ActiveSupport.encode_big_decimal_as_string = false
ENVied.require

Dir.glob( "#{File.dirname(__FILE__)}/#{File.basename(__FILE__,'.rb')}/*.rb" ){ |lib| require lib }


# Microservice.build({
#   url:      'http://foo.com/api/endpoint',
#   encoding: :json,
#   auth:     :basic,
#   password: ENVied.PASSWORD,
#   username: ENVied.USERNAME,
#   errors:   :wrap,
# }) do
#
#   on :get, '/:frim/:fram' do
#     post({ oss: params[:frim], fay: params[:fram] }) do |response|
#       payload[ :quux ] = response[ :shifafa ]
#     end
#   end
#
# end
