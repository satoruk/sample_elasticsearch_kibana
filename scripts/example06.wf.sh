#!/bin/sh -eu

BASE_URL http://localhost:9200/

DELETE example06_sample1 || echo 'Skip DELETE INDEX'

PUT example06_sample1 <<EOD
{
  "settings": {
    "index": {
      "analysis": {
        "analyzer": {
          "my_normalizer": {
            "tokenizer": "whitespace",
            "filter": [
              "icu_folding",
              "kana_filter"
            ]
          }
        },
        "filter": {
          "kana_filter" : {
            "type": "icu_transform",
            "id": "Hiragana-Katakana"
          }
        }
      }
    }
  },
  "mappings": {
    "properties": {
      "city": {
        "type": "text",
        "fields": {
          "raw": {
            "analyzer": "my_normalizer",
            "fielddata": true,
            "type":  "text"
          }
        }
      }
    }
  }
}
EOD

nl=$'\n'
POST 'example06_sample1/_doc/_bulk?refresh' <<EOD
{"index":{}}$nl{ "city": "こが" }
{"index":{}}$nl{ "city": "かわごえ" }
EOD

GET "example06_sample1"

GET example06_sample1/_search <<EOD
{
  "query": {
    "multi_match": {
      "query": "かわうち",
      "fields": [
        "city",
        "city.raw"
      ]
    }
  },
  "sort": {
    "city.raw": "asc"
  }
}
EOD
