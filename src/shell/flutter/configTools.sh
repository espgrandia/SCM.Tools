#!/bin/bash

# ============= This is separation line =============
# @brief : flutter exported.sh 會用到的 build config 工具.
# @details : 放置常用產出部分 build config 內容的工具函式，使用者可以引用此檔案來使用函式.
# @author : esp
# @create date : 2020-10-20
#
# ---
#
# @sa:
#  與 configConst.sh 有相依性。
#  需於 import configTools.sh 或呼叫相關函式前，
#  確保有 import configConst.sh
#  使用範例可參考下方的 @sample
#
# ---
#
# @sample :
#  ``` shell
#  # import configConst.sh for configTools.sh using export Environment Variable。
#    . flutter/configConst.sh
#
#  # import configTools_Gen_Required function
#  . flutter/configTools.sh
#
#  configTools_Gen_Required ... 細節看個函式的說明
#  ```
#
# ---
#
# Reference :
# - title: Bash pass array as function parameter
#  - https://zybuluo.com/ysongzybl/note/93889
# - title: Shell: 传数组给函数, 函数接受数组参数,Passing array to function of shell script - Just Code
#  - http://justcode.ikeepstudying.com/2018/10/shell-%e4%bc%a0%e6%95%b0%e7%bb%84%e7%bb%99%e5%87%bd%e6%95%b0-%e5%87%bd%e6%95%b0%e6%8e%a5%e5%8f%97%e6%95%b0%e7%bb%84%e5%8f%82%e6%95%b0passing-array-to-function-of-shell-script/
#
# @附註 : 與 exported.sh 的 config 有關的產生函式，
#

## ================================== buildConfig key section : Begin ==================================
# for config key
export configTools_Optional="optional"

## ================================== buildConfig key section : End ==================================

