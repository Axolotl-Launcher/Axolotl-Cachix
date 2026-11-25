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
| `v1.11.2-beta.3` | [`793bc3af3beaa65d967e3448aec9e65f39b1157b`](https://github.com/Axolotl-Launcher/Axolotl/commit/793bc3af3beaa65d967e3448aec9e65f39b1157b) | ✅ | ✅ |
| `main` | [`793bc3af3beaa65d967e3448aec9e65f39b1157b`](https://github.com/Axolotl-Launcher/Axolotl/commit/793bc3af3beaa65d967e3448aec9e65f39b1157b) | ✅ | ✅ |

<!-- END CACHED-COMMITS -->

| 图例  Legend |      描述      | Description |
|:------------:|:--------------:|:----------------:|
|     `✅`     | 缓存成功       | `Successfully cached` |
|   `❔❓❌`   | 构建失败1/2/3+ | `Build failed 1/2/3+` |
|     `💤`     | 无可用的flakes | `No available flakes` |
|     `⏳`     | 未知故障       | `Undetermined issues` |
