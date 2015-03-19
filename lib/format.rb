module SerialNumberField
  class Format < Redmine::FieldFormat::Base
    NAME = 'serial_number'

    add NAME
    self.searchable_supported = true
    self.customized_class_names = %w(Issue)
    self.form_partial = 'custom_fields/formats/serial_number'

    LIST = {
      :'yyyy' => { :strftime => '%Y' },
      :'yy' => { :strftime => '%y' },
      :'YYYY' => { :strftime => '%Y', :financial_year => true },
      :'YY' => { :strftime => '%y', :financial_year => true }
    }

    def validate_custom_field(custom_field)
      value = custom_field.regexp
      errors = []
      # TODO DRY
      errors << [:regexp, :end_must_numeric_format_in_serial_number] unless value =~ /\{0+\}\Z/
      value.gsub(/\{(.+?)\}/) do |format_value_with_brace|
        format_value = $1.clone
        unless format_value =~ /\A0+\Z/
          errors << [:regexp, :invalid_format_in_serial_number] unless LIST.stringify_keys.keys.include?(format_value)
        end
      end

      errors.uniq
    end

    def generate_value(custom_field, issue)
      value = custom_field.custom_values.where(
        customized_id: issue.project.issues.map(&:id)).maximum(:value)

      if value.present?
        value = value.next
      else
        # TODO DRY
        datetime = issue.created_on || DateTime.now
        value = custom_field.regexp.gsub(/\{(.+?)\}/) do |format_value_with_brace|
          format_value = $1.clone
          if LIST.stringify_keys.keys.include?(format_value)
            parse_date_time_format(format_value, datetime)
          else
            parse_number_format(format_value)
          end
        end
      end

      value
    end

    private

      def parse_date_time_format(format_value, datetime)
        parse_conf = LIST[format_value.to_sym]
        if parse_conf.key?(:financial_year) && parse_conf[:financial_year]
          datetime = datetime.beginning_of_financial_year
        end

        datetime.strftime(parse_conf[:strftime])
      end

      def parse_number_format(format_value)
        '1'.rjust(format_value.size, '0')
      end

  end
end
