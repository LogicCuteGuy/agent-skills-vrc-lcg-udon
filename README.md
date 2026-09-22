**English** | [日本語](README.ja.md) | [简体中文](README.zh-CN.md) | [繁體中文](README.zh-TW.md) | [한국어](README.ko.md) | [ไทย](README.th.md)

<p align="center">
  <img src="https://img.shields.io/badge/VRChat_SDK-3.10.5-00b4d8?style=for-the-badge" alt="VRChat SDK" />
  <img src="https://img.shields.io/badge/UdonSharp-C%23_%E2%86%92_Udon-5C2D91?style=for-the-badge&logo=csharp&logoColor=white" alt="UdonSharp" />
  <img src="https://img.shields.io/badge/LCGUdonSharp-0.3.2-6f42c1?style=for-the-badge" alt="LCGUdonSharp 0.3.2" />
  <img src="https://img.shields.io/badge/AI_Agent-Skills_%26_Rules-ff6b35?style=for-the-badge" alt="Agent Skills" />
  <img src="https://img.shields.io/github/license/LogicCuteGuy/agent-skills-vrc-lcg-udon?style=for-the-badge" alt="License" />
</p>

<p align="center">
  <img src="https://img.shields.io/github/actions/workflow/status/LogicCuteGuy/agent-skills-vrc-lcg-udon/ci.yml?branch=dev&style=flat-square&label=CI" alt="CI" />
</p>

<h1 align="center">Agent Skills for VRChat UdonSharp</h1>

<p align="center">
  <b>Skills, rules, and validation hooks that teach AI coding agents to generate correct UdonSharp code</b>
</p>

<p align="center">
  <a href="#about">About</a> &bull;
  <a href="#install">Install</a> &bull;
  <a href="#structure">Structure</a> &bull;
  <a href="#skills">Skills</a> &bull;
  <a href="#rules">Rules</a> &bull;
  <a href="#hooks">Hooks</a> &bull;
  <a href="#contributing">Contributing</a> &bull;
  <a href="#disclaimer">Disclaimer</a>
</p>

---

<h2 id="about">About</h2>

