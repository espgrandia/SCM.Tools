#!/bin/bash

# ============= This is separation line =============
# @brief : 一般性工具.
# @details : 放置常用工具函式，使用者可以引用此檔案來使用函式.
# @author : esp
# @create date : 2020-09-01
#
# sample :
#  ``` shell
#  # include changeToDirectory function
#  . src/generalTools.sh
#
#  changeToDirectory "${sample_Title_Log}" "${sample_WorkPath}"
#  ```
#
# ---
#
# 注意事項:
# - 使用此通用函式，有相依於 scm.tools/src/shell/generalConst.sh
#   - 其中有使用到 checkResultFail_And_ChangeFolder
#   - 需自行 include generalConst.sh
#   - 再 include generalTools.sh
#
# ---
#
# Reference :
# - title: bash - How to change the output color of echo in Linux - Stack Overflow
#   - website : https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux
#

# ============= This is separation line =============
# @brief function : 取得 git short hash .
# @detail : 簡易函式，不再處理細節的判斷，為保持正確性，參數請自行帶上 "" .
#   - 設定 git short hash 到輸入的參數 ${2}。
#
# @param ${1}: 要輸出的 title log : e.g. "${sample_Title_Log}" .
# @param ${2}: 要設定 git hash 的參數: e.g. sample_GitHash_Short .
function getGitShortHash() {

    local func_Title_Log="*** function [${FUNCNAME[0]}] -"

    echo
    echo "${func_Title_Log} Begin ***"
    echo
    echo "${func_Title_Log} Input param : Begin ***"
    echo "${func_Title_Log} TitleLog : ${1}"
    echo "${func_Title_Log} input param name for setting git hash : ${2}"
    echo "${func_Title_Log} Input param : End ***"

    # Git Hash version
    # 使用 git show 的方式取得 shor commit ID (為 7 位數)。
    eval ${2}=$(git show -s --format=%h)

    echo
    echo "${func_Title_Log} ${1} ============= git hash - Begin ============="
    echo "${func_Title_Log} ${1} ${2} : $(eval echo \$${2})"
    echo "${func_Title_Log} ${1} ============= git hash - End ============="
    echo

    echo "${func_Title_Log} End ***"
    echo
}

# ============= This is separation line =============
# @brief function : 刪除並重新建立資料夾.
# @detail : 簡易函式，不再處理細節的判斷，為保持正確性，參數請自行帶上 "" .
#   - 刪除只會刪除 folder path 此層資料夾的所有資料
#   - folder path (${2}) 階層中沒有的資料夾會全部建立。
#
# @param ${1}: 要輸出的 title log : e.g. "${sample_Title_Log}" .
# @param ${2}: 要處理的目標資料夾(含路徑) : e.g. "${sample_DestFolder}" .
function remvoe_And_Makedir() {

    local func_Title_Log="*** function [${FUNCNAME[0]}] -"

    echo
    echo "${func_Title_Log} Begin ***"
    echo
    echo "${func_Title_Log} Input param : Begin ***"
    echo "${func_Title_Log} TitleLog : ${1}"
    echo "${func_Title_Log} Dest Folder path : "${2}""
    echo "${func_Title_Log} Input param : End ***"

    echo
    echo "${func_Title_Log} ${1} ============= rm & mkdir folder - Begin ============="

    # 設定輸出資料夾
    func_DestFolder="${2}"

    # 刪除輸出資料夾.
    echo "${func_Title_Log} ${1} rm -rf "${func_DestFolder}""
    rm -rf "${func_DestFolder}"

    # 建立輸出目錄
    echo "${func_Title_Log} ${1} mkdir -p "${func_DestFolder}""
    mkdir -p "${func_DestFolder}"

    echo "${func_Title_Log} ${1} ============= rm & mkdir folder - End ============="
    echo

    echo "${func_Title_Log} End ***"
    echo
}

# ============= This is separation line =============
# @brief function : change to directory .
# @detail : 簡易函式，不再處理細節的判斷，為保持正確性，參數請自行帶上 "" .
#
# @param ${1}: 要輸出的 title log : e.g. "${sample_Title_Log}" .
# @param ${2}: 切換的目的資料夾: e.g. "${sample_WorkPath}"，$(dirname $0)，etc ...
function changeToDirectory() {

    local func_Title_Log="*** function [${FUNCNAME[0]}] -"

    echo
    echo "${func_Title_Log} Begin ***"
    echo "${func_Title_Log} Input param : Begin ***"
    echo "${func_Title_Log} TitleLog: ${1}"
    echo "${func_Title_Log} ChangeDestFolder: ${2}"
    echo "${func_Title_Log} Input param : End ***"
    echo "${func_Title_Log} ${1} current path: $(pwd) ***"

    cd "${2}"

    echo "${func_Title_Log} ${1} change dir to ${2} ***"
    echo "${func_Title_Log} ${1} current path: $(pwd) ***"
    echo "${func_Title_Log} End ***"
    echo
}

