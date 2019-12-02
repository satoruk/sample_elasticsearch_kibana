#!/bin/sh -eu

# ユースケース
# ユーザ(uid)の自転車の買い替えを記録しておき、
# 特定の日時にどのブランドの自転車を愛用していたかを検索する.
#
# Rangeのデータ型を使うことで特定の日時で絞り込む様にした.
#
# Top Hits Aggregationを利用する方法も試みたが最終的には集計自体は可能だが絞り込みができなかったので検索クエリをシンプルできる様にデータ構造を工夫することで対応した.

BASE_URL http://localhost:9200/

verbose=0
DELETE example11 || echo 'Skip DELETE INDEX'
echo 'put mappings'
PUT example11 <<EOD
{
  "mappings": {
    "properties": {
      "uid":        { "type": "integer"    },
      "price":      { "type": "integer"    },
      "name":       { "type": "text"       },
      "created_at": { "type": "date"       },
      "range":      { "type": "date_range" }
    }
  }
}
EOD

nl=$'\n'
POST 'example11/_doc/_bulk?refresh' <<EOD
{"index":{}}$nl{ "uid": 1001, "created_at": "2011-01-01T12:00:00Z", "range": { "gte": "2011-01-01", "lt": "2012-01-01" }, "price": 106, "name": "SCOTT" }
{"index":{}}$nl{ "uid": 1001, "created_at": "2012-01-01T12:00:00Z", "range": { "gte": "2012-01-01", "lt": "2012-01-02" }, "price": 110, "name": "FELT2" }
{"index":{}}$nl{ "uid": 1001, "created_at": "2012-01-02T12:00:00Z", "range": { "gte": "2012-01-02", "lt": "2013-01-01" }, "price": 105, "name": "FELT" }
{"index":{}}$nl{ "uid": 1001, "created_at": "2013-01-01T12:00:00Z", "range": { "gte": "2013-01-01"                     }, "price": 104, "name": "TREK" }
{"index":{}}$nl{ "uid": 1002, "created_at": "2011-01-01T12:00:00Z", "range": { "gte": "2011-01-01", "lt": "2012-01-01" }, "price": 103, "name": "Bianchi" }
{"index":{}}$nl{ "uid": 1002, "created_at": "2012-01-01T12:00:00Z", "range": { "gte": "2012-01-01", "lt": "2013-01-01" }, "price": 102, "name": "MERIDA" }
{"index":{}}$nl{ "uid": 1002, "created_at": "2013-01-01T12:00:00Z", "range": { "gte": "2013-01-01"                     }, "price": 101, "name": "GIANT" }
EOD

verbose=1

# 2012/02/01 時点の使用バイクを特定する.
# uid:1001 FELT
# uid:1002 MERIDA
#         { "term":  { "uid":     { "value": 1001 } } },
GET example11/_search <<EOD
{
  "size": 10,
  "query": {
    "bool": {
      "must": [
        {
          "term": {
            "uid": 1001
          }
        },
        {
          "term": {
            "range": "2012-02-01T12:00:00Z"
          }
        }
      ]
    }
  }
}
EOD

