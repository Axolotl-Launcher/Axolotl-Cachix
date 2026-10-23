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
| `v1.9.9` | [`b2f81391e584aebf3ef07e8db2fc9cdad2ffb4c7`](https://github.com/Axolotl-Launcher/Axolotl/commit/b2f81391e584aebf3ef07e8db2fc9cdad2ffb4c7) | ✅ | ✅ |
| `v1.10.0-beta.5` | [`2d75d79481fe18e4a934027d5345493ab01a4b14`](https://github.com/Axolotl-Launcher/Axolotl/commit/2d75d79481fe18e4a934027d5345493ab01a4b14) | ✅ | ✅ |
| `main` | [`c9f46034f1056a73d2233d238a7af3526f9929c7`](https://github.com/Axolotl-Launcher/Axolotl/commit/c9f46034f1056a73d2233d238a7af3526f9929c7) | ⏳ | ⏳ |

<!-- END CACHED-COMMITS -->

| 图例  Legend |      描述      | Description |
|:------------:|:--------------:|:----------------:|
|     `✅`     | 缓存成功       | `Successfully cached` |
|   `❔❓❌`   | 构建失败1/2/3+ | `Build failed 1/2/3+` |
|     `💤`     | 无可用的flakes | `No available flakes` |
|     `⏳`     | 未知故障       | `Undetermined issues` |