# ============= This is separation line =============
# @brief function : configTools_Gen_Required.
# @detail : 簡易函式，不再處理細節的判斷，為保持正確性，參數請自行帶上 "".
# @param ${1} : file path : 要輸出的檔案位置 (含檔名)
# @param ${2} : flutter project work path : 指的是 flutter 專案目錄的路徑。
# @param ${3} : output path : 指的是 輸出的資料夾路徑。
# @param ${4} : version : 對應 pubspec.yaml 的版本號碼。=> e.g. 1.0.0+0
# @param ${!5} : subcommands : 對應 flutter subcommands : (aar apk appbundle bundle ios ios-framework)
#   => e.g. sample_Subcommands=(apk ios)
#   => sa 可參考 configCost.sh configConst_Subcommand_xxx 來設定。
#
# sample e.g. configTools_Gen_Required "${sample_FilePath}" "${sample_WorkPath}" "${sample_OutputPath}" "${sample_Pubspec_version}" sample_Subcommands[@]
function configTools_Gen_Required() {

    local func_Title_Log="*** function [configTools_Gen_Required] -"

    echo
    echo "${func_Title_Log} Begin ***"
    echo "${func_Title_Log} Input param : Begin ***"
    echo "${func_Title_Log} file path : "${1}""
    echo "${func_Title_Log} project work path : "${2}""
    echo "${func_Title_Log} output path : "${3}""
    echo "${func_Title_Log} version : "${4}""
    echo "${func_Title_Log} subcommands : ("${!5}")"
    echo "${func_Title_Log} Input param : End ***"

    # for local varient
    local func_Param_FilePath="${1}"
    local func_Param_WorkPath="${2}"
    local func_Param_OutputPath="${3}"
    local func_Param_Version="${4}"
    local func_Param_Subcommands=("${!5}")

    # for base key，最上層的 key
    local func_Required="required"

    # [required] [paths] : 有關路徑的設定。
    local func_Required_Key_Paths="paths"
    local func_Required_Key_Paths_Work="work"
    local func_Required_Key_Paths_Output="output"

    # for required
    # [required] [version]: 版本資訊 : 一般對應於 flutter pubspec.yaml 中的 version。
    local func_Required_Key_Version="version"

    # [required] [subcommands]: 編譯不同的版本 : build sumcommand (like as : apk, ios, ...)。
    local func_Required_Key_Subcommands="subcommands"

    # 輸出檔案格式為 yaml，尚未找到可以方便由 shell 寫 yaml 的方式，先用兜的。

    # for [required]:
    echo "# ${func_Required} section" >>"${func_Param_FilePath}"
    echo "${func_Required} :" >>"${func_Param_FilePath}"

    ## for [required] [paths]:
    echo "" >>"${func_Param_FilePath}"
    echo "  # [${func_Required_Key_Paths}] : 有關路徑的設定" >>"${func_Param_FilePath}"
    echo "  ${func_Required_Key_Paths} :" >>"${func_Param_FilePath}"

    ### for [required] [paths] [work]:
    echo "    # [${func_Required_Key_Paths_Work}] : flutter 專案目錄的路徑 : 一般與 flutter pubspec.yaml 同一個資料夾路徑" >>"${func_Param_FilePath}"
    echo "    ${func_Required_Key_Paths_Work} : "${func_Param_WorkPath}"" >>"${func_Param_FilePath}"

    ### for [required] [paths] [output]:
    echo "" >>"${func_Param_FilePath}"
    echo "    # [${func_Required_Key_Paths_Output}] : 輸出資料夾 [需帶完整路徑] : apk，ipa 等輸出的資料夾位置 => e.g. [專案路徑]/[scm]/output" >>"${func_Param_FilePath}"
    echo "    ${func_Required_Key_Paths_Output} : "${func_Param_OutputPath}"" >>"${func_Param_FilePath}"

    ## for [required] [version]:
    echo "" >>"${func_Param_FilePath}"
    echo "  # [${func_Required_Key_Version}] : 版本資訊 : 一般對應於 flutter pubspec.yaml 中的 version" >>"${func_Param_FilePath}"
    echo "  ${func_Required_Key_Version} : ${func_Param_Version}" >>"${func_Param_FilePath}"

    ## for [required] [subcommands]:
    echo "" >>"${func_Param_FilePath}"
    echo "  # [${func_Required_Key_Subcommands}] : build sumcommand (like as : ${configConst_Subcommand_apk}, ${configConst_Subcommand_ios}, ...)" >>"${func_Param_FilePath}"
    echo "  ${func_Required_Key_Subcommands} :" >>"${func_Param_FilePath}"

    local func_i
    for ((func_i = 0; func_i < ${#func_Param_Subcommands[@]}; func_i++)); do #請注意 ((   )) 雙層括號

        local aSubcommand=${func_Param_Subcommands[${func_i}]}
        echo "    - ${aSubcommand}" >>"${func_Param_FilePath}"

    done

    echo "${func_Title_Log} End ***"
    echo
}

# ============= This is separation line =============
# @brief function : configTools_Gen_Optional_ReportFilePath.
# @detail : 簡易函式，不再處理細節的判斷，為保持正確性，參數請自行帶上 "".
#  - exported.sh 的 Report File Path 為 markdown 語法撰寫，附檔名請設定為 .md
#  - 若 build config file 沒有設定 report file，則會以 build config file 加上後綴，"xxx.yaml.report.md"
# @param $1 : file path : 要輸出的檔案位置 (含檔名)
# @param $2 : report file path : 指定 exported.sh 的 report file path (含檔名)。
#
# sample e.g. configTools_Gen_Optional_ReportFilePath "${sample_FilePath}" "${sample_ReportFilePath}"
function configTools_Gen_Optional_ReportFilePath() {

    local func_Title_Log="*** function [configTools_Gen_Optional_Dart_Define] -"

    echo
    echo "${func_Title_Log} Begin ***"
    echo "${func_Title_Log} Input param : Begin ***"
    echo "${func_Title_Log} file path : "${1}""
    echo "${func_Title_Log} report file path : "${2}""
    echo "${func_Title_Log} Input param : End ***"

    # for local varient
    local func_Param_FilePath="${1}"
    local func_Param_ReportFilePath="${2}"

    # 輸出檔案格式為 yaml，尚未找到可以方便由 shell 寫 yaml 的方式，先用兜的。

    # for flavor
    func_Optional_Key_ReportFilePath=report_path

    echo "" >>"${func_Param_FilePath}"
    echo "# ${configTools_Optional} [${func_Optional_Key_ReportFilePath}] sction" >>"${func_Param_FilePath}"
    echo "# - [${func_Optional_Key_ReportFilePath}] : exported.sh 額外會用到的參數，指定 report file path (含檔名)。" >>"${func_Param_FilePath}"
    echo "# - 為 markdown 語法撰寫，沒設定會有預設檔案名稱。" >>"${func_Param_FilePath}"    
    echo "${configTools_Optional} :" >>"${func_Param_FilePath}"
    echo "  ${func_Optional_Key_ReportFilePath} : ${func_Param_ReportFilePath}" >>"${func_Param_FilePath}"

    echo "${func_Title_Log} End ***"
    echo
}

# ============= This is separation line =============
# @brief function : configTools_Gen_Optional_BuildConfigType.
# @detail : 簡易函式，不再處理細節的判斷，為保持正確性，參數請自行帶上 "".
# @param $1 : file path : 要輸出的檔案位置 (含檔名)
# @param ${!2} : buildConfigTypes : 對應 flutter build config types : (debug profile release)
# 依據 flutter build ， 有 debug ， profile ， release
#   => e.g. sample_BuildConfigTypes=(debug release)
#   => sa 可參考 configCost.sh configConst_BuildConfigType_xxx 來設定。
#
# sample e.g. configTools_Gen_Optional_BuildConfigType "${sample_FilePath}" sample_BuildConfigTypes[@]
function configTools_Gen_Optional_BuildConfigType() {

    local func_Title_Log="*** function [configTools_Gen_Optional_BuildConfigType] -"

    echo
    echo "${func_Title_Log} Begin ***"
    echo "${func_Title_Log} Input param : Begin ***"
    echo "${func_Title_Log} file path : "${1}""
    echo "${func_Title_Log} build config types : ("${!2}")"
    echo "${func_Title_Log} Input param : End ***"

    # for local varient
    local func_Param_FilePath="${1}"
    local func_Param_BuildConfigTypes=("${!2}")

    # 輸出檔案格式為 yaml，尚未找到可以方便由 shell 寫 yaml 的方式，先用兜的。

    # for buildConfigTypes
    local func_Optional_Key_BuildConfigType="build_config_types"

    echo "" >>"${func_Param_FilePath}"
    echo "# ${configTools_Optional} [${func_Optional_Key_BuildConfigType}] sction" >>"${func_Param_FilePath}"
    echo "# - [${func_Optional_Key_BuildConfigType}] : build config type (like as : ${configConst_BuildConfigType_Debug}, ${configConst_BuildConfigType_Profile}, ${configConst_BuildConfigType_Release})" >>"${func_Param_FilePath}"
    echo "# - support subcommands: ${configConst_Subcommand_apk}, ${configConst_Subcommand_appbundle}, ${configConst_Subcommand_bundle}, ${configConst_Subcommand_ios}" >>"${func_Param_FilePath}"
    echo "${configTools_Optional} :" >>"${func_Param_FilePath}"

    echo "  ${func_Optional_Key_BuildConfigType} :" >>"${func_Param_FilePath}"

    local func_i
    for ((func_i = 0; func_i < ${#func_Param_BuildConfigTypes[@]}; func_i++)); do #請注意 ((   )) 雙層括號

        local aBuildConfigType=${func_Param_BuildConfigTypes[${func_i}]}
        echo "    - ${aBuildConfigType}" >>"${func_Param_FilePath}"

    done

    echo "${func_Title_Log} End ***"
    echo
}

# ============= This is separation line =============
# @brief function : configTools_Gen_Optional_Dart_Define.
# @detail : 簡易函式，不再處理細節的判斷，為保持正確性，參數請自行帶上 "".
# @param $1 : file path : 要輸出的檔案位置 (含檔名)
# @param $2 : separator : 分隔符號，不判斷，單純設定，外面需決定好內容。=> e.g. "+"
# @param $3 : defines : 兜好 [key][separator][value的內容]
#   => e.g. sample_DartDefines=(gitHash+920f6fc envName+dev)
#
# sample e.g. configTools_Gen_Optional_Dart_Define "${sample_FilePath}" "${sample_Separator}" sample_DartDefines[@]
function configTools_Gen_Optional_Dart_Define() {

    local func_Title_Log="*** function [configTools_Gen_Optional_Dart_Define] -"

    echo
    echo "${func_Title_Log} Begin ***"
    echo "${func_Title_Log} Input param : Begin ***"
    echo "${func_Title_Log} file path : "${1}""
    echo "${func_Title_Log} separator : "${2}""
    echo "${func_Title_Log} ${configConst_BuildParam_Key_DartDefine} values : ("${!3}")"
    echo "${func_Title_Log} Input param : End ***"

    # for local varient
    local func_Param_FilePath="${1}"
    local func_Param_Separator="${2}"
    local func_Param_Defines=("${!3}")

    # for [optional]
    # [optional] [dart-define] : dart-define 會用到的內容，為 list 型態，{key}{separator}{value}
    local func_Optional_Key_DartDef="dart_define"
    local func_Optional_Key_DartDef_Key_Separator="separator"
    local func_Optional_Key_DartDef_Key_Defines="defines"

    # 輸出檔案格式為 yaml，尚未找到可以方便由 shell 寫 yaml 的方式，先用兜的。

    # for dart-define
    echo "" >>"${func_Param_FilePath}"
    echo "# ${configTools_Optional} [${func_Optional_Key_DartDef}] sction" >>"${func_Param_FilePath}"
    echo "# - [${func_Optional_Key_DartDef}] : ${configConst_BuildParam_Key_DartDefine} 會用到的內容，為 list 型態，{key}{separator}{value}" >>"${func_Param_FilePath}"
    echo "# - support subcommands: ${configConst_Subcommand_apk}, ${configConst_Subcommand_appbundle}, ${configConst_Subcommand_ios}, ${configConst_Subcommand_ios_framework}" >>"${func_Param_FilePath}"
    echo "${configTools_Optional} :" >>"${func_Param_FilePath}"
    echo "  ${func_Optional_Key_DartDef} :" >>"${func_Param_FilePath}"
    echo "    ${func_Optional_Key_DartDef_Key_Separator} : ${func_Param_Separator}" >>"${func_Param_FilePath}"
    echo "    ${func_Optional_Key_DartDef_Key_Defines} :" >>"${func_Param_FilePath}"

    local func_i
    for ((func_i = 0; func_i < ${#func_Param_Defines[@]}; func_i++)); do #請注意 ((   )) 雙層括號

        local aDefine=${func_Param_Defines[${func_i}]}
        echo "      - ${aDefine}" >>"${func_Param_FilePath}"

    done

    echo "${func_Title_Log} End ***"
    echo
}

# ============= This is separation line =============
# @brief function : configTools_Gen_Optional_Dart_Define.
# @detail : 簡易函式，不再處理細節的判斷，為保持正確性，參數請自行帶上 "".
# @param $1 : file path : 要輸出的檔案位置 (含檔名)
# @param $2 : flavor : flutter flavor 的設定內容 => e.g. "Runner"
#
# sample e.g. configTools_Gen_Optional_Flavor "${sample_FilePath}" "${sample_Flavor}"
function configTools_Gen_Optional_Flavor() {

    local func_Title_Log="*** function [configTools_Gen_Optional_Dart_Define] -"

    echo
    echo "${func_Title_Log} Begin ***"
    echo "${func_Title_Log} Input param : Begin ***"
    echo "${func_Title_Log} file path : "${1}""
    echo "${func_Title_Log} ${configConst_BuildParam_Key_Flavor} value : "${2}""
    echo "${func_Title_Log} Input param : End ***"

    # for local varient
    local func_Param_FilePath="${1}"
    local func_Param_Flavor="${2}"

    # 輸出檔案格式為 yaml，尚未找到可以方便由 shell 寫 yaml 的方式，先用兜的。

    # for flavor
    func_Optional_Key_Flavor=flavor

    echo "" >>"${func_Param_FilePath}"
    echo "# ${configTools_Optional} [${func_Optional_Key_Flavor}] sction" >>"${func_Param_FilePath}"
    echo "# - [${func_Optional_Key_Flavor}] : ${configConst_BuildParam_Key_flavor} 會用到的內容，對應於 flutter build 的 flavor 參數" >>"${func_Param_FilePath}"
    echo "# - support subcommands: ${configConst_Subcommand_aar}, ${configConst_Subcommand_apk}, ${configConst_Subcommand_appbundle}, ${configConst_Subcommand_bundle}, ${configConst_Subcommand_ios}, ${configConst_Subcommand_ios_framework}" >>"${func_Param_FilePath}"
    echo "${configTools_Optional} :" >>"${func_Param_FilePath}"
    echo "  ${func_Optional_Key_Flavor} : ${func_Param_Flavor}" >>"${func_Param_FilePath}"

    echo "${func_Title_Log} End ***"
    echo
}

# ============= This is separation line =============
# @brief function : configTools_Gen_Optional_Target_Platform.
# @detail : 簡易函式，不再處理細節的判斷，為保持正確性，參數請自行帶上 "".
# @param $1 : file path : 要輸出的檔案位置 (含檔名)
# @param $2 : platforms : flutter --target-platform 的設定內容 => e.g. "android-arm,android-arm64"
# TODO: flutter build apk --target-platform android-arm,android-arm64
#
# sample e.g. configTools_Gen_Optional_Flavor "${sample_FilePath}" "${sample_Target_Platform}"
# @sa :
#      --target-platform                             The target platform for which the project is compiled.
#                                                  [android-arm (default), android-arm64 (default), android-x86, android-x64 (default)]
function configTools_Gen_Optional_Target_Platform() {

    local func_Title_Log="*** function [configTools_Gen_Optional_Target_Platform] -"

    echo
    echo "${func_Title_Log} Begin ***"
    echo "${func_Title_Log} Input param : Begin ***"
    echo "${func_Title_Log} file path : "${1}""
    echo "${func_Title_Log} ${configConst_BuildParam_Key_TargetPlatform} values : "${2}""
    echo "${func_Title_Log} Input param : End ***"

    # for local varient
    local func_Param_FilePath="${1}"
    local func_Param_Target_Platform="${2}"

    # 輸出檔案格式為 yaml，尚未找到可以方便由 shell 寫 yaml 的方式，先用兜的。

    # for base key，最上層的 key
    local func_Optional="optional"

    # for target-platform
    func_Optional_Key_TargetPlatform=target_platform

    echo "" >>"${func_Param_FilePath}"
    echo "# ${configTools_Optional} [${func_Optional_Key_TargetPlatform}] sction" >>"${func_Param_FilePath}"
    echo "# - [${func_Optional_Key_TargetPlatform}] : ${configConst_BuildParam_Key_TargetPlatform} 會用到的內容，對應於 flutter build 的 target-platform 參數" >>"${func_Param_FilePath}"
    echo "# - support subcommands: ${configConst_Subcommand_aar}, ${configConst_Subcommand_apk}, ${configConst_Subcommand_appbundle}, ${configConst_Subcommand_bundle}" >>"${func_Param_FilePath}"
    echo "${configTools_Optional} :" >>"${func_Param_FilePath}"
    echo "  ${func_Optional_Key_TargetPlatform} : ${func_Param_Target_Platform}" >>"${func_Param_FilePath}"

    echo "${func_Title_Log} End ***"
    echo
}

# TODO:
# target : "lib/main_abc.dart"
