#!/bin/bash

# ============= This is separation line =============
# @brief : keychainTool_ImportCerToKeychain.sh 會用到的 generator config 工具。
# @details : 放置常用產出部分 build config 內容的工具函式，使用者可以引用此檔案來使用函式。
# @author : esp
# @create date : 2022-05-17
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
#    . xcode/keychain/configConst.sh
#
#  # import config_tools_gen_required 等函式。
#  . xcode/keychain/configTools.sh
#
#  config_tools_gen_required
#  ```
#
# ---
#
# 提供函式 :
#  > 細節看各個的函式明
#  - config_tools_gen_required
#  - config_tools_gen_extra_cer_info_unit
#  - config_tools_gen_optional_work_path
#
# ---
#
# Config File sample :
#
# [required] 必要資訊。
#   ``` yaml
#   required:
#     keychain:
#       name: App.Keychain
#       password: 123456
#     cer_info_key_names :
#       - cer_info_app_1
#   ```
#
# [extra] 額外的 cer info unit 資訊，最外層的 key name 是動態取得 (由 required 資訊提供)。
#   ``` yaml
#   cer_info_app_1:
#     file_password_separator: +
#     file_password_list:
#       - app.share/doc/abc.p12+abc
#       - app.share/doc/def.p12+def
#       - app.share/doc/ghi.cer+
#       - app.share/doc/jkl.cer+
#   ```
#
# [optional] [work_path] sction
# - [work_path] : 指定 shell 執行的工作目錄。
# - => e.g. "/Users/[UserName]/Desktop/Code/[some_app_project]/submodules/app.share"。
#   ``` yaml
#   optional :
#     work_path : /Users/esp/Desktop/Code/app_flutter_project/submodules/app.share
#   ```
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

