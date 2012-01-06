module Stinger
  class Subscriber
    attr_reader :credentials, :api

    def initialize(credentials)
      @credentials = credentials
      @api = Stinger::API.new(:credentials => credentials)
    end

    def add(subscriber)
      @result = api.execute('legacy.manage_subscriber', subscriber)
    end

    def success?
      !@result[:error] && [1,2].include?(@result.fetch(:data, {})[:status].to_i)
    end

    def error
      return @result[:error] if @result.key?(:error)
      success? ? nil : @result[:data][:message]
    end
  end
end
