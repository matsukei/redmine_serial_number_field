module RedmineSerialNumberField

  class IssueControllerHooks < Redmine::Hook::ViewListener
    def controller_issues_new_after_save(context = {})

      issue = context.values_at(:issue)
      issue.reload
      Issue.transaction do
        # TODO
        # issue.xxxxx
      end
    end

  end

end
