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
# - title: [bash - How to change the output color of echo in Linux - Stack Overflow]
#   - website : https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux
#

## ================================== General section : Begin ==================================

### ---------------------------------- True/Flase Flag section : Begin ----------------------------------
###
# ============= This is separation line =============
# @brief 開關性質的 Flag，Enable (開): Y，Disable (關): N。
#  - 也可以當作是 true / false 的簡易判斷。
export generalConst_Enable_Flag="Y"
export generalConst_Disable_Flag="N"
###
### ---------------------------------- True/Flase Flag  section : End ----------------------------------

### ---------------------------------- Colors Setting section : Begin ----------------------------------
###
# ============= This is separation line =============
# @brief Color Const Value 設定，可修改 Cosole log 上文字的顏色。

# Reset
generalConst_Colors_Color_Off='\033[0m' # Text Reset

# Regular Colors
generalConst_Colors_Black='\033[0;30m'  # Black
generalConst_Colors_Red='\033[0;31m'    # Red
generalConst_Colors_Green='\033[0;32m'  # Green
generalConst_Colors_Yellow='\033[0;33m' # Yellow
generalConst_Colors_Blue='\033[0;34m'   # Blue
generalConst_Colors_Purple='\033[0;35m' # Purple
generalConst_Colors_Cyan='\033[0;36m'   # Cyan
generalConst_Colors_White='\033[0;37m'  # White

# Bold
generalConst_Colors_BBlack='\033[1;30m'  # Black
generalConst_Colors_BRed='\033[1;31m'    # Red
generalConst_Colors_BGreen='\033[1;32m'  # Green
generalConst_Colors_BYellow='\033[1;33m' # Yellow
generalConst_Colors_BBlue='\033[1;34m'   # Blue
generalConst_Colors_BPurple='\033[1;35m' # Purple
generalConst_Colors_BCyan='\033[1;36m'   # Cyan
generalConst_Colors_BWhite='\033[1;37m'  # White

# Underline
generalConst_Colors_UBlack='\033[4;30m'  # Black
generalConst_Colors_URed='\033[4;31m'    # Red
generalConst_Colors_UGreen='\033[4;32m'  # Green
generalConst_Colors_UYellow='\033[4;33m' # Yellow
generalConst_Colors_UBlue='\033[4;34m'   # Blue
generalConst_Colors_UPurple='\033[4;35m' # Purple
generalConst_Colors_UCyan='\033[4;36m'   # Cyan
generalConst_Colors_UWhite='\033[4;37m'  # White

# Background
generalConst_Colors_On_Black='\033[40m'  # Black
generalConst_Colors_On_Red='\033[41m'    # Red
generalConst_Colors_On_Green='\033[42m'  # Green
generalConst_Colors_On_Yellow='\033[43m' # Yellow
generalConst_Colors_On_Blue='\033[44m'   # Blue
generalConst_Colors_On_Purple='\033[45m' # Purple
generalConst_Colors_On_Cyan='\033[46m'   # Cyan
generalConst_Colors_On_White='\033[47m'  # White

# High Intensity
generalConst_Colors_IBlack='\033[0;90m'  # Black
generalConst_Colors_IRed='\033[0;91m'    # Red
generalConst_Colors_IGreen='\033[0;92m'  # Green
generalConst_Colors_IYellow='\033[0;93m' # Yellow
generalConst_Colors_IBlue='\033[0;94m'   # Blue
generalConst_Colors_IPurple='\033[0;95m' # Purple
generalConst_Colors_ICyan='\033[0;96m'   # Cyan
generalConst_Colors_IWhite='\033[0;97m'  # White

# Bold High Intensity
generalConst_Colors_BIBlack='\033[1;90m'  # Black
generalConst_Colors_BIRed='\033[1;91m'    # Red
generalConst_Colors_BIGreen='\033[1;92m'  # Green
generalConst_Colors_BIYellow='\033[1;93m' # Yellow
generalConst_Colors_BIBlue='\033[1;94m'   # Blue
generalConst_Colors_BIPurple='\033[1;95m' # Purple
generalConst_Colors_BICyan='\033[1;96m'   # Cyan
generalConst_Colors_BIWhite='\033[1;97m'  # White

# High Intensity backgrounds
generalConst_Colors_On_IBlack='\033[0;100m'  # Black
generalConst_Colors_On_IRed='\033[0;101m'    # Red
generalConst_Colors_On_IGreen='\033[0;102m'  # Green
generalConst_Colors_On_IYellow='\033[0;103m' # Yellow
generalConst_Colors_On_IBlue='\033[0;104m'   # Blue
generalConst_Colors_On_IPurple='\033[0;105m' # Purple
generalConst_Colors_On_ICyan='\033[0;106m'   # Cyan
generalConst_Colors_On_IWhite='\033[0;107m'  # White
###
### ---------------------------------- Colors Setting section : End ----------------------------------

## ================================== General section : End ==================================
