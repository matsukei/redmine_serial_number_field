require File.expand_path('../../test_helper', __FILE__)

class SerialNumberField::IssuesControllerTest < ActionController::TestCase
  tests IssuesController

  fixtures :projects,
           :users, :email_addresses, :user_preferences,
           :roles, :members, :member_roles,
           :issues, :issue_statuses, :issue_relations,
           :versions, :trackers, :projects_trackers,
           :issue_categories, :enabled_modules,
           :enumerations, :attachments, :workflows,
           :custom_fields, :custom_values,
           :custom_fields_projects, :custom_fields_trackers,
           :time_entries, :journals, :journal_details,
           :queries, :repositories, :changesets

  include Redmine::I18n

  def setup
    @default_custom_field = create_default_serial_number_field
    @for_all_custom_field = create_for_all_serial_number_field
    @request.session[:user_id] = 2
  end

  def test_get_new
    get :new, :params => {
        :project_id => 1,
        :tracker_id => 1
      }
    assert_response :success

    assert_select 'form#issue-form' do
      # Delete the screen input item later
      assert_select 'input[name=?]', "issue[custom_field_values][#{@default_custom_field.id}]"
      assert_select 'input[name=?]', "issue[custom_field_values][#{@for_all_custom_field.id}]"
    end
  end

  def test_post_create_and_show_and_get_edit_update_with_current_created_and_post_copy
    # create
    assert_difference 'Issue.count' do
      assert_no_difference 'Journal.count' do
        post :create, :params => {
            :project_id => 1,
            :issue => {
              :tracker_id => 1,
              :status_id => 2,
              :subject => 'This is the test_new issue',
            }
          }
      end
    end
    assert_redirected_to :controller => 'issues', :action => 'show', :id => Issue.last.id

    issue = Issue.find_by_subject('This is the test_new issue')
    assert_added_serial_number(issue.id, 'MCC-0001', @default_custom_field)
    assert_added_serial_number(issue.id, 'MCC-0001', @for_all_custom_field)

    # show
    get :show, :params => {
        :id => issue.id
      }
    assert_response :success

    assert_select "div.cf_#{@default_custom_field.id}.attribute" do
      assert_select 'div.label' do
        assert_select 'span', text: @default_custom_field.name
      end
      assert_select 'div.value', text: /MCC-0001/
    end

    assert_select "div.cf_#{@for_all_custom_field.id}.attribute" do
      assert_select 'div.label' do
        assert_select 'span', text: @for_all_custom_field.name
      end
      assert_select 'div.value', text: /MCC-0001/
    end

    # edit
    get :edit, :params => {
        :id => issue.id
      }
    assert_response :success

    assert_select 'form#issue-form' do
      # Delete the screen input item later
      assert_select "input[name=?][value='MCC-0001']", "issue[custom_field_values][#{@default_custom_field.id}]"
      assert_select "input[name=?][value='MCC-0001']", "issue[custom_field_values][#{@for_all_custom_field.id}]"
    end

    # update
    assert_difference 'Journal.count' do
      put :update, :params => {
          :id => issue.id,
          :issue => {
            :notes => 'just trying'
          }
        }
    end
    assert_added_serial_number(issue.id, 'MCC-0001', @default_custom_field)
    assert_added_serial_number(issue.id, 'MCC-0001', @for_all_custom_field)

    # copy
    assert_difference 'Issue.count' do
      post :create, :params => {
          :project_id => 1,
          :issue => {
            :tracker_id => 1,
            :status_id => 2,
            :subject => 'This is the test_copy issue',
            :custom_field_values => {
              @default_custom_field.id => 'MCC-0001'
            }
          },
          :copy_from => issue.id,
          :link_copy => 1
        }
    end
    copied_issue = Issue.find_by_subject('This is the test_copy issue')
    assert_redirected_to :controller => 'issues', :action => 'show', :id => copied_issue.id

    assert_not_equal(issue.id, copied_issue.id)
    assert_added_serial_number(copied_issue.id, 'MCC-0002', @default_custom_field)
    assert_added_serial_number(copied_issue.id, 'MCC-0002', @for_all_custom_field)
  end

  def test_show_with_already_created
    get :show, :params => {
        :id => 1
      }
    assert_response :success

    assert_select "div.cf_#{@default_custom_field.id}.attribute" do
      assert_select 'div.label' do
        assert_select 'span', text: @default_custom_field.name
      end
      assert_select 'div.value', text: ''
    end

    assert_select "div.cf_#{@for_all_custom_field.id}.attribute" do
      assert_select 'div.label' do
        assert_select 'span', text: @for_all_custom_field.name
      end
      assert_select 'div.value', text: ''
    end

  end

  def test_get_edit_with_already_created
    get :edit, :params => {
        :id => 1
      }
    assert_response :success

    assert_select 'form#issue-form' do
      # Delete the screen input item later
      assert_select "input[name=?]", "issue[custom_field_values][#{@default_custom_field.id}]"
      assert_select "input[name=?]", "issue[custom_field_values][#{@for_all_custom_field.id}]"
    end

  end

  def test_put_update_with_already_created
    # Added serial nubmer #1 project_id: 1, tracker_id: 1
    assert_difference 'Journal.count' do
      put :update, :params => {
          :id => 1,
          :issue => {
            :subject => 'just trying #1'
          }
        }
    end
    assert_added_serial_number(1, 'MCC-0001', @default_custom_field)
    assert_added_serial_number(1, 'MCC-0001', @for_all_custom_field)

    # Added serial nubmer #3 project_id: 1, tracker_id: 1
    assert_difference 'Journal.count' do
      put :update, :params => {
          :id => 3,
          :issue => {
            :subject => 'just trying #3'
          }
        }
    end
    assert_added_serial_number(3, 'MCC-0002', @default_custom_field)
    assert_added_serial_number(3, 'MCC-0002', @for_all_custom_field)

    # Changed tracker(have serial number) #3 project_id: 1, tracker_id: 3
    assert_difference 'Journal.count' do
      put :update, :params => {
          :id => 3,
          :issue => {
            :tracker_id => 3
          }
        }
    end
    assert_added_serial_number(3, 'MCC-0002', @default_custom_field)
    assert_added_serial_number(3, 'MCC-0002', @for_all_custom_field)

    # Changed tracker(not have serial number) #3 project_id: 1, tracker_id: 2
    assert_difference 'Journal.count' do
      put :update, :params => {
          :id => 3,
          :issue => {
            :tracker_id => 2
          }
        }
    end
    assert_none_serial_number(3, @default_custom_field)
    assert_added_serial_number(3, 'MCC-0002', @for_all_custom_field)

    # Changed project(not have serial number) #1 project_id: 3, tracker_id: 3
    assert_difference 'Journal.count' do
      put :update, :params => {
          :id => 1,
          :issue => {
            :project_id => 3,
            :tracker_id => 3
          }
        }
    end
    assert_none_serial_number(1, @default_custom_field)
    assert_added_serial_number(1, 'MCC-0001', @for_all_custom_field)

    # Changed project(have serial number) #3 project_id: 1, tracker_id: 3
    assert_difference 'Journal.count' do
      put :update, :params => {
          :id => 3,
          :issue => {
            :project_id => 1,
            :tracker_id => 3
          }
        }
    end
    assert_added_serial_number(3, 'MCC-0001', @default_custom_field)
    assert_added_serial_number(3, 'MCC-0002', @for_all_custom_field)

    # Changed project(have serial number) #1 project_id: 2, tracker_id: 3
    assert_difference 'Journal.count' do
      put :update, :params => {
          :id => 1,
          :issue => {
            :project_id => 2,
            :tracker_id => 3
          }
        }
    end
    assert_added_serial_number(1, 'MCC-0002', @default_custom_field)
    assert_added_serial_number(1, 'MCC-0001', @for_all_custom_field)

    # Changed project(have serial number) #2 project_id: 1, tracker_id: 3
    assert_difference 'Journal.count' do
      put :update, :params => {
          :id => 2,
          :issue => {
            :tracker_id => 3
          }
        }
    end
    assert_added_serial_number(2, 'MCC-0003', @default_custom_field)
    assert_added_serial_number(2, 'MCC-0003', @for_all_custom_field)

    # Changed project(have serial number) #1 project_id: 1, tracker_id: 3
    assert_difference 'Journal.count' do
      put :update, :params => {
          :id => 1,
          :issue => {
            :project_id => 1,
            :tracker_id => 3
          }
        }
    end
    assert_added_serial_number(1, 'MCC-0002', @default_custom_field)
    assert_added_serial_number(1, 'MCC-0001', @for_all_custom_field)


    # Changed project(have serial number) #4 project_id: 2, tracker_id: 2
    assert_difference 'Journal.count' do
      put :update, :params => {
          :id => 4,
          :issue => {
            :project_id => 2,
            :tracker_id => 2
          }
        }
    end
    assert_none_serial_number(4, @default_custom_field)
    assert_added_serial_number(4, 'MCC-0004', @for_all_custom_field)

    # Changed project(not have serial number) #2 project_id: 3, tracker_id: 3
    assert_difference 'Journal.count' do
      put :update, :params => {
          :id => 2,
          :issue => {
            :project_id => 3,
            :tracker_id => 3
          }
        }
    end
    assert_none_serial_number(2, @default_custom_field)
    assert_added_serial_number(2, 'MCC-0003', @for_all_custom_field)

    # Changed project(have serial number) #2 project_id: 1, tracker_id: 3
    assert_difference 'Journal.count' do
      put :update, :params => {
          :id => 2,
          :issue => {
            :project_id => 1,
            :tracker_id => 3
          }
        }
    end
    assert_added_serial_number(2, 'MCC-0003', @default_custom_field)
    assert_added_serial_number(2, 'MCC-0003', @for_all_custom_field)
  end

  def test_get_bulk_edit
    get :bulk_edit, :params => {
        :ids => [1, 3]
      }
    assert_response :success

    assert_select 'form#bulk_edit_form' do
      # Delete the screen input item later
      assert_select "input[name=?][value='__none__']", "issue[custom_field_values][#{@default_custom_field.id}]"
      assert_select "input[name=?][value='__none__']", "issue[custom_field_values][#{@for_all_custom_field.id}]"
    end

  end

  def test_bulk_update
    issue_ids = [1, 2, 4, 5, 7, 8]
    expected_default_serial_numbers = [
      'MCC-0001', nil, 'MCC-0002', nil, 'MCC-0003', 'MCC-0004'
    ]
    expected_for_all_serial_numbers = [
      'MCC-0001', 'MCC-0002', 'MCC-0003','MCC-0004', 'MCC-0005', 'MCC-0006'
    ]

    post :bulk_update, :params => {
        :ids => issue_ids.shuffle,
        :notes => "Bulk editing"
      }

    issue_ids.each_with_index do |issue_id, i|
      issue = Issue.find(issue_id)
      journal = issue.journals.reorder('created_on DESC').first
      assert_equal "Bulk editing", journal.notes

      expected_value = expected_default_serial_numbers[i]
      if expected_value.nil?
        assert_none_serial_number(issue_id, @default_custom_field)
      else
        assert_added_serial_number(issue_id, expected_value, @default_custom_field)
      end
      assert_added_serial_number(issue_id, expected_for_all_serial_numbers[i], @for_all_custom_field)
    end

  end

end
