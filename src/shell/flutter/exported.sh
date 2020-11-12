#!/bin/bash

# brief : 簡單處理目前的出版 => release for apk and ipa
#         並不是正式的出版流程，之後需要再分析更好的流程，陸續整理中。
# ---
#
# Reference :
# - title: [shell]shell運算(數字[加減乘除，比較大小]，字串，檔案) - IT閱讀
#   - website : https://www.itread01.com/content/1548088410.html
#
# ---
#
# 目前支援 :
# - version 管理 : 與 pubspec.yaml 的 version 來做結合，由參數帶入。
#
# ---
#
# input 參數說明 :
#   主要是 對應於 flutter pubspec.yaml 中
#   version:[BuildName]+[BuildNumber] => e.g. version: 1.0.0+10
# - $1 : exported_Param_BuildConfigFile="[專案路徑]/[scm]/output/buildConfig.yaml" : 設定編譯的 config 功能檔案 [需帶完整路徑].
#   - 內容為協議好的格式，只是做成可彈性設定的方式，可選項目，沒有則以基本編譯。
#
#   - sample file : buildConfig.yaml
#
#     ``` yaml
#     optional:
#       dart_define :
#         separator : +
#         defines :
#           - gitHash+cd8a0dc
#           - envName+rc
#     ```
#
# ---
#
# Toggle Feature (切換功能) 說明:
#
# - exported_ToogleFeature_IsDumpSet_When_Parse_BuildConfigFile="Y" => e.g. "Y" 或 "N"
#   - 是否開啟 dump set 內容，當 parse build config file 時，會去判斷。
#   - 上傳版本會是關閉狀態，若需要測試時，自行打開。
#
# - exported_ToogleFeature_BuildConfigType=release
#   - build configutation type : 編譯組態設定，之後視情況是否要開放
#   - 依據 flutter build version : 有 debug ， profile ， release 三種方式
#
# ---
#
# build 方式 :
#  - 經由讀取 build config file 來處理，細部說明可參考 configTools.sh
#
#  - reauired:
#    - version: [BuildName]+[BuildNumber] => e.g. 1.0.0+10
#      - android :
#        - VersionName : [BuildName] => e.g. 1.0.0
#        - VersionCode : [BuildNumber]  => e.g. 10
#
#      - iOS :
#        - BundleShortVersion : [BuildName] => e.g. 1.0.0
#        - BundleVersion : [BuildName].[BuildNumber] => e.g. 1.0.0.10
#
#  - optinonal :
#    - dart-define
#      - key 設定於 exported_DartDef_Key_GitHash : gitHash
#        用途 :git commit ID for short hash
#        對應於 flutter 的使用方式 String.fromEnvironment('gitHash')
#      - key : 設定於 exported_DartDef_Key_EnvName : envName
#        用途 : 設定於此次編譯的對應環境
#        對應於 flutter 的使用方式 String.fromEnvironment('envName')
#
# ---
#
# TODO:
#  - 只有產出 release (是否足夠)
#  - apk 未瘦身，不確定是否有擾亂 ?
#  - flavor 的可行性。
#  - dart-define 的可行性。
#    - 設定讀取OK
#    - 思考是否可改成由外部設定檔案方式來做 list 概念 的批次處理方式。
#  - flutter 的編譯組態是否要開放?
#

## ================================== buildConfig function section : Begin ==================================
# ============= This is separation line =============
# @brief function : 剖析 required 部分，
#        如 : version，subcommands
# @detail : 簡易函式，不再處理細節的判斷，為保持正確性，參數請自行帶上 "".
#   - 拆解成獨立函式，但是內容跟此 shell 有高度相依，只是獨立函式容易閱讀。
# exported_Config_required_subcommands=([0]="aar" [1]="apk" [2]="appbundle" [3]="bundle" [4]="ios" [5]="ios-framework")
# @param $1: aSubcommand
# @param $2: exported_SubcommandInfo_xxx[0] : info 的 first : 為 subcommand name。
#   e.g. ${exported_SubcommandInfo_aar[0]} : aar
# @param $3: 要設定的參數，對應於 Subcommand Info : 是否要執行 (isExcute)。
#   e.g. exported_SubcommandInfo_aar[1] .
function dealSumcommandInfo() {

    local func_Title_Log="*** function [dealSumcommandInfo] -"
    local func_A_Subcommand=$1
    local func_SumcommandInfo_Name=$2

    # echo "${func_Title_Log} Before func_A_Subcommand : ${func_A_Subcommand} ***"
    # echo "${func_Title_Log} Before func_SumcommandInfo_Name : ${func_SumcommandInfo_Name} ***"
    # echo "${func_Title_Log} Before func_SubcommandInfo_IsExcute : $(eval echo \$${3}) ***"

    # 判斷是否為 要處理的 command (subcommand name 是否相同) .
    if [ ${func_A_Subcommand} = ${func_SumcommandInfo_Name} ]; then
        eval ${3}="Y"
    fi

    # echo "${func_Title_Log} func_A_Subcommand : ${func_A_Subcommand} ***"
    # echo "${func_Title_Log} Before func_SumcommandInfo_Name : ${func_SumcommandInfo_Name} ***"
    # echo "${func_Title_Log} func_SubcommandInfo_IsExcute : $(eval echo \$${3}) ***"
}

