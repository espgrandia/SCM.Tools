#!/bin/bash

# ============= This is separation line =============
# @brief : flutter / dart 的擴展工具函式。
# @details : 放置常用與 flutter 有關的輔助工具函式，使用者可以引用此檔案來使用函式。
#  - 可供外部使用的函式，請看 [Public Function Section] 區塊。
#
# @author : esp
# @create date : 2021-08-25
#
# ---
#
# 注意事項:
# - 使用此通用函式，有相依 include 檔案於
#   - scm.tools/src/shell/general_const.sh
#     > func => check_result_if_fail_then_change_folder ...
#   - config_const.sh
#     > export 參數 => CONFIG_CONST_COMMAND_NAME_FVM ...
#   - include 方式 :
#     - 需自行 include general_const.sh
#     - 需自行 include general_tools.sh
#     - 需自行 include config_tools.sh
#     - 再 include flutterExtensionTools.sh
#

## ================================== Public Function Section : Begin ==================================
##
# ============= This is separation line =============
# @brief function : [dart_extension_tools_deal_is_enable_fvm_mode_and_relay__to__check_ok_then_excute_command__if__result_fail_then_change_folder]
#   - 說明 : 處理 fvm mode 資訊，會調整後續呼叫的 command name， 以及 command params，
#           再轉呼叫 [Check_OK_Then_Excute_Command__If__ResultFail_Then_ChangeFolder] 來執行命令。
# @detail : 簡易函式，不再處理細節的判斷，為保持正確性，參數請自行帶上 "".
#   - 主要參數及使用方式，請參考 [check_ok_then_excute_command] 說明。
#
# @Params :
# @param ${1}: 要輸出的 title log : e.g. "${sample_title_log}" .
# @param ${2}: is enable fvm mode : "Y" 或 "N" : e.g. "${sample_is_enable_fvm_mode}"
# @Param ${3}: isExcute : 是否要執行命令 => "Y" 或 "N" => e.g. "${sample_is_execute}"
# @Param ${4}: commandParams : 要執行的 command 的參數資訊，為 array => e.g. sample_command_params[@]
# @param ${5}: 切換回去的的 folder path" => e.g. "${sample_change_folder}"
#
# sample e.g. dart_extension_tools_deal_is_enable_fvm_mode_and_relay__to__check_ok_then_excute_command__if__result_fail_then_change_folder \
#  "${sample_title_log}" "${sample_is_enable_fvm_mode}" "${sample_is_execute}" sample_command_params[@] "${sample_change_folder}"
function dart_extension_tools_deal_is_enable_fvm_mode_and_relay__to__check_ok_then_excute_command__if__result_fail_then_change_folder() {

    local func_title_log="*** function [${FUNCNAME[0]}] -"

    echo
    echo "${func_title_log} Begin ***"
    echo "${func_title_log} Input param : Begin ***"
    echo "${func_title_log} TitleLog: ${1}"
    echo "${func_title_log} is enable fvm mode : ${2}"
    echo "${func_title_log} isExcute : ${3}"
    echo "${func_title_log} command params : ${!4}"
    echo "${func_title_log} change folder : ${5}"
    echo "${func_title_log} Input param : End ***"

    # 應用於函式中主體的 title log。
    local func_main_body_title_log="${func_title_log} ${1}"

    # [params]
    local func_param_is_enable_fvm_mode="${2}"
    local func_param_is_excute="${3}"
    local func_param_command_params=("${!4}")
    local func_param_change_folder="${5}"

    # ===> flutter command <===
    # command 初始設定
    local func_command_name=""
    local func_command_params=()

    # 判斷 func_param_is_enable_fvm_mode
    if [ ${func_param_is_enable_fvm_mode} = "${GENERAL_CONST_ENABLE_FLAG}" ]; then

        func_command_name="${CONFIG_CONST_COMMAND_NAME_FVM}"
        func_command_params+=("${CONFIG_CONST_COMMAND_NAME_DART}")

    else

        func_command_name="${CONFIG_CONST_COMMAND_NAME_DART}"

    fi

    # 處理 execute params。
    func_command_params+=("${func_param_command_params[@]}")

    echo
    echo "${func_main_body_title_log} command info : Begin ***"
    echo "${func_main_body_title_log} func_command_name : ${func_command_name}"
    echo "${func_main_body_title_log} func_command_params : ${func_command_params[@]}"
    echo "${func_main_body_title_log} func_command_params count : ${#func_command_params[@]}"
    echo "${func_main_body_title_log} command info : End ***"
    echo

    # execute command
    # 呼叫通用函式來處理是否要執行該 command 以及錯誤的後續處理。
    check_ok_then_excute_command__if__result_fail_then_change_folder "${func_title_log}" "${func_param_is_excute}" \
        "${func_command_name}" func_command_params[@] "${func_param_change_folder}"

    echo "${func_title_log} End ***"
    echo
}

