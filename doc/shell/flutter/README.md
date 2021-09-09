# Flutter Shell Tools

---

## 大綱

- [Flutter Shell Tools](#flutter-shell-tools)
  - [大綱](#大綱)
  - [說明](#說明)
    - [flutter](#flutter)
    - [fvm](#fvm)
  - [參考](#參考)

---

## 說明

在 [src]/[shell]/[fluuter] 這個資料夾下，

主要是針對 flutter 提供的 command 以及 flutter 延伸的應用工具使用包裝。

主要的 shell 功能可以看各自的 shell 檔案上方的說明。

這邊只稍微說明概念。

### flutter

- 支援版本 :

  目前支援 flutter 1.22.0

  > 以 flutter 1.22.0 來實作。

  - flutter 2.2.3 現行項目測試 OK

- 未來規劃 :

  以 flutter 2.2.3 為主，新增支援的 flutter build command

**shell 簡易說明 :**

- `configConst.sh`

  宣告 flutter 輔助工具會用到的 const value

  - 初期是給 exported.sh 以及實作曾專案的使用，後來有擴大使用範圍。

- `configTools.sh`

  flutter exported.sh 會用到的 build config 工具。

- `exported.sh`

  簡單處理目前的出版 => release for apk and ipa。

- `flutterExtensionTools.sh`

  flutter 的擴展工具函式。

- `releaseNoteTools.sh`

  flutter project 中，exporte 相關 shell ，會用到的 release note 工具。

### fvm

**shell 簡易說明 :**

- `fvmTools.sh`

  透過 fvm (Flutter Version Management) 用來管理 Flutter Version 切換功能。

---

## 參考

- [Flutter 中文资源主页 | Flutter中文文档网站_教程_入门_社区资源]

- [fvm | Flutter Version Management]

- [技術研究 備份](./backup/技術研究.xlsx)

  - 備份時間 : 2021-09-09

  > flutter build command 技術研究，主要整理 subcommand 有哪些參數，以及差異性列表。

- [flutter 2.2.3 command log 備份](./backup/flutter_2.2.3)

---

[Flutter 中文资源主页 | Flutter中文文档网站_教程_入门_社区资源]:
  https://flutter.cn/

[fvm | Flutter Version Management]:
  https://fvm.app/

[=> Top](#flutter-shell-tools)

[=> Go Back](../../../README.md)
