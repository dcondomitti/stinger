module Stinger
  class API
    attr_accessor :options

    def self.options
      {
        :url => 'https://echo.bluehornet.com/api/xmlrpc/index.php',
        :credentials => {}
      }
    end

    def initialize(options = {})
      @options = options.reverse_merge(self.class.options)

      raise 'API Key and Shared Secret are required to make connection.' unless @options[:credentials].key?(:api_key) && @options[:credentials].key?(:shared_secret)
    end

    def execute(method, data)
      request = HTTParty.post(options[:url], :body => {:data => build_xml(method, data)})
      handle_response(request)
    end

    private
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

      def build_xml(method, data)
        xml = Builder::XmlMarkup.new
        xml.api {
          xml.authentication {
            xml.api_key options[:credentials][:api_key]
            xml.shared_secret options[:credentials][:shared_secret]
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
