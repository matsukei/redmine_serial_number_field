# Redmine Serial Number Field

[![Build Status](https://travis-ci.org/matsukei/redmine_serial_number_field.svg?branch=master)](https://travis-ci.org/matsukei/redmine_serial_number_field)

[English »](https://github.com/matsukei/redmine_serial_number_field/blob/master/README.en.md)

Redmine に自動で連番を付加するカスタムフィールドを提供するプラグインです。

## Features

* チケットに対するカスタムフィールドの書式として「自動採番」が利用可能になります。
  * カスタムフィールドの新規作成後は、正規表現を編集することは、できません。
  * チケットが登録できる、全てのユーザーは、自動採番の権限があります。
* 指定したフォーマットの連番を、チケット登録や更新時（一括操作も含む）に自動的に採番します。
  * カスタムフィールド単位での採番となります。同じカスタムフィールドを複数のプロジェクトで使用している場合は、それらのプロジェクトで連続した採番になります。
  * カスタムフィールド項目は、チケットの閲覧時には表示します。しかし、登録および更新時には表示しません。
* チケットのフィルタ条件、検索対象など、カスタムフィールドの基本的なオプションも利用可能です。

### Notes

#### 採番済みチケットのトラッカーやプロジェクトを変更した場合

* 変更後のトラッカーが同じカスタムフィールドを持っていない場合、採番された連番は削除されます。
* 変更後のトラッカーが同じカスタムフィールドを持っている場合、採番された連番は変化しません。

#### ワークフローのカスタムフィールドに対する権限を設定した場合

* 自動採番のカスタムフィールドを読み取り専用に設定すると動作がおかしくなる場合があります。

## Usage

1. チケットの新しいカスタムフィールドを作成します。
2. 項目「書式」を自動採番に変更します。
3. 項目「正規表現」に連番フォーマットを指定します。
4. フィルタや検索条件として使いたい場合は、適宜チェックを入れます。
5. 自動採番をしたいトラッカーとプロジェクトを指定します。
6. 完了です。
    * 新たにチケットを作成すれば自動で採番されます。
    * 既に作成されたチケットは何かしら更新すれば採番されます。

## Screenshot

*Administration > Custom fields > Issues > 自動採番*

![usage.png](https://github.com/matsukei/redmine_serial_number_field/blob/master/doc/images/usage.png)

*Issues*

![issues.png](https://github.com/matsukei/redmine_serial_number_field/blob/master/doc/images/issues.png)

## Supported versions

* Redmine 3.2.x or higher

## Format specifications

|採番対象の日付   |年表記フォーマット   |年度(4/1 - 3/31)|連番フォーマット  |結果                      |
|----------------|-------------------|----------------|----------------|------------------------|
|Issue#created_on|`yy`               |No              |000             |2015-03-01 => '15001'   |
|Issue#created_on|`yyyy`             |No              |0000            |2015-03-01 => '20150001'|
|Issue#created_on|`YY`               |Yes             |000             |2015-03-01 => '14001'   |
|Issue#created_on|`YYYY`             |Yes             |0000            |2015-03-01 => '20140001'|

* OK
  * `{000000}` #=> `000001`
  * `ABC-{yy}-{00}` #=> `ABC-15-01`
* NG
  * 末尾が連番フォーマットでない場合
    * e.g. `ABC-{000}-{yy}`
  * 年表記フォーマット、連番フォーマットでない場合
    * e.g. `{abc}-{yy}-{000}`

## Install

1. `your_redmine_path/plugins/redmine_serial_number_field/` に clone もしくはダウンロードしたソースを配置します
2. `$ cd your_redmine_path/`
3. `$ bundle install`
4. Redmineを再起動してください

## License

[The MIT License](https://opensource.org/licenses/MIT)
