<div align="center">

<h1>Setup Arturo</h1> 

### Install & use Arturo on any GitHub runner

![License](https://img.shields.io/github/license/arturo-lang/setup-arturo?style=for-the-badge) [![Build Status](https://img.shields.io/github/actions/workflow/status/arturo-lang/setup-arturo/matrix.yml?branch=main&style=for-the-badge)](https://github.com/arturo-lang/setup-arturo/actions) 
</div>

---

<!--ts-->
   * [Quick Start](#quick-start)
   * [More Examples](#more-examples)
      * [Native builds](#native-builds)
      * [Cross-platform matrix](#cross-platform-matrix)
      * [Compilation from source](#compilation-from-source)
      * [Using nightly builds](#using-nightly-builds)
   * [Options](#options)
   * [Supported Platforms](#supported-platforms)
   * [License](#license)
<!--te-->

---

## Quick Start

```yaml
- name: Install Arturo
  uses: arturo-lang/setup-arturo@v2
  with: 
    token: ${{ secrets.GITHUB_TOKEN }}
```

> [!NOTE]
> If all you need is to have Arturo available as part of your workflow, chances are all you'll have to do in most cases is to include the step above (^), and the action will auto-detect your runner/OS, fetch the appropriate version, etc. No configuration needed at all! 😉

> [!TIP]
> Want the single fastest runner there is, *with* Arturo enabled? Use macOS on arm64 (basically: `macos-latest`). The whole environment setup easily averages 20 seconds!

## More Examples

### Native builds

```yaml
jobs:
  build:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v6
      
      - name: Install Arturo
        uses: arturo-lang/setup-arturo@v2
        with: 
          token: ${{ secrets.GITHUB_TOKEN }}

      - name: Run script
        run: arturo script.art
```

> [!CAUTION]
> Pre-built MINI binaries on `ubuntu-22.04-arm` (ARM64) don't work well!
>
> In general, it's recommended to use the latest runners (ubuntu-latest, macos-latest, windows-latest) for best compatibility.

### Cross-platform matrix

```yaml
jobs:
  test:
    runs-on: ${{ 
      (matrix.os == 'windows' && matrix.arch == 'arm64') && 'windows-11-arm' ||
      (matrix.os == 'windows')                           && 'windows-latest' || 
      (matrix.os == 'macos' && matrix.arch == 'arm64')   && 'macos-latest'   || 
      (matrix.os == 'macos')                             && 'macOS-15-intel' || 
                                                            'ubuntu-latest'  }}
    strategy:
      matrix:
        include: 
          - {os: linux,   arch: amd64, mode: full}
          - {os: linux,   arch: arm64, mode: mini}
          - {os: windows, arch: amd64, mode: full}
          - {os: windows, arch: arm64, mode: full, do: compile}
          - {os: macos,   arch: amd64, mode: full}
          - {os: macos,   arch: arm64, mode: full}
          - {os: freebsd, arch: amd64, mode: full}
          - {os: web}

    defaults:
      run:
        shell: ${{ 
          (matrix.os == 'freebsd') && 'freebsd {0}' ||
          (matrix.os == 'windows') && 'msys2 {0}'   || 
                                      'bash'        }}

    steps:
      - uses: actions/checkout@v6
      
      - name: Install Arturo
        uses: arturo-lang/setup-arturo@v2
        with: 
          token: ${{ secrets.GITHUB_TOKEN }}
          do: ${{ matrix.do || 'fetch' }}
          os: ${{ matrix.os }}
          arch: ${{ matrix.arch }}
          mode: ${{ matrix.mode }}
      
      - name: Test
        run: arturo tests/test.art
```

> [!NOTE]
> There are no pre-built Windows/arm64 releases yet: on `windows-11-arm`, use `do: compile` (as above).

### Compilation from source

```yaml
- name: Build Arturo from source
  uses: arturo-lang/setup-arturo@v2
  with: 
    token: ${{ secrets.GITHUB_TOKEN }}
    do: compile
    src: main              # or specific branch/tag/commit
    mode: full
    create_artifact: true
    artifact_version: "0.9.85"
```

### Using nightly builds

```yaml
- name: Install Arturo (nightly)
  uses: arturo-lang/setup-arturo@v2
  with: 
    token: ${{ secrets.GITHUB_TOKEN }}
    from: latest           # Use nightly builds instead of stable
```

## Options

| Option | Values | Default | Notes |
|--------|--------|---------|-------|
| `token` | GitHub token | *required* | Use `${{ secrets.GITHUB_TOKEN }}` |
| `do` | `fetch`, `compile` | `fetch` | Fetch release or compile from source |
| `from` | `latest`, `stable` | `stable` | Source repository for fetch mode (`latest` = nightly builds) |
| `mode` | `mini`, `full`, `noui` | `full` | Build configuration (`noui`: full, minus the UI - compile mode only) |
| `os` | `linux`, `windows`, `macos`, `freebsd`, `web`, `wasi` | auto-detect | Target platform |
| `arch` | `amd64`, `arm64`, `js`, `wasm32` | auto-detect | Target architecture |
| `support` | `standard`, `legacy` | auto-detect | For older Ubuntu systems (webkit 4.0 vs 4.1) |
| `src` | branch/tag/commit | latest | Specific Arturo version (compile mode) |
| `metadata` | string | - | Build metadata (compile mode) |
| `create_artifact` | `true`, `false` | `false` | Upload build artifact |
| `artifact_version` | string | - | Version string for artifact naming (compile mode) |
| `artifacts_only` | `true`, `false` | `false` | Skip setup, download & re-upload artifacts only (fetch mode) |
| `release` | `true`, `false` | `false` | It's an official release (compile mode only) |
| `pgo` | `true`, `false` | `false` | Build with profile-guided optimization: slower build, faster binary (compile mode only) |
| `timezone` | time zone name, or empty | `UTC` | Time zone to set the runner to - GitHub-hosted runners only (empty = leave it as is) |

## Supported Platforms

| OS | Architecture | Mode | Fetch | Compile | Runner |
|----|--------------|------|:-----:|:-------:|--------|
| Linux | amd64, arm64 | mini, full | ✅ | ✅ | ubuntu-latest, ubuntu-22.04, ubuntu-24.04-arm, ubuntu-24.04 |
| Linux | amd64, arm64 | noui | ❌ | ✅ | ubuntu-latest, ubuntu-24.04, ubuntu-24.04-arm |
| Windows | amd64 | mini, full | ✅ | ✅ | windows-latest |
| Windows | arm64 | mini, full | ❌ | ✅ | windows-11-arm |
| macOS | amd64, arm64 | mini, full | ✅ | ✅ | macOS-15-intel, macos-latest |
| FreeBSD | amd64 | mini, full | ✅ | ✅ | ubuntu-latest (via VM) |
| FreeBSD | arm64 | mini, full | ❌ | ✅ | ubuntu-latest (via VM, emulated - slow) |
| Web | js | mini | ✅ | ✅ | ubuntu-latest |
| WASI | wasm32 | mini | ❌ | ✅ | ubuntu-latest |

> [!NOTE]
> ### No-UI builds
> `mode: noui` (Linux only) is a full build without anything UI-related (`webview`, dialogs & clipboard): that means no GTK/WebKit to install - nor to link against. It's meant for headless setups (servers, containers, CI) where everything else of the full build is still wanted. For now, it's available in compile mode only (`do: compile`).

> [!NOTE]
> ### WASI builds
> `os: wasi` (or `arch: wasm32`) builds Arturo as a WebAssembly binary (`arturo.wasm`), for WASI runtimes - outside the browser. It's always a mini build, with 32-bit integers; and there are no processes, networking or signals. The action installs [wasmtime](https://wasmtime.dev) to run it with, e.g.:
>
> ```bash
> wasmtime run --dir /::/ --env HOME --env PWD ~/.arturo/bin/arturo.wasm script.art
> ```
>
> For now, it's available in compile mode only (`do: compile`).

> [!NOTE]
> ### Windows on ARM
> On `windows-11-arm`, the action uses MSYS2's `CLANGARM64` environment (there's no GCC for Windows/arm64) along with a pre-built Nim for arm64, so Arturo is compiled with clang. Your steps can still use `shell: msys2 {0}`, exactly as on `windows-latest`.

> [!NOTE]
> ### Time Zone
> Not all GitHub-hosted runners are on UTC (e.g. `windows-11-arm` is on Pacific Time), so anything depending on the local time zone - like date arithmetic across DST changes - may give different results on each of them. That's why, by default, the action sets GitHub-hosted runners to UTC (via `tzutil` on Windows; `timedatectl`, or `/etc/localtime`, on Linux/macOS).
>
> Self-hosted runners are never touched, since the change would outlive the job. To leave GitHub-hosted runners as they are, set `timezone: ''`.
>
> Any other time zone has to be named the way the runner's OS does: e.g. `Europe/Madrid` on Linux/macOS, but `Romance Standard Time` on Windows (`UTC` works everywhere).

> [!NOTE] 
> ### Legacy Support
> For older Ubuntu runners (< 24.04), the action automatically detects and uses WebKit 4.0 instead of 4.1. You can also explicitly set `support: legacy` to force this behavior.

---

## License

MIT License

Copyright (c) 2019-2026 Yanis Zafirópulos (aka Dr.Kameleon)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.