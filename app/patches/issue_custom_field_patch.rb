require_dependency 'issue_custom_field'

module SerialNumberField
  module IssueCustomFieldPatch
    extend ActiveSupport::Concern

    def validate_custom_field
      super

      invalid_message = l('activerecord.errors.messages.invalid')
      if errors[:regexp].include?(invalid_message) && field_format == SerialNumberField::Format::NAME
        regexp_error_messages = errors[:regexp].clone

        errors.delete(:regexp)
        regexp_error_messages.each do |regexp_error_message|
          errors[:regexp] = regexp_error_message unless regexp_error_message == invalid_message
        end
      end
    end

  end
end

SerialNumberField::IssueCustomFieldPatch.tap do |mod|
  IssueCustomField.send :prepend, mod unless IssueCustomField.include?(mod)
end
