#!/bin/bash

# @brief : 以 輸入的 provision profile root foler 為收尋的基礎資料夾，
#          將該資料夾以下的 provision profile 都 copy 到 xcdoe 引用的 provision profile 資料夾位置。
#
# ---
#
# input 參數說明 :
#
# - $1 : thisShell_Param_ProvisionProfile_SourceFolder="[路徑]/[provision profile source folder]" : 要 copy 的 profision profile 的來源根目錄。
#
#   - 路徑可以帶相對路徑，也可以是完整路徑。
#     - 相對路徑 : 是 [provision profile source folder] 相對於此 shell 的路徑，須以此 shell 角度來看相對路徑。
#     > 兩者都可以，不過建議用 [完整路徑] 路徑帶入，可以減少 此 shell 引用位置，也需要跟著調整的問題。
#
# ---
#
# 程式碼區塊 說明:
#
# - [通用規則] :
#   函式與此 shell 有高度相依，若要抽離到獨立 shell，需調整之。
#   其中 [thisShell_xxx] 是跨函式讀取。
#
# - 此 shell 主要分兩個主要區塊 :
#
#   - prcess function section :
#     流程函式，將流程會用到的獨立功能，以函式來呈現，
#
#   - deal prcess step section :
#     實際跑流程函式的順序，
#     會依序呼叫 [process_xxx]，
#     !!! [Waring] 有先後順序影響，不可任意調整呼叫順序，調整時務必想清楚 !!!。
#

## ================================== prcess function section : Begin ==================================
# ============= This is separation line =============
# @brief function : [程序] 此 shell 的初始化。
function process_Init() {

  # 計時，實測結果不同 shell 不會影響，各自有各自的 SECONDS。
  SECONDS=0

  # 此 shell 的 dump log title.
  thisShell_Title_Name="provisionProfileTool_Copy"
  thisShell_Title_Log="[${thisShell_Title_Name}] -"

  echo
  echo "${thisShell_Title_Log} ||==========> ${thisShell_Title_Name} : Begin <==========||"

  # 取得相對目錄.
  local func_Shell_WorkPath=$(dirname $0)

  echo
  echo "${thisShell_Title_Log} func_Shell_WorkPath : ${func_Shell_WorkPath}"

  # 前置處理作業

  # import function
  # 因使用 include 檔案的函式，所以在此之前需先確保路經是在此 shell 資料夾中。

  # include general function
  echo
  echo "${thisShell_Title_Log} include general function"
  . "${func_Shell_WorkPath}/../../generalTools.sh"

  # include const value
  echo
  echo "${thisShell_Title_Log} include provisionProfileTool_Const.sh"
  . "${func_Shell_WorkPath}/provisionProfileTool_Const.sh"

  # 設定原先的呼叫路徑。
  thisShell_OldPath=$(pwd)

  # 切換執行目錄.
  change_to_directory "${thisShell_Title_Log}" "${func_Shell_WorkPath}"

  # 設定成完整路徑。
  thisShell_Shell_WorkPath=$(pwd)

  echo "${thisShell_Title_Log} thisShell_OldPath : ${thisShell_OldPath}"
  echo "${thisShell_Title_Log} thisShell_Shell_WorkPath : ${thisShell_Shell_WorkPath}"
  echo "${thisShell_Title_Log} configConst_Xcode_Using_ProvisionProfile_Folder : ${configConst_Xcode_Using_ProvisionProfile_Folder}"
  echo
}

# ============= This is separation line =============
# @brief function : [程序] 處理 input param。
# @param $1 : provision profile source folder : 要 copy 的 profision profile 的來源根目錄。
function process_Deal_InputParam() {

  local func_Title_Log="${thisShell_Title_Log} *** function [${FUNCNAME[0]}] -"

  # set input param variable
  thisShell_Param_ProvisionProfile_SourceFolder="${1}"

  # check input parameters
  check_input_param "${thisShell_Title_Log}" thisShell_Param_ProvisionProfile_SourceFolder "${thisShell_Param_ProvisionProfile_SourceFolder}"

  echo
  echo "${func_Title_Log} ||==========> Begin <==========||"
  echo "${func_Title_Log} thisShell_Param_ProvisionProfile_SourceFolder : ${thisShell_Param_ProvisionProfile_SourceFolder}"
  echo "${func_Title_Log} ||==========> End <==========||"
  echo
}

# ============= This is separation line =============
# @brief function : [程序] 執行 確保 Provision Profile 目標資料夾是合法的。
function process_Guarantee_ProvisionProfile_DestFolder_Legal() {

  local func_Title_Log="${thisShell_Title_Log} *** function [${FUNCNAME[0]}] -"

  # 暫存此區塊的起始時間。
  local func_Temp_Seconds=${SECONDS}

  echo
  echo "${func_Title_Log} ||==========> Begin <==========||"

  echo "${func_Title_Log} mkdir -p ${configConst_Xcode_Using_ProvisionProfile_Folder}"

  mkdir -p "${configConst_Xcode_Using_ProvisionProfile_Folder}"

  echo "${func_Title_Log} ||==========> End <==========|| Elapsed time: $((${SECONDS} - ${func_Temp_Seconds}))s"
  echo
}

# ============= This is separation line =============
# @brief function : [程序] 執行 Copy Provision Profile。
function process_Deal_Copy_ProvisionProfile() {

  local func_Title_Log="${thisShell_Title_Log} *** function [${FUNCNAME[0]}] -"

  # 暫存此區塊的起始時間。
  local func_Temp_Seconds=${SECONDS}

  echo
  echo "${func_Title_Log} ||==========> Begin <==========||"

  # 搜尋 thisShell_Param_ProvisionProfile_SourceFolder 下的 mobileprovision。
  local func_FilePaths=$(find "${thisShell_Param_ProvisionProfile_SourceFolder}" -name "*.mobileprovision")

  # 複製.mobileprovision檔案到 MobileDevice/Provisioning Profiles。
  local func_A_FilePath
  for func_A_FilePath in ${func_FilePaths[@]}; do
    echo "${func_Title_Log} func_A_FilePath : ${func_A_FilePath}"
    cp $func_A_FilePath "${configConst_Xcode_Using_ProvisionProfile_Folder}"
  done

  echo "${func_Title_Log} ||==========> End <==========|| Elapsed time: $((${SECONDS} - ${func_Temp_Seconds}))s"
  echo

}

# ============= This is separation line =============
# @brief function : [程序] shell 全部完成需處理的部份.
function process_Finish() {

  # 全部完成
  # 切回原有執行目錄.
  change_to_directory "${thisShell_Title_Log}" "${thisShell_OldPath}"

  echo
  echo "${thisShell_Title_Log} ||==========> ${thisShell_Title_Name} : End <==========|| Elapsed time: ${SECONDS}s"
}
## ================================== prcess function section : End ==================================

## ================================== deal prcess step section : Begin ==================================
# ============= This is separation line =============
# call - [程序] 此 shell 的初始化。
process_Init

# ============= This is separation line =============
# call - [程序] 處理 input param。
# 需要帶入此 shell 的輸入參數。
# TODO: 可思考是否有更好的方式？
process_Deal_InputParam "${1}"

# ============= This is separation line =============
# call - [程序] 執行 確保 Provision Profile 目標資料夾是合法的。
process_Guarantee_ProvisionProfile_DestFolder_Legal

# ============= This is separation line =============
# call - [程序] 執行 Copy Provision Profile。
process_Deal_Copy_ProvisionProfile

# ============= This is separation line =============
# call - [程序] shell 全部完成需處理的部份.
process_Finish
## ================================== deal prcess step section : End ==================================

exit 0