# ============= This is separation line =============
# @brief function : [flutter_extension_tools_deal_is_enable_fvm_mode_and_relay__to__check_ok_then_excute_command__if__result_fail_then_change_folder]
#   - 說明 : 處理 fvm mode 資訊，會調整後續呼叫的 command name， 以及 command params，
#           再轉呼叫 [Check_OK_Then_Excute_Command__If__ResultFail_Then_ChangeFolder] 來執行命令。
# @detail : 簡易函式，不再處理細節的判斷，為保持正確性，參數請自行帶上 "".
#   - 主要參數及使用方式，請參考 [check_ok_then_excute_command] 說明。
#
# @Params :
# @param ${1}: 要輸出的 title log : e.g. "${sample_title_log}" .
# @param ${2}: is enable fvm mode : "Y" 或 "N" : e.g. "${sample_is_enable_fvm_mode}"
# @Param ${3}: isExcute : 是否要執行命令 => "Y" 或 "N" => e.g. "${sample_is_execute}"
# @Param ${4}: commandParams : 要執行的 command 的參數資訊，為 array => e.g. sample_command_params[@]
# @param ${5}: 切換回去的的 folder path" => e.g. "${sample_change_folder}"
#
# sample e.g. flutter_extension_tools_deal_is_enable_fvm_mode_and_relay__to__check_ok_then_excute_command__if__result_fail_then_change_folder \
#  "${sample_title_log}" "${sample_is_enable_fvm_mode}" "${sample_is_execute}" sample_command_params[@] "${sample_change_folder}"
function flutter_extension_tools_deal_is_enable_fvm_mode_and_relay__to__check_ok_then_excute_command__if__result_fail_then_change_folder() {

    local func_title_log="*** function [${FUNCNAME[0]}] -"

    echo
    echo "${func_title_log} Begin ***"
    echo "${func_title_log} Input param : Begin ***"
    echo "${func_title_log} TitleLog: ${1}"
    echo "${func_title_log} is enable fvm mode : ${2}"
    echo "${func_title_log} isExcute : ${3}"
    echo "${func_title_log} command params : ${!4}"
    echo "${func_title_log} change folder : ${5}"
    echo "${func_title_log} Input param : End ***"

    # 應用於函式中主體的 title log。
    local func_main_body_title_log="${func_title_log} ${1}"

    # [params]
    local func_param_is_enable_fvm_mode="${2}"
    local func_param_is_excute="${3}"
    local func_param_command_params=("${!4}")
    local func_param_change_folder="${5}"

    # ===> flutter command <===
    # command 初始設定
    local func_command_name=""
    local func_command_params=()

    # 判斷 func_param_is_enable_fvm_mode
    if [ ${func_param_is_enable_fvm_mode} = "${GENERAL_CONST_ENABLE_FLAG}" ]; then

        func_command_name="${CONFIG_CONST_COMMAND_NAME_FVM}"
        func_command_params+=("${CONFIG_CONST_COMMAND_NAME_FLUTTER}")

    else

        func_command_name="${CONFIG_CONST_COMMAND_NAME_FLUTTER}"

    fi

    # 處理 execute params。
    func_command_params+=("${func_param_command_params[@]}")

    echo
    echo "${func_main_body_title_log} command info : Begin ***"
    echo "${func_main_body_title_log} func_command_name : ${func_command_name}"
    echo "${func_main_body_title_log} func_command_params : ${func_command_params[@]}"
    echo "${func_main_body_title_log} func_command_params count : ${#func_command_params[@]}"
    echo "${func_main_body_title_log} command info : End ***"
    echo

    # execute command
    # 呼叫通用函式來處理是否要執行該 command 以及錯誤的後續處理。
    check_ok_then_excute_command__if__result_fail_then_change_folder "${func_title_log}" "${func_param_is_excute}" \
        "${func_command_name}" func_command_params[@] "${func_param_change_folder}"

    echo "${func_title_log} End ***"
    echo
}

