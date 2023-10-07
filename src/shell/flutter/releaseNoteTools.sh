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
#   - scm.tools/src/shell/generalTools.sh
#     > func => checkResultFail_And_ChangeFolder ...
#   - configConst.sh
#     > export 參數 => configConst_CommandName_Fvm ...
#   - include 方式 :
#     - 需自行 include generalConst.sh
#     - 需自行 include generalTools.sh
#     - 需自行 include configTools.sh
#     - 再 include releaseNoteTools.sh
#

## ================================== Public Function Section : Begin ==================================
# ============= This is separation line =============
# @brief function : releastNoteTools_Gen_Init.
# @details : ReleaseNote 的初始基本資訊.
# @param ${1} : 要輸出的 title log : e.g. "${sample_Title_Log}"
# @param ${2} : release note file path: 檔名含路徑 e.g. "${sample_ReleaseNote_File}"
# @param ${3} : name: e.g. "${sample_ProjectName}"
# @param ${4} : version : 一般為對應 pubspec.yaml 的版本號碼。=> e.g. 1.0.0+0 e.g.
# @param ${5} : gitCommit : e.g. "cd8a0dc" ， "${sample_GitCommitHash}"
# @param ${6} : 若失敗要切換的路徑，change folder path : e.g. "${sample_OldPath}"
# @param ${7} : is enable fvm mode : "Y" 或 "N" : e.g. $"{sample_Is_Enable_FVM_Mode}"
function releastNoteTools_Gen_Init() {

    local func_Title_Log="*** function [${FUNCNAME[0]}] -"

    echo
    echo "${func_Title_Log} Begin ***"
    echo "${func_Title_Log} Input param : Begin ***"
    echo "${func_Title_Log} TitleLog: ${1}"
    echo "${func_Title_Log} release note file path: ${2}"
    echo "${func_Title_Log} name : ${3}"
    echo "${func_Title_Log} version : ${4}"
    echo "${func_Title_Log} gitCommmit : ${5}"
    echo "${func_Title_Log} change folder path : ${6}"
    echo "${func_Title_Log} is enable fvm mode : ${7}"
    echo "${func_Title_Log} Input param : End ***"

    local func_Param_ReleaseNote_File="${2}"
    local func_Param_Name="${3}"
    local func_Param_Version="${4}"
    local func_Param_GitCommit="${5}"
    local func_Param_ChangeFolderPath="${6}"
    local func_Param_Is_Enable_FVM_Mode="${7}"

    echo
    echo "${func_Title_Log} ${1} ============= Release Note Init Info - Begin ============="

    echo "${func_Title_Log} ${1} ReleaseNote_File in ${func_Param_ReleaseNote_File}"

    echo "# Release Note" >>"${func_Param_ReleaseNote_File}"

    echo >>"${func_Param_ReleaseNote_File}"
    echo "---" >>"${func_Param_ReleaseNote_File}"
    echo >>"${func_Param_ReleaseNote_File}"
    echo "## Project Info" >>"${func_Param_ReleaseNote_File}"
    echo >>"${func_Param_ReleaseNote_File}"
    echo "- Name : ${func_Param_Name}" >>"${func_Param_ReleaseNote_File}"
    echo >>"${func_Param_ReleaseNote_File}"
    echo "- Version : ${func_Param_Version}" >>"${func_Param_ReleaseNote_File}"
    echo >>"${func_Param_ReleaseNote_File}"
    echo "- Git Commit ID : ${func_Param_GitCommit}" >>"${func_Param_ReleaseNote_File}"
    echo >>"${func_Param_ReleaseNote_File}"
    echo "- Is Enable FVM Mode : ${func_Param_Is_Enable_FVM_Mode}" >>"${func_Param_ReleaseNote_File}"
    echo >>"${func_Param_ReleaseNote_File}"
    echo "  > 只有為 ${GENERAL_CONST_ENABLE_FLAG} 才會使用 ${configConst_CommandName_Fvm} 功能呼叫 ${configConst_CommandName_Flutter} 。" >>"${func_Param_ReleaseNote_File}"

    # ===> flutter pub get <===
    # 執行 flutter pub get 會以 pubspec.lock 為主要優先插件版本的參考檔案
    # 若是沒有 pubspec.lock 則才會以 pubspec.yaml 為主下載插件資源
    _releastNoteTools_Gen_Init_Excecute_Command_Section "${1}" "${func_Param_Is_Enable_FVM_Mode}" "pub get" \
        "${func_Param_ChangeFolderPath}"

    # ===> flutter --version --machine <===
    _releastNoteTools_Gen_Init_Excecute_Command_Section "${1}" "${func_Param_Is_Enable_FVM_Mode}" "--version --machine" \
        "${func_Param_ChangeFolderPath}" "${func_Param_ReleaseNote_File}"

    # ===> flutter doctor <===
    _releastNoteTools_Gen_Init_Excecute_Command_Section "${1}" "${func_Param_Is_Enable_FVM_Mode}" "doctor -v" \
        "${func_Param_ChangeFolderPath}" "${func_Param_ReleaseNote_File}"

    # ===> flutter pub deps <===
    _releastNoteTools_Gen_Init_Excecute_Command_Section "${1}" "${func_Param_Is_Enable_FVM_Mode}" "pub deps" \
        "${func_Param_ChangeFolderPath}" "${func_Param_ReleaseNote_File}"

    echo "${func_Title_Log} ============= Release Note Init Info - End ============="
    echo

    echo "${func_Title_Log} End ***"
    echo
}

