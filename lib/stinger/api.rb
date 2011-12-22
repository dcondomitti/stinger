module Stinger
  class API
    attr_accessor :options

    def self.options
      {
        :url => 'https://ems.premiercellar.com/api/xmlrpc/index.php'
      }
    end

    def initialize(options = {})
      @options = options.reverse_merge(self.class.options)
    end

    def execute(method, data)
      request = HTTParty.post(options[:url], :body => {:data => build_xml(method, data)})
      handle_response(request)
    end

    def handle_response(response)
      body = Hash.from_xml(response.body).recursive_symbolize_keys!.fetch(:methodResponse, {}).fetch(:item, nil)
      # Handle all the bad things
      errors = []
      errors.push 'API request failed.' unless response.code.to_i == 200 && !body.nil?
      errors.push 'Can currently handle only one response at a time.' if body.is_a? Array
      errors.push body[:responseText] if body[:error].to_i == 1
      return {:error => errors.join("\n\n")} if errors.any?

      # Ah, and now for the good things
      body[:responseText] = body[:responseText].fetch(:item, []).join(', ') if body[:responseText].is_a? Hash
      return {:data => body[:responseData], :success => body[:responseText]}
    end

    private
      def build_xml(method, data)
        require 'builder'

        xml = Builder::XmlMarkup.new
        xml.api {
          xml.authentication {
            xml.api_key options[:brand].blue_hornet_api_key
            xml.shared_secret options[:brand].blue_hornet_shared_secret
            xml.response_type 'xml'
          }
          xml.data {
            xml.methodCall {
              xml.methodName method
              recursively_convert_data_to_xml(xml, data)
            }
          }
        }
        return xml.target!
      end

      def recursively_convert_data_to_xml(xml, hash)
        hash.each do |key,value|
          # At current we can only assume an array is going to be a collection.
          if value.is_a? Array
            xml.tag!(key) do
              value.each do |item|
                xml.tag!(key.to_s.singularize) do
                  recursively_convert_data_to_xml(xml, item)
                end
              end
            end
          elsif value.is_a? Hash
            xml.tag!(key) do
              recursively_convert_data_to_xml(xml, value)
            end
          else
            xml.tag!(key, value)
          end
        end
      end
  end
end
