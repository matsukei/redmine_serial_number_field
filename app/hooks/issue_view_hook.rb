module SerialNumberField
  class IssueViewHooks < Redmine::Hook::ViewListener
    render_on :view_issues_form_details_bottom, :partial => 'remove_serial_number_field'
    render_on :view_issues_bulk_edit_details_bottom, :partial => 'remove_serial_number_field'
  end
end
