#!/bin/bash

# @brief : 以 輸入的 provision profile root foler 為收尋的基礎資料夾，
#          將該資料夾以下的 provision profile 都 copy 到 xcdoe 引用的 provision profile 資料夾位置。
#
# ---
#
# input 參數說明 :
#
# - $1 : this_shell_param_provision_profile_source_folder="[路徑]/[provision profile source folder]" : 要 copy 的 profision profile 的來源根目錄。
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
#   其中 [this_shell_xxx] 是跨函式讀取。
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
function process_init() {

  # 計時，實測結果不同 shell 不會影響，各自有各自的 SECONDS。
  SECONDS=0

  # 此 shell 的 dump log title.
  this_shell_title_name="provision_profile_tool_copy"
  this_shell_title_log="[${this_shell_title_name}] -"

  echo
  echo "${this_shell_title_log} ||==========> ${this_shell_title_name} : Begin <==========||"

  # 取得相對目錄.
  local func_shell_work_path=$(dirname $0)

  echo
  echo "${this_shell_title_log} func_shell_work_path : ${func_shell_work_path}"

  # 前置處理作業

  # import function
  # 因使用 include 檔案的函式，所以在此之前需先確保路經是在此 shell 資料夾中。

  # include general function
  echo
  echo "${this_shell_title_log} include general function"
  . "${func_shell_work_path}/../../general_tools.sh"

  # include const value
  echo
  echo "${this_shell_title_log} include provision_profile_tool_const.sh"
  . "${func_shell_work_path}/provision_profile_tool_const.sh"

  # 設定原先的呼叫路徑。
  this_shell_old_path=$(pwd)

  # 切換執行目錄.
  change_to_directory "${this_shell_title_log}" "${func_shell_work_path}"

  # 設定成完整路徑。
  this_shell_work_path=$(pwd)

  echo "${this_shell_title_log} this_shell_old_path : ${this_shell_old_path}"
  echo "${this_shell_title_log} this_shell_work_path : ${this_shell_work_path}"
  echo "${this_shell_title_log} CONFIG_CONST_XCODE_USING_PROVISION_PROFILE_FOLDER : ${CONFIG_CONST_XCODE_USING_PROVISION_PROFILE_FOLDER}"
  echo
}

# ============= This is separation line =============
# @brief function : [程序] 處理 input param。
# @param $1 : provision profile source folder : 要 copy 的 profision profile 的來源根目錄。
function process_deal_input_param() {

  local func_title_log="${this_shell_title_log} *** function [${FUNCNAME[0]}] -"

  # set input param variable
  this_shell_param_provision_profile_source_folder="${1}"

  # check input parameters
  check_input_param "${this_shell_title_log}" this_shell_param_provision_profile_source_folder "${this_shell_param_provision_profile_source_folder}"

  echo
  echo "${func_title_log} ||==========> Begin <==========||"
  echo "${func_title_log} this_shell_param_provision_profile_source_folder : ${this_shell_param_provision_profile_source_folder}"
  echo "${func_title_log} ||==========> End <==========||"
  echo
}

# ============= This is separation line =============
# @brief function : [程序] 執行 確保 Provision Profile 目標資料夾是合法的。
function process_guarantee_provision_profile_dest_folder_legal() {

  local func_title_log="${this_shell_title_log} *** function [${FUNCNAME[0]}] -"

  # 暫存此區塊的起始時間。
  local func_temp_seconds=${SECONDS}

  echo
  echo "${func_title_log} ||==========> Begin <==========||"

  echo "${func_title_log} mkdir -p ${CONFIG_CONST_XCODE_USING_PROVISION_PROFILE_FOLDER}"

  mkdir -p "${CONFIG_CONST_XCODE_USING_PROVISION_PROFILE_FOLDER}"

  echo "${func_title_log} ||==========> End <==========|| Elapsed time: $((${SECONDS} - ${func_temp_seconds}))s"
  echo
}

# ============= This is separation line =============
# @brief function : [程序] 執行 Copy Provision Profile。
function process_deal_copy_provision_profile() {

  local func_title_log="${this_shell_title_log} *** function [${FUNCNAME[0]}] -"

  # 暫存此區塊的起始時間。
  local func_temp_seconds=${SECONDS}

  echo
  echo "${func_title_log} ||==========> Begin <==========||"

  # 搜尋 this_shell_param_provision_profile_source_folder 下的 mobileprovision。
  local func_file_paths=$(find "${this_shell_param_provision_profile_source_folder}" -name "*.mobileprovision")

  # 複製.mobileprovision檔案到 MobileDevice/Provisioning Profiles。
  local func_file_path
  for func_file_path in ${func_file_paths[@]}; do
    echo "${func_title_log} func_file_path : ${func_file_path}"
    cp $func_file_path "${CONFIG_CONST_XCODE_USING_PROVISION_PROFILE_FOLDER}"
  done

  echo "${func_title_log} ||==========> End <==========|| Elapsed time: $((${SECONDS} - ${func_temp_seconds}))s"
  echo

}

# ============= This is separation line =============
# @brief function : [程序] shell 全部完成需處理的部份.
function process_finish() {

  # 全部完成
  # 切回原有執行目錄.
  change_to_directory "${this_shell_title_log}" "${this_shell_old_path}"

  echo
  echo "${this_shell_title_log} ||==========> ${this_shell_title_name} : End <==========|| Elapsed time: ${SECONDS}s"
}
## ================================== prcess function section : End ==================================

## ================================== deal prcess step section : Begin ==================================
# ============= This is separation line =============
# call - [程序] 此 shell 的初始化。
process_init

# ============= This is separation line =============
# call - [程序] 處理 input param。
# 需要帶入此 shell 的輸入參數。
# TODO: 可思考是否有更好的方式？
process_deal_input_param "${1}"

# ============= This is separation line =============
# call - [程序] 執行 確保 Provision Profile 目標資料夾是合法的。
process_guarantee_provision_profile_dest_folder_legal

# ============= This is separation line =============
# call - [程序] 執行 Copy Provision Profile。
process_deal_copy_provision_profile

# ============= This is separation line =============
# call - [程序] shell 全部完成需處理的部份.
process_finish
## ================================== deal prcess step section : End ==================================

exit 0
