# coding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/../../../test/test_helper')

def create_default_serial_number_field
  custom_field = IssueCustomField.create!({
    :field_format => "serial_number",
    :name => 'default_sn',
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
  # Support request
  Tracker.find(3).custom_fields << custom_field

  return custom_field
end

def create_for_all_serial_number_field
  custom_field = IssueCustomField.create!({
    :field_format => "serial_number",
    :name => 'for_all_sn',
    :regexp => 'MCC-{0000}',
    :is_required =>"0",
    :is_filter => "1",
    :searchable => "1",
    :visible => "1",
    :is_for_all => "1",
    :role_ids  => []
  })
  Tracker.all.each { |tracker| tracker.custom_fields << custom_field }

  return custom_field
end

def valid_regexp_values
  [
    '{yyyy}-{0000}', '{yy}-{0000}',
    '{YYYY}-{0000}', '{YY}-{0000}',
    '{ISO}-{000}',
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

def assert_added_serial_number(issue_id, expected_value, custom_field)
  issue = Issue.find(issue_id)
  custom_value = issue.custom_values.where(
    :custom_field_id => custom_field.id).first

  assert_not_nil custom_value
  assert_equal expected_value, custom_value.value
  assert_include custom_field, issue.available_custom_fields
end

def assert_none_serial_number(issue_id, custom_field)
  issue = Issue.find(issue_id)
  custom_value = issue.custom_values.where(
    :custom_field_id => custom_field.id).first

  assert_nil custom_value
  assert_not_include custom_field, issue.available_custom_fields
end
