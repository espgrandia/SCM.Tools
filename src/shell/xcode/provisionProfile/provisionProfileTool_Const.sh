#!/bin/bash

# @brief : 宣告 provision profile 輔助工具會用到的 const value。
#
# @details :
#  - 目前會使用到的 shell
#    - provisionProfileTool_Copy.sh
#    - provisionProfileTool_Delete.sh
#
# ---
#
# 參考:
#
# - Linux / Unix Shell Script: Get Current User Name - nixCraft : https://www.cyberciti.biz/faq/appleosx-bsd-shell-script-get-current-user/
#   關於使用者的相關找尋方式
#   - mac 實測 : 除了 USERNAME 是空白的，其餘方式可以找尋到。
#     - USER : esp
#     - USERNAME :
#     - who : esp      console  May 11 09:28
#     - whoami : esp
#     - id -u -n : esp

## ================================== provision profile tools section : Begin ==================================

### ---------------------------------- general section : Begin ----------------------------------
# @brief : 透過 provision profile 通用的。

# 設定 xcode 引用的 provision profile 位置。
# @brief : Provision Profile 目標位置，Xcode 使用 Provision Profile 資料夾 有其規則。
# @details :
#  - 路徑 (command line) : ~/Library/MobileDevice/Provisioning\ Profiles
#  - 說明 :
#    由於 shell 中使用 ~/xxx 不會自動轉換成使用者的資料夾，所以要自己兜使用者路徑。
#    且因為是用直接用參數設定，所以不需要 Provisioning\ Profiles"
export CONFIG_CONST_XCODE_USING_PROVISION_PROFILE_FOLDER="/Users/${USER}/Library/MobileDevice/Provisioning Profiles"

### ---------------------------------- general section : End ----------------------------------


## ================================== provision profile tools section : End ==================================