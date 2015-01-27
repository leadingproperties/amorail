require 'active_model'

module Amorail
  class AmoEntity

    include ActiveModel::Model
    include ActiveModel::AttributeMethods
    include ActiveModel::Validations

    attr_accessor :url

    def initialize(attributes={})
      super
      @client = Amorail.client
    end

    def self.attr_accessor(*vars)
      @attributes ||= []
      @attributes.concat vars
      super(*vars)
    end

    def request_attributes
      {}
    end

    def self.attributes
      @attributes
    end

    def attributes
      attrs = {}
      self.attributes_list.each { |a| attrs[a] = self.send(a) } 
      attrs
    end

    def attributes_list
      self.class.attributes
    end

    def client
      @client
    end

    def save
      if valid?
        begin
          create
        rescue AmoUnauthorizedError => e 
          client.authorize
          create
        end
      else
        false
      end
    end

    def save!
      if valid?
        response = client.post(url, request_attributes)
        true if response.status == 200 or response.status == 204
      else
        false
      end
    end

    def create
      response = client.post(url, request_attributes)
      if response.status == 200 or response.status == 204
        reload_model(response.body["response"])
        true
      else
        false
      end
    end

    # override this method for Amo<Any> class

    def reload_model(response)
    end

  end
end