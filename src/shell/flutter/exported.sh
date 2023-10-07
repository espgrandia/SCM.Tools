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
# - $1 : thisShell_Param_BuildConfigFile="[專案路徑]/[scm]/output/buildConfig.yaml" : 設定編譯的 config 功能檔案 [需帶完整路徑].
#
#   - 內容為協議好的格式，只是做成可彈性設定的方式，可選項目，沒有則以基本編譯。
#
#   - 目前 exported.sh 支援的功能，在 configTools.sh 會有對應函式可以設定到 buildConfig.yaml 中。
#
#   - sample file : buildConfig.yaml
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
# - const define : "Y" 或 "N" 改使用 "${GENERAL_CONST_ENABLE_FLAG}" 或 "${GENERAL_CONST_DISABLE_FLAG}" 來判斷 ， 定義在 generalConst.sh
#
# ---
#
# Toggle Feature (切換功能) 說明:
#
# - thisShell_ToogleFeature_IsDumpSet_When_Parse_BuildConfigFile="${GENERAL_CONST_ENABLE_FLAG}" => e.g. "${GENERAL_CONST_ENABLE_FLAG}" 或 "${GENERAL_CONST_DISABLE_FLAG}"
#   - 是否開啟 dump set 內容，當 parse build config file 時，會去判斷。
#   - 上傳版本會是關閉狀態，若需要測試時，自行打開。
#
# - thisShell_ToogleFeature_DefaultBuildConfigType=release
#   - build configutation type : 編譯組態設定，之後視情況是否要開放
#   - 依據 flutter build version : 有 debug ， profile ， release 三種方式
#   - 可參考 configTools.sh 中的 configConst_BuildConfigType_xxx。
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
# thisShell_Config_xxx 說明 :
#
# - 來源 : 來自於 build config 轉換成的 shell 內部參數。
#   經由讀取 build config file (對應於 thisShell_Param_BuildConfigFile 內容) 來處理，
#   細部說明可參考 configTools.sh
#
# - required :
#
#   - thisShell_Config_required_paths_work
#     flutter project 工作目錄。
#
#   - thisShell_Config_required_paths_output
#     產出內容的輸出路徑。
#
#   - thisShell_Config_required_subcommands=([0]="aar" [1]="apk" [2]="appbundle" [3]="bundle" [4]="ios" [5]="ios-framework")
#     build subcommands，為此次需要編譯的模式為哪一些。
#
# ---
#
# - optional :
#
#   - report_path :
#     - thisShell_Config_optional_report_path :
#       exported.sh 額外會用到的參數，指定 report file path (含檔名)。
#       為 markdown 語法撰寫，沒設定會有預設檔案名稱。
#
# - optional :
#
#   - build_name :
#     - thisShell_Config_optional_build_name :
#       - [build_name] : build-name 會用到的內容，對應於 flutter build 的 build-name 參數
#       - support subcommands: apk， appbundle， ios
#
# - optional :
#
#   - build_number :
#     - thisShell_Config_optional_build_number :
#       - [build_number] : build-number 會用到的內容，對應於 flutter build 的 build-number 參數
#       - support subcommands: aar， apk， appbundle， bundle， ios
#
# ---
#
# - optional :
#
#   - build_config_types :
#     - thisShell_Config_optional_build_config_types :
#       build config type (like as : debug, profile, release)
#
# ---
#
# - optional :
#
#   - dart-define
#
#    - thisShell_Config_optional_dart_define_separator
#      為要分隔符號
#      => e.g. "+"
#
#    - thisShell_Config_optional_dart_define_defines
#      要設定到 dart-define 的內容，為 list 型態。
#      => e.g. (gitHash+920f6fc envName+dev)
#
# ---
#
# - optional :
#
#   - target_platform :
#     - thisShell_Config_optional_target_platform :
#       對應於 flutter build 的 target-platform 參數。
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
#   - buildConfig function section :
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

## ================================== buildConfig function section : Begin ==================================
# ============= This is separation line =============
# @brief function : 處理並設定單一的 subcommand info .
# @detail : 簡易函式，不再處理細節的判斷，為保持正確性，參數請自行帶上 ""。
#   - 拆解成獨立函式，但是內容跟此 shell 有高度相依，只是獨立函式容易閱讀。
#
# @param $1: 需要驗證的 subcommand，內容來自於 build config => e.g. "${func_subcommand}" or "aar" ...
# @param $2: SubcommandInfo 中的 `name`。 thisShell_SubcommandInfo_xxx[0]。
#   => e.g. ${thisShell_SubcommandInfo_aar[0]} : aar
# @param $3: 要設定的參數，對應於 SubcommandInfo 中的 `是否要執行 (isExcute)`。 thisShell_SubcommandInfo_xxx[1]
#   => e.g. thisShell_SubcommandInfo_aar[1] .
#
# @sa : SubcommandInfo 說明可看 shell 上方的說明區塊。
#
# @TODO: 目前 SubcommandInfo 無法用 array 方式帶入，尚未測試成功，所以先分開參數帶入，之後可找時間另外找方法測試可行性。
#
# e.g. => dealSumcommandInfo "${func_subcommand}" "${thisShell_SubcommandInfo_aar[0]}" thisShell_SubcommandInfo_aar[1]
function dealSumcommandInfo() {

    local func_title_log="*** function [${FUNCNAME[0]}] -"
    local func_param_subcommand=$1
    local func_param_sumcommand_info_name=$2

    # echo "${func_title_log} Before func_param_subcommand : ${func_param_subcommand} ***"
    # echo "${func_title_log} Before func_param_sumcommand_info_name : ${func_param_sumcommand_info_name} ***"
    # echo "${func_title_log} Before func_SubcommandInfo_IsExcute : $(eval echo \$${3}) ***"

    # 判斷是否為 要處理的 command (subcommand name 是否相同) .
    if [ ${func_param_subcommand} = ${func_param_sumcommand_info_name} ]; then
        eval ${3}="${GENERAL_CONST_ENABLE_FLAG}"
    fi

    # echo "${func_title_log} func_param_subcommand : ${func_param_subcommand} ***"
    # echo "${func_title_log} Before func_param_sumcommand_info_name : ${func_param_sumcommand_info_name} ***"
    # echo "${func_title_log} func_SubcommandInfo_IsExcute : $(eval echo \$${3}) ***"
}

