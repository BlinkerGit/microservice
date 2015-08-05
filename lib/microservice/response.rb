module Microservice
  class Response

    attr_reader   :agent
    attr_reader   :error
    attr_reader   :last
    attr_reader   :status
    attr_reader   :params
    attr_accessor :payload

    def initialize( agent, params )
      @error   = nil
      @last    = nil
      @status  = nil
      @payload = {}
      @agent   = agent
      @params  = with_indifferent_access( params )
    end

    (Agent::VERBS_WITH_PARAMS + Agent::VERBS_WITHOUT_PARAMS).each do |v|
      define_method v do |args = {}, headers = {}, &block|
        r = with_error_handling do
          @agent.send v, args, headers
        end
        @last, @status = @agent.last, @agent.last[:code]
        self.instance_exec( r, &block ) unless @error
        render
      end
    end

    def render
      to_json
    end

    def set_error( **options )
      @error = { class: nil, message: nil, backtrace: nil }.merge( options )
    end

    def as_json
      {
        source:  agent.source,
        version: agent.version,
        status:  status,
        error:   error,
        payload: payload.as_json,
      }
    end

    def to_json
      as_json.to_json
    end

    private

    def with_error_handling( &block )
      yield
    rescue => err
      raise err unless @agent.wrap
      message   = err.is_a?( StandardError ) ? err.message : err.to_s
      backtrace = err.respond_to?( :backtrace ) ? err.backtrace : nil
      set_error( class: err.class.to_s, message: message , backtrace: backtrace )
      err
    end

    def with_indifferent_access( hash )
      hash.dup.tap do |p|
        class << p
          def [](k)
            super( k.to_s )
          end
          def []=(k,v)
            super( k.to_s, v )
          end
        end
      end
    end

  end
end
