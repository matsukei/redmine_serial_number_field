# Redmine Serial Number Field

Redmine plugin for automatically available to custom field to generate a sequential number.

## Features

* 自動的に連番を生成するカスタムフィールド(チケット用)が利用可能
  * カスタムフィールドの設定画面で、設定された日付(issueのcreated_atとか、、、)を元に採番ルールでチケット作成時に自動的に採番する
* チケットのフィルタ条件、検索対象など、カスタムフィールドの基本的なオプションも利用化
* 原則編集不可とし、照会画面には表示（編集画面には表示しない）

## Usage

**TODO**

## Supported versions

* Redmine 2.6+

## Specifications

|採番対象の日付|日付フォーマット|年度 |連番フォーマット|結果                    |
|--------------|----------------|-----|----------------|------------------------|
|created_at    |`%y`            |No   |000             |2015-03-01 => '15001'   |
|created_at    |`%Y`            |No   |0000            |2015-03-01 => '20150001'|
|created_at    |`%y`            |Yes  |000             |2015-03-01 => '14001'   |
|created_at    |`%Y`            |Yes  |0000            |2015-03-01 => '20140001'|

### Format

* http://docs.ruby-lang.org/ja/2.1.0/method/String/i/succ.html
* http://docs.ruby-lang.org/ja/2.1.0/method/String/i/rjust.html
* http://pubs.opengroup.org/onlinepubs/009695399/functions/strftime.html
* https://github.com/asanghi/fiscali
  * http://qiita.com/snoozer05/items/57715f028a8da5aa45f4
