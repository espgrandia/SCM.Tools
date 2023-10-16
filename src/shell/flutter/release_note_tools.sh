#!/bin/bash

# ============= This is separation line =============
# @brief : flutter project 中，exporte 相關 shell ，會用到的 release note 工具。
# @details : 放置常用產出部分 release 內容的工具函式，使用者可以引用此檔案來使用函式。
#  - 可供外部使用的函式，請看 [Public Function Section] 區塊。
#
# @author : esp
# @create date : 2020-10-22
#
# ---
#
# 注意事項:
# - 使用此通用函式，有相依 include 檔案於
#   - scm.tools/src/shell/general_tools.sh
#     > func => check_result_if_fail_then_change_folder ...
#   - config_const.sh
#     > export 參數 => CONFIG_CONST_COMMAND_NAME_FVM ...
#   - include 方式 :
#     - 需自行 include general_const.sh
#     - 需自行 include general_tools.sh
#     - 需自行 include config_tools.sh
#     - 再 include release_note_tools.sh
#

## ================================== Public Function Section : Begin ==================================
# ============= This is separation line =============
# @brief function : release_note_tools_gen_init.
# @details : ReleaseNote 的初始基本資訊.
# @param ${1} : 要輸出的 title log : e.g. "${sample_title_log}"
# @param ${2} : release note file path: 檔名含路徑 e.g. "${sample_release_note_file}"
# @param ${3} : name: e.g. "${sample_project_name}"
# @param ${4} : version : 一般為對應 pubspec.yaml 的版本號碼。=> e.g. 1.0.0+0 e.g.
# @param ${5} : gitCommit : e.g. "cd8a0dc" ， "${sample_git_commit_hash}"
# @param ${6} : 若失敗要切換的路徑，change folder path : e.g. "${sample_old_path}"
# @param ${7} : is enable fvm mode : "Y" 或 "N" : e.g. $"{sample_is_enable_fvm_mode}"
function release_note_tools_gen_init() {

    local func_title_log="*** function [${FUNCNAME[0]}] -"

    echo
    echo "${func_title_log} Begin ***"
    echo "${func_title_log} Input param : Begin ***"
    echo "${func_title_log} TitleLog: ${1}"
    echo "${func_title_log} release note file path: ${2}"
    echo "${func_title_log} name : ${3}"
    echo "${func_title_log} version : ${4}"
    echo "${func_title_log} gitCommmit : ${5}"
    echo "${func_title_log} change folder path : ${6}"
    echo "${func_title_log} is enable fvm mode : ${7}"
    echo "${func_title_log} Input param : End ***"

    local func_param_release_note_file="${2}"
    local func_param_name="${3}"
    local func_param_version="${4}"
    local func_param_git_commit="${5}"
    local func_param_change_folder_path="${6}"
    local func_param_is_enable_fvm_mode="${7}"

    echo
    echo "${func_title_log} ${1} ============= Release Note Init Info - Begin ============="

    echo "${func_title_log} ${1} ReleaseNote_File in ${func_param_release_note_file}"

    echo "# Release Note" >>"${func_param_release_note_file}"

    echo >>"${func_param_release_note_file}"
    echo "---" >>"${func_param_release_note_file}"
    echo >>"${func_param_release_note_file}"
    echo "## Project Info" >>"${func_param_release_note_file}"
    echo >>"${func_param_release_note_file}"
    echo "- Name : ${func_param_name}" >>"${func_param_release_note_file}"
    echo >>"${func_param_release_note_file}"
    echo "- Version : ${func_param_version}" >>"${func_param_release_note_file}"
    echo >>"${func_param_release_note_file}"
    echo "- Git Commit ID : ${func_param_git_commit}" >>"${func_param_release_note_file}"
    echo >>"${func_param_release_note_file}"
    echo "- Is Enable FVM Mode : ${func_param_is_enable_fvm_mode}" >>"${func_param_release_note_file}"
    echo >>"${func_param_release_note_file}"
    echo "  > 只有為 ${GENERAL_CONST_ENABLE_FLAG} 才會使用 ${CONFIG_CONST_COMMAND_NAME_FVM} 功能呼叫 ${CONFIG_CONST_COMMAND_NAME_FLUTTER} 。" >>"${func_param_release_note_file}"

    # ===> flutter pub get <===
    # 執行 flutter pub get 會以 pubspec.lock 為主要優先插件版本的參考檔案
    # 若是沒有 pubspec.lock 則才會以 pubspec.yaml 為主下載插件資源
    _release_note_tools_gen_init_excecute_command_section "${1}" "${func_param_is_enable_fvm_mode}" "pub get" \
        "${func_param_change_folder_path}"

    # ===> flutter --version --machine <===
    _release_note_tools_gen_init_excecute_command_section "${1}" "${func_param_is_enable_fvm_mode}" "--version --machine" \
        "${func_param_change_folder_path}" "${func_param_release_note_file}"

    # ===> flutter doctor <===
    _release_note_tools_gen_init_excecute_command_section "${1}" "${func_param_is_enable_fvm_mode}" "doctor -v" \
        "${func_param_change_folder_path}" "${func_param_release_note_file}"

    # ===> flutter pub deps <===
    _release_note_tools_gen_init_excecute_command_section "${1}" "${func_param_is_enable_fvm_mode}" "pub deps" \
        "${func_param_change_folder_path}" "${func_param_release_note_file}"

    echo "${func_title_log} ============= Release Note Init Info - End ============="
    echo

    echo "${func_title_log} End ***"
    echo
}

