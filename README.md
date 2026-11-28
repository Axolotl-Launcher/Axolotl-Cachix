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
| `v1.11.2` | [`fa84d93fbf47c4ed00a8eac0c662c2f41099a9c3`](https://github.com/Axolotl-Launcher/Axolotl/commit/fa84d93fbf47c4ed00a8eac0c662c2f41099a9c3) | ⏳ | ⏳ |
| `v1.11.2-beta.4` | [`7d480a07f14045cb6721636a4b8a8e7610e8d3ce`](https://github.com/Axolotl-Launcher/Axolotl/commit/7d480a07f14045cb6721636a4b8a8e7610e8d3ce) | ✅ | ✅ |
| `main` | [`544951213c1f52ed2dcae4422bb91e3e2ac119bf`](https://github.com/Axolotl-Launcher/Axolotl/commit/544951213c1f52ed2dcae4422bb91e3e2ac119bf) | ✅ | ✅ |

<!-- END CACHED-COMMITS -->

| 图例  Legend |      描述      | Description |
|:------------:|:--------------:|:----------------:|
|     `✅`     | 缓存成功       | `Successfully cached` |
|   `❔❓❌`   | 构建失败1/2/3+ | `Build failed 1/2/3+` |
|     `💤`     | 无可用的flakes | `No available flakes` |
|     `⏳`     | 未知故障       | `Undetermined issues` |
