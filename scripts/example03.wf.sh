#!/bin/sh -eu

# 時系列データの指定した日時時点の情報を取得
BASE_URL http://localhost:9200/

verbose=0
DELETE example03 || echo 'Skip DELETE INDEX'
echo 'put mappings'
PUT example03 <<EOD
{
  "mappings": {
    "properties": {
      "uid":     { "type": "keyword" },
      "name":    { "type": "text"    },
      "age":     { "type": "integer" },
      "born_on": { "type": "date"    }
    }
  }
}
EOD

nl=$'\n'
POST 'example03/_doc/_bulk?refresh' <<EOD
{"index":{}}$nl{ "uid": 1001, "created_at": "2011-01-01T12:10:30Z", "name": "SCOTT" }
{"index":{}}$nl{ "uid": 1001, "created_at": "2012-01-01T12:10:30Z", "name": "FELT" }
{"index":{}}$nl{ "uid": 1001, "created_at": "2013-01-01T12:10:30Z", "name": "TREK" }
{"index":{}}$nl{ "uid": 1002, "created_at": "2011-01-01T12:10:30Z", "name": "Bianchi" }
{"index":{}}$nl{ "uid": 1002, "created_at": "2012-01-01T12:10:30Z", "name": "MERIDA" }
{"index":{}}$nl{ "uid": 1002, "created_at": "2013-01-01T12:10:30Z", "name": "GIANT" }
EOD

verbose=1

GET example03/_search <<EOD
{
  "size": 0,
  "query": {
    "bool": {
      "must": [
        { "term":  { "uid":     { "value": 1001 } } },
        { "range": { "created_at": { "lte": "2012-01-01T12:10:30Z"  } } }
      ]
    }
  },
  "aggs": {
    "group_by_uid": {
      "terms": {
        "field": "uid"
      },
      "aggs": {
        "group_docs": {
          "top_hits": {
            "size": 1,
            "sort": [
              {
                "created_at": {
                    "order": "desc"
                }
              }
            ]
          }
        }
      }
    }
  }
}
EOD
