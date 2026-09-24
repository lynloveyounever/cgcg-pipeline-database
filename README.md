# CGCG Pipeline Database

這個 repository 提供動畫專案的 **asset 目錄規範**與可直接複製的空白模板。

- 完整規範：[`docs/asset-directory-structure.md`](docs/asset-directory-structure.md)
- 建立工具：[`scripts/create_asset.sh`](scripts/create_asset.sh)

快速建立一個角色 asset：

```bash
./scripts/create_asset.sh /path/to/show characters hero_ari
```

工具會建立 `/path/to/show/assets/characters/hero_ari`，並套用
[`templates/asset`](templates/asset) 的標準結構。
