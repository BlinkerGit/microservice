module Microservice
  class Response

    attr_reader   :agent
    attr_reader   :error
    attr_reader   :last
    attr_reader   :source
    attr_reader   :status
    attr_accessor :payload

    def initialize( source, agent )
      @source  = source
      @agent   = agent
      @error   = nil
      @last    = nil
      @status  = nil
      @payload = {}
    end

    (Agent::VERBS_WITH_PARAMS + Agent::VERBS_WITHOUT_PARAMS).each do |v|
      define_method v do |params = {}, headers = {}, &block|
        r = with_error_handling do
          @agent.send v, params, headers
        end
        @last, @status = @agent.last, @agent.last[:code]
        self.instance_exec( r, &block ) unless @error
        self.to_json
      end
    end

    def to_json
      {
        source:  source,
        status:  status,
        error:   error,
        payload: payload.as_json,
      }.to_json
    end

    private

    def with_error_handling( &block )
      yield
    rescue => err
      raise err unless @agent.wrap
      @error = {
        class:     err.class.to_s,
        message:   err.is_a?( StandardError ) ? err.message : err.to_s,
        backtrace: err.respond_to?( :backtrace ) ? err.backtrace : nil,
      }
      err
    end

  end
end
