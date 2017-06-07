module SerialNumberField

  class IssueControllerHooks < Redmine::Hook::Listener
    unloadable

    def controller_issues_bulk_edit_before_save(context = {})
      assign_serial_number(context)
    end

    def controller_issues_new_after_save(context = {})
      assign_serial_number(context)
    end

    private
      def assign_serial_number(context)
        issue = context[:issue]
        issue.assign_serial_number!
      end
  end

end
