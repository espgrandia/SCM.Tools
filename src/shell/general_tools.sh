#!/bin/bash

# ============= This is separation line =============
# @brief : 一般性工具.
# @details : 放置常用工具函式，使用者可以引用此檔案來使用函式.
# @author : esp
# @create date : 2020-09-01
#
# sample :
#  ``` shell
#  # include change_to_directory function
#  . src/generalTools.sh
#
#  change_to_directory "${sample_title_log}" "${sample_work_path}"
#  ```
#
# ---
#
# 注意事項:
# - 使用此通用函式，有相依於 scm.tools/src/shell/general_const.sh
#   - 其中有使用到 GENERAL_CONST_ENABLE_FLAG
#   - 需自行 include general_const.sh
#   - 再 include generalTools.sh
#
# ---
#
# Reference :
# - title: bash - How to change the output color of echo in Linux - Stack Overflow
#   - website : https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux
#

## ================================== Git section : Begin ==================================
##
# ============= This is separation line =============
# @brief function : 取得 git short hash .
# @detail : 簡易函式，不再處理細節的判斷，為保持正確性，參數請自行帶上 "" .
#   - 設定 git short hash 到輸入的參數 ${2}。
#
# @param ${1}: 要輸出的 title log : e.g. "${sample_title_log}" .
# @param ${2}: 要設定 git hash 的參數: e.g. sample_git_hash_short .
function get_git_short_hash() {

    local func_title_log="*** function [${FUNCNAME[0]}] -"

    echo
    echo "${func_title_log} Begin ***"
    echo
    echo "${func_title_log} Input param : Begin ***"
    echo "${func_title_log} TitleLog : ${1}"
    echo "${func_title_log} input param name for setting git hash : ${2}"
    echo "${func_title_log} Input param : End ***"

    # 應用於函式中主體的 title log。
    local func_main_body_title_log="${func_title_log} ${1}"

    # Git Hash version
    # 使用 git show 的方式取得 shor commit ID (為 7 位數)。
    eval ${2}=$(git show -s --format=%h)

    echo
    echo "${func_main_body_title_log} ============= git hash - Begin ============="
    echo "${func_main_body_title_log} ${2} : $(eval echo \$${2})"
    echo "${func_main_body_title_log} ============= git hash - End ============="
    echo

    echo "${func_title_log} End ***"
    echo
}
##
## ================================== Git section : End ==================================

## ================================== Folder section : Begin ==================================
##
# ============= This is separation line =============
# @brief function : 刪除並重新建立資料夾.
# @detail : 簡易函式，不再處理細節的判斷，為保持正確性，參數請自行帶上 "" .
#   - 刪除只會刪除 folder path 此層資料夾的所有資料
#   - folder path (${2}) 階層中沒有的資料夾會全部建立。
#
# @param ${1}: 要輸出的 title log : e.g. "${sample_title_log}" .
# @param ${2}: 要處理的目標資料夾(含路徑) : e.g. "${sample_dest_folder}" .
function remvoe_and_make_dir() {

    local func_title_log="*** function [${FUNCNAME[0]}] -"

    echo
    echo "${func_title_log} Begin ***"
    echo
    echo "${func_title_log} Input param : Begin ***"
    echo "${func_title_log} TitleLog : ${1}"
    echo "${func_title_log} Dest Folder path : "${2}""
    echo "${func_title_log} Input param : End ***"

    # 應用於函式中主體的 title log。
    local func_main_body_title_log="${func_title_log} ${1}"

    echo
    echo "${func_main_body_title_log} ============= rm & mkdir folder - Begin ============="

    # 設定輸出資料夾
    local func_dest_folder="${2}"

    # 刪除輸出資料夾.
    echo "${func_main_body_title_log} rm -rf "${func_dest_folder}""
    rm -rf "${func_dest_folder}"

    # 建立輸出目錄
    echo "${func_main_body_title_log} mkdir -p "${func_dest_folder}""
    mkdir -p "${func_dest_folder}"

    echo "${func_main_body_title_log} ============= rm & mkdir folder - End ============="
    echo

    echo "${func_title_log} End ***"
    echo
}

# ============= This is separation line =============
# @brief function : change to directory .
# @detail : 簡易函式，不再處理細節的判斷，為保持正確性，參數請自行帶上 "" .
#
# @param ${1}: 要輸出的 title log : e.g. "${sample_title_log}" .
# @param ${2}: 切換的目的資料夾: e.g. "${sample_work_path}"，$(dirname $0)，etc ...
function change_to_directory() {

    local func_title_log="*** function [${FUNCNAME[0]}] -"

    echo
    echo "${func_title_log} Begin ***"
    echo "${func_title_log} Input param : Begin ***"
    echo "${func_title_log} TitleLog: ${1}"
    echo "${func_title_log} ChangeDestFolder: ${2}"
    echo "${func_title_log} Input param : End ***"

    # 應用於函式中主體的 title log。
    local func_main_body_title_log="${func_title_log} ${1}"

    echo "${func_main_body_title_log} current path: $(pwd) ***"

    cd "${2}"

    echo "${func_main_body_title_log} change dir to ${2} ***"
    echo "${func_main_body_title_log} current path: $(pwd) ***"
    echo
    echo "${func_title_log} End ***"
    echo
}
##
## ================================== Folder section : End ==================================

