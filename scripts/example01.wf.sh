#!/bin/sh -eu

BASE_URL http://localhost:9200/

DELETE example01 || echo 'Skip DELETE INDEX'
PUT example01 <<EOD
{
  "mappings": {
    "properties": {
      "date": {
        "type": "date"
      }
    }
  }
}
EOD

PUT 'example01/_doc/1?refresh' <<EOD
{
  "name": "Alice Yamada",
  "name_ja": "山田アリス",
  "date": "2015-01-01"
}
EOD

PUT 'example01/_doc/2?refresh' <<EOD
{
 "name": "Bob Suzki",
  "name_ja": "鈴木ボブ",
  "date": "2015-01-01T12:10:30Z"
}
EOD

PUT 'example01/_doc/3?refresh' <<EOD
{
  "name": "Chili Sato",
  "name_ja": "佐藤チリ",
  "date": 1420070400001
}
EOD

GET example01/_search <<EOD
{
  "query": {
    "match_phrase": {
      "name_ja" : "山田"
    }
  },
  "sort": { "date": "asc"}
}
EOD
