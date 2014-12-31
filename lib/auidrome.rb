module Auidrome
  TUITS_DIR = 'public/tuits'
  TUITS_FILE = 'public/tuits.json'
  CORE_ATTRIBUTES = %w{created_at auido identities madrinos}
  HREF_ATTRIBUTES = %w{page blog photos videos code media status linkedin wikipedia}
end
require_relative 'auidrome/config.rb'
require_relative 'auidrome/tuit.rb'
require_relative 'auidrome/human.rb'