## ================================== Check section : Begin ==================================
##
# ============= This is separation line =============
# @brief function : check input param is illegal.
# @detail : 簡易函式，不再處理細節的判斷，為保持正確性，參數請自行帶上 "" .
#   - 判斷輸入參數的合法性，失敗會直接 exit 1 .
#
# @param ${1}: 要輸出的 title log : e.g. "${sample_title_log}" .
# @param ${2}: input param name: e.g. "sample_param_project_relative_path" .
# @param ${3}: input param value: e.g. "${sample_param_project_relative_path}" .
function check_input_param() {

    if [[ ${3} == "" ]]; then

        # fail 再秀 log.
        local func_title_log="*** function [${FUNCNAME[0]}] -"

        echo
        echo "${func_title_log} Begin ***"
        echo "${func_title_log} Input param : Begin ***"
        echo "${func_title_log} TitleLog: ${1}"
        echo "${func_title_log} param name: ${2}"
        echo "${func_title_log} param value: ${3}"
        echo "${func_title_log} Input param : End ***"

        # 應用於函式中主體的 title log。
        local func_main_body_title_log="${func_title_log} ${1}"

        echo
        echo "${GENERAL_CONST_COLORS_RED}${GENERAL_CONST_COLORS_ON_CYAN}${func_main_body_title_log} ${2}: ${3} is illegal. Error !!!${GENERAL_CONST_COLORS_COLOR_OFF}"
        echo
        echo "${func_title_log} End ***"
        echo

        exit 1
    fi
}

# ============= This is separation line =============
# @brief function : 檢查輸入 result code 是否失敗，並作對應處理。
# @detail
#   - 簡易函式，不再處理細節的判斷，為保持正確性，參數請自行帶上 "" .
#   - 檢查輸入 result 是否失敗 (0: 成功，非0: 失敗)，失敗則切換目錄，並直接 return : exit result code .
#   - 一般為呼叫完某個 command line，判斷其回傳值是否成功，失敗則離開此 shell .
#
# @param ${1}: 要輸出的 title log : e.g. "${sample_title_log}" .
# @param ${2}: 要驗證的 result value: e.g. $? : 非0為失敗 ..
# @param ${3}: 要 dump log" .
# @param ${4}: 切換回去的的 folder path" .
function check_result_if_fail_then_change_folder() {

    if [ "${2}" -ne 0 ]; then

        # fail 再秀 log.
        local func_title_log="*** function [${FUNCNAME[0]}] -"

        echo
        echo "${func_title_log} Begin ***"
        echo
        echo "${func_title_log} Input param : Begin ***"
        echo "${func_title_log} TitleLog: ${1}"
        echo "${func_title_log} Result value: ${2}"
        echo "${func_title_log} Dump Log: ${3}"
        echo "${func_title_log} Change Folder: ${4}"
        echo "${func_title_log} Input param : End ***"

        # 應用於函式中主體的 title log。
        local func_main_body_title_log="${func_title_log} ${1}"

        # 切回原有執行目錄.
        echo
        echo "${func_main_body_title_log} ===> change director : ${4} <==="
        change_to_directory "${func_title_log}" "${4}"

        echo
        echo "${GENERAL_CONST_COLORS_RED}${GENERAL_CONST_COLORS_ON_CYAN}${func_main_body_title_log} ===> dump log : ${3} <===${GENERAL_CONST_COLORS_COLOR_OFF}"
        echo "${GENERAL_CONST_COLORS_RED}${GENERAL_CONST_COLORS_ON_CYAN}${func_main_body_title_log} ===> exit shell : result : ${2} <===${GENERAL_CONST_COLORS_COLOR_OFF}"
        echo
        echo "${func_title_log} End ***"

        exit ${2}
    fi
}

