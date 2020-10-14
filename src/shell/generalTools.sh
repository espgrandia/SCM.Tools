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
# ---
#
# Reference : 
# - title: bash - How to change the output color of echo in Linux - Stack Overflow
#   - website : https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux
#

# ============= This is separation line =============

# @brief function : change to directory .
# @detail : 簡易函式，不再處理細節的判斷，為保持正確性，參數請自行帶上 "" .
# @param $1: 要輸出的 title log : e.g. "${sample_Title_Log}" .
# @param $2: 切換的目的資料夾: e.g. "${sample_Shell_WorkPath}"，$(dirname $0)，etc ...
function changeToDirectory() {

	local func_Title_Log="*** function [changeToDirectory] -"

	echo
	echo "${func_Title_Log} Begin ***"
	echo "${func_Title_Log} Input param : Begin ***"
	echo "${func_Title_Log} TitleLog: ${1}"
	echo "${func_Title_Log} ChangeDestFolder: ${2}"
	echo "${func_Title_Log} Input param : End ***"
	echo "${func_Title_Log} ${1} current path: $(pwd) ***"

	cd ${2}

	echo "${func_Title_Log} ${1} change dir to ${2} ***"
	echo "${func_Title_Log} ${1} current path: $(pwd) ***"
	echo "${func_Title_Log} End ***"
	echo
}

# ============= This is separation line =============

# @brief function : check input param is illegal.
# @detail : 簡易函式，不再處理細節的判斷，為保持正確性，參數請自行帶上 "" .
#   - 判斷輸入參數的合法性，失敗會直接 return.
# @param $1: 要輸出的 title log : e.g. "${sample_Title_Log}" .
# @param $2: input param name: e.g. "sample_Param_ProjectRelativePath" .
# @param $3: input param value: e.g. "${sample_Param_ProjectRelativePath}" .
function checkInputParam() {

	if [[ ${3} == "" ]]; then

		# for echo color
		local func_Bold_Black='\033[1;30m'
		local func_ForegroundColor_Red='\033[0;31m'
		local func_BackgroundColor_Cyan='\033[46m'
		local func_Color_Off='\033[0m'

		# fail 再秀 log.
		local func_Title_Log="*** function [checkInputParam] -"

		echo
		echo "${func_Title_Log} Begin ***"
		echo "${func_Title_Log} Input param : Begin ***"
		echo "${func_Title_Log} TitleLog: ${1}"
		echo "${func_Title_Log} param name: ${2}"
		echo "${func_Title_Log} param value: ${3}"
		echo "${func_Title_Log} Input param : End ***"
		echo "${func_Bold_Black}${func_ForegroundColor_Red}${func_BackgroundColor_Cyan}${func_Title_Log} ${1} ${2}: ${3} is illegal. Error !!!${func_Color_Off}"
		echo "${func_Title_Log} End ***"
		echo

		exit 1
	fi
}

# ============= This is separation line =============

# @brief function : 檢查輸入 result code 是否失敗，並作對應處理。
# @detail
#   - 簡易函式，不再處理細節的判斷，為保持正確性，參數請自行帶上 "" .
#   - 檢查輸入 result 是否失敗 (0: 成功，非0: 失敗)，失敗則切換目錄，並直接 return : exit result code .
#   - 一般為呼叫完某個 command line，判斷其回傳值是否成功，失敗則離開此 shell .
# @param $1: 要輸出的 title log : e.g. "${sample_Title_Log}" .
# @param $2: 要驗證的 result value: e.g. $? : 非0為失敗 ..
# @param $3: 要 dump log" .
# @param $4: 切換回去的的 folder path" .
function checkResultFail_And_ChangeFolder() {

	if [ "${2}" -ne 0 ]; then

		# for echo color
		local func_Bold_Black='\033[1;30m'
		local func_ForegroundColor_Red='\033[0;31m'
		local func_BackgroundColor_Cyan='\033[46m'
		local func_Color_Off='\033[0m'

		# fail 再秀 log.
		local func_Title_Log="*** function [checkResultFail_And_ChangeFolder] -"

		echo
		echo "${func_Title_Log} Begin ***"
		echo
		echo "${func_Title_Log} Input param : Begin ***"
		echo "${func_Title_Log} TitleLog: ${1}"
		echo "${func_Title_Log} Result value: ${2}"
		echo "${func_Title_Log} Dump Log: ${3}"
		echo "${func_Title_Log} Change Folder: ${4}"
		echo "${func_Title_Log} Input param : End ***"

		# 切回原有執行目錄.
		echo
		echo "${func_Title_Log} ${1} ===> change director : ${4} <==="
		changeToDirectory "${1}" "${4}"

		echo
		echo "${func_Bold_Black}${func_ForegroundColor_Red}${func_BackgroundColor_Cyan}${func_Title_Log} ${1} ===> dump log : ${3} <===${func_Color_Off}"
		echo "${func_Bold_Black}${func_ForegroundColor_Red}${func_BackgroundColor_Cyan}${func_Title_Log} ${1} ===> exit shell : result : ${2} <===${func_Color_Off}"
		echo
		echo "${func_Title_Log} End ***"

		exit ${2}
	fi
}

# ============= This is separation line =============

# @brief function : split string to a pair .
# @detail : 簡易函式，不再處理細節的判斷，為保持正確性，參數請自行帶上 "" .
#   - 依據輸入的字串，分隔符號，以及要寫入的參入名稱。
#   - 剖析後，會取分隔後前兩筆寫入對應的參數。
# @param $1: 要輸出的 title log : e.g. "${exported_Title_Log}" .
# @param $2: 要分析的字串: e.g. "1.0.0+2" .
# @param $3: separator 的字串: e.g. "+" .
# @param $4: 要設定的第一個參數，拆解後取第一位的內容來設定。 e.g. sample_Shell_Split_First .
# @param $5: 要設定的第一個參數，拆解後取第二位的內容來設定。 e.g. sample_Shell_Split_Second .
function splitStringToPair() {

	local func_Title_Log="*** function [splitStringToPair] -"

	echo
	echo "${func_Title_Log} Begin ***"
	echo
	echo "${func_Title_Log} Input param : Begin ***"
	echo "${func_Title_Log} TitleLog : ${1}"
	echo "${func_Title_Log} source string : ${2}"
	echo "${func_Title_Log} separator string : ${3}"
	echo "${func_Title_Log} first name : ${4}"
	echo "${func_Title_Log} second name : ${5}"
	echo "${func_Title_Log} Input param : End ***"
	echo
	echo "${func_Title_Log} ${1} execute split ***"

	eval ${4}="$(echo ${2} | cut -d${3} -f1)"
	eval ${5}="$(echo ${2} | cut -d${3} -f2)"

	echo "${func_Title_Log} ${1} 1st : $(eval echo \$${4}) ***"
	echo "${func_Title_Log} ${1} 2nd : $(eval echo \$${5}) ***"
	echo
	echo "${func_Title_Log} End ***"
	echo
}
