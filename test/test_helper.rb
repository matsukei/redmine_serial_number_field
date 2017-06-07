# coding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/../../../test/test_helper')

def create_default_serial_number_field
  custom_field = IssueCustomField.create!({
    :field_format => "serial_number",
    :name => 's-n-field',
    :regexp => 'MCC-{0000}',
    :is_required =>"0",
    :is_filter => "1",
    :searchable => "1",
    :visible => "1",
    :is_for_all => "0",
    :role_ids  => []
  })

  # eCookbook
  Project.find(1).issue_custom_fields << custom_field
  # OnlineStore
  Project.find(2).issue_custom_fields << custom_field
  # Bug
  Tracker.find(1).custom_fields << custom_field

  return custom_field
end

def valid_regexp_values
  [
    '{yyyy}-{0000}', '{yy}-{0000}',
    '{YYYY}-{0000}', '{YY}-{0000}',
    '{0000}', '#{yyyy}-{00000}',
    'OCG-{yy}-{00000}', '日本語{YYYY}-{00000}',
    ' {YY}-{00000}', '!{00000}'
  ]
end

def invalid_regexp_values
  [
    '', ' ', '　', 'ABC-{000}-{yy}',
    '{abc}-{yy}-{000}', '{yy}-{00000}-OCG',
    '{YYYY}-{00000}日本語', 'hogehoge'
  ]
end