## ================================== Generator Config Required section : Begin ==================================
# ============= This is separation line =============
# @brief function : config_tools_gen_required.
# @detail : 簡易函式，不再處理細節的判斷，為保持正確性，參數請自行帶上 "".
# @param ${1} : file path : 要輸出的檔案位置 (含檔名)
# @param ${2} : keychain_name : 要設定的 keychain name。
# @param ${3} : keychian_password : 要設定的 keychain password。
# @param ${!4} : cer_info_key_names : 要設定到 keychain 的 cer info key names (對應於 config 的其他要取得的 cer info unit) : (cer_info_app_1 cer_info_app_2)
#   => e.g. sample_cer_info_key_names=(cer_info_app_1 cer_info_app_2)
# @sa config_tools_gen_extra_cer_info_unit
#   => 每一個 cer info 在 config file (yaml) 的格式，可參考 config_tools_gen_extra_cer_info_unit 說明。
#
# sample e.g. config_tools_gen_required "${sample_file_path}" "${sample_keychain_name}" "${sample_keychain_password}" sample_cer_info_key_names[@]
function config_tools_gen_required() {

    local func_title_log="*** function [${FUNCNAME[0]}] -"

    echo
    echo "${func_title_log} Begin ***"
    echo "${func_title_log} Input param : Begin ***"
    echo "${func_title_log} file path : ${1}"
    echo "${func_title_log} keychain_name : ${2}"
    echo "${func_title_log} keychian_password : ${3}"
    echo "${func_title_log} cer_info_key_names : (${!4})"
    echo "${func_title_log} Input param : End ***"

    # for local varient
    local func_param_file_path="${1}"
    local func_param_keychain_name="${2}"
    local func_param_keychain_password="${3}"
    local func_param_cer_info_key_names=("${!4}")

    # 輸出檔案格式為 yaml，尚未找到可以方便由 shell 寫 yaml 的方式，先用兜的。
    # for [required]:
    echo "# ${CONFIG_CONST_CONFIG_KEY_REQUIRED} section" >>"${func_param_file_path}"
    echo "${CONFIG_CONST_CONFIG_KEY_REQUIRED} :" >>"${func_param_file_path}"

    ## for [required] [keychain]:
    echo "" >>"${func_param_file_path}"
    echo "  # [${CONFIG_CONST_CONFIG_KEY_REQUIRED_KEYCHAIN}] : 要設定的鑰匙圈資訊 (會設定為 keychain 中 default) " >>"${func_param_file_path}"
    echo "  ${CONFIG_CONST_CONFIG_KEY_REQUIRED_KEYCHAIN} :" >>"${func_param_file_path}"

    ### for [required] [keychain] [name]:
    echo "" >>"${func_param_file_path}"
    echo "    # [${CONFIG_CONST_CONFIG_KEY_REQUIRED_KEYCHAIN_NAME}] : 要設定的鑰匙圈名稱，在 \`keychain Access.App\` 會顯示的名稱 => e.g. xxx.App.Keychain" >>"${func_param_file_path}"
    echo "    ${CONFIG_CONST_CONFIG_KEY_REQUIRED_KEYCHAIN_NAME} : ${func_param_keychain_name}" >>"${func_param_file_path}"

    ### for [required] [keychain] [password]:
    echo "    # [${CONFIG_CONST_CONFIG_KEY_REQUIRED_KEYCHAIN_PASSWORD}] : 要設定的鑰匙圈密碼，需要存取該鑰匙圈需要輸入的密碼 => e.g. abc123" >>"${func_param_file_path}"
    echo "    ${CONFIG_CONST_CONFIG_KEY_REQUIRED_KEYCHAIN_PASSWORD} : ${func_param_keychain_password}" >>"${func_param_file_path}"

    ## for [required] [cer_info_key_names]:
    echo "" >>"${func_param_file_path}"
    echo "  # [${CONFIG_CONST_CONFIG_KEY_REQUIRED_CER_INFO_KEY_NAMES}] : 需要額外處理的 cer infos，針對每一個 key name，會動態去取得 cer info unit 資訊。" >>"${func_param_file_path}"
    echo "  # [${CONFIG_CONST_CONFIG_KEY_REQUIRED_CER_INFO_KEY_NAMES}] : input like as (cer_info_appA cer_info_appB)。" >>"${func_param_file_path}"
    echo "  # Note : => 每一個 cer info 在 config file (yaml) 須符合下列格式 (以下為範例) :" >>"${func_param_file_path}"
    echo "  #   \`\`\` yaml" >>"${func_param_file_path}"
    echo "  #   # cer info unit key。" >>"${func_param_file_path}"
    echo "  #   cer_info_app_1:" >>"${func_param_file_path}"
    echo "  #     # file 與 password 的分隔符號。" >>"${func_param_file_path}"
    echo "  #     file_password_separator: +" >>"${func_param_file_path}"
    echo "  #     # file 與 password 為乙組的資訊" >>"${func_param_file_path}"
    echo "  #     # 可接收無密碼。" >>"${func_param_file_path}"
    echo "  #     # 以 \`file_password_separator\` 做拆分，沒有後面部分，視同無密碼。" >>"${func_param_file_path}"
    echo "  #     file_password_list:" >>"${func_param_file_path}"
    echo "  #     - app.share/doc/abc.p12+abc" >>"${func_param_file_path}"
    echo "  #     - app.share/doc/def.p12+def" >>"${func_param_file_path}"
    echo "  #     - app.share/doc/ghi.cer+" >>"${func_param_file_path}"
    echo "  #     - app.share/doc/jkl.cer" >>"${func_param_file_path}"
    echo "  #   \`\`\`" >>"${func_param_file_path}"

    echo "  ${CONFIG_CONST_CONFIG_KEY_REQUIRED_CER_INFO_KEY_NAMES} :" >>"${func_param_file_path}"

    local func_i
    for ((func_i = 0; func_i < ${#func_param_cer_info_key_names[@]}; func_i++)); do #請注意 ((   )) 雙層括號

        local func_subcommand=${func_param_cer_info_key_names[${func_i}]}
        echo "    - ${func_subcommand}" >>"${func_param_file_path}"

    done

    echo "${func_title_log} End ***"
    echo
}
## ================================== Generator Config Required section : End ==================================

## ================================== Generator Config Extra section : Begin ==================================
# ============= This is separation line =============
# @brief function : config_tools_gen_extra_cer_info_unit.
# @detail : 簡易函式，不再處理細節的判斷，為保持正確性，參數請自行帶上 "".
#  產出格式 :
#   => 每一個 cer info 在 config file (yaml) 須符合下列格式 (以下為範例)
#
#      ``` yaml
#      # cer info unit key。
#      cer_info_app_1:
#        # file 與 password 的分隔符號。
#        file_password_separator: +
#        # file 與 password 為乙組的資訊
#        # 可接收無密碼，以 `file_password_separator` 做拆分，沒有後面部分，視同無密碼。
#        file_password_list:
#        - app.share/doc/abc.p12+abc
#        - app.share/doc/def.p12+def
#        - app.share/doc/ghi.cer+
#        - app.share/doc/jkl.cer+
#      ```
#
# @param $1 : file path : 要輸出的檔案位置 (含檔名)
# @param $2 : cer info unit key name: 要輸出到 yaml 的 key name。
# @param $3 : file_password_separator : 分隔符號，不判斷，單純設定，外面需決定好內容。=> e.g. "+"
#             若整組都沒有密碼，允許為空，可以帶空字串 ""。
# @param $4 : file password list : 兜好 [key][separator][value的內容]
#   => e.g. sample_file_password_list=(app.share/doc/abc.p12+abc app.share/doc/def.p12+def app.share/doc/ghi.cer+ app.share/doc/jkl.cer)
#
# sample e.g. config_tools_gen_extra_cer_info_unit "${sample_file_path}" "${sample_separator}" sample_file_password_list[@]
function config_tools_gen_extra_cer_info_unit() {

    local func_title_log="*** function [${FUNCNAME[0]}] -"

    echo
    echo "${func_title_log} Begin ***"
    echo "${func_title_log} Input param : Begin ***"
    echo "${func_title_log} file path : ${1}"
    echo "${func_title_log} cer info unit key name: ${2}"
    echo "${func_title_log} file_password_separator : ${3}"
    echo "${func_title_log} ${CONFIG_CONST_CONFIG_KEY_CER_INFO_UNIT_FILE_PASSWORD_LIST} values : (${!4})"
    echo "${func_title_log} Input param : End ***"

    # for local varient
    local func_param_file_path="${1}"
    local func_param_cer_info_unit_key="${2}"
    local func_param_separator="${3}"
    local func_param_file_password_list=("${!4}")

    local func_cer_info_unit_title="cer info unit"

    # 輸出檔案格式為 yaml，尚未找到可以方便由 shell 寫 yaml 的方式，先用兜的。
    # for extra cer info unit
    echo "" >>"${func_param_file_path}"
    echo "# extra [${func_cer_info_unit_title}] sction" >>"${func_param_file_path}"
    echo "# - [${func_cer_info_unit_title}] : ${CONFIG_CONST_CONFIG_KEY_CER_INFO_UNIT_FILE_PASSWORD_LIST} 會用到的內容，為 list 型態，{p12/cer}{separator}{password}" >>"${func_param_file_path}"
    echo "#   可接收無密碼，以 \`file_password_separator\` 做拆分，沒有後面部分，視同無密碼。" >>"${func_param_file_path}"
    echo "#     - 有密碼 : 一般為 {p12}{separator}{password}" >>"${func_param_file_path}"
    echo "#     - 無密碼 : 一般為 {cer}" >>"${func_param_file_path}"
    echo "${func_param_cer_info_unit_key} :" >>"${func_param_file_path}"
    echo "  # 若整組都沒有密碼，允許為空，可以帶空字串 \"\"。" >>"${func_param_file_path}"
    echo "  ${CONFIG_CONST_CONFIG_KEY_CER_INFO_UNIT_FILE_PASSWORD_SEPARATOR} : ${func_param_separator}" >>"${func_param_file_path}"
    echo "  ${CONFIG_CONST_CONFIG_KEY_CER_INFO_UNIT_FILE_PASSWORD_LIST} :" >>"${func_param_file_path}"

    local func_i
    for ((func_i = 0; func_i < ${#func_param_file_password_list[@]}; func_i++)); do #請注意 ((   )) 雙層括號

        local func_file_password=${func_param_file_password_list[${func_i}]}
        echo "    - ${func_file_password}" >>"${func_param_file_path}"

    done

    echo "${func_title_log} End ***"
    echo
}
## ================================== Generator Config Extra section : End ==================================

## ================================== Generator Config Optional section : Begin ==================================
# ============= This is separation line =============
# @brief function : config_tools_gen_optional_work_path.
#
# @detail : 簡易函式，不再處理細節的判斷，為保持正確性，參數請自行帶上 "".
#   - 產出的檔案名稱，加上 前綴字 (prefix)。
#
# @param $1 : file path : 要輸出的檔案位置 (含檔名)
# @param $2 : work path : 指定 shell 執行的工作目錄 => e.g. "/Users/[UserName]/Desktop/Code/[some_app_project]/submodules/app.share"。
#
# sample e.g. config_tools_gen_optional_work_path "${sample_file_path}" "${sample_work_path}"
function config_tools_gen_optional_work_path() {

    local func_title_log="*** function [${FUNCNAME[0]}] -"

    echo
    echo "${func_title_log} Begin ***"
    echo "${func_title_log} Input param : Begin ***"
    echo "${func_title_log} file path : ${1}"
    echo "${func_title_log} ${CONFIG_CONST_CONFIG_KEY_WORK_PATH} value : ${2}"
    echo "${func_title_log} Input param : End ***"

    # for local varient
    local func_param_file_path="${1}"
    local func_param_key_feature_value="${2}"

    # for [optional]
    # for (keyFeature) : [work_path]
    local func_optional_key_for_key_feature="${CONFIG_CONST_CONFIG_KEY_WORK_PATH}"

    # 輸出檔案格式為 yaml，尚未找到可以方便由 shell 寫 yaml 的方式，先用兜的。
    echo "" >>"${func_param_file_path}"
    echo "# ${CONFIG_CONST_CONFIG_KEY_OPTIONAL} [${func_optional_key_for_key_feature}] sction" >>"${func_param_file_path}"
    echo "# - [${func_optional_key_for_key_feature}] : 指定 shell 執行的工作目錄。" >>"${func_param_file_path}"
    echo "# - => e.g. \"/Users/[UserName]/Desktop/Code/[some_app_project]/submodules/app.share\"。" >>"${func_param_file_path}"
    echo "${CONFIG_CONST_CONFIG_KEY_OPTIONAL} :" >>"${func_param_file_path}"
    echo "  ${func_optional_key_for_key_feature} : ${func_param_key_feature_value}" >>"${func_param_file_path}"

    echo "${func_title_log} End ***"
    echo
}
## ================================== Generator Config Optional section : End ==================================
