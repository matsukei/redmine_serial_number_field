require_dependency 'issue'

module SerialNumberField
  module IssuePatch
    extend ActiveSupport::Concern
    unloadable

    def assign_serial_number!
      serial_number_fields.each do |cf|
        next if assigned_serial_number?(cf)

        target_custom_value = serial_number_custom_value(cf)
        new_serial_number = cf.format.generate_value(cf, self)

        # Unimplemented change Tracker(custom_value is nil)
        if target_custom_value.present?
          target_custom_value.update_attributes!(
            :value => new_serial_number)
        end
      end
    end

    def assigned_serial_number?(cf)
      serial_number_custom_value(cf).try(:value).present?
    end

    def serial_number_custom_value(cf)
      CustomValue.where(:custom_field_id => cf.id,
        :customized_type => 'Issue',
        :customized_id => self.id).first
    end

    def serial_number_fields
      editable_custom_fields.select do |value|
        value.field_format == SerialNumberField::Format::NAME
      end
    end

  end
end

SerialNumberField::IssuePatch.tap do |mod|
  Issue.send :include, mod unless Issue.include?(mod)
end
