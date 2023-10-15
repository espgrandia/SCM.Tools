#!/bin/bash

# @brief : 刪除 xcdoe 引用的 provision profiles。
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
    this_shell_title_name="provisionProfileTool_Delete"
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
    echo "${this_shell_title_log} include provisionProfileTool_Const.sh"
    . "${func_shell_work_path}/provisionProfileTool_Const.sh"

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
# @brief function : [程序] 執行 刪除 Xcode 引用的 Provision Profiles。
function process_deal_delete_provision_profiles_from_dest_folder() {

    local func_title_log="${this_shell_title_log} *** function [${FUNCNAME[0]}] -"

    # 暫存此區塊的起始時間。
    local func_temp_seconds=${SECONDS}

    echo
    echo "${func_title_log} ||==========> Begin <==========||"

    # cd ~/Library/MobileDevice/Provisioning\ Profiles
    cd "${CONFIG_CONST_XCODE_USING_PROVISION_PROFILE_FOLDER}"
    rm *.mobileprovision

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
# call - [程序] 執行 刪除 Xcode 引用的 Provision Profiles。
process_deal_delete_provision_profiles_from_dest_folder

# ============= This is separation line =============
# call - [程序] shell 全部完成需處理的部份.
process_finish
## ================================== deal prcess step section : End ==================================

exit 0
