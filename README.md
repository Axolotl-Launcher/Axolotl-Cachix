# Axolotl-Cachix

预构建 [美西螈启动器](https://github.com/Mystic-Stars/Axolotl) 产物由 [工作流](./.github/workflows/nix-cache.yml) 自动推送至 [Cachix](https://axlmc.cachix.org)。\
请将 `"https://axlmc.cachix.org"` 加入 `extra-substituters`，\
并将 `"axlmc.cachix.org-1:dmsRJqFQqLMfvRveerHV3DxDCW1wq1N+TX1+dryYWZU="` 加入 `extra-trusted-public-keys`。

Prebuilt [Axolotl Launcher](https://github.com/Mystic-Stars/Axolotl) artifacts are pushed automatically by the [workflow](./.github/workflows/nix-cache.yml) to [Cachix](https://axlmc.cachix.org).\
Please add `"https://axlmc.cachix.org"` to `extra-substituters`,\
then add `"axlmc.cachix.org-1:dmsRJqFQqLMfvRveerHV3DxDCW1wq1N+TX1+dryYWZU="` to `extra-trusted-public-keys`.

<!-- BEGIN CACHED-COMMITS -->

| Ref | Commit | x86_64-linux | aarch64-linux |
| --- | --- | :---: | :---: |
| `v1.11.1` | [`d0eae7ef8a9ef7e8f1da840e0546a258b881c866`](https://github.com/Axolotl-Launcher/Axolotl/commit/d0eae7ef8a9ef7e8f1da840e0546a258b881c866) | ✅ | ✅ |
| `v1.11.2-beta.1` | [`4171c2f480f82cf40e90f99c2a5303ed26718b30`](https://github.com/Axolotl-Launcher/Axolotl/commit/4171c2f480f82cf40e90f99c2a5303ed26718b30) | ✅ | ✅ |
| `main` | [`3d5ffb62cc9c04e295a2754527729362ef13b756`](https://github.com/Axolotl-Launcher/Axolotl/commit/3d5ffb62cc9c04e295a2754527729362ef13b756) | ✅ | ✅ |

<!-- END CACHED-COMMITS -->

| 图例  Legend |      描述      | Description |
|:------------:|:--------------:|:----------------:|
|     `✅`     | 缓存成功       | `Successfully cached` |
|   `❔❓❌`   | 构建失败1/2/3+ | `Build failed 1/2/3+` |
|     `💤`     | 无可用的flakes | `No available flakes` |
|     `⏳`     | 未知故障       | `Undetermined issues` |
