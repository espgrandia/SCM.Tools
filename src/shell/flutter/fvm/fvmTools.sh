#!/bin/bash

# ============= This is separation line =============
# @brief : 透過 fvm (Flutter Version Management) 用來管理 Flutter Version 切換功能。
# @details : 目前主要放可以切換 fvm global 的工具函示。
# @author : esp
# @create date : 2021-08-11
# @sa FVM website : https://fvm.app/
#
# ---
#
# 注意事項:
# - 使用此通用函式，有相依於 scm.tools/src/shell/general_tools.sh
#   - 其中有使用到 [check_result_if_fail_then_change_folder]，[get_first_found_command_from_input_command_list_by_using_which_command]，etc ...。
#   - 需自行 include general_const.sh
#   - 需自行 include general_tools.sh
#
# - 另一個 剖析 json file 中的某 key 對應的 value to console. (parse_JsonFile_With_Key_To_Console.py)
#   scm.tools/src/python/parse_JsonFile_With_Key_To_Console.py 中，需帶入路徑進來。
#

# ============= This is separation line =============
# @brief function : 處理 fvm global 設定，從 local 的 active 版本設定到 global 部分.
# @details
#  - 頗析專案下的， .fvm/fvm_config.json 裡的 flutterSdkVersion 版本，設定到 fvm global。
#
# @param $1: 要輸出的 title log : e.g. "${sample_title_log}"
# @param $2: 錯誤時要切換回去的路徑: e.g. "${sample_work_path}"，$(dirname $0)，etc ...。
# @param $3: fvm config file (以當前呼叫此函式時的所屬資料夾為相對路徑思考)。
# @param $4: 頗析 jsonfile 的 python 位置 `parse_JsonFile_With_Key_To_Console.py`，(以當前呼叫此函式時的所屬資料夾為相對路徑思考)。
#  - 此 `parse_JsonFile_With_Key_To_Console.py` 在 scm.tools//src/python/ 下，
#    由於此函式是設計為 include 的工具函示，所以需要額外帶入，若有同樣的參數設定的不同 python 寫法，也可以替換之。
#
function deal_fvm_set_active_to_global() {

    local func_title_log="*** function [${FUNCNAME[0]}] - ${1}"

    echo
    echo "${func_title_log} Begin ***"
    echo "${func_title_log} Input param : Begin ***"
    echo "${func_title_log} TitleLog: ${1}"
    echo "${func_title_log} ChangePath: ${2}"
    echo "${func_title_log} fvm config file: ${3}"
    echo "${func_title_log} parse json file by python: ${4}"
    echo "${func_title_log} Input param : End ***"

    local func_param_title_log="${1}"
    local func_param_change_folder="${2}"
    local func_param_fvm_config_file="${3}"
    local func_param_parse_json_file_by_python="${4}"

    echo
    echo "${func_title_log} ============= parse json file - Begin ============="

    local func_key_flutter_sdk_version="flutterSdkVersion"

    # [get python command name] : 設定支援的 python command name。
    local func_python_list=(python python3 python2)
    local func_execute_python=""

    echo "${func_title_log} func_python_list : ${func_python_list[@]}"

    # [get python command name] : 使用 scm.tools 工具。
    get_first_found_command_from_input_command_list_by_using_which_command__if__result_fail_then_change_folder \
        "${func_param_title_log}" func_python_list[@] func_execute_python "${func_param_change_folder}"

    # [get python command name] : 可以到這，表示有找到合法的 python ， func_execute_python 一定有內容。
    echo "${func_title_log} func_execute_python : ${func_execute_python}"

    # [取得 jsonfile] : key 為 [flutterSdkVersion] 的內容。
    echo "${func_title_log} will execute python command : ${func_execute_python} ${func_param_parse_json_file_by_python} ${func_param_fvm_config_file} ${func_key_flutter_sdk_version}"
    local func_flutter_sdk_version=$(${func_execute_python} ${func_param_parse_json_file_by_python} ${func_param_fvm_config_file} ${func_key_flutter_sdk_version})
    check_result_if_fail_then_change_folder "${func_title_log}" "$?" "!!! ~ parse json file => fail ~ !!!" "${2}"

    echo "${func_title_log} ${func_key_flutter_sdk_version} value : ${func_flutter_sdk_version}"

    echo "${func_title_log} ============= parse json file - End ============="

    echo
    echo "${func_title_log} ============= fvm - Begin ============="
    echo "${func_title_log} fvm list [before fvm global ${func_flutter_sdk_version}]"
    fvm list
    check_result_if_fail_then_change_folder "${func_title_log}" "$?" "!!! ~ fvm list => fail ~ !!!" "${2}"

    echo
    echo "${func_title_log} fvm global ${func_flutter_sdk_version}"
    fvm global "${func_flutter_sdk_version}"
    check_result_if_fail_then_change_folder "${func_title_log}" "$?" "!!! ~ fvm global ${func_flutter_sdk_version} => fail ~ !!!" "${2}"

    echo
    echo "${func_title_log} fvm list [after fvm global ${func_flutter_sdk_version}]"
    fvm list
    check_result_if_fail_then_change_folder "${func_title_log}" "$?" "!!! ~ fvm list => fail ~ !!!" "${2}"

    echo "${func_title_log} ============= fvm - End ============="
    echo

    echo "${func_title_log} End ***"
    echo
}
