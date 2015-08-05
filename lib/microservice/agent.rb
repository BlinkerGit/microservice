module Microservice
  class Agent # Based on the Blinker Gateway REST Adapter, originally by Jeff Bennett.

    VERBS_WITH_PARAMS    = %i(post put)
    VERBS_WITHOUT_PARAMS = %i(get head delete options)

    attr_accessor :encoding    # :json, :xml, :none
    attr_accessor :auth        # :url_token, :url_auth, :basic, :none
    attr_accessor :wrap        # true, false
    attr_accessor :mode        # :rest (:soap not yet implemented)
    attr_accessor :source      # just a name
    attr_accessor :version     # just a string

    attr_accessor :base_url
    attr_accessor :last

    # when auth_method == :url_token
    attr_accessor :auth_key
    attr_accessor :auth_token

    # when auth_method == :url_auth || :basic
    attr_accessor :username
    attr_accessor :password

    def initialize( **options )
      @source   = options[ :source     ].try(:to_s)   || ''
      @version  = options[ :version    ].try(:to_s)   || ''
      @base_url = options[ :url        ].try(:to_s)   or raise ArgumentError.new('No URL in configuration')
      @auth     = options[ :auth       ].try(:to_sym) || :none
      @encoding = options[ :encoding   ].try(:to_sym) || :none
      @mode     = options[ :mode       ].try(:to_sym) || :rest
      @last     = {}
      @wrap     = !!options[ :wrap_errors  ]
      if url_auth? || basic_auth?
        @username   = options[ :username   ] || ''
        @password   = options[ :password   ] || ''
      elsif token_auth?
        @auth_key   = options[ :auth_key   ] || 'auth'
        @auth_token = options[ :auth_token ] || ''
      end
    end

    (VERBS_WITH_PARAMS + VERBS_WITHOUT_PARAMS).each do |v|
      define_method v do |args = {}, headers = {}|
        format( fetch( v, args, headers ) )
      end
    end

    private

    def fetch( method, args = {}, headers = {} )
      last[ String === args ? :body : :params ] = args
      last[ :url      ] = assemble_url( ( method == :get && Hash === args ) ? args : {} )
      last[ :headers  ] = assemble_headers( headers )
      last[ :response ] = begin
        case method
        when *VERBS_WITH_PARAMS    then ::RestClient.send( method, last[:url], args, last[:headers] )
        when *VERBS_WITHOUT_PARAMS then ::RestClient.send( method, last[:url],       last[:headers] )
        else nil
        end
      rescue ::RestClient::Exception => e
        e
      end
      last[ :code     ] = last[ :response ].try( ::RestClient::Exception === last[ :response ] ? :http_code : :code )
      last[ :response ]
    end

    def assemble_url( args = {} )
      result = base_url.dup
      args   = args.merge({ auth_key => auth_token }) if token_auth?
      result = "#{result}#{result.include?('?') ? '&' : '?'}#{URI.encode_www_form(args)}" if args.present?
      result.insert( result.index('://')+3, "#{ERB::Util.url_encode username}:#{ERB::Util.url_encode password}@" ) if url_auth?
      result
    end

    def assemble_headers( headers = {} )
      base = ( encoding == :none ? {} : {'Content-Type' => "application/#{encoding}", 'Accept' => "application/#{encoding}"} )
      auth_headers = basic_auth? ? { 'Authorization' => "Basic #{Base64.encode64( "#{username}:#{password}" ).chomp}" } : {}
      base.merge( headers.merge( auth_headers ) )
    end

    def format( response )
      return response if !response || response.is_a?( ::RestClient::Exception )
      case encoding
      when :json then JSON.parse(   response ).tap{ |r| symbolize_keys_deep!( r ) }
      when :xml  then Nokogiri.XML( response ).tap{ |r| symbolize_keys_deep!( r ) }
      else response
      end
    end

    def symbolize_keys_deep!(h)
      if h.kind_of? Array
        h.each do |k|
          symbolize_keys_deep! k
        end
      elsif h.kind_of?(Hash)
        h.keys.each do |k|
          ks    = k.respond_to?(:to_sym) ? k.to_sym : k
          h[ks] = h.delete k # Preserve order even when k == ks
          symbolize_keys_deep! h[ks] if h[ks].kind_of?(Hash) || h[ks].kind_of?(Array)
        end
      end
    end

    def token_auth?
      auth == :url_token
    end

    def url_auth?
      auth == :url_auth
    end

    def basic_auth?
      auth == :basic
    end

  end
end
