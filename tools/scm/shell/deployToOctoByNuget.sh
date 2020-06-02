#!/bin/bash

# Note: 此為 nuget 打包 與 佈署到 octo 的 shell.
# input 參數說明, 後面為範例.
# $1 : deployToOctoByNuget_ExcutePath="/root/xxx/abc"
# $2 : deployToOctoByNuget_MONO="/bin/mono"
# $3 : deployToOctoByNuget_NUGET="../../nuget.exe"
# $4 : deployToOctoByNuget_OCTO_APIKEY="API-38XPLCYVZGWWIL59QXSY4YRC96A"
# $5 : deployToOctoByNuget_OCTO="../../Octo.exe"
# $6 : deployToOctoByNuget_OCTO_PROJ_NAME="XSG.BravoCasino.$JOB_NAME"
# $7 : deployToOctoByNuget_NUSPEC_NAME="package.BravoCasino.nuspec" 
# $8 : deployToOctoByNuget_VERSION="1.0.$BUILD_NUMBER"
# $9 : deployToOctoByNuget_OCTO_URL=http://octopus.ci.sgt


# set variable
deployToOctoByNuget_ExcutePath=$1
deployToOctoByNuget_MONO=$2
deployToOctoByNuget_NUGET=$3
deployToOctoByNuget_OCTO_APIKEY=$4
deployToOctoByNuget_OCTO=$5
deployToOctoByNuget_OCTO_PROJ_NAME=$6
deployToOctoByNuget_NUSPEC_NAME=$7
deployToOctoByNuget_VERSION=$8
deployToOctoByNuget_OCTO_URL=$9

deployToOctoByNuget_OCTO_PACKAGE_URL=$deployToOctoByNuget_OCTO_URL/nuget/packages

deployToOctoByNuget_Title_Log="[deployToOctoByNuget] -"

echo "$deployToOctoByNuget_Title_Log ============= InPut Param : Begin ============="
echo "$deployToOctoByNuget_Title_Log deployToOctoByNuget_ExcutePath     : " $deployToOctoByNuget_ExcutePath
echo "$deployToOctoByNuget_Title_Log deployToOctoByNuget_MONO           : " $deployToOctoByNuget_MONO
echo "$deployToOctoByNuget_Title_Log deployToOctoByNuget_NUGET          : " $deployToOctoByNuget_NUGET
echo "$deployToOctoByNuget_Title_Log deployToOctoByNuget_OCTO_APIKEY    : " $deployToOctoByNuget_OCTO_APIKEY
echo "$deployToOctoByNuget_Title_Log deployToOctoByNuget_OCTO           : " $deployToOctoByNuget_OCTO
echo "$deployToOctoByNuget_Title_Log deployToOctoByNuget_OCTO_PROJ_NAME : " $deployToOctoByNuget_OCTO_PROJ_NAME
echo "$deployToOctoByNuget_Title_Log deployToOctoByNuget_NUSPEC_NAME    : " $deployToOctoByNuget_NUSPEC_NAME
echo "$deployToOctoByNuget_Title_Log deployToOctoByNuget_VERSION        : " $deployToOctoByNuget_VERSION
echo "$deployToOctoByNuget_Title_Log deployToOctoByNuget_OCTO_URL       : " $deployToOctoByNuget_OCTO_URL
echo "$deployToOctoByNuget_Title_Log ============= InPut Param : End ============="
echo ""
echo "$deployToOctoByNuget_Title_Log ============= Value : Begin ============="
echo "$deployToOctoByNuget_Title_Log deployToOctoByNuget_OCTO_PACKAGE_URL : " $deployToOctoByNuget_OCTO_PACKAGE_URL
echo "$deployToOctoByNuget_Title_Log ============= Value : End ============="
echo 
echo 


# check input...
if [[ $deployToOctoByNuget_ExcutePath == "" ]]; then
	echo "$deployToOctoByNuget_Title_Log deployToOctoByNuget_ExcutePath: $deployToOctoByNuget_ExcutePath is illegal."
	exit 1
fi

if [[ $deployToOctoByNuget_MONO == "" ]]; then
	echo "$deployToOctoByNuget_Title_Log deployToOctoByNuget_MONO: $deployToOctoByNuget_MONO is illegal."
	exit 1
fi

if [[ $deployToOctoByNuget_NUGET == "" ]]; then
	echo "$deployToOctoByNuget_Title_Log deployToOctoByNuget_NUGET: $deployToOctoByNuget_NUGET is illegal."
	exit 1
fi

if [[ $deployToOctoByNuget_OCTO_APIKEY == "" ]]; then
	echo "$deployToOctoByNuget_Title_Log deployToOctoByNuget_OCTO_APIKEY: $deployToOctoByNuget_OCTO_APIKEY is illegal."
	exit 1
fi

if [[ $deployToOctoByNuget_OCTO == "" ]]; then
	echo "$deployToOctoByNuget_Title_Log deployToOctoByNuget_OCTO: $deployToOctoByNuget_OCTO is illegal."
	exit 1
fi

