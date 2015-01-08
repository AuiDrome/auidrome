module Auidrome
  TUITS_FILE = 'public/tuits.json'
  PUBLIC_TUITS_DIR = 'public/tuits'
  PROTECTED_TUITS_DIR = 'data/protected/auidrome/tuits'
  PRIVATE_TUITS_DIR = 'data/private/auidrome/tuits'
  CORE_ATTRIBUTES = %w{created_at auido identities madrinos}
  HREF_ATTRIBUTES = %w{web page blog photos videos code sound media status linkedin wikipedia}
end
require_relative 'auidrome/config.rb'
require_relative 'auidrome/tuit.rb'
require_relative 'auidrome/human.rb'
require_relative 'auidrome/access_level.rb'
