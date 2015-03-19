module SerialNumberField
  class Format < Redmine::FieldFormat::Base
    NAME = 'serial_number'

    add NAME
    self.searchable_supported = true
    self.customized_class_names = %w(Issue)
    self.form_partial = 'custom_fields/formats/serial_number'

    LIST = {
      :'yyyy' => '%Y',
      :'yy' => '%y',
      :'YYYY' => 'TODO: financial_year',
      :'YY' => 'TODO: financial_year'
    }

    def validate_custom_field(custom_field)
      value = custom_field.regexp
      errors = []
      errors << [:regexp, :end_must_numeric_format_in_serial_number] unless value =~ /\{\d+\}\Z/
      value.scan(/\{(.+?)\}/).flatten.each do |format_value|
        unless format_value =~ /\A\d+\Z/
          errors << [:regexp, :invalid_format_in_serial_number] unless LIST.stringify_keys.keys.include?(format_value)
        end
      end

      errors.uniq
    end

    def generate_value(datetime)
      # TODO
      # "foo".rjust(10, "*")
      # "09".next # => "10"
    end

  end
end
