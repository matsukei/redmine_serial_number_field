require_dependency 'issue_custom_field'

module SerialNumberField
  module IssueCustomFieldPatch
    extend ActiveSupport::Concern

    included do
      unloadable

      def validate_custom_field_with_skip_regexp_valid
        validate_custom_field_without_skip_regexp_valid

        invalid_message = l('activerecord.errors.messages.invalid')
        if errors[:regexp].include?(invalid_message) && field_format == SerialNumberField::Format::NAME
          regexp_error_messages = errors[:regexp].clone

          errors.delete(:regexp)
          regexp_error_messages.each do |regexp_error_message|
            errors[:regexp] = regexp_error_message unless regexp_error_message == invalid_message
          end
        end
      end

      alias_method_chain :validate_custom_field, :skip_regexp_valid
    end

  end
end

SerialNumberField::IssueCustomFieldPatch.tap do |mod|
  IssueCustomField.send :include, mod unless IssueCustomField.include?(mod)
end
