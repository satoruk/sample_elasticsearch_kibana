FROM docker.elastic.co/elasticsearch/elasticsearch:7.1.1

RUN elasticsearch-plugin install analysis-icu \
 && elasticsearch-plugin install analysis-kuromoji
