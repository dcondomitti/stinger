module Stinger
  class Subscriber
    attr_reader :credentials, :api

    def initialize(credentials)
      @credentials = credentials
      @api = Stinger::API.new(:credentials => credentials)
    end

    def add(subscriber)
      api.execute('legacy.manage_subscriber', subscriber)
    end
  end
end
