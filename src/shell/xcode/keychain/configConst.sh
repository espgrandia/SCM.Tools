#!/bin/bash

# @brief : 宣告 keychain 輔助工具會用到的 const value。
#
# @details :
#  - 目前會使用到的 shell
#    - configTools.sh
#    - keychainTool_ImportCerToKeychain.sh
#  - 部分內容會給使用 exported.sh 參考使用。
#

## ================================== Config File (yaml) Key section : Begin ==================================
# @brief 針對 config file (yaml) 會用到的 key，於此定義。
# @detail 首先會用到的是 confitTools.sh，其餘的 keychainTool_ImportCerToKeychain.sh 看看是否能使用。
# @sa [configTools.sh] [config_tools_gen_required]

### ---------------------------------- [required] section : Begin ----------------------------------
# @brief [required] 必要項目的 key。
# for [required] key。
export CONFIG_CONST_CONFIG_KEY_REQUIRED="required"

# for [required] [keychain]
export CONFIG_CONST_CONFIG_KEY_REQUIRED_KEYCHAIN="keychain"

# for [required] [keychain] [name]
# - 設定的 keycahin 名稱。
# - 意即 顯示在 keychain.app 中的 keycahin 名稱。
export CONFIG_CONST_CONFIG_KEY_REQUIRED_KEYCHAIN_NAME="name"

# for [required] [keychain] [password]
# - 設定的 keycahin 密碼。
export CONFIG_CONST_CONFIG_KEY_REQUIRED_KEYCHAIN_PASSWORD="password"

# for [required] [cer_info_key_names]
# - 額外的 cer info 的 key name，需要在 config file 有對應的資訊內容。
export CONFIG_CONST_CONFIG_KEY_REQUIRED_CER_INFO_KEY_NAMES="cer_info_key_names"
### ----------------------------------[required] section : End ----------------------------------

### ---------------------------------- [extra] section : Begin ----------------------------------
# @brief [extra] cer info unit 所需要項目的 key。
# - 針對 [required] [cer_info_key_names] 的內容，動態取得 [some cer_info_key_name] 的資訊。
# @sa [configTools.sh] [config_tools_gen_extra_cer_info_unit]

# for [some cer_info_key_name] [file_password_separator]
# - 分合符號
export CONFIG_CONST_CONFIG_KEY_CER_INFO_UNIT_FILE_PASSWORD_SEPARATOR="file_password_separator"

export CONFIG_CONST_CONFIG_KEY_CER_INFO_UNIT_FILE_PASSWORD_LIST="file_password_list"
### ----------------------------------[extra] section : End ----------------------------------

### ---------------------------------- [optional] section : Begin ----------------------------------
# @brief [optional] 項目的 key。
# @detail 非必要項目，有設定到的功能，才會去使用。
# @sa [configTools.sh] [config_tools_gen_optional_work_path]

# for [optional] key。
export CONFIG_CONST_CONFIG_KEY_OPTIONAL="optional"

# for [optional] [work_path]。
# - 有設定的話，則會以該資料夾為工作目錄，
# - 沒有的話，會以 keychain tool 所在的資料夾為工作目錄。
export CONFIG_CONST_CONFIG_KEY_WORK_PATH="work_path"
### ----------------------------------[optional] section : End ----------------------------------

## ================================== Config File (yaml) Key section : End ==================================

