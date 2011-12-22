module Stinger
  class TransactionalMessage
    attr_reader :credentials, :api

    def initialize(credentials)
      @credentials = credentials
      @api = Stinger::API.new(:credentials => credentials)
    end

    def send(data)
      api.execute('transactional.sendTransaction', data)
    end
  end
end
