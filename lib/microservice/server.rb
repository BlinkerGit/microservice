module Microservice
  class Server < Sinatra::Base

    set server: :puma
    set logging: true

    class << self
      attr_accessor :agent
    end
  end
end
