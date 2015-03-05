require_dependency 'issue'

module SerialNumberField
  module IssuePatch
    extend ActiveSupport::Concern

    def assign_serial_number!
      serial_number_fields.each do |cf|
        next if assigned_serial_number?(cf)

        CustomValue.create!(:custom_field => cf,
          :customized => self, :value => cf.generate_value(created_on || DateTime.now))
      end
    end

    def assigned_serial_number?(cf)
      CustomValue.exists?(:custom_field_id => cf.id,
        :customized_type => 'Issue',:customized_id => self.id)
    end

    def serial_number_fields
      editable_custom_fields.select do |value|
        value.field_format == SerialNumberField::Format::NAME
      end
    end

  end
end

unless Issue.included_modules.include?(SerialNumberField::IssuePatch)
  Issue.send(:include, SerialNumberField::IssuePatch)
end
