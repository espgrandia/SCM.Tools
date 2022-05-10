#!/bin/bash

# ============= This is separation line =============
# @brief : 此為 xcode 編譯 framework 並產出 fat libery 的 shell.
# @author : esp
# @create date : 2018-12-05
#
# @input 參數說明, 後面為範例.
# $1 : buildXcodeFramework_Param_ProjectRelativePath="../"   
#    : [專案檔的路徑，相對於此shell的資料夾所在位置來看]
# $2 : buildXcodeFramework_Param_ProjFolderName="SampleProject.xcodeproj"
#    : [framework 專案的 project folder name].
# $3 : buildXcodeFramework_Param_SchemeName="SampleProject"
#    : [framework 專案的 scheme 名稱].
# $4 : buildXcodeFramework_Param_ConfigurationType="Debug"
#    : [編譯組態].
# $5 : buildXcodeFramework_Param_BUILD_DIR="SCM/Output"
#    : [編譯後的 product 輸出目錄].
#    : [相對目錄: xcode 專案檔來思考相對目錄 : buildXcodeFramework_Param_ProjectRelativePath].
# $6 : buildXcodeFramework_Param_DerivedData="SCM/DerivedData"
#    : [編譯過程的暫存檔].
#    : [相對目錄: xcode 專案檔來思考相對目錄 : buildXcodeFramework_Param_ProjectRelativePath].
# $7 : buildXcodeFramework_Param_ExportedFolder="../exported"
#    : [framework最後的產出目錄].
#    : [相對目錄: xcode 專案檔來思考相對目錄 : buildXcodeFramework_Param_ProjectRelativePath].


# ============= This is separation line =============

# function block.

# @brief function : change to directory.
# @detail : 簡易函式，不再處理細節的判斷，為保持正確性，參數請自行帶上 "".
# @param $1: 要輸出的 title log : e.g. "${buildXcodeFramework_Title_Log}"
# @param $2: 切換的目的資料夾: e.g. "${buildXcodeFramework_Shell_WorkPath}".
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
# @param $1: 要輸出的 title log : e.g. "${buildXcodeFramework_Title_Log}"
# @param $2: input param name: e.g. "buildXcodeFramework_Param_ProjectRelativePath".
# @param $3: input param value: e.g. "${buildXcodeFramework_Param_ProjectRelativePath}".
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

# ============= This is separation line =============
# set input param variable
buildXcodeFramework_Param_ProjectRelativePath=$1
buildXcodeFramework_Param_ProjFolderName=$2
buildXcodeFramework_Param_SchemeName=$3
buildXcodeFramework_Param_ConfigurationType=$4
buildXcodeFramework_Param_BUILD_DIR=$5
buildXcodeFramework_Param_DerivedData=$6
buildXcodeFramework_Param_ExportedFolder=$7

# 此 shell 的 dump log title.
buildXcodeFramework_Title_Log="[buildFramework] -"

echo 
echo "${buildXcodeFramework_Title_Log} ============= Param : Begin ============="
echo "${buildXcodeFramework_Title_Log} buildXcodeFramework_Param_ProjectRelativePath : ${buildXcodeFramework_Param_ProjectRelativePath}" 
echo "${buildXcodeFramework_Title_Log} buildXcodeFramework_Param_ProjFolderName      : ${buildXcodeFramework_Param_ProjFolderName}" 
echo "${buildXcodeFramework_Title_Log} buildXcodeFramework_Param_SchemeName          : ${buildXcodeFramework_Param_SchemeName}" 
echo "${buildXcodeFramework_Title_Log} buildXcodeFramework_Param_ConfigurationType   : ${buildXcodeFramework_Param_ConfigurationType}" 
echo "${buildXcodeFramework_Title_Log} buildXcodeFramework_Param_BUILD_DIR           : ${buildXcodeFramework_Param_BUILD_DIR}" 
echo "${buildXcodeFramework_Title_Log} buildXcodeFramework_Param_DerivedData         : ${buildXcodeFramework_Param_DerivedData}" 
echo "${buildXcodeFramework_Title_Log} buildXcodeFramework_Param_ExportedFolder      : ${buildXcodeFramework_Param_ExportedFolder}" 
echo "${buildXcodeFramework_Title_Log} ============= Param : End ============="
echo 

