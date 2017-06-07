require File.expand_path('../../test_helper', __FILE__)

class SerialNumberField::IssuesControllerTest < Redmine::ControllerTest
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
    @custom_field = create_default_serial_number_field
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
      assert_select 'input[name=?]', "issue[custom_field_values][#{@custom_field.id}]"
    end
  end

  def test_post_create_and_show_and_get_edit_update_with_current_created
    # test_post_create
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
    assert_not_nil issue

    v = issue.custom_values.where(:custom_field_id => @custom_field.id).first
    assert_not_nil v
    assert_equal 'MCC-0001', v.value

    # show
    get :show, :params => {
        :id => issue.id
      }
    assert_response :success

    assert_select "div.cf_#{@custom_field.id}.attribute" do
      assert_select 'div.label' do
        assert_select 'span', text: @custom_field.name
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
      assert_select "input[name=?][value='MCC-0001']", "issue[custom_field_values][#{@custom_field.id}]"
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

    issue = Issue.find(issue.id)
    v = issue.custom_values.where(:custom_field_id => @custom_field.id).first
    assert_not_nil v
    assert_equal 'MCC-0001', v.value
  end

  def test_show_with_already_created
    get :show, :params => {
        :id => 1
      }
    assert_response :success

    assert_select "div.cf_#{@custom_field.id}.attribute" do
      assert_select 'div.label' do
        assert_select 'span', text: @custom_field.name
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
      assert_select "input[name=?]", "issue[custom_field_values][#{@custom_field.id}]"
    end

  end

  def test_put_update_with_already_created
    3.times do |i|
      assert_difference 'Journal.count' do
        put :update, :params => {
            :id => 1,
            :issue => {
              :subject => "try #{i.next}"
            }
          }
      end

      issue = Issue.find(1)
      v = issue.custom_values.where(:custom_field_id => @custom_field.id).first
      assert_not_nil v
      # TODO
      assert_equal nil, v.value
    end

  end

  def test_get_bulk_edit
    get :bulk_edit, :params => {
        :ids => [1, 3]
      }
    assert_response :success

    assert_select 'form#bulk_edit_form' do
      # Delete the screen input item later
      assert_select "input[name=?][value='__none__']", "issue[custom_field_values][#{@custom_field.id}]"
    end

  end

  def test_bulk_update
    issue_ids = [1, 2, 4, 5, 7, 8]
    expected_serial_numbers = [
      'MCC-0001', nil, 'MCC-0001', nil, 'MCC-0002', 'MCC-0003'
    ]
    # 1
    post :bulk_update, :params => {
        :ids => issue_ids,
        :notes => 'Bulk editing #1'
      }

    issue_ids.each_with_index do |issue_id, i|
      issue = Issue.find(issue_id)
      journal = issue.journals.reorder('created_on DESC').first
      assert_equal 'Bulk editing #1', journal.notes

      expected_serial_number = expected_serial_numbers[i]
      v = issue.custom_values.where(:custom_field_id => @custom_field.id).first
      if expected_serial_number.nil?
        assert_nil v
      else
        # TODO
        assert_not_nil v
        assert_equal nil, v.value
      end
    end

    # 2
    post :bulk_update, :params => {
        :ids => issue_ids,
        :notes => 'Bulk editing #2'
      }

    issue_ids.each_with_index do |issue_id, i|
      issue = Issue.find(issue_id)
      journal = issue.journals.reorder('created_on DESC').first
      assert_equal 'Bulk editing #2', journal.notes

      expected_serial_number = expected_serial_numbers[i]
      v = issue.custom_values.where(:custom_field_id => @custom_field.id).first
      if expected_serial_number.nil?
        assert_nil v
      else
        # TODO
        assert_not_nil v
        assert_equal expected_serial_number, v.value
      end
    end

  end

end
