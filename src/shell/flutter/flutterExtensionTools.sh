#!/bin/bash

# ============= This is separation line =============
# @brief : flutter 的擴展工具函式。
# @details : 放置常用與 flutter 有關的輔助工具函式，使用者可以引用此檔案來使用函式.
#  - 可供外部使用的函式，請看 [Public Function Section] 區塊。
# @author : esp
# @create date : 2021-08-25
#
# ---
#
# 注意事項:
# - 使用此通用函式，有相依 include 檔案於
#   - scm.tools/src/shell/generalConst.sh
#     > func => checkResultFail_And_ChangeFolder ...
#   - configConst.sh
#     > export 參數 => configConst_CommandName_Fvm ...
#   - include 方式 :
#     - 需自行 include generalConst.sh
#     - 需自行 include generalTools.sh
#     - 需自行 include configTools.sh
#     - 再 include flutterExtensionTools.sh
#

## ================================== Public Function Section : Begin ==================================
# ============= This is separation line =============
# @brief function : flutterExtensionTools_Generator_VersionMachine_File。
# @details : 要產生的 flutter version machin 資訊的檔案。
#  - 需注意，該檔案內容會直接覆蓋，資料夾路徑須先準備好，這裡不做資料夾路徑檢查。
# @param ${1} : 要輸出的 title log : e.g. "${sample_Title_Log}"
# @param ${2} : is enable fvm mode : "Y" 或 "N" : e.g. $"{sample_Is_Enable_FVM_Mode}"
# @param ${3} : 要產生的檔案， generator file path: 檔名含路徑 e.g. "${sample_Generator_FlutterVersionMachin_File}"
# @param ${4} : 若失敗要切換的路徑，change folder path : e.g. "${sample_OldPath}"
function flutterExtensionTools_Generator_VersionMachine_File() {

    local func_Title_Log="*** function [${FUNCNAME[0]}] -"

    echo
    echo "${func_Title_Log} Begin ***"
    echo "${func_Title_Log} Input param : Begin ***"
    echo "${func_Title_Log} TitleLog: ${1}"
    echo "${func_Title_Log} is enable fvm mode : ${2}"
    echo "${func_Title_Log} generator file path: ${3}"
    echo "${func_Title_Log} change folder path : ${4}"
    echo "${func_Title_Log} Input param : End ***"

    local func_Param_Is_Enable_FVM_Mode="${2}"
    local func_Param_Generator_File="${3}"
    local func_Param_ChangeFolderPath="${4}"

    echo
    echo "${func_Title_Log} ${1} ============= Generator Flutter Version Machine To File - Begin ============="

    echo "">"${func_Param_Generator_File}"
    echo "const Map<String, String> flutterVersionMachine = const <String, String>" >> "${func_Param_Generator_File}"

    # ===> flutter command <===
    # command 初始設定
    local func_Execute_Command_Name
    local func_Execute_Command_Content
    local func_Execute_Command_SubCommand_Content="--version --machine"

	# 判斷 func_Param_Is_Enable_FVM_Mode
	if [ ${func_Param_Is_Enable_FVM_Mode} = "${generalConst_Enable_Flag}" ]; then

		func_Execute_Command_Name="${configConst_CommandName_Fvm}"
        func_Execute_Command_Content="${configConst_CommandName_Flutter} ${func_Execute_Command_SubCommand_Content}"

	else

		func_Execute_Command_Name="${configConst_CommandName_Flutter}"
        func_Execute_Command_Content="${func_Execute_Command_SubCommand_Content}"
	fi

    # execute command
    echo "${func_Title_Log} ${1} ${func_Execute_Command_Name} ${func_Execute_Command_Content} >> ${func_Param_Generator_File}"
    ${func_Execute_Command_Name} ${func_Execute_Command_Content}>>"${func_Param_Generator_File}"
    checkResultFail_And_ChangeFolder "${func_Title_Log}" "$?" "!!! ~ ${func_Execute_Command_Name} ${func_Execute_Command_Content} => fail ~ !!!" "${func_Param_ChangeFolderPath}"
    
    echo ";" >> "${func_Param_Generator_File}"


    echo "${func_Title_Log} ${1} ============= Generator Flutter Version Machine To File - End ============="
    echo

    echo "${func_Title_Log} End ***"
    echo
}
## ================================== Public Function Section : End ==================================


## ================================== Private Function Section : Begin ==================================
# TBD，暫時保留區。
## ================================== Private Function Section : End ==================================
