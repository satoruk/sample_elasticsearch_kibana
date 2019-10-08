#!/bin/sh -eu

# テンプレートのサンプル
BASE_URL http://localhost:9200/

DELETE example07_sample1 || echo 'Skip DELETE INDEX'
DELETE _template/example07_tpl_01 || echo 'Skip DELETE TEMPLATE'

PUT _template/example07_tpl_01 <<EOD
{
  "index_patterns": ["example07_*"],
  "settings": {
    "index": {
      "analysis": {
        "analyzer":{
          "my_normalizer": {
            "tokenizer": "whitespace",
            "char_filter": [
              "kuromoji_iteration_mark"
            ],
            "filter": [
              "icu_folding",
              "kana_filter"
            ]
          }
        },
        "filter": {
          "kana_filter": {
            "type": "icu_transform",
            "id": "Hiragana-Katakana"
          }
        }
      }
    }
  },
  "mappings": {
    "dynamic_templates": [
      {
        "title": {
          "path_match": "title",
          "mapping": {
            "type": "keyword",
            "fielddata": true
          }
        }
      },
      {
        "name": {
          "path_match": "*_name",
          "mapping": {
            "type": "text",
            "copy_to": "title",
            "fields": {
              "raw": {
                "type": "keyword"
              },
              "text": {
                "analyzer": "my_normalizer",
                "fielddata": true,
                "type": "text"
              }
            }
          }
        }
      }
    ]
  }
}
EOD

nl=$'\n'
POST 'example07_sample1/_doc/_bulk?refresh' <<EOD
{"index":{}}$nl{ "product_name": "ドラえもん" }
{"index":{}}$nl{ "product_name": "アボカド" }
{"index":{}}$nl{ "product_name": "りんご" }
{"index":{}}$nl{ "product_name": "シミュレーター" }
EOD

GET example07_sample1/_search <<EOD
{
  "query": {
    "match_all": { }
  },
  "docvalue_fields": [
    "title",
    "*.*"
  ]
}
EOD

GET example07_sample1/_search <<EOD
{
  "query": {
    "multi_match": {
      /* "query": "アボガド", */
      /* "query": "シュミレーター", */
      "query": "シュミレーター",
      "fuzziness": "AUTO",
      "fields": [
        "title",
        "product_name.text"
      ]
    }
  },
  "docvalue_fields": [
    "title",
    "*.*"
  ],
  "sort": {
    "product_name.raw": "asc"
  }
}
EOD
