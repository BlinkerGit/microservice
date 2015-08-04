module Microservice
  class Dsl

    def initialize( name, config )
      Microservice::Server.agent = Microservice::Agent.new( **{ mode: :rest, source: name }.merge( config ) )
    end

    def on( verb, route, &block )
      Microservice::Server.send( verb, route ) do
        Microservice::Response.new( Microservice::Server.agent, params ).instance_eval( &block ).to_s
      end
    end

  end
end


