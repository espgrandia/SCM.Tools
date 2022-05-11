#!/bin/bash

# @brief : 刪除 xcdoe 引用的 provision profiles。
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
    thisShell_Title_Log="[provisionProfileTool_Delete] -"

    echo
    echo "${thisShell_Title_Log} ||==========> provisionProfileTool_Delete : Begin <==========||"

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
    changeToDirectory "${thisShell_Title_Log}" "${func_Shell_WorkPath}"

    # 設定成完整路徑。
    thisShell_Shell_WorkPath=$(pwd)

    # # 設定 Provision Profile 目標位置，Xcode 使用 Provision Profile 資料夾 有其規則。
    # #  - 路徑 (command line) : ~/Library/MobileDevice/Provisioning\ Profiles
    # #  - 說明 :
    # #    由於 shell 中使用 ~/xxx 不會自動轉換成使用者的資料夾，所以要自己兜使用者路徑。
    # #    且因為是用直接用參數設定，所以不需要 Provisioning\ Profiles"
    # configConst_Xcode_Using_ProvisionProfile_Folder="/Users/$USER/Library/MobileDevice/Provisioning Profiles"

    echo "${thisShell_Title_Log} thisShell_OldPath : ${thisShell_OldPath}"
    echo "${thisShell_Title_Log} thisShell_Shell_WorkPath : ${thisShell_Shell_WorkPath}"
    echo "${thisShell_Title_Log} configConst_Xcode_Using_ProvisionProfile_Folder : ${configConst_Xcode_Using_ProvisionProfile_Folder}"
    echo
}

# ============= This is separation line =============
# @brief function : [程序] 執行 刪除 Xcode 引用的 Provision Profiles。
function process_Deal_Delete_ProvisionProfiles_From_DestFolder() {

    local func_Title_Log="${thisShell_Title_Log} *** function [${FUNCNAME[0]}] -"

    # 暫存此區塊的起始時間。
    local func_Temp_Seconds=${SECONDS}
    local func_Subcommand=${thisShell_SubcommandInfo_web[0]}

    echo
    echo "${func_Title_Log} ||==========> ${func_Subcommand} : Begin <==========||"

    # cd ~/Library/MobileDevice/Provisioning\ Profiles
    cd "${configConst_Xcode_Using_ProvisionProfile_Folder}"
    rm *.mobileprovision

    echo "${func_Title_Log} ||==========> ${func_Subcommand} : End <==========|| Elapsed time: $((${SECONDS} - ${func_Temp_Seconds}))s"
    echo

}

# ============= This is separation line =============
# @brief function : [程序] shell 全部完成需處理的部份.
function process_Finish() {

    # 全部完成
    # 切回原有執行目錄.
    changeToDirectory "${thisShell_Title_Log}" "${thisShell_OldPath}"

    echo
    echo "${thisShell_Title_Log} ||==========> provisionProfileTool_Delete : End <==========|| Elapsed time: ${SECONDS}s"
}
## ================================== prcess function section : End ==================================

## ================================== deal prcess step section : Begin ==================================
# ============= This is separation line =============
# call - [程序] 此 shell 的初始化。
process_Init

# ============= This is separation line =============
# call - [程序] 執行 刪除 Xcode 引用的 Provision Profiles。
process_Deal_Delete_ProvisionProfiles_From_DestFolder

# ============= This is separation line =============
# call - [程序] shell 全部完成需處理的部份.
process_Finish
## ================================== deal prcess step section : End ==================================

exit 0
