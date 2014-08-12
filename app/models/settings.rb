require 'settingslogic'

class Settings < Settingslogic
  source "#{Rails.root}/config/c2_mario_constants.yml"
  namespace "constants"
end