# ============= This is separation line =============
# @brief function : release_note_tools_gen_exported_title.
# @details :
#  - 正式輸出內容的 Title : 本文內容的 title 。
#  - 在此區塊可以輸出與不同專案的的個別資訊，比如呼叫 exported.sh 的設定差異內容或此專案才有的基本資訊.
# @param ${1} : release note file path: 檔名含路徑 e.g. "${sample_release_note_file}"
function release_note_tools_gen_exported_title() {

    local func_title_log="*** function [${FUNCNAME[0]}] -"

    echo
    echo "${func_title_log} Begin ***"
    echo "${func_title_log} Input param : Begin ***"
    echo "${func_title_log} release note file path: ${1}"
    echo "${func_title_log} Input param : End ***"

    local func_param_release_note_file="${1}"

    echo >>"${func_param_release_note_file}"
    echo "---" >>"${func_param_release_note_file}"
    echo >>"${func_param_release_note_file}"
    echo "## Exported Info" >>"${func_param_release_note_file}"

    echo "${func_title_log} End ***"
    echo
}

# ============= This is separation line =============
# @brief function : release_note_tools_gen_final.
# @details :
#  - 結尾內容
# @param ${1} : release note file path: 檔名含路徑 e.g. "${sample_release_note_file}"
# @param ${2} : Elapsed time (單位 : 秒): 整個 shell 的執行時間 e.g. "${SECONDS}" or "${sample_total_time}"
function release_note_tools_gen_final() {

    local func_title_log="*** function [${FUNCNAME[0]}] -"

    echo
    echo "${func_title_log} Begin ***"
    echo "${func_title_log} Input param : Begin ***"
    echo "${func_title_log} release note file path: ${1}"
    echo "${func_title_log} Elapsed time: ${2}"
    echo "${func_title_log} Input param : End ***"

    local func_param_release_note_file="${1}"
    local func_total_time="${2}"

    echo >>"${func_param_release_note_file}"
    echo "---" >>"${func_param_release_note_file}"
    echo >>"${func_param_release_note_file}"
    echo "## Total Exported Time" >>"${func_param_release_note_file}"
    echo >>"${func_param_release_note_file}"
    echo "- Elapsed time: ${func_total_time}s" >>"${func_param_release_note_file}"
}
## ================================== Public Function Section : End ==================================