# ============= This is separation line =============
# @brief function : 剖析 required 部分，
#        如 : version，subcommands
# @detail : 簡易函式，不再處理細節的判斷，為保持正確性，參數請自行帶上 "".
#   - 拆解成獨立函式，但是內容跟此 shell 有高度相依，只是獨立函式容易閱讀。
# exported_Config_required_subcommands=([0]="aar" [1]="apk" [2]="appbundle" [3]="bundle" [4]="ios" [5]="ios-framework")
function parseReruiredSection() {

    echo
    echo "${exported_Title_Log} ============= parse required section : Begin ============="

    # check input parameters
    checkInputParam "${exported_Title_Log}" exported_Config_required_version "${exported_Config_required_version}"
    checkInputParam "${exported_Title_Log}" exported_Config_required_paths_work "${exported_Config_required_paths_work}"
    checkInputParam "${exported_Title_Log}" exported_Config_required_paths_output "${exported_Config_required_paths_output}"
    checkInputParam "${exported_Title_Log}" exported_Config_required_subcommands "${exported_Config_required_subcommands[@]}"

    echo
    echo "${exported_Title_Log} ============= Param : Begin ============="
    echo "${exported_Title_Log} exported_Config_required_version : ${exported_Config_required_version}"
    echo "${exported_Title_Log} exported_Config_required_paths_work : ${exported_Config_required_paths_work}"
    echo "${exported_Title_Log} exported_Config_required_paths_output : ${exported_Config_required_paths_output}"
    echo "${exported_Title_Log} exported_Config_required_subcommands : ${exported_Config_required_subcommands[@]}"
    echo "${exported_Title_Log} ============= Param : End ============="
    echo

    # for version
    splitStringToPair "${exported_Title_Log}" "${exported_Config_required_version}" "+" exported_BuildName exported_BuildNumber

    local i
    for ((i = 0; i < ${#exported_Config_required_subcommands[@]}; i++)); do #請注意 ((   )) 雙層括號

        local aSubcommand=${exported_Config_required_subcommands[$i]}

        # 判斷是否為 aar
        dealSumcommandInfo "${aSubcommand}" "${exported_SubcommandInfo_aar[0]}" exported_SubcommandInfo_aar[1]

        # 判斷是否為 apk
        dealSumcommandInfo "${aSubcommand}" "${exported_SubcommandInfo_apk[0]}" exported_SubcommandInfo_apk[1]

        # 判斷是否為 appbundle
        dealSumcommandInfo "${aSubcommand}" "${exported_SubcommandInfo_appbundle[0]}" exported_SubcommandInfo_appbundle[1]

        # 判斷是否為 bundle
        dealSumcommandInfo "${aSubcommand}" "${exported_SubcommandInfo_bundle[0]}" exported_SubcommandInfo_bundle[1]

        # 判斷是否為 ios
        dealSumcommandInfo "${aSubcommand}" "${exported_SubcommandInfo_ios[0]}" exported_SubcommandInfo_ios[1]

        # 判斷是否為 ios_framework
        dealSumcommandInfo "${aSubcommand}" "${exported_SubcommandInfo_ios_framework[0]}" exported_SubcommandInfo_ios_framework[1]

    done

    # check input parameters
    checkInputParam "${exported_Title_Log}" exported_BuildName "${exported_BuildName}"
    checkInputParam "${exported_Title_Log}" exported_BuildNumber "${exported_BuildNumber}"

    echo "${exported_Title_Log} exported_BuildName  : ${exported_BuildName}"
    echo "${exported_Title_Log} exported_BuildNumber : ${exported_BuildNumber}"

    # dump support sumcommand info
    echo "${exported_Title_Log} exported_SubcommandInfo_aar           : ${exported_SubcommandInfo_aar[@]}"
    echo "${exported_Title_Log} exported_SubcommandInfo_apk           : ${exported_SubcommandInfo_apk[@]}"
    echo "${exported_Title_Log} exported_SubcommandInfo_appbundle     : ${exported_SubcommandInfo_appbundle[@]}"
    echo "${exported_Title_Log} exported_SubcommandInfo_bundle        : ${exported_SubcommandInfo_bundle[@]}"
    echo "${exported_Title_Log} exported_SubcommandInfo_ios           : ${exported_SubcommandInfo_ios[@]}"
    echo "${exported_Title_Log} exported_SubcommandInfo_ios_framework : ${exported_SubcommandInfo_ios_framework[@]}"

    echo "${exported_Title_Log} ============= required section : End ============="
    echo

}

# ============= This is separation line =============
# @brief function : 剖析 dart-define
# @detail : 簡易函式，不再處理細節的判斷，為保持正確性，參數請自行帶上 "".
#   - 拆解成獨立函式，但是內容跟此 shell 有高度相依，只是獨立函式容易閱讀。
function parseDartDefine() {

    # 判斷是否有 dart-define 的設定:
    if [ -n "${exported_Config_optional_dart_define_defines}" ] && [ -n "${exported_Config_optional_dart_define_separator}" ]; then

        echo
        echo "${exported_Title_Log} ============= parse dart-define : Begin ============="

        # check input parameters
        checkInputParam "${exported_Title_Log}" exported_Config_optional_dart_define_defines "${exported_Config_optional_dart_define_defines[@]}"
        checkInputParam "${exported_Title_Log}" exported_Config_optional_dart_define_separator "${exported_Config_optional_dart_define_separator}"

        echo
        echo "${exported_Title_Log} ============= Param : Begin ============="
        echo "${exported_Title_Log} exported_Config_optional_dart_define_defines : ${exported_Config_optional_dart_define_defines[@]}"
        echo "${exported_Title_Log} exported_Config_optional_dart_define_separator : ${exported_Config_optional_dart_define_separator}"
        echo "${exported_Title_Log} ============= Param : End ============="
        echo

        local i
        for ((i = 0; i < ${#exported_Config_optional_dart_define_defines[@]}; i++)); do #請注意 ((   )) 雙層括號

            local aDefine=${exported_Config_optional_dart_define_defines[$i]}

            local aKey
            local aVal

            splitStringToPair "${exported_Title_Log}" "${aDefine}" "${exported_Config_optional_dart_define_separator}" aKey aVal

            # 第一次，尚未設定。
            if [ -z "${exported_DartDef_PartOf_Command}" ] && [ -z "${exported_DartDef_PartOf_FileName}" ]; then

                exported_DartDef_PartOf_Command="--dart-define=${aKey}=${aVal}"
                exported_DartDef_PartOf_FileName="${aKey}_${aVal}"

            else

                exported_DartDef_PartOf_Command="${exported_DartDef_PartOf_Command} --dart-define=${aKey}=${aVal}"
                exported_DartDef_PartOf_FileName="${exported_DartDef_PartOf_FileName}-${aKey}_${aVal}"

            fi

        done

        # check input parameters
        checkInputParam "${exported_Title_Log}" exported_DartDef_PartOf_Command "${exported_DartDef_PartOf_Command[@]}"
        checkInputParam "${exported_Title_Log}" exported_DartDef_PartOf_FileName "${exported_DartDef_PartOf_FileName}"

        echo "${exported_Title_Log} exported_DartDef_PartOf_Command  : ${exported_DartDef_PartOf_Command}"
        echo "${exported_Title_Log} exported_DartDef_PartOf_FileName : ${exported_DartDef_PartOf_FileName}"

        echo "${exported_Title_Log} ============= parse dart-define : End ============="
        echo

    fi
}
## ================================== buildConfig function section : End ==================================

## ================================== export function section : Begin ==================================
### ==================== NotyetSupportSubcommand : Begin ====================
# @brief 尚未支援的 subcommand 的通用函式
# @param $1 : command name
function export_NotyetSupportSubcommand() {

    local func_Title_Log="*** function [export_NotyetSupportSubcommand] -"

    # for echo color
    local func_Bold_Black='\033[1;30m'
    local func_ForegroundColor_Red='\033[0;31m'
    local func_BackgroundColor_Cyan='\033[46m'
    local func_Color_Off='\033[0m'

    # 暫存此區塊的起始時間。
    local func_Subcommand=${1}

    echo "${func_Bold_Black}${func_ForegroundColor_Red}${func_BackgroundColor_Cyan}${func_Title_Log} OPPS!! Notyet support this subcommand ( "${func_Subcommand}" ).\n    Please check your demand or make request that modify exported.sh to support this subcommand ( "${func_Subcommand}" ).\n    Error !!! ***${func_Color_Off}"

    # checkResultFail_And_ChangeFolder "${exported_Title_Log}" "10" "!!! ~ OPPS!! Not yet support this subcommand:  "${func_Subcommand}" => fail ~ !!!" "${exported_OldPath}"
}
### ==================== NotyetSupportSubcommand : End ====================

### ==================== aar : Begin ====================
# @brief exported aar 部分
function export_aar() {

    local func_Title_Log="*** function [export_aar] -"

    # 暫存此區塊的起始時間。
    local func_Temp_Seconds=${SECONDS}
    local func_Subcommand=${exported_SubcommandInfo_aar[0]}

    echo
    echo "${exported_Title_Log} ||==========> "${func_Subcommand}" : Begin <==========||"

    export_NotyetSupportSubcommand ${func_Subcommand}

    echo "${exported_Title_Log} ||==========> "${func_Subcommand}" : End <==========|| Elapsed time: $((${SECONDS} - ${func_Temp_Seconds}))s"
    echo
}
### ==================== aar : End ====================

### ==================== apk : Begin ====================
# @brief exported apk 部分
function export_apk() {

    # You are building a fat APK that includes binaries for android-arm,android-arm64, android-x64.
    # 之後要瘦身

    # 暫存此區塊的起始時間。
    local func_Temp_Seconds=${SECONDS}
    local func_Subcommand=${exported_SubcommandInfo_apk[0]}

    echo
    echo "${exported_Title_Log} ||==========> "${func_Subcommand}" : Begin <==========||"
    echo "${exported_Title_Log} 開始打包 "${func_Subcommand}""

    # ===> value 設定 <===
    # for android 參數
    local func_Android_VersionName="${exported_BuildName}"
    local func_Android_VersionCode="${exported_BuildNumber}"

    echo
    echo "${exported_Title_Log} ============= Value : Begin ============="
    echo "${exported_Title_Log} func_Android_VersionName : ${func_Android_VersionName}"
    echo "${exported_Title_Log} func_Android_VersionCode : ${func_Android_VersionCode}"
    echo "${exported_Title_Log} ============= Value : End ============="
    echo

    # ===> build apk <===
    echo "${exported_Title_Log} flutter build "${func_Subcommand}" --${exported_ToogleFeature_BuildConfigType} ..."

    # 設定基本的 command 內容.
    local func_Build_Command="build "${func_Subcommand}" --"${exported_ToogleFeature_BuildConfigType}" --build-name "${func_Android_VersionName}" --build-number "${func_Android_VersionCode}""

    # 若有 dart-define
    if [ -n "${exported_DartDef_PartOf_Command}" ]; then
        func_Build_Command="${func_Build_Command} ${exported_DartDef_PartOf_Command}"
    fi

    echo "${exported_Title_Log} flutter ${func_Build_Command}"
    flutter ${func_Build_Command}

    # check result - build apk
    checkResultFail_And_ChangeFolder "${exported_Title_Log}" "$?" "!!! ~ flutter build "${func_Subcommand}" => fail ~ !!!" "${exported_OldPath}"

    # ===> copy apk to destination folder <===
    echo "${exported_Title_Log} copy ${exported_ToogleFeature_BuildConfigType} "${func_Subcommand}" to output folder"

    # 設定基本的輸出檔案格式。
    local func_Build_FileName="Android-${exported_ToogleFeature_BuildConfigType}-${func_Android_VersionName}-${func_Android_VersionCode}"

    # 若有 dart-define
    if [ -n "${exported_DartDef_PartOf_FileName}" ]; then
        func_Build_FileName="${func_Build_FileName}-${exported_DartDef_PartOf_FileName}"
    fi

    # 補上結尾
    func_Build_FileName="${func_Build_FileName}-$(date "+%Y%m%d%H%M").apk"

    cp -r build/app/outputs/apk/${exported_ToogleFeature_BuildConfigType}/app-${exported_ToogleFeature_BuildConfigType}.apk "${exported_Config_required_paths_output}"/${func_Build_FileName}

    # check result - copy apk
    checkResultFail_And_ChangeFolder "${exported_Title_Log}" "$?" "!!! ~ copy "${func_Subcommand}" => fail ~ !!!" "${exported_OldPath}"

    echo "${exported_Title_Log} 打包 "${func_Subcommand}" 已經完成"
    echo "${exported_Title_Log} output file name : ${func_Build_FileName}"
    say "${exported_Title_Log} 打包 "${func_Subcommand}" 成功"

    echo
    echo "${exported_Title_Log} ||==========> "${func_Subcommand}" : End <==========|| Elapsed time: $((${SECONDS} - ${func_Temp_Seconds}))s"
    echo
}
### ==================== apk : End ====================

### ==================== appbundle : Begin ====================
# @brief exported appbundle 部分
function export_appbundle() {

    local func_Title_Log="*** function [export_appbundle] -"

    # 暫存此區塊的起始時間。
    local func_Temp_Seconds=${SECONDS}
    local func_Subcommand=${exported_SubcommandInfo_appbundle[0]}

    echo
    echo "${exported_Title_Log} ||==========> "${func_Subcommand}" : Begin <==========||"

    export_NotyetSupportSubcommand ${func_Subcommand}

    echo "${exported_Title_Log} ||==========> "${func_Subcommand}" : End <==========|| Elapsed time: $((${SECONDS} - ${func_Temp_Seconds}))s"
    echo
}
### ==================== appbundle : End ====================

### ==================== bundle : Begin ====================
# @brief exported bundle 部分
function export_bundle() {

    local func_Title_Log="*** function [export_bundle] -"

    # 暫存此區塊的起始時間。
    local func_Temp_Seconds=${SECONDS}
    local func_Subcommand=${exported_SubcommandInfo_bundle[0]}

    echo
    echo "${exported_Title_Log} ||==========> "${func_Subcommand}" : Begin <==========||"

    export_NotyetSupportSubcommand ${func_Subcommand}

    echo "${exported_Title_Log} ||==========> "${func_Subcommand}" : End <==========|| Elapsed time: $((${SECONDS} - ${func_Temp_Seconds}))s"
    echo
}
### ==================== bundle : End ====================

### ==================== ios : Begin ====================
# @brief ios 部分
function export_ios() {

    local func_Title_Log="*** function [export_ios] -"

    # 暫存此區塊的起始時間。
    local func_Temp_Seconds=${SECONDS}
    local func_Subcommand=${exported_SubcommandInfo_ios[0]}

    echo
    echo "${exported_Title_Log} ||==========> "${func_Subcommand}" : Begin <==========||"
    echo "${exported_Title_Log} 開始打包 "${func_Subcommand}""

    # ===> value 設定 <===
    # for android 參數
    local func_iOS_BundleShortVersion="${exported_BuildName}"
    local func_iOS_BundleVersion="${func_iOS_BundleShortVersion}.${exported_BuildNumber}"

    echo
    echo "${exported_Title_Log} ============= Value : Begin ============="
    echo "${exported_Title_Log} func_iOS_BundleShortVersion : ${func_iOS_BundleShortVersion}"
    echo "${exported_Title_Log} func_iOS_BundleVersion      : ${func_iOS_BundleVersion}"
    echo "${exported_Title_Log} ============= Value : End ============="
    echo

    # ===> build ios <===
    echo "${exported_Title_Log} flutter build "${func_Subcommand}" --${exported_ToogleFeature_BuildConfigType} ..."

    # 設定基本的 command 內容.
    local func_Build_Command="build "${func_Subcommand}" --"${exported_ToogleFeature_BuildConfigType}" --build-name "${func_iOS_BundleShortVersion}" --build-number "${func_iOS_BundleVersion}""

    # 若有 dart-define
    if [ -n "${exported_DartDef_PartOf_Command}" ]; then
        func_Build_Command="${func_Build_Command} ${exported_DartDef_PartOf_Command}"
    fi

    echo "${exported_Title_Log} flutter ${func_Build_Command}"
    flutter ${func_Build_Command}

    # check result - build ios
    checkResultFail_And_ChangeFolder "${exported_Title_Log}" "$?" "!!! ~ flutter build ios => fail ~ !!!" "${exported_OldPath}"

    # ===> zip Payload to destination folder <===
    if [ -d build/ios/iphoneos/Runner.app ]; then

        # 切換到 輸出目錄，再打包才不會包到不該包的資料夾。
        changeToDirectory "${exported_Title_Log}" "${exported_Config_required_paths_output}"

        # 打包 ipa 的固定資料夾名稱。
        mkdir Payload

        cp -r "${exported_Flutter_WorkPath}"/build/ios/iphoneos/Runner.app "${exported_Config_required_paths_output}"/Payload

        # check result - copy iOS Payload
        checkResultFail_And_ChangeFolder "${exported_Title_Log}" "$?" "!!! ~ copy iOS Payload => fail ~ !!!" "${exported_OldPath}"

        # 設定基本的輸出檔案格式。
        local func_Build_FileName="iOS-${exported_ToogleFeature_BuildConfigType}-${func_iOS_BundleVersion}"

        # 若有 dart-define
        if [ -n "${exported_DartDef_PartOf_FileName}" ]; then
            func_Build_FileName="${func_Build_FileName}-${exported_DartDef_PartOf_FileName}"
        fi

        # 補上結尾
        func_Build_FileName="${func_Build_FileName}-$(date "+%Y%m%d%H%M").ipa"

        # zip -r -m iOS-${exported_ToogleFeature_BuildConfigType}-${func_iOS_BundleVersion}-${exported_Param_DartDef_Val_GitHash}-$(date "+%Y%m%d%H%M").ipa Payload
        zip -r -m ${func_Build_FileName} Payload

        # check result - zip iOS Payload
        checkResultFail_And_ChangeFolder "${exported_Title_Log}" "$?" "!!! ~ zip iOS Payload => fail ~ !!!" "${exported_OldPath}"

        # 切換到 flutter work path
        changeToDirectory "${exported_Title_Log}" "${exported_Flutter_WorkPath}"

        echo "${exported_Title_Log} 打包 "${func_Subcommand}" 很順利 😄"
        say "${exported_Title_Log} 打包 "${func_Subcommand}" 成功"

    else

        echo "${exported_Title_Log} 遇到報錯了 😭, 打開 Xcode 查找錯誤原因"
        say "${exported_Title_Log} 打包 "${func_Subcommand}" 失敗"

        # check result - copy ios
        checkResultFail_And_ChangeFolder "${exported_Title_Log}" "100" "!!! ~ Not found build/ios/iphoneos/Runner.app => fail ~ !!!" "${exported_OldPath}"
    fi

    echo
    echo "${exported_Title_Log} ||==========> "${func_Subcommand}" : End <==========|| Elapsed time: $((${SECONDS} - ${func_Temp_Seconds}))s"
    echo
}
### ==================== ios : End ====================

### ==================== ios_framework : Begin ====================
# @brief exported ios_framework 部分
function export_ios_framework() {

    local func_Title_Log="*** function [export_ios_framework] -"

    # 暫存此區塊的起始時間。
    local func_Temp_Seconds=${SECONDS}
    local func_Subcommand=${exported_SubcommandInfo_ios_framework[0]}

    echo
    echo "${exported_Title_Log} ||==========> "${func_Subcommand}" : Begin <==========||"

    export_NotyetSupportSubcommand ${func_Subcommand}

    echo "${exported_Title_Log} ||==========> "${func_Subcommand}" : End <==========|| Elapsed time: $((${SECONDS} - ${func_Temp_Seconds}))s"
    echo
}
### ==================== ios_framework : End ====================
## ================================== export function section : End ==================================

## ================================== prcess function section : Begin ==================================
# ============= This is separation line =============
# @brief function : [程序] 此 shell 的初始化。
function process_Init() {

    # 計時，實測結果不同 shell 不會影響，各自有各自的 SECONDS。
    SECONDS=0

    # 此 shell 的 dump log title.
    exported_Title_Log="[exported] -"

    echo
    echo "${exported_Title_Log} ||==========> exported : Begin <==========||"

    # 取得相對目錄.
    local func_Shell_WorkPath=$(dirname $0)

    echo
    echo "${exported_Title_Log} func_Shell_WorkPath : ${func_Shell_WorkPath}"

    # 前置處理作業

    # import function
    # 因使用 include 檔案的函式，所以在此之前需先確保路經是在此 shell 資料夾中。
    # import general function
    echo
    echo "${exported_Title_Log} import general function"
    . "${func_Shell_WorkPath}"/../generalTools.sh

    # import parse_yaml function
    echo
    echo "${exported_Title_Log} import parse_yaml function"

    # 同樣在 scm.tools 專案下的相對路徑。
    . "${func_Shell_WorkPath}"/../../../submodules/bash-yaml/script/yaml.sh

    # 設定原先的呼叫路徑。
    exported_OldPath=$(pwd)

    # 切換執行目錄.
    changeToDirectory "${exported_Title_Log}" "${func_Shell_WorkPath}"

    # 設定成完整路徑。
    exported_Shell_WorkPath=$(pwd)

    echo "${exported_Title_Log} exported_OldPath : "${exported_OldPath}""
    echo "${exported_Title_Log} exported_Shell_WorkPath : "${exported_Shell_WorkPath}""
    echo
}

# ============= This is separation line =============
# @brief function : [程序] 處理 input param。
function process_Deal_InputParam() {

    # set input param variable
    exported_Param_BuildConfigFile="${1}"

    # check input parameters
    checkInputParam "${exported_Title_Log}" exported_Param_BuildConfigFile "${exported_Param_BuildConfigFile}"

    echo
    echo "${exported_Title_Log} ============= Param : Begin ============="
    echo "${exported_Title_Log} exported_Param_BuildConfigFile : ${exported_Param_BuildConfigFile}"
    echo "${exported_Title_Log} ============= Param : End ============="
    echo
}

# ============= This is separation line =============
# @brief function : [程序] Toggle Feature 設定。
function process_Deal_ToggleFeature() {

    # 是否開啟 dump set 內容，當 parse build config file 時，會去判斷。
    exported_ToogleFeature_IsDumpSet_When_Parse_BuildConfigFile="N"

    # build configutation type : 編譯組態設定，之後視情況是否要開放
    # 依據 flutter build ， 有 debug ， profile ， release
    exported_ToogleFeature_BuildConfigType=release

    echo
    echo "${exported_Title_Log} ============= Toogle Feature : Begin ============="
    echo "${exported_Title_Log} exported_ToogleFeature_IsDumpSet_When_Parse_BuildConfigFile : ${exported_ToogleFeature_IsDumpSet_When_Parse_BuildConfigFile}"
    echo "${exported_Title_Log} exported_ToogleFeature_BuildConfigType : ${exported_ToogleFeature_BuildConfigType}"
    echo "${exported_Title_Log} ============= Toogle Feature : End ============="
    echo

}

# ============= This is separation line =============
# @brief function : [程序] SubcommandInfo 的初始化。
function process_Init_SubcommandInfo() {

    # 設定目前支援的 subcomand
    # exported_Config_required_subcommands=([0]="aar" [1]="apk" [2]="appbundle" [3]="bundle" [4]="ios" [5]="ios-framework")
    # 規則 :
    #   [0] : build subcommand name
    #   [1]: 是否要執行 (isExcute)。
    # 目前只支援 apk 及 ios，之後視情況新增。
    exported_SubcommandInfo_aar=("aar" "N")
    exported_SubcommandInfo_apk=("apk" "N")
    exported_SubcommandInfo_appbundle=("appbundle" "N")
    exported_SubcommandInfo_bundle=("bundle" "N")
    exported_SubcommandInfo_ios=("ios" "N")
    exported_SubcommandInfo_ios_framework=("ios-framework" "N")
}

# ============= This is separation line =============
# @brief function : [程序] 剖析 build config。
function process_Parse_BuildConfig() {

    # 判斷 build config file
    # 字串是否不為空。 (a non-empty string)
    # TODO: flutter build apk --target-platform android-arm,android-arm64
    # TODO: 之後可調整成函式，並去除判斷是否存在，Build Config File 會變成必要資訊。
    if [ -n "${exported_Param_BuildConfigFile}" ]; then

        echo
        echo "${exported_Title_Log} ============= parse build config file : Begin ============="

        # parse build config file
        echo "${exported_Title_Log} 將剖析 Build Config File 來做細微的設定。"

        create_variables "${exported_Param_BuildConfigFile}" "exported_Config_"

        # 開啟可以抓到此 shell 目前有哪些設定值。
        if [ ${exported_ToogleFeature_IsDumpSet_When_Parse_BuildConfigFile} = "Y" ]; then
            set >${exported_Param_BuildConfigFile}_BeforeParseConfig.temp
        fi

        # parse required section
        parseReruiredSection

        # parse dart define
        parseDartDefine

        # 開啟可以抓到此 shell 目前有哪些設定值。
        if [ ${exported_ToogleFeature_IsDumpSet_When_Parse_BuildConfigFile} = "Y" ]; then
            set >${exported_Param_BuildConfigFile}_AfterParseConfig.temp
        fi

        echo "${exported_Title_Log} ============= parse build config file : End ============="
        echo

        # FIXME
        # exit 1
    fi

}

# ============= This is separation line =============
# @brief function : [程序] 處理路徑相關 (包含 flutter work path)。
function process_Deal_Paths() {

    # 切換到 config file 設定的 flutter project work path: 為 flutter 專案的工作目錄 shell 目錄 (之後會切回到原有呼叫的目錄)
    changeToDirectory "${exported_Title_Log}" "${exported_Config_required_paths_work}"
    exported_Flutter_WorkPath=$(pwd)

    echo
    echo "${exported_Title_Log} //========== dump paths : Begin ==========//"
    echo "${exported_Title_Log} exported_OldPath                      : ${exported_OldPath}"
    echo "${exported_Title_Log} exported_Shell_WorkPath               : ${exported_Shell_WorkPath}"
    echo "${exported_Title_Log} exported_Config_required_paths_work   : ${exported_Config_required_paths_work}"
    echo "${exported_Title_Log} exported_Flutter_WorkPath             : ${exported_Flutter_WorkPath}"
    echo "${exported_Title_Log} exported_Config_required_paths_output : ${exported_Config_required_paths_output}"
    echo "${exported_Title_Log} current path                          : $(pwd)"
    echo "${exported_Title_Log} //========== dump paths : End ==========//"
}

# ============= This is separation line =============
# @brief function : [程序] 清除緩存 (之前編譯的暫存檔)。
function process_Clean_Cache() {

    # 以 exported_Flutter_WorkPath 為工作目錄來執行
    # 先期準備，刪除舊的資料

    echo "${exported_Title_Log} 刪除 build"
    find . -d -name "build" | xargs rm -rf
    flutter clean
    rm -rf build
}

# ============= This is separation line =============
# @brief function : [程序] 執行 build subcommands。
# @details : 依照 build config 的設定來 執行 build subcommand。
function process_Excecute_Build_Sumcommands() {

    # 判斷是否要出版 aar
    check_OK_Then_Excute_Command "${exported_Title_Log}" ${exported_SubcommandInfo_aar[1]} export_aar

    # 判斷是否要出版 apk
    check_OK_Then_Excute_Command "${exported_Title_Log}" ${exported_SubcommandInfo_apk[1]} export_apk

    # 判斷是否要出版 appbundle
    check_OK_Then_Excute_Command "${exported_Title_Log}" ${exported_SubcommandInfo_appbundle[1]} export_appbundle

    # 判斷是否要出版 bundle
    check_OK_Then_Excute_Command "${exported_Title_Log}" ${exported_SubcommandInfo_bundle[1]} export_bundle

    # 判斷是否要出版 ios
    check_OK_Then_Excute_Command "${exported_Title_Log}" ${exported_SubcommandInfo_ios[1]} export_ios

    # 判斷是否要出版 ios_framework
    check_OK_Then_Excute_Command "${exported_Title_Log}" ${exported_SubcommandInfo_ios_framework[1]} export_ios_framework
}

# ============= This is separation line =============
# @brief function : [程序] shell 全部完成需處理的部份.
function process_Finish() {

    # 全部完成
    # 切回原有執行目錄.
    changeToDirectory "${exported_Title_Log}" "${exported_OldPath}"

    echo
    echo "${exported_Title_Log} ||==========> exported : End <==========|| Elapsed time: ${SECONDS}s"
}
## ================================== prcess function section : End ==================================

## ================================== deal prcess step section : Begin ==================================
# ============= This is separation line =============
# call - [程序] 此 shell 的初始化。
process_Init

# ============= This is separation line =============
# call - [程序] 處理 input param。
# 需要帶入此 shell 的輸入參數。
# TODO: 可思考是否有更好的方式？
process_Deal_InputParam "${1}"

# ============= This is separation line =============
# call - [程序] Toggle Feature 設定。
process_Deal_ToggleFeature

# ============= This is separation line =============
# call - [程序] SubcommandInfo 的初始化。
process_Init_SubcommandInfo

# ============= This is separation line =============
# call - [程序] 剖析 build config。
process_Parse_BuildConfig

# ============= This is separation line =============
# call - [程序] 處理路徑相關 (包含 flutter work path)。
process_Deal_Paths

# ============= This is separation line =============
# call - [程序] 清除緩存 (之前編譯的暫存檔)。
process_Clean_Cache

# ============= This is separation line =============
# call - [程序] 執行 build subcommands。
process_Excecute_Build_Sumcommands

# ============= This is separation line =============
# call - [程序] shell 全部完成需處理的部份.
process_Finish
## ================================== deal prcess step section : End ==================================

exit 0