if [[ $deployToOctoByNuget_OCTO_PROJ_NAME == "" ]]; then
	echo "$deployToOctoByNuget_Title_Log deployToOctoByNuget_OCTO_PROJ_NAME: $deployToOctoByNuget_OCTO_PROJ_NAME is illegal."
	exit 1
fi

if [[ $deployToOctoByNuget_NUSPEC_NAME == "" ]]; then
	echo "$deployToOctoByNuget_Title_Log deployToOctoByNuget_NUSPEC_NAME: $deployToOctoByNuget_NUSPEC_NAME is illegal."
	exit 1
fi

if [[ $deployToOctoByNuget_VERSION == "" ]]; then
	echo "$deployToOctoByNuget_Title_Log deployToOctoByNuget_VERSION: $deployToOctoByNuget_VERSION is illegal."
	exit 1
fi

if [[ $deployToOctoByNuget_OCTO_URL == "" ]]; then
	echo "$deployToOctoByNuget_Title_Log deployToOctoByNuget_OCTO_URL: $deployToOctoByNuget_OCTO_URL is illegal."
	exit 1
fi



# 切換執行目錄.
deployToOctoByNuget_OldPath=`pwd`
echo "$deployToOctoByNuget_Title_Log deployToOctoByNuget_OldPath : " $deployToOctoByNuget_OldPath 

# 切換到指定的執行路徑.
cd $deployToOctoByNuget_ExcutePath
echo "$deployToOctoByNuget_Title_Log change dir to $deployToOctoByNuget_ExcutePath"
echo "$deployToOctoByNuget_Title_Log current path: `pwd`"

# Nuget Pack
$deployToOctoByNuget_MONO $deployToOctoByNuget_NUGET pack $deployToOctoByNuget_NUSPEC_NAME -Version $deployToOctoByNuget_VERSION
if [ $? -ne 0 ]; then
	echo "$deployToOctoByNuget_Title_Log Nuget Pack Fail..."
	echo "$deployToOctoByNuget_Title_Log command: $deployToOctoByNuget_MONO $deployToOctoByNuget_NUGET pack $deployToOctoByNuget_NUSPEC_NAME -Version $deployToOctoByNuget_VERSION"

	# 切回原有執行目錄.
	cd $deployToOctoByNuget_OldPath
	echo "$deployToOctoByNuget_Title_Log change dir to $deployToOctoByNuget_OldPath"
	echo "$deployToOctoByNuget_Title_Log current path: `pwd`"

	exit 1
fi


# # Nuget Push To Octopus
$deployToOctoByNuget_MONO $deployToOctoByNuget_NUGET push $deployToOctoByNuget_OCTO_PROJ_NAME.$deployToOctoByNuget_VERSION.nupkg -s $deployToOctoByNuget_OCTO_PACKAGE_URL $deployToOctoByNuget_OCTO_APIKEY
if [ $? -ne 0 ]; then
	echo "$deployToOctoByNuget_Title_Log Nuget Push To Octopus Fail..."
	echo "$deployToOctoByNuget_Title_Log command: $deployToOctoByNuget_MONO $deployToOctoByNuget_NUGET push $deployToOctoByNuget_OCTO_PROJ_NAME.$deployToOctoByNuget_VERSION.nupkg -s $deployToOctoByNuget_OCTO_PACKAGE_URL $deployToOctoByNuget_OCTO_APIKEY"

	# 切回原有執行目錄.
	cd $deployToOctoByNuget_OldPath
	echo "$deployToOctoByNuget_Title_Log change dir to $deployToOctoByNuget_OldPath"
	echo "$deployToOctoByNuget_Title_Log current path: `pwd`"

	exit 1
fi


# # Octo Create Release
$deployToOctoByNuget_MONO $deployToOctoByNuget_OCTO create-release --project $deployToOctoByNuget_OCTO_PROJ_NAME --version $deployToOctoByNuget_VERSION --packageversion $deployToOctoByNuget_VERSION --server $deployToOctoByNuget_OCTO_URL --apikey $deployToOctoByNuget_OCTO_APIKEY
if [ $? -ne 0 ]; then
	echo "$deployToOctoByNuget_Title_Log Octo Create Release Fail..."
	echo "$deployToOctoByNuget_Title_Log command: $deployToOctoByNuget_MONO $deployToOctoByNuget_OCTO create-release --project $deployToOctoByNuget_OCTO_PROJ_NAME --version $deployToOctoByNuget_VERSION --packageversion $deployToOctoByNuget_VERSION --server $deployToOctoByNuget_OCTO_URL --apikey $deployToOctoByNuget_OCTO_APIKEY"

	# 切回原有執行目錄.
	cd $$deployToOctoByNuget_Title_Log deployToOctoByNuget_OldPath
	echo "$deployToOctoByNuget_Title_Log change dir to $deployToOctoByNuget_OldPath"
	echo "$deployToOctoByNuget_Title_Log current path: `pwd`"

	exit 1
fi

# 切回原有執行目錄.
cd $deployToOctoByNuget_OldPath
echo "$deployToOctoByNuget_Title_Log change dir to $deployToOctoByNuget_OldPath"
echo "$deployToOctoByNuget_Title_Log current path: `pwd`"

exit 0
