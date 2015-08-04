module Microservice
  class Server < Sinatra::Base
    class << self
      attr_accessor :agent
    end
  end
end
