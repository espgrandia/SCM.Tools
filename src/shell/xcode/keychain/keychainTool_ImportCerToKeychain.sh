#!/bin/bash

# Note :
#   此 shell 為 import 客製化 keychain 並設定為預設鑰匙圈。
#   目的為方便管理開發者憑證。
#   此 shell 為提供 import cer to keychain 的工具 shell。
#   使用者只要呼叫此 shell 則會設定此客製化的 keychain 為預設鑰匙圈。
#   > 若有原來登入的 login keychain，會一併加入為 search lis)。
#
# ---
#
# input 參數說明 :
#
# - $1 : thisShell_Param_ConfigFile="[專案路徑]/[scm]/output/config.yaml" : 設定 import cer to keychain 的 config 功能檔案 [需帶完整路徑].
#
#   - 內容為協議好的格式，只是做成可彈性設定的方式，可選項目，沒有則以基本編譯。
#
#   - 目前 keychainTool_ImportCerToKeychain.sh 支援的功能，在 configTools.sh 會有對應函式可以設定到 config.yaml 中。
#
#   - sample file : keychainConfig.yaml
#
#
# ---
#
#
# Config File sample :
#
# [required] 必要資訊。
#   ``` yaml
#   required:
#     keychain:
#       name: App.Keychain
#       password: 123456
#     cer_info_key_names :
#       - cer_info_app_share
#   ```
#
# [extra] 額外的 cer info unit 資訊，最外層的 key name 是動態取得 (由 required 資訊提供)
#   ``` yaml
#   cer_info_app_share:
#     file_password_separator: +
#     file_password_list:
#       - app.share/doc/abc.p12+abc
#       - app.share/doc/def.p12+def
#   ```
#
# [optional] [work_path] sction
# - [work_path] : 指定 shell 執行的工作目錄。
# - => e.g. "/Users/[UserName]/Desktop/Code/[some_app_project]/submodules/app.share"。
#   ``` yaml
#   optional :
#     work_path : /Users/esp/Desktop/Code/app_flutter_project/submodules/app.share
#   ```
#
# ---
#
# 通用性 const define :
#
# - const define : "Y" 或 "N" 改使用 "${GENERAL_CONST_ENABLE_FLAG}" 或 "${GENERAL_CONST_DISABLE_FLAG}" 來判斷 ， 定義在 generalConst.sh
#
# ---
#
# Toggle Feature (切換功能) 說明:
#
# - thisShell_ToogleFeature_IsDumpSet_When_Parse_ConfigFile="${GENERAL_CONST_ENABLE_FLAG}" => e.g. "${GENERAL_CONST_ENABLE_FLAG}" 或 "${GENERAL_CONST_DISABLE_FLAG}"
#   - 是否開啟 dump set 內容，當 parse build config file 時，會去判斷。
#   - 上傳版本會是關閉狀態，若需要測試時，自行打開。
#
# ---
#
# thisShell_Config_xxx 說明 :
#
# - 來源 : 來自於 build config 轉換成的 shell 內部參數。
#   經由讀取 build config file (對應於 thisShell_Param_ConfigFile 內容) 來處理，
#   細部說明可參考 configTools.sh
#
# - required :
#
#   - thisShell_Config_required_keychain_name
#     要設定的鑰匙圈名稱，在  會顯示的名稱 => e.g. xxx.App.Keychain。
#
#   - thisShell_Config_required_keychain_password
#     要設定的鑰匙圈密碼，需要存取該鑰匙圈需要輸入的密碼 => e.g. abc123
#
#   - thisShell_Config_required_cer_info_key_names=([0]="cer_info_app_A" [1]="cer_info_app_B")
#     需要額外處理的 cer infos，針對每一個 key name，會動態去取得 cer info unit 資訊。
#
# ---
#
# - extra [cer info unit]:
#
#   由 thisShell_Config_required_cer_info_key_names 的內容，動態取得對應的 yaml key 的內容。 cer_info_app_A
#   > 如 thisShell_Config_required_cer_info_key_names=([0]="cer_info_app_A" [1]="cer_info_app_B") ，
#   > 則需要取得 cer_info_app_A ， cer_info_app_B 的內容。
#
#   - thisShell_Config_[cer_info_name] :
#     主要的 key name ， [cer_info_name] 是動態取得。
#     > e.g. cer_info_app_A
#
#     - thisShell_Config_[cer_info_name]_file_password_separator :
#       分隔符號。
#
#     - thisShell_Config_[cer_info_name]_file_password_list :
#       file 與 password 為乙組的資訊。
#       以 `file_password_separator` 做拆分，沒有後面部分，視同無密碼。。
#
# ---
#
# - optional :
#
#   - work_path :
#     - thisShell_Config_optional_work_path :
#       [work_path] : 指定 shell 執行的工作目錄。
#
# ---
#
# 程式碼區塊 說明:
#
# - [通用規則] :
#   函式與此 shell 有高度相依，若要抽離到獨立 shell，需調整之。
#   其中 [thisShell_xxx] 是跨函式讀取。
#
# - 此 shell 主要分四個主要區塊 :
#
#   - config function section :
#     有關 build config 處理的相關函式。
#
#   - extra [addCerToKeychain] function section :
#     新增 cer 到指定的 keychain 的函式。
#
#   - prcess function section :
#     流程函式，將流程會用到的獨立功能，以函式來呈現，
#
#   - deal prcess step section :
#     實際跑流程函式的順序，
#     會依序呼叫 [process_xxx]，
#     !!! [Waring] 有先後順序影響，不可任意調整呼叫順序，調整時務必想清楚 !!!。
#