# ============= This is separation line =============
# @brief function : releastNoteTools_Gen_Exported_Title.
# @details :
#  - 正式輸出內容的 Title : 本文內容的 title 。
#  - 在此區塊可以輸出與不同專案的的個別資訊，比如呼叫 exported.sh 的設定差異內容或此專案才有的基本資訊.
# @param ${1} : release note file path: 檔名含路徑 e.g. "${sample_ReleaseNote_File}"
function releastNoteTools_Gen_Exported_Title() {

    local func_Title_Log="*** function [${FUNCNAME[0]}] -"

    echo
    echo "${func_Title_Log} Begin ***"
    echo "${func_Title_Log} Input param : Begin ***"
    echo "${func_Title_Log} release note file path: ${1}"
    echo "${func_Title_Log} Input param : End ***"

    local func_Param_ReleaseNote_File="${1}"

    echo >>"${func_Param_ReleaseNote_File}"
    echo "---" >>"${func_Param_ReleaseNote_File}"
    echo >>"${func_Param_ReleaseNote_File}"
    echo "## Exported Info" >>"${func_Param_ReleaseNote_File}"

    echo "${func_Title_Log} End ***"
    echo
}

# ============= This is separation line =============
# @brief function : releastNoteTools_Gen_Final.
# @details :
#  - 結尾內容
# @param ${1} : release note file path: 檔名含路徑 e.g. "${sample_ReleaseNote_File}"
# @param ${2} : Elapsed time (單位 : 秒): 整個 shell 的執行時間 e.g. "${SECONDS}" or "${sample_TotalTime}"
function releastNoteTools_Gen_Final() {

    local func_Title_Log="*** function [${FUNCNAME[0]}] -"

    echo
    echo "${func_Title_Log} Begin ***"
    echo "${func_Title_Log} Input param : Begin ***"
    echo "${func_Title_Log} release note file path: ${1}"
    echo "${func_Title_Log} Elapsed time: ${2}"
    echo "${func_Title_Log} Input param : End ***"

    local func_Param_ReleaseNote_File="${1}"
    local func_TotalTime="${2}"

    echo >>"${func_Param_ReleaseNote_File}"
    echo "---" >>"${func_Param_ReleaseNote_File}"
    echo >>"${func_Param_ReleaseNote_File}"
    echo "## Total Exported Time" >>"${func_Param_ReleaseNote_File}"
    echo >>"${func_Param_ReleaseNote_File}"
    echo "- Elapsed time: ${func_TotalTime}s" >>"${func_Param_ReleaseNote_File}"
}
## ================================== Public Function Section : End ==================================

