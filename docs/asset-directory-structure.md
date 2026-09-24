# 動畫公司 Asset 目錄結構規範

## 設計目標

1. **專案、asset、鏡頭分離**：可重複使用的內容放在 `assets`，鏡頭製作放在 `shots`。
2. **工作檔與發佈檔分離**：藝術家只在 `work` 工作，下游只讀取 `publish`。
3. **軟體中立**：目錄描述製程而不是工具；Maya、Blender、Houdini 等檔案可共存。
4. **可自動化**：固定命名與版本格式，方便資產管理系統、farm 及備份程式解析。

## 專案根目錄

```text
show_name/
├── assets/                    # 可跨鏡頭重複使用的資產
│   ├── characters/            # 角色、生物
│   ├── props/                 # 道具、載具
│   ├── environments/          # 場景、建築、植被組
│   └── fx/                    # 可重用特效設定或 library
├── shots/                     # sequence/shot 鏡頭資料（不放 asset master）
│   └── sq010/sh010/
├── editorial/                 # 剪輯、音訊、reference cut
├── shared/                    # 全專案共用色彩、字型、LUT 與設定
├── delivery/                  # 對外交付；依日期或批次存放
└── tmp/                       # 可清除的暫存，不納入備份
```

## 單一 asset 模板

每個 asset 使用小寫 snake_case 唯一名稱，例如 `hero_ari`、`market_stall_a`：

```text
assets/<type>/<asset_name>/
├── README.md                  # owner、狀態、比例、特殊說明
├── reference/                 # 客戶資料、照片、掃描；原始素材唯讀
├── design/
│   ├── work/                  # 概念、turnaround、色稿工作檔
│   └── publish/               # 核准設計圖
├── model/
│   ├── work/                  # 建模工作檔
│   └── publish/               # 核准 geometry 與 preview
├── surfacing/
│   ├── work/                  # 材質、貼圖工作檔
│   └── publish/               # 核准材質與 texture package
├── rig/
│   ├── work/                  # rig 工作檔、測試
│   └── publish/               # 給動畫使用的 rig
├── groom/
│   ├── work/                  # 毛髮／羽毛／梳理工作檔
│   └── publish/               # groom cache 與設定
├── lookdev/
│   ├── work/                  # lookdev 場景與測試
│   └── publish/               # 核准 look 與 turntable
└── cache/
    ├── incoming/              # 外部或上游暫存；驗證後移走
    └── publish/               # 已驗證、可追溯的 cache
```

不適用的部門目錄可以保留為空，確保工具取得一致路徑。大型貼圖、cache 與影片應存放於公司檔案系統或 object storage；Git 僅管理結構、設定與小型 metadata。

## 命名規則

| 項目 | 格式 | 範例 |
| --- | --- | --- |
| asset 名稱 | `[a-z][a-z0-9_]*` | `hero_ari`, `tree_oak_a` |
| 工作檔 | `<asset>_<task>_v###_<artist>.<ext>` | `hero_ari_model_v012_mlin.ma` |
| 發佈檔 | `<asset>_<task>_v###.<ext>` | `hero_ari_model_v012.usd` |
| 貼圖 | `<asset>_<material>_<channel>_<UDIM>.<ext>` | `hero_ari_skin_basecolor_1001.exr` |
| 預覽 | `<asset>_<task>_v###_preview.<ext>` | `hero_ari_rig_v003_preview.mp4` |

- 版本一律三位數並遞增；不得使用 `final`、`latest`、`new`。
- 人員縮寫只出現在 `work`，正式 publish 不綁定人名。
- 路徑、檔名只用 ASCII 小寫字母、數字與底線，不使用空白。
- DCC 場景以相對路徑或 resolver URI 引用資產，禁止寫死個人磁碟路徑。

## Publish 規則

每次 publish 建議建立不可覆寫的版本目錄：

```text
model/publish/
├── v001/
│   ├── hero_ari_model_v001.usd
│   ├── hero_ari_model_v001_preview.jpg
│   └── manifest.json
└── current -> v001             # 僅由 publish 工具更新的 alias
```

`manifest.json` 至少記錄：asset ID、task、版本、建立者、建立時間、來源工作檔、軟體版本、相依 publish、檔案 checksum 及審核狀態。下游應鎖定明確版本；`current` 適合瀏覽，不應作為最終交付的相依來源。

## 權限與生命週期

- `work`：所屬部門可寫，保留增量版本；可依政策歸檔舊版。
- `publish/v###`：publish service 寫入，所有製作人員唯讀，禁止覆寫。
- `reference`：保留原始檔及授權資訊，限制刪除權限。
- `cache/incoming`、`tmp`：設定自動清理期限，不可成為唯一資料來源。
- `delivery`：由製片或 delivery 工具控制，附 checksum 與交付清單。

## 導入建議

1. 先選一個角色與一個場景做 pilot，確認各 DCC 的路徑解析。
2. 將 `create_asset.sh` 接到資產管理系統，建立 asset 時同步產生唯一 ID。
3. 實作 publish validator，檢查命名、單位、frame rate、色彩空間、相依版本與 checksum。
4. 最後才鎖定 publish 權限並搬移既有資產；舊路徑暫時用 redirect/mapping 過渡。