## ================================== Private Function Section : Begin ==================================
# ============= This is separation line =============
# @brief function (private) : _release_note_tools_gen_init_excecute_command_section.
# @details : [release_note_tools_gen_init] 中關於 Excecute Command Section 的通用性函式.
# @param ${1} : 要輸出的 title log : e.g. "${sample_title_log}"
# @param ${2} : is enable fvm mode : "Y" 或 "N" : e.g. $"{sample_is_enable_fvm_mode}"
# @param ${3} : Execute SubCommand Content : 部分的子 command content。 e.g. "${sample_execute_subcommand_content}"， "pub get" ...
# @param ${4} : 若失敗要切換的路徑，change folder path : e.g. "${sample_old_path}"
# @param ${5} : [optional] release note file path: 檔名含路徑。
#  - 若有值，則表示要將內容， dump log 到 release note file 中。 e.g. "${sample_release_note_file}"
#  - 沒有值，則直接用 console 執行。
function _release_note_tools_gen_init_excecute_command_section() {

    local func_title_log="*** function [${FUNCNAME[0]}] -"

    echo
    echo "${func_title_log} Begin ***"
    echo "${func_title_log} Input param : Begin ***"
    echo "${func_title_log} TitleLog: ${1}"
    echo "${func_title_log} is enable fvm mode : ${2}"
    echo "${func_title_log} excecute subCommand Content : ${3}"
    echo "${func_title_log} change folder path : ${4}"
    echo "${func_title_log} release note file path: ${5}"
    echo "${func_title_log} Input param : End ***"

    local func_param_is_enable_fvm_mode="${2}"
    local func_param_execute_subcommand_content="${3}"
    local func_param_change_folder_path="${4}"
    local func_param_release_note_file="${5}"

    # ===> flutter command <===
    # command 初始設定
    local func_execute_command_name
    local func_execute_command_content

    # 判斷 func_param_is_enable_fvm_mode
    if [ ${func_param_is_enable_fvm_mode} = "${GENERAL_CONST_ENABLE_FLAG}" ]; then

        func_execute_command_name="${CONFIG_CONST_COMMAND_NAME_FVM}"
        func_execute_command_content="${CONFIG_CONST_COMMAND_NAME_FLUTTER} ${func_param_execute_subcommand_content}"

    else

        func_execute_command_name="${CONFIG_CONST_COMMAND_NAME_FLUTTER}"
        func_execute_command_content="${func_param_execute_subcommand_content}"
    fi

    echo "${func_title_log} ${1} ============= ${func_execute_command_name} ${func_execute_command_content} - Begin ============="

    # 若有 release note file
    if [ -n "${func_param_release_note_file}" ]; then

        # for ReleaseNote
        echo >>"${func_param_release_note_file}"
        echo "---" >>"${func_param_release_note_file}"
        echo >>"${func_param_release_note_file}"
        echo "## ${func_execute_command_name} ${func_execute_command_content}" >>"${func_param_release_note_file}"
        echo >>"${func_param_release_note_file}"

        # execute command
        echo "${func_title_log} ${1} ${func_execute_command_name} ${func_execute_command_content} >> ${func_param_release_note_file}"
        ${func_execute_command_name} ${func_execute_command_content} >>"${func_param_release_note_file}"

    else

        # execute command
        echo "${func_title_log} ${1} ${func_execute_command_name} ${func_execute_command_content}"
        ${func_execute_command_name} ${func_execute_command_content}

    fi

    check_result_if_fail_then_change_folder "${func_title_log}" "$?" "!!! ~ ${func_execute_command_name} ${func_execute_command_content} => fail ~ !!!" "${func_param_change_folder_path}"

    echo "${func_title_log} ${1} ============= ${func_execute_command_name} ${func_execute_command_content} - End ============="
    echo

}
## ================================== Private Function Section : End ==================================
