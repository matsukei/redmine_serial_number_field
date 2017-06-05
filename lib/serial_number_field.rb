require 'pathname'

module SerialNumberField
  def self.root
    @root ||= Pathname.new File.expand_path('..', File.dirname(__FILE__))
  end
end

# Load patches for Redmine
Rails.configuration.to_prepare do
  Dir[SerialNumberField.root.join('app/patches/**/*_patch.rb')].each { |f| require_dependency f }
end

Dir[SerialNumberField.root.join('app/hooks/**/*_hook.rb')].each { |f| require_dependency f }
