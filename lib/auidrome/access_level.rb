# Copyright 2015 The Cocktail Experience
require 'json'
module Auidrome
  class AccessLevel
    def self.pedaler? identity
      !Auidrome::People.pedalers[identity.to_sym].nil?
    end
    def self.can_read_protected? reader, public_data
      pedaler?(reader) || public_data['madrino'].include?(reader) rescue false
    end
    def self.can_read_private? reader, public_data
      public_data['identity'].include?(reader) rescue false
    end
  end
end
