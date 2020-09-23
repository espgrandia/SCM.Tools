#!/bin/bash

# ============= This is separation line =============
# @brief : 一般性工具.
# @details : 放置常用工具函式，使用者可以引用此檔案來使用函式.
# @author : esp
# @create date : 2020-09-01
# sample :
#  ``` shell
#  # include changeToDirectory function
#  . src/generalTools.sh
#
#  changeToDirectory "${sample_Title_Log}" "${sample_Shell_WorkPath}"
#  ```
#
# ============= This is separation line =============

# function block.

# @brief function : change to directory.
# @detail : 簡易函式，不再處理細節的判斷，為保持正確性，參數請自行帶上 "".
# @param $1: 要輸出的 title log : e.g. "${sample_Title_Log}"
# @param $2: 切換的目的資料夾: e.g. "${sample_Shell_WorkPath}"，$(dirname $0)，etc ...
function changeToDirectory(){
	changeToDirectory_Title_Log="*** function [changeToDirectory] -"
	echo
	echo "${changeToDirectory_Title_Log} Begin ***"
	echo "${changeToDirectory_Title_Log} Input param : Begin ***"
	echo "${changeToDirectory_Title_Log} TitleLog: ${1}"
	echo "${changeToDirectory_Title_Log} ChangeDestFolder: ${2}"
	echo "${changeToDirectory_Title_Log} Input param : End ***"
	echo "${changeToDirectory_Title_Log} ${1} current path: `pwd` ***"
	cd ${2}
	echo "${changeToDirectory_Title_Log} ${1} change dir to ${2} ***"
	echo "${changeToDirectory_Title_Log} ${1} current path: `pwd` ***"
	echo "${changeToDirectory_Title_Log} End ***"
	echo
}

# @brief function : check input param is illegal.
# @detail : 簡易函式，不再處理細節的判斷，為保持正確性，參數請自行帶上 "".
# @detail : 判斷輸入參數的合法性，失敗會直接 return.
# @param $1: 要輸出的 title log : e.g. "${sample_Title_Log}"
# @param $2: input param name: e.g. "sample_Param_ProjectRelativePath".
# @param $3: input param value: e.g. "${sample_Param_ProjectRelativePath}".
function checkInputParam(){

	if [[ ${3} == "" ]]; then
		# fail 再秀 log.
		checkInputParam_Title_Log="*** function [checkInputParam] -"
		echo
		echo "${checkInputParam_Title_Log} Begin ***"
		echo "${checkInputParam_Title_Log} Input param : Begin ***"
		echo "${checkInputParam_Title_Log} TitleLog: ${1}"
		echo "${checkInputParam_Title_Log} param name: ${2}"
		echo "${checkInputParam_Title_Log} param value: ${3}"
		echo "${checkInputParam_Title_Log} Input param : End ***"
		echo "${checkInputParam_Title_Log} ${1} ${2}: ${3} is illegal. Error !!!"
		echo "${checkInputParam_Title_Log} End ***"
		echo
		exit 1
	fi
}

# ============= This is separation line =============
# @brief function : 檢查輸入 result code 是否失敗，並作對應處理。
# @detail 
#  - 簡易函式，不再處理細節的判斷，為保持正確性，參數請自行帶上 "".
#  - 檢查輸入 result 是否失敗 (0: 成功，非0: 失敗)，失敗則切換目錄，並直接 return : exit result code.
#  - 一般為呼叫完某個 command line，判斷其回傳值是否成功，失敗則離開此 shell.
# @param $1: 要輸出的 title log : e.g. "${sample_Title_Log}"
# @param $2: 要驗證的 result value: e.g. $? : 非0為失敗.
# @param $3: 要 dump log".
# @param $4: 切換回去的的 folder path".
function checkResultFail_And_ChangeFolder(){

	if [ "${2}" -ne 0 ]; then
		# fail 再秀 log.
		checkResultFail_And_ChangeFolder_Title_Log="*** function [checkResultFail_And_ChangeFolder] -"
		echo
		echo "${checkResultFail_And_ChangeFolder_Title_Log} Begin ***"
		echo "${checkResultFail_And_ChangeFolder_Title_Log} Input param : Begin ***"
		echo "${checkResultFail_And_ChangeFolder_Title_Log} TitleLog: ${1}"
		echo "${checkResultFail_And_ChangeFolder_Title_Log} Result value: ${2}"
		echo "${checkResultFail_And_ChangeFolder_Title_Log} Dump Log: ${3}"
        echo "${checkResultFail_And_ChangeFolder_Title_Log} Change Folder: ${4}"
		echo "${checkResultFail_And_ChangeFolder_Title_Log} Input param : End ***"
		echo "${checkResultFail_And_ChangeFolder_Title_Log} End ***"

        # 切回原有執行目錄.
		echo
        echo "${checkResultFail_And_ChangeFolder_Title_Log} ${1} ===> change director : ${4} <==="
        changeToDirectory "${1}" "${4}"

        echo
		echo "${checkResultFail_And_ChangeFolder_Title_Log} ${1} ===> dump log : ${3} <==="
        echo "${checkResultFail_And_ChangeFolder_Title_Log} ${1} ===> exit shell : result : ${2} <==="
		exit ${2}
	fi
}