# ============= This is separation line =============
# @brief function : flutter_extension_tools_generator_version_machine_file。
# @details : 要產生的 flutter version machin 資訊的檔案。
#  - 需注意，該檔案內容會直接覆蓋，資料夾路徑須先準備好，這裡不做資料夾路徑檢查。
#  - 若 local 沒有該版本，在 console dump version 版本時，會需要手動按下允許。
#    此時若不允許，則產生的檔案會有問題，請自行排除之。
# @param ${1} : 要輸出的 title log : e.g. "${sample_title_log}"
# @param ${2} : is enable fvm mode : "Y" 或 "N" : e.g. $"{sample_is_enable_fvm_mode}"
# @param ${3} : 要產生的檔案， generator file path: 檔名含路徑 e.g. "${sample_generator_flutter_version_machine_file}"
# @param ${4} : 若失敗要切換的路徑，change folder path : e.g. "${sample_old_path}"
function flutter_extension_tools_generator_version_machine_file() {

    local func_title_log="*** function [${FUNCNAME[0]}] -"

    echo
    echo "${func_title_log} Begin ***"
    echo "${func_title_log} Input param : Begin ***"
    echo "${func_title_log} TitleLog: ${1}"
    echo "${func_title_log} is enable fvm mode : ${2}"
    echo "${func_title_log} generator file path: ${3}"
    echo "${func_title_log} change folder path : ${4}"
    echo "${func_title_log} Input param : End ***"

    # 應用於函式中主體的 title log。
    local func_main_body_title_log="${func_title_log} ${1}"

    # [params]
    local func_param_is_enable_fvm_mode="${2}"
    local func_param_generator_file="${3}"
    local func_param_change_folder_path="${4}"

    echo
    echo "${func_main_body_title_log} ============= Generator Flutter Version Machine To File - Begin ============="

    echo "" >"${func_param_generator_file}"
    echo "const Map<String, String> flutterVersionMachine = <String, String>" >>"${func_param_generator_file}"

    # ===> flutter command <===
    # command 初始設定
    local func_execute_command_name
    local func_execute_command_content
    local func_execute_command_subcommand_content="--version --machine"

    # 判斷 func_param_is_enable_fvm_mode
    if [ ${func_param_is_enable_fvm_mode} = "${GENERAL_CONST_ENABLE_FLAG}" ]; then

        func_execute_command_name="${CONFIG_CONST_COMMAND_NAME_FVM}"
        func_execute_command_content="${CONFIG_CONST_COMMAND_NAME_FLUTTER} ${func_execute_command_subcommand_content}"

    else

        func_execute_command_name="${CONFIG_CONST_COMMAND_NAME_FLUTTER}"
        func_execute_command_content="${func_execute_command_subcommand_content}"
    fi

    # [execute command] : 於 terminal 先呼叫一次，有可能 local 第一次下載此版本，此時需要手動操作，使用者需按下允許更新。
    echo "${func_main_body_title_log} Execute Command => [ ${func_execute_command_name} ${func_execute_command_content} ] <="
    ${func_execute_command_name} ${func_execute_command_content}
    check_result_if_fail_then_change_folder "${func_title_log}" "$?" "!!! ~ ${func_execute_command_name} ${func_execute_command_content} => fail ~ !!!" "${func_param_change_folder_path}"

    # [execute command] : 再次呼叫 command，此次會寫到檔案。
    echo "${func_main_body_title_log} Execute Command => [ ${func_execute_command_name} ${func_execute_command_content} >> ${func_param_generator_file} ] <="
    ${func_execute_command_name} ${func_execute_command_content} >>"${func_param_generator_file}"
    check_result_if_fail_then_change_folder "${func_title_log}" "$?" "!!! ~ [ ${func_execute_command_name} ${func_execute_command_content} >> ${func_param_generator_file} ] => fail ~ !!!" "${func_param_change_folder_path}"

    echo ";" >>"${func_param_generator_file}"

    echo "${func_main_body_title_log} ============= Generator Flutter Version Machine To File - End ============="
    echo

    echo "${func_title_log} End ***"
    echo
}
##
## ================================== Public Function Section : End ==================================

## ================================== Private Function Section : Begin ==================================
##
# TBD，暫時保留區。
##
## ================================== Private Function Section : End ==================================
