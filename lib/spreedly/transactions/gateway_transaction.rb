module Spreedly
  class GatewayTransaction < Transaction
    field :order_id, :ip, :description, :gateway_token, :gateway_transaction_id, :email, :transaction_type
    field :merchant_name_descriptor, :merchant_location_descriptor
    field :on_test_gateway, type: :boolean

    attr_reader :response, :gateway_specific_fields, :gateway_specific_response_fields, :shipping_address

    def initialize(xml_doc)
      super
      response_xml_doc = xml_doc.at_xpath('.//response')
      shipping_address_xml_doc = xml_doc.at_xpath('.//shipping_address')
      @response = response_xml_doc ? Response.new(response_xml_doc) : nil
      @shipping_address = shipping_address_xml_doc ? ShippingAddress.new(shipping_address_xml_doc) : nil
      @gateway_specific_fields = parse_gateway_fields(xml_doc, './/gateway_specific_fields')
      @gateway_specific_response_fields = parse_gateway_fields(xml_doc, './/gateway_specific_response_fields')
    end

    def parse_gateway_fields(xml_doc, path)
      result = {}

      xml_doc.at_xpath(path).xpath('*').each do |node|
        node_name = node.name.to_sym
        if (node.elements.empty?)
          result[node_name] = node.text
        else
          node.elements.each do |childnode|
            result[node_name] ||= {}
            result[node_name][childnode.name.to_sym] = childnode.text
          end
        end
      end

      result
    end
  end
end