# ============= This is separation line =============
# @brief function : check input param is illegal.
# @detail : 簡易函式，不再處理細節的判斷，為保持正確性，參數請自行帶上 "" .
#   - 判斷輸入參數的合法性，失敗會直接 return.
#
# @param ${1}: 要輸出的 title log : e.g. "${sample_Title_Log}" .
# @param ${2}: input param name: e.g. "sample_Param_ProjectRelativePath" .
# @param ${3}: input param value: e.g. "${sample_Param_ProjectRelativePath}" .
function checkInputParam() {

    if [[ ${3} == "" ]]; then

        # for echo color
        local func_Bold_Black='\033[1;30m'
        local func_ForegroundColor_Red='\033[0;31m'
        local func_BackgroundColor_Cyan='\033[46m'
        local func_Color_Off='\033[0m'

        # fail 再秀 log.
        local func_Title_Log="*** function [${FUNCNAME[0]}] -"

        echo
        echo "${func_Title_Log} Begin ***"
        echo "${func_Title_Log} Input param : Begin ***"
        echo "${func_Title_Log} TitleLog: ${1}"
        echo "${func_Title_Log} param name: ${2}"
        echo "${func_Title_Log} param value: ${3}"
        echo "${func_Title_Log} Input param : End ***"
        echo "${func_Bold_Black}${func_ForegroundColor_Red}${func_BackgroundColor_Cyan}${func_Title_Log} ${1} ${2}: ${3} is illegal. Error !!!${func_Color_Off}"
        echo "${func_Title_Log} End ***"
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
# @param ${1}: 要輸出的 title log : e.g. "${sample_Title_Log}" .
# @param ${2}: 要驗證的 result value: e.g. $? : 非0為失敗 ..
# @param ${3}: 要 dump log" .
# @param ${4}: 切換回去的的 folder path" .
function checkResultFail_And_ChangeFolder() {

    if [ "${2}" -ne 0 ]; then

        # for echo color
        local func_Bold_Black='\033[1;30m'
        local func_ForegroundColor_Red='\033[0;31m'
        local func_BackgroundColor_Cyan='\033[46m'
        local func_Color_Off='\033[0m'

        # fail 再秀 log.
        local func_Title_Log="*** function [${FUNCNAME[0]}] -"

        echo
        echo "${func_Title_Log} Begin ***"
        echo
        echo "${func_Title_Log} Input param : Begin ***"
        echo "${func_Title_Log} TitleLog: ${1}"
        echo "${func_Title_Log} Result value: ${2}"
        echo "${func_Title_Log} Dump Log: ${3}"
        echo "${func_Title_Log} Change Folder: ${4}"
        echo "${func_Title_Log} Input param : End ***"

        # 切回原有執行目錄.
        echo
        echo "${func_Title_Log} ${1} ===> change director : ${4} <==="
        changeToDirectory "${1}" "${4}"

        echo
        echo "${func_Bold_Black}${func_ForegroundColor_Red}${func_BackgroundColor_Cyan}${func_Title_Log} ${1} ===> dump log : ${3} <===${func_Color_Off}"
        echo "${func_Bold_Black}${func_ForegroundColor_Red}${func_BackgroundColor_Cyan}${func_Title_Log} ${1} ===> exit shell : result : ${2} <===${func_Color_Off}"
        echo
        echo "${func_Title_Log} End ***"

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
# @param ${1}: 要輸出的 title log : e.g. "${sample_Title_Log}" .
# @param ${2} : check value : 要驗證的 value。
# @param ${!3} : source list : 要驗證的 array。
#
# sample e.g. check_Legal_Val_In_List "${sample_Title_Log}" "${sample_Val}" sample_List[@]
#
# @retrun 0: 成功， 99: 失敗。
function check_Legal_Val_In_List() {

    local func_Title_Log="*** function [${FUNCNAME[0]}] -"

    echo
    echo "${func_Title_Log} Begin ***"
    echo "${func_Title_Log} Input param : Begin ***"
    echo "${func_Title_Log} TitleLog: ${1}"
    echo "${func_Title_Log} check value: ${2}"
    echo "${func_Title_Log} source list: ("${!3}")"
    echo "${func_Title_Log} Input param : End ***"

    local func_Param_TitleLog="${1}"
    local func_Param_CheckVal="${2}"
    local func_Param_SrcList=("${!3}")

    checkInputParam "${func_Title_Log}" func_Param_TitleLog "${func_Param_TitleLog}"
    checkInputParam "${func_Title_Log}" func_Param_CheckVal "${func_Param_CheckVal}"
    checkInputParam "${func_Title_Log}" func_Param_SrcList "${func_Param_SrcList[@]}"

    # func_ReVal 的初始設定。
    local func_ReVal=99

    # 檢查是否合法。
    local func_i
    for ((func_i = 0; func_i < ${#func_Param_SrcList[@]}; func_i++)); do #請注意 ((   )) 雙層括號

        local aCheckVal=${func_Param_SrcList[${func_i}]}

        # 判斷是否為 要處理的 command (subcommand name 是否相同) .
        if [ ${func_Param_CheckVal} = ${aCheckVal} ]; then
            echo "${func_Title_Log} Find aCheckVal : ${aCheckVal} in (${func_Param_SrcList[*]}) ***"
            func_ReVal=0
            break
        fi

    done

    echo "${func_Title_Log} End ***"
    echo

    return "${func_ReVal}"
}

# ============= This is separation line =============
# @brief function : 驗證 input check value 是否在 input source list 中，沒找到會切換路徑並中斷程式。
# @detail : 簡易函式，不再處理細節的判斷，為保持正確性，參數請自行帶上 "".
#   - 會呼叫 [check_Legal_Val_In_List] 來驗證 value 是否有在 inpput list。
#   - 若 value 不在 list 中 :
#     - dump 錯誤訊息。 (以及 error code : 99 失敗)。
#     - 則切換指定的資料夾路徑。
#     - 離開中斷 shell。
#
# @param ${1}: 要輸出的 title log : e.g. "${sample_Title_Log}" .
# @param ${2} : check value : 要驗證的 value。
# @param ${!3} : source list : 要驗證的 array。
# @param ${4}: 切換回去的的 folder path"
#
# sample e.g. check_Legal_Val_In_List__If__ResultFail_Then_ChangeFolder "${sample_Title_Log}" "${sample_Val}" sample_List[@] "${sample_ChangeFolder}"
function check_Legal_Val_In_List__If__ResultFail_Then_ChangeFolder() {

    local func_Title_Log="*** function [${FUNCNAME[0]}] -"

    echo
    echo "${func_Title_Log} Begin ***"
    echo "${func_Title_Log} Input param : Begin ***"
    echo "${func_Title_Log} TitleLog: ${1}"
    echo "${func_Title_Log} check value: ${2}"
    echo "${func_Title_Log} source list: (${!3})"
    echo "${func_Title_Log} change folder: ${4}"
    echo "${func_Title_Log} Input param : End ***"

    local func_Param_TitleLog="${1}"
    local func_Param_CheckVal="${2}"
    local func_Param_SrcList=("${!3}")
    local func_Param_ChangeFolder="${4}"

    check_Legal_Val_In_List "${func_Param_TitleLog}" "${func_Param_CheckVal}" func_Param_SrcList[@]

    # 呼叫驗證，帶入回傳值，不合法則中斷程序。
    checkResultFail_And_ChangeFolder "${func_Title_Log} ${func_Param_TitleLog}" "$?" \
        "\r\n!!! ~ OPPS!! Input val : ${func_Param_CheckVal} not found in (${func_Param_SrcList[*]}) => fail ~ !!!" "${func_Param_ChangeFolder}"

    echo "${func_Title_Log} End ***"
    echo
}

# ============= This is separation line =============
# @brief function : 驗證 input check list 的 values， 每一個 value 內容，是否在 input source list 中，沒找到會切換路徑並中斷程式。
# @detail : 簡易函式，不再處理細節的判斷，為保持正確性，參數請自行帶上 "".
#   - 會呼叫 [check_Legal_Val_In_List__If__ResultFail_Then_ChangeFolder] 來驗證 單一 value 是否有在 inpput list。
#   - 若 value 不在 list 中 :
#     - dump 錯誤訊息。 (以及 error code : 99 失敗)。
#     - 則切換指定的資料夾路徑。
#     - 離開中斷 shell。
#   - check list 不可為空，若為空 :
#     - dump 錯誤訊息。 (以及 error code : 1 失敗， shell 檢查 list 數量是否大於 0，測試的結果不成立會回傳 1)。
#
# @param ${1}: 要輸出的 title log : e.g. "${sample_Title_Log}" .
# @param ${!2} : check list : 要驗證的 array。
# @param ${!3} : source list : 要驗證的 array。
# @param ${4}: 切換回去的的 folder path"
#
# sample e.g. check_Legal_VerifiedList_In_List__If__ResultFail_Then_ChangeFolder "${sample_Title_Log}" \
#               sample_VerifiedList[@] sample_List[@] "${sample_ChangeFolder}"
function check_Legal_VerifiedList_In_List__If__ResultFail_Then_ChangeFolder() {

    local func_Title_Log="*** function [${FUNCNAME[0]}] -"

    echo
    echo "${func_Title_Log} Begin ***"
    echo "${func_Title_Log} Input param : Begin ***"
    echo "${func_Title_Log} TitleLog: ${1}"
    echo "${func_Title_Log} check list original name: ${2}"
    echo "${func_Title_Log} check list: (${!2})"
    echo "${func_Title_Log} source list original name: ${3}"
    echo "${func_Title_Log} source list: (${!3})"
    echo "${func_Title_Log} change folder: ${4}"
    echo "${func_Title_Log} Input param : End ***"

    local func_Param_TitleLog="${1}"
    local func_Param_CheckList_Original_Name=${2}
    local func_Param_CheckList=("${!2}")
    local func_Param_SrcList=("${!3}")
    local func_Param_ChangeFolder="${4}"

    # 字串是否不為空。 (a non-empty string)
    if 	[ "${#func_Param_CheckList[@]}" -gt "0" ]; then

        local func_i
        for ((func_i = 0; func_i < ${#func_Param_CheckList[@]}; func_i++)); do #請注意 ((   )) 雙層括號

            local func_aCheckVal=${func_Param_CheckList[${func_i}]}
            local func_curIndx

            # 判斷 是否為合法的 [config type]。
            check_Legal_Val_In_List__If__ResultFail_Then_ChangeFolder "${func_Param_TitleLog}" "${func_aCheckVal}" \
                func_Param_SrcList[@] "${func_Param_ChangeFolder}"

        done

    else

        checkResultFail_And_ChangeFolder "${func_Param_TitleLog}" "$?" "!!! ${func_Param_CheckList_Original_Name} count : ${#func_Param_CheckList[@]} is illegal => fail ~ !!!" "${func_Param_ChangeFolder}"

    fi

    echo "${func_Title_Log} End ***"
    echo
}

# ============= This is separation line =============
# @brief function : split string to a pair .
# @detail : 簡易函式，不再處理細節的判斷，為保持正確性，參數請自行帶上 "" .
#   - 依據輸入的字串，分隔符號，以及要寫入的參入名稱。
#   - 剖析後，會取分隔後前兩筆寫入對應的參數。
#
# @param ${1}: 要輸出的 title log : e.g. "${sample_Title_Log}" .
# @param ${2}: 要分析的字串: e.g. "1.0.0+2" .
# @param ${3}: separator 的字串: e.g. "+" .
# @param ${4}: 要設定的第一個參數，拆解後取第一位的內容來設定。 e.g. sample_Split_First .
# @param ${5}: 要設定的第一個參數，拆解後取第二位的內容來設定。 e.g. sample_Split_Second .
#
# sample e.g. splitStringToPair "${sample_Title_Log}" "${sample_SourceString}" "${sample_Separator}" sample_Split_First sample_Split_Second
function splitStringToPair() {

    local func_Title_Log="*** function [${FUNCNAME[0]}] -"

    echo
    echo "${func_Title_Log} Begin ***"
    echo
    echo "${func_Title_Log} Input param : Begin ***"
    echo "${func_Title_Log} TitleLog : ${1}"
    echo "${func_Title_Log} source string : ${2}"
    echo "${func_Title_Log} separator string : ${3}"
    echo "${func_Title_Log} first name : ${4}"
    echo "${func_Title_Log} second name : ${5}"
    echo "${func_Title_Log} Input param : End ***"
    echo
    echo "${func_Title_Log} ${1} execute split ***"

    eval ${4}="$(echo ${2} | cut -d${3} -f1)"
    eval ${5}="$(echo ${2} | cut -d${3} -f2)"

    echo "${func_Title_Log} ${1} 1st : $(eval echo \$${4}) ***"
    echo "${func_Title_Log} ${1} 2nd : $(eval echo \$${5}) ***"
    echo
    echo "${func_Title_Log} End ***"
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
# @param ${1}: 要輸出的 title log : e.g. "${sample_Title_Log}" .
# @param ${2}: 要設定的目標的字串，為實際會設定的參數， (有可能為空，需判斷): e.g. sample_DestString ("abc" or "") .
# @param ${3}: 要 append 的來源的字串參數，要 dump log，所以也是用參數帶入 (有可能為空，需判斷): e.g. sample_SourceString ("App_1.0.1" or "") .
# @param ${4}: separator 的字串 (要 append 時的分隔字串，允許為空字串): e.g. "-" .
#
# sample e.g. append_DestString_From_SourceString_With_Separator "${sample_Title_Log}" sample_DestString sample_SourceString "${sample_Separator}"
function append_DestString_From_SourceString_With_Separator() {

    local func_Title_Log="*** function [${FUNCNAME[0]}] -"

    echo
    echo "${func_Title_Log} Begin ***"
    echo
    echo "${func_Title_Log} Input param : Begin ***"
    echo "${func_Title_Log} TitleLog : ${1}"
    echo "${func_Title_Log} dest string : ${2}"
    echo "${func_Title_Log} source string : ${3}"
    echo "${func_Title_Log} separator string : ${4}"
    echo "${func_Title_Log} Input param : End ***"
    echo

    local func_Param_DestStringValue=$(eval echo \$${2})
    local func_Param_SourceStringValue=$(eval echo \$${3})
    local func_Param_Separator=${4}

    echo "${func_Title_Log} ${1} ${2} (dest string value)   : $(eval echo \$${2}) ***"
    echo "${func_Title_Log} ${1} ${3} (source string value) : $(eval echo \$${3}) ***"
    echo
    echo "${func_Title_Log} ${1} execute append - [Begin] ***"

    # 若有 Source String Value
    if [ -n "${func_Param_SourceStringValue}" ]; then

        # 若有 Dest String Value
        if [ -n "${func_Param_DestStringValue}" ]; then
            eval ${2}="${func_Param_DestStringValue}${func_Param_Separator}${func_Param_SourceStringValue}"
        else
            eval ${2}="${func_Param_SourceStringValue}"
        fi

    fi

    echo "${func_Title_Log} ${1} ${2} (dest string value)   : $(eval echo \$${2}) ***"
    echo "${func_Title_Log} ${1} ${3} (source string value) : $(eval echo \$${3}) ***"
    echo "${func_Title_Log} ${1} execute append - [End] ***"
    echo
    echo "${func_Title_Log} End ***"
    echo
}

# ============= This is separation line =============
# @brief function : 確認成功，則執行 command.
# @details : 要執行 command 前會判斷是否要帶入其對應參數 (commandParams)
#
# @param ${1}: 要輸出的 title log : e.g. "${sample_Title_Log}" .
# @Param ${2}: isExcute : 是否要執行命令 => "Y" 或 "N" => e.g. ${sample_IsExcute}
# @Param ${3}: command : 要執行的 command，可能為函式或 shell => e.g. sample_Command
# @Param ${4}: commandParams : 要執行的 command 的參數資訊，為 array => e.g. sample_CommandParams[@]
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
#     sample_CommandParams=("help" "build" "apk")
#     check_OK_Then_Excute_Command "${sample_Title_Log}" "${sample_ToggleFeature_Is_Excute}" "flutter" sample_CommandParams[@]
#  - e.g.2.
#     sample_CommandParams=("${sample_OutputFolder}")
#     check_OK_Then_Excute_Command "${sample_Title_Log}" "${sample_ToggleFeature_Is_Excute}" "open" sample_CommandParams[@]
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
function check_OK_Then_Excute_Command() {

  local func_ReVal=0

    echo "check_OK_Then_Excute_Command - generalConst_Enable_Flag : ${generalConst_Enable_Flag} ***"

    # 驗證成功再處理後續。
    if [ ${2} = "${generalConst_Enable_Flag}" ]; then

        local func_Title_Log="*** function [${FUNCNAME[0]}] -"

        echo
        echo "${func_Title_Log} Begin ***"
        echo "${func_Title_Log} Input param : Begin ***"
        echo "${func_Title_Log} TitleLog : ${1}"
        echo "${func_Title_Log} command : ${3}"
        echo "${func_Title_Log} command params : ${!4}"
        echo "${func_Title_Log} Input param : End ***"

        echo
        echo "${func_Title_Log} ${1} ============= excute command - Begin ============="

        # for local varient
        local func_Command="${3}"
        local func_CommandParams=("${!4}")

        # 若有 func_CommandParams
        if [ -n "${func_CommandParams}" ]; then

            echo "${func_Title_Log} ${1} func_CommandParams : ${func_CommandParams[@]}"
            echo "${func_Title_Log} ${1} func_CommandParams count : ${#func_CommandParams[@]}"
            echo "${func_Title_Log} ${1} will excute command : ${func_Command} ${func_CommandParams[@]}"

            ${func_Command} "${func_CommandParams[@]}"

            func_ReVal=$?
            echo "${func_Title_Log} ${1} excute command result code: ${func_ReVal}"

        else

            echo "${func_Title_Log} ${1} will excute command : ${func_Command}"

            ${func_Command}

            func_ReVal=$?
            echo "${func_Title_Log} ${1} excute command result code: ${func_ReVal}"

        fi

        echo "${func_Title_Log} ${1} ============= excute command - End ============="
        echo

        echo "${func_Title_Log} End ***"
        echo

    fi

    return "${func_ReVal}"
}

# ============= This is separation line =============
# @brief function : 轉呼叫 [check_OK_Then_Excute_Command]，回傳值若非成功 (0)，則切換路徑並中斷程式。
# @detail : 簡易函式，不再處理細節的判斷，為保持正確性，參數請自行帶上 "".
#   - 主要參數及使用方式，請參考 [check_OK_Then_Excute_Command] 說明。
#
# @Params :
# === copy from [check_OK_Then_Excute_Command] - Begin
# @param ${1}: 要輸出的 title log : e.g. "${sample_Title_Log}" .
# @Param ${2}: isExcute : 是否要執行命令 => "Y" 或 "N" => e.g. ${sample_IsExcute}
# @Param ${3}: command : 要執行的 command，可能為函式或 shell => e.g. sample_Command
# @Param ${4}: commandParams : 要執行的 command 的參數資訊，為 array => e.g. sample_CommandParams[@]
# === copy from [check_OK_Then_Excute_Command] - End
#
# @param ${5}: 切換回去的的 folder path" => e.g. "${sample_ChangeFolder}"
#
# sample e.g. check_OK_Then_Excute_Command__If__ResultFail_Then_ChangeFolder [check_OK_Then_Excute_Command Param_1 ... Param_4] "${sample_ChangeFolder}"
function check_OK_Then_Excute_Command__If__ResultFail_Then_ChangeFolder() 
{

    local func_Title_Log="*** function [${FUNCNAME[0]}] -"

    echo
    echo "${func_Title_Log} Begin ***"
    echo "${func_Title_Log} Input param : Begin ***"
    echo "${func_Title_Log} TitleLog : ${1}"
    echo "${func_Title_Log} isExcute : ${2}"
    echo "${func_Title_Log} command : ${3}"
    echo "${func_Title_Log} command params : ${!4}"
    echo "${func_Title_Log} change folder: ${5}"
    echo "${func_Title_Log} Input param : End ***"

    local func_Param_TitleLog="${1}"
    local func_Param_IsExcute="${2}"
    local func_Param_CoommandName="${3}"
    local func_Param_CoommandParams=("${!4}")
    local func_Param_ChangeFolder="${5}"

    check_OK_Then_Excute_Command "${func_Param_TitleLog}" "${func_Param_IsExcute}" "${func_Param_CoommandName}" func_Param_CoommandParams[@]

    # 呼叫驗證，帶入回傳值，不合法則中斷程序。
    checkResultFail_And_ChangeFolder "${func_Param_TitleLog}" "$?" \
        "\r\n!!! ~ OPPS!! Execute Command Fail. \r\n- Command Name : ${func_Param_CoommandName}\r\n- Command Params: $(echo ${func_Param_CoommandParams[@]}) \r\n => fail ~ !!!" "${func_Param_ChangeFolder}"

    echo "${func_Title_Log} End ***"
    echo
}

