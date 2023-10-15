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
# - $1 : this_shell_param_config_file="[專案路徑]/[scm]/output/config.yaml" : 設定 import cer to keychain 的 config 功能檔案 [需帶完整路徑].
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
# - const define : "Y" 或 "N" 改使用 "${GENERAL_CONST_ENABLE_FLAG}" 或 "${GENERAL_CONST_DISABLE_FLAG}" 來判斷 ， 定義在 general_const.sh
#
# ---
#
# Toggle Feature (切換功能) 說明:
#
# - this_shell_toogle_feature_is_dump_set_when_parse_config_file="${GENERAL_CONST_ENABLE_FLAG}" => e.g. "${GENERAL_CONST_ENABLE_FLAG}" 或 "${GENERAL_CONST_DISABLE_FLAG}"
#   - 是否開啟 dump set 內容，當 parse build config file 時，會去判斷。
#   - 上傳版本會是關閉狀態，若需要測試時，自行打開。
#
# ---
#
# this_shell_config_xxx 說明 :
#
# - 來源 : 來自於 build config 轉換成的 shell 內部參數。
#   經由讀取 build config file (對應於 this_shell_param_config_file 內容) 來處理，
#   細部說明可參考 configTools.sh
#
# - required :
#
#   - this_shell_config_required_keychain_name
#     要設定的鑰匙圈名稱，在  會顯示的名稱 => e.g. xxx.App.Keychain。
#
#   - this_shell_config_required_keychain_password
#     要設定的鑰匙圈密碼，需要存取該鑰匙圈需要輸入的密碼 => e.g. abc123
#
#   - this_shell_config_required_cer_info_key_names=([0]="cer_info_app_A" [1]="cer_info_app_B")
#     需要額外處理的 cer infos，針對每一個 key name，會動態去取得 cer info unit 資訊。
#
# ---
#
# - extra [cer info unit]:
#
#   由 this_shell_config_required_cer_info_key_names 的內容，動態取得對應的 yaml key 的內容。 cer_info_app_A
#   > 如 this_shell_config_required_cer_info_key_names=([0]="cer_info_app_A" [1]="cer_info_app_B") ，
#   > 則需要取得 cer_info_app_A ， cer_info_app_B 的內容。
#
#   - this_shell_config_[cer_info_name] :
#     主要的 key name ， [cer_info_name] 是動態取得。
#     > e.g. cer_info_app_A
#
#     - this_shell_config_[cer_info_name]_file_password_separator :
#       分隔符號。
#
#     - this_shell_config_[cer_info_name]_file_password_list :
#       file 與 password 為乙組的資訊。
#       以 `file_password_separator` 做拆分，沒有後面部分，視同無密碼。。
#
# ---
#
# - optional :
#
#   - work_path :
#     - this_shell_config_optional_work_path :
#       [work_path] : 指定 shell 執行的工作目錄。
#
# ---
#
# 程式碼區塊 說明:
#
# - [通用規則] :
#   函式與此 shell 有高度相依，若要抽離到獨立 shell，需調整之。
#   其中 [this_shell_xxx] 是跨函式讀取。
#
# - 此 shell 主要分四個主要區塊 :
#
#   - config function section :
#     有關 build config 處理的相關函式。
#
#   - extra [add_cer_to_keychain] function section :
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
function parse_reruired_section() {

    local func_title_log="${this_shell_title_log} *** function [${FUNCNAME[0]}] -"

    echo
    echo "${func_title_log} ||==========> Begin <==========||"

    # check input parameters
    check_input_param "${func_title_log}" this_shell_config_required_keychain_name "${this_shell_config_required_keychain_name}"
    check_input_param "${func_title_log}" this_shell_config_required_keychain_password "${this_shell_config_required_keychain_password}"
    check_input_param "${func_title_log}" this_shell_config_required_cer_info_key_names "${this_shell_config_required_cer_info_key_names[@]}"

    echo
    echo "${func_title_log} ============= Param : Begin ============="
    echo "${func_title_log} this_shell_config_required_keychain_name : ${this_shell_config_required_keychain_name}"
    echo "${func_title_log} this_shell_config_required_keychain_password : ${this_shell_config_required_keychain_password}"
    echo "${func_title_log} this_shell_config_required_cer_info_key_names : ${this_shell_config_required_cer_info_key_names[@]}"
    echo "${func_title_log} ============= Param : End ============="
    echo

    echo "${func_title_log} ||==========> End <==========||"
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
function check_extra_cer_info_unit_legal() {

    local func_title_log="${this_shell_title_log} *** function [${FUNCNAME[0]}] -"

    echo
    echo "${func_title_log} ||==========> Begin <==========||"

    local func_param_cer_info_key_name=${1}

    # file_password_separator 允許為空，有值才處理，這裡只單純 dump log，不驗證。
    local func_check_legal_cer_info_key_name_file_password_separator=this_shell_config_${func_param_cer_info_key_name}_file_password_separator
    local func_check_legal_cer_info_key_name_file_password_list=this_shell_config_${func_param_cer_info_key_name}_file_password_list

    # check_input_param "${func_title_log}" ${func_check_legal_cer_info_key_name_file_password_separator} "$(eval echo \${$func_check_legal_cer_info_key_name_file_password_separator})"
    check_input_param "${func_title_log}" ${func_check_legal_cer_info_key_name_file_password_list} "$(eval echo \${$func_check_legal_cer_info_key_name_file_password_list[@]})"

    echo "${func_title_log} ${func_check_legal_cer_info_key_name_file_password_separator} : $(eval echo \${$func_check_legal_cer_info_key_name_file_password_separator})"

    echo "${func_title_log} ${func_check_legal_cer_info_key_name_file_password_list} : $(eval echo \${$func_check_legal_cer_info_key_name_file_password_list[@]})"
    echo "${func_title_log} ${func_check_legal_cer_info_key_name_file_password_list} count : $(eval echo \${\#$func_check_legal_cer_info_key_name_file_password_list[@]})"

    local func_file_password_separator="$(eval echo \${$func_check_legal_cer_info_key_name_file_password_separator})"
    local func_file_password_list=($(eval echo \${$func_check_legal_cer_info_key_name_file_password_list[@]}))

    echo "${func_title_log} func_file_password_separator : ${func_file_password_separator}"

    echo "${func_title_log} func_file_password_list : ${func_file_password_list[@]}"
    echo "${func_title_log} func_file_password_list count : ${#func_file_password_list[@]}"

    echo "${func_title_log} ||==========> End <==========||"
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
function parse_extra_cer_info_section() {

    local func_title_log="${this_shell_title_log} *** function [${FUNCNAME[0]}] -"

    echo
    echo "${func_title_log} ||==========> Begin <==========||"

    local func_i
    for ((func_i = 0; func_i < ${#this_shell_config_required_cer_info_key_names[@]}; func_i++)); do #請注意 ((   )) 雙層括號

        local aCerInfoKeyName=${this_shell_config_required_cer_info_key_names[${func_i}]}
        echo "${this_shell_title_log} aCerInfoKeyName : ${aCerInfoKeyName}"

        check_extra_cer_info_unit_legal "${aCerInfoKeyName}"

    done

    echo "${func_title_log} ||==========> End <==========||"
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
function add_cer_to_keychain() {

    local func_title_log="${this_shell_title_log} *** function [${FUNCNAME[0]}] -"

    local func_param_keychain_name="${2}"
    local func_param_cer_file_path="${3}"
    local func_param_p12_pwd="${4}"

    echo
    echo "${func_title_log} Begin ***"
    echo "${func_title_log} Input param : Begin ***"
    echo "${func_title_log} TitleLog: ${1}"
    echo "${func_title_log} keychainName: ${func_param_keychain_name}"
    echo "${func_title_log} cerFilePath: ${func_param_cer_file_path}"
    echo "${func_title_log} p12Pwd: ${func_param_p12_pwd}"
    echo "${func_title_log} Input param : End ***"

    if [[ ${func_param_p12_pwd} == "" ]]; then
        # 無密碼.
        echo
        echo "${func_title_log} ${1} security import cer : ${func_param_cer_file_path} to keychain : ${func_param_keychain_name}"
        security import "${func_param_cer_file_path}" -k "${func_param_keychain_name}" -T /usr/bin/codesign -T /usr/bin/productsign
    else
        echo
        echo "${func_title_log} ${1} security import cer : ${func_param_cer_file_path} with pw: ${func_param_p12_pwd} to keychain : ${func_param_keychain_name}"
        security import "${func_param_cer_file_path}" -k "${func_param_keychain_name}" -P ${func_param_p12_pwd} -T /usr/bin/codesign -T /usr/bin/productsign
    fi

    echo "${func_title_log} End ***"
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
# @sa check_extra_cer_info_unit_legal
#    之前的流程已經呼叫 [check_extra_cer_info_unit_legal] 驗證過，在此直接使用，不再次驗證。
function execute_add_cer_to_keychain_from_extra_cer_info_unit() {

    local func_title_log="${this_shell_title_log} *** function [${FUNCNAME[0]}] -"

    echo
    echo "${func_title_log} ||==========> Begin <==========||"

    local func_param_cer_info_key_name=${1}

    # file_password_separator 允許為空，有值才處理，這裡只單純 dump log，不驗證。
    local func_check_legal_cer_info_key_name_file_password_separator=this_shell_config_${func_param_cer_info_key_name}_file_password_separator
    local func_check_legal_cer_info_key_name_file_password_list=this_shell_config_${func_param_cer_info_key_name}_file_password_list

    echo "${func_title_log} ${func_check_legal_cer_info_key_name_file_password_separator} : $(eval echo \${$func_check_legal_cer_info_key_name_file_password_separator})"

    echo "${func_title_log} ${func_check_legal_cer_info_key_name_file_password_list} : $(eval echo \${$func_check_legal_cer_info_key_name_file_password_list[@]})"
    echo "${func_title_log} ${func_check_legal_cer_info_key_name_file_password_list} count : $(eval echo \${\#$func_check_legal_cer_info_key_name_file_password_list[@]})"

    local func_file_password_separator="$(eval echo \${$func_check_legal_cer_info_key_name_file_password_separator})"
    local func_file_password_list=($(eval echo \${$func_check_legal_cer_info_key_name_file_password_list[@]}))

    echo "${func_title_log} func_file_password_separator : ${func_file_password_separator}"

    echo "${func_title_log} func_file_password_list : ${func_file_password_list[@]}"
    echo "${func_title_log} func_file_password_list count : ${#func_file_password_list[@]}"

    # 頗析 file passweord list
    local i
    for ((i = 0; i < ${#func_file_password_list[@]}; i++)); do #請注意 ((   )) 雙層括號

        local func_file_password=${func_file_password_list[$i]}

        # 要設定的 split 參數，先初始化。
        local func_file=""
        local func_password=""

        # split_string_to_pair 會自行判斷是否要進行 split，所以可以直接呼叫之。
        split_string_to_pair "${this_shell_title_log}" "${func_file_password}" "${func_file_password_separator}" func_file func_password

        add_cer_to_keychain "${func_title_log}" "${this_shell_config_required_keychain_name}" "${func_file}" "${func_password}"

    done

    echo "${func_title_log} ||==========> End <==========||"
    echo
}
## ================================== extra function section : End ==================================

## ================================== prcess function section : Begin ==================================
# ============= This is separation line =============
# @brief function : [程序] 此 shell 的初始化。
function process_init() {

    # 計時，實測結果不同 shell 不會影響，各自有各自的 SECONDS。
    SECONDS=0

    # 此 shell 的 dump log title.
    this_shell_title_name="keychainTool_ImportCerToKeychain"
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

    # 不確定是否使用者都有使用 configTools.sh 產生 build config file， 再來呼叫 keychainTool_ImportCerToKeychain.sh
    # 保險起見， include configConst.sh
    # include configConst.sh for configTools.sh using export Environment Variable。
    echo
    echo "${this_shell_title_log} include configConst.sh"
    . "${func_shell_work_path}"/configConst.sh

    # include general function
    echo
    echo "${this_shell_title_log} include general function"
    . "${func_shell_work_path}"/../../general_const.sh
    . "${func_shell_work_path}"/../../generalTools.sh

    # include parse_yaml function
    echo
    echo "${this_shell_title_log} include parse_yaml function"

    # 同樣在 scm.tools 專案下的相對路徑。
    . "${func_shell_work_path}"/../../../../submodules/bash-yaml/script/yaml.sh

    # 設定原先的呼叫路徑。
    this_shell_old_path=$(pwd)

    # 切換執行目錄.
    change_to_directory "${this_shell_title_log}" "${func_shell_work_path}"

    # 設定成完整路徑。
    this_shell_work_path=$(pwd)

    echo "${this_shell_title_log} this_shell_old_path : ${this_shell_old_path}"
    echo "${this_shell_title_log} this_shell_work_path : ${this_shell_work_path}"
    echo
}

# ============= This is separation line =============
# @brief function : [程序] 處理 input param。
function process_deal_input_param() {

    local func_title_log="${this_shell_title_log} *** function [${FUNCNAME[0]}] -"

    echo
    echo "${func_title_log} ||==========> Begin <==========||"

    # set input param variable
    this_shell_param_config_file="${1}"

    # check input parameters
    check_input_param "${func_title_log}" this_shell_param_config_file "${this_shell_param_config_file}"

    echo
    echo "${func_title_log} ============= Param : Begin ============="
    echo "${func_title_log} this_shell_param_config_file : ${this_shell_param_config_file}"
    echo "${func_title_log} ============= Param : End ============="
    echo

    echo "${func_title_log} ||==========> End <==========||"
    echo
}

# ============= This is separation line =============
# @brief function : [程序] Toggle Feature 設定。
function process_deal_toggle_feature() {

    local func_title_log="${this_shell_title_log} *** function [${FUNCNAME[0]}] -"

    echo
    echo "${func_title_log} ||==========> Begin <==========||"

    # 是否開啟 dump set 內容，當 parse build config file 時，會去判斷。
    this_shell_toogle_feature_is_dump_set_when_parse_config_file="${GENERAL_CONST_DISABLE_FLAG}"

    echo
    echo "${func_title_log} ============= Toogle Feature : Begin ============="
    echo "${func_title_log} this_shell_toogle_feature_is_dump_set_when_parse_config_file : ${this_shell_toogle_feature_is_dump_set_when_parse_config_file}"
    echo "${func_title_log} ============= Toogle Feature : End ============="
    echo

    echo "${func_title_log} ||==========> End <==========||"
    echo

}

# ============= This is separation line =============
# @brief function : [程序] 剖析 config file。
function process_parse_config_file() {

    local func_title_log="${this_shell_title_log} *** function [${FUNCNAME[0]}] -"

    echo
    echo "${func_title_log} ||==========> Begin <==========||"

    # parse build config file
    echo "${func_title_log} 將剖析 Build Config File 來做細微的設定。"

    create_variables "${this_shell_param_config_file}" "this_shell_config_"

    # 開啟可以抓到此 shell 目前有哪些設定值。
    if [ ${this_shell_toogle_feature_is_dump_set_when_parse_config_file} = "${GENERAL_CONST_ENABLE_FLAG}" ]; then
        set >${this_shell_param_config_file}_BeforeParseConfig.temp.log
    fi

    # 剖析 required 部分。
    parse_reruired_section

    # 剖析 extra cerInfo 部分。
    parse_extra_cer_info_section

    # 開啟可以抓到此 shell 目前有哪些設定值。
    if [ ${this_shell_toogle_feature_is_dump_set_when_parse_config_file} = "${GENERAL_CONST_ENABLE_FLAG}" ]; then
        set >${this_shell_param_config_file}_AfterParseConfig.temp.log
    fi

    # FIXME
    # exit 1

    echo "${func_title_log} ||==========> End <==========||"
    echo
}

# ============= This is separation line =============
# @brief function : [程序] 處理路徑相關 (包含 flutter work path)。
function process_deal_paths() {

    local func_title_log="${this_shell_title_log} *** function [${FUNCNAME[0]}] -"

    echo
    echo "${func_title_log} ||==========> Begin <==========||"

    # 判斷是否要切換到 config file 設定的 work path。
    # 有的話，會切換到該目錄，再執行 keycahin 相關命令 (之後會切回到原有呼叫的目錄)。
    if [ -n "${this_shell_config_optional_work_path}" ]; then
        change_to_directory "${this_shell_title_log}" "${this_shell_config_optional_work_path}"
    fi

    this_shell_execute_keychain_work_path=$(pwd)

    echo
    echo "${func_title_log} //========== dump paths : Begin ==========//"
    echo "${func_title_log} this_shell_old_path                    : ${this_shell_old_path}"
    echo "${func_title_log} this_shell_work_path                   : ${this_shell_work_path}"
    echo "${func_title_log} this_shell_config_optional_work_path   : ${this_shell_config_optional_work_path}"
    echo "${func_title_log} this_shell_execute_keychain_work_path  : ${this_shell_execute_keychain_work_path}"
    echo "${func_title_log} current path                           : $(pwd)"
    echo "${func_title_log} //========== dump paths : End ==========//"
    echo

    echo "${func_title_log} ||==========> End <==========||"
    echo
}

# ============= This is separation line =============
# @brief function : [程序] 處理 keychain 基礎資訊。
function process_deal_keychain_base_info() {

    local func_title_log="${this_shell_title_log} *** function [${FUNCNAME[0]}] -"

    echo
    echo "${func_title_log} ||==========> Begin <==========||"

    # 刪除同名鑰匙圈
    security delete-keychain "${this_shell_config_required_keychain_name}"

    echo "${func_title_log} || security delete-keychain ${this_shell_config_required_keychain_name} => result : ${?} ||"

    # 重設keychain list
    security list-keychain -s

    echo "${func_title_log} || security list-keychain -s => result : ${?}||"

    # 產生新的keychain。
    security create-keychain -p "${this_shell_config_required_keychain_password}" "${this_shell_config_required_keychain_name}"

    echo "${func_title_log} || security create-keychain -p ${this_shell_config_required_keychain_password} ${this_shell_config_required_keychain_name} => result : ${?}||"

    # 加入鑰匙圈
    # 有 login.keychain，則將 login.keychain 也加入 keychain 的收尋清單 (search list)。
    if [[ -f ~/Library/Keychains/login.keychain ]]; then
        security list-keychain -s "${this_shell_config_required_keychain_name}" login.keychain
    else
        security list-keychain -s "${this_shell_config_required_keychain_name}"
    fi

    echo "${func_title_log} || security list-keychain -s ${this_shell_config_required_keychain_name} ... => result : ${?}||"

    # 設為預設鑰匙圈。
    security default-keychain -s "${this_shell_config_required_keychain_name}"

    echo "${func_title_log} || security default-keychain -s ${this_shell_config_required_keychain_name} => result : ${?}||"

    # 解鎖。
    security unlock-keychain -p "${this_shell_config_required_keychain_password}" "${this_shell_config_required_keychain_name}"

    echo "${func_title_log} || security unlock-keychain -p ${this_shell_config_required_keychain_password} ${this_shell_config_required_keychain_name} => result : ${?}||"

    #帶參數-l 表示要在休眠後自動上鎖。
    #帶參數-u 表示要在閑置後自動上鎖。
    #不帶任何參數，表示無論是閒置後或休眠後都不要自動上鎖。
    security set-keychain-settings "${this_shell_config_required_keychain_name}"

    echo "${func_title_log} || security set-keychain-settings ${this_shell_config_required_keychain_name} => result : ${?}||"

    echo "${func_title_log} ||==========> End <==========||"
    echo
}

# ============= This is separation line =============
# @brief function : [程序] 處理 cer 加入到 鑰匙圈。
function process_deal_keychain_add_cer_to_keychain() {

    local func_title_log="${this_shell_title_log} *** function [${FUNCNAME[0]}] -"

    echo
    echo "${func_title_log} ||==========> Begin <==========||"

    local func_i
    for ((func_i = 0; func_i < ${#this_shell_config_required_cer_info_key_names[@]}; func_i++)); do #請注意 ((   )) 雙層括號

        local aCerInfoKeyName=${this_shell_config_required_cer_info_key_names[${func_i}]}
        echo "${this_shell_title_log} aCerInfoKeyName : ${aCerInfoKeyName}"

        execute_add_cer_to_keychain_from_extra_cer_info_unit "${aCerInfoKeyName}"

    done

    echo "${func_title_log} ||==========> End <==========||"
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
# call - [程序] Toggle Feature 設定。
process_deal_toggle_feature

# ============= This is separation line =============
# call - [程序] 剖析 config file。
process_parse_config_file

# ============= This is separation line =============
# call - [程序] 處理路徑相關 (包含 flutter work path)。
process_deal_paths

# ============= This is separation line =============
# call - [程序] 處理 keychain 基礎資訊。
process_deal_keychain_base_info

# ============= This is separation line =============
# call - [程序] 處理 cer 加入到 鑰匙圈。
process_deal_keychain_add_cer_to_keychain

# ============= This is separation line =============
# call - [程序] shell 全部完成需處理的部份.
process_finish
## ================================== deal prcess step section : End ==================================

exit 0
