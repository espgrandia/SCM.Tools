#!/bin/bash

# ============= This is separation line =============
# @brief : flutter project 中，exporte 相關 shell ，會用到的 release note 工具.
# @details : 放置常用產出部分 release 內容的工具函式，使用者可以引用此檔案來使用函式.
# @author : esp
# @create date : 2020-10-22
#
# ---
#
# 注意事項:
# - 使用此通用函式，有相依於 scm.tools/src/shell/generalTools.sh
#   - 其中有使用到 checkResultFail_And_ChangeFolder
#   - 需自行 include generalTools.sh
#   - 再 include releaseNoteTools.sh
#

# ============= This is separation line =============
# @brief function : releastNoteTools_Gen_Init.
# @details : ReleaseNote 的初始基本資訊.
# @param ${1} : 要輸出的 title log : e.g. "${sample_Title_Log}"
# @param ${2} : release note file path: 檔名含路徑 e.g. "${sample_ReleaseNote_File}"
# @param ${3} : name: e.g. "${sample_ProjectName}"
# @param ${4} : version : 一般為對應 pubspec.yaml 的版本號碼。=> e.g. 1.0.0+0 e.g.
# @param ${5} : gitCommit : e.g. "cd8a0dc" ， "${sample_GitCommitHash}"
# @param ${6} : 若失敗要切換的路徑，change folder path : e.g. "${sample_OldPath}"
function releastNoteTools_Gen_Init() {

    local func_Title_Log="*** function [${FUNCNAME[0]}] -"

    echo
    echo "${func_Title_Log} Begin ***"
    echo "${func_Title_Log} Input param : Begin ***"
    echo "${func_Title_Log} TitleLog: "${1}""
    echo "${func_Title_Log} release note file path: "${2}""
    echo "${func_Title_Log} name : "${3}""
    echo "${func_Title_Log} version : "${4}""
    echo "${func_Title_Log} gitCommmit : "${5}""
    echo "${func_Title_Log} change folder path : "${6}""
    echo "${func_Title_Log} Input param : End ***"

    local func_Param_ReleaseNote_File="$2"
    local func_Param_Name="$3"
    local func_Param_Version="$4"
    local func_Param_GitCommit="$5"
    local func_Param_ChangeFolderPath="$5"

    echo
    echo "${func_Title_Log} "${1}" ============= Release Note Init Info - Begin ============="

    echo "${func_Title_Log} "${1}" ReleaseNote_File in ${func_Param_ReleaseNote_File}"

    echo "# Release Note" >>"${func_Param_ReleaseNote_File}"

    echo >>"${func_Param_ReleaseNote_File}"
    echo "---" >>"${func_Param_ReleaseNote_File}"
    echo >>"${func_Param_ReleaseNote_File}"
    echo "## Project info" >>"${func_Param_ReleaseNote_File}"
    echo >>"${func_Param_ReleaseNote_File}"
    echo "- name : ${func_Param_Name}" >>"${func_Param_ReleaseNote_File}"
    echo >>"${func_Param_ReleaseNote_File}"
    echo "- version : ${func_Param_Version}" >>"${func_Param_ReleaseNote_File}"
    echo >>"${func_Param_ReleaseNote_File}"
    echo "- git Commit ID : ${func_Param_GitCommit}" >>"${func_Param_ReleaseNote_File}"

    # 執行 flutter pub get 會以 pubspec.lock 為主要優先插件版本的參考檔案
    # 若是沒有 pubspec.lock 則才會以 pubspec.yaml 為主下載插件資源

    echo "${func_Title_Log} "${1}" ============= flutter pub get - Begin ============="

    echo "${func_Title_Log} "${1}" 開始更新 packages 插件資源 => flutter pub get"
    flutter pub get
    checkResultFail_And_ChangeFolder "${func_Title_Log}" "$?" "!!! ~ flutter pub get => fail ~ !!!" "${func_Param_ChangeFolderPath}"

    echo "${func_Title_Log} ============= flutter pub get - End ============="
    echo

    # ===> flutter doctor <===
    echo "${func_Title_Log} "${1}" flutter doctor >> ${func_Param_ReleaseNote_File}"

    echo >>"${func_Param_ReleaseNote_File}"
    echo "---" >>"${func_Param_ReleaseNote_File}"
    echo >>"${func_Param_ReleaseNote_File}"
    echo "## flutter doctor -v" >>"${func_Param_ReleaseNote_File}"
    echo >>"${func_Param_ReleaseNote_File}"
    flutter doctor -v >>"${func_Param_ReleaseNote_File}"
    checkResultFail_And_ChangeFolder "${func_Title_Log}" "$?" "!!! ~ flutter doctor -v => fail ~ !!!" "${func_Param_ChangeFolderPath}"

    # ===> flutter pub deps <===
    echo "${func_Title_Log} flutter pub deps >> ${func_Param_ReleaseNote_File}"

    echo >>"${func_Param_ReleaseNote_File}"
    echo "---" >>"${func_Param_ReleaseNote_File}"
    echo >>"${func_Param_ReleaseNote_File}"
    echo "## flutter pub deps" >>"${func_Param_ReleaseNote_File}"
    echo >>"${func_Param_ReleaseNote_File}"
    flutter pub deps >>"${func_Param_ReleaseNote_File}"
    checkResultFail_And_ChangeFolder "${func_Title_Log}" "$?" "!!! ~ flutter pub deps => fail ~ !!!" "${func_Param_ChangeFolderPath}"

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
    echo "${func_Title_Log} release note file path: "${1}""
    echo "${func_Title_Log} Input param : End ***"

    local func_Param_ReleaseNote_File="$1"

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
    echo "${func_Title_Log} release note file path: "${1}""
    echo "${func_Title_Log} Elapsed time: "${2}""
    echo "${func_Title_Log} Input param : End ***"

    local func_Param_ReleaseNote_File="$1"
    local func_TotalTime="$2"

    echo >>"${func_Param_ReleaseNote_File}"
    echo "---" >>"${func_Param_ReleaseNote_File}"
    echo >>"${func_Param_ReleaseNote_File}"
    echo "## Total Exported Time" >>"${func_Param_ReleaseNote_File}"
    echo >>"${func_Param_ReleaseNote_File}"
    echo "- Elapsed time: ${func_TotalTime}s" >>"${func_Param_ReleaseNote_File}"
}
