# Copyright 2015 The Cocktail Experience
require 'json'
module Auidrome
  # "auidos" in committed public/tuits.json on "human" dromes (with port number < 10000)
  class People
    class << self
      @@all = nil

      def all
        # Order matters: the former more important
        @@all ||= from_dromes \
          :pedalodrome,
          :byebyedrome,
          :lovedrome,
          :acadodrome,
          :restodrome,
          :auidrome,
          :ripodrome,
          :fictiondrome
      end

      def drome_for auido
        @@all[auido.to_sym].first if all[auido.to_sym]
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
