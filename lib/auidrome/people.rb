# Copyright 2015 The Cocktail Experience
require 'json'
module Auidrome
  # "auidos" in committed public/tuits.json on "human" dromes (with port number < 10000)
  class People
    class << self
      @@all = nil
      @@pedalers = {}

      # Returns a hash with :auido_as_symbol => [:array, :of, :dromenames]
      # For example:
      #  {
      #    :alejandroporras => [:byebyedrome, :pedalodrome],
      #    :olalla => [:acadodrome, :auidrome]
      #  }
      def all
        # Order matters: the former more important when calling #drome_for
        @@all ||= from_dromes \
          :byebyedrome,
          :pedalodrome,
          :lovedrome,
          :acadodrome,
          :restodrome,
          :auidrome,
          :ripodrome,
          :fictiondrome
      end

      # Returns the first (more important) drome for a given person
      def drome_for auido
        @@all[auido.to_sym].first if all[auido.to_sym]
      end

      # Returns a hash with the Twitter identities of the people in the
      # Pedalodrome associated with their name. For example:
      #   { :ander_r4 => :ANDER, ... }
      def pedalers
        if @@pedalers.empty?
          Dir.glob("#{PEDALERS_DIR}/*.json") do |path|
            auido = File.basename(path, '.json')
            identities = JSON.parse(File.read(path))['identity'] || []
            identities.each do |identity|
              @@pedalers[identity.to_sym] = auido.to_sym
            end
          end
        end
        @@pedalers
      end

    private
      def from_dromes *dromes
        {}.tap do |people|
          dromes.reverse.each do |drome|
            JSON.parse(File.read("data/public/#{drome}/tuits.json")).each do |name, created_at|
              people[name.to_sym] ||= []
              people[name.to_sym].push drome
            end
          end
        end
      end
    end
  end
end