VRChat world development with **UdonSharp** (C# &rarr; Udon Assembly) has strict compile constraints that differ significantly from standard C#. In stock Udon runtime code, features like `List<T>`, `async/await`, `try/catch`, LINQ, and lambdas cause **compile errors**. Editor-evaluated field initializers are a separate C# context and may use some of these features to generate a final field value that Udon supports. This repository also supports the `com.logiccuteguy.lcgudonsharp` compiler profile, whose documented lowering passes intentionally enable a restricted subset of interfaces, async, exceptions, LINQ closures, and extended language features.

### Choose the compiler profile first

The restrictions in this repository are **profile-specific**, not universal bans:

| Compiler profile | Runtime guidance |
|------------------|------------------|
| **Stock UdonSharp** | `List<T>`, `async/await`, `try/catch`, runtime LINQ/lambdas, interfaces, and unsupported generics are blocked. Use the stock alternatives documented by this repository. |
| **LCGUdonSharp 0.3.2** | When the live Unity project installs `com.logiccuteguy.lcgudonsharp`, restricted interfaces, async lowering, synchronous exceptions, `Where`/`Select` LINQ closures, closed generics, proven `dynamic`, array-backed `Span<T>`, exact lowered `List<T>` / `Dictionary<TKey,TValue>` collections with JSON support, and experimental `[LCGPacket]` are available within their documented boundaries. |

LCGUdonSharp is not unrestricted .NET: only the exact compiler-lowered `List<T>` and `Dictionary<TKey,TValue>` collection shapes are supported, other generic heap collections remain blocked, and only the async, exception, LINQ, collection/JSON, and language shapes listed in [`references/lcgudonsharp.md`](skills/unity-vrc-udon-sharp/references/lcgudonsharp.md) are available. Agents and validation hooks must inspect the live Unity project before applying the stock `NEVER` list; when the project cannot be inspected, they deliberately default to Stock UdonSharp.

This repository provides AI coding agents with the knowledge to generate correct UdonSharp code from the start.

| Problem | Solution |
|---------|----------|
| AI applies stock restrictions to an LCG project, or emits syntax outside the selected profile | Compiler-profile detection + profile-aware rules and hooks |
| Sync variable bloat | Decision tree + data budget |
| Incorrect networking patterns | Pattern library + anti-patterns |
| SDK version feature differences | Version table with feature mapping |
| Late Joiner state inconsistency | Sync pattern selection framework |

**This is NOT:**
- A VRChat SDK or UdonSharp distribution
- A Unity project (no executable code)
- A replacement for [official VRChat documentation](https://creators.vrchat.com/)
- A guarantee of all AI behaviors

> **Issues**: Bug reports and knowledge requests are welcome via [GitHub Issues](https://github.com/LogicCuteGuy/agent-skills-vrc-lcg-udon/issues).
> **PRs**: Pull Requests are not accepted. See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

---

<h2 id="install">Install</h2>

> **Migrating from fork/clone?** &mdash; Since v1.0.0, this project is distributed as an **npm package**. You no longer need to fork or clone the repository. Simply run one of the install commands below inside your VRChat Unity project. If you previously cloned this repo, you can safely delete the cloned directory and switch to the npm-based install.

### Method 1: skills CLI (recommended)

```bash
npx skills add LogicCuteGuy/agent-skills-vrc-lcg-udon
```

This uses the [skills.sh](https://skills.sh) ecosystem to install skills into your project.

### Method 2: Claude Code plugin

```bash
claude plugin marketplace add LogicCuteGuy/agent-skills-vrc-lcg-udon
claude plugin install vrc-udon-skills@agent-skills-vrc-udon
```

### Method 3: git clone

```bash
git clone https://github.com/LogicCuteGuy/agent-skills-vrc-lcg-udon.git
```

### Installing a specific version

The LCG fork is currently installed directly from GitHub and does not yet publish an npm package or version tags. To pin a reproducible revision, check out a specific commit SHA:

```bash
git clone https://github.com/LogicCuteGuy/agent-skills-vrc-lcg-udon.git
cd agent-skills-vrc-lcg-udon
git checkout <commit-sha>
```

---

<h2 id="structure">Structure</h2>

```
skills/                                  # All skills
  unity-vrc-udon-sharp/                 # UdonSharp core skill
    SKILL.md                              # Skill definition + frontmatter
    LICENSE.txt                           # MIT License
    CHEATSHEET.md                         # Quick reference (1 page)
    rules/                               # Constraint rules
      udonsharp-constraints.md
      udonsharp-networking.md
      udonsharp-sync-selection.md
    hooks/                               # PostToolUse validation
      validate-udonsharp.sh
      validate-udonsharp.ps1
    assets/templates/                    # Code templates (17 files)
    references/                          # Detailed documentation (26 files)
  unity-vrc-world-sdk-3/                # VRC World SDK skill
    SKILL.md, LICENSE.txt, CHEATSHEET.md, references/ (8 files)
templates/                               # AI tool config templates
  CLAUDE.md  AGENTS.md  GEMINI.md        # Distributed to users via installer
.claude-plugin/marketplace.json         # Claude Code plugin registration
CLAUDE.md                               # Development guide (this repo only)
```

---

<h2 id="skills">Skills</h2>

### unity-vrc-udon-sharp

UdonSharp scripting core skill. Covers compile constraints, networking, events, and templates.

| Area | Content |
|------|---------|
| **Constraints** | C# features blocked in Udon runtime, their alternatives (`List<T>` &rarr; `DataList`, `async` &rarr; `SendCustomEventDelayedSeconds`), and the Editor-evaluated initializer boundary |
| **LCGUdonSharp profile** | Auto-detected `com.logiccuteguy.lcgudonsharp` support for restricted interfaces, async, synchronous exceptions, LINQ closures, closed generics, `dynamic`, `Span<T>`, and `[LCGPacket]` |
| **Networking** | Ownership model, Manual/Continuous sync, FieldChangeCallback, anti-patterns |
| **NetworkCallable** | Introduced in SDK 3.8.1: parameterized network events (up to 8 args) |
| **Persistence** | Introduced in SDK 3.7.4: PlayerData/PlayerObject API |
| **Dynamics** | Introduced in SDK 3.10.0: PhysBones, Contacts, VRC Constraints for Worlds |
| **Web Loading** | String/Image download, VRCJson, VRCUrl constraints |
| **Templates** | 17 templates (interactions, sync patterns, persistence, editor utilities, and more) |

### unity-vrc-world-sdk-3

World-level scene setup, component placement, and optimization.

| Area | Content |
|------|---------|
| **Scene Setup** | VRC_SceneDescriptor, spawn points, Reference Camera |
| **Components** | VRC_Pickup, Station, ObjectSync, Mirror, Portal, CameraDolly |
| **Layers** | VRChat reserved layers and collision matrix |
| **Performance** | FPS targets, Quest/Android limits, optimization checklist |
| **Lighting** | Baked lighting best practices |
| **Audio/Video** | Spatial audio, video player selection (AVPro vs Unity) |
| **Upload** | Build and upload workflow, pre-upload checklist |

---

<h2 id="rules">Rules</h2>

Rules are constraint files that guide AI agents before code generation.

| Rule File | Content |
|-----------|---------|
| `udonsharp-constraints` | Blocked C# features, code generation rules, attributes, syncable types |
| `udonsharp-networking` | Ownership model, sync modes, anti-patterns, NetworkCallable constraints |
| `udonsharp-sync-selection` | Sync decision tree, data budget targets, 6 minimization principles |

**Networking rule:** A parameterless `public` method without a leading `_` is a legacy network entry. Prefix local-only/custom public methods with `_`, and use `[NetworkCallable]` to expose only intentional entries. Confirm `NetworkCalling.InNetworkCall` before reading `NetworkCalling.CallingPlayer`; authorize the caller separately from receiver ownership. Never use instance master as a security or access-control boundary.

### Sync Decision Tree

```
Q1: Visible to other players?
    No  --> No sync (0 bytes)
    Yes --> Q2

Q2: Late Joiner needs current state?
    No  --> Events only (0 bytes)
    Yes --> Q3

Q3: Continuous change? (position/rotation)
    Yes --> Continuous sync
    No  --> Manual sync (minimal [UdonSynced])
```

**Target**: < 50 bytes per behaviour. Small-medium worlds: < 100 bytes total.

---

<h2 id="hooks">Validation Hooks</h2>

PostToolUse hooks that auto-run when `.cs` files are edited.

| Category | Check | Severity |
|----------|-------|----------|
| Context-sensitive Features | `List<T>`, LINQ, lambdas (blocked in Udon runtime; may be valid in Editor-evaluated field initializers) | WARNING |
| Blocked Runtime Features | `async/await`, `try/catch`, coroutines | ERROR |
| Blocked Patterns | `AddListener()`, `StartCoroutine()` | ERROR |
| Networking | `[UdonSynced]` without `RequestSerialization()` | WARNING |
| Networking | `[UdonSynced]` without `Networking.SetOwner()` | WARNING |
| Sync Bloat | 6+ synced variables per behaviour | WARNING |
| Sync Bloat | `int[]`/`float[]` sync (recommend smaller types) | WARNING |
| Config Mismatch | `NoVariableSync` mode with `[UdonSynced]` fields | ERROR |

Supports both **Bash** (`validate-udonsharp.sh`) and **PowerShell** (`validate-udonsharp.ps1`).

The Bash validator requires `jq`. If `jq` is unavailable, it passes the input
through unchanged and emits `VALIDATOR-WARNING: validation skipped
(JQ_UNAVAILABLE)`; it does not silently claim that validation succeeded.

---

## SDK Versions

**Active support / last verified**: VRChat SDK 3.10.5

From v4.0.0 onward, the support policy is latest stable SDK only; the support target moves to a new stable release only after this repository verifies it. A new stable release is not supported automatically. Current last verified target: 3.10.5.

The table below keeps historical feature-introduction notes for migration reference. SDK 3.7.1-3.10.4 entries are historical information only; they are not active support or validation targets for this Skill. This is the Skill's support boundary, not a statement about VRChat's own SDK policy.

| SDK Version | Key Features | Status |
|:-----------:|:-------------|:------:|
| **3.7.1** | `StringBuilder`, `Regex`, `System.Random` | Historical |
| **3.7.4** | Persistence API (PlayerData / PlayerObject) | Historical |
| **3.7.6** | Multi-platform Build & Publish (PC + Android) | Historical |
| **3.8.0** | PhysBone dependency sorting, Force Kinematic On Remote | Historical |
| **3.8.1** | `[NetworkCallable]` parameterized events, `Others`/`Self` targets | Historical |
| **3.9.0** | Camera Dolly API, Auto Hold pickup | Historical |
| **3.10.0** | VRChat Dynamics for Worlds (PhysBones, Contacts, VRC Constraints) | Historical |
| **3.10.1** | Bug fixes, stability improvements | Historical |
| **3.10.2** | EventTiming.PostLateUpdate/FixedUpdate, PhysBones fixes, shader time globals | Historical |
| **3.10.3** | `VRCPlayerApi.isVRCPlus`, VRCRaycast (avatar), Mirror render-order fix | Historical |
| **3.10.4** | VRCTween, Box-shaped Contacts, Global Avatar PhysBone Colliders, world `VRCPhysBoneCollider` Udon access, DataList/DataDictionary capacity APIs | Historical |
| **3.10.5** | WorldQualitySettings, writable VRCQualitySettings, Assembly Version Defines, Pickup Outline Renderers, Pipeline Manager validation | Active / Last verified |

> **Note**: Before publishing, confirm that the project uses an SDK version currently supported by VRChat.

---

## Official Resources

| Resource | URL |
|----------|-----|
| VRChat Creators Docs | https://creators.vrchat.com/ |
| UdonSharp API Reference | https://udonsharp.docs.vrchat.com/ |
| VRChat Forums (Q&A) | https://ask.vrchat.com/ |
| VRChat Canny (Bugs/Features) | https://feedback.vrchat.com/ |
| VRChat Community GitHub | https://github.com/vrchat-community |

---

<h2 id="community-contributors">Community Contributors</h2>

This project has benefited from people who took the time to file concrete Issues and help verify the fixes. Thank you to:

<!-- community-contributors:start -->
<p>
<a href="https://github.com/KatanoShingo" title="@KatanoShingo"><img src="https://github.com/KatanoShingo.png?size=64" width="64" height="64" alt="@KatanoShingo"></a>
<a href="https://github.com/Guribo" title="@Guribo"><img src="https://github.com/Guribo.png?size=64" width="64" height="64" alt="@Guribo"></a>
<a href="https://github.com/haru0416-dev" title="@haru0416-dev"><img src="https://github.com/haru0416-dev.png?size=64" width="64" height="64" alt="@haru0416-dev"></a>
<a href="https://github.com/Yodokoro" title="@Yodokoro"><img src="https://github.com/Yodokoro.png?size=64" width="64" height="64" alt="@Yodokoro"></a>
<a href="https://github.com/tetradice" title="@tetradice"><img src="https://github.com/tetradice.png?size=64" width="64" height="64" alt="@tetradice"></a>
<a href="https://github.com/owlboy" title="@owlboy"><img src="https://github.com/owlboy.png?size=64" width="64" height="64" alt="@owlboy"></a>
<a href="https://github.com/nomlasvrc" title="@nomlasvrc"><img src="https://github.com/nomlasvrc.png?size=64" width="64" height="64" alt="@nomlasvrc"></a>
<a href="https://github.com/ureishi" title="@ureishi"><img src="https://github.com/ureishi.png?size=64" width="64" height="64" alt="@ureishi"></a>
<a href="https://github.com/irucaVRC" title="@irucaVRC"><img src="https://github.com/irucaVRC.png?size=64" width="64" height="64" alt="@irucaVRC"></a>
</p>
<!-- community-contributors:end -->

---

<h2 id="contributing">Contributing</h2>

**Issues are welcome** -- bug reports and knowledge requests help improve this project.

**Pull Requests are not accepted** -- all fixes and updates are made by the maintainer.

See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

---

<h2 id="disclaimer">Disclaimer</h2>

> **This project is not affiliated with VRChat Inc. No official endorsement, partnership, or association is implied.**
>
> "VRChat", "UdonSharp", "Udon" and related names/logos are trademarks of VRChat Inc. All trademarks belong to their respective owners.
>
> This repository is a **personal knowledge base** for AI coding agents to generate correct UdonSharp code. It does not distribute any part of the VRChat SDK or UdonSharp compiler.

### Accuracy

- Content is provided **"AS IS"** without warranty. See [LICENSE](LICENSE).
- This is a personal project. **Errors, outdated information, or incomplete content may exist.** Always verify against [official VRChat documentation](https://creators.vrchat.com/).
- The author assumes no liability for issues caused by this repository (build errors, upload rejections, unexpected world behavior, etc.).
- Active SDK support is limited to 3.10.5, the last verified target. Older version entries are historical migration information, not a promise to test or fix those SDKs. Behavior may change with new VRChat releases.

### AI-Assisted Creation

This knowledge base was created and maintained with AI tool assistance (Claude, Gemini, Codex). All content has been reviewed, but AI-generated portions may contain subtle errors. Use at your own risk.

---

## License

This project is licensed under the **MIT License**. See [LICENSE](LICENSE) for details.

Fork, modify, and redistribute freely under MIT License terms. This license applies to the documentation, rules, templates, and hooks in this repository. It does **not** grant any rights to VRChat's SDK, UdonSharp compiler, or other VRChat intellectual property.
