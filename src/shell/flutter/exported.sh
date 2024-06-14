#!/bin/bash

# @brief : 簡單處理目前的出版 => release for apk and ipa。
#          為正式的出版流程，需要再分析更好的流程，陸續整理中。
#
# ---
#
# Reference :
# - title: [shell]shell運算(數字[加減乘除，比較大小]，字串，檔案) - IT閱讀
#   - website : https://www.itread01.com/content/1548088410.html
#
# ---
#
# input 參數說明 :
#
# - $1 : this_shell_param_build_config_file="[專案路徑]/[scm]/output/build_config.yaml" : 設定編譯的 config 功能檔案 [需帶完整路徑].
#
#   - 內容為協議好的格式，只是做成可彈性設定的方式，可選項目，沒有則以基本編譯。
#
#   - 目前 exported.sh 支援的功能，在 config_tools.sh 會有對應函式可以設定到 build_config.yaml 中。
#
#   - sample file : build_config.yaml
#
#     ``` yaml
#     optional:
#       dart_define :
#         separator : +
#         defines :
#           - gitHash+cd8a0dc
#           - envName+rc
#     ```
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
# - this_shell_toogle_feature_is_dump_set_when_parse_build_config_file="${GENERAL_CONST_ENABLE_FLAG}" => e.g. "${GENERAL_CONST_ENABLE_FLAG}" 或 "${GENERAL_CONST_DISABLE_FLAG}"
#   - 是否開啟 dump set 內容，當 parse build config file 時，會去判斷。
#   - 上傳版本會是關閉狀態，若需要測試時，自行打開。
#
# - this_shell_toogle_feature_default_build_config_type=release
#   - build configutation type : 編譯組態設定，之後視情況是否要開放
#   - 依據 flutter build version : 有 debug ， profile ， release 三種方式
#   - 可參考 config_tools.sh 中的 CONFIG_CONST_BUILD_CONFIG_TYPE_[XXX]。
#   - [註] : 若 build config 有設定 [build_config_types] 則會以該設定為主。
#
# ---
#
# SubcommandInfo :
# - 規則 :
#   - [0]: build subcommand name。
#   - [1]: 是否要執行 (isExcute)。 default : "${GENERAL_CONST_DISABLE_FLAG}"。
#
# ---
#
# this_shell_config_xxx 說明 :
#
# - 來源 : 來自於 build config 轉換成的 shell 內部參數。
#   經由讀取 build config file (對應於 this_shell_param_build_config_file 內容) 來處理，
#   細部說明可參考 config_tools.sh
#
# - required :
#
#   - this_shell_config_required_paths_work
#     flutter project 工作目錄。
#
#   - this_shell_config_required_paths_output
#     產出內容的輸出路徑。
#
#   - this_shell_config_required_subcommands=([0]="aar" [1]="apk" [2]="appbundle" [3]="bundle" [4]="ios" [5]="ios-framework")
#     build subcommands，為此次需要編譯的模式為哪一些。
#
# ---
#
# - optional :
#
#   - report_path :
#     - this_shell_config_optional_report_path :
#       exported.sh 額外會用到的參數，指定 report file path (含檔名)。
#       為 markdown 語法撰寫，沒設定會有預設檔案名稱。
#
# - optional :
#
#   - build_name :
#     - this_shell_config_optional_build_name :
#       - [build_name] : build-name 會用到的內容，對應於 flutter build 的 build-name 參數
#       - support subcommands: apk， appbundle， ios
#
# - optional :
#
#   - build_number :
#     - this_shell_config_optional_build_number :
#       - [build_number] : build-number 會用到的內容，對應於 flutter build 的 build-number 參數
#       - support subcommands: aar， apk， appbundle， bundle， ios
#
# ---
#
# - optional :
#
#   - build_config_types :
#     - this_shell_config_optional_build_config_types :
#       build config type (like as : debug, profile, release)
#
# ---
#
# - optional :
#
#   - dart-define
#
#    - this_shell_config_optional_dart_define_separator
#      為要分隔符號
#      => e.g. "+"
#
#    - this_shell_config_optional_dart_define_defines
#      要設定到 dart-define 的內容，為 list 型態。
#      => e.g. (gitHash+920f6fc envName+dev)
#
# ---
#
# - optional :
#
#   - target_platform :
#     - this_shell_config_optional_target_platform :
#       對應於 flutter build 的 target-platform 參數。
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
#   - build_config function section :
#     有關 build config 處理的相關函式。
#
#   - export function section :
#     實際執行 flutter build [subcommand] 的函式。
#
#   - prcess function section :
#     流程函式，將流程會用到的獨立功能，以函式來呈現，
#
#   - deal prcess step section :
#     實際跑流程函式的順序，
#     會依序呼叫 [process_xxx]，
#     !!! [Waring] 有先後順序影響，不可任意調整呼叫順序，調整時務必想清楚 !!!。
#
# ---
#
# TODO:
#  - apk 未瘦身，不確定是否有擾亂 ?
#

## ================================== build_config function section : Begin ==================================
# ============= This is separation line =============
# @brief function : 處理並設定單一的 subcommand info .
# @detail : 簡易函式，不再處理細節的判斷，為保持正確性，參數請自行帶上 ""。
#   - 拆解成獨立函式，但是內容跟此 shell 有高度相依，只是獨立函式容易閱讀。
#
# @param $1: 需要驗證的 subcommand，內容來自於 build config => e.g. "${func_subcommand}" or "aar" ...
# @param $2: SubcommandInfo 中的 `name`。 this_shell_subcommand_info_xxx[0]。
#   => e.g. ${this_shell_subcommand_info_aar[0]} : aar
# @param $3: 要設定的參數，對應於 SubcommandInfo 中的 `是否要執行 (isExcute)`。 this_shell_subcommand_info_xxx[1]
#   => e.g. this_shell_subcommand_info_aar[1] .
#
# @sa : SubcommandInfo 說明可看 shell 上方的說明區塊。
#
# @TODO: 目前 SubcommandInfo 無法用 array 方式帶入，尚未測試成功，所以先分開參數帶入，之後可找時間另外找方法測試可行性。
#
# e.g. => deal_subcommand_info "${func_subcommand}" "${this_shell_subcommand_info_aar[0]}" this_shell_subcommand_info_aar[1]
function deal_subcommand_info() {

    local func_title_log="*** function [${FUNCNAME[0]}] -"
    local func_param_subcommand=$1
    local func_param_sumcommand_info_name=$2

    # echo "${func_title_log} Before func_param_subcommand : ${func_param_subcommand} ***"
    # echo "${func_title_log} Before func_param_sumcommand_info_name : ${func_param_sumcommand_info_name} ***"
    # echo "${func_title_log} Before func_subcommand_info_is_excute : $(eval echo \$${3}) ***"

    # 判斷是否為 要處理的 command (subcommand name 是否相同) .
    if [ ${func_param_subcommand} = ${func_param_sumcommand_info_name} ]; then
        eval ${3}="${GENERAL_CONST_ENABLE_FLAG}"
    fi

    # echo "${func_title_log} func_param_subcommand : ${func_param_subcommand} ***"
    # echo "${func_title_log} Before func_param_sumcommand_info_name : ${func_param_sumcommand_info_name} ***"
    # echo "${func_title_log} func_subcommand_info_is_excute : $(eval echo \$${3}) ***"
}

