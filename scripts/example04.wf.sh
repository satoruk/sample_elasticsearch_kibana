#!/bin/sh -eu

# ユースケース
# ユーザ(uid)の自転車の買い替えを記録しておき、
# 特定の日時にどのブランドの自転車を愛用していたかを検索する.

BASE_URL http://localhost:9200/

verbose=0
DELETE example04 || echo 'Skip DELETE INDEX'
echo 'put mappings'
XPUT example04 <<EOD
{
  "mappings": {
    "properties": {
      "uid":        { "type": "integer" },
      "name":       { "type": "text"    },
      "created_at": { "type": "date"    }
    }
  }
}
EOD

nl=$'\n'
POST 'example04/_doc/_bulk?refresh' <<EOD
{"index":{}}$nl{ "content_ja": "吾輩 は猫 である" }
{"index":{}}$nl{ "content_ja": "我 が 名 は 青春 の エッセイ ドラゴン" }
{"index":{}}$nl{ "content_ja": "下町 ロケット" }
{"index":{}}$nl{ "content_ja": "北斗 の 拳" }
{"index":{}}$nl{ "content_ja": "進撃 の 巨人" }
EOD

verbose=1

GET example04/_search <<EOD
{
  "suggest": {
    "my-suggestion-1": {
      "text": "ドラコン",
      "term": {
        "field": "content_ja",
        "size": 10
      }
    },
    "my-suggestion-2": {
      "text": "ろけって",
      "term": {
        "field": "content_ja",
        "size": 10
      }
    }
  }
}
EOD

POST _analyze <<EOD
{
  "tokenizer": "keyword",
  "text": "New York"
}
EOD