## ================================== config function section : Begin ==================================

# ============= This is separation line =============
# @brief function : 剖析 required 部分。
#        如 : keychain_name ， keychain_password ...
# @detail : 簡易函式，不再處理細節的判斷，為保持正確性，參數請自行帶上 "".
#   - 拆解成獨立函式，但是內容跟此 shell 有高度相依，只是獨立函式容易閱讀。
function parseReruiredSection() {

    local func_Title_Log="${thisShell_Title_Log} *** function [${FUNCNAME[0]}] -"

    echo
    echo "${func_Title_Log} ||==========> Begin <==========||"

    # check input parameters
    checkInputParam "${func_Title_Log}" thisShell_Config_required_keychain_name "${thisShell_Config_required_keychain_name}"
    checkInputParam "${func_Title_Log}" thisShell_Config_required_keychain_password "${thisShell_Config_required_keychain_password}"
    checkInputParam "${func_Title_Log}" thisShell_Config_required_cer_info_key_names "${thisShell_Config_required_cer_info_key_names[@]}"

    echo
    echo "${func_Title_Log} ============= Param : Begin ============="
    echo "${func_Title_Log} thisShell_Config_required_keychain_name : ${thisShell_Config_required_keychain_name}"
    echo "${func_Title_Log} thisShell_Config_required_keychain_password : ${thisShell_Config_required_keychain_password}"
    echo "${func_Title_Log} thisShell_Config_required_cer_info_key_names : ${thisShell_Config_required_cer_info_key_names[@]}"
    echo "${func_Title_Log} ============= Param : End ============="
    echo

    echo "${func_Title_Log} ||==========> End <==========||"
    echo
}

