# Redmine Serial Number Field

[日本語 »](https://github.com/matsukei/redmine_serial_number_field/blob/master/README.md)

Add a format to be serial number in the specified format as a issue custom field.

## Features

* "Automatic serial number" is available as a format for custom fields for issues.
  * After creating a new custom field, you can not edit the "Regular expression".
  * Every user who can create a issue has automatic number assignment authority.
* Automatically assign serial numbers in the specified format at issue registration or update(Including bulk operations).
  * Assign a serial number for each custom field. If the same custom field is used for multiple projects, It will be consecutive numbers in those projects.
  * Custom field items are displayed when viewing issues. However, it will not be displayed when registering or updating.
* Basic options for custom fields are also available, such as issue filter criteria and search target.

### Notes

#### When you change tracker or project of numbered issue

* If the changed tracker does not have the same custom field, the serial number assigned will be deleted.
* If the tracker after change has the same custom field, the serial numbers numbered will not change.

#### When you set permissions for custom fields in workflow

* Setting a custom field for automatic number assignment to read only will not work properly.

## Usage

1. Create a new custom field for the issue.
2. Change the item "Format" to "Automatic serial number".
3. Specify the serial number format in the item "Regular expression".
4. If you wish to use it as a filter or search condition, please check as appropriate.
5. Specify the tracker and project you want to number automatically.
6. Done!
    * If you create a new issue it will be automatically numbered.
    * Issues already created will be numbered as they are updated.

## Screenshot

*Administration > Custom fields > Issues > Automatic serial number*

![usage.png](https://github.com/matsukei/redmine_serial_number_field/blob/master/doc/images/usage.en.png)

*Issues*

![issues.png](https://github.com/matsukei/redmine_serial_number_field/blob/master/doc/images/issues.png)

## Supported versions

* Redmine 4.1 (Ruby 2.6)

## Format specifications

|Column used in year format |Year format|fiscal year(4/1 - 3/31)|e.g. Regular expression  |e.g Result (2015-03-31)|
|---------------------------|-----------|-----------------------|-------------------------|-----------------------|
|Issue#created_on           |`yyyy`     |No                     |`{yyyy}-{0000}`          |`2015-0001`            |
|^                          |`yy`       |No                     |`{yy}-{0000}`            |`15-0001`              |
|^                          |`YYYY`     |Yes                    |`{YYYY}-{0000}`          |`2014-0001`            |
|^                          |`YY`       |Yes                    |`{YY}-{0000}`            |`14-0001`              |
|^                          |`ISO`      |No                     |`{ISO}-{0000}`           |`20150331-0001`        |

* OK
  * `{000000}` #=> `000001`
  * `ABC-{yy}-{00}` #=> `ABC-15-01`
* NG
  * When the end is not the serial number format
    * e.g. `ABC-{000}-{yy}`
  * When format not including year format or serial number format is included.
    * e.g. `{abc}-{yy}-{000}`

## Install

1. git clone or copy an unarchived plugin to `plugins/redmine_serial_number_field` on your Redmine path.
2. `$ cd your_redmine_path/`
3. `$ bundle install`
4. Please restart Redmine

## License

[The MIT License](https://opensource.org/licenses/MIT)
