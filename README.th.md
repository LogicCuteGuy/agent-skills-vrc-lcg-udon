[English](README.md) | [日本語](README.ja.md) | [简体中文](README.zh-CN.md) | [繁體中文](README.zh-TW.md) | [한국어](README.ko.md) | **ไทย**

<p align="center">
  <img src="https://img.shields.io/badge/VRChat_SDK-3.10.5-00b4d8?style=for-the-badge" alt="VRChat SDK" />
  <img src="https://img.shields.io/badge/UdonSharp-C%23_%E2%86%92_Udon-5C2D91?style=for-the-badge&logo=csharp&logoColor=white" alt="UdonSharp" />
  <img src="https://img.shields.io/badge/LCGUdonSharp-0.3.4-6f42c1?style=for-the-badge" alt="LCGUdonSharp 0.3.4" />
  <img src="https://img.shields.io/badge/AI_Agent-Skills_%26_Rules-ff6b35?style=for-the-badge" alt="สกิลเอเจนต์ AI" />
  <img src="https://img.shields.io/github/license/LogicCuteGuy/agent-skills-vrc-lcg-udon?style=for-the-badge" alt="สัญญาอนุญาต" />
</p>

<p align="center">
  <img src="https://img.shields.io/github/actions/workflow/status/LogicCuteGuy/agent-skills-vrc-lcg-udon/ci.yml?branch=dev&style=flat-square&label=CI" alt="CI" />
</p>

<h1 align="center">Agent Skills for VRChat UdonSharp</h1>

<p align="center">
  <b>สกิล กฎ และฮุกตรวจสอบที่สอนให้เอเจนต์เขียนโค้ด AI สร้างโค้ด UdonSharp ที่ถูกต้องตั้งแต่แรก</b>
</p>

<p align="center">
  <a href="#about">เกี่ยวกับ</a> &bull;
  <a href="#install">ติดตั้ง</a> &bull;
  <a href="#structure">โครงสร้าง</a> &bull;
  <a href="#skills">สกิล</a> &bull;
  <a href="#rules">กฎ</a> &bull;
  <a href="#hooks">ฮุก</a> &bull;
  <a href="#contributing">มีส่วนร่วม</a> &bull;
  <a href="#disclaimer">ข้อจำกัดความรับผิดชอบ</a>
</p>