# ============= This is separation line =============
# @brief function : 確認 extra cer info unit 是否合法。
#   如 : cer_info_app_share，...
#   ``` yaml
#   cer_info_app_share:
#     file_password_separator: +
#     file_password_list:
#       - app.share/doc/abc.p12+abc
#       - app.share/doc/def.p12+def
#   ```
# @detail : 簡易函式，不再處理細節的判斷，為保持正確性，參數請自行帶上 "".
#   - 拆解成獨立函式，但是內容跟此 shell 有高度相依，只是獨立函式容易閱讀。
#   - 只檢查是否為合法設定。
#
# @param $1 : cer_info_key_name
function check_ExtraCerInfoUnit_Legal() {

    local func_Title_Log="${thisShell_Title_Log} *** function [${FUNCNAME[0]}] -"

    echo
    echo "${func_Title_Log} ||==========> Begin <==========||"

    local func_Param_CerInfoKeyName=${1}

    # file_password_separator 允許為空，有值才處理，這裡只單純 dump log，不驗證。
    local func_Check_Legal_CerInfoKeyName_FilePassword_Separator=thisShell_Config_${func_Param_CerInfoKeyName}_file_password_separator
    local func_Check_Legal_CerInfoKeyName_FilePassword_List=thisShell_Config_${func_Param_CerInfoKeyName}_file_password_list

    # checkInputParam "${func_Title_Log}" ${func_Check_Legal_CerInfoKeyName_FilePassword_Separator} "$(eval echo \${$func_Check_Legal_CerInfoKeyName_FilePassword_Separator})"
    checkInputParam "${func_Title_Log}" ${func_Check_Legal_CerInfoKeyName_FilePassword_List} "$(eval echo \${$func_Check_Legal_CerInfoKeyName_FilePassword_List[@]})"

    echo "${func_Title_Log} ${func_Check_Legal_CerInfoKeyName_FilePassword_Separator} : $(eval echo \${$func_Check_Legal_CerInfoKeyName_FilePassword_Separator})"

    echo "${func_Title_Log} ${func_Check_Legal_CerInfoKeyName_FilePassword_List} : $(eval echo \${$func_Check_Legal_CerInfoKeyName_FilePassword_List[@]})"
    echo "${func_Title_Log} ${func_Check_Legal_CerInfoKeyName_FilePassword_List} count : $(eval echo \${\#$func_Check_Legal_CerInfoKeyName_FilePassword_List[@]})"

    local func_FilePassword_Separator="$(eval echo \${$func_Check_Legal_CerInfoKeyName_FilePassword_Separator})"
    local func_FilePassword_List=($(eval echo \${$func_Check_Legal_CerInfoKeyName_FilePassword_List[@]}))

    echo "${func_Title_Log} func_FilePassword_Separator : ${func_FilePassword_Separator}"

    echo "${func_Title_Log} func_FilePassword_List : ${func_FilePassword_List[@]}"
    echo "${func_Title_Log} func_FilePassword_List count : ${#func_FilePassword_List[@]}"

    echo "${func_Title_Log} ||==========> End <==========||"
    echo
}