# ============= This is separation line =============
# check input param ...
echo 
echo "${buildXcodeFramework_Title_Log} check input param"
checkInputParam "${buildXcodeFramework_Title_Log}" buildXcodeFramework_Param_ProjectRelativePath "${buildXcodeFramework_Param_ProjectRelativePath}"
checkInputParam "${buildXcodeFramework_Title_Log}" buildXcodeFramework_Param_ProjFolderName "${buildXcodeFramework_Param_ProjFolderName}"
checkInputParam "${buildXcodeFramework_Title_Log}" buildXcodeFramework_Param_SchemeName "${buildXcodeFramework_Param_SchemeName}"
checkInputParam "${buildXcodeFramework_Title_Log}" buildXcodeFramework_Param_ConfigurationType "${buildXcodeFramework_Param_ConfigurationType}"
checkInputParam "${buildXcodeFramework_Title_Log}" buildXcodeFramework_Param_BUILD_DIR "${buildXcodeFramework_Param_BUILD_DIR}"
checkInputParam "${buildXcodeFramework_Title_Log}" buildXcodeFramework_Param_DerivedData "${buildXcodeFramework_Param_DerivedData}"
checkInputParam "${buildXcodeFramework_Title_Log}" buildXcodeFramework_Param_ExportedFolder "${buildXcodeFramework_Param_ExportedFolder}"

# ============= This is separation line =============
# 切換執行目錄.
buildXcodeFramework_OldPath=`pwd`
echo 
echo "${buildXcodeFramework_Title_Log} buildXcodeFramework_OldPath : " ${buildXcodeFramework_OldPath} 
echo "${buildXcodeFramework_Title_Log} current path: `pwd`"

# 先切到 shell 目錄 (之後會切換到 project 目錄)
buildXcodeFramework_Shell_WorkPath=$(dirname $0)
# buildXcodeFramework_Shell_WorkPath=$(dirname $(readlink -f $0))
echo 
echo "${buildXcodeFramework_Title_Log} buildXcodeFramework_Shell_WorkPath : " ${buildXcodeFramework_Shell_WorkPath} 
changeToDirectory "${buildXcodeFramework_Title_Log}" "${buildXcodeFramework_Shell_WorkPath}"

# 切換到指定的執行路徑.
echo 
echo "${buildXcodeFramework_Title_Log} buildXcodeFramework_Param_ProjectRelativePath : " ${buildXcodeFramework_Param_ProjectRelativePath} 
changeToDirectory "${buildXcodeFramework_Title_Log}" "${buildXcodeFramework_Param_ProjectRelativePath}"

# ============= This is separation line =============
# delete folder.
echo 
echo "${buildXcodeFramework_Title_Log} delete folder : ${buildXcodeFramework_Param_DerivedData}"
echo "${buildXcodeFramework_Title_Log} delete folder : ${buildXcodeFramework_Param_BUILD_DIR}"

rm -rf ${buildXcodeFramework_Param_DerivedData}
rm -rf ${buildXcodeFramework_Param_BUILD_DIR}

# ============= This is separation line =============
# build iphoneos
buildXcodeFramework_TmpCommandLine="-project "${buildXcodeFramework_Param_ProjFolderName}" -scheme "${buildXcodeFramework_Param_SchemeName}" ONLY_ACTIVE_ARCH=NO -configuration "${buildXcodeFramework_Param_ConfigurationType}" -sdk iphoneos BUILD_DIR="${buildXcodeFramework_Param_BUILD_DIR}" -derivedDataPath "${buildXcodeFramework_Param_DerivedData}" clean build"
echo 
echo "${buildXcodeFramework_Title_Log} build iphoneos"
echo "${buildXcodeFramework_Title_Log} xcodebuild ${buildXcodeFramework_TmpCommandLine}"
xcodebuild ${buildXcodeFramework_TmpCommandLine}
if [ $? -ne 0 ]; then
	echo 
	echo "${buildXcodeFramework_Title_Log} xcodebuild Fail..."
	echo "${buildXcodeFramework_Title_Log} ${buildXcodeFramework_TmpCommandLine}"

	# 切回原有執行目錄.
	changeToDirectory "${buildXcodeFramework_Title_Log}" "${buildXcodeFramework_OldPath}"

	exit 10
fi

# build iphone simulator
buildXcodeFramework_TmpCommandLine="-project "${buildXcodeFramework_Param_ProjFolderName}" -scheme "${buildXcodeFramework_Param_SchemeName}" ONLY_ACTIVE_ARCH=NO -configuration "${buildXcodeFramework_Param_ConfigurationType}" -sdk iphonesimulator BUILD_DIR="${buildXcodeFramework_Param_BUILD_DIR}" -derivedDataPath "${buildXcodeFramework_Param_DerivedData}" clean build"
echo 
echo "${buildXcodeFramework_Title_Log} build iphone simulator"
echo "${buildXcodeFramework_Title_Log} xcodebuild ${buildXcodeFramework_TmpCommandLine}"
xcodebuild ${buildXcodeFramework_TmpCommandLine}
if [ $? -ne 0 ]; then
	echo 
	echo "${buildXcodeFramework_Title_Log} xcodebuild Fail..."
	echo "${buildXcodeFramework_Title_Log} ${buildXcodeFramework_TmpCommandLine}"

	# 切回原有執行目錄.
	changeToDirectory "${buildXcodeFramework_Title_Log}" "${buildXcodeFramework_OldPath}"
	exit 11
