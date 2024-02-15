require 'pathname'

module SerialNumberField
  def self.root
    @root ||= Pathname.new File.expand_path('..', File.dirname(__FILE__))
  end
end

# Load patches for Redmine
Rails.configuration.to_prepare do
  Dir[SerialNumberField.root.join('app/patches/serial_number_field/**/*_patch.rb')].each { |f| require_dependency f }
end

#Dir[SerialNumberField.root.join('app/hooks/**/*_hook.rb')].each { |f| require_dependency f }
Dir[SerialNumberField.root.join('app/hooks/serial_number_field/**/*_hook.rb')].each { |f| require_relative f }
