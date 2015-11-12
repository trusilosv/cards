require 'paperclip'
require 'cards/models/cards_base'
require 'cards/models/card'
require 'cards/models/card_version'
require 'cards/models/file_attachment'
require 'cards/models/tag'
require 'cards/models/tagging'

Paperclip::Attachment.default_options.merge!(
  :path => ":rails_root/public/system/:attachment/:id/:style/:basename.:extension",
  :url => "/system/:attachment/:id/:style/:basename.:extension"
)

module Cards
  module Models

  end
end