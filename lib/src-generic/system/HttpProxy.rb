module Wiris
  class HttpProxy
    attr_accessor :port
    attr_accessor :host
    attr_accessor :auth

    def initialize(host, port)
      @port = port
      @host = host
      @auth = nil
    end

    def self.newHttpProxy(host, port, user, pass)
      proxy = HttpProxy.new(host, port)
      hpa = HttpProxyAuth.new()
      hpa.user = user
      hpa.pass = pass
      proxy.auth = hpa
      return proxy
    end

  end
end