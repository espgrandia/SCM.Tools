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
# - 使用此通用函式，有相依於 scm.tools/src/shell/generalTools.sh
#   - 其中有使用到 [check_result_if_fail_then_change_folder]，[get_first_found_command_from_input_command_list_by_using_which_command]，etc ...。
#   - 需自行 include generalConst.sh
#   - 需自行 include generalTools.sh
#
# - 另一個 剖析 json file 中的某 key 對應的 value to console. (parse_JsonFile_With_Key_To_Console.py)
#   scm.tools/src/python/parse_JsonFile_With_Key_To_Console.py 中，需帶入路徑進來。
#

# ============= This is separation line =============
# @brief function : 處理 fvm global 設定，從 local 的 active 版本設定到 global 部分.
# @details
#  - 頗析專案下的， .fvm/fvm_config.json 裡的 flutterSdkVersion 版本，設定到 fvm global。
#
# @param $1: 要輸出的 title log : e.g. "${sample_Title_Log}"
# @param $2: 錯誤時要切換回去的路徑: e.g. "${sample_WorkPath}"，$(dirname $0)，etc ...。
# @param $3: fvm config file (以當前呼叫此函式時的所屬資料夾為相對路徑思考)。
# @param $4: 頗析 jsonfile 的 python 位置 `parse_JsonFile_With_Key_To_Console.py`，(以當前呼叫此函式時的所屬資料夾為相對路徑思考)。
#  - 此 `parse_JsonFile_With_Key_To_Console.py` 在 scm.tools//src/python/ 下，
#    由於此函式是設計為 include 的工具函示，所以需要額外帶入，若有同樣的參數設定的不同 python 寫法，也可以替換之。
#
function dealFvmSetActiveToGlobal() {

    local func_Title_Log="*** function [${FUNCNAME[0]}] - ${1}"

    echo
    echo "${func_Title_Log} Begin ***"
    echo "${func_Title_Log} Input param : Begin ***"
    echo "${func_Title_Log} TitleLog: ${1}"
    echo "${func_Title_Log} ChangePath: ${2}"
    echo "${func_Title_Log} fvm config file: ${3}"
    echo "${func_Title_Log} parse json file by python: ${4}"
    echo "${func_Title_Log} Input param : End ***"

    local func_Param_TitleLog="${1}"
    local func_Param_ChangeFolder="${2}"
    local func_Param_Fvm_Config_File="${3}"
    local func_Param_Parse_JsonFile_BY_Python="${4}"

    echo
    echo "${func_Title_Log} ============= parse json file - Begin ============="

    local func_Key_FlutterSdkVersion="flutterSdkVersion"

    # [get python command name] : 設定支援的 python command name。
    local func_PythonList=(python python3 python2)
    local func_Execute_Python=""

    echo "${func_Title_Log} func_PythonList : ${func_PythonList[@]}"

    # [get python command name] : 使用 scm.tools 工具。
    get_first_found_command_from_input_command_list_by_using_which_command__if__result_fail_then_change_folder \
        "${func_Param_TitleLog}" func_PythonList[@] func_Execute_Python "${func_Param_ChangeFolder}"

    # [get python command name] : 可以到這，表示有找到合法的 python ， func_Execute_Python 一定有內容。
    echo "${func_Title_Log} func_Execute_Python : ${func_Execute_Python}"

    # [取得 jsonfile] : key 為 [flutterSdkVersion] 的內容。
    echo "${func_Title_Log} will execute python command : ${func_Execute_Python} ${func_Param_Parse_JsonFile_BY_Python} ${func_Param_Fvm_Config_File} ${func_Key_FlutterSdkVersion}"
    local func_FlutterSdkVersion=$(${func_Execute_Python} ${func_Param_Parse_JsonFile_BY_Python} ${func_Param_Fvm_Config_File} ${func_Key_FlutterSdkVersion})
    check_result_if_fail_then_change_folder "${func_Title_Log}" "$?" "!!! ~ parse json file => fail ~ !!!" "${2}"

    echo "${func_Title_Log} ${func_Key_FlutterSdkVersion} value : ${func_FlutterSdkVersion}"

    echo "${func_Title_Log} ============= parse json file - End ============="

    echo
    echo "${func_Title_Log} ============= fvm - Begin ============="
    echo "${func_Title_Log} fvm list [before fvm global ${func_FlutterSdkVersion}]"
    fvm list
    check_result_if_fail_then_change_folder "${func_Title_Log}" "$?" "!!! ~ fvm list => fail ~ !!!" "${2}"

    echo
    echo "${func_Title_Log} fvm global ${func_FlutterSdkVersion}"
    fvm global "${func_FlutterSdkVersion}"
    check_result_if_fail_then_change_folder "${func_Title_Log}" "$?" "!!! ~ fvm global ${func_FlutterSdkVersion} => fail ~ !!!" "${2}"

    echo
    echo "${func_Title_Log} fvm list [after fvm global ${func_FlutterSdkVersion}]"
    fvm list
    check_result_if_fail_then_change_folder "${func_Title_Log}" "$?" "!!! ~ fvm list => fail ~ !!!" "${2}"

    echo "${func_Title_Log} ============= fvm - End ============="
    echo

    echo "${func_Title_Log} End ***"
    echo
}
