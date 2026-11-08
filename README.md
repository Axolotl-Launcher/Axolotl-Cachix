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
| `v1.10.5` | [`e9d1def79b35bcd2dceb20d83beb43bef0ba0182`](https://github.com/Axolotl-Launcher/Axolotl/commit/e9d1def79b35bcd2dceb20d83beb43bef0ba0182) | ✅ | ✅ |
| `v1.11.0-beta.2` | [`f21f729f856a4d1d5a64c22837abb01267909168`](https://github.com/Axolotl-Launcher/Axolotl/commit/f21f729f856a4d1d5a64c22837abb01267909168) | ✅ | ✅ |
| `main` | [`fa03fe3f3e6507272217ed0b7c486058b8aedfd3`](https://github.com/Axolotl-Launcher/Axolotl/commit/fa03fe3f3e6507272217ed0b7c486058b8aedfd3) | ⏳ | ⏳ |

<!-- END CACHED-COMMITS -->

| 图例  Legend |      描述      | Description |
|:------------:|:--------------:|:----------------:|
|     `✅`     | 缓存成功       | `Successfully cached` |
|   `❔❓❌`   | 构建失败1/2/3+ | `Build failed 1/2/3+` |
|     `💤`     | 无可用的flakes | `No available flakes` |
|     `⏳`     | 未知故障       | `Undetermined issues` |
