Redmine::Plugin.register :redmine_serial_number_field do
  name 'Redmine Serial Number Field'
  author 'tachimasa & maeda-m'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  requires_redmine '2.6'
  url 'https://github.com/matsukei/redmine_serial_number_field'
  author_url 'http://www.matsukei.co.jp/'
end

require_relative 'lib/format'
require_relative 'lib/issue_controller_hooks'