# ============= This is separation line =============
# @brief function : 驗證 input check value 是否在 input source list 中。
# @detail : 簡易函式，不再處理細節的判斷，為保持正確性，參數請自行帶上 "".
#   - 只檢查是否為合法設定。
#   - value 有在 list 中，則回傳 0。
#   - value 不在 list 中，則回傳 99。
#   - 呼叫完此函式，可使用 "$?" 來取得回傳值。
#
# @param ${1}: 要輸出的 title log : e.g. "${sample_title_log}" .
# @param ${2} : check value : 要驗證的 value。
# @param ${!3} : source list : 要驗證的 array。
#
# sample e.g. check_legal_val_in_list "${sample_title_log}" "${sample_val}" sample_list[@]
#
# @retrun 0: 成功， 99: 失敗。
function check_legal_val_in_list() {

    local func_title_log="*** function [${FUNCNAME[0]}] -"

    echo
    echo "${func_title_log} Begin ***"
    echo "${func_title_log} Input param : Begin ***"
    echo "${func_title_log} TitleLog: ${1}"
    echo "${func_title_log} check value: ${2}"
    echo "${func_title_log} source list: ("${!3}")"
    echo "${func_title_log} Input param : End ***"

    local func_param_title_log="${1}"
    local func_param_check_val="${2}"
    local func_param_src_list=("${!3}")

    check_input_param "${func_title_log}" func_param_title_log "${func_param_title_log}"
    check_input_param "${func_title_log}" func_param_check_val "${func_param_check_val}"
    check_input_param "${func_title_log}" func_param_src_list "${func_param_src_list[@]}"

    # 應用於函式中主體的 title log。
    local func_main_body_title_log="${func_title_log} ${1}"

    # func_return_value 的初始設定。
    local func_return_value=99

    # 檢查是否合法。
    local func_i
    for ((func_i = 0; func_i < ${#func_param_src_list[@]}; func_i++)); do #請注意 ((   )) 雙層括號

        local func_a_check_val=${func_param_src_list[${func_i}]}

        # 判斷是否為 要處理的 command (subcommand name 是否相同) .
        if [ ${func_param_check_val} = ${func_a_check_val} ]; then
            echo "${func_main_body_title_log} Find func_a_check_val : ${func_a_check_val} in (${func_param_src_list[*]}) ***"
            func_return_value=0
            break
        fi

    done

    echo "${func_title_log} End ***"
    echo

    return "${func_return_value}"
}

# ============= This is separation line =============
# @brief function : 驗證 input check value 是否在 input source list 中，沒找到會切換路徑並中斷程式。
# @detail : 簡易函式，不再處理細節的判斷，為保持正確性，參數請自行帶上 "".
#   - 會呼叫 [check_legal_val_in_list] 來驗證 value 是否有在 inpput list。
#   - 若 value 不在 list 中 :
#     - dump 錯誤訊息。 (以及 error code : 99 失敗)。
#     - 則切換指定的資料夾路徑。
#     - 離開中斷 shell。
#
# @param ${1}: 要輸出的 title log : e.g. "${sample_title_log}" .
# @param ${2} : check value : 要驗證的 value。
# @param ${!3} : source list : 要驗證的 array。
# @param ${4}: 切換回去的的 folder path"
#
# sample e.g. check_legal_val_in_list__if__result_fail_then_change_folder "${sample_title_log}" "${sample_val}" sample_list[@] "${sample_change_folder}"
function check_legal_val_in_list__if__result_fail_then_change_folder() {

    local func_title_log="*** function [${FUNCNAME[0]}] -"

    echo
    echo "${func_title_log} Begin ***"
    echo "${func_title_log} Input param : Begin ***"
    echo "${func_title_log} TitleLog: ${1}"
    echo "${func_title_log} check value: ${2}"
    echo "${func_title_log} source list: (${!3})"
    echo "${func_title_log} change folder: ${4}"
    echo "${func_title_log} Input param : End ***"

    local func_param_title_log="${1}"
    local func_param_check_val="${2}"
    local func_param_src_list=("${!3}")
    local func_param_change_folder="${4}"

    check_legal_val_in_list "${func_title_log}" "${func_param_check_val}" func_param_src_list[@]

    # 呼叫驗證，帶入回傳值，不合法則中斷程序。
    check_result_if_fail_then_change_folder "${func_title_log}" "$?" \
        "\r\n!!! ~ OPPS!! Input val : ${func_param_check_val} not found in (${func_param_src_list[*]}) => fail ~ !!!" "${func_param_change_folder}"

    echo "${func_title_log} End ***"
    echo
}

# ============= This is separation line =============
# @brief function : 驗證 input check list 的 values， 每一個 value 內容，是否在 input source list 中，沒找到會切換路徑並中斷程式。
# @detail : 簡易函式，不再處理細節的判斷，為保持正確性，參數請自行帶上 "".
#   - 會呼叫 [check_legal_val_in_list__if__result_fail_then_change_folder] 來驗證 單一 value 是否有在 inpput list。
#   - 若 value 不在 list 中 :
#     - dump 錯誤訊息。 (以及 error code : 99 失敗)。
#     - 則切換指定的資料夾路徑。
#     - 離開中斷 shell。
#   - check list 不可為空，若為空 :
#     - dump 錯誤訊息。 (以及 error code : 1 失敗， shell 檢查 list 數量是否大於 0，測試的結果不成立會回傳 1)。
#
# @param ${1}: 要輸出的 title log : e.g. "${sample_title_log}" .
# @param ${!2} : check list : 要驗證的 array。
# @param ${!3} : source list : 要驗證的 array。
# @param ${4}: 切換回去的的 folder path"
#
# sample e.g. check_legal_verified_list_in_list__if__result_fail_then_change_folder "${sample_title_log}" \
#               sample_verified_list[@] sample_list[@] "${sample_change_folder}"
function check_legal_verified_list_in_list__if__result_fail_then_change_folder() {

    local func_title_log="*** function [${FUNCNAME[0]}] -"

    echo
    echo "${func_title_log} Begin ***"
    echo "${func_title_log} Input param : Begin ***"
    echo "${func_title_log} TitleLog: ${1}"
    echo "${func_title_log} check list original name: ${2}"
    echo "${func_title_log} check list: (${!2})"
    echo "${func_title_log} source list original name: ${3}"
    echo "${func_title_log} source list: (${!3})"
    echo "${func_title_log} change folder: ${4}"
    echo "${func_title_log} Input param : End ***"

    local func_param_check_list_original_name=${2}
    local func_param_check_list=("${!2}")
    local func_param_src_list=("${!3}")
    local func_param_change_folder="${4}"

    # 字串是否不為空。 (a non-empty string)
    if [ "${#func_param_check_list[@]}" -gt "0" ]; then

        local func_i
        for ((func_i = 0; func_i < ${#func_param_check_list[@]}; func_i++)); do #請注意 ((   )) 雙層括號

            local func_a_check_val=${func_param_check_list[${func_i}]}

            # 判斷 是否為合法的 [config type]。
            check_legal_val_in_list__if__result_fail_then_change_folder "${func_title_log}" "${func_a_check_val}" \
                func_param_src_list[@] "${func_param_change_folder}"

        done

    else

        check_result_if_fail_then_change_folder "${func_title_log}" "$?" "!!! ${func_param_check_list_original_name} count : ${#func_param_check_list[@]} is illegal => fail ~ !!!" "${func_param_change_folder}"

    fi

    echo "${func_title_log} End ***"
    echo
}
##
## ================================== Check section : End ==================================

## ================================== String section : Begin ==================================
##
# ============= This is separation line =============
# @brief function : split string to a pair .
# @detail : 簡易函式，不再處理細節的判斷，為保持正確性，參數請自行帶上 "" .
#   - 依據輸入的字串，分隔符號，以及要寫入的參入名稱。
#   - 剖析後，會取分隔後前兩筆寫入對應的參數。
#
# @param ${1}: 要輸出的 title log : e.g. "${sample_title_log}" .
# @param ${2}: 要分析的字串: e.g. "1.0.0+2" .
# @param ${3}: separator 的字串: e.g. "+" .
# @param ${4}: 要設定的第一個參數，拆解後取第一位的內容來設定。 e.g. sample_split_frst .
# @param ${5}: 要設定的第一個參數，拆解後取第二位的內容來設定。 e.g. sample_split_second .
#
# sample e.g. split_string_to_pair "${sample_title_log}" "${sample_source_string}" "${sample_separator}" sample_split_frst sample_split_second
function split_string_to_pair() {

    local func_title_log="*** function [${FUNCNAME[0]}] -"

    echo
    echo "${func_title_log} Begin ***"
    echo
    echo "${func_title_log} Input param : Begin ***"
    echo "${func_title_log} TitleLog : ${1}"
    echo "${func_title_log} source string : ${2}"
    echo "${func_title_log} separator string : ${3}"
    echo "${func_title_log} first name : ${4}"
    echo "${func_title_log} second name : ${5}"
    echo "${func_title_log} Input param : End ***"
    echo

    # 應用於函式中主體的 title log。
    local func_main_body_title_log="${func_title_log} ${1}"

    local func_param_source_string_value=${2}
    local func_param_separator=${3}

    # 有分隔符號，並且 source string 有含分隔符號，才實際處理。
    # 沒有判斷的話可能會出錯。
    if [ -n "${func_param_separator}" ] && [[ "${func_param_source_string_value}" == *"${func_param_separator}"* ]]; then

        echo "${func_main_body_title_log} input param legal => execute split ***"

        eval ${4}="$(echo ${func_param_source_string_value} | cut -d${func_param_separator} -f1)"
        eval ${5}="$(echo ${func_param_source_string_value} | cut -d${func_param_separator} -f2)"

    else
        echo "${func_main_body_title_log} not found separator (${func_param_separator}) or source string (${func_param_source_string_value}) not contains separator (${func_param_separator})。 ***"
        echo "${func_main_body_title_log} 1st is assigned eaual to source string。 ***"

        eval ${4}="${func_param_source_string_value}"
    fi

    echo "${func_main_body_title_log} 1st (${4}) : $(eval echo \$${4}) ***"
    echo "${func_main_body_title_log} 2nd (${5}) : $(eval echo \$${5}) ***"
    echo
    echo "${func_title_log} End ***"
    echo
}

# ============= This is separation line =============
# @brief function : append destString from sourceString with separator .
# @detail : 簡易函式，不再處理細節的判斷，為保持正確性，參數請自行帶上 "" .
#   - 依據輸入的字串，分隔符號，以及要寫入的參入名稱。
#   - append string 概念 :
#     判斷 source string 是否有值，
#     - 有值則會在判斷 dest string 是否有值，。
#       - 有值則會 append source string 到 dest string 後面，且中間以 separator 來當分隔符號。
#       - 空值則會 設定 source string 給 dest string。
#
# @param ${1}: 要輸出的 title log : e.g. "${sample_title_log}" .
# @param ${2}: 要設定的目標的字串，為實際會設定的參數， (有可能為空，需判斷): e.g. sample_dest_string ("abc" or "") .
# @param ${3}: 要 append 的來源的字串參數，要 dump log，所以也是用參數帶入 (有可能為空，需判斷): e.g. sample_source_string ("App_1.0.1" or "") .
# @param ${4}: separator 的字串 (要 append 時的分隔字串，允許為空字串): e.g. "-" .
#
# sample e.g. append_dest_string_from_source_string_with_separator "${sample_title_log}" sample_dest_string sample_source_string "${sample_separator}"
function append_dest_string_from_source_string_with_separator() {

    local func_title_log="*** function [${FUNCNAME[0]}] -"

    echo
    echo "${func_title_log} Begin ***"
    echo
    echo "${func_title_log} Input param : Begin ***"
    echo "${func_title_log} TitleLog : ${1}"
    echo "${func_title_log} dest string : ${2}"
    echo "${func_title_log} source string : ${3}"
    echo "${func_title_log} separator string : ${4}"
    echo "${func_title_log} Input param : End ***"
    echo

    # 應用於函式中主體的 title log。
    local func_main_body_title_log="${func_title_log} ${1}"

    local func_param_dest_string_value=$(eval echo \$${2})
    local func_param_source_string_value=$(eval echo \$${3})
    local func_param_separator=${4}

    echo "${func_main_body_title_log} ${2} (dest string value)   : $(eval echo \$${2}) ***"
    echo "${func_main_body_title_log} ${3} (source string value) : $(eval echo \$${3}) ***"
    echo
    echo "${func_main_body_title_log} execute append - [Begin] ***"

    # 若有 Source String Value
    if [ -n "${func_param_source_string_value}" ]; then

        # 若有 Dest String Value
        if [ -n "${func_param_dest_string_value}" ]; then
            eval ${2}="${func_param_dest_string_value}${func_param_separator}${func_param_source_string_value}"
        else
            eval ${2}="${func_param_source_string_value}"
        fi

    fi

    echo "${func_main_body_title_log} ${2} (dest string value)   : $(eval echo \$${2}) ***"
    echo "${func_main_body_title_log} ${3} (source string value) : $(eval echo \$${3}) ***"
    echo "${func_main_body_title_log} execute append - [End] ***"
    echo
    echo "${func_title_log} End ***"
    echo
}
##
## ================================== String section : End ==================================

## ================================== Command section : Begin ==================================
##
# ============= This is separation line =============
# @brief function : [check_ok_then_excute_command] 確認成功，則執行 command.
# @details : 要執行 command 前會判斷是否要帶入其對應參數 (commandParams)
#
# @param ${1}: 要輸出的 title log : e.g. "${sample_title_log}" .
# @Param ${2}: isExcute : 是否要執行命令 => "Y" 或 "N" => e.g. "${sample_is_execute}"
# @Param ${3}: command : 要執行的 command，可能為函式或 shell => e.g. "${sample_command_name}"，"open"，"flutter"，...。
# @Param ${4}: commandParams : 要執行的 command 的參數資訊，為 array => e.g. sample_command_params[@]
#   - 為 option，有才會帶入到 command 後面。
#   - array : 第 0 個為 command line，
#   - array : 第 1 個 (含 1) 後面為依序要輸入的參數
#
# @return : 回傳值 (execute command 結果回傳)。
#  符合一般的 shell 或 command line 回傳 result code 原則。
#  - 0 : 成功 (包括不需要 execute command)
#  - 其他 : 都視為失敗。
#
# ---
#
# @sample
#  - e.g.1.
#     sample_command_params=("help" "build" "apk")
#     check_ok_then_excute_command "${sample_title_log}" "${sample_toggle_feature_is_execute}" "flutter" sample_command_params[@]
#  - e.g.2.
#     sample_command_params=("${sample_output_folder}")
#     check_ok_then_excute_command "${sample_title_log}" "${sample_toggle_feature_is_execute}" "open" sample_command_params[@]
#
# ---
#
# @reference :
#   - title: shell script - How to add/remove an element to/from the array in bash? - Unix & Linux Stack Exchange
#     - website: https://unix.stackexchange.com/questions/328882/how-to-add-remove-an-element-to-from-the-array-in-bash
#   - title : Bash if..else Statement | Linuxize
#     - website: https://linuxize.com/post/bash-if-else-statement/
#
# @附註
#  原先想採用只輸入一個 array，的方式，然後用 arry2=(arr1[@]:1) 的方式來設定，
#  不過若某個 value 是有含空白，在 array copy 時會被視為不同的內容，也就是數量會長大。
#  導致要用別的方式處理，後來改成直接輸入兩個參數 (command , command prarms) 來判斷比較簡單。
#
function check_ok_then_excute_command() {

    local func_title_log="*** function [${FUNCNAME[0]}] -"

    check_input_param "${func_title_log}" GENERAL_CONST_ENABLE_FLAG "${GENERAL_CONST_ENABLE_FLAG}"

    local func_return_value=0

    # 驗證成功再處理後續。
    if [ ${2} = "${GENERAL_CONST_ENABLE_FLAG}" ]; then

        echo
        echo "${func_title_log} Begin ***"
        echo "${func_title_log} Input param : Begin ***"
        echo "${func_title_log} TitleLog : ${1}"
        echo "${func_title_log} command : ${3}"
        echo "${func_title_log} command params : ${!4}"
        echo "${func_title_log} Input param : End ***"

        # 應用於函式中主體的 title log。
        local func_main_body_title_log="${func_title_log} ${1}"

        echo
        echo "${func_main_body_title_log} ============= excute command - Begin ============="

        # for local varient
        local func_command="${3}"
        local func_command_params=("${!4}")

        # 若有 func_command_params
        if [ -n "${func_command_params}" ]; then

            echo "${func_main_body_title_log} func_command_params : ${func_command_params[@]}"
            echo "${func_main_body_title_log} func_command_params count : ${#func_command_params[@]}"
            echo "${func_main_body_title_log} will excute command : ${func_command} ${func_command_params[@]}"

            ${func_command} "${func_command_params[@]}"

            func_return_value=$?
            echo "${func_main_body_title_log} excute command result code: ${func_return_value}"

        else

            echo "${func_main_body_title_log} will excute command : ${func_command}"

            ${func_command}

            func_return_value=$?
            echo "${func_main_body_title_log} excute command result code: ${func_return_value}"

        fi

        echo "${func_main_body_title_log} ============= excute command - End ============="
        echo

        echo "${func_title_log} End ***"
        echo

    fi

    return "${func_return_value}"
}

# ============= This is separation line =============
# @brief function : 轉呼叫 [check_ok_then_excute_command]，回傳值若非成功 (0)，則切換路徑並中斷程式。
# @detail : 簡易函式，不再處理細節的判斷，為保持正確性，參數請自行帶上 "".
#   - 主要參數及使用方式，請參考 [check_ok_then_excute_command] 說明。
#
# @Params :
# === copy from [check_ok_then_excute_command] - Begin
# @param ${1}: 要輸出的 title log : e.g. "${sample_title_log}" .
# @Param ${2}: isExcute : 是否要執行命令 => "Y" 或 "N" => e.g. "${sample_is_execute}"
# @Param ${3}: command : 要執行的 command，可能為函式或 shell => e.g. "${sample_command_name}"，"open"，"flutter"，...。
# @Param ${4}: commandParams : 要執行的 command 的參數資訊，為 array => e.g. sample_command_params[@]
# === copy from [check_ok_then_excute_command] - End
#
# @param ${5}: 切換回去的的 folder path" => e.g. "${sample_change_folder}"
#
# sample e.g. check_ok_then_excute_command__if__result_fail_then_change_folder \
#  "${sample_title_log}"  "${sample_is_execute}" "${sample_command_name}" sample_command_params[@] "${sample_change_folder}"
function check_ok_then_excute_command__if__result_fail_then_change_folder() {

    local func_title_log="*** function [${FUNCNAME[0]}] -"

    echo
    echo "${func_title_log} Begin ***"
    echo "${func_title_log} Input param : Begin ***"
    echo "${func_title_log} TitleLog : ${1}"
    echo "${func_title_log} isExcute : ${2}"
    echo "${func_title_log} command : ${3}"
    echo "${func_title_log} command params : ${!4}"
    echo "${func_title_log} change folder: ${5}"
    echo "${func_title_log} Input param : End ***"

    local func_param_title_log="${1}"
    local func_param_is_excute="${2}"
    local func_param_coommand_name="${3}"
    local func_param_command_params=("${!4}")
    local func_param_change_folder="${5}"

    check_ok_then_excute_command "${func_title_log}" "${func_param_is_excute}" "${func_param_coommand_name}" func_param_command_params[@]

    # 呼叫驗證，帶入回傳值，不合法則中斷程序。
    check_result_if_fail_then_change_folder "${func_title_log}" "$?" \
        "\r\n!!! ~ OPPS!! Execute Command Fail. \r\n- Command Name : ${func_param_coommand_name}\r\n- Command Params: (${func_param_command_params[*]}) \r\n => fail ~ !!!" "${func_param_change_folder}"

    echo "${func_title_log} End ***"
    echo
}

# ============= This is separation line =============
# @brief function : 藉由 which 來收尋 source command list，取得第一個找到的 command。
# @detail : 簡易函式，不再處理細節的判斷，為保持正確性，參數請自行帶上 "".
#   - 只檢查是否為合法設定，
#   - 透過 which 命令，依序 找尋 source command list。
#     - 有找到合法的 command， 則設定 found first command， 並回傳 0。
#     - command list 都找不到，則回傳 99。
#   - 呼叫完此函式，可使用 "$?" 來取得回傳值。
#
# @param ${1} : 要輸出的 title log : e.g. "${sample_title_log}" .
# @param ${!2} : source command list : 要驗證的 command list。 e.g. sample_command_list[@]
# @param ${3} : found first command : 第一個收尋到的 commmand。 e.g. sample_found_first_command .
#
# sample e.g. get_first_found_command_from_input_command_list_by_using_which_command "${sample_title_log}" sample_command_list[@] sample_found_first_command
#
# @retrun 0: 成功， 99: 失敗 (Not Found Command)。
function get_first_found_command_from_input_command_list_by_using_which_command() {

    local func_title_log="*** function [${FUNCNAME[0]}] -"

    echo
    echo "${func_title_log} Begin ***"
    echo "${func_title_log} Input param : Begin ***"
    echo "${func_title_log} TitleLog: ${1}"
    echo "${func_title_log} source command list: (${!2})"
    echo "${func_title_log} found first command: ${3}"
    echo "${func_title_log} Input param : End ***"

    local func_param_title_log="${1}"
    local func_param_command_list=("${!2}")
    local func_param_found_first_command="${3}"

    check_input_param "${func_title_log}" func_param_title_log "${func_param_title_log}"
    check_input_param "${func_title_log}" func_param_command_list "${func_param_command_list[@]}"
    check_input_param "${func_title_log}" func_param_found_first_command "${func_param_found_first_command}"

    # 應用於函式中主體的 title log。
    local func_main_body_title_log="${func_title_log} ${1}"

    # func_return_value 的初始設定。
    local func_return_value=99

    # Check 是否有找到可使用的 python。
    local func_i
    for ((func_i = 0; func_i < ${#func_param_command_list[@]}; func_i++)); do #請注意 ((   )) 雙層括號

        local func_command=${func_param_command_list[${func_i}]}

        echo "${func_main_body_title_log} which ${func_command}"
        which which ${func_command}

        if [ $? -eq 0 ]; then
            echo "${func_main_body_title_log} assign ${func_param_found_first_command} to ${func_command}"
            func_return_value=0
            eval ${3}="${func_command}"
            break
        fi

    done

    echo "${func_main_body_title_log} found first command => (${func_param_found_first_command}) : $(eval echo \$${func_param_found_first_command}) ***"

    echo "${func_main_body_title_log} func_return_value : ${func_return_value} ***"

    echo "${func_title_log} End ***"
    echo

    return "${func_return_value}"
}

# ============= This is separation line =============
# @brief function : 轉呼叫 [get_first_found_command_from_input_command_list_by_using_which_command]，沒找到會切換路徑並中斷程式。
# @detail : 簡易函式，不再處理細節的判斷，為保持正確性，參數請自行帶上 "".
#   - 會呼叫 [get_first_found_command_from_input_command_list_by_using_which_command] 來驗證 ， input command list 透過 which 命令是否有找到其中一個 command。
#   - 若 找不到 合法的 command:
#     - dump 錯誤訊息。 (以及 error code : 99 失敗)。
#     - 則切換指定的資料夾路徑。
#     - 離開中斷 shell。
#
# === copy from [get_first_found_command_from_input_command_list_by_using_which_command] - Begin
# @param ${1} : 要輸出的 title log : e.g. "${sample_title_log}" .
# @param ${!2} : source command list : 要驗證的 command list。 e.g. sample_command_list[@]
# @param ${3} : found first command : 第一個收尋到的 commmand。 e.g. sample_found_first_command .
# === copy from [get_first_found_command_from_input_command_list_by_using_which_command] - End
#
# @param ${4}: 切換回去的的 folder path" => e.g. "${sample_change_folder}"
#
# sample e.g. get_first_found_command_from_input_command_list_by_using_which_command__if__result_fail_then_change_folder "${sample_title_log}" sample_command_list[@] sample_found_first_command "${sample_change_folder}"
#
# @retrun 0: 成功， 404: 失敗 (Not Found Command)。
function get_first_found_command_from_input_command_list_by_using_which_command__if__result_fail_then_change_folder() {

    local func_title_log="*** function [${FUNCNAME[0]}] -"

    echo
    echo "${func_title_log} Begin ***"
    echo "${func_title_log} Input param : Begin ***"
    echo "${func_title_log} TitleLog: ${1}"
    echo "${func_title_log} source command list: (${!2})"
    echo "${func_title_log} found first command: ${3}"
    echo "${func_title_log} change folder: ${4}"
    echo "${func_title_log} Input param : End ***"

    local func_param_command_list=("${!2}")
    local func_param_found_first_command="${3}"
    local func_param_change_folder="${4}"

    get_first_found_command_from_input_command_list_by_using_which_command \
        "${func_title_log}" func_param_command_list[@] "${func_param_found_first_command}"

    # 呼叫驗證，帶入回傳值，不合法則中斷程序。
    check_result_if_fail_then_change_folder "${func_title_log}" "$?" \
        "\r\n!!! ~ OPPS!! \r\nInput Command List : (${func_param_command_list[*]}) \r\nNot found by using \`which\` command. => fail ~ !!!" "${func_param_change_folder}"

    echo "${func_title_log} End ***"
    echo
}
##
## ================================== Command section : End ==================================

## ================================== Show Colors Info section : Begin ==================================
##
# ============= This is separation line =============
# @brief function : 秀 log 的顏色設定，可由此參考 dump log 是否需要調整顏色，使重要訊息可以呈現出來。
# @detail : 簡易函式，不再處理細節的判斷，為保持正確性，參數請自行帶上 "".
function show_colors_info() {

    local func_title_log="*** function [${FUNCNAME[0]}] -"

    echo
    echo "${func_title_log} Begin ***"

    # reset
    _show_one_color GENERAL_CONST_COLORS_COLOR_OFF

    # Regular Colors
    _show_one_color GENERAL_CONST_COLORS_BLACK
    _show_one_color GENERAL_CONST_COLORS_RED
    _show_one_color GENERAL_CONST_COLORS_GREEN
    _show_one_color GENERAL_CONST_COLORS_YELLOW
    _show_one_color GENERAL_CONST_COLORS_BLUE
    _show_one_color GENERAL_CONST_COLORS_PURPLE
    _show_one_color GENERAL_CONST_COLORS_CYAN
    _show_one_color GENERAL_CONST_COLORS_WHITE

    # Bold
    _show_one_color GENERAL_CONST_COLORS_BBLACK
    _show_one_color GENERAL_CONST_COLORS_BRED
    _show_one_color GENERAL_CONST_COLORS_BGREEN
    _show_one_color GENERAL_CONST_COLORS_BYELLOW
    _show_one_color GENERAL_CONST_COLORS_BBLUE
    _show_one_color GENERAL_CONST_COLORS_BPURPLE
    _show_one_color GENERAL_CONST_COLORS_BCYAN
    _show_one_color GENERAL_CONST_COLORS_BWHITE

    # Underline
    _show_one_color GENERAL_CONST_COLORS_UBLACK
    _show_one_color GENERAL_CONST_COLORS_URED
    _show_one_color GENERAL_CONST_COLORS_UGREEN
    _show_one_color GENERAL_CONST_COLORS_UYELLOW
    _show_one_color GENERAL_CONST_COLORS_UBLUE
    _show_one_color GENERAL_CONST_COLORS_UPURPLE
    _show_one_color GENERAL_CONST_COLORS_UCYAN
    _show_one_color GENERAL_CONST_COLORS_UWHITE

    # Background
    _show_one_color GENERAL_CONST_COLORS_ON_BLACK
    _show_one_color GENERAL_CONST_COLORS_ON_RED
    _show_one_color GENERAL_CONST_COLORS_ON_GREEN
    _show_one_color GENERAL_CONST_COLORS_ON_YELLOW
    _show_one_color GENERAL_CONST_COLORS_ON_BLUE
    _show_one_color GENERAL_CONST_COLORS_ON_PURPLE
    _show_one_color GENERAL_CONST_COLORS_ON_CYAN
    _show_one_color GENERAL_CONST_COLORS_ON_WHITE

    # High Intensity
    _show_one_color GENERAL_CONST_COLORS_IBLACK
    _show_one_color GENERAL_CONST_COLORS_IRED
    _show_one_color GENERAL_CONST_COLORS_IGREEN
    _show_one_color GENERAL_CONST_COLORS_IYELLOW
    _show_one_color GENERAL_CONST_COLORS_IBLUE
    _show_one_color GENERAL_CONST_COLORS_IPURPLE
    _show_one_color GENERAL_CONST_COLORS_ICYAN
    _show_one_color GENERAL_CONST_COLORS_IWHITE

    # Bold High Intensity
    _show_one_color GENERAL_CONST_COLORS_BIBLACK
    _show_one_color GENERAL_CONST_COLORS_BIRED
    _show_one_color GENERAL_CONST_COLORS_BIGREEN
    _show_one_color GENERAL_CONST_COLORS_BIYELLOW
    _show_one_color GENERAL_CONST_COLORS_BIBLUE
    _show_one_color GENERAL_CONST_COLORS_BIPURPLE
    _show_one_color GENERAL_CONST_COLORS_BICYAN
    _show_one_color GENERAL_CONST_COLORS_BIWHITE

    # High Intensity backgrounds
    _show_one_color GENERAL_CONST_COLORS_ON_IBLACK
    _show_one_color GENERAL_CONST_COLORS_ON_IRED
    _show_one_color GENERAL_CONST_COLORS_ON_IGREEN
    _show_one_color GENERAL_CONST_COLORS_ON_IYELLOW
    _show_one_color GENERAL_CONST_COLORS_ON_IBLUE
    _show_one_color GENERAL_CONST_COLORS_ON_IPURPLE
    _show_one_color GENERAL_CONST_COLORS_ON_ICYAN
    _show_one_color GENERAL_CONST_COLORS_ON_IWHITE

    echo "${func_title_log} End ***"
    echo
}
##
## ================================== Show Colors Info section : End ==================================

## ================================== Private Function Section : Begin ==================================
##
# ============= This is separation line =============
# @brief function : 單純秀 單一 color 設定的 log。
#  - private function，暫時沒考慮開放。
#
# @param ${1}: 要輸出的 Color 參數名稱，內部會取其實際內容。 e.g. sample_color_name
#
# sample e.g. _show_one_color sample_color_name
function _show_one_color() {
    local func_color_name=${1}
    local func_color_value=$(eval echo \$${1})
    echo "Color Value Name : ${GENERAL_CONST_COLORS_WHITE}${func_color_name} = ${func_color_value}I love you${GENERAL_CONST_COLORS_COLOR_OFF}"
}
##
## ================================== Private Function Section : End ==================================