fi


# ============= This is separation line =============
# export framework
echo 
echo echo "${buildXcodeFramework_Title_Log} deal exported framework using lipo"
buildXcodeFramework_Src1RootFolder="${buildXcodeFramework_Param_BUILD_DIR}/${buildXcodeFramework_Param_ConfigurationType}-iphoneos/${buildXcodeFramework_Param_SchemeName}.framework"
buildXcodeFramework_Src2RootFolder="${buildXcodeFramework_Param_BUILD_DIR}/${buildXcodeFramework_Param_ConfigurationType}-iphonesimulator/${buildXcodeFramework_Param_SchemeName}.framework"
buildXcodeFramework_ExportedOutputFolder="${buildXcodeFramework_Param_ExportedFolder}/${buildXcodeFramework_Param_SchemeName}.framework"

echo 
echo "${buildXcodeFramework_Title_Log} ============= exported extra value : Begin ============="
echo "${buildXcodeFramework_Title_Log} buildXcodeFramework_Src1RootFolder         : ${buildXcodeFramework_Src1RootFolder}" 
echo "${buildXcodeFramework_Title_Log} buildXcodeFramework_Src2RootFolder         : ${buildXcodeFramework_Src2RootFolder}" 
echo "${buildXcodeFramework_Title_Log} buildXcodeFramework_ExportedOutputFolder   : ${buildXcodeFramework_ExportedOutputFolder}" 
echo "${buildXcodeFramework_Title_Log} ============= exported extra value : End ============="
echo 

# ============= This is separation line =============
echo 
echo "${buildXcodeFramework_Title_Log} try to remove ${buildXcodeFramework_Param_ExportedFolder}"
rm -r ${buildXcodeFramework_Param_ExportedFolder}

echo "${buildXcodeFramework_Title_Log} try to mkdir $buildXcodeFramework_Param_ExportedFolder"
mkdir ${buildXcodeFramework_Param_ExportedFolder}

echo "${buildXcodeFramework_Title_Log} cp -R ${buildXcodeFramework_Src1RootFolder} ${buildXcodeFramework_Param_ExportedFolder}"
cp -R ${buildXcodeFramework_Src1RootFolder} ${buildXcodeFramework_Param_ExportedFolder}

# ============= This is separation line =============
# lipo -create ...
buildXcodeFramework_TmpCommandLine="-create "${buildXcodeFramework_Src1RootFolder}/${buildXcodeFramework_Param_SchemeName}" "${buildXcodeFramework_Src2RootFolder}/${buildXcodeFramework_Param_SchemeName}" -output "${buildXcodeFramework_ExportedOutputFolder}/${buildXcodeFramework_Param_SchemeName}""
echo 
echo "${buildXcodeFramework_Title_Log} framework join to fat libery"
echo "${buildXcodeFramework_Title_Log} lipo ${buildXcodeFramework_TmpCommandLine}"
lipo ${buildXcodeFramework_TmpCommandLine}
if [ $? -ne 0 ]; then
	echo 
	echo "${buildXcodeFramework_Title_Log} lipo create Fail..."
	echo "${buildXcodeFramework_Title_Log} lipo ${buildXcodeFramework_TmpCommandLine}"

	# 切回原有執行目錄.
	changeToDirectory "${buildXcodeFramework_Title_Log}" "${buildXcodeFramework_OldPath}"
	exit 20
fi


# lipo -info ...
buildXcodeFramework_TmpCommandLine="-info "${buildXcodeFramework_ExportedOutputFolder}/${buildXcodeFramework_Param_SchemeName}""
echo 
echo "${buildXcodeFramework_Title_Log} dump framework info"
echo "${buildXcodeFramework_Title_Log} lipo ${buildXcodeFramework_TmpCommandLine}"
lipo ${buildXcodeFramework_TmpCommandLine}
if [ $? -ne 0 ]; then
	echo 
	echo "${buildXcodeFramework_Title_Log} lipo info Fail..."
	echo "${buildXcodeFramework_Title_Log} lipo ${buildXcodeFramework_TmpCommandLine}"

	# 切回原有執行目錄.
	changeToDirectory "${buildXcodeFramework_Title_Log}" "${buildXcodeFramework_OldPath}"
	exit 21
fi

# 全部完成
# 切回原有執行目錄.
changeToDirectory "${buildXcodeFramework_Title_Log}" "${buildXcodeFramework_OldPath}"
exit 0
