# Copyright 2015 The Cocktail Experience
module Auidrome
  TUITS_FILE = 'public/tuits.json'
  PUBLIC_TUITS_DIR = 'public/tuits'
  PROTECTED_TUITS_DIR = 'data/protected/auidrome/tuits'
  PRIVATE_TUITS_DIR = 'data/private/auidrome/tuits'
  CORE_PROPERTIES = %w{created_at auido identities madrinos}
  HREF_PROPERTIES = %w{
    web
    page
    blog
    photo
    video
    code
    sound
    media
    status
    linkedin
    wikipedia
    featuring
    tel.
  }
  # Protocols to build HREFs ('http://' if omitted)
  PROTOCOLS = {
    'tel.' => 'tel:'
  }
  # Templates to build HREFs
  PROPERTY_VALUE_TEMPLATES = {
    twitter: "http://twitter.com/{{value}}"
  }

end
require_relative 'auidrome/config.rb'
require_relative 'auidrome/tuit.rb'
require_relative 'auidrome/human.rb'
require_relative 'auidrome/access_level.rb'
