module Microservice
  class Dsl

    SINATRA_VERBS = %i(get post put patch delete options link unlink).freeze

    def initialize( name, version = nil, config = {} )
      raise ArgumentError.new( 'Must provide a service name' ) unless name && name.length > 0
      Microservice::Server.agent = Microservice::Agent.new( **{ mode: :rest, source: name, version: version }.merge( config ) )
    end

    def on( verb, route, &block )
      raise ArgumentError.new( "Invalid verb: #{verb.inspect}" ) unless SINATRA_VERBS.include?( verb.to_sym )
      Microservice::Server.send( verb, route ) do
        Microservice::Response.new( Microservice::Server.agent, params ).instance_eval( &block ).to_s
      end
    end

  end
end


