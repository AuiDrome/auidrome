require 'json'
module Auidrome
  class Tuit
      def self.store_these tuits
        File.open(TUITS_FILE,"w") do |f|
          f.write(tuits.to_json)
        end 
      end
    
      def self.current_stored_tuits
        if File.file?(TUITS_FILE)
          JSON.parse(File.read(TUITS_FILE))
        else
          {}
        end
      end

      def self.read_from_index_file auido
        {
          'created_at' => Tuit.current_stored_tuits[auido] || 'NOT FOUND!?!?',
          'auido' => auido
        }
      end

      def self.read_json(filepath)
        File.exists?(filepath) ? JSON.parse(File.read(filepath)) : {}
      end
  end
end
