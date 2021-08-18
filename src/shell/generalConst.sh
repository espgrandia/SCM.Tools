#!/bin/bash

# ============= This is separation line =============
# @brief : 一般性工具.
# @details : 放置常用通用參數，使用者可以引用此檔案來使用該參數.
# @author : esp
# @create date : 2021-08-18
#
# sample :
#
#  ``` shell
#  # include 通用性參數設定。
#  . src/generalConst.sh
#
#  # then can use export parameter
#
#  ${generalConst_Enable_Flag}
#
#  ```
#
# ---
#
# Reference :
# - title: bash - How to change the output color of echo in Linux - Stack Overflow
#   - website : https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux
#

## ================================== General section : Begin ==================================

### ---------------------------------- True/Flase Flag section : Begin ----------------------------------

# @brief 開關性質的 Flag，Enable (開): Y，Disable (關): N。
#  - 也可以當作是 true / false 的簡易判斷。
export generalConst_Enable_Flag="Y"
export generalConst_Disable_Flag="N"

### ---------------------------------- True/Flase Flag  section : Begin ----------------------------------

## ================================== General section : Begin ==================================