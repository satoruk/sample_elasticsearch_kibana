Elasticsearch and Kibana のサンプル

## 概要
- `Elasticsearch`を2ノード1クラスタ構成
- `Kibana`

## GitHub
- https://github.com/satoruk/sample_elasticsearch_kibana

### 起動

```shell
docker-compose up
```

- Kibana
  - http://localhost:5601/
- Elasticsearch
  - http://localhost:9200/

### 終了


```shell
docker-compose down
```

環境毎削除する場合

```shell
docker-compose down --rmi all -v
```

### サンプルスクリプトの実行

`scripts`以下にサンプルスクリプトがあります。

実行方法

```sh
bin/restful_workflow scripts/example01.wf.sh
```
