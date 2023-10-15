#!/bin/bash

# ============= This is separation line =============
# @brief : flutter exported.sh 會用到的 build config 工具。
# @details : 放置常用產出部分 build config 內容的工具函式，使用者可以引用此檔案來使用函式。
# @author : esp
# @create date : 2020-10-20
#
# ---
#
# 注意事項:
# - 使用此通用函式，有相依 include 檔案於
#   - scm.tools/src/shell/general_const.sh
#   - configConst.sh
#   - include 方式 :
#     - 需自行 include general_const.sh
#     - 需自行 include configTools.sh
#     - 再 include releaseNoteTools.sh
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
#  # import config_tools_gen_required function
#  . flutter/configTools.sh
#
#  config_tools_gen_required ... 細節看個函式的說明
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
# @附註 : 與 exported.sh 的 config 有關的產生函式。
#

## ================================== buildConfig key section : Begin ==================================
# for config key
export CONFIG_TOOLS_OPTIONAL="optional"

## ================================== buildConfig key section : End ==================================


## ================================== buildConfig Required section : Begin ==================================
# ============= This is separation line =============
# @brief function : config_tools_gen_required.
# @detail : 簡易函式，不再處理細節的判斷，為保持正確性，參數請自行帶上 ""。
# @param ${1} : file path : 要輸出的檔案位置 (含檔名)
# @param ${2} : flutter project work path : 指的是 flutter 專案目錄的路徑。
# @param ${3} : output path : 指的是 輸出的資料夾路徑。
# @param ${!4} : subcommands : 對應 flutter subcommands : (aar apk appbundle bundle ios ios-framework)
#   => e.g. sample_subcommands=(apk ios)
#   => sa 可參考 configCost.sh configConst_Subcommand_xxx 來設定。
#
# sample e.g. config_tools_gen_required "${sample_file_path}" "${sample_work_path}" "${sample_output_path}" sample_subcommands[@]
function config_tools_gen_required() {

    local func_title_log="*** function [${FUNCNAME[0]}] -"

    echo
    echo "${func_title_log} Begin ***"
    echo "${func_title_log} Input param : Begin ***"
    echo "${func_title_log} file path : ${1}"
    echo "${func_title_log} project work path : ${2}"
    echo "${func_title_log} output path : ${3}"
    echo "${func_title_log} subcommands : (${!4})"
    echo "${func_title_log} Input param : End ***"

    # for local varient
    local func_param_file_path="${1}"
    local func_param_work_path="${2}"
    local func_param_output_path="${3}"
    local func_param_subcommands=("${!4}")

    # for base key，最上層的 key
    local func_required="required"

    # [required] [paths] : 有關路徑的設定。
    local func_required_key_paths="paths"
    local func_required_key_paths_work="work"
    local func_required_key_paths_output="output"

    # for required
    # [required] [version]: 版本資訊 : 一般對應於 flutter pubspec.yaml 中的 version。
    local func_required_key_version="version"

    # [required] [subcommands]: 編譯不同的版本 : build sumcommand (like as : apk，ios，...)。
    local func_required_key_subcommands="subcommands"

    # 輸出檔案格式為 yaml，尚未找到可以方便由 shell 寫 yaml 的方式，先用兜的。
    # for [required]:
    echo "# ${func_required} section" >>"${func_param_file_path}"
    echo "${func_required} :" >>"${func_param_file_path}"

    ## for [required] [paths]:
    echo "" >>"${func_param_file_path}"
    echo "  # [${func_required_key_paths}] : 有關路徑的設定" >>"${func_param_file_path}"
    echo "  ${func_required_key_paths} :" >>"${func_param_file_path}"

    ### for [required] [paths] [work]:
    echo "    # [${func_required_key_paths_work}] : flutter 專案目錄的路徑 : 一般與 flutter pubspec.yaml 同一個資料夾路徑" >>"${func_param_file_path}"
    echo "    ${func_required_key_paths_work} : ${func_param_work_path}" >>"${func_param_file_path}"

    ### for [required] [paths] [output]:
    echo "" >>"${func_param_file_path}"
    echo "    # [${func_required_key_paths_output}] : 輸出資料夾 [需帶完整路徑] : apk，ipa 等輸出的資料夾位置 => e.g. [專案路徑]/[scm]/output" >>"${func_param_file_path}"
    echo "    ${func_required_key_paths_output} : ${func_param_output_path}" >>"${func_param_file_path}"

    ## for [required] [subcommands]:
    echo "" >>"${func_param_file_path}"
    echo "  # [${func_required_key_subcommands}] : flutter build sumcommand" >>"${func_param_file_path}"
    echo "  # - flutter(v2) build support sumcommands : ${CONFIG_CONST_FLUTTER_PROVIDE_SUBCOMMANDS_STRING}" >>"${func_param_file_path}"
    echo "  # - [exported.sh] provide sumcommands : ${CONFIG_CONST_EXPORTED_SHELL_PROVIDE_SUBCOMMANDS_STRING}" >>"${func_param_file_path}"
    echo "  ${func_required_key_subcommands} :" >>"${func_param_file_path}"

    local func_i
    for ((func_i = 0; func_i < ${#func_param_subcommands[@]}; func_i++)); do #請注意 ((   )) 雙層括號

        local func_subcommand=${func_param_subcommands[${func_i}]}
        echo "    - ${func_subcommand}" >>"${func_param_file_path}"

    done

    echo "${func_title_log} End ***"
    echo
}
## ================================== buildConfig Required section : End ==================================

## ================================== buildConfig Optional section : Begin ==================================
# ============= This is separation line =============
# @brief function : config_tools_gen_optional_report_file_path.
# @detail : 簡易函式，不再處理細節的判斷，為保持正確性，參數請自行帶上 ""。
#  - exported.sh 的 Report File Path 為 markdown 語法撰寫，附檔名請設定為 .md
#  - 若 build config file 沒有設定 report file，則會以 build config file 加上後綴，"xxx.yaml.report.md"
# @param $1 : file path : 要輸出的檔案位置 (含檔名)
# @param $2 : report file path : 指定 exported.sh 的 report file path (含檔名)。
#
# sample e.g. config_tools_gen_optional_report_file_path "${sample_file_path}" "${sample_report_file_path}"
function config_tools_gen_optional_report_file_path() {

    local func_title_log="*** function [${FUNCNAME[0]}] -"

    echo
    echo "${func_title_log} Begin ***"
    echo "${func_title_log} Input param : Begin ***"
    echo "${func_title_log} file path : ${1}"
    echo "${func_title_log} report file path : ${2}"
    echo "${func_title_log} Input param : End ***"

    # for local varient
    local func_param_file_path="${1}"
    local func_param_key_feature_value="${2}"

    # for [optional]
    # for (keyFeature) : [report_path]
    local func_optional_key_for_key_feature="report_path"

    # 輸出檔案格式為 yaml，尚未找到可以方便由 shell 寫 yaml 的方式，先用兜的。
    echo "" >>"${func_param_file_path}"
    echo "# ${CONFIG_TOOLS_OPTIONAL} [${func_optional_key_for_key_feature}] sction" >>"${func_param_file_path}"
    echo "# - [${func_optional_key_for_key_feature}] : exported.sh 額外會用到的參數，指定 report file path (含檔名)。" >>"${func_param_file_path}"
    echo "# - 為 markdown 語法撰寫，沒設定會有預設檔案名稱。" >>"${func_param_file_path}"    
    echo "${CONFIG_TOOLS_OPTIONAL} :" >>"${func_param_file_path}"
    echo "  ${func_optional_key_for_key_feature} : ${func_param_key_feature_value}" >>"${func_param_file_path}"

    echo "${func_title_log} End ***"
    echo
}

# ============= This is separation line =============
# @brief function : config_tools_gen_optional_enable_fvm_mode.
#
# @detail : 簡易函式，不再處理細節的判斷，為保持正確性，參數請自行帶上 ""。
#   - 呼叫此函式則表示要開啟 FVM Mode，預設沒有開啟。
#     > fvm flutter build ...
#
# @param $1 : file path : 要輸出的檔案位置 (含檔名)
#
# sample e.g. config_tools_gen_optional_enable_fvm_mode "${sample_file_path}"
function config_tools_gen_optional_enable_fvm_mode() {

    local func_title_log="*** function [${FUNCNAME[0]}] -"

    echo
    echo "${func_title_log} Begin ***"
    echo "${func_title_log} Input param : Begin ***"
    echo "${func_title_log} file path : ${1}"
    echo "${func_title_log} Input param : End ***"

    # for local varient
    local func_param_file_path="${1}"

    # 呼叫此函式，一定是開啟，找不到或非 Y 都是關閉。。
    local func_param_key_feature_value="${GENERAL_CONST_ENABLE_FLAG}"

    # for [optional]
    # for (keyFeature) : [build_name]
    local func_optional_key_for_key_feature="${CONFIG_CONST_CONFIG_KEY_FVM_IS_ENABLE_FVM_MODE}"

    # 輸出檔案格式為 yaml，尚未找到可以方便由 shell 寫 yaml 的方式，先用兜的。
    echo "" >>"${func_param_file_path}"
    echo "# ${CONFIG_TOOLS_OPTIONAL} [${func_optional_key_for_key_feature}] sction" >>"${func_param_file_path}"
    echo "# - [${func_optional_key_for_key_feature}] : 呼叫此函式則表示要開啟 FVM Mode，預設沒有開啟。" >>"${func_param_file_path}"
    echo "# - e.g. 實際執行類似 下列方式 :" >>"${func_param_file_path}"
    echo "#   > ${CONFIG_CONST_COMMAND_NAME_FVM} flutter build ..." >>"${func_param_file_path}"
    echo "# - 原則上 exported.sh 有實作的 subcommands，都會支援才是。" >>"${func_param_file_path}"
    echo "${CONFIG_TOOLS_OPTIONAL} :" >>"${func_param_file_path}"
    echo "  ${func_optional_key_for_key_feature} : ${func_param_key_feature_value}" >>"${func_param_file_path}"

    echo "${func_title_log} End ***"
    echo
}


# ============= This is separation line =============
# @brief function : config_tools_gen_optional_prefix_file_name.
#
# @detail : 簡易函式，不再處理細節的判斷，為保持正確性，參數請自行帶上 ""。
#   - 產出的檔案名稱，加上 前綴字 (prefix)。
#
# @param $1 : file path : 要輸出的檔案位置 (含檔名)
# @param $2 : prefix file name : 輸出檔案的前贅字 => e.g. "[AppName].[version]"
#
# sample e.g. config_tools_gen_optional_build_name "${sample_file_path}" "${sample_prefix_file_name}"
function config_tools_gen_optional_prefix_file_name() {

    local func_title_log="*** function [${FUNCNAME[0]}] -"

    echo
    echo "${func_title_log} Begin ***"
    echo "${func_title_log} Input param : Begin ***"
    echo "${func_title_log} file path : ${1}"
    echo "${func_title_log} ${CONFIG_CONST_CONFIG_KEY_PREFIX_FILE_NAME} value : ${2}"
    echo "${func_title_log} Input param : End ***"

    # for local varient
    local func_param_file_path="${1}"
    local func_param_key_feature_value="${2}"

    # for [optional]
    # for (keyFeature) : [build_name]
    local func_optional_key_for_key_feature="${CONFIG_CONST_CONFIG_KEY_PREFIX_FILE_NAME}"

    # 輸出檔案格式為 yaml，尚未找到可以方便由 shell 寫 yaml 的方式，先用兜的。
    echo "" >>"${func_param_file_path}"
    echo "# ${CONFIG_TOOLS_OPTIONAL} [${func_optional_key_for_key_feature}] sction" >>"${func_param_file_path}"
    echo "# - [${func_optional_key_for_key_feature}] : exported.sh 額外會用到的參數，產出的檔案名稱，加上 前綴字 (prefix)。" >>"${func_param_file_path}"
    echo "# - 原則上 exported.sh 有實作的 subcommands，都會支援才是。" >>"${func_param_file_path}"
    echo "${CONFIG_TOOLS_OPTIONAL} :" >>"${func_param_file_path}"
    echo "  ${func_optional_key_for_key_feature} : ${func_param_key_feature_value}" >>"${func_param_file_path}"

    echo "${func_title_log} End ***"
    echo
}

# ============= This is separation line =============
# @brief function : config_tools_gen_optional_build_name.
#
# @detail : 簡易函式，不再處理細節的判斷，為保持正確性，參數請自行帶上 ""。
#   - flutter pubspec.yaml 中 version : [Build_Name]+[Build_Number]。
#     一般對應於上面的 [Build_Name]，有設定則會當作產出的檔案名稱一環。
#   - 預設 : 沒指定時，flutter build 會預設為下面的 [Build_Name]
#     pubspec.yaml 的 version : [Build_Name]+[Build_Number]，但檔案名稱沒有對應內容。
#
# @param $1 : file path : 要輸出的檔案位置 (含檔名)
# @param $2 : build name : flutter --build-name 的設定內容 => e.g. "0.1.1"
#
# sample e.g. config_tools_gen_optional_build_name "${sample_file_path}" "${sample_build_name}"
function config_tools_gen_optional_build_name() {

    local func_title_log="*** function [${FUNCNAME[0]}] -"

    echo
    echo "${func_title_log} Begin ***"
    echo "${func_title_log} Input param : Begin ***"
    echo "${func_title_log} file path : ${1}"
    echo "${func_title_log} ${CONFIG_CONST_BUILD_PARAM_KEY_BUILD_NAME} value : ${2}"
    echo "${func_title_log} Input param : End ***"

    # for local varient
    local func_param_file_path="${1}"
    local func_param_key_feature_value="${2}"

    # for [optional]
    # for (keyFeature) : [build_name]
    local func_optional_key_for_key_feature="build_name"

    # 輸出檔案格式為 yaml，尚未找到可以方便由 shell 寫 yaml 的方式，先用兜的。
    echo "" >>"${func_param_file_path}"
    echo "# ${CONFIG_TOOLS_OPTIONAL} [${func_optional_key_for_key_feature}] sction" >>"${func_param_file_path}"
    echo "# - [${func_optional_key_for_key_feature}] : ${CONFIG_CONST_BUILD_PARAM_KEY_BUILD_NAME} 會用到的內容，對應於 flutter build 的 ${CONFIG_CONST_BUILD_PARAM_KEY_BUILD_NAME} 參數" >>"${func_param_file_path}"
    echo "#   - flutter pubspec.yaml 中 version : [Build_Name]+[Build_Number]。" >>"${func_param_file_path}"
    echo "#     一般對應於上面的 [Build_Name]，有設定則會當作產出的檔案名稱一環。" >>"${func_param_file_path}"
    echo "#   - 預設 : 沒指定時，flutter build 會預設為下面的 [Build_Name]" >>"${func_param_file_path}"
    echo "#     pubspec.yaml 的 version : [Build_Name]+[Build_Number]，但檔案名稱沒有對應內容。" >>"${func_param_file_path}"
    echo "# - support subcommands: ${CONFIG_CONST_SUBCOMMAND_APK}，${CONFIG_CONST_SUBCOMMAND_APPBUNDLE}，${CONFIG_CONST_SUBCOMMAND_IOS}" >>"${func_param_file_path}"
    echo "${CONFIG_TOOLS_OPTIONAL} :" >>"${func_param_file_path}"
    echo "  ${func_optional_key_for_key_feature} : ${func_param_key_feature_value}" >>"${func_param_file_path}"

    echo "${func_title_log} End ***"
    echo
}

# ============= This is separation line =============
# @brief function : config_tools_gen_optional_build_number.
#
# @detail : 簡易函式，不再處理細節的判斷，為保持正確性，參數請自行帶上 ""。
#   - flutter pubspec.yaml 中 version : [Build_Name]+[Build_Number]。
#     一般對應於上面的 [Build_Number]，有設定則會當作產出的檔案名稱一環。
#   - 預設 : 沒指定時，flutter build 會預設為下面的 [Build_Number]
#     pubspec.yaml 的 version : [Build_Name]+[Build_Number]，但檔案名稱沒有對應內容。
#
# @param $1 : file path : 要輸出的檔案位置 (含檔名)
# @param $2 : build number : flutter --build-number 的設定內容 => e.g. "0.1.1.4" or "12" [需看 subcommands 實際支援度]
#
# sample e.g. config_tools_gen_optional_build_number "${sample_file_path}" "${sample_build_number}"
function config_tools_gen_optional_build_number() {

    local func_title_log="*** function [${FUNCNAME[0]}] -"

    echo
    echo "${func_title_log} Begin ***"
    echo "${func_title_log} Input param : Begin ***"
    echo "${func_title_log} file path : ${1}"
    echo "${func_title_log} ${CONFIG_CONST_BUILD_PARAM_KEY_BUILD_NUMBER} value : ${2}"
    echo "${func_title_log} Input param : End ***"

    # for local varient
    local func_param_file_path="${1}"
    local func_param_key_feature_value="${2}"

    # for [optional]
    # for (keyFeature) : [build_name]
    local func_optional_key_for_key_feature="build_number"

    # 輸出檔案格式為 yaml，尚未找到可以方便由 shell 寫 yaml 的方式，先用兜的。
    echo "" >>"${func_param_file_path}"
    echo "# ${CONFIG_TOOLS_OPTIONAL} [${func_optional_key_for_key_feature}] sction" >>"${func_param_file_path}"
    echo "# - [${func_optional_key_for_key_feature}] : ${CONFIG_CONST_BUILD_PARAM_KEY_BUILD_NUMBER} 會用到的內容，對應於 flutter build 的 ${CONFIG_CONST_BUILD_PARAM_KEY_BUILD_NUMBER} 參數" >>"${func_param_file_path}"
    echo "#   - flutter pubspec.yaml 中 version : [Build_Name]+[Build_Number]。" >>"${func_param_file_path}"
    echo "#     一般對應於上面的 [Build_Number]，有設定則會當作產出的檔案名稱一環。" >>"${func_param_file_path}"
    echo "#   - 預設 : 沒指定時，flutter build 會預設為下面的 [Build_Number]" >>"${func_param_file_path}"
    echo "#     pubspec.yaml 的 version : [Build_Name]+[Build_Number]，但檔案名稱沒有對應內容。" >>"${func_param_file_path}"
    echo "# - support subcommands: ${CONFIG_CONST_SUBCOMMAND_AAR}，${CONFIG_CONST_SUBCOMMAND_APK}，${CONFIG_CONST_SUBCOMMAND_APPBUNDLE}，${CONFIG_CONST_SUBCOMMAND_BUNDLE}，${CONFIG_CONST_SUBCOMMAND_IOS}" >>"${func_param_file_path}"
    echo "${CONFIG_TOOLS_OPTIONAL} :" >>"${func_param_file_path}"
    echo "  ${func_optional_key_for_key_feature} : ${func_param_key_feature_value}" >>"${func_param_file_path}"

    echo "${func_title_log} End ***"
    echo
}

# ============= This is separation line =============
# @brief function : config_tools_gen_optional_build_config_type.
# @detail : 簡易函式，不再處理細節的判斷，為保持正確性，參數請自行帶上 ""。
# @param $1 : file path : 要輸出的檔案位置 (含檔名)
# @param ${!2} : buildConfigTypes : 對應 flutter build config types : (debug profile release)
# 依據 flutter build ， 有 debug ， profile ， release
#   => e.g. sample_build_config_types=(debug release)
#   => sa 可參考 configCost.sh configConst_BuildConfigType_xxx 來設定。
#
# sample e.g. config_tools_gen_optional_build_config_type "${sample_file_path}" sample_build_config_types[@]
function config_tools_gen_optional_build_config_type() {

    local func_title_log="*** function [${FUNCNAME[0]}] -"

    echo
    echo "${func_title_log} Begin ***"
    echo "${func_title_log} Input param : Begin ***"
    echo "${func_title_log} file path : ${1}"
    echo "${func_title_log} build config types : (${!2})"
    echo "${func_title_log} Input param : End ***"

    # for local varient
    local func_param_file_path="${1}"
    local func_param_build_config_types=("${!2}")

    # for [optional]
    # for (keyFeature) : [build_config_types]
    local func_optional_key_for_key_feature="build_config_types"

    # 輸出檔案格式為 yaml，尚未找到可以方便由 shell 寫 yaml 的方式，先用兜的。
    echo "" >>"${func_param_file_path}"
    echo "# ${CONFIG_TOOLS_OPTIONAL} [${func_optional_key_for_key_feature}] sction" >>"${func_param_file_path}"
    echo "# - [${func_optional_key_for_key_feature}] : build config type (like as : ${CONFIG_CONST_BUILD_CONFIG_TYPE_DEBUG}，${CONFIG_CONST_BUILD_CONFIG_TYPE_PROFILE}，${CONFIG_CONST_BUILD_CONFIG_TYPE_RELEASE})" >>"${func_param_file_path}"
    echo "# - support subcommands: ${CONFIG_CONST_SUBCOMMAND_APK}，${CONFIG_CONST_SUBCOMMAND_APPBUNDLE}，${CONFIG_CONST_SUBCOMMAND_BUNDLE}，${CONFIG_CONST_SUBCOMMAND_IOS}" >>"${func_param_file_path}"
    echo "${CONFIG_TOOLS_OPTIONAL} :" >>"${func_param_file_path}"
    echo "  ${func_optional_key_for_key_feature} :" >>"${func_param_file_path}"

    local func_i
    for ((func_i = 0; func_i < ${#func_param_build_config_types[@]}; func_i++)); do #請注意 ((   )) 雙層括號

        local func_build_config_type=${func_param_build_config_types[${func_i}]}
        echo "    - ${func_build_config_type}" >>"${func_param_file_path}"

    done

    echo "${func_title_log} End ***"
    echo
}

# ============= This is separation line =============
# @brief function : config_tools_gen_optional_dart_define.
# @detail : 簡易函式，不再處理細節的判斷，為保持正確性，參數請自行帶上 ""。
# @param $1 : file path : 要輸出的檔案位置 (含檔名)
# @param $2 : separator : 分隔符號，不判斷，單純設定，外面需決定好內容。=> e.g. "+"
# @param $3 : defines : 兜好 [key][separator][value的內容]
#   => e.g. sample_dart_defines=(gitHash+920f6fc envName+dev)
#
# sample e.g. config_tools_gen_optional_dart_define "${sample_file_path}" "${sample_separator}" sample_dart_defines[@]
function config_tools_gen_optional_dart_define() {

    local func_title_log="*** function [${FUNCNAME[0]}] -"

    echo
    echo "${func_title_log} Begin ***"
    echo "${func_title_log} Input param : Begin ***"
    echo "${func_title_log} file path : ${1}"
    echo "${func_title_log} separator : ${2}"
    echo "${func_title_log} ${CONFIG_CONST_BUILD_PARAM_KEY_DART_DEFINE} values : (${!3})"
    echo "${func_title_log} Input param : End ***"

    # for local varient
    local func_param_file_path="${1}"
    local func_param_separator="${2}"
    local func_param_defines=("${!3}")

    # for [optional]
    # [optional] [dart-define] : dart-define 會用到的內容，為 list 型態，{key}{separator}{value}
    local func_optional_key_dart_def="dart_define"
    local func_optional_key_dart_def_Key_Separator="separator"
    local func_optional_key_dart_def_Key_Defines="defines"

    # 輸出檔案格式為 yaml，尚未找到可以方便由 shell 寫 yaml 的方式，先用兜的。
    # for dart-define
    echo "" >>"${func_param_file_path}"
    echo "# ${CONFIG_TOOLS_OPTIONAL} [${func_optional_key_dart_def}] sction" >>"${func_param_file_path}"
    echo "# - [${func_optional_key_dart_def}] : ${CONFIG_CONST_BUILD_PARAM_KEY_DART_DEFINE} 會用到的內容，為 list 型態，{key}{separator}{value}" >>"${func_param_file_path}"
    echo "# - support subcommands: ${CONFIG_CONST_SUBCOMMAND_APK}，${CONFIG_CONST_SUBCOMMAND_APPBUNDLE}，${CONFIG_CONST_SUBCOMMAND_IOS}，${CONFIG_CONST_SUBCOMMAND_IOS_FRAMEWORK}" >>"${func_param_file_path}"
    echo "${CONFIG_TOOLS_OPTIONAL} :" >>"${func_param_file_path}"
    echo "  ${func_optional_key_dart_def} :" >>"${func_param_file_path}"
    echo "    ${func_optional_key_dart_def_Key_Separator} : ${func_param_separator}" >>"${func_param_file_path}"
    echo "    ${func_optional_key_dart_def_Key_Defines} :" >>"${func_param_file_path}"

    local func_i
    for ((func_i = 0; func_i < ${#func_param_defines[@]}; func_i++)); do #請注意 ((   )) 雙層括號

        local func_define=${func_param_defines[${func_i}]}
        echo "      - ${func_define}" >>"${func_param_file_path}"

    done

    echo "${func_title_log} End ***"
    echo
}

# ============= This is separation line =============
# @brief function : config_tools_gen_optional_dart_define.
# @detail : 簡易函式，不再處理細節的判斷，為保持正確性，參數請自行帶上 ""。
# @param $1 : file path : 要輸出的檔案位置 (含檔名)
# @param $2 : flavor : flutter flavor 的設定內容 => e.g. "Runner"
#
# sample e.g. config_tools_gen_optional_flavor "${sample_file_path}" "${sample_flavor}"
function config_tools_gen_optional_flavor() {

    local func_title_log="*** function [${FUNCNAME[0]}] -"

    echo
    echo "${func_title_log} Begin ***"
    echo "${func_title_log} Input param : Begin ***"
    echo "${func_title_log} file path : ${1}"
    echo "${func_title_log} ${CONFIG_CONST_BUILD_PARAM_KEY_FLAVOR} value : ${2}"
    echo "${func_title_log} Input param : End ***"

    # for local varient
    local func_param_file_path="${1}"
    local func_param_key_feature_value="${2}"

    # for [optional]
    # for (keyFeature) : [flavor]
    #    > 剛好跟 fultter --flavor 參數是一樣可以使用。
    local func_optional_key_for_key_feature="${CONFIG_CONST_BUILD_PARAM_KEY_FLAVOR}"

    # 輸出檔案格式為 yaml，尚未找到可以方便由 shell 寫 yaml 的方式，先用兜的。
    echo "" >>"${func_param_file_path}"
    echo "# ${CONFIG_TOOLS_OPTIONAL} [${func_optional_key_for_key_feature}] sction" >>"${func_param_file_path}"
    echo "# - [${func_optional_key_for_key_feature}] : ${configConst_BuildParam_Key_flavor} 會用到的內容，對應於 flutter build 的 ${CONFIG_CONST_BUILD_PARAM_KEY_FLAVOR} 參數" >>"${func_param_file_path}"
    echo "# - support subcommands: ${CONFIG_CONST_SUBCOMMAND_AAR}，${CONFIG_CONST_SUBCOMMAND_APK}，${CONFIG_CONST_SUBCOMMAND_APPBUNDLE}，${CONFIG_CONST_SUBCOMMAND_BUNDLE}，${CONFIG_CONST_SUBCOMMAND_IOS}，${CONFIG_CONST_SUBCOMMAND_IOS_FRAMEWORK}" >>"${func_param_file_path}"
    echo "${CONFIG_TOOLS_OPTIONAL} :" >>"${func_param_file_path}"
    echo "  ${func_optional_key_for_key_feature} : ${func_param_key_feature_value}" >>"${func_param_file_path}"

    echo "${func_title_log} End ***"
    echo
}

# ============= This is separation line =============
# @brief function : config_tools_gen_optional_target_platform.
# @detail : 簡易函式，不再處理細節的判斷，為保持正確性，參數請自行帶上 ""。
# @param $1 : file path : 要輸出的檔案位置 (含檔名)
# @param $2 : platforms : flutter --target-platform 的設定內容 => e.g. "android-arm,android-arm64"
#
# sample e.g. config_tools_gen_optional_target_platform "${sample_file_path}" "${sample_target_platform}"
#
# - flutter command line sample :
#   > flutter build apk --target-platform android-arm,android-arm64
#
# @sa :
#      --target-platform                             The target platform for which the project is compiled.
#                                                  [android-arm (default), android-arm64 (default), android-x86, android-x64 (default)]
function config_tools_gen_optional_target_platform() {

    local func_title_log="*** function [${FUNCNAME[0]}] -"

    echo
    echo "${func_title_log} Begin ***"
    echo "${func_title_log} Input param : Begin ***"
    echo "${func_title_log} file path : ${1}"
    echo "${func_title_log} ${CONFIG_CONST_BUILD_PARAM_KEY_TARGET_PLATFORM} value : ${2}"
    echo "${func_title_log} Input param : End ***"

    # for local varient
    local func_param_file_path="${1}"
    local func_param_key_feature_value="${2}"

    # for [optional]
    # for (keyFeature) : [target_platform]
    local func_optional_key_for_key_feature=target_platform

    # 輸出檔案格式為 yaml，尚未找到可以方便由 shell 寫 yaml 的方式，先用兜的。
    echo "" >>"${func_param_file_path}"
    echo "# ${CONFIG_TOOLS_OPTIONAL} [${func_optional_key_for_key_feature}] sction" >>"${func_param_file_path}"
    echo "# - [${func_optional_key_for_key_feature}] : ${CONFIG_CONST_BUILD_PARAM_KEY_TARGET_PLATFORM} 會用到的內容，對應於 flutter build 的 ${CONFIG_CONST_BUILD_PARAM_KEY_TARGET_PLATFORM} 參數" >>"${func_param_file_path}"
    echo "# - support subcommands: ${CONFIG_CONST_SUBCOMMAND_AAR}，${CONFIG_CONST_SUBCOMMAND_APK}，${CONFIG_CONST_SUBCOMMAND_APPBUNDLE}，${CONFIG_CONST_SUBCOMMAND_BUNDLE}" >>"${func_param_file_path}"
    echo "${CONFIG_TOOLS_OPTIONAL} :" >>"${func_param_file_path}"
    echo "  ${func_optional_key_for_key_feature} : ${func_param_key_feature_value}" >>"${func_param_file_path}"

    echo "${func_title_log} End ***"
    echo
}

# TODO:
# target : "lib/main_abc.dart"
## ================================== buildConfig Optional section : End ==================================

