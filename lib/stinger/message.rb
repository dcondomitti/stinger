module Stinger
  class Message
    attr_reader :credentials, :api

    def initialize(credentials)
      @credentials = credentials
      @api = Stinger::API.new(:credentials => credentials)
    end

    def metrics(*args)
      options = args.extract_options!.delete_if{|k,v| ![:start_date, :end_date, :date, :last].include?(k) }
      message_id = args.first.to_i if args.length==1 && !args.first.to_i.zero?

      unless message_id
        api.execute('legacy.message_stats', options)
      else
        api.execute('legacy.message_stats', {:mess_id => message_id})
      end
    end
  end
end
