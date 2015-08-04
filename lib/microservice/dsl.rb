module Microservice
  class Dsl

    def initialize( name, config )
      @name  = name
      @agent = Microservice::Agent.new( **{ mode: :rest }.merge( config ) )
    end

    def on( verb, route, &block )
      Microservice::Server.send( verb, route ) do
        Microservice::Response.new( @name, @agent ).instance_eval( &block ).to_s
      end
    end

  end
end


