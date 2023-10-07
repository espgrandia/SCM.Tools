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
#  ${GENERAL_CONST_ENABLE_FLAG}
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
export GENERAL_CONST_ENABLE_FLAG="Y"
export GENERAL_CONST_DISABLE_FLAG="N"
###
### ---------------------------------- True/Flase Flag  section : End ----------------------------------

### ---------------------------------- Colors Setting section : Begin ----------------------------------
###
# ============= This is separation line =============
# @brief Color Const Value 設定，可修改 Cosole log 上文字的顏色。

# Reset
generalConst_Colors_Color_Off='\033[0m' # Text Reset

# Regular Colors
GENERAL_CONST_COLORS_BLACK='\033[0;30m'  # Black
GENERAL_CONST_COLORS_RED='\033[0;31m'    # Red
GENERAL_CONST_COLORS_GREEN='\033[0;32m'  # Green
GENERAL_CONST_COLORS_YELLOW='\033[0;33m' # Yellow
GENERAL_CONST_COLORS_BLUE='\033[0;34m'   # Blue
GENERAL_CONST_COLORS_PURPLE='\033[0;35m' # Purple
GENERAL_CONST_COLORS_CYAN='\033[0;36m'   # Cyan
GENERAL_CONST_COLORS_WHITE='\033[0;37m'  # White

# Bold
GENERAL_CONST_COLORS_BBLACK='\033[1;30m'  # Black
GENERAL_CONST_COLORS_BRED='\033[1;31m'    # Red
GENERAL_CONST_COLORS_BGREEN='\033[1;32m'  # Green
GENERAL_CONST_COLORS_BYELLOW='\033[1;33m' # Yellow
GENERAL_CONST_COLORS_BBLUE='\033[1;34m'   # Blue
GENERAL_CONST_COLORS_BPURPLE='\033[1;35m' # Purple
GENERAL_CONST_COLORS_BCYAN='\033[1;36m'   # Cyan
GENERAL_CONST_COLORS_BWHITE='\033[1;37m'  # White

# Underline
GENERAL_CONST_COLORS_UBLACK='\033[4;30m'  # Black
GENERAL_CONST_COLORS_URED='\033[4;31m'    # Red
GENERAL_CONST_COLORS_UGREEN='\033[4;32m'  # Green
GENERAL_CONST_COLORS_UYELLOW='\033[4;33m' # Yellow
GENERAL_CONST_COLORS_UBLUE='\033[4;34m'   # Blue
GENERAL_CONST_COLORS_UPURPLE='\033[4;35m' # Purple
GENERAL_CONST_COLORS_UCYAN='\033[4;36m'   # Cyan
GENERAL_CONST_COLORS_UWHITE='\033[4;37m'  # White

# Background
GENERAL_CONST_COLORS_ON_BLACK='\033[40m'  # Black
GENERAL_CONST_COLORS_ON_RED='\033[41m'    # Red
GENERAL_CONST_COLORS_ON_GREEN='\033[42m'  # Green
GENERAL_CONST_COLORS_ON_YELLOW='\033[43m' # Yellow
GENERAL_CONST_COLORS_ON_BLUE='\033[44m'   # Blue
GENERAL_CONST_COLORS_ON_PURPLE='\033[45m' # Purple
GENERAL_CONST_COLORS_ON_CYAN='\033[46m'   # Cyan
GENERAL_CONST_COLORS_ON_WHITE='\033[47m'  # White

# High Intensity
GENERAL_CONST_COLORS_IBLACK='\033[0;90m'  # Black
GENERAL_CONST_COLORS_IRED='\033[0;91m'    # Red
GENERAL_CONST_COLORS_IGREEN='\033[0;92m'  # Green
GENERAL_CONST_COLORS_IYELLOW='\033[0;93m' # Yellow
GENERAL_CONST_COLORS_IBLUE='\033[0;94m'   # Blue
GENERAL_CONST_COLORS_IPURPLE='\033[0;95m' # Purple
GENERAL_CONST_COLORS_ICYAN='\033[0;96m'   # Cyan
GENERAL_CONST_COLORS_IWHITE='\033[0;97m'  # White

# Bold High Intensity
GENERAL_CONST_COLORS_BIBLACK='\033[1;90m'  # Black
GENERAL_CONST_COLORS_BIRED='\033[1;91m'    # Red
GENERAL_CONST_COLORS_BIGREEN='\033[1;92m'  # Green
GENERAL_CONST_COLORS_BIYELLOW='\033[1;93m' # Yellow
GENERAL_CONST_COLORS_BIBLUE='\033[1;94m'   # Blue
GENERAL_CONST_COLORS_BIPURPLE='\033[1;95m' # Purple
GENERAL_CONST_COLORS_BICYAN='\033[1;96m'   # Cyan
GENERAL_CONST_COLORS_BIWHITE='\033[1;97m'  # White

# High Intensity backgrounds
GENERAL_CONST_COLORS_ON_IBLACK='\033[0;100m'  # Black
GENERAL_CONST_COLORS_ON_IRED='\033[0;101m'    # Red
GENERAL_CONST_COLORS_ON_IGREEN='\033[0;102m'  # Green
GENERAL_CONST_COLORS_ON_IYELLOW='\033[0;103m' # Yellow
GENERAL_CONST_COLORS_ON_IBLUE='\033[0;104m'   # Blue
GENERAL_CONST_COLORS_ON_IPURPLE='\033[0;105m' # Purple
GENERAL_CONST_COLORS_ON_ICYAN='\033[0;106m'   # Cyan
GENERAL_CONST_COLORS_ON_IWHITE='\033[0;107m'  # White
###
### ---------------------------------- Colors Setting section : End ----------------------------------

## ================================== General section : End ==================================