# ============= This is separation line =============
# @brief function : 剖析 extra cerInfo 部分，
#   如 : cer_info_app_share，...
#   ``` yaml
#   cer_info_app_share:
#     file_password_separator: +
#     file_password_list:
#       - app.share/doc/abc.p12+abc
#       - app.share/doc/def.p12+def
#   ```
# @detail : 簡易函式，不再處理細節的判斷，為保持正確性，參數請自行帶上 "".
#   - 拆解成獨立函式，但是內容跟此 shell 有高度相依，只是獨立函式容易閱讀。
#   - 只檢查是否為合法設定。
function parseExtraCerInfoSection() {

    local func_Title_Log="${thisShell_Title_Log} *** function [${FUNCNAME[0]}] -"

    echo
    echo "${func_Title_Log} ||==========> Begin <==========||"

    local func_i
    for ((func_i = 0; func_i < ${#thisShell_Config_required_cer_info_key_names[@]}; func_i++)); do #請注意 ((   )) 雙層括號

        local aCerInfoKeyName=${thisShell_Config_required_cer_info_key_names[${func_i}]}
        echo "${thisShell_Title_Log} aCerInfoKeyName : ${aCerInfoKeyName}"

        check_ExtraCerInfoUnit_Legal "${aCerInfoKeyName}"

    done

    echo "${func_Title_Log} ||==========> End <==========||"
    echo
}
## ================================== config function section : End ==================================

## ================================== extra function section : Begin ==================================

# @brief function : 新增 cer 到指定的 keychain.
# @detail : 簡易函式，不再處理細節的判斷，為保持正確性，參數請自行帶上 "".
# @param $1: 要輸出的 title log : 為此 shell 統一輸出的 title
# @param $2: keychainName: [xxx]Keychain".
# @param $3: cerFilePath (cer 的路徑，可為 .cer 或 .p12 檔案) : e.g. "/[cer]/[acbApp].p12".
# @param $4: p12Pwd (.p12 的密碼，可為空，若為空則不設定密碼到 keychain): e.g. "acbApp".
function addCerToKeychain() {

    addCerToKeychain_Title_Log="*** function [addCerToKeychain] -"

    addCerToKeychain_Param_KeychainName="${2}"
    addCerToKeychain_Param_CerFilePath="${3}"
    addCerToKeychain_Param_p12Pwd="${4}"

    echo
    echo "${addCerToKeychain_Title_Log} Begin ***"
    echo "${addCerToKeychain_Title_Log} Input param : Begin ***"
    echo "${addCerToKeychain_Title_Log} TitleLog: ${1}"
    echo "${addCerToKeychain_Title_Log} keychainName: ${addCerToKeychain_Param_KeychainName}"
    echo "${addCerToKeychain_Title_Log} cerFilePath: ${addCerToKeychain_Param_CerFilePath}"
    echo "${addCerToKeychain_Title_Log} p12Pwd: ${addCerToKeychain_Param_p12Pwd}"
    echo "${addCerToKeychain_Title_Log} Input param : End ***"

    if [[ ${addCerToKeychain_Param_p12Pwd} == "" ]]; then
        # 無密碼.
        echo
        echo "${addCerToKeychain_Title_Log} ${1} security import cer : ${addCerToKeychain_Param_CerFilePath} to keychain : ${addCerToKeychain_Param_KeychainName}"
        security import "${addCerToKeychain_Param_CerFilePath}" -k "${addCerToKeychain_Param_KeychainName}" -T /usr/bin/codesign -T /usr/bin/productsign
    else
        echo
        echo "${addCerToKeychain_Title_Log} ${1} security import cer : ${addCerToKeychain_Param_CerFilePath} with pw: ${addCerToKeychain_Param_p12Pwd} to keychain : ${addCerToKeychain_Param_KeychainName}"
        security import "${addCerToKeychain_Param_CerFilePath}" -k "${addCerToKeychain_Param_KeychainName}" -P ${addCerToKeychain_Param_p12Pwd} -T /usr/bin/codesign -T /usr/bin/productsign
    fi

    echo "${addCerToKeychain_Title_Log} End ***"
    echo
}

# ============= This is separation line =============
# @brief function : 執行 從 ExtraCerInfoUnit 的內容，加入 cer 到 keychain。
#   如 : cer_info_app_share，...
#   ``` yaml
#   cer_info_app_share:
#     file_password_separator: +
#     file_password_list:
#       - app.share/doc/abc.p12+abc
#       - app.share/doc/def.p12+def
#   ```
# @detail : 簡易函式，不再處理細節的判斷，為保持正確性，參數請自行帶上 "".
#   - 拆解成獨立函式，但是內容跟此 shell 有高度相依，只是獨立函式容易閱讀。
#   - 只檢查是否為合法設定。
#   - 之前已經驗證過
#
# @param $1 : cer_info_key_name
# @sa check_ExtraCerInfoUnit_Legal
#    之前的流程已經呼叫 [check_ExtraCerInfoUnit_Legal] 驗證過，在此直接使用，不再次驗證。
function execute_Add_Cer_To_Keychain_From_ExtraCerInfoUnit() {

    local func_Title_Log="${thisShell_Title_Log} *** function [${FUNCNAME[0]}] -"

    echo
    echo "${func_Title_Log} ||==========> Begin <==========||"

    local func_Param_CerInfoKeyName=${1}

    # file_password_separator 允許為空，有值才處理，這裡只單純 dump log，不驗證。
    local func_Check_Legal_CerInfoKeyName_FilePassword_Separator=thisShell_Config_${func_Param_CerInfoKeyName}_file_password_separator
    local func_Check_Legal_CerInfoKeyName_FilePassword_List=thisShell_Config_${func_Param_CerInfoKeyName}_file_password_list

    echo "${func_Title_Log} ${func_Check_Legal_CerInfoKeyName_FilePassword_Separator} : $(eval echo \${$func_Check_Legal_CerInfoKeyName_FilePassword_Separator})"

    echo "${func_Title_Log} ${func_Check_Legal_CerInfoKeyName_FilePassword_List} : $(eval echo \${$func_Check_Legal_CerInfoKeyName_FilePassword_List[@]})"
    echo "${func_Title_Log} ${func_Check_Legal_CerInfoKeyName_FilePassword_List} count : $(eval echo \${\#$func_Check_Legal_CerInfoKeyName_FilePassword_List[@]})"

    local func_FilePassword_Separator="$(eval echo \${$func_Check_Legal_CerInfoKeyName_FilePassword_Separator})"
    local func_FilePassword_List=($(eval echo \${$func_Check_Legal_CerInfoKeyName_FilePassword_List[@]}))

    echo "${func_Title_Log} func_FilePassword_Separator : ${func_FilePassword_Separator}"

    echo "${func_Title_Log} func_FilePassword_List : ${func_FilePassword_List[@]}"
    echo "${func_Title_Log} func_FilePassword_List count : ${#func_FilePassword_List[@]}"

    # 頗析 file passweord list
    local i
    for ((i = 0; i < ${#func_FilePassword_List[@]}; i++)); do #請注意 ((   )) 雙層括號

        local aFilePassword=${func_FilePassword_List[$i]}

        # 要設定的 split 參數，先初始化。
        local aFile=""
        local aPassword=""

        # splitStringToPair 會自行判斷是否要進行 split，所以可以直接呼叫之。
        splitStringToPair "${thisShell_Title_Log}" "${aFilePassword}" "${func_FilePassword_Separator}" aFile aPassword

        addCerToKeychain "${func_Title_Log}" "${thisShell_Config_required_keychain_name}" "${aFile}" "${aPassword}"

    done

    echo "${func_Title_Log} ||==========> End <==========||"
    echo
}
## ================================== extra function section : End ==================================

## ================================== prcess function section : Begin ==================================
# ============= This is separation line =============
# @brief function : [程序] 此 shell 的初始化。
function process_Init() {

    # 計時，實測結果不同 shell 不會影響，各自有各自的 SECONDS。
    SECONDS=0

    # 此 shell 的 dump log title.
    thisShell_Title_Name="keychainTool_ImportCerToKeychain"
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

    # 不確定是否使用者都有使用 configTools.sh 產生 build config file， 再來呼叫 keychainTool_ImportCerToKeychain.sh
    # 保險起見， include configConst.sh
    # include configConst.sh for configTools.sh using export Environment Variable。
    echo
    echo "${thisShell_Title_Log} include configConst.sh"
    . "${func_Shell_WorkPath}"/configConst.sh

    # include general function
    echo
    echo "${thisShell_Title_Log} include general function"
    . "${func_Shell_WorkPath}"/../../generalConst.sh
    . "${func_Shell_WorkPath}"/../../generalTools.sh

    # include parse_yaml function
    echo
    echo "${thisShell_Title_Log} include parse_yaml function"

    # 同樣在 scm.tools 專案下的相對路徑。
    . "${func_Shell_WorkPath}"/../../../../submodules/bash-yaml/script/yaml.sh

    # 設定原先的呼叫路徑。
    thisShell_OldPath=$(pwd)

    # 切換執行目錄.
    changeToDirectory "${thisShell_Title_Log}" "${func_Shell_WorkPath}"

    # 設定成完整路徑。
    thisShell_Shell_WorkPath=$(pwd)

    echo "${thisShell_Title_Log} thisShell_OldPath : ${thisShell_OldPath}"
    echo "${thisShell_Title_Log} thisShell_Shell_WorkPath : ${thisShell_Shell_WorkPath}"
    echo
}

# ============= This is separation line =============
# @brief function : [程序] 處理 input param。
function process_Deal_InputParam() {

    local func_Title_Log="${thisShell_Title_Log} *** function [${FUNCNAME[0]}] -"

    echo
    echo "${func_Title_Log} ||==========> Begin <==========||"

    # set input param variable
    thisShell_Param_ConfigFile="${1}"

    # check input parameters
    checkInputParam "${func_Title_Log}" thisShell_Param_ConfigFile "${thisShell_Param_ConfigFile}"

    echo
    echo "${func_Title_Log} ============= Param : Begin ============="
    echo "${func_Title_Log} thisShell_Param_ConfigFile : ${thisShell_Param_ConfigFile}"
    echo "${func_Title_Log} ============= Param : End ============="
    echo

    echo "${func_Title_Log} ||==========> End <==========||"
    echo
}

# ============= This is separation line =============
# @brief function : [程序] Toggle Feature 設定。
function process_Deal_ToggleFeature() {

    local func_Title_Log="${thisShell_Title_Log} *** function [${FUNCNAME[0]}] -"

    echo
    echo "${func_Title_Log} ||==========> Begin <==========||"

    # 是否開啟 dump set 內容，當 parse build config file 時，會去判斷。
    thisShell_ToogleFeature_IsDumpSet_When_Parse_ConfigFile="${GENERAL_CONST_DISABLE_FLAG}"

    echo
    echo "${func_Title_Log} ============= Toogle Feature : Begin ============="
    echo "${func_Title_Log} thisShell_ToogleFeature_IsDumpSet_When_Parse_ConfigFile : ${thisShell_ToogleFeature_IsDumpSet_When_Parse_ConfigFile}"
    echo "${func_Title_Log} ============= Toogle Feature : End ============="
    echo

    echo "${func_Title_Log} ||==========> End <==========||"
    echo

}

# ============= This is separation line =============
# @brief function : [程序] 剖析 config file。
function process_Parse_ConfigFile() {

    local func_Title_Log="${thisShell_Title_Log} *** function [${FUNCNAME[0]}] -"

    echo
    echo "${func_Title_Log} ||==========> Begin <==========||"

    # parse build config file
    echo "${func_Title_Log} 將剖析 Build Config File 來做細微的設定。"

    create_variables "${thisShell_Param_ConfigFile}" "thisShell_Config_"

    # 開啟可以抓到此 shell 目前有哪些設定值。
    if [ ${thisShell_ToogleFeature_IsDumpSet_When_Parse_ConfigFile} = "${GENERAL_CONST_ENABLE_FLAG}" ]; then
        set >${thisShell_Param_ConfigFile}_BeforeParseConfig.temp.log
    fi

    # 剖析 required 部分。
    parseReruiredSection

    # 剖析 extra cerInfo 部分。
    parseExtraCerInfoSection

    # 開啟可以抓到此 shell 目前有哪些設定值。
    if [ ${thisShell_ToogleFeature_IsDumpSet_When_Parse_ConfigFile} = "${GENERAL_CONST_ENABLE_FLAG}" ]; then
        set >${thisShell_Param_ConfigFile}_AfterParseConfig.temp.log
    fi

    # FIXME
    # exit 1

    echo "${func_Title_Log} ||==========> End <==========||"
    echo
}

# ============= This is separation line =============
# @brief function : [程序] 處理路徑相關 (包含 flutter work path)。
function process_Deal_Paths() {

    local func_Title_Log="${thisShell_Title_Log} *** function [${FUNCNAME[0]}] -"

    echo
    echo "${func_Title_Log} ||==========> Begin <==========||"

    # 判斷是否要切換到 config file 設定的 work path。
    # 有的話，會切換到該目錄，再執行 keycahin 相關命令 (之後會切回到原有呼叫的目錄)。
    if [ -n "${thisShell_Config_optional_work_path}" ]; then
        changeToDirectory "${thisShell_Title_Log}" "${thisShell_Config_optional_work_path}"
    fi

    thisShell_Execute_Keychain_WorkPath=$(pwd)

    echo
    echo "${func_Title_Log} //========== dump paths : Begin ==========//"
    echo "${func_Title_Log} thisShell_OldPath                     : ${thisShell_OldPath}"
    echo "${func_Title_Log} thisShell_Shell_WorkPath              : ${thisShell_Shell_WorkPath}"
    echo "${func_Title_Log} thisShell_Config_optional_work_path   : ${thisShell_Config_optional_work_path}"
    echo "${func_Title_Log} thisShell_Execute_Keychain_WorkPath   : ${thisShell_Execute_Keychain_WorkPath}"
    echo "${func_Title_Log} current path                          : $(pwd)"
    echo "${func_Title_Log} //========== dump paths : End ==========//"
    echo

    echo "${func_Title_Log} ||==========> End <==========||"
    echo
}

# ============= This is separation line =============
# @brief function : [程序] 處理 keychain 基礎資訊。
function process_Deal_KeyChain_BaseInfo() {

    local func_Title_Log="${thisShell_Title_Log} *** function [${FUNCNAME[0]}] -"

    echo
    echo "${func_Title_Log} ||==========> Begin <==========||"

    # 刪除同名鑰匙圈
    security delete-keychain "${thisShell_Config_required_keychain_name}"

    echo "${func_Title_Log} || security delete-keychain ${thisShell_Config_required_keychain_name} => result : ${?} ||"

    # 重設keychain list
    security list-keychain -s

    echo "${func_Title_Log} || security list-keychain -s => result : ${?}||"

    # 產生新的keychain。
    security create-keychain -p "${thisShell_Config_required_keychain_password}" "${thisShell_Config_required_keychain_name}"

    echo "${func_Title_Log} || security create-keychain -p ${thisShell_Config_required_keychain_password} ${thisShell_Config_required_keychain_name} => result : ${?}||"

    # 加入鑰匙圈
    # 有 login.keychain，則將 login.keychain 也加入 keychain 的收尋清單 (search list)。
    if [[ -f ~/Library/Keychains/login.keychain ]]; then
        security list-keychain -s "${thisShell_Config_required_keychain_name}" login.keychain
    else
        security list-keychain -s "${thisShell_Config_required_keychain_name}"
    fi

    echo "${func_Title_Log} || security list-keychain -s ${thisShell_Config_required_keychain_name} ... => result : ${?}||"

    # 設為預設鑰匙圈。
    security default-keychain -s "${thisShell_Config_required_keychain_name}"

    echo "${func_Title_Log} || security default-keychain -s ${thisShell_Config_required_keychain_name} => result : ${?}||"

    # 解鎖。
    security unlock-keychain -p "${thisShell_Config_required_keychain_password}" "${thisShell_Config_required_keychain_name}"

    echo "${func_Title_Log} || security unlock-keychain -p ${thisShell_Config_required_keychain_password} ${thisShell_Config_required_keychain_name} => result : ${?}||"

    #帶參數-l 表示要在休眠後自動上鎖。
    #帶參數-u 表示要在閑置後自動上鎖。
    #不帶任何參數，表示無論是閒置後或休眠後都不要自動上鎖。
    security set-keychain-settings "${thisShell_Config_required_keychain_name}"

    echo "${func_Title_Log} || security set-keychain-settings ${thisShell_Config_required_keychain_name} => result : ${?}||"

    echo "${func_Title_Log} ||==========> End <==========||"
    echo
}

# ============= This is separation line =============
# @brief function : [程序] 處理 cer 加入到 鑰匙圈。
function process_Deal_KeyChain_AddCerToKeychain() {

    local func_Title_Log="${thisShell_Title_Log} *** function [${FUNCNAME[0]}] -"

    echo
    echo "${func_Title_Log} ||==========> Begin <==========||"

    local func_i
    for ((func_i = 0; func_i < ${#thisShell_Config_required_cer_info_key_names[@]}; func_i++)); do #請注意 ((   )) 雙層括號

        local aCerInfoKeyName=${thisShell_Config_required_cer_info_key_names[${func_i}]}
        echo "${thisShell_Title_Log} aCerInfoKeyName : ${aCerInfoKeyName}"

        execute_Add_Cer_To_Keychain_From_ExtraCerInfoUnit "${aCerInfoKeyName}"

    done

    echo "${func_Title_Log} ||==========> End <==========||"
    echo
}

# ============= This is separation line =============
# @brief function : [程序] shell 全部完成需處理的部份.
function process_Finish() {

    # 全部完成
    # 切回原有執行目錄.
    changeToDirectory "${thisShell_Title_Log}" "${thisShell_OldPath}"

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
# call - [程序] Toggle Feature 設定。
process_Deal_ToggleFeature

# ============= This is separation line =============
# call - [程序] 剖析 config file。
process_Parse_ConfigFile

# ============= This is separation line =============
# call - [程序] 處理路徑相關 (包含 flutter work path)。
process_Deal_Paths

# ============= This is separation line =============
# call - [程序] 處理 keychain 基礎資訊。
process_Deal_KeyChain_BaseInfo

# ============= This is separation line =============
# call - [程序] 處理 cer 加入到 鑰匙圈。
process_Deal_KeyChain_AddCerToKeychain

# ============= This is separation line =============
# call - [程序] shell 全部完成需處理的部份.
process_Finish
## ================================== deal prcess step section : End ==================================

exit 0
