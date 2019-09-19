#!/bin/sh -eu

# 時系列データの指定した日時時点の情報を取得
BASE_URL http://localhost:9200/

verbose=0

DELETE example02 || echo 'Skip DELETE INDEX'

echo 'put mappings'
PUT example02 <<EOD
{
  "mappings": {
    "properties": {
      "type":       { "type": "keyword" },
      "name":       { "type": "text"    },
      "age":        { "type": "integer" },
      "updated_at": { "type": "date"    }
    }
  }
}
EOD

PUT example02/_doc/1 <<EOD
{
  "type": "portfolio",
  "name": "Alice Yamada",
  "age": 21,
  "updated_at": "2015-01-01T12:10:30Z"
}
EOD

PUT example02/_doc/2 <<EOD
{
  "type": "portfolio",
  "name": "Alice Yamada",
  "age": 22,
  "updated_at": "2016-01-01T12:10:30Z"
}
EOD

PUT example02/_doc/3 <<EOD
{
  "type": "portfolio",
  "name": "Alice Yamada",
  "age": 23,
  "updated_at": "2017-01-01T12:10:30Z"
}
EOD

sleep 1
verbose=1

echo 'SEARCH'
XGET example02/_search <<EOD
{
  "query": {
    "bool": {
      "must": {
        "match": {
          "name": "Alice"
        }
      },
      "filter": {
        "match": {
          "type": "portfolio"
        }
      }
    }
  },
  "sort": { "updated_at": "asc"}
}
EOD
