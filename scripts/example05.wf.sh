#!/bin/sh -eu

# ICU Analysis Plugin
BASE_URL http://localhost:9200/

# verbose=0

DELETE example05 || echo 'Skip DELETE INDEX'
DELETE example05_sample || echo 'Skip DELETE INDEX'
DELETE example05_sample1 || echo 'Skip DELETE INDEX'

#               "icu_folding"
PUT example05 <<EOD
{
  "settings": {
    "index": {
      "analysis": {
        "analyzer": {
          "my_normalizer": {
            "tokenizer": "my_tokenizer",
            "char_filter": [
              "m17n_char_filter",
              "kuromoji_iteration_mark",
              "ja_last_name_char_filter",
              "ja_char_filter"
            ],
            "filter": [
              "icu_folding",
              "kana_filter"
            ]
          },
          "m17n_normalizer": {
            "tokenizer": "m17n_tokenizer",
            "char_filter": [
              "m17n_char_filter",
              "kuromoji_iteration_mark",
              "ja_last_name_char_filter",
              "ja_char_filter"
            ],
            "filter": [
              "icu_folding",
              "kana_filter"
            ]
          },
          "m17n_name_normalizer": {
            "tokenizer": "m17n_name_tokenizer",
            "char_filter": [
              "m17n_char_filter",
              "kuromoji_iteration_mark",
              "ja_last_name_char_filter",
              "ja_char_filter"
            ],
            "filter": [
              "icu_folding",
              "kana_filter"
            ]
          }
        },
        "tokenizer": {
          "m17n_tokenizer": {
            "type": "ngram",
            "min_gram": 2,
            "max_gram": 3,
            "token_chars": [
              "letter",
              "digit"
            ]
          },
          "m17n_name_tokenizer": {
            "type": "ngram",
            "min_gram": 1,
            "max_gram": 2,
            "token_chars": [
              "letter",
              "digit"
            ]
          },
          "my_tokenizer": {
            "type": "whitespace"
          }
        },
        "char_filter": {
          "m17n_char_filter": {
            "type": "icu_normalizer",
            "name" : "nfc"
          },
          "ja_last_name_char_filter": {
            "type": "mapping",
            "mappings": [
              "坂=>坂,阪",
              "富=>富,冨",
              "峯=>峯,峰",
              "島=>島,嶋",
              "崎=>崎,嵜,﨑",
              "斉=>斉,斎,齋,齊",
              "槇=>槙",
              "沢=>沢,澤",
              "界=>界,堺",
              "辺=>辺,邊,邉",
              "高=>高,髙"
            ]
          },
          "ja_char_filter": {
            "type": "mapping",
            "mappings": [
              "バ=>バ,ヴァ",
              "ビ=>ビ,ヴィ",
              "ブ=>ブ,ヴ",
              "べ=>べ,ヴェ",
              "ボ=>ボ,ヴォ"
            ]
          }
        },
        "filter": {
          "kana_filter" : {
            "type": "icu_transform",
            "id": "Hiragana-Katakana"
          },
          "folding": {
            "type": "asciifolding",
            "preserve_original" : true
          },
          "synonym": {
            "type": "synonym",
            "lenient": false,
            "synonyms": [
              "アイフォン, i-phone => iphone"
            ]
          }
        }
      }
    }
  }
}
EOD
verbose=1

GET '_template/example05_*' || echo 'no templates'

XDELETE _template/example05_tpl_01
PUT _template/example05_tpl_01 <<EOD
{
  "index_patterns" : ["example05_*"],
  "mappings": {
    "_source": {
        "enabled": false
    },
    "dynamic_templates": [
      {
        "full_name": {
          "path_match":   "name.*",
          "path_unmatch": "*.middle",
          "mapping": {
            "type":       "text",
            "copy_to":    "full_name"
          }
        }
      }
    ]
  }
}
EOD

# DELETE example05_sample1/_doc/1
PUT example05_sample1/_doc/1?refresh <<EOD
{
  "name": {
    "first":  "John",
    "middle": "Winston",
    "last":   "Lennon"
  }
}
EOD
sleep 3
GET 'example05_sample1/_doc/1'
XGET 'example05_sample1/_doc/1?_source=true'

# ICU Tokenizer

#  "analyzer": "nfc_normalized",
#  "analyzer": "nfkc_cf_normalized",
#   "text": "ヴェ ウ゛ェネチア ㌶ 1 ①  ①   ⑵  Å 渡辺 渡邊 渡邉 ㍻ ①  ㊤  Ⅲ "
XPOST example05/_analyze <<EOD
{
  "analyzer": "m17n_normalizer",
  "text": "プログラミング ㌶ ①  ⑵  ㊤ ㍻ Ⅲ "
}
EOD

XPOST example05/_analyze <<EOD
{
  "analyzer": "m17n_normalizer",
  "text": "ヴェネチア ベネチア iPhone アイフォーン アイフォン Å サーバー"
}
EOD

XPOST example05/_analyze <<EOD
{
  "analyzer": "m17n_normalizer",
  "text": "ヴェプロ㌶① ㊤㍻Ⅲ  avo \n　cado"
}
EOD

XPOST example05/_analyze <<EOD
{
  "analyzer": "m17n_normalizer",
  "text": "中嶋"
}
EOD

XPOST example05/_analyze <<EOD
{
  "analyzer": "my_normalizer",
  "text": "いすゞ自動車"
}
EOD

# GET '_cat/plugins?format=json'

