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
		checkInputParam_Title_Log="*** function [checkInputParam_Title_Log] -"
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