# ============= This is separation line =============
# @brief function : 剖析 required 部分 。
#        如 : version，subcommands。
# @detail : 簡易函式，不再處理細節的判斷，為保持正確性，參數請自行帶上 ""。
#   - 拆解成獨立函式，但是內容跟此 shell 有高度相依，只是獨立函式容易閱讀。
function parseReruiredSection() {

    echo
    echo "${thisShell_Title_Log} ============= parse required section : Begin ============="

    # check input parameters
    check_input_param "${thisShell_Title_Log}" thisShell_Config_required_paths_work "${thisShell_Config_required_paths_work}"
    check_input_param "${thisShell_Title_Log}" thisShell_Config_required_paths_output "${thisShell_Config_required_paths_output}"
    check_input_param "${thisShell_Title_Log}" thisShell_Config_required_subcommands "${thisShell_Config_required_subcommands[@]}"

    echo
    echo "${thisShell_Title_Log} ============= Param : Begin ============="
    echo "${thisShell_Title_Log} thisShell_Config_required_paths_work : ${thisShell_Config_required_paths_work}"
    echo "${thisShell_Title_Log} thisShell_Config_required_paths_output : ${thisShell_Config_required_paths_output}"
    echo "${thisShell_Title_Log} thisShell_Config_required_subcommands : ${thisShell_Config_required_subcommands[@]}"
    echo "${thisShell_Title_Log} ============= Param : End ============="
    echo

    local func_i
    for ((func_i = 0; func_i < ${#thisShell_Config_required_subcommands[@]}; func_i++)); do #請注意 ((   )) 雙層括號

        local func_subcommand=${thisShell_Config_required_subcommands[${func_i}]}

        # 判斷是否為 aar
        dealSumcommandInfo "${func_subcommand}" "${thisShell_SubcommandInfo_aar[0]}" thisShell_SubcommandInfo_aar[1]

        # 判斷是否為 apk
        dealSumcommandInfo "${func_subcommand}" "${thisShell_SubcommandInfo_apk[0]}" thisShell_SubcommandInfo_apk[1]

        # 判斷是否為 appbundle
        dealSumcommandInfo "${func_subcommand}" "${thisShell_SubcommandInfo_appbundle[0]}" thisShell_SubcommandInfo_appbundle[1]

        # 判斷是否為 bundle
        dealSumcommandInfo "${func_subcommand}" "${thisShell_SubcommandInfo_bundle[0]}" thisShell_SubcommandInfo_bundle[1]

        # 判斷是否為 ios
        dealSumcommandInfo "${func_subcommand}" "${thisShell_SubcommandInfo_ios[0]}" thisShell_SubcommandInfo_ios[1]

        # 判斷是否為 ios_framework
        dealSumcommandInfo "${func_subcommand}" "${thisShell_SubcommandInfo_ios_framework[0]}" thisShell_SubcommandInfo_ios_framework[1]

        # 判斷是否為 ipa
        dealSumcommandInfo "${func_subcommand}" "${thisShell_SubcommandInfo_ipa[0]}" thisShell_SubcommandInfo_ipa[1]

        # 判斷是否為 web
        dealSumcommandInfo "${func_subcommand}" "${thisShell_SubcommandInfo_web[0]}" thisShell_SubcommandInfo_web[1]

    done

    # dump support sumcommand info
    echo "${thisShell_Title_Log} thisShell_SubcommandInfo_aar           : ${thisShell_SubcommandInfo_aar[@]}"
    echo "${thisShell_Title_Log} thisShell_SubcommandInfo_apk           : ${thisShell_SubcommandInfo_apk[@]}"
    echo "${thisShell_Title_Log} thisShell_SubcommandInfo_appbundle     : ${thisShell_SubcommandInfo_appbundle[@]}"
    echo "${thisShell_Title_Log} thisShell_SubcommandInfo_bundle        : ${thisShell_SubcommandInfo_bundle[@]}"
    echo "${thisShell_Title_Log} thisShell_SubcommandInfo_ios           : ${thisShell_SubcommandInfo_ios[@]}"
    echo "${thisShell_Title_Log} thisShell_SubcommandInfo_ios_framework : ${thisShell_SubcommandInfo_ios_framework[@]}"
    echo "${thisShell_Title_Log} thisShell_SubcommandInfo_ipa           : ${thisShell_SubcommandInfo_ipa[@]}"
    echo "${thisShell_Title_Log} thisShell_SubcommandInfo_web           : ${thisShell_SubcommandInfo_web[@]}"

    echo "${thisShell_Title_Log} ============= required section : End ============="
    echo

}

# ============= This is separation line =============
# @brief function : 剖析 ReportPath 部分 。
# @detail : 簡易函式，不再處理細節的判斷，為保持正確性，參數請自行帶上 ""。
#   - 拆解成獨立函式，但是內容跟此 shell 有高度相依，只是獨立函式容易閱讀。
#   - 只檢查是否為合法設定。
function parseReportPathSection() {

    # build config 有設定則以設定為主。
    if [ -n "${thisShell_Config_optional_report_path}" ]; then
        thisShell_ReportNoteFile=${thisShell_Config_optional_report_path}
    fi

}

# ============= This is separation line =============
# @brief function : 剖析 BuildConfigType 部分 。
# @detail : 簡易函式，不再處理細節的判斷，為保持正確性，參數請自行帶上 ""。
#   - 拆解成獨立函式，但是內容跟此 shell 有高度相依，只是獨立函式容易閱讀。
#   - 只檢查是否為合法設定。
function parseBuildConfigTypeSection() {

    if [ -n "${thisShell_Config_optional_build_config_types}" ]; then

        local func_SrcList=("${configConst_BuildConfigType_Debug}" "${configConst_BuildConfigType_Profile}" "${configConst_BuildConfigType_Release}")

        local func_i
        for ((func_i = 0; func_i < ${#thisShell_Config_optional_build_config_types[@]}; func_i++)); do #請注意 ((   )) 雙層括號

            local func_Check_Value="${thisShell_Config_optional_build_config_types[${func_i}]}"

            check_legal_val_in_list__if__result_fail_then_change_folder "${thisShell_Title_Log}" \
                "${func_Check_Value}" func_SrcList[@] "${thisShell_OldPath}"

        done

    fi
}

# ============= This is separation line =============
# @brief function : 剖析 dart-define 。
# @detail : 簡易函式，不再處理細節的判斷，為保持正確性，參數請自行帶上 ""。
#   - 拆解成獨立函式，但是內容跟此 shell 有高度相依，只是獨立函式容易閱讀。
function parseDartDefine() {

    # 判斷是否有 dart-define 的設定:
    if [ -n "${thisShell_Config_optional_dart_define_defines}" ] && [ -n "${thisShell_Config_optional_dart_define_separator}" ]; then

        echo
        echo "${thisShell_Title_Log} ============= parse "${configConst_BuildParam_Key_DartDefine}" : Begin ============="

        # check input parameters
        check_input_param "${thisShell_Title_Log}" thisShell_Config_optional_dart_define_defines "${thisShell_Config_optional_dart_define_defines[@]}"
        check_input_param "${thisShell_Title_Log}" thisShell_Config_optional_dart_define_separator "${thisShell_Config_optional_dart_define_separator}"

        echo
        echo "${thisShell_Title_Log} ============= Param : Begin ============="
        echo "${thisShell_Title_Log} thisShell_Config_optional_dart_define_defines : ${thisShell_Config_optional_dart_define_defines[@]}"
        echo "${thisShell_Title_Log} thisShell_Config_optional_dart_define_separator : ${thisShell_Config_optional_dart_define_separator}"
        echo "${thisShell_Title_Log} ============= Param : End ============="
        echo

        local i
        for ((i = 0; i < ${#thisShell_Config_optional_dart_define_defines[@]}; i++)); do #請注意 ((   )) 雙層括號

            local aDefine=${thisShell_Config_optional_dart_define_defines[$i]}

            local aKey
            local aVal

            split_string_to_pair "${thisShell_Title_Log}" "${aDefine}" "${thisShell_Config_optional_dart_define_separator}" aKey aVal

            # 第一次，尚未設定。
            if [ -z "${thisShell_DartDef_PartOf_Command}" ] && [ -z "${thisShell_DartDef_PartOf_FileName}" ]; then

                thisShell_DartDef_PartOf_Command="--"${configConst_BuildParam_Key_DartDefine}"=${aKey}=${aVal}"
                thisShell_DartDef_PartOf_FileName="${aKey}_${aVal}"

            else

                thisShell_DartDef_PartOf_Command="${thisShell_DartDef_PartOf_Command} --"${configConst_BuildParam_Key_DartDefine}"=${aKey}=${aVal}"
                thisShell_DartDef_PartOf_FileName="${thisShell_DartDef_PartOf_FileName}-${aKey}_${aVal}"

            fi

        done

        # check input parameters
        check_input_param "${thisShell_Title_Log}" thisShell_DartDef_PartOf_Command "${thisShell_DartDef_PartOf_Command[@]}"
        check_input_param "${thisShell_Title_Log}" thisShell_DartDef_PartOf_FileName "${thisShell_DartDef_PartOf_FileName}"

        echo "${thisShell_Title_Log} thisShell_DartDef_PartOf_Command  : ${thisShell_DartDef_PartOf_Command}"
        echo "${thisShell_Title_Log} thisShell_DartDef_PartOf_FileName : ${thisShell_DartDef_PartOf_FileName}"

        echo "${thisShell_Title_Log} ============= parse "${configConst_BuildParam_Key_DartDefine}" : End ============="
        echo

    fi
}

## ================================== buildConfig function section : End ==================================

## ================================== export function section : Begin ==================================
### ==================== NotyetSupportSubcommand : Begin ====================
# @brief 尚未支援的 subcommand 的通用函式
# @param $1 : command name
function export_NotyetSupportSubcommand() {

    local func_title_log="${thisShell_Title_Log} *** function [${FUNCNAME[0]}] -"

    # 暫存此區塊的起始時間。
    local func_Subcommand=${1}

    echo "${GENERAL_CONST_COLORS_BBLACK}${GENERAL_CONST_COLORS_RED}${GENERAL_CONST_COLORS_ON_CYAN}${func_title_log} OPPS!! Notyet support this subcommand ( ${func_Subcommand} ).\n    Please check your demand or make request that modify exported.sh to support this subcommand ( ${func_Subcommand} ).\n    Error !!! ***${GENERAL_CONST_COLORS_COLOR_OFF}"

    check_result_if_fail_then_change_folder "${func_title_log}" "50" "!!! ~ OPPS!! Notyet support this subcommand ( ${func_Subcommand} ).\n    Please check your demand or make request that modify exported.sh to support this subcommand ( ${func_Subcommand} ).\n    Error !!! ***" "${thisShell_OldPath}"
}
### ==================== NotyetSupportSubcommand : End ====================

### ==================== aar : Begin ====================
# @brief exported aar 部分 。
function export_aar() {

    local func_title_log="${thisShell_Title_Log} *** function [${FUNCNAME[0]}] -"

    # 暫存此區塊的起始時間。
    local func_temp_seconds=${SECONDS}
    local func_Subcommand=${thisShell_SubcommandInfo_aar[0]}

    echo
    echo "${thisShell_Title_Log} ||==========> ${func_Subcommand} : Begin <==========||"

    export_NotyetSupportSubcommand ${func_Subcommand}

    echo "${thisShell_Title_Log} ||==========> ${func_Subcommand} : End <==========|| Elapsed time: $((${SECONDS} - ${func_temp_seconds}))s"
    echo
}
### ==================== aar : End ====================

### ==================== apk : Begin ====================
# @brief exported apk 部分 。
# @param ${1}: buildConfigType :  有 debug ， profile ， release 。
function export_apk() {

    local func_name=${FUNCNAME[0]}
    local func_title_log="${thisShell_Title_Log} *** function [${func_name}] -"

    # 暫存此區塊的起始時間。
    local func_temp_seconds=${SECONDS}
    local func_Subcommand=${thisShell_SubcommandInfo_apk[0]}

    echo
    echo "${func_title_log} ||==========> ${func_Subcommand} : Begin <==========||"

    local func_param_build_config_type="${1}"

    # check input parameters
    check_input_param "${func_title_log}" func_param_build_config_type "${func_param_build_config_type}"

    echo
    echo "${func_title_log} ============= Param : Begin ============="
    echo "${func_title_log} func_param_build_config_type : ${func_param_build_config_type}"
    echo "${func_title_log} ============= Param : End ============="
    echo

    echo "${func_title_log} 開始打包 ${func_Subcommand}"

    # ===> Command 設定 <===
    # 設定基本的 command 內容. [subcommand] [config type]
    local func_build_command_name
    local func_build_command

	# 判斷 thisShell_Config_flutter_run_config_is_enable_fvm_mode
	if [ ${thisShell_Config_optional_is_enable_fvm_mode} = "${GENERAL_CONST_ENABLE_FLAG}" ]; then

		func_build_command_name="${configConst_CommandName_Fvm}"
		func_build_command="${configConst_CommandName_Flutter} build ${func_Subcommand} --${func_param_build_config_type}"

	else

		func_build_command_name="${configConst_CommandName_Flutter}"
		func_build_command="build ${func_Subcommand} --${func_param_build_config_type}"

	fi
   
    # 若有 build_name
    if [ -n "${thisShell_Config_optional_build_name}" ]; then
        func_build_command="${func_build_command} --${configConst_BuildParam_Key_BuildName} ${thisShell_Config_optional_build_name}"
    fi

    # 若有 build_number
    if [ -n "${thisShell_Config_optional_build_number}" ]; then
        func_build_command="${func_build_command} --${configConst_BuildParam_Key_BuildNumber} ${thisShell_Config_optional_build_number}"
    fi

    # 若有 flavor
    if [ -n "${thisShell_Config_optional_flavor}" ]; then
        func_build_command="${func_build_command} --${configConst_BuildParam_Key_Flavor}=${thisShell_Config_optional_flavor}"
    fi

    # 若有 dart-define
    if [ -n "${thisShell_DartDef_PartOf_Command}" ]; then
        func_build_command="${func_build_command} ${thisShell_DartDef_PartOf_Command}"
    fi

    # 若有 target-platform
    if [ -n "${thisShell_Config_optional_target_platform}" ]; then
        func_build_command="${func_build_command} --${configConst_BuildParam_Key_TargetPlatform} ${thisShell_Config_optional_target_platform}"
    fi

    # ===> OutputFile 設定 <===
    # 設定基本的輸出檔案格式。
    local func_build_file_name

    local func_build_seperator="-"

    # 若有 prefix file name
    append_dest_string_from_source_string_with_separator "${func_title_log}" \
        func_build_file_name thisShell_Config_optional_prefix_file_name "${func_build_seperator}"

    # 若有 flavor
    append_dest_string_from_source_string_with_separator "${func_title_log}" \
        func_build_file_name thisShell_Config_optional_flavor "${func_build_seperator}"

    # 若有 config type
    append_dest_string_from_source_string_with_separator "${func_title_log}" \
        func_build_file_name func_param_build_config_type "${func_build_seperator}"

    # 若有 build_name
    append_dest_string_from_source_string_with_separator "${func_title_log}" \
        func_build_file_name thisShell_Config_optional_build_name "${func_build_seperator}"

    # 若有 build_number
    append_dest_string_from_source_string_with_separator "${func_title_log}" \
        func_build_file_name thisShell_Config_optional_build_number "${func_build_seperator}"

    # 若有 dart-define
    append_dest_string_from_source_string_with_separator "${func_title_log}" \
        func_build_file_name thisShell_DartDef_PartOf_FileName "${func_build_seperator}"

    # 補上結尾
    func_build_file_name="${func_build_file_name}-$(date "+%Y%m%d%H%M").apk"

    # ===> Origin build output 設定 <===
    local func_origin_build_file_name="build/app/outputs/apk"

    # 若有 flavor
    if [ -n "${thisShell_Config_optional_flavor}" ]; then
        func_origin_build_file_name="${func_origin_build_file_name}/${thisShell_Config_optional_flavor}/${func_param_build_config_type}/app-${thisShell_Config_optional_flavor}"
    else
        func_origin_build_file_name="${func_origin_build_file_name}/${func_param_build_config_type}/app"
    fi

    # build type
    func_origin_build_file_name="${func_origin_build_file_name}-${func_param_build_config_type}.apk"

    # ===> report note - init 設定 <===
    echo >>"${thisShell_ReportNoteFile}"
    echo "---" >>"${thisShell_ReportNoteFile}"
    echo >>"${thisShell_ReportNoteFile}"
    echo "## [${func_name}] ${func_build_file_name}" >>"${thisShell_ReportNoteFile}"
    echo >>"${thisShell_ReportNoteFile}"
    echo "- command line :" >>"${thisShell_ReportNoteFile}"
    echo >>"${thisShell_ReportNoteFile}"
    echo "  \`\`\`shell" >>"${thisShell_ReportNoteFile}"
    echo "    ${func_build_command_name} ${func_build_command}" >>"${thisShell_ReportNoteFile}"
    echo "  \`\`\`" >>"${thisShell_ReportNoteFile}"

    # ===> build apk <===
    echo "${func_title_log} ===> build ${func_Subcommand} <==="
    echo "${func_title_log} ${func_build_command_name} ${func_build_command}"
    ${func_build_command_name} ${func_build_command}

    # check result - build apk
    check_result_if_fail_then_change_folder "${func_title_log}" "$?" "!!! ~ ${func_build_command_name} ${func_build_command} => fail ~ !!!" "${thisShell_OldPath}"

    # ===> copy apk to destination folder <===
    echo "${func_title_log} ===> copy ${func_param_build_config_type} ${func_Subcommand} to output folder <==="

    cp -r "${func_origin_build_file_name}" "${thisShell_Config_required_paths_output}/${func_build_file_name}"

    # check result - copy apk
    check_result_if_fail_then_change_folder "${func_title_log}" "$?" "!!! ~ copy ${func_param_build_config_type} ${func_Subcommand} to output folder => fail ~ !!!" "${thisShell_OldPath}"

    echo "${func_title_log} 打包 ${func_Subcommand} 已經完成"
    echo "${func_title_log} output file name : ${func_build_file_name}"
    say "${func_title_log} 打包 ${func_Subcommand} 成功"

    # ===> report note - final 設定 <===
    # ===> 輸出 全部的產出時間統計 <===
    local func_total_time=$((${SECONDS} - ${func_temp_seconds}))
    echo >>"${thisShell_ReportNoteFile}"
    echo "- Elapsed time: ${func_total_time}s" >>"${thisShell_ReportNoteFile}"

    echo
    echo "${func_title_log} ||==========> ${func_Subcommand} : End <==========|| Elapsed time: ${func_total_time}s"
    echo
}
### ==================== apk : End ====================

### ==================== appbundle : Begin ====================
# @brief exported appbundle 部分 。
# @param ${1}: buildConfigType :  有 debug ， profile ， release 。
function export_appbundle() {

    local func_name=${FUNCNAME[0]}
    local func_title_log="${thisShell_Title_Log} *** function [${func_name}] -"

    # 暫存此區塊的起始時間。
    local func_temp_seconds=${SECONDS}
    local func_Subcommand=${thisShell_SubcommandInfo_appbundle[0]}

    echo
    echo "${func_title_log} ||==========> ${func_Subcommand} : Begin <==========||"

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
    local func_FirstLetter_Trans_To_Upper_For_BuildConfigType=$(echo ${func_param_build_config_type:0:1} | tr "[:lower:]" "[:upper:]")
    func_FirstLetter_Trans_To_Upper_For_BuildConfigType=${func_FirstLetter_Trans_To_Upper_For_BuildConfigType}$(echo ${func_param_build_config_type:1})

    echo
    echo "${func_title_log} ============= check value : Begin ============="
    echo "${func_title_log} func_FirstLetter_Trans_To_Upper_For_BuildConfigType : ${func_FirstLetter_Trans_To_Upper_For_BuildConfigType}"
    echo "${func_title_log} ============= check value : End ============="
    echo

    echo "${func_title_log} 開始打包 ${func_Subcommand}"

    # ===> Command 設定 <===
    # 設定基本的 command 內容. [subcommand] [config type]
    local func_build_command_name
    local func_build_command

	# 判斷 thisShell_Config_flutter_run_config_is_enable_fvm_mode
	if [ ${thisShell_Config_optional_is_enable_fvm_mode} = "${GENERAL_CONST_ENABLE_FLAG}" ]; then

		func_build_command_name="${configConst_CommandName_Fvm}"
		func_build_command="${configConst_CommandName_Flutter} build ${func_Subcommand} --${func_param_build_config_type}"

	else

		func_build_command_name="${configConst_CommandName_Flutter}"
		func_build_command="build ${func_Subcommand} --${func_param_build_config_type}"

	fi
   
    # 若有 build_name
    if [ -n "${thisShell_Config_optional_build_name}" ]; then
        func_build_command="${func_build_command} --${configConst_BuildParam_Key_BuildName} ${thisShell_Config_optional_build_name}"
    fi

    # 若有 build_number
    if [ -n "${thisShell_Config_optional_build_number}" ]; then
        func_build_command="${func_build_command} --${configConst_BuildParam_Key_BuildNumber} ${thisShell_Config_optional_build_number}"
    fi

    # 若有 flavor
    if [ -n "${thisShell_Config_optional_flavor}" ]; then
        func_build_command="${func_build_command} --${configConst_BuildParam_Key_Flavor}=${thisShell_Config_optional_flavor}"
    fi

    # 若有 dart-define
    if [ -n "${thisShell_DartDef_PartOf_Command}" ]; then
        func_build_command="${func_build_command} ${thisShell_DartDef_PartOf_Command}"
    fi

    # 若有 target-platform
    if [ -n "${thisShell_Config_optional_target_platform}" ]; then
        func_build_command="${func_build_command} --${configConst_BuildParam_Key_TargetPlatform} ${thisShell_Config_optional_target_platform}"
    fi

    # ===> OutputFile 設定 <===
    # 設定基本的輸出檔案格式。
    local func_build_file_name

    local func_build_seperator="-"

    # 若有 prefix file name
    append_dest_string_from_source_string_with_separator "${func_title_log}" \
        func_build_file_name thisShell_Config_optional_prefix_file_name "${func_build_seperator}"

    # 若有 flavor
    append_dest_string_from_source_string_with_separator "${func_title_log}" \
        func_build_file_name thisShell_Config_optional_flavor "${func_build_seperator}"

    # 若有 config type
    append_dest_string_from_source_string_with_separator "${func_title_log}" \
        func_build_file_name func_param_build_config_type "${func_build_seperator}"

    # 若有 build_name
    append_dest_string_from_source_string_with_separator "${func_title_log}" \
        func_build_file_name thisShell_Config_optional_build_name "${func_build_seperator}"

    # 若有 build_number
    append_dest_string_from_source_string_with_separator "${func_title_log}" \
        func_build_file_name thisShell_Config_optional_build_number "${func_build_seperator}"

    # 若有 dart-define
    append_dest_string_from_source_string_with_separator "${func_title_log}" \
        func_build_file_name thisShell_DartDef_PartOf_FileName "${func_build_seperator}"

    # 補上結尾
    func_build_file_name="${func_build_file_name}-$(date "+%Y%m%d%H%M").aab"

    # ===> Origin build output 設定 <===
    local func_origin_build_file_name="build/app/outputs/bundle"

    # 若有 flavor
    if [ -n "${thisShell_Config_optional_flavor}" ]; then
        
        func_origin_build_file_name="${func_origin_build_file_name}/${thisShell_Config_optional_flavor}${func_FirstLetter_Trans_To_Upper_For_BuildConfigType}/app-${thisShell_Config_optional_flavor}"
    else
        func_origin_build_file_name="${func_origin_build_file_name}/${func_FirstLetter_Trans_To_Upper_For_BuildConfigType}/app"
    fi

    # build type
    func_origin_build_file_name="${func_origin_build_file_name}-${func_param_build_config_type}.aab"

    echo "${func_title_log} ===> func_origin_build_file_name : ${func_origin_build_file_name} <==="

    # ===> report note - init 設定 <===
    echo >>"${thisShell_ReportNoteFile}"
    echo "---" >>"${thisShell_ReportNoteFile}"
    echo >>"${thisShell_ReportNoteFile}"
    echo "## [${func_name}] ${func_build_file_name}" >>"${thisShell_ReportNoteFile}"
    echo >>"${thisShell_ReportNoteFile}"
    echo "- command line :" >>"${thisShell_ReportNoteFile}"
    echo >>"${thisShell_ReportNoteFile}"
    echo "  \`\`\`shell" >>"${thisShell_ReportNoteFile}"
    echo "    ${func_build_command_name} ${func_build_command}" >>"${thisShell_ReportNoteFile}"
    echo "  \`\`\`" >>"${thisShell_ReportNoteFile}"

    # ===> build appbundle <===
    echo "${func_title_log} ===> build ${func_Subcommand} <==="
    echo "${func_title_log} ${func_build_command_name} ${func_build_command}"
    ${func_build_command_name} ${func_build_command}

    # check result - build appbundle
    check_result_if_fail_then_change_folder "${func_title_log}" "$?" "!!! ~ ${func_build_command_name} ${func_build_command} => fail ~ !!!" "${thisShell_OldPath}"

    # ===> copy aab to destination folder <===
    echo "${func_title_log} ===> copy ${func_param_build_config_type} ${func_Subcommand} to output folder <==="

    cp -r "${func_origin_build_file_name}" "${thisShell_Config_required_paths_output}/${func_build_file_name}"

    # check result - copy aab
    check_result_if_fail_then_change_folder "${func_title_log}" "$?" "!!! ~ copy ${func_param_build_config_type} ${func_Subcommand} to output folder => fail ~ !!!" "${thisShell_OldPath}"

    echo "${func_title_log} 打包 ${func_Subcommand} 已經完成"
    echo "${func_title_log} output file name : ${func_build_file_name}"
    say "${func_title_log} 打包 ${func_Subcommand} 成功"

    # ===> report note - final 設定 <===
    # ===> 輸出 全部的產出時間統計 <===
    local func_total_time=$((${SECONDS} - ${func_temp_seconds}))
    echo >>"${thisShell_ReportNoteFile}"
    echo "- Elapsed time: ${func_total_time}s" >>"${thisShell_ReportNoteFile}"

    echo
    echo "${func_title_log} ||==========> ${func_Subcommand} : End <==========|| Elapsed time: ${func_total_time}s"
    echo
}
### ==================== appbundle : End ====================

### ==================== bundle : Begin ====================
# @brief exported bundle 部分 。
# @param ${1}: buildConfigType :  有 debug ， profile ， release 。
function export_bundle() {

    local func_title_log="${thisShell_Title_Log} *** function [${FUNCNAME[0]}] -"

    # 暫存此區塊的起始時間。
    local func_temp_seconds=${SECONDS}
    local func_Subcommand=${thisShell_SubcommandInfo_bundle[0]}

    echo
    echo "${func_title_log} ||==========> ${func_Subcommand} : Begin <==========||"

    export_NotyetSupportSubcommand ${func_Subcommand}

    echo "${func_title_log} ||==========> ${func_Subcommand} : End <==========|| Elapsed time: $((${SECONDS} - ${func_temp_seconds}))s"
    echo
}
### ==================== bundle : End ====================

### ==================== ios : Begin ====================
# @brief ios 部分 。
# @param ${1}: buildConfigType :  有 debug ， profile ， release 。
function export_ios() {

    local func_name=${FUNCNAME[0]}
    local func_title_log="${thisShell_Title_Log} *** function [${func_name}] -"

    # 暫存此區塊的起始時間。
    local func_temp_seconds=${SECONDS}
    local func_Subcommand=${thisShell_SubcommandInfo_ios[0]}

    echo
    echo "${func_title_log} ||==========> ${func_Subcommand} : Begin <==========||"

    local func_param_build_config_type="${1}"

    # check input parameters
    check_input_param "${func_title_log}" func_param_build_config_type "${func_param_build_config_type}"

    echo
    echo "${func_title_log} ============= Param : Begin ============="
    echo "${func_title_log} func_param_build_config_type : ${func_param_build_config_type}"
    echo "${func_title_log} ============= Param : End ============="
    echo

    echo "${func_title_log} 開始打包 ${func_Subcommand}"

    # ===> Command 設定 <===
    # 設定基本的 command 內容. [subcommand] [config type]
    local func_build_command_name
    local func_build_command

	# 判斷 thisShell_Config_flutter_run_config_is_enable_fvm_mode
	if [ ${thisShell_Config_optional_is_enable_fvm_mode} = "${GENERAL_CONST_ENABLE_FLAG}" ]; then

		func_build_command_name="${configConst_CommandName_Fvm}"
		func_build_command="${configConst_CommandName_Flutter} build ${func_Subcommand} --${func_param_build_config_type}"

	else

		func_build_command_name="${configConst_CommandName_Flutter}"
		func_build_command="build ${func_Subcommand} --${func_param_build_config_type}"

	fi

    # 若有 build_name
    if [ -n "${thisShell_Config_optional_build_name}" ]; then
        func_build_command="${func_build_command} --${configConst_BuildParam_Key_BuildName} ${thisShell_Config_optional_build_name}"
    fi

    # 若有 build_number
    if [ -n "${thisShell_Config_optional_build_number}" ]; then
        func_build_command="${func_build_command} --${configConst_BuildParam_Key_BuildNumber} ${thisShell_Config_optional_build_number}"
    fi

    # 若有 flavor
    if [ -n "${thisShell_Config_optional_flavor}" ]; then
        func_build_command="${func_build_command} --${configConst_BuildParam_Key_Flavor}=${thisShell_Config_optional_flavor}"
    fi

    # 若有 dart-define
    if [ -n "${thisShell_DartDef_PartOf_Command}" ]; then
        func_build_command="${func_build_command} ${thisShell_DartDef_PartOf_Command}"
    fi

    # ===> OutputFile 設定 <===
    # 設定基本的輸出檔案格式。
    local func_build_file_name

    local func_build_seperator="-"

    # 若有 prefix file name
    append_dest_string_from_source_string_with_separator "${func_title_log}" \
        func_build_file_name thisShell_Config_optional_prefix_file_name "${func_build_seperator}"

    # 若有 flavor
    append_dest_string_from_source_string_with_separator "${func_title_log}" \
        func_build_file_name thisShell_Config_optional_flavor "${func_build_seperator}"

    # 若有 config type
    append_dest_string_from_source_string_with_separator "${func_title_log}" \
        func_build_file_name func_param_build_config_type "${func_build_seperator}"

    # 若有 build_name
    append_dest_string_from_source_string_with_separator "${func_title_log}" \
        func_build_file_name thisShell_Config_optional_build_name "${func_build_seperator}"

    # 若有 build_number
    append_dest_string_from_source_string_with_separator "${func_title_log}" \
        func_build_file_name thisShell_Config_optional_build_number "${func_build_seperator}"

    # 若有 dart-define
    append_dest_string_from_source_string_with_separator "${func_title_log}" \
        func_build_file_name thisShell_DartDef_PartOf_FileName "${func_build_seperator}"

    # 補上結尾
    func_build_file_name="${func_build_file_name}-$(date "+%Y%m%d%H%M").ipa"

    # ===> Origin build output 設定 <===
    local func_Origin_Build_AppFolder="build/ios/iphoneos"

    # 若有 flavor
    if [ -n "${thisShell_Config_optional_flavor}" ]; then
        func_Origin_Build_AppFolder="${func_Origin_Build_AppFolder}/${thisShell_Config_optional_flavor}.app"
    else
        func_Origin_Build_AppFolder="${func_Origin_Build_AppFolder}/Runner.app"
    fi

    # ===> report note - init 設定 <===
    echo >>"${thisShell_ReportNoteFile}"
    echo "---" >>"${thisShell_ReportNoteFile}"
    echo >>"${thisShell_ReportNoteFile}"
    echo "## [${func_name}] ${func_build_file_name}" >>"${thisShell_ReportNoteFile}"
    echo >>"${thisShell_ReportNoteFile}"
    echo "- command line :" >>"${thisShell_ReportNoteFile}"
    echo >>"${thisShell_ReportNoteFile}"
    echo "  \`\`\`shell" >>"${thisShell_ReportNoteFile}"
    echo "    ${func_build_command_name} ${func_build_command}" >>"${thisShell_ReportNoteFile}"
    echo "  \`\`\`" >>"${thisShell_ReportNoteFile}"

    # ===> build ios <===
    echo "${func_title_log} ===> build ${func_Subcommand} <==="
    echo "${func_title_log} ${func_build_command_name} ${func_build_command}"
    ${func_build_command_name} ${func_build_command}

    # check result - build ios
    check_result_if_fail_then_change_folder "${func_title_log}" "$?" "!!! ~ ${func_build_command_name} ${func_build_command} => fail ~ !!!" "${thisShell_OldPath}"

    # ===> zip Payload to destination folder <===
    if [ -d ${func_Origin_Build_AppFolder} ]; then

        # 切換到 輸出目錄，再打包才不會包到不該包的資料夾。
        change_to_directory "${func_title_log}" "${thisShell_Config_required_paths_output}"

        # 打包 ipa 的固定資料夾名稱。
        mkdir Payload

        cp -r "${thisShell_Flutter_WorkPath}/${func_Origin_Build_AppFolder}" "${thisShell_Config_required_paths_output}/Payload"

        # check result - copy iOS Payload
        check_result_if_fail_then_change_folder "${func_title_log}" "$?" "!!! ~ copy iOS Payload => fail ~ !!!" "${thisShell_OldPath}"

        # zip -r -m iOS-${func_param_build_config_type}-${func_iOS_BundleVersion}-${thisShell_Param_DartDef_Val_GitHash}-$(date "+%Y%m%d%H%M").ipa Payload
        zip -r -m ${func_build_file_name} Payload

        # check result - zip iOS Payload
        check_result_if_fail_then_change_folder "${func_title_log}" "$?" "!!! ~ zip iOS Payload => fail ~ !!!" "${thisShell_OldPath}"

        # 切換到 flutter work path
        change_to_directory "${func_title_log}" "${thisShell_Flutter_WorkPath}"

        echo "${func_title_log} 打包 ${func_Subcommand} 很順利 😄"
        say "${func_title_log} 打包 ${func_Subcommand} 成功"

    else

        echo "${func_title_log} 遇到報錯了 😭, 打開 Xcode 查找錯誤原因"
        say "${func_title_log} 打包 ${func_Subcommand} 失敗"

        # check result - copy ios
        check_result_if_fail_then_change_folder "${func_title_log}" "100" "!!! ~ Not found ${func_Origin_Build_AppFolder} => fail ~ !!!" "${thisShell_OldPath}"
    fi

    # ===> report note - final 設定 <===
    # ===> 輸出 全部的產出時間統計 <===
    local func_total_time=$((${SECONDS} - ${func_temp_seconds}))
    echo >>"${thisShell_ReportNoteFile}"
    echo "- Elapsed time: ${func_total_time}s" >>"${thisShell_ReportNoteFile}"

    echo
    echo "${func_title_log} ||==========> ${func_Subcommand} : End <==========|| Elapsed time: ${func_total_time}s"
    echo
}
### ==================== ios : End ====================

### ==================== ios_framework : Begin ====================
# @brief exported ios_framework 部分 。
function export_ios_framework() {

    local func_title_log="${thisShell_Title_Log} *** function [${FUNCNAME[0]}] -"

    # 暫存此區塊的起始時間。
    local func_temp_seconds=${SECONDS}
    local func_Subcommand=${thisShell_SubcommandInfo_ios_framework[0]}

    echo
    echo "${func_title_log} ||==========> ${func_Subcommand} : Begin <==========||"

    export_NotyetSupportSubcommand ${func_Subcommand}

    echo "${func_title_log} ||==========> ${func_Subcommand} : End <==========|| Elapsed time: $((${SECONDS} - ${func_temp_seconds}))s"
    echo
}
### ==================== ios_framework : End ====================


### ==================== ipa : Begin ====================
# @brief exported ipa 部分 。
# @param ${1}: buildConfigType :  有 debug ， profile ， release 。
function export_ipa() {

    local func_name=${FUNCNAME[0]}
    local func_title_log="${thisShell_Title_Log} *** function [${func_name}] -"

    # 暫存此區塊的起始時間。
    local func_temp_seconds=${SECONDS}
    local func_Subcommand=${thisShell_SubcommandInfo_ipa[0]}

    echo
    echo "${func_title_log} ||==========> ${func_Subcommand} : Begin <==========||"

    local func_param_build_config_type="${1}"

    # check input parameters
    check_input_param "${func_title_log}" func_param_build_config_type "${func_param_build_config_type}"

    echo
    echo "${func_title_log} ============= Param : Begin ============="
    echo "${func_title_log} func_param_build_config_type : ${func_param_build_config_type}"
    echo "${func_title_log} ============= Param : End ============="
    echo

    echo "${func_title_log} 開始打包 ${func_Subcommand}"

    # ===> Command 設定 <===
    # 設定基本的 command 內容. [subcommand] [config type]
    local func_build_command_name
    local func_build_command

	# 判斷 thisShell_Config_flutter_run_config_is_enable_fvm_mode
	if [ ${thisShell_Config_optional_is_enable_fvm_mode} = "${GENERAL_CONST_ENABLE_FLAG}" ]; then

		func_build_command_name="${configConst_CommandName_Fvm}"
		func_build_command="${configConst_CommandName_Flutter} build ${func_Subcommand} --${func_param_build_config_type}"

	else

		func_build_command_name="${configConst_CommandName_Flutter}"
		func_build_command="build ${func_Subcommand} --${func_param_build_config_type}"

	fi

    # 若有 build_name
    if [ -n "${thisShell_Config_optional_build_name}" ]; then
        func_build_command="${func_build_command} --${configConst_BuildParam_Key_BuildName} ${thisShell_Config_optional_build_name}"
    fi

    # 若有 build_number
    if [ -n "${thisShell_Config_optional_build_number}" ]; then
        func_build_command="${func_build_command} --${configConst_BuildParam_Key_BuildNumber} ${thisShell_Config_optional_build_number}"
    fi

    # 若有 flavor
    if [ -n "${thisShell_Config_optional_flavor}" ]; then
        func_build_command="${func_build_command} --${configConst_BuildParam_Key_Flavor}=${thisShell_Config_optional_flavor}"
    fi

    # 若有 dart-define
    if [ -n "${thisShell_DartDef_PartOf_Command}" ]; then
        func_build_command="${func_build_command} ${thisShell_DartDef_PartOf_Command}"
    fi

    # ===> OutputFile 設定 <===
    # 設定基本的輸出資料夾名稱格式。
    local func_Build_FolderName

    local func_build_seperator="-"

    # 若有 prefix file name
    append_dest_string_from_source_string_with_separator "${func_title_log}" \
        func_Build_FolderName thisShell_Config_optional_prefix_file_name "${func_build_seperator}"

    # 若有 flavor
    append_dest_string_from_source_string_with_separator "${func_title_log}" \
        func_Build_FolderName thisShell_Config_optional_flavor "${func_build_seperator}"

    # 若有 config type
    append_dest_string_from_source_string_with_separator "${func_title_log}" \
        func_Build_FolderName func_param_build_config_type "${func_build_seperator}"

    # 若有 build_name
    append_dest_string_from_source_string_with_separator "${func_title_log}" \
        func_Build_FolderName thisShell_Config_optional_build_name "${func_build_seperator}"

    # 若有 build_number
    append_dest_string_from_source_string_with_separator "${func_title_log}" \
        func_Build_FolderName thisShell_Config_optional_build_number "${func_build_seperator}"

    # 若有 dart-define
    append_dest_string_from_source_string_with_separator "${func_title_log}" \
        func_Build_FolderName thisShell_DartDef_PartOf_FileName "${func_build_seperator}"

    # 補上結尾
    func_Build_FolderName="${func_Build_FolderName}-$(date "+%Y%m%d%H%M")"

    # 補上前綴資料夾名稱，最後再處理，是讓上面的處理名稱方式統一。
    func_Build_FolderName="archive/${func_Build_FolderName}"

    # ===> Origin build output 設定 <===
    local func_Origin_Build_AppFolder="build/ios/archive"
    local func_Origin_Archive_Name

    # 若有 flavor
    if [ -n "${thisShell_Config_optional_flavor}" ]; then
        func_Origin_Archive_Name="${thisShell_Config_optional_flavor}.xcarchive"
    else
        func_Origin_Archive_Name="Runner.xcarchive"
    fi

    # sample 輸出路徑: (flutter build ipa)
    # - build/ios/archive/[flavor].xcarchive
    func_Origin_Build_AppFolder="${func_Origin_Build_AppFolder}/${func_Origin_Archive_Name}"

    # ===> report note - init 設定 <===
    echo >>"${thisShell_ReportNoteFile}"
    echo "---" >>"${thisShell_ReportNoteFile}"
    echo >>"${thisShell_ReportNoteFile}"
    echo "## [${func_name}] ${func_Build_FolderName}/${func_Origin_Archive_Name}" >>"${thisShell_ReportNoteFile}"
    echo >>"${thisShell_ReportNoteFile}"
    echo "- command line :" >>"${thisShell_ReportNoteFile}"
    echo >>"${thisShell_ReportNoteFile}"
    echo "  \`\`\`shell" >>"${thisShell_ReportNoteFile}"
    echo "    ${func_build_command_name} ${func_build_command}" >>"${thisShell_ReportNoteFile}"
    echo "  \`\`\`" >>"${thisShell_ReportNoteFile}"

    # ===> build ipa <===
    echo "${func_title_log} ===> build ${func_Subcommand} <==="
    echo "${func_title_log} ${func_build_command_name} ${func_build_command}"
    ${func_build_command_name} ${func_build_command}

    # check result - build ipa
    check_result_if_fail_then_change_folder "${func_title_log}" "$?" "!!! ~ ${func_build_command_name} ${func_build_command} => fail ~ !!!" "${thisShell_OldPath}"

    # ===> zip Payload to destination folder <===
    if [ -d ${func_Origin_Build_AppFolder} ]; then

        # 確保藥輸出的 archive 的資料夾存在。
        mkdir -p ${thisShell_Config_required_paths_output}/${func_Build_FolderName}

        mv -v "${thisShell_Flutter_WorkPath}/${func_Origin_Build_AppFolder}" "${thisShell_Config_required_paths_output}/${func_Build_FolderName}"

        # check result - mv iOS archive
        check_result_if_fail_then_change_folder "${func_title_log}" "$?" "!!! ~ mv -v iOS archive => fail ~ !!!" "${thisShell_OldPath}"

        echo "${func_title_log} 打包 ${func_Subcommand} 很順利 😄"
        say "${func_title_log} 打包 ${func_Subcommand} 成功"

    else

        echo "${func_title_log} 遇到報錯了 😭, 打開 Xcode 查找錯誤原因"
        say "${func_title_log} 打包 ${func_Subcommand} 失敗"

        # check result - copy ios
        check_result_if_fail_then_change_folder "${func_title_log}" "100" "!!! ~ Not found ${func_Origin_Build_AppFolder} => fail ~ !!!" "${thisShell_OldPath}"
    fi

    # ===> report note - final 設定 <===
    # ===> 輸出 全部的產出時間統計 <===
    local func_total_time=$((${SECONDS} - ${func_temp_seconds}))
    echo >>"${thisShell_ReportNoteFile}"
    echo "- Elapsed time: ${func_total_time}s" >>"${thisShell_ReportNoteFile}"

    echo
    echo "${func_title_log} ||==========> ${func_Subcommand} : End <==========|| Elapsed time: ${func_total_time}s"
    echo

}
### ==================== ipa : End ====================


### ==================== web : Begin ====================
# @brief exported web 部分 。
function export_web() {

    local func_title_log="${thisShell_Title_Log} *** function [${FUNCNAME[0]}] -"

    # 暫存此區塊的起始時間。
    local func_temp_seconds=${SECONDS}
    local func_Subcommand=${thisShell_SubcommandInfo_web[0]}

    echo
    echo "${func_title_log} ||==========> ${func_Subcommand} : Begin <==========||"

    export_NotyetSupportSubcommand ${func_Subcommand}

    echo "${func_title_log} ||==========> ${func_Subcommand} : End <==========|| Elapsed time: $((${SECONDS} - ${func_temp_seconds}))s"
    echo
}
### ==================== web : End ====================
## ================================== export function section : End ==================================

## ================================== prcess function section : Begin ==================================
# ============= This is separation line =============
# @brief function : [程序] 此 shell 的初始化。
function process_Init() {

    # 計時，實測結果不同 shell 不會影響，各自有各自的 SECONDS。
    SECONDS=0

    # 此 shell 的 dump log title.
    thisShell_Title_Log="[exported] -"

    echo
    echo "${thisShell_Title_Log} ||==========> exported : Begin <==========||"

    # 取得相對目錄.
    local func_Shell_WorkPath=$(dirname $0)

    echo
    echo "${thisShell_Title_Log} func_Shell_WorkPath : ${func_Shell_WorkPath}"

    # 前置處理作業

    # import function
    # 因使用 include 檔案的函式，所以在此之前需先確保路經是在此 shell 資料夾中。

    # 不確定是否使用者都有使用 configTools.sh 產生 build config file， 再來呼叫 exported.sh
    # 保險起見， include configConst.sh
    # include configConst.sh for configTools.sh using export Environment Variable。
    echo
    echo "${thisShell_Title_Log} include configConst.sh"
    . "${func_Shell_WorkPath}"/configConst.sh

    # include general function
    echo
    echo "${thisShell_Title_Log} include general function"
    . "${func_Shell_WorkPath}"/../generalConst.sh
    . "${func_Shell_WorkPath}"/../generalTools.sh

    # include parse_yaml function
    echo
    echo "${thisShell_Title_Log} include parse_yaml function"

    # 同樣在 scm.tools 專案下的相對路徑。
    . "${func_Shell_WorkPath}"/../../../submodules/bash-yaml/script/yaml.sh

    # 設定原先的呼叫路徑。
    thisShell_OldPath=$(pwd)

    # 切換執行目錄.
    change_to_directory "${thisShell_Title_Log}" "${func_Shell_WorkPath}"

    # 設定成完整路徑。
    thisShell_Shell_WorkPath=$(pwd)

    echo "${thisShell_Title_Log} thisShell_OldPath : ${thisShell_OldPath}"
    echo "${thisShell_Title_Log} thisShell_Shell_WorkPath : ${thisShell_Shell_WorkPath}"
    echo
}

# ============= This is separation line =============
# @brief function : [程序] 處理 input param。
function process_Deal_InputParam() {

    # set input param variable
    thisShell_Param_BuildConfigFile="${1}"

    # check input parameters
    check_input_param "${thisShell_Title_Log}" thisShell_Param_BuildConfigFile "${thisShell_Param_BuildConfigFile}"

    echo
    echo "${thisShell_Title_Log} ============= Param : Begin ============="
    echo "${thisShell_Title_Log} thisShell_Param_BuildConfigFile : ${thisShell_Param_BuildConfigFile}"
    echo "${thisShell_Title_Log} ============= Param : End ============="
    echo

    thisShell_ReportNoteFile="${thisShell_Param_BuildConfigFile}.report.md"
}

# ============= This is separation line =============
# @brief function : [程序] Toggle Feature 設定。
function process_Deal_ToggleFeature() {

    # 是否開啟 dump set 內容，當 parse build config file 時，會去判斷。
    thisShell_ToogleFeature_IsDumpSet_When_Parse_BuildConfigFile="${GENERAL_CONST_DISABLE_FLAG}"

    # build configutation type : 編譯組態設定，之後視情況是否要開放
    # 依據 flutter build ， 有 debug ， profile ， release，
    # 可參考 configConst.sh 中的 configConst_BuildConfigType_xxx
    thisShell_ToogleFeature_DefaultBuildConfigType="${configConst_BuildConfigType_Release}"

    echo
    echo "${thisShell_Title_Log} ============= Toogle Feature : Begin ============="
    echo "${thisShell_Title_Log} thisShell_ToogleFeature_IsDumpSet_When_Parse_BuildConfigFile : ${thisShell_ToogleFeature_IsDumpSet_When_Parse_BuildConfigFile}"
    echo "${thisShell_Title_Log} thisShell_ToogleFeature_DefaultBuildConfigType : ${thisShell_ToogleFeature_DefaultBuildConfigType}"
    echo "${thisShell_Title_Log} ============= Toogle Feature : End ============="
    echo

}

# ============= This is separation line =============
# @brief function : [程序] SubcommandInfo 的初始化。
function process_Init_SubcommandInfo() {

    # 設定目前支援的 subcomand
    # 搭配 flutter build 中的 subcommands，
    #
    # 此次需要編譯來源:
    # thisShell_Config_required_subcommands=([0]="aar" [1]="apk" [2]="appbundle" [3]="bundle" [4]="ios" [5]="ios-framework")
    #
    # SubcommandInfo :
    # - 規則 :
    #   - [0]: build subcommand name。
    #   - [1]: 是否要執行 (isExcute)。 default : "${GENERAL_CONST_DISABLE_FLAG}"。
    #
    # 目前只支援 apk 及 ios，之後視情況新增。
    thisShell_SubcommandInfo_aar=("${configConst_Subcommand_aar}" "${GENERAL_CONST_DISABLE_FLAG}")
    thisShell_SubcommandInfo_apk=("${configConst_Subcommand_apk}" "${GENERAL_CONST_DISABLE_FLAG}")
    thisShell_SubcommandInfo_appbundle=("${configConst_Subcommand_appbundle}" "${GENERAL_CONST_DISABLE_FLAG}")
    thisShell_SubcommandInfo_bundle=("${configConst_Subcommand_bundle}" "${GENERAL_CONST_DISABLE_FLAG}")
    thisShell_SubcommandInfo_ios=("${configConst_Subcommand_ios}" "${GENERAL_CONST_DISABLE_FLAG}")
    thisShell_SubcommandInfo_ios_framework=("${configConst_Subcommand_ios_framework}" "${GENERAL_CONST_DISABLE_FLAG}")
    thisShell_SubcommandInfo_ipa=("${configConst_Subcommand_ipa}" "${GENERAL_CONST_DISABLE_FLAG}")
    thisShell_SubcommandInfo_web=("${configConst_Subcommand_web}" "${GENERAL_CONST_DISABLE_FLAG}")
}

# ============= This is separation line =============
# @brief function : [程序] 剖析 build config。
function process_Parse_BuildConfig() {

    # 判斷 build config file
    # 字串是否不為空。 (a non-empty string)
    if [ -n "${thisShell_Param_BuildConfigFile}" ]; then

        echo
        echo "${thisShell_Title_Log} ============= parse build config file : Begin ============="

        # parse build config file
        echo "${thisShell_Title_Log} 將剖析 Build Config File 來做細微的設定。"

        create_variables "${thisShell_Param_BuildConfigFile}" "thisShell_Config_"

        # 開啟可以抓到此 shell 目前有哪些設定值。
        if [ ${thisShell_ToogleFeature_IsDumpSet_When_Parse_BuildConfigFile} = "${GENERAL_CONST_ENABLE_FLAG}" ]; then
            set >${thisShell_Param_BuildConfigFile}_BeforeParseConfig.temp.log
        fi

        # parse required section
        parseReruiredSection

        # parse report path section
        parseReportPathSection

        # parse build config type section
        parseBuildConfigTypeSection

        # parse dart define section
        parseDartDefine

        # 開啟可以抓到此 shell 目前有哪些設定值。
        if [ ${thisShell_ToogleFeature_IsDumpSet_When_Parse_BuildConfigFile} = "${GENERAL_CONST_ENABLE_FLAG}" ]; then
            set >${thisShell_Param_BuildConfigFile}_AfterParseConfig.temp.log
        fi

        echo "${thisShell_Title_Log} ============= parse build config file : End ============="
        echo

        # FIXME
        # exit 1
    fi

}

# ============= This is separation line =============
# @brief function : [程序] 處理路徑相關 (包含 flutter work path)。
function process_Deal_Paths() {

    # 切換到 config file 設定的 flutter project work path: 為 flutter 專案的工作目錄 shell 目錄 (之後會切回到原有呼叫的目錄)
    change_to_directory "${thisShell_Title_Log}" "${thisShell_Config_required_paths_work}"
    thisShell_Flutter_WorkPath=$(pwd)

    echo
    echo "${thisShell_Title_Log} //========== dump paths : Begin ==========//"
    echo "${thisShell_Title_Log} thisShell_OldPath                      : ${thisShell_OldPath}"
    echo "${thisShell_Title_Log} thisShell_Shell_WorkPath               : ${thisShell_Shell_WorkPath}"
    echo "${thisShell_Title_Log} thisShell_Config_required_paths_work   : ${thisShell_Config_required_paths_work}"
    echo "${thisShell_Title_Log} thisShell_Flutter_WorkPath             : ${thisShell_Flutter_WorkPath}"
    echo "${thisShell_Title_Log} thisShell_Config_required_paths_output : ${thisShell_Config_required_paths_output}"
    echo "${thisShell_Title_Log} current path                          : $(pwd)"
    echo "${thisShell_Title_Log} //========== dump paths : End ==========//"
}

# ============= This is separation line =============
# @brief function : [程序] 清除緩存 (之前編譯的暫存檔)。
function process_Clean_Cache() {

    # 以 thisShell_Flutter_WorkPath 為工作目錄來執行
    # 先期準備，刪除舊的資料

    echo "${thisShell_Title_Log} 刪除 build"
    find . -d -name "build" | xargs rm -rf

    echo "${thisShell_Title_Log} ${configConst_CommandName_Flutter} clean"
    ${configConst_CommandName_Flutter} clean
}

# ============= This is separation line =============
# call - [程序] 建立 report note 初始化部分。
function process_Create_ReportNote_Init() {

    echo "# Report Note" >>"${thisShell_ReportNoteFile}"
    echo >>"${thisShell_ReportNoteFile}"
    echo "---" >>"${thisShell_ReportNoteFile}"
    echo >>"${thisShell_ReportNoteFile}"
    echo "## Base info" >>"${thisShell_ReportNoteFile}"
    echo >>"${thisShell_ReportNoteFile}"
    echo "- Subject : report info by \`exported.sh\`" >>"${thisShell_ReportNoteFile}"
    echo >>"${thisShell_ReportNoteFile}"
    echo "- BuildConfigFile :" >>"${thisShell_ReportNoteFile}"
    echo >>"${thisShell_ReportNoteFile}"
    echo "  > ${thisShell_Param_BuildConfigFile}" >>"${thisShell_ReportNoteFile}"
}

# ============= This is separation line =============
# @brief function : [程序] 執行 build subcommands。
# @details : 依照 build config 的設定來 執行 build subcommand。
function process_Execute_Build_Sumcommands() {

    # 判斷是否要出版 aar
    check_ok_then_excute_command "${thisShell_Title_Log}" ${thisShell_SubcommandInfo_aar[1]} export_aar

    # 處理有 build config type 的 subcommands.
    # 先設定成 default 的 build config type。
    local func_BuildConfigTypes=("${thisShell_ToogleFeature_DefaultBuildConfigType}")

    # 若有 build config types，則以此為主。
    # 支援的 subcommand : [apk] [appbundle] [bundle] [ios]。
    if [ -n "${thisShell_Config_optional_build_config_types}" ]; then
        func_BuildConfigTypes=("${thisShell_Config_optional_build_config_types[@]}")
    fi

    local func_i
    for ((func_i = 0; func_i < ${#func_BuildConfigTypes[@]}; func_i++)); do #請注意 ((   )) 雙層括號

        local func_build_config_type=${func_BuildConfigTypes[${func_i}]}

        # 要帶入的 params，使用 check_ok_then_excute_command 來判斷是否要執行，所以要用 array 方式帶入。
        local func_command_params=("${func_build_config_type}")

        # 判斷是否要出版 apk
        check_ok_then_excute_command "${thisShell_Title_Log}" ${thisShell_SubcommandInfo_apk[1]} export_apk func_command_params[@]

        # 判斷是否要出版 appbundle
        check_ok_then_excute_command "${thisShell_Title_Log}" ${thisShell_SubcommandInfo_appbundle[1]} export_appbundle func_command_params[@]

        # 判斷是否要出版 bundle
        check_ok_then_excute_command "${thisShell_Title_Log}" ${thisShell_SubcommandInfo_bundle[1]} export_bundle func_command_params[@]

        # 判斷是否要出版 ios
        check_ok_then_excute_command "${thisShell_Title_Log}" ${thisShell_SubcommandInfo_ios[1]} export_ios func_command_params[@]

        # 判斷是否要出版 ipa
        check_ok_then_excute_command "${thisShell_Title_Log}" ${thisShell_SubcommandInfo_ipa[1]} export_ipa func_command_params[@]

        # 判斷是否要出版 web : TODO: 只有支援 release，profile，之後可能還要判斷是否是合法的 BuildConfigType，是的話才處理。
        check_ok_then_excute_command "${thisShell_Title_Log}" ${thisShell_SubcommandInfo_web[1]} export_web func_command_params[@]

    done

    # 判斷是否要出版 ios_framework
    check_ok_then_excute_command "${thisShell_Title_Log}" ${thisShell_SubcommandInfo_ios_framework[1]} export_ios_framework
}

# ============= This is separation line =============
# @brief function : [程序] shell 全部完成需處理的部份。
function process_Finish() {

    # 全部完成
    # 切回原有執行目錄.
    change_to_directory "${thisShell_Title_Log}" "${thisShell_OldPath}"

    echo
    echo "${thisShell_Title_Log} ||==========> exported : End <==========|| Elapsed time: ${SECONDS}s"
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
# call - [程序] SubcommandInfo 的初始化。
process_Init_SubcommandInfo

# ============= This is separation line =============
# call - [程序] 剖析 build config。
process_Parse_BuildConfig

# ============= This is separation line =============
# call - [程序] 處理路徑相關 (包含 flutter work path)。
process_Deal_Paths

# ============= This is separation line =============
# call - [程序] 清除緩存 (之前編譯的暫存檔)。
process_Clean_Cache

# ============= This is separation line =============
# call - [程序] 建立 report note 初始化部分。
process_Create_ReportNote_Init

# ============= This is separation line =============
# call - [程序] 執行 build subcommands。
process_Execute_Build_Sumcommands

# ============= This is separation line =============
# call - [程序] shell 全部完成需處理的部份。
process_Finish
## ================================== deal prcess step section : End ==================================

exit 0
