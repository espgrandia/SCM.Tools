#!/bin/sh

# brief : 剖析 yaml 的 shell
# $1 : yaml file name
# $2 : 設定 剖析 yaml 後在 shell 環境設定的前贅字
# 轉換成 shell 環境設定，會依照階層，用 "_" 來取代階層概念
# TODO:
#  - $3 : 不知道用途
#  - 無法讀取 yaml 中的 array。

# 可以改用 https://github.com/jasperes/bash-yaml

# website : 
#  - 原始出處 : https://gist.github.com/pkuczynski/8665367
#  - 善心人士對原始出處的修正版 : https://github.com/jasperes/bash-yaml

## sample: test.sh
#
# ``` shell
#    # include parse_yaml function
#    . parse_yaml.sh

#    # read yaml file
#    eval $(parse_yaml zconfig.yml "config_")

#    # access yaml content
#    echo $config_development_database
# ```

## sample : zconfig.yml
#
# ``` yml
#    development:
#    adapter: mysql2
#    encoding: utf8
#    database: my_database
#    username: root
#    password:
# ```

parse_yaml() {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}