## ================================== Private Function Section : Begin ==================================
# ============= This is separation line =============
# @brief function (private) : _releastNoteTools_Gen_Init_Excecute_Command_Section.
# @details : [releastNoteTools_Gen_Init] 中關於 Excecute Command Section 的通用性函式.
# @param ${1} : 要輸出的 title log : e.g. "${sample_Title_Log}"
# @param ${2} : is enable fvm mode : "Y" 或 "N" : e.g. $"{sample_Is_Enable_FVM_Mode}"
# @param ${3} : Execute SubCommand Content : 部分的子 command content。 e.g. "${sample_Execute_SubCommand_Content}"， "pub get" ...
# @param ${4} : 若失敗要切換的路徑，change folder path : e.g. "${sample_OldPath}"
# @param ${5} : [optional] release note file path: 檔名含路徑。
#  - 若有值，則表示要將內容， dump log 到 release note file 中。 e.g. "${sample_ReleaseNote_File}"
#  - 沒有值，則直接用 console 執行。
function _releastNoteTools_Gen_Init_Excecute_Command_Section() {

    local func_Title_Log="*** function [${FUNCNAME[0]}] -"

    echo
    echo "${func_Title_Log} Begin ***"
    echo "${func_Title_Log} Input param : Begin ***"
    echo "${func_Title_Log} TitleLog: ${1}"
    echo "${func_Title_Log} is enable fvm mode : ${2}"
    echo "${func_Title_Log} excecute subCommand Content : ${3}"
    echo "${func_Title_Log} change folder path : ${4}"
    echo "${func_Title_Log} release note file path: ${5}"
    echo "${func_Title_Log} Input param : End ***"

    local func_Param_Is_Enable_FVM_Mode="${2}"
    local func_Param_Execute_SubCommand_Content="${3}"
    local func_Param_ChangeFolderPath="${4}"
    local func_Param_ReleaseNote_File="${5}"

    # ===> flutter command <===
    # command 初始設定
    local func_Execute_Command_Name
    local func_Execute_Command_Content

    # 判斷 func_Param_Is_Enable_FVM_Mode
    if [ ${func_Param_Is_Enable_FVM_Mode} = "${GENERAL_CONST_ENABLE_FLAG}" ]; then

        func_Execute_Command_Name="${configConst_CommandName_Fvm}"
        func_Execute_Command_Content="${configConst_CommandName_Flutter} ${func_Param_Execute_SubCommand_Content}"

    else

        func_Execute_Command_Name="${configConst_CommandName_Flutter}"
        func_Execute_Command_Content="${func_Param_Execute_SubCommand_Content}"
    fi

    echo "${func_Title_Log} ${1} ============= ${func_Execute_Command_Name} ${func_Execute_Command_Content} - Begin ============="

    # 若有 release note file
    if [ -n "${func_Param_ReleaseNote_File}" ]; then

        # for ReleaseNote
        echo >>"${func_Param_ReleaseNote_File}"
        echo "---" >>"${func_Param_ReleaseNote_File}"
        echo >>"${func_Param_ReleaseNote_File}"
        echo "## ${func_Execute_Command_Name} ${func_Execute_Command_Content}" >>"${func_Param_ReleaseNote_File}"
        echo >>"${func_Param_ReleaseNote_File}"

        # execute command
        echo "${func_Title_Log} ${1} ${func_Execute_Command_Name} ${func_Execute_Command_Content} >> ${func_Param_ReleaseNote_File}"
        ${func_Execute_Command_Name} ${func_Execute_Command_Content} >>"${func_Param_ReleaseNote_File}"

    else

        # execute command
        echo "${func_Title_Log} ${1} ${func_Execute_Command_Name} ${func_Execute_Command_Content}"
        ${func_Execute_Command_Name} ${func_Execute_Command_Content}

    fi

    checkResultFail_And_ChangeFolder "${func_Title_Log}" "$?" "!!! ~ ${func_Execute_Command_Name} ${func_Execute_Command_Content} => fail ~ !!!" "${func_Param_ChangeFolderPath}"

    echo "${func_Title_Log} ${1} ============= ${func_Execute_Command_Name} ${func_Execute_Command_Content} - End ============="
    echo

}
## ================================== Private Function Section : End ==================================
