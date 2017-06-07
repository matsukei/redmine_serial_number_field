require File.expand_path('../../test_helper', __FILE__)

class SerialNumberField::CustomFieldsControllerTest < ActionController::TestCase
  tests CustomFieldsController

  fixtures :custom_fields, :custom_values,
           :custom_fields_projects, :custom_fields_trackers,
           :roles, :users,
           :members, :member_roles,
           :groups_users,
           :trackers, :projects_trackers,
           :enabled_modules,
           :projects, :issues,
           :issue_statuses,
           :issue_categories,
           :enumerations,
           :workflows

  def setup
    @request.session[:user_id] = 1
  end

  def test_new_should_serial_number_format_has_only_issue
    CustomFieldsHelper::CUSTOM_FIELDS_TABS.each do |tab|
      type = tab[:name]
      format_name = SerialNumberField::Format::NAME
      expect_selected =  'IssueCustomField' == type ? 1 : 0

      get :new, :params => {
          :type => type,
          :custom_field => {
            :field_format => format_name
          }
        }
      assert_response :success

      assert_select 'form#custom_field_form' do
        assert_select 'select[name=?]', 'custom_field[field_format]' do
          assert_select 'option[value=?][selected=selected]', format_name, expect_selected
        end
      end
    end
  end

  def test_new_serial_number_format
    get :new, :params => {
        :type => 'IssueCustomField',
        :custom_field => {
          :field_format => SerialNumberField::Format::NAME
        }
      }
    assert_response :success

    assert_select 'form#custom_field_form' do
      assert_select 'input[name=?]', 'custom_field[name]'
      assert_select 'textarea[name=?]', 'custom_field[description]'
      assert_select 'input[name=?]:not([disabled])', 'custom_field[regexp]'
      # Trackers
      assert_select 'input[type=checkbox][name=?]', 'custom_field[project_ids][]', Project.count
      assert_select 'input[type=hidden][name=?]', 'custom_field[project_ids][]', 1
      # Projects
      assert_select 'input[type=checkbox][name=?]', 'custom_field[tracker_ids][]', Tracker.count
      assert_select 'input[type=hidden][name=?]', 'custom_field[tracker_ids][]', 1
      # Delete the screen input item later
      assert_select 'input[type=hidden][value="0"][name=?]', 'custom_field[is_required]'
      assert_select 'input[type=hidden][value="1"][name=?]', 'custom_field[visible]'
      assert_select 'input[type=hidden][value=""][name=?]', 'custom_field[role_ids][]'
    end
  end

  def test_create_serial_number_field
    valid_regexp_values.each_with_index do |valid_regexp, i|
      field_name = "auto_number_#{i.next}"
      field = new_record(IssueCustomField) do
        post :create, :params => {
            :type => "IssueCustomField",
            :custom_field => {
              :field_format => "serial_number",
              :name => field_name,
              :description => "",
              :regexp => valid_regexp,
              :is_required =>"0",
              :is_filter => "1",
              :searchable => "1",
              :visible => "1",
              :tracker_ids => ["1", ""],
              :is_for_all => "0",
              :project_ids => ["1", "3", ""]
            }
          }
      end
      assert_redirected_to "/custom_fields/#{field.id}/edit"

      assert_equal field_name, field.name
      assert_equal valid_regexp, field.regexp
      assert_equal [1], field.trackers.map(&:id).sort
      assert_equal [1, 3], field.projects.map(&:id).sort
    end
  end

  def test_create_serial_number_field_with_failure
    invalid_regexp_values.each_with_index do |invalid_regexp, i|
      assert_no_difference 'CustomField.count' do
        post :create, :params => {
            :type => "IssueCustomField",
            :custom_field => {
              :field_format => "serial_number",
              :name => "auto_number_#{i.next}",
              :regexp => invalid_regexp,
              :is_required =>"0",
              :visible => "1"
            }
          }
      end
      assert_response :success

      assert_select_error /regular expression is /i
    end
  end

  def test_edit_serial_number_field
    custom_field = create_default_serial_number_field

    get :edit, :params => {
        :id => custom_field.id
      }

    assert_response :success

    assert_select 'input[name=?][value=?]', 'custom_field[name]', custom_field.name
    assert_select 'input[name=?][value=?][disabled=disabled]', 'custom_field[regexp]', custom_field.regexp
  end

  def test_update_serial_number_field
    custom_field = create_default_serial_number_field

    valid_regexp_values.each_with_index do |valid_regexp, i|
      put :update, :params => {
          :id => custom_field.id,
          :custom_field => {
            :regexp => valid_regexp
          }
        }
      assert_redirected_to "/custom_fields/#{custom_field.id}/edit"

      custom_field.reload
      assert_equal valid_regexp, custom_field.regexp
    end
  end

  def test_update_serial_number_field_with_failure
    custom_field = create_default_serial_number_field

    invalid_regexp_values.each_with_index do |invalid_regexp, i|
      put :update, :params => {
          :id => custom_field.id,
          :custom_field => {
            :regexp => invalid_regexp
          }
        }
      assert_response :success

      assert_select_error /regular expression is /i
    end
  end

end
