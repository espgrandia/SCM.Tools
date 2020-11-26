#!/bin/bash

# brief : 宣告 exported.sh 會使用到的 config file 常數
# 主要是給 configTools.sh 以及 exported.sh 使用
# 部分內容會給使用 exported.sh 參考使用
#

## ================================== subcommand key section : Begin ==================================
# @brief for flutter subcommand
# @sa
#   - configTools.sh 中 configTools_Gen_Required 參數可參考此區塊來設定
#   - exported.sh 會使用到。
export configConst_Subcommand_aar="aar"
export configConst_Subcommand_apk="apk"
export configConst_Subcommand_appbundle="appbundle"
export configConst_Subcommand_bundle="bundle"
export configConst_Subcommand_ios="ios"
export configConst_Subcommand_ios_framework="ios-framework"
## ================================== subcommand key section : End ==================================

## ================================== ToogleFeature key section : Begin ==================================
# @brief 針對 flutter build [subcommand] 的後續參數，屬於開關性質的設定。
# @details 
#  - optional 的功能。
#  - 有設定則表示需要開啟此功能，使用者可設定需要的參數給 configTools.sh 的某個函式 (TODO: 尚未支援)。
#  - exported.sh 會依照此 subcommand 有支援的 feature 來帶入。

# 不更新 pub。
export configConst_BuildParam_ToggleFeature_NoPub="no-pub"
## ================================== ToogleFeature key section : End ==================================

## ================================== ToogleFeature key section : Begin ==================================
# @brief 針對 flutter build [subcommand] 的後續參數，屬於需要額外帶入內容的項目。
# @details 
#  - optional 的功能。
#  - confitTools.sh 會用到此區塊的 key，使用者只需要呼叫對應的函式即可。
#  - exported.sh 會依照 build config 的相關設定來處理。

# 設定 dart 的環境變數，可於 dart 層取得。
export configConst_BuildParam_Key_DartDefine="dart-define"

# 依照 flavor 來做編譯，Android 為 flavor， iOS 為 Xcode schemes。
export configConst_BuildParam_Key_flavor="flavor"

# 設定 Android 的發佈平台。
export configConst_BuildParam_Key_TargetPlatform="target-platform"
## ================================== ToogleFeature key section : End ==================================