#!/usr/bin/python
# -*- coding: UTF-8 -*-

import sys
import json

# @brief: 剖析 json file 中的某 key 對應的 value to console.
# @details : 若用 shell 的可以設定 xxx=`python parse_JsonFile_With_Key.py ../BundleZipResource/iOS/l001/default/version.manifest packageUrl`
#          : python parse_JsonFile_With_Key.py ../BundleZipResource/iOS/l001/default/version.manifest packageUrl
#          : 簡易工具，不做防呆。
# input param as follow:
# @param 1 : parse json file : ../BundleZipResource/iOS/l001/default/version.manifest
# @param 2 : parse key       : packageUrl
# 

def main():
    # print command line arguments
    # for arg in sys.argv[1:]:
    #     print arg
    
    if len(sys.argv) >= 3:

        json_file_name = sys.argv[1]

        parse_key = sys.argv[2]

        # '../BundleZipResource/iOS/l001/default/version.manifest'
        with open(json_file_name) as f:
            data = json.load(f)
            f.close()

        # 輸出到console上
        print(data[parse_key])

if __name__ == '__main__':
    main()