> ติดตั้ง LCGUdonSharp 0.3.4 ผ่าน VCC/ALCOM หรือไฟล์ ZIP แพ็กเกจที่แนบในรีลีส ไฟล์ซอร์สที่ GitHub สร้างอัตโนมัติไม่ใช่แพ็กเกจสำหรับติดตั้งใน Unity ให้นำเข้าตัวอย่างเสริมหลังติดตั้งคอมไพเลอร์เสร็จแล้ว [LCGUdonSharp 0.3.4](https://github.com/LogicCuteGuy/LCGUdonSharp/releases/tag/0.3.4)

---

<h2 id="about">เกี่ยวกับ</h2>

การพัฒนาเวิลด์ VRChat ด้วย **UdonSharp** (C# → Udon Assembly) มีข้อจำกัดการคอมไพล์ที่เข้มงวดซึ่งต่างจาก C# มาตรฐานอย่างมาก ในโค้ด Udon runtime ตามปกติ ฟีเจอร์อย่าง `List<T>`, `async/await`, `try/catch`, LINQ และ lambda ทำให้เกิด **ข้อผิดพลาดการคอมไพล์** initializer ของฟิลด์ที่ประเมินในตอน Editor เป็นบริบท C# คนละส่วน และอาจใช้ฟีเจอร์เหล่านี้บางส่วนเพื่อสร้างค่าฟิลด์ขั้นสุดท้ายที่ Udon รองรับ รี포ซิทรีนี้ยังรองรับโปรไฟล์ `com.logiccuteguy.lcgudonsharp` ซึ่งพาสการลดระดับ (lowering) ที่มีเอกสารกำหนดไว้จะเปิดใช้งานชุดย่อยที่จำกัดของ interface, async, exception, LINQ closure และฟีเจอร์ภาษาที่ขยายเพิ่มโดยเจตนา

### เลือกโปรไฟล์คอมไพเลอร์ก่อน

ข้อจำกัดในรีปอซิทรีนี้เป็นข้อจำกัด **เฉพาะโปรไฟล์** ไม่ใช่ข้อห้ามที่ใช้กับทุกโปรไฟล์:

| โปรไฟล์คอมไพเลอร์ | แนวทางสำหรับโค้ด runtime |
|--------------------|---------------------------|
| **Stock UdonSharp** | ไม่รองรับ `List<T>`, `async/await`, `try/catch`, LINQ/lambda ตอน runtime, interface และ generic ที่อยู่นอกชุดรองรับ ให้ใช้ทางเลือกของ Stock ที่เอกสารนี้ระบุ |
| **LCGUdonSharp 0.3.4** | เมื่อโปรเจกต์ Unity ที่กำลังใช้งานติดตั้ง `com.logiccuteguy.lcgudonsharp` จะใช้ interface แบบจำกัด, async lowering, exception แบบ synchronous, LINQ closure ของ `Where`/`Select`, closed generic, `dynamic` ที่พิสูจน์ชนิดได้, `Span<T>` ที่มี array รองรับ, `List<T>` / `Dictionary<TKey,TValue>` รูปแบบตรงที่ lowering พร้อม JSON และ `[LCGPacket]` แบบทดลองได้ภายในขอบเขตที่ระบุไว้ |

LCGUdonSharp ไม่ใช่ .NET แบบไร้ข้อจำกัด: รองรับเฉพาะ `List<T>` และ `Dictionary<TKey,TValue>` รูปแบบตรงที่คอมไพเลอร์ lowering ส่วน generic heap collection อื่นยังใช้ไม่ได้ และรองรับเฉพาะรูปแบบ async, exception, LINQ, collection/JSON และภาษาที่ระบุใน [`references/lcgudonsharp.md`](skills/unity-vrc-udon-sharp/references/lcgudonsharp.md) เท่านั้น เอเจนต์และ validation hook ต้องตรวจโปรเจกต์ Unity ที่กำลังใช้งานก่อนนำรายการ `NEVER` ของ Stock มาใช้ หากตรวจโปรเจกต์ไม่ได้ ระบบจะเลือก Stock UdonSharp โดยตั้งใจ

รีปอซิทรีนี้มอบความรู้ที่จำเป็นให้เอเจนต์เขียนโค้ด AI ในการสร้างโค้ด UdonSharp ที่ถูกต้องตั้งแต่เริ่มต้น

| ปัญหา | วิธีแก้ |
|---------|----------|
| AI นำข้อจำกัดของ Stock ไปใช้กับโปรเจกต์ LCG หรือสร้าง syntax ที่อยู่นอกโปรไฟล์ที่เลือก | ตรวจจับโปรไฟล์คอมไพเลอร์ + กฎและฮุกที่รับรู้โปรไฟล์ |
| ตัวแปรซิงก์ล้นมากเกินไป | ต้นไม้ตัดสินใจ + งบประมาณข้อมูล |
| รูปแบบการเน็ตเวิร์กที่ไม่ถูกต้อง | คลังรูปแบบ + รูปแบบต้องห้าม |
| ฟีเจอร์ต่างกันตามเวอร์ชัน SDK | ตารางเวอร์ชันพร้อมแผนที่ฟีเจอร์ |
| Late Joiner สถานะไม่สอดคล้องกัน | กรอบการเลือกรูปแบบซิงก์ |

**นี่ไม่ใช่:**
- SDK VRChat หรือการแจกจ่าย UdonSharp
- โปรเจกต์ Unity (ไม่มีโค้ดที่รันได้)
- ตัวแทน [เอกสาร VRChat ทางการ](https://creators.vrchat.com/)
- การรับประกันพฤติกรรมของ AI ทุกกรณี

> **Issues**: ยินดีรับรายงานข้อผิดพลาดและคำขอความรู้ผ่าน [GitHub Issues](https://github.com/LogicCuteGuy/agent-skills-vrc-lcg-udon/issues)
> **PRs**: ไม่รับ Pull Requests ดูรายละเอียดที่ [CONTRIBUTING.md](CONTRIBUTING.md)

---

<h2 id="install">ติดตั้ง</h2>

> **กำลังย้ายจากการ fork/clone?** &mdash; ตั้งแต่ v1.0.0 เป็นต้นไป โปรเจกต์นี้แจกจ่ายเป็น**แพ็กเกจ npm** คุณไม่จำเป็นต้อง fork หรือ clone รี포ซิทรีอีกต่อไป แค่รันคำสั่งติดตั้งด้านล่างใดก็ได้ภายในโปรเจกต์ Unity ของ VRChat ถ้าคุณเคย clone รี포ซิทรีนี้ สามารถลบที่ clone ไว้แล้วเปลี่ยนไปใช้การติดตั้งผ่าน npm ได้อย่างปลอดภัย

### วิธีที่ 1: skills CLI (แนะนำ)

```bash
npx skills add LogicCuteGuy/agent-skills-vrc-lcg-udon
```

วิธีนี้ใช้ระบบนิเวศ [skills.sh](https://skills.sh) เพื่อติดตั้งสกิลเข้าไปในโปรเจกต์ของคุณ

### วิธีที่ 2: ปลั๊กอิน Claude Code

```bash
claude plugin marketplace add LogicCuteGuy/agent-skills-vrc-lcg-udon
claude plugin install vrc-udon-skills@agent-skills-vrc-udon
```

### วิธีที่ 3: git clone

```bash
git clone https://github.com/LogicCuteGuy/agent-skills-vrc-lcg-udon.git
```

### ติดตั้งเวอร์ชันที่ระบุ

ปัจจุบัน fork ของ LCG ติดตั้งโดยตรงจาก GitHub และยังไม่มีแพ็กเกจ npm หรือ version tag หากต้องการล็อก revision ที่ทำซ้ำได้ ให้ checkout commit SHA ที่ระบุ:

```bash
git clone https://github.com/LogicCuteGuy/agent-skills-vrc-lcg-udon.git
cd agent-skills-vrc-lcg-udon
git checkout <commit-sha>
```

---

<h2 id="structure">โครงสร้าง</h2>

```
skills/                                  # สกิลทั้งหมด
  unity-vrc-udon-sharp/                 # สกิลหลัก UdonSharp
    SKILL.md                              # นิยามสกิล + frontmatter
    LICENSE.txt                           # สัญญาอนุญาต MIT
    CHEATSHEET.md                         # แผ่นอ้างอิงรวดเร็ว (1 หน้า)
    rules/                               # กฎข้อจำกัด
      udonsharp-constraints.md
      udonsharp-networking.md
      udonsharp-sync-selection.md
    hooks/                               # ตรวจสอบหลังใช้เครื่องมือ (PostToolUse)
      validate-udonsharp.sh
      validate-udonsharp.ps1
    assets/templates/                    # เทมเพลตโค้ด (17 ไฟล์)
    references/                          # เอกสารอธิบายรายละเอียด (26 ไฟล์)
  unity-vrc-world-sdk-3/                # สกิล VRC World SDK
    SKILL.md, LICENSE.txt, CHEATSHEET.md, references/ (8 ไฟล์)
templates/                               # เทมเพลตคอนฟิกสำหรับเครื่องมือ AI
  CLAUDE.md  AGENTS.md  GEMINI.md        # แจกจ่ายให้ผู้ใช้ผ่านตัวติดตั้ง
.claude-plugin/marketplace.json         # ลงทะเบียนปลั๊กอิน Claude Code
CLAUDE.md                               # คู่มือการพัฒนา (เฉพาะรีปอซิทรีนี้)
```

---

<h2 id="skills">สกิล</h2>

### unity-vrc-udon-sharp

สกิลหลักการสคริปต์ UdonSharp ครอบคลุมข้อจำกัดการคอมไพล์ เน็ตเวิร์ก อีเวนต์ และเทมเพลต

| พื้นที่ | เนื้อหา |
|------|---------|
| **Constraints** | ฟีเจอร์ C# ที่ถูกบล็อกใน Udon runtime พร้อมทางเลือกใช้งาน (`List<T>` &rarr; `DataList`, `async` &rarr; `SendCustomEventDelayedSeconds`) และขอบเขต initializer ที่ประเมินตอน Editor |
| **LCGUdonSharp profile** | ตรวจพบอัตโนมัติ `com.logiccuteguy.lcgudonsharp` รองรับ interface ที่จำกัด, async, exception แบบ synchronous, LINQ closure, generic แบบปิด, `dynamic`, `Span<T>` และ `[LCGPacket]` |
| **Networking** | โมเดล ownership, โหมดซิงก์ Manual/Continuous, FieldChangeCallback, รูปแบบต้องห้าม |
| **NetworkCallable** | แนะนำใน SDK 3.8.1: อีเวนต์เน็ตเวิร์กที่มีพารามิเตอร์ (สูงสุด 8 อาร์กิวเมนต์) |
| **Persistence** | แนะนำใน SDK 3.7.4: API PlayerData/PlayerObject |
| **Dynamics** | แนะนำใน SDK 3.10.0: PhysBones, Contacts, VRC Constraints สำหรับเวิลด์ |
| **Web Loading** | ดาวน์โหลด String/Image, VRCJson, ข้อจำกัด VRCUrl |
| **Templates** | 17 เทมเพลต (interaction, รูปแบบซิงก์, persistence, utility สำหรับ Editor และอื่น ๆ) |

### unity-vrc-world-sdk-3

การตั้งค่าซีนระดับเวิลด์ การวางคอมโพเนนต์ และการปรับประสิทธิภาพ

| พื้นที่ | เนื้อหา |
|------|---------|
| **Scene Setup** | VRC_SceneDescriptor, จุดเกิด, Reference Camera |
| **Components** | VRC_Pickup, Station, ObjectSync, Mirror, Portal, CameraDolly |
| **Layers** | เลเยอร์สงวนของ VRChat และตารางชนิดกัน |
| **Performance** | เป้าหมาย FPS, ขีดจำกัด Quest/Android, รายการตรวจสอบการปรับประสิทธิภาพ |
| **Lighting** | แนวทางปฏิบัติที่ดีที่สุดสำหรับแสงแบบ bake |
| **Audio/Video** | เสียงเชิงพื้นที่ การเลือกตัวเล่นวิดีโอ (AVPro เทียบกับ Unity) |
| **Upload** | ขั้นตอน build และอัปโหลด รายการตรวจสอบก่อนอัปโหลด |

---

<h2 id="rules">กฎ</h2>

กฎคือไฟล์ข้อจำกัดที่นำทางเอเจนต์ AI ก่อนการสร้างโค้ด

| ไฟล์กฎ | เนื้อหา |
|-----------|---------|
| `udonsharp-constraints` | ฟีเจอร์ C# ที่ถูกบล็อก กฎการสร้างโค้ด attribute ชนิดที่ซิงก์ได้ |
| `udonsharp-networking` | โมเดล ownership โหมดซิงก์ รูปแบบต้องห้าม ข้อจำกัด NetworkCallable |
| `udonsharp-sync-selection` | ต้นไม้ตัดสินใจซิงก์ เป้าหมายงบประมาณข้อมูล หลักการลดขนาด 6 ข้อ |

**กฎการเน็ตเวิร์ก:** เมธอด `public` ที่ไม่มีพารามิเตอร์และไม่ขึ้นต้นด้วย `_` คือจุดเข้าเน็ตเวิร์กแบบเดิม ให้ขึ้นต้นเมธอดสาธารณะที่ใช้เฉพาะในเครื่องหรือปรับแต่งเองด้วย `_` และใช้ `[NetworkCallable]` เพื่อเปิดจุดเข้าที่ตั้งใจไว้เท่านั้น ยืนยัน `NetworkCalling.InNetworkCall` ก่อนอ่าน `NetworkCalling.CallingPlayer` และอนุญาตผู้เรียกแยกจากการเป็นเจ้าของฝั่งผู้รับ ห้ามใช้ instance master เป็นขอบเขตความปลอดภัยหรือการควบคุมการเข้าถึง

### ต้นไม้ตัดสินใจการซิงก์

```
Q1: ผู้เล่นคนอื่นมองเห็นหรือไม่?
    ไม่ --> ไม่ต้องซิงก์ (0 ไบต์)
    ใช่ --> Q2

Q2: Late Joiner ต้องการสถานะปัจจุบันหรือไม่?
    ไม่ --> มีแค่อีเวนต์ (0 ไบต์)
    ใช่ --> Q3

Q3: เปลี่ยนแปลงต่อเนื่องหรือไม่? (ตำแหน่ง/การหมุน)
    ใช่ --> ซิงก์ต่อเนื่อง
    ไม่ --> ซิงก์ Manual ([UdonSynced] น้อยที่สุด)
```

**เป้าหมาย**: ต่ำกว่า 50 ไบต์ต่อ behaviour เวิลด์ขนาดเล็กถึงกลาง: รวมต่ำกว่า 100 ไบต์

---

<h2 id="hooks">ฮุกตรวจสอบ</h2>

ฮุก PostToolUse ที่ทำงานอัตโนมัติเมื่อมีการแก้ไขไฟล์ `.cs`

| หมวด | ตรวจสอบ | ระดับ |
|----------|-------|----------|
| ฟีเจอร์ที่ขึ้นกับบริบท | `List<T>`, LINQ, lambda (ถูกบล็อกใน Udon runtime แต่อาจใช้ได้ใน field initializer ที่ประเมินตอน Editor) | WARNING |
| ฟีเจอร์รันไทม์ที่ถูกบล็อก | `async/await`, `try/catch`, coroutine | ERROR |
| รูปแบบที่ถูกบล็อก | `AddListener()`, `StartCoroutine()` | ERROR |
| Networking | `[UdonSynced]` โดยไม่เรียก `RequestSerialization()` | WARNING |
| Networking | `[UdonSynced]` โดยไม่เรียก `Networking.SetOwner()` | WARNING |
| ตัวแปรซิงก์ล้น | ตัวแปรซิงก์ 6 ตัวขึ้นไปต่อ behaviour | WARNING |
| ตัวแปรซิงก์ล้น | ซิงก์ `int[]`/`float[]` (แนะนำชนิดที่เล็กกว่า) | WARNING |
| คอนฟิกไม่ตรง | โหมด `NoVariableSync` กับฟิลด์ `[UdonSynced]` | ERROR |

รองรับทั้ง **Bash** (`validate-udonsharp.sh`) และ **PowerShell** (`validate-udonsharp.ps1`)

ตัวตรวจสอบ Bash ต้องการ `jq` ถ้าไม่มี `jq` จะส่งข้อมูลอินพุตผ่านไปโดยไม่เปลี่ยนแปลงและแจ้ง `VALIDATOR-WARNING: validation skipped (JQ_UNAVAILABLE)` ออกมา โดยจะไม่ประกาศอย่างเงียบ ๆ ว่าการตรวจสอบสำเร็จแล้ว

---

## เวอร์ชัน SDK

**กำลังสนับสนุน / ตรวจสอบล่าสุด**: VRChat SDK 3.10.5

ตั้งแต่ v4.0.0 เป็นต้นไป นโยบายการสนับสนุนคือรองรับ SDK เวอร์ชันเสถียรล่าสุดเท่านั้น และจะย้ายเป้าหมายการสนับสนุนไปยังเวอร์ชันเสถียรใหม่ก็ต่อเมื่อคลังเก็บนี้ตรวจสอบยืนยันแล้ว เวอร์ชันเสถียรใหม่จะได้รับการสนับสนุนโดยอัตโนมัติไม่ได้ เป้าหมายที่ตรวจสอบล่าสุดในปัจจุบัน: 3.10.5

ตารางด้านล่างเก็บบันทึกการแนะนำฟีเจอร์ตามประวัติไว้เพื่อการอ้างอิงการย้ายระบบ รายการ SDK 3.7.1-3.10.4 เป็นข้อมูลประวัติเท่านั้น ไม่ใช่เป้าหมายการสนับสนุนหรือการตรวจสอบของสกิลนี้ นี่คือขอบเขตการสนับสนุนของสกิล ไม่ใช่คำแถลงเกี่ยวกับนโยบาย SDK ของ VRChat เอง

| เวอร์ชัน SDK | ฟีเจอร์สำคัญ | สถานะ |
|:-----------:|:-------------|:------:|
| **3.7.1** | `StringBuilder`, `Regex`, `System.Random` | ประวัติ |
| **3.7.4** | Persistence API (PlayerData / PlayerObject) | ประวัติ |
| **3.7.6** | Build & Publish หลายแพลตฟอร์ม (PC + Android) | ประวัติ |
| **3.8.0** | การจัดลำดับ dependency ของ PhysBone, Force Kinematic On Remote | ประวัติ |
| **3.8.1** | อีเวนต์มีพารามิเตอร์ `[NetworkCallable]`, เป้าหมาย `Others`/`Self` | ประวัติ |
| **3.9.0** | Camera Dolly API, Auto Hold pickup | ประวัติ |
| **3.10.0** | VRChat Dynamics สำหรับเวิลด์ (PhysBones, Contacts, VRC Constraints) | ประวัติ |
| **3.10.1** | แก้ไขบั๊ก ปรับปรุงความเสถียร | ประวัติ |
| **3.10.2** | EventTiming.PostLateUpdate/FixedUpdate, แก้ไข PhysBones, global ของเวลา shader | ประวัติ |
| **3.10.3** | `VRCPlayerApi.isVRCPlus`, VRCRaycast (avatar), แก้ลำดับการเรนเดอร์ Mirror | ประวัติ |
| **3.10.4** | VRCTween, Contacts รูปทรงกล่อง, Global Avatar PhysBone Colliders, การเข้าถึง `VRCPhysBoneCollider` ของเวิลด์ผ่าน Udon, API ความจุ DataList/DataDictionary | ประวัติ |
| **3.10.5** | WorldQualitySettings, VRCQualitySettings ที่เขียนได้, Assembly Version Defines, Pickup Outline Renderers, การตรวจสอบ Pipeline Manager | ปัจจุบัน / ตรวจสอบล่าสุด |

> **หมายเหตุ**: ก่อนเผยแพร่ โปรดตรวจสอบว่าโปรเจกต์ใช้เวอร์ชัน SDK ที่ VRChat สนับสนุนในปัจจุบัน

---

## เอกสารทางการ

| ทรัพยากร | URL |
|----------|-----|
| เอกสาร Creators ของ VRChat | https://creators.vrchat.com/ |
| อ้างอิง API ของ UdonSharp | https://udonsharp.docs.vrchat.com/ |
| ฟอรัม VRChat (ถาม-ตอบ) | https://ask.vrchat.com/ |
| VRChat Canny (บั๊ก/ฟีเจอร์) | https://feedback.vrchat.com/ |
| GitHub ชุมชน VRChat | https://github.com/vrchat-community |

---

<h2 id="community-contributors">ผู้ร่วมสนับสนุนจากชุมชน</h2>

โปรเจกต์นี้ได้รับประโยชน์จากผู้ที่สละเวลาแจ้ง Issue ที่เป็นรูปธรรมและช่วยตรวจสอบการแก้ไข ขอขอบคุณ:

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

<h2 id="contributing">มีส่วนร่วม</h2>

**ยินดีรับ Issue** -- รายงานข้อผิดพลาดและคำขอความรู้ช่วยให้โปรเจกต์นี้ดีขึ้น

**ไม่รับ Pull Requests** -- การแก้ไขและการอัปเดตทั้งหมดดำเนินการโดยผู้ดูแล

ดูรายละเอียดที่ [CONTRIBUTING.md](CONTRIBUTING.md)

---

<h2 id="disclaimer">ข้อจำกัดความรับผิดชอบ</h2>

> **โปรเจกต์นี้ไม่มีส่วนเกี่ยวข้องกับ VRChat Inc. ไม่มีการรับรอง ความร่วมมือ หรือความสัมพันธ์อย่างเป็นทางการใด ๆ**
>
> "VRChat", "UdonSharp", "Udon" และชื่อ/โลโก้ที่เกี่ยวข้องเป็นเครื่องหมายการค้าของ VRChat Inc. เครื่องหมายการค้าทั้งหมดเป็นของเจ้าของที่เกี่ยวข้อง
>
> รีปอซิทรีนี้เป็น**คลังความรู้ส่วนตัว**สำหรับเอเจนต์เขียนโค้ด AI ในการสร้างโค้ด UdonSharp ที่ถูกต้อง ไม่ได้แจกจ่ายส่วนใดของ SDK VRChat หรือคอมไพเลอร์ UdonSharp

### ความถูกต้อง

- เนื้อหาจัดทำขึ้น**"ตามที่เป็น"**โดยไม่มีการรับประกัน ดู [LICENSE](LICENSE)
- นี่คือโปรเจกต์ส่วนตัว **อาจมีข้อผิดพลาด ข้อมูลที่ล้าสมัย หรือเนื้อหาที่ไม่สมบูรณ์** ตรวจสอบกับ[เอกสาร VRChat ทางการ](https://creators.vrchat.com/) เสมอ
- ผู้เขียนไม่รับผิดชอบต่อปัญหาที่เกิดจากรีปอซิทรีนี้ (ข้อผิดพลาดตอน build การถูกปฏิเสธการอัปโหลด พฤติกรรมเวิลด์ที่ไม่คาดคิด ฯลฯ)
- การสนับสนุน SDK ที่ใช้งานจำกัดที่ 3.10.5 ซึ่งเป็นเป้าหมายที่ตรวจสอบล่าสุด รายการเวอร์ชันเก่าเป็นข้อมูลย้ายระบบเชิงประวัติ ไม่ใช่สัญญาว่าจะทดสอบหรือแก้ไข SDK เหล่านั้น พฤติกรรมอาจเปลี่ยนไปเมื่อ VRChat ออกเวอร์ชันใหม่

### การสร้างโดยมีส่วนช่วยจาก AI

คลังความรู้นี้สร้างและดูแลรักษาโดยมีเครื่องมือ AI ช่วย (Claude, Gemini, Codex) เนื้อหาทั้งหมดได้รับการตรวจสอบแล้ว แต่ส่วนที่สร้างโดย AI อาจมีข้อผิดพลาดเล็กน้อย ใช้ความเสี่ยงของคุณเอง

---

## สัญญาอนุญาต

โปรเจกต์นี้ใช้**สัญญาอนุญาต MIT** ดูรายละเอียดที่ [LICENSE](LICENSE)

สามารถ fork ดัดแปลง และแจกจ่ายต่อได้อย่างเสรีตามเงื่อนไขสัญญาอนุญาต MIT สัญญาอนุญาตนี้มีผลกับเอกสาร กฎ เทมเพลต และฮุกในรีปอซิทรีนี้ **ไม่**ให้สิทธิใด ๆ เหนือ SDK ของ VRChat คอมไพเลอร์ UdonSharp หรือทรัพย์สินทางปัญญาอื่น ๆ ของ VRChat