# ============= This is separation line =============
# @brief function : 剖析 required 部分 。
#        如 : version，subcommands。
# @detail : 簡易函式，不再處理細節的判斷，為保持正確性，參數請自行帶上 ""。
#   - 拆解成獨立函式，但是內容跟此 shell 有高度相依，只是獨立函式容易閱讀。
function parse_reruired_section() {

    echo
    echo "${this_shell_title_log} ============= parse required section : Begin ============="

    # check input parameters
    check_input_param "${this_shell_title_log}" this_shell_config_required_paths_work "${this_shell_config_required_paths_work}"
    check_input_param "${this_shell_title_log}" this_shell_config_required_paths_output "${this_shell_config_required_paths_output}"
    check_input_param "${this_shell_title_log}" this_shell_config_required_subcommands "${this_shell_config_required_subcommands[@]}"

    echo
    echo "${this_shell_title_log} ============= Param : Begin ============="
    echo "${this_shell_title_log} this_shell_config_required_paths_work : ${this_shell_config_required_paths_work}"
    echo "${this_shell_title_log} this_shell_config_required_paths_output : ${this_shell_config_required_paths_output}"
    echo "${this_shell_title_log} this_shell_config_required_subcommands : ${this_shell_config_required_subcommands[@]}"
    echo "${this_shell_title_log} ============= Param : End ============="
    echo

    local func_i
    for ((func_i = 0; func_i < ${#this_shell_config_required_subcommands[@]}; func_i++)); do #請注意 ((   )) 雙層括號

        local func_subcommand=${this_shell_config_required_subcommands[${func_i}]}

        # 判斷是否為 aar
        deal_subcommand_info "${func_subcommand}" "${this_shell_subcommand_info_aar[0]}" this_shell_subcommand_info_aar[1]

        # 判斷是否為 apk
        deal_subcommand_info "${func_subcommand}" "${this_shell_subcommand_info_apk[0]}" this_shell_subcommand_info_apk[1]

        # 判斷是否為 appbundle
        deal_subcommand_info "${func_subcommand}" "${this_shell_subcommand_info_appbundle[0]}" this_shell_subcommand_info_appbundle[1]

        # 判斷是否為 bundle
        deal_subcommand_info "${func_subcommand}" "${this_shell_subcommand_info_bundle[0]}" this_shell_subcommand_info_bundle[1]

        # 判斷是否為 ios
        deal_subcommand_info "${func_subcommand}" "${this_shell_subcommand_info_ios[0]}" this_shell_subcommand_info_ios[1]

        # 判斷是否為 ios_framework
        deal_subcommand_info "${func_subcommand}" "${this_shell_subcommand_info_ios_framework[0]}" this_shell_subcommand_info_ios_framework[1]

        # 判斷是否為 ipa
        deal_subcommand_info "${func_subcommand}" "${this_shell_subcommand_info_ipa[0]}" this_shell_subcommand_info_ipa[1]

        # 判斷是否為 web
        deal_subcommand_info "${func_subcommand}" "${this_shell_subcommand_info_web[0]}" this_shell_subcommand_info_web[1]

    done

    # dump support sumcommand info
    echo "${this_shell_title_log} this_shell_subcommand_info_aar           : ${this_shell_subcommand_info_aar[@]}"
    echo "${this_shell_title_log} this_shell_subcommand_info_apk           : ${this_shell_subcommand_info_apk[@]}"
    echo "${this_shell_title_log} this_shell_subcommand_info_appbundle     : ${this_shell_subcommand_info_appbundle[@]}"
    echo "${this_shell_title_log} this_shell_subcommand_info_bundle        : ${this_shell_subcommand_info_bundle[@]}"
    echo "${this_shell_title_log} this_shell_subcommand_info_ios           : ${this_shell_subcommand_info_ios[@]}"
    echo "${this_shell_title_log} this_shell_subcommand_info_ios_framework : ${this_shell_subcommand_info_ios_framework[@]}"
    echo "${this_shell_title_log} this_shell_subcommand_info_ipa           : ${this_shell_subcommand_info_ipa[@]}"
    echo "${this_shell_title_log} this_shell_subcommand_info_web           : ${this_shell_subcommand_info_web[@]}"

    echo "${this_shell_title_log} ============= required section : End ============="
    echo

}

# ============= This is separation line =============
# @brief function : 剖析 ReportPath 部分 。
# @detail : 簡易函式，不再處理細節的判斷，為保持正確性，參數請自行帶上 ""。
#   - 拆解成獨立函式，但是內容跟此 shell 有高度相依，只是獨立函式容易閱讀。
#   - 只檢查是否為合法設定。
function parse_report_path_section() {

    # build config 有設定則以設定為主。
    if [ -n "${this_shell_config_optional_report_path}" ]; then
        this_shell_report_note_file=${this_shell_config_optional_report_path}
    fi

}

# ============= This is separation line =============
# @brief function : 剖析 BuildConfigType 部分 。
# @detail : 簡易函式，不再處理細節的判斷，為保持正確性，參數請自行帶上 ""。
#   - 拆解成獨立函式，但是內容跟此 shell 有高度相依，只是獨立函式容易閱讀。
#   - 只檢查是否為合法設定。
function parse_build_config_type_section() {

    if [ -n "${this_shell_config_optional_build_config_types}" ]; then

        local func_src_list=("${CONFIG_CONST_BUILD_CONFIG_TYPE_DEBUG}" "${CONFIG_CONST_BUILD_CONFIG_TYPE_PROFILE}" "${CONFIG_CONST_BUILD_CONFIG_TYPE_RELEASE}")

        local func_i
        for ((func_i = 0; func_i < ${#this_shell_config_optional_build_config_types[@]}; func_i++)); do #請注意 ((   )) 雙層括號

            local func_check_value="${this_shell_config_optional_build_config_types[${func_i}]}"

            check_legal_val_in_list__if__result_fail_then_change_folder "${this_shell_title_log}" \
                "${func_check_value}" func_src_list[@] "${this_shell_old_path}"

        done

    fi
}

# ============= This is separation line =============
# @brief function : 剖析 dart-define 。
# @detail : 簡易函式，不再處理細節的判斷，為保持正確性，參數請自行帶上 ""。
#   - 拆解成獨立函式，但是內容跟此 shell 有高度相依，只是獨立函式容易閱讀。
function parse_dart_define_section() {

    # 判斷是否有 dart-define 的設定:
    if [ -n "${this_shell_config_optional_dart_define_defines}" ] && [ -n "${this_shell_config_optional_dart_define_separator}" ]; then

        echo
        echo "${this_shell_title_log} ============= parse "${CONFIG_CONST_BUILD_PARAM_KEY_DART_DEFINE}" : Begin ============="

        # check input parameters
        check_input_param "${this_shell_title_log}" this_shell_config_optional_dart_define_defines "${this_shell_config_optional_dart_define_defines[@]}"
        check_input_param "${this_shell_title_log}" this_shell_config_optional_dart_define_separator "${this_shell_config_optional_dart_define_separator}"

        echo
        echo "${this_shell_title_log} ============= Param : Begin ============="
        echo "${this_shell_title_log} this_shell_config_optional_dart_define_defines : ${this_shell_config_optional_dart_define_defines[@]}"
        echo "${this_shell_title_log} this_shell_config_optional_dart_define_separator : ${this_shell_config_optional_dart_define_separator}"
        echo "${this_shell_title_log} ============= Param : End ============="
        echo

        local func_i
        for ((func_i = 0; func_i < ${#this_shell_config_optional_dart_define_defines[@]}; func_i++)); do #請注意 ((   )) 雙層括號

            local func_define=${this_shell_config_optional_dart_define_defines[${func_i}]}

            local func_key
            local func_val

            split_string_to_pair "${this_shell_title_log}" "${func_define}" "${this_shell_config_optional_dart_define_separator}" func_key func_val

            # 第一次，尚未設定。
            if [ -z "${this_shell_dart_def_part_of_command}" ] && [ -z "${this_shell_dart_def_part_of_file_name}" ]; then

                this_shell_dart_def_part_of_command="--"${CONFIG_CONST_BUILD_PARAM_KEY_DART_DEFINE}"=${func_key}=${func_val}"
                this_shell_dart_def_part_of_file_name="${func_key}_${func_val}"

            else

                this_shell_dart_def_part_of_command="${this_shell_dart_def_part_of_command} --"${CONFIG_CONST_BUILD_PARAM_KEY_DART_DEFINE}"=${func_key}=${func_val}"
                this_shell_dart_def_part_of_file_name="${this_shell_dart_def_part_of_file_name}-${func_key}_${func_val}"

            fi

        done

        # check input parameters
        check_input_param "${this_shell_title_log}" this_shell_dart_def_part_of_command "${this_shell_dart_def_part_of_command[@]}"
        check_input_param "${this_shell_title_log}" this_shell_dart_def_part_of_file_name "${this_shell_dart_def_part_of_file_name}"

        echo "${this_shell_title_log} this_shell_dart_def_part_of_command  : ${this_shell_dart_def_part_of_command}"
        echo "${this_shell_title_log} this_shell_dart_def_part_of_file_name : ${this_shell_dart_def_part_of_file_name}"

        echo "${this_shell_title_log} ============= parse "${CONFIG_CONST_BUILD_PARAM_KEY_DART_DEFINE}" : End ============="
        echo

    fi
}

## ================================== build_config function section : End ==================================

## ================================== export function section : Begin ==================================
### ==================== NotyetSupportSubcommand : Begin ====================
# @brief 尚未支援的 subcommand 的通用函式
# @param $1 : command name
function export_notyet_support_subcommand() {

    local func_title_log="${this_shell_title_log} *** function [${FUNCNAME[0]}] -"

    # 暫存此區塊的起始時間。
    local func_subcommand=${1}

    echo "${GENERAL_CONST_COLORS_BBLACK}${GENERAL_CONST_COLORS_RED}${GENERAL_CONST_COLORS_ON_CYAN}${func_title_log} OPPS!! Notyet support this subcommand ( ${func_subcommand} ).\n    Please check your demand or make request that modify ${this_shell_title_name}.sh to support this subcommand ( ${func_subcommand} ).\n    Error !!! ***${GENERAL_CONST_COLORS_COLOR_OFF}"

    check_result_if_fail_then_change_folder "${func_title_log}" "50" "!!! ~ OPPS!! Notyet support this subcommand ( ${func_subcommand} ).\n    Please check your demand or make request that modify ${this_shell_title_name}.sh to support this subcommand ( ${func_subcommand} ).\n    Error !!! ***" "${this_shell_old_path}"
}
### ==================== NotyetSupportSubcommand : End ====================

### ==================== aar : Begin ====================
# @brief exported aar 部分 。
function export_aar() {

    local func_title_log="${this_shell_title_log} *** function [${FUNCNAME[0]}] -"

    # 暫存此區塊的起始時間。
    local func_temp_seconds=${SECONDS}
    local func_subcommand=${this_shell_subcommand_info_aar[0]}

    echo
    echo "${this_shell_title_log} ||==========> ${func_subcommand} : Begin <==========||"

    export_notyet_support_subcommand ${func_subcommand}

    echo "${this_shell_title_log} ||==========> ${func_subcommand} : End <==========|| Elapsed time: $((${SECONDS} - ${func_temp_seconds}))s"
    echo
}
### ==================== aar : End ====================

### ==================== apk : Begin ====================
# @brief exported apk 部分 。
# @param ${1}: build_config_type :  有 debug ， profile ， release 。
function export_apk() {

    local func_name=${FUNCNAME[0]}
    local func_title_log="${this_shell_title_log} *** function [${func_name}] -"

    # 暫存此區塊的起始時間。
    local func_temp_seconds=${SECONDS}
    local func_subcommand=${this_shell_subcommand_info_apk[0]}

    echo
    echo "${func_title_log} ||==========> ${func_subcommand} : Begin <==========||"

    local func_param_build_config_type="${1}"

    # check input parameters
    check_input_param "${func_title_log}" func_param_build_config_type "${func_param_build_config_type}"

    echo
    echo "${func_title_log} ============= Param : Begin ============="
    echo "${func_title_log} func_param_build_config_type : ${func_param_build_config_type}"
    echo "${func_title_log} ============= Param : End ============="
    echo

    echo "${func_title_log} 開始打包 ${func_subcommand}"

    # ===> Command 設定 <===
    # 設定基本的 command 內容. [subcommand] [config type]
    local func_build_command_name
    local func_build_command

    # 判斷 this_shell_config_flutter_run_config_is_enable_fvm_mode
    if [ ${this_shell_config_optional_is_enable_fvm_mode} = "${GENERAL_CONST_ENABLE_FLAG}" ]; then

        func_build_command_name="${CONFIG_CONST_COMMAND_NAME_FVM}"
        func_build_command="${CONFIG_CONST_COMMAND_NAME_FLUTTER} build ${func_subcommand} --${func_param_build_config_type}"

    else

        func_build_command_name="${CONFIG_CONST_COMMAND_NAME_FLUTTER}"
        func_build_command="build ${func_subcommand} --${func_param_build_config_type}"

    fi

    # 若有 build_name
    if [ -n "${this_shell_config_optional_build_name}" ]; then
        func_build_command="${func_build_command} --${CONFIG_CONST_BUILD_PARAM_KEY_BUILD_NAME} ${this_shell_config_optional_build_name}"
    fi

    # 若有 build_number
    if [ -n "${this_shell_config_optional_build_number}" ]; then
        func_build_command="${func_build_command} --${CONFIG_CONST_BUILD_PARAM_KEY_BUILD_NUMBER} ${this_shell_config_optional_build_number}"
    fi

    # 若有 flavor
    if [ -n "${this_shell_config_optional_flavor}" ]; then
        func_build_command="${func_build_command} --${CONFIG_CONST_BUILD_PARAM_KEY_FLAVOR}=${this_shell_config_optional_flavor}"
    fi

    # 若有 dart-define
    if [ -n "${this_shell_dart_def_part_of_command}" ]; then
        func_build_command="${func_build_command} ${this_shell_dart_def_part_of_command}"
    fi

    # 若有 target-platform
    if [ -n "${this_shell_config_optional_target_platform}" ]; then
        func_build_command="${func_build_command} --${CONFIG_CONST_BUILD_PARAM_KEY_TARGET_PLATFORM} ${this_shell_config_optional_target_platform}"
    fi

    # ===> OutputFile 設定 <===
    # 設定基本的輸出檔案格式。
    local func_build_file_name

    local func_build_seperator="-"

    # 若有 prefix file name
    append_dest_string_from_source_string_with_separator "${func_title_log}" \
        func_build_file_name this_shell_config_optional_prefix_file_name "${func_build_seperator}"

    # 若有 flavor
    append_dest_string_from_source_string_with_separator "${func_title_log}" \
        func_build_file_name this_shell_config_optional_flavor "${func_build_seperator}"

    # 若有 config type
    append_dest_string_from_source_string_with_separator "${func_title_log}" \
        func_build_file_name func_param_build_config_type "${func_build_seperator}"

    # 若有 build_name
    append_dest_string_from_source_string_with_separator "${func_title_log}" \
        func_build_file_name this_shell_config_optional_build_name "${func_build_seperator}"

    # 若有 build_number
    append_dest_string_from_source_string_with_separator "${func_title_log}" \
        func_build_file_name this_shell_config_optional_build_number "${func_build_seperator}"

    # 若有 dart-define
    append_dest_string_from_source_string_with_separator "${func_title_log}" \
        func_build_file_name this_shell_dart_def_part_of_file_name "${func_build_seperator}"

    # 補上 時間戳記
    func_build_file_name="${func_build_file_name}-$(date "+%Y%m%d%H%M")"

    # 設定要輸出的資料夾，原有的輸出目錄，補上檔名 (尚未加上副檔名) 當子資料夾。
    local func_output_folder=${this_shell_config_required_paths_output}/${func_build_file_name}

    # 確保要輸出的的資料夾存在。
    mkdir -p ${func_output_folder}

    # 補上結尾
    func_build_file_name="${func_build_file_name}.apk"

    # 若有 混淆 功能 (obfuscate)，測試中，暫時寫死
    # e.g. flutter build apk --obfuscate --split-debug-info=/<project-name>/<directory> --extra-gen-snapshot-options=--save-obfuscation-map=/<your-path>
    if [ ${func_param_build_config_type} = "${CONFIG_CONST_BUILD_CONFIG_TYPE_RELEASE}" ]; then

        # TODO: 有指定輸出資料夾，則以指定資料夾為主。
        local func_debug_info_folder="${func_output_folder}/${CONFIG_CONST_EXPORTED_DEFAULT_OBFUSCATE_SPLIT_DEBUG_INFO_FOLDER_NAME}"
        mkdir -p "${func_debug_info_folder}"

        # TODO: 有指定輸出檔案，則以指定輸出檔案為主。
        func_build_command="${func_build_command} --${CONFIG_CONST_BUILD_PARAM_KEY_OBFUSCATE} --${CONFIG_CONST_BUILD_PARAM_KEY_SPLIT_DEBUG_INFO}=${func_debug_info_folder} --${CONFIG_CONST_BUILD_PARAM_KEY_OBFUSCATE_SAVE_MAP_PATH}=${func_debug_info_folder}/${CONFIG_CONST_EXPORTED_DEFAULT_OBFUSCATE_SAVE_MAP_FILE_NAME}"

    fi

    # ===> Origin build output 設定 <===
    local func_origin_build_file_name="build/app/outputs/apk"

    # 若有 flavor
    if [ -n "${this_shell_config_optional_flavor}" ]; then
        func_origin_build_file_name="${func_origin_build_file_name}/${this_shell_config_optional_flavor}/${func_param_build_config_type}/app-${this_shell_config_optional_flavor}"
    else
        func_origin_build_file_name="${func_origin_build_file_name}/${func_param_build_config_type}/app"
    fi

    # build type
    func_origin_build_file_name="${func_origin_build_file_name}-${func_param_build_config_type}.apk"

    # ===> report note - init 設定 <===
    echo >>"${this_shell_report_note_file}"
    echo "---" >>"${this_shell_report_note_file}"
    echo >>"${this_shell_report_note_file}"
    echo "## [${func_name}] ${func_build_file_name}" >>"${this_shell_report_note_file}"
    echo >>"${this_shell_report_note_file}"
    echo "- command line :" >>"${this_shell_report_note_file}"
    echo >>"${this_shell_report_note_file}"
    echo "  \`\`\`shell" >>"${this_shell_report_note_file}"
    echo "    ${func_build_command_name} ${func_build_command}" >>"${this_shell_report_note_file}"
    echo "  \`\`\`" >>"${this_shell_report_note_file}"

    # ===> build apk <===
    echo "${func_title_log} ===> build ${func_subcommand} <==="
    echo "${func_title_log} ${func_build_command_name} ${func_build_command}"
    ${func_build_command_name} ${func_build_command}

    # check result - build apk
    check_result_if_fail_then_change_folder "${func_title_log}" "$?" "!!! ~ ${func_build_command_name} ${func_build_command} => fail ~ !!!" "${this_shell_old_path}"

    # ===> copy apk to destination folder <===
    echo "${func_title_log} ===> copy ${func_param_build_config_type} ${func_subcommand} to output folder <==="

    cp -r "${func_origin_build_file_name}" "${func_output_folder}/${func_build_file_name}"

    # check result - copy apk
    check_result_if_fail_then_change_folder "${func_title_log}" "$?" "!!! ~ copy ${func_param_build_config_type} ${func_subcommand} to output folder => fail ~ !!!" "${this_shell_old_path}"

    echo "${func_title_log} 打包 ${func_subcommand} 已經完成"
    echo "${func_title_log} output file name : ${func_build_file_name}"
    say "${func_title_log} 打包 ${func_subcommand} 成功"

    # ===> report note - final 設定 <===
    # ===> 輸出 全部的產出時間統計 <===
    local func_total_time=$((${SECONDS} - ${func_temp_seconds}))
    echo >>"${this_shell_report_note_file}"
    echo "- Elapsed time: ${func_total_time}s" >>"${this_shell_report_note_file}"

    echo
    echo "${func_title_log} ||==========> ${func_subcommand} : End <==========|| Elapsed time: ${func_total_time}s"
    echo
}
### ==================== apk : End ====================

### ==================== appbundle : Begin ====================
# @brief exported appbundle 部分 。
# @param ${1}: build_config_type :  有 debug ， profile ， release 。
function export_appbundle() {

    local func_name=${FUNCNAME[0]}
    local func_title_log="${this_shell_title_log} *** function [${func_name}] -"

    # 暫存此區塊的起始時間。
    local func_temp_seconds=${SECONDS}
    local func_subcommand=${this_shell_subcommand_info_appbundle[0]}

    echo
    echo "${func_title_log} ||==========> ${func_subcommand} : Begin <==========||"

    local func_param_build_config_type="${1}"

    # check input parameters
    check_input_param "${func_title_log}" func_param_build_config_type "${func_param_build_config_type}"

    echo
    echo "${func_title_log} ============= Param : Begin ============="
    echo "${func_title_log} func_param_build_config_type : ${func_param_build_config_type}"
    echo "${func_title_log} ============= Param : End ============="
    echo

    # 資料夾部分內容，需要轉換 config type 的首字為大寫， e.g. release => Release 。
    # - 設定首字小寫轉大寫。
    # - 加上原本後面的內容。
    local func_first_letter_trans_to_upper_for_build_config_type=$(echo ${func_param_build_config_type:0:1} | tr "[:lower:]" "[:upper:]")
    func_first_letter_trans_to_upper_for_build_config_type=${func_first_letter_trans_to_upper_for_build_config_type}$(echo ${func_param_build_config_type:1})

    echo
    echo "${func_title_log} ============= check value : Begin ============="
    echo "${func_title_log} func_first_letter_trans_to_upper_for_build_config_type : ${func_first_letter_trans_to_upper_for_build_config_type}"
    echo "${func_title_log} ============= check value : End ============="
    echo

    echo "${func_title_log} 開始打包 ${func_subcommand}"

    # ===> Command 設定 <===
    # 設定基本的 command 內容. [subcommand] [config type]
    local func_build_command_name
    local func_build_command

    # 判斷 this_shell_config_flutter_run_config_is_enable_fvm_mode
    if [ ${this_shell_config_optional_is_enable_fvm_mode} = "${GENERAL_CONST_ENABLE_FLAG}" ]; then

        func_build_command_name="${CONFIG_CONST_COMMAND_NAME_FVM}"
        func_build_command="${CONFIG_CONST_COMMAND_NAME_FLUTTER} build ${func_subcommand} --${func_param_build_config_type}"

    else

        func_build_command_name="${CONFIG_CONST_COMMAND_NAME_FLUTTER}"
        func_build_command="build ${func_subcommand} --${func_param_build_config_type}"

    fi

    # 若有 build_name
    if [ -n "${this_shell_config_optional_build_name}" ]; then
        func_build_command="${func_build_command} --${CONFIG_CONST_BUILD_PARAM_KEY_BUILD_NAME} ${this_shell_config_optional_build_name}"
    fi

    # 若有 build_number
    if [ -n "${this_shell_config_optional_build_number}" ]; then
        func_build_command="${func_build_command} --${CONFIG_CONST_BUILD_PARAM_KEY_BUILD_NUMBER} ${this_shell_config_optional_build_number}"
    fi

    # 若有 flavor
    if [ -n "${this_shell_config_optional_flavor}" ]; then
        func_build_command="${func_build_command} --${CONFIG_CONST_BUILD_PARAM_KEY_FLAVOR}=${this_shell_config_optional_flavor}"
    fi

    # 若有 dart-define
    if [ -n "${this_shell_dart_def_part_of_command}" ]; then
        func_build_command="${func_build_command} ${this_shell_dart_def_part_of_command}"
    fi

    # 若有 target-platform
    if [ -n "${this_shell_config_optional_target_platform}" ]; then
        func_build_command="${func_build_command} --${CONFIG_CONST_BUILD_PARAM_KEY_TARGET_PLATFORM} ${this_shell_config_optional_target_platform}"
    fi

    # ===> OutputFile 設定 <===
    # 設定基本的輸出檔案格式。
    local func_build_file_name

    local func_build_seperator="-"

    # 若有 prefix file name
    append_dest_string_from_source_string_with_separator "${func_title_log}" \
        func_build_file_name this_shell_config_optional_prefix_file_name "${func_build_seperator}"

    # 若有 flavor
    append_dest_string_from_source_string_with_separator "${func_title_log}" \
        func_build_file_name this_shell_config_optional_flavor "${func_build_seperator}"

    # 若有 config type
    append_dest_string_from_source_string_with_separator "${func_title_log}" \
        func_build_file_name func_param_build_config_type "${func_build_seperator}"

    # 若有 build_name
    append_dest_string_from_source_string_with_separator "${func_title_log}" \
        func_build_file_name this_shell_config_optional_build_name "${func_build_seperator}"

    # 若有 build_number
    append_dest_string_from_source_string_with_separator "${func_title_log}" \
        func_build_file_name this_shell_config_optional_build_number "${func_build_seperator}"

    # 若有 dart-define
    append_dest_string_from_source_string_with_separator "${func_title_log}" \
        func_build_file_name this_shell_dart_def_part_of_file_name "${func_build_seperator}"

    # 補上 時間戳記
    func_build_file_name="${func_build_file_name}-$(date "+%Y%m%d%H%M")"

    # 設定要輸出的資料夾，原有的輸出目錄，補上檔名 (尚未加上副檔名) 當子資料夾。
    local func_output_folder=${this_shell_config_required_paths_output}/${func_build_file_name}

    # 確保要輸出的的資料夾存在。
    mkdir -p ${func_output_folder}

    # 補上結尾
    func_build_file_name="${func_build_file_name}.aab"

    # 若有 混淆 功能 (obfuscate)，測試中，暫時寫死
    # e.g. flutter build apk --obfuscate --split-debug-info=/<project-name>/<directory> --extra-gen-snapshot-options=--save-obfuscation-map=/<your-path>
    if [ ${func_param_build_config_type} = "${CONFIG_CONST_BUILD_CONFIG_TYPE_RELEASE}" ]; then

        # TODO: 有指定輸出資料夾，則以指定資料夾為主。
        local func_debug_info_folder="${func_output_folder}/${CONFIG_CONST_EXPORTED_DEFAULT_OBFUSCATE_SPLIT_DEBUG_INFO_FOLDER_NAME}"
        mkdir -p "${func_debug_info_folder}"

        # TODO: 有指定輸出檔案，則以指定輸出檔案為主。
        func_build_command="${func_build_command} --${CONFIG_CONST_BUILD_PARAM_KEY_OBFUSCATE} --${CONFIG_CONST_BUILD_PARAM_KEY_SPLIT_DEBUG_INFO}=${func_debug_info_folder} --${CONFIG_CONST_BUILD_PARAM_KEY_OBFUSCATE_SAVE_MAP_PATH}=${func_debug_info_folder}/${CONFIG_CONST_EXPORTED_DEFAULT_OBFUSCATE_SAVE_MAP_FILE_NAME}"

    fi

    # ===> Origin build output 設定 <===
    local func_origin_build_file_name="build/app/outputs/bundle"

    # 若有 flavor
    if [ -n "${this_shell_config_optional_flavor}" ]; then
        func_origin_build_file_name="${func_origin_build_file_name}/${this_shell_config_optional_flavor}${func_first_letter_trans_to_upper_for_build_config_type}/app-${this_shell_config_optional_flavor}"
    else
        func_origin_build_file_name="${func_origin_build_file_name}/${func_param_build_config_type}/app"
    fi

    # build type
    func_origin_build_file_name="${func_origin_build_file_name}-${func_param_build_config_type}.aab"

    echo "${func_title_log} ===> func_origin_build_file_name : ${func_origin_build_file_name} <==="

    # ===> report note - init 設定 <===
    echo >>"${this_shell_report_note_file}"
    echo "---" >>"${this_shell_report_note_file}"
    echo >>"${this_shell_report_note_file}"
    echo "## [${func_name}] ${func_build_file_name}" >>"${this_shell_report_note_file}"
    echo >>"${this_shell_report_note_file}"
    echo "- command line :" >>"${this_shell_report_note_file}"
    echo >>"${this_shell_report_note_file}"
    echo "  \`\`\`shell" >>"${this_shell_report_note_file}"
    echo "    ${func_build_command_name} ${func_build_command}" >>"${this_shell_report_note_file}"
    echo "  \`\`\`" >>"${this_shell_report_note_file}"

    # ===> build appbundle <===
    echo "${func_title_log} ===> build ${func_subcommand} <==="
    echo "${func_title_log} ${func_build_command_name} ${func_build_command}"
    ${func_build_command_name} ${func_build_command}

    # check result - build appbundle
    check_result_if_fail_then_change_folder "${func_title_log}" "$?" "!!! ~ ${func_build_command_name} ${func_build_command} => fail ~ !!!" "${this_shell_old_path}"

    # ===> copy aab to destination folder <===
    echo "${func_title_log} ===> copy ${func_param_build_config_type} ${func_subcommand} to output folder <==="

    cp -r "${func_origin_build_file_name}" "${func_output_folder}/${func_build_file_name}"

    # check result - copy aab
    check_result_if_fail_then_change_folder "${func_title_log}" "$?" "!!! ~ copy ${func_param_build_config_type} ${func_subcommand} to output folder => fail ~ !!!" "${this_shell_old_path}"

    echo "${func_title_log} 打包 ${func_subcommand} 已經完成"
    echo "${func_title_log} output file name : ${func_build_file_name}"
    say "${func_title_log} 打包 ${func_subcommand} 成功"

    # ===> report note - final 設定 <===
    # ===> 輸出 全部的產出時間統計 <===
    local func_total_time=$((${SECONDS} - ${func_temp_seconds}))
    echo >>"${this_shell_report_note_file}"
    echo "- Elapsed time: ${func_total_time}s" >>"${this_shell_report_note_file}"

    echo
    echo "${func_title_log} ||==========> ${func_subcommand} : End <==========|| Elapsed time: ${func_total_time}s"
    echo
}
### ==================== appbundle : End ====================

### ==================== bundle : Begin ====================
# @brief exported bundle 部分 。
# @param ${1}: build_config_type :  有 debug ， profile ， release 。
function export_bundle() {

    local func_title_log="${this_shell_title_log} *** function [${FUNCNAME[0]}] -"

    # 暫存此區塊的起始時間。
    local func_temp_seconds=${SECONDS}
    local func_subcommand=${this_shell_subcommand_info_bundle[0]}

    echo
    echo "${func_title_log} ||==========> ${func_subcommand} : Begin <==========||"

    export_notyet_support_subcommand ${func_subcommand}

    echo "${func_title_log} ||==========> ${func_subcommand} : End <==========|| Elapsed time: $((${SECONDS} - ${func_temp_seconds}))s"
    echo
}
### ==================== bundle : End ====================

### ==================== ios : Begin ====================
# @brief ios 部分 。
# @param ${1}: build_config_type :  有 debug ， profile ， release 。
function export_ios() {

    local func_name=${FUNCNAME[0]}
    local func_title_log="${this_shell_title_log} *** function [${func_name}] -"

    # 暫存此區塊的起始時間。
    local func_temp_seconds=${SECONDS}
    local func_subcommand=${this_shell_subcommand_info_ios[0]}

    echo
    echo "${func_title_log} ||==========> ${func_subcommand} : Begin <==========||"

    local func_param_build_config_type="${1}"

    # check input parameters
    check_input_param "${func_title_log}" func_param_build_config_type "${func_param_build_config_type}"

    echo
    echo "${func_title_log} ============= Param : Begin ============="
    echo "${func_title_log} func_param_build_config_type : ${func_param_build_config_type}"
    echo "${func_title_log} ============= Param : End ============="
    echo

    echo "${func_title_log} 開始打包 ${func_subcommand}"

    # ===> Command 設定 <===
    # 設定基本的 command 內容. [subcommand] [config type]
    local func_build_command_name
    local func_build_command

    # 判斷 this_shell_config_flutter_run_config_is_enable_fvm_mode
    if [ ${this_shell_config_optional_is_enable_fvm_mode} = "${GENERAL_CONST_ENABLE_FLAG}" ]; then

        func_build_command_name="${CONFIG_CONST_COMMAND_NAME_FVM}"
        func_build_command="${CONFIG_CONST_COMMAND_NAME_FLUTTER} build ${func_subcommand} --${func_param_build_config_type}"

    else

        func_build_command_name="${CONFIG_CONST_COMMAND_NAME_FLUTTER}"
        func_build_command="build ${func_subcommand} --${func_param_build_config_type}"

    fi

    # 若有 build_name
    if [ -n "${this_shell_config_optional_build_name}" ]; then
        func_build_command="${func_build_command} --${CONFIG_CONST_BUILD_PARAM_KEY_BUILD_NAME} ${this_shell_config_optional_build_name}"
    fi

    # 若有 build_number
    if [ -n "${this_shell_config_optional_build_number}" ]; then
        func_build_command="${func_build_command} --${CONFIG_CONST_BUILD_PARAM_KEY_BUILD_NUMBER} ${this_shell_config_optional_build_number}"
    fi

    # 若有 flavor
    if [ -n "${this_shell_config_optional_flavor}" ]; then
        func_build_command="${func_build_command} --${CONFIG_CONST_BUILD_PARAM_KEY_FLAVOR}=${this_shell_config_optional_flavor}"
    fi

    # 若有 dart-define
    if [ -n "${this_shell_dart_def_part_of_command}" ]; then
        func_build_command="${func_build_command} ${this_shell_dart_def_part_of_command}"
    fi

    # 若有 extra command line...

    # ===> OutputFile 設定 <===
    # 設定基本的輸出檔案格式。
    local func_build_file_name

    local func_build_seperator="-"

    # 若有 prefix file name
    append_dest_string_from_source_string_with_separator "${func_title_log}" \
        func_build_file_name this_shell_config_optional_prefix_file_name "${func_build_seperator}"

    # 若有 flavor
    append_dest_string_from_source_string_with_separator "${func_title_log}" \
        func_build_file_name this_shell_config_optional_flavor "${func_build_seperator}"

    # 若有 config type
    append_dest_string_from_source_string_with_separator "${func_title_log}" \
        func_build_file_name func_param_build_config_type "${func_build_seperator}"

    # 若有 build_name
    append_dest_string_from_source_string_with_separator "${func_title_log}" \
        func_build_file_name this_shell_config_optional_build_name "${func_build_seperator}"

    # 若有 build_number
    append_dest_string_from_source_string_with_separator "${func_title_log}" \
        func_build_file_name this_shell_config_optional_build_number "${func_build_seperator}"

    # 若有 dart-define
    append_dest_string_from_source_string_with_separator "${func_title_log}" \
        func_build_file_name this_shell_dart_def_part_of_file_name "${func_build_seperator}"

    # 補上 時間戳記
    func_build_file_name="${func_build_file_name}-$(date "+%Y%m%d%H%M")"

    # 設定要輸出的資料夾，原有的輸出目錄，補上檔名 (尚未加上副檔名) 當子資料夾。
    local func_output_folder=${this_shell_config_required_paths_output}/${func_build_file_name}

    # 確保要輸出的的資料夾存在。
    mkdir -p ${func_output_folder}

    # 補上結尾
    func_build_file_name="${func_build_file_name}.ipa"

    # 若有 混淆 功能 (obfuscate)，測試中，暫時寫死
    # e.g. flutter build apk --obfuscate --split-debug-info=/<project-name>/<directory> --extra-gen-snapshot-options=--save-obfuscation-map=/<your-path>
    if [ ${func_param_build_config_type} = "${CONFIG_CONST_BUILD_CONFIG_TYPE_RELEASE}" ]; then

        # TODO: 有指定輸出資料夾，則以指定資料夾為主。
        local func_debug_info_folder="${func_output_folder}/${CONFIG_CONST_EXPORTED_DEFAULT_OBFUSCATE_SPLIT_DEBUG_INFO_FOLDER_NAME}"
        mkdir -p "${func_debug_info_folder}"

        # TODO: 有指定輸出檔案，則以指定輸出檔案為主。
        func_build_command="${func_build_command} --${CONFIG_CONST_BUILD_PARAM_KEY_OBFUSCATE} --${CONFIG_CONST_BUILD_PARAM_KEY_SPLIT_DEBUG_INFO}=${func_debug_info_folder} --${CONFIG_CONST_BUILD_PARAM_KEY_OBFUSCATE_SAVE_MAP_PATH}=${func_debug_info_folder}/${CONFIG_CONST_EXPORTED_DEFAULT_OBFUSCATE_SAVE_MAP_FILE_NAME}"

    fi

    # ===> Origin build output 設定 <===
    local func_origin_build_app_folder="build/ios/iphoneos"

    # 若有 flavor
    if [ -n "${this_shell_config_optional_flavor}" ]; then
        func_origin_build_app_folder="${func_origin_build_app_folder}/${this_shell_config_optional_flavor}.app"
    else
        func_origin_build_app_folder="${func_origin_build_app_folder}/Runner.app"
    fi

    # ===> report note - init 設定 <===
    echo >>"${this_shell_report_note_file}"
    echo "---" >>"${this_shell_report_note_file}"
    echo >>"${this_shell_report_note_file}"
    echo "## [${func_name}] ${func_build_file_name}" >>"${this_shell_report_note_file}"
    echo >>"${this_shell_report_note_file}"
    echo "- command line :" >>"${this_shell_report_note_file}"
    echo >>"${this_shell_report_note_file}"
    echo "  \`\`\`shell" >>"${this_shell_report_note_file}"
    echo "    ${func_build_command_name} ${func_build_command}" >>"${this_shell_report_note_file}"
    echo "  \`\`\`" >>"${this_shell_report_note_file}"

    # ===> build ios <===
    echo "${func_title_log} ===> build ${func_subcommand} <==="
    echo "${func_title_log} ${func_build_command_name} ${func_build_command}"
    ${func_build_command_name} ${func_build_command}

    # check result - build ios
    check_result_if_fail_then_change_folder "${func_title_log}" "$?" "!!! ~ ${func_build_command_name} ${func_build_command} => fail ~ !!!" "${this_shell_old_path}"

    # ===> zip Payload to destination folder <===
    if [ -d ${func_origin_build_app_folder} ]; then

        # 切換到 輸出目錄，再打包才不會包到不該包的資料夾。
        change_to_directory "${func_title_log}" "${func_output_folder}"

        # 打包 ipa 的固定資料夾名稱。
        mkdir Payload

        cp -r "${this_shell_flutter_work_path}/${func_origin_build_app_folder}" "${func_output_folder}/Payload"

        # check result - copy iOS Payload
        check_result_if_fail_then_change_folder "${func_title_log}" "$?" "!!! ~ copy iOS Payload => fail ~ !!!" "${this_shell_old_path}"

        # zip file
        zip -r -m ${func_build_file_name} Payload

        # check result - zip iOS Payload
        check_result_if_fail_then_change_folder "${func_title_log}" "$?" "!!! ~ zip iOS Payload => fail ~ !!!" "${this_shell_old_path}"

        # 切換到 flutter work path
        change_to_directory "${func_title_log}" "${this_shell_flutter_work_path}"

        echo "${func_title_log} 打包 ${func_subcommand} 很順利 😄"
        say "${func_title_log} 打包 ${func_subcommand} 成功"

    else

        echo "${func_title_log} 遇到報錯了 😭, 打開 Xcode 查找錯誤原因"
        say "${func_title_log} 打包 ${func_subcommand} 失敗"

        # check result - copy ios
        check_result_if_fail_then_change_folder "${func_title_log}" "100" "!!! ~ Not found ${func_origin_build_app_folder} => fail ~ !!!" "${this_shell_old_path}"
    fi

    # ===> report note - final 設定 <===
    # ===> 輸出 全部的產出時間統計 <===
    local func_total_time=$((${SECONDS} - ${func_temp_seconds}))
    echo >>"${this_shell_report_note_file}"
    echo "- Elapsed time: ${func_total_time}s" >>"${this_shell_report_note_file}"

    echo
    echo "${func_title_log} ||==========> ${func_subcommand} : End <==========|| Elapsed time: ${func_total_time}s"
    echo
}
### ==================== ios : End ====================

### ==================== ios_framework : Begin ====================
# @brief exported ios_framework 部分 。
function export_ios_framework() {

    local func_title_log="${this_shell_title_log} *** function [${FUNCNAME[0]}] -"

    # 暫存此區塊的起始時間。
    local func_temp_seconds=${SECONDS}
    local func_subcommand=${this_shell_subcommand_info_ios_framework[0]}

    echo
    echo "${func_title_log} ||==========> ${func_subcommand} : Begin <==========||"

    export_notyet_support_subcommand ${func_subcommand}

    echo "${func_title_log} ||==========> ${func_subcommand} : End <==========|| Elapsed time: $((${SECONDS} - ${func_temp_seconds}))s"
    echo
}
### ==================== ios_framework : End ====================

### ==================== ipa : Begin ====================
# @brief exported ipa 部分 。
# @param ${1}: build_config_type :  有 debug ， profile ， release 。
function export_ipa() {

    local func_name=${FUNCNAME[0]}
    local func_title_log="${this_shell_title_log} *** function [${func_name}] -"

    # 暫存此區塊的起始時間。
    local func_temp_seconds=${SECONDS}
    local func_subcommand=${this_shell_subcommand_info_ipa[0]}

    echo
    echo "${func_title_log} ||==========> ${func_subcommand} : Begin <==========||"

    local func_param_build_config_type="${1}"

    # check input parameters
    check_input_param "${func_title_log}" func_param_build_config_type "${func_param_build_config_type}"

    echo
    echo "${func_title_log} ============= Param : Begin ============="
    echo "${func_title_log} func_param_build_config_type : ${func_param_build_config_type}"
    echo "${func_title_log} ============= Param : End ============="
    echo

    echo "${func_title_log} 開始打包 ${func_subcommand}"

    # ===> Command 設定 <===
    # 設定基本的 command 內容. [subcommand] [config type]
    local func_build_command_name
    local func_build_command

    # 判斷 this_shell_config_flutter_run_config_is_enable_fvm_mode
    if [ ${this_shell_config_optional_is_enable_fvm_mode} = "${GENERAL_CONST_ENABLE_FLAG}" ]; then

        func_build_command_name="${CONFIG_CONST_COMMAND_NAME_FVM}"
        func_build_command="${CONFIG_CONST_COMMAND_NAME_FLUTTER} build ${func_subcommand} --${func_param_build_config_type}"

    else

        func_build_command_name="${CONFIG_CONST_COMMAND_NAME_FLUTTER}"
        func_build_command="build ${func_subcommand} --${func_param_build_config_type}"

    fi

    # 若有 build_name
    if [ -n "${this_shell_config_optional_build_name}" ]; then
        func_build_command="${func_build_command} --${CONFIG_CONST_BUILD_PARAM_KEY_BUILD_NAME} ${this_shell_config_optional_build_name}"
    fi

    # 若有 build_number
    if [ -n "${this_shell_config_optional_build_number}" ]; then
        func_build_command="${func_build_command} --${CONFIG_CONST_BUILD_PARAM_KEY_BUILD_NUMBER} ${this_shell_config_optional_build_number}"
    fi

    # 若有 flavor
    if [ -n "${this_shell_config_optional_flavor}" ]; then
        func_build_command="${func_build_command} --${CONFIG_CONST_BUILD_PARAM_KEY_FLAVOR}=${this_shell_config_optional_flavor}"
    fi

    # 若有 dart-define
    if [ -n "${this_shell_dart_def_part_of_command}" ]; then
        func_build_command="${func_build_command} ${this_shell_dart_def_part_of_command}"
    fi

    # ===> OutputFile 設定 <===
    # 設定基本的輸出資料夾名稱格式。
    local func_build_folder_name

    local func_build_seperator="-"

    # 若有 prefix file name
    append_dest_string_from_source_string_with_separator "${func_title_log}" \
        func_build_folder_name this_shell_config_optional_prefix_file_name "${func_build_seperator}"

    # 若有 flavor
    append_dest_string_from_source_string_with_separator "${func_title_log}" \
        func_build_folder_name this_shell_config_optional_flavor "${func_build_seperator}"

    # 若有 config type
    append_dest_string_from_source_string_with_separator "${func_title_log}" \
        func_build_folder_name func_param_build_config_type "${func_build_seperator}"

    # 若有 build_name
    append_dest_string_from_source_string_with_separator "${func_title_log}" \
        func_build_folder_name this_shell_config_optional_build_name "${func_build_seperator}"

    # 若有 build_number
    append_dest_string_from_source_string_with_separator "${func_title_log}" \
        func_build_folder_name this_shell_config_optional_build_number "${func_build_seperator}"

    # 若有 dart-define
    append_dest_string_from_source_string_with_separator "${func_title_log}" \
        func_build_folder_name this_shell_dart_def_part_of_file_name "${func_build_seperator}"

    # 補上 時間戳記
    func_build_folder_name="${func_build_folder_name}-$(date "+%Y%m%d%H%M")"

    # 設定要輸出的資料夾，原有的輸出目錄，補上檔名 (尚未加上副檔名) 當子資料夾。
    local func_output_folder=${this_shell_config_required_paths_output}/${func_build_folder_name}

    # 確保要輸出的的資料夾存在。
    mkdir -p ${func_output_folder}
    
    # 若有 混淆 功能 (obfuscate)，測試中，暫時寫死
    # e.g. flutter build apk --obfuscate --split-debug-info=/<project-name>/<directory> --extra-gen-snapshot-options=--save-obfuscation-map=/<your-path>
    if [ ${func_param_build_config_type} = "${CONFIG_CONST_BUILD_CONFIG_TYPE_RELEASE}" ]; then

        # TODO: 有指定輸出資料夾，則以指定資料夾為主。
        local func_debug_info_folder="${func_output_folder}/${CONFIG_CONST_EXPORTED_DEFAULT_OBFUSCATE_SPLIT_DEBUG_INFO_FOLDER_NAME}"
        mkdir -p "${func_debug_info_folder}"

        # TODO: 有指定輸出檔案，則以指定輸出檔案為主。
        func_build_command="${func_build_command} --${CONFIG_CONST_BUILD_PARAM_KEY_OBFUSCATE} --${CONFIG_CONST_BUILD_PARAM_KEY_SPLIT_DEBUG_INFO}=${func_debug_info_folder} --${CONFIG_CONST_BUILD_PARAM_KEY_OBFUSCATE_SAVE_MAP_PATH}=${func_debug_info_folder}/${CONFIG_CONST_EXPORTED_DEFAULT_OBFUSCATE_SAVE_MAP_FILE_NAME}"

    fi

    # ===> Origin build output 設定 <===
    local func_origin_build_app_folder="build/ios/archive"
    local func_origin_archive_name

    # 若有 flavor
    if [ -n "${this_shell_config_optional_flavor}" ]; then
        func_origin_archive_name="${this_shell_config_optional_flavor}.xcarchive"
    else
        func_origin_archive_name="Runner.xcarchive"
    fi

    # sample 輸出路徑: (flutter build ipa)
    # - build/ios/archive/[flavor].xcarchive
    func_origin_build_app_folder="${func_origin_build_app_folder}/${func_origin_archive_name}"

    # ===> report note - init 設定 <===
    echo >>"${this_shell_report_note_file}"
    echo "---" >>"${this_shell_report_note_file}"
    echo >>"${this_shell_report_note_file}"
    echo "## [${func_name}] ${func_build_folder_name}/${func_origin_archive_name}" >>"${this_shell_report_note_file}"
    echo >>"${this_shell_report_note_file}"
    echo "- command line :" >>"${this_shell_report_note_file}"
    echo >>"${this_shell_report_note_file}"
    echo "  \`\`\`shell" >>"${this_shell_report_note_file}"
    echo "    ${func_build_command_name} ${func_build_command}" >>"${this_shell_report_note_file}"
    echo "  \`\`\`" >>"${this_shell_report_note_file}"

    # ===> build ipa <===
    echo "${func_title_log} ===> build ${func_subcommand} <==="
    echo "${func_title_log} ${func_build_command_name} ${func_build_command}"
    ${func_build_command_name} ${func_build_command}

    # check result - build ipa
    check_result_if_fail_then_change_folder "${func_title_log}" "$?" "!!! ~ ${func_build_command_name} ${func_build_command} => fail ~ !!!" "${this_shell_old_path}"

    # ===> zip Payload to destination folder <===
    if [ -d ${func_origin_build_app_folder} ]; then

        mv -v "${this_shell_flutter_work_path}/${func_origin_build_app_folder}" "${func_output_folder}"

        # check result - mv iOS archive
        check_result_if_fail_then_change_folder "${func_title_log}" "$?" "!!! ~ mv -v iOS archive => fail ~ !!!" "${this_shell_old_path}"

        echo "${func_title_log} 打包 ${func_subcommand} 很順利 😄"
        say "${func_title_log} 打包 ${func_subcommand} 成功"

    else

        echo "${func_title_log} 遇到報錯了 😭, 打開 Xcode 查找錯誤原因"
        say "${func_title_log} 打包 ${func_subcommand} 失敗"

        # check result - copy ios
        check_result_if_fail_then_change_folder "${func_title_log}" "100" "!!! ~ Not found ${func_origin_build_app_folder} => fail ~ !!!" "${this_shell_old_path}"
    fi

    # ===> report note - final 設定 <===
    # ===> 輸出 全部的產出時間統計 <===
    local func_total_time=$((${SECONDS} - ${func_temp_seconds}))
    echo >>"${this_shell_report_note_file}"
    echo "- Elapsed time: ${func_total_time}s" >>"${this_shell_report_note_file}"

    echo
    echo "${func_title_log} ||==========> ${func_subcommand} : End <==========|| Elapsed time: ${func_total_time}s"
    echo

}
### ==================== ipa : End ====================

### ==================== web : Begin ====================
# @brief exported web 部分 。
function export_web() {

    local func_title_log="${this_shell_title_log} *** function [${FUNCNAME[0]}] -"

    # 暫存此區塊的起始時間。
    local func_temp_seconds=${SECONDS}
    local func_subcommand=${this_shell_subcommand_info_web[0]}

    echo
    echo "${func_title_log} ||==========> ${func_subcommand} : Begin <==========||"

    export_notyet_support_subcommand ${func_subcommand}

    echo "${func_title_log} ||==========> ${func_subcommand} : End <==========|| Elapsed time: $((${SECONDS} - ${func_temp_seconds}))s"
    echo
}
### ==================== web : End ====================
## ================================== export function section : End ==================================

## ================================== prcess function section : Begin ==================================
# ============= This is separation line =============
# @brief function : [程序] 此 shell 的初始化。
function process_init() {

    # 計時，實測結果不同 shell 不會影響，各自有各自的 SECONDS。
    SECONDS=0

    # 此 shell 的 dump log title.
    local file_name=$(basename $0)
    this_shell_title_name="${file_name%.*}"
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

    # 不確定是否使用者都有使用 config_tools.sh 產生 build config file， 再來呼叫 exported.sh
    # 保險起見， include config_const.sh
    # include config_const.sh for config_tools.sh using export Environment Variable。
    echo
    echo "${this_shell_title_log} include config_const.sh"
    . "${func_shell_work_path}"/config_const.sh

    # include general function
    echo
    echo "${this_shell_title_log} include general function"
    . "${func_shell_work_path}"/../general_const.sh
    . "${func_shell_work_path}"/../general_tools.sh

    # include parse_yaml function
    echo
    echo "${this_shell_title_log} include parse_yaml function"

    # 同樣在 scm.tools 專案下的相對路徑。
    . "${func_shell_work_path}"/../../../submodules/bash-yaml/script/yaml.sh

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

    # set input param variable
    this_shell_param_build_config_file="${1}"

    # check input parameters
    check_input_param "${this_shell_title_log}" this_shell_param_build_config_file "${this_shell_param_build_config_file}"

    echo
    echo "${this_shell_title_log} ============= Param : Begin ============="
    echo "${this_shell_title_log} this_shell_param_build_config_file : ${this_shell_param_build_config_file}"
    echo "${this_shell_title_log} ============= Param : End ============="
    echo

    this_shell_report_note_file="${this_shell_param_build_config_file}.report.md"
}

# ============= This is separation line =============
# @brief function : [程序] Toggle Feature 設定。
function process_deal_toggle_feature() {

    # 是否開啟 dump set 內容，當 parse build config file 時，會去判斷。
    this_shell_toogle_feature_is_dump_set_when_parse_build_config_file="${GENERAL_CONST_DISABLE_FLAG}"

    # build configutation type : 編譯組態設定，之後視情況是否要開放
    # 依據 flutter build ， 有 debug ， profile ， release，
    # 可參考 config_const.sh 中的 CONFIG_CONST_BUILD_CONFIG_TYPE_[XXX]
    this_shell_toogle_feature_default_build_config_type="${CONFIG_CONST_BUILD_CONFIG_TYPE_RELEASE}"

    echo
    echo "${this_shell_title_log} ============= Toogle Feature : Begin ============="
    echo "${this_shell_title_log} this_shell_toogle_feature_is_dump_set_when_parse_build_config_file : ${this_shell_toogle_feature_is_dump_set_when_parse_build_config_file}"
    echo "${this_shell_title_log} this_shell_toogle_feature_default_build_config_type : ${this_shell_toogle_feature_default_build_config_type}"
    echo "${this_shell_title_log} ============= Toogle Feature : End ============="
    echo

}

# ============= This is separation line =============
# @brief function : [程序] SubcommandInfo 的初始化。
function process_init_subcommand_info() {

    # 設定目前支援的 subcomand
    # 搭配 flutter build 中的 subcommands，
    #
    # 此次需要編譯來源:
    # this_shell_config_required_subcommands=([0]="aar" [1]="apk" [2]="appbundle" [3]="bundle" [4]="ios" [5]="ios-framework")
    #
    # SubcommandInfo :
    # - 規則 :
    #   - [0]: build subcommand name。
    #   - [1]: 是否要執行 (isExcute)。 default : "${GENERAL_CONST_DISABLE_FLAG}"。
    #
    # 目前只支援 apk 及 ios，之後視情況新增。
    this_shell_subcommand_info_aar=("${CONFIG_CONST_SUBCOMMAND_AAR}" "${GENERAL_CONST_DISABLE_FLAG}")
    this_shell_subcommand_info_apk=("${CONFIG_CONST_SUBCOMMAND_APK}" "${GENERAL_CONST_DISABLE_FLAG}")
    this_shell_subcommand_info_appbundle=("${CONFIG_CONST_SUBCOMMAND_APPBUNDLE}" "${GENERAL_CONST_DISABLE_FLAG}")
    this_shell_subcommand_info_bundle=("${CONFIG_CONST_SUBCOMMAND_BUNDLE}" "${GENERAL_CONST_DISABLE_FLAG}")
    this_shell_subcommand_info_ios=("${CONFIG_CONST_SUBCOMMAND_IOS}" "${GENERAL_CONST_DISABLE_FLAG}")
    this_shell_subcommand_info_ios_framework=("${CONFIG_CONST_SUBCOMMAND_IOS_FRAMEWORK}" "${GENERAL_CONST_DISABLE_FLAG}")
    this_shell_subcommand_info_ipa=("${CONFIG_CONST_SUBCOMMAND_IPA}" "${GENERAL_CONST_DISABLE_FLAG}")
    this_shell_subcommand_info_web=("${CONFIG_CONST_SUBCOMMAND_WEB}" "${GENERAL_CONST_DISABLE_FLAG}")
}

# ============= This is separation line =============
# @brief function : [程序] 剖析 build config。
function process_parse_build_config() {

    # 判斷 build config file
    # 字串是否不為空。 (a non-empty string)
    if [ -n "${this_shell_param_build_config_file}" ]; then

        echo
        echo "${this_shell_title_log} ============= parse build config file : Begin ============="

        # parse build config file
        echo "${this_shell_title_log} 將剖析 Build Config File 來做細微的設定。"

        create_variables "${this_shell_param_build_config_file}" "this_shell_config_"

        # 開啟可以抓到此 shell 目前有哪些設定值。
        if [ ${this_shell_toogle_feature_is_dump_set_when_parse_build_config_file} = "${GENERAL_CONST_ENABLE_FLAG}" ]; then
            set >${this_shell_param_build_config_file}_BeforeParseConfig.temp.log
        fi

        # parse required section
        parse_reruired_section

        # parse report path section
        parse_report_path_section

        # parse build config type section
        parse_build_config_type_section

        # parse dart define section
        parse_dart_define_section

        # 開啟可以抓到此 shell 目前有哪些設定值。
        if [ ${this_shell_toogle_feature_is_dump_set_when_parse_build_config_file} = "${GENERAL_CONST_ENABLE_FLAG}" ]; then
            set >${this_shell_param_build_config_file}_AfterParseConfig.temp.log
        fi

        echo "${this_shell_title_log} ============= parse build config file : End ============="
        echo

        # FIXME
        # exit 1
    fi

}

# ============= This is separation line =============
# @brief function : [程序] 處理路徑相關 (包含 flutter work path)。
function process_deal_paths() {

    # 切換到 config file 設定的 flutter project work path: 為 flutter 專案的工作目錄 shell 目錄 (之後會切回到原有呼叫的目錄)
    change_to_directory "${this_shell_title_log}" "${this_shell_config_required_paths_work}"
    this_shell_flutter_work_path=$(pwd)

    echo
    echo "${this_shell_title_log} //========== dump paths : Begin ==========//"
    echo "${this_shell_title_log} this_shell_old_path                      : ${this_shell_old_path}"
    echo "${this_shell_title_log} this_shell_work_path               : ${this_shell_work_path}"
    echo "${this_shell_title_log} this_shell_config_required_paths_work   : ${this_shell_config_required_paths_work}"
    echo "${this_shell_title_log} this_shell_flutter_work_path             : ${this_shell_flutter_work_path}"
    echo "${this_shell_title_log} this_shell_config_required_paths_output : ${this_shell_config_required_paths_output}"
    echo "${this_shell_title_log} current path                          : $(pwd)"
    echo "${this_shell_title_log} //========== dump paths : End ==========//"
}

# ============= This is separation line =============
# @brief function : [程序] 清除緩存 (之前編譯的暫存檔)。
function process_clean_cache() {

    # 以 this_shell_flutter_work_path 為工作目錄來執行
    # 先期準備，刪除舊的資料

    echo "${this_shell_title_log} 刪除 build"
    find . -d -name "build" | xargs rm -rf

    echo "${this_shell_title_log} ${CONFIG_CONST_COMMAND_NAME_FLUTTER} clean"
    ${CONFIG_CONST_COMMAND_NAME_FLUTTER} clean
}

# ============= This is separation line =============
# call - [程序] 建立 report note 初始化部分。
function process_create_report_note_init() {

    echo "# Report Note" >>"${this_shell_report_note_file}"
    echo >>"${this_shell_report_note_file}"
    echo "---" >>"${this_shell_report_note_file}"
    echo >>"${this_shell_report_note_file}"
    echo "## Base info" >>"${this_shell_report_note_file}"
    echo >>"${this_shell_report_note_file}"
    echo "- Subject : report info by \`${this_shell_title_name}.sh\`" >>"${this_shell_report_note_file}"
    echo >>"${this_shell_report_note_file}"
    echo "- BuildConfigFile :" >>"${this_shell_report_note_file}"
    echo >>"${this_shell_report_note_file}"
    echo "  > ${this_shell_param_build_config_file}" >>"${this_shell_report_note_file}"
}

# ============= This is separation line =============
# @brief function : [程序] 執行 build subcommands。
# @details : 依照 build config 的設定來 執行 build subcommand。
function process_execute_build_sumcommands() {

    # 判斷是否要出版 aar
    check_ok_then_excute_command "${this_shell_title_log}" ${this_shell_subcommand_info_aar[1]} export_aar

    # 處理有 build config type 的 subcommands.
    # 先設定成 default 的 build config type。
    local func_build_config_types=("${this_shell_toogle_feature_default_build_config_type}")

    # 若有 build config types，則以此為主。
    # 支援的 subcommand : [apk] [appbundle] [bundle] [ios]。
    if [ -n "${this_shell_config_optional_build_config_types}" ]; then
        func_build_config_types=("${this_shell_config_optional_build_config_types[@]}")
    fi

    local func_i
    for ((func_i = 0; func_i < ${#func_build_config_types[@]}; func_i++)); do #請注意 ((   )) 雙層括號

        local func_build_config_type=${func_build_config_types[${func_i}]}

        # 要帶入的 params，使用 check_ok_then_excute_command 來判斷是否要執行，所以要用 array 方式帶入。
        local func_command_params=("${func_build_config_type}")

        # 判斷是否要出版 apk
        check_ok_then_excute_command "${this_shell_title_log}" ${this_shell_subcommand_info_apk[1]} export_apk func_command_params[@]

        # 判斷是否要出版 appbundle
        check_ok_then_excute_command "${this_shell_title_log}" ${this_shell_subcommand_info_appbundle[1]} export_appbundle func_command_params[@]

        # 判斷是否要出版 bundle
        check_ok_then_excute_command "${this_shell_title_log}" ${this_shell_subcommand_info_bundle[1]} export_bundle func_command_params[@]

        # 判斷是否要出版 ios
        check_ok_then_excute_command "${this_shell_title_log}" ${this_shell_subcommand_info_ios[1]} export_ios func_command_params[@]

        # 判斷是否要出版 ipa
        check_ok_then_excute_command "${this_shell_title_log}" ${this_shell_subcommand_info_ipa[1]} export_ipa func_command_params[@]

        # 判斷是否要出版 web : TODO: 只有支援 release，profile，之後可能還要判斷是否是合法的 BuildConfigType，是的話才處理。
        check_ok_then_excute_command "${this_shell_title_log}" ${this_shell_subcommand_info_web[1]} export_web func_command_params[@]

    done

    # 判斷是否要出版 ios_framework
    check_ok_then_excute_command "${this_shell_title_log}" ${this_shell_subcommand_info_ios_framework[1]} export_ios_framework
}

# ============= This is separation line =============
# @brief function : [程序] shell 全部完成需處理的部份。
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
# call - [程序] SubcommandInfo 的初始化。
process_init_subcommand_info

# ============= This is separation line =============
# call - [程序] 剖析 build config。
process_parse_build_config

# ============= This is separation line =============
# call - [程序] 處理路徑相關 (包含 flutter work path)。
process_deal_paths

# ============= This is separation line =============
# call - [程序] 清除緩存 (之前編譯的暫存檔)。
process_clean_cache

# ============= This is separation line =============
# call - [程序] 建立 report note 初始化部分。
process_create_report_note_init

# ============= This is separation line =============
# call - [程序] 執行 build subcommands。
process_execute_build_sumcommands

# ============= This is separation line =============
# call - [程序] shell 全部完成需處理的部份。
process_finish
## ================================== deal prcess step section : End ==================================

exit 0
