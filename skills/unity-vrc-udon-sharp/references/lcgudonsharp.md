# LCGUdonSharp Compiler Profile

Use this profile only when the Unity project installs
`com.logiccuteguy.lcgudonsharp`. The verified package contract is LCGUdonSharp
`0.3.8` on Unity `2022.3` with VRChat Worlds SDK `3.10.5`.

This reference overrides the stock compiler restrictions only where it says so.
Ownership, serialization, UdonVM API availability, event signatures, and all
other runtime rules in this Skill still apply.

## Installation and upgrade (0.3.8)

Install through VCC/ALCOM or extract the named release asset
`com.logiccuteguy.lcgudonsharp-0.3.8.zip` before using a local package reference.
GitHub's automatic source archives are developer checkouts, not installable
Unity packages. The 0.3.2 distribution could lack the compiler payload; update
affected projects to 0.3.8 and let Unity refresh so the installer can repair it.

Installable packages contain the compiler under `Payload~/UdonSharp` and optional
examples under `Samples~/Examples`. Import examples only after setup completes.
The installer validates compiler features, dependencies, and metadata before
replacing the compiler. Version 0.3.8 adds nested and polymorphic data snapshots
and a local equipment example. Upstream reports 27 Unity ScriptableObject checks,
including equipment purchases and cast behavior in the Udon VM, seven packaging
tests, and an editor test assembly compiling with zero errors. These are upstream
results, not
runtime validation performed by this skills repository. The 0.3.6 networking
recovery and motion-batching guidance below remains applicable; it does not
establish crowded-world bandwidth, FPS, or latency for every project.

Source: [LCGUdonSharp 0.3.8 release](https://github.com/LogicCuteGuy/LCGUdonSharp/releases/tag/0.3.8)
and [installation guide](https://github.com/LogicCuteGuy/LCGUdonSharp/blob/0.3.8/README.md#installation--setup).

## Selecting the profile

The validation hooks select LCGUdonSharp when either Unity manifest contains the
package key:

- `Packages/manifest.json`
- `Packages/vpm-manifest.json`

They also recognize source files under
`Packages/com.logiccuteguy.lcgudonsharp/`. For nonstandard layouts, set
`UDONSHARP_COMPILER_PROFILE=lcg`; set it to `stock` to force the stock contract.
Unknown values fall back to automatic discovery and then to stock validation.

Before generating code, verify the package and SDK versions in the live project.
Do not infer the profile from a repository name or from extended syntax already
present in a source file.

## Extended language contract

| Feature | LCGUdonSharp support | Important boundary |
|---------|----------------------|--------------------|
| Interfaces | Source-defined interfaces, parameters, returns, properties, multiple implementations, interface arrays, closed generic specializations, and closed generic interface diamonds with multiple interface inheritance | Open generic runtime uses, generic methods, default/static members, events, indexers, explicit implementations, `[NetworkCallable]` interface implementations, and built-in Udon event name collisions are rejected |
| `async` / `await` | Parameterless `async void`, `Task.Yield()`, constant positive `Task.Delay(int)`, and one supported VRChat SDK await per behaviour | Single-flight only; async locals, parameters, nested awaits, explicit returns, direct `Task<T>` result assignment, and multiple simultaneous SDK awaits are rejected |
| Exceptions | Synchronous `try`/`catch`/`finally`, approved typed and catch-all handlers, `throw new`, rethrow, and compiler guards for supported null/bounds/integral-zero failures | `await` inside `try`, catch filters, arbitrary thrown expressions, unsupported exception types, extern/VM faults, cross-behaviour propagation, floating-point divide-by-zero, overflow, casts, and SDK domain failures are outside the contract |
| LINQ closures | `Where()`, `Select()`, and `ToArray()` with captured values are lowered to loops | Other LINQ operators and general runtime delegates are not implied |
| Generics | Closed generic static helpers, closed generic interface specializations, and exact compiler-lowered `List<T>` / `Dictionary<TKey,TValue>` collections | Open generics, generic behaviours, other generic heap objects, collection interfaces, derived collections, and custom comparers remain rejected |
| `ref` / `out` | Locals, fields, array elements, `out var`, and supported recursion | Keep ordinary Udon type/extern restrictions |
| `dynamic` | Accepted only when the compiler proves one concrete type | Ambiguous or changing runtime types are rejected |
| `Span<T>` | Array-backed local spans with the compiler's supported operations | Do not treat `Span<T>` as a general heap or API-boundary type |
| Collections and JSON | Exact `List<T>` and `Dictionary<TKey,TValue>` syntax lowers to `DataList` / `DataDictionary`; a VRCJson-backed `System.Text.Json` facade supports documented round trips | Collection interfaces, derived collections, custom comparers, nullable collection annotations, collection LINQ, and Inspector-serialized collections are rejected |

## Custom ScriptableObject data (0.3.8)

Ordinary custom Unity `ScriptableObject` classes need no LCG base class or
attribute. Assign their assets to behaviour fields in the Inspector. The data
class may live in an ordinary C# assembly and needs no Udon program asset;
the consuming UdonSharp behaviour still needs its paired program asset.

During proxy serialization/build, each behaviour receives an `object[]` data
snapshot. Read public instance fields and private `[SerializeField]` fields,
including inherited fields. Supported values include primitives, strings, enums,
the documented Unity value types, `VRCUrl`, and Udon-supported Unity references.
One-dimensional field arrays and behaviour fields containing arrays of data
assets are supported. Nested custom data fields/arrays and derived assets assigned
to custom base types are also supported. Native SDK types such as `UdonProduct`
keep their existing Udon behavior; this lowering is for custom data assets.

Every array field read returns a fresh shallow defensive copy, preserving null.
Cache the array in a local before loops to avoid repeated allocation. Referenced
Unity objects retain their normal mutable APIs. Repeated asset references inside
one baked graph share a snapshot; separate top-level behaviour fields are baked
separately and do not promise shared reference identity. Rebuild
after changing asset data or its field schema; edits during play do not update
snapshots. Heap-to-proxy reads preserve Inspector asset assignments and never
write snapshot values back into the source asset.

### Nested references and checked casts

Custom base types, including abstract data classes, may hold derived assets.
Use `is`, declaration patterns, `as`, and checked explicit casts between custom
data types. Upcasts preserve the snapshot; downcasts inspect runtime type tags.
An incompatible `as` returns null; an incompatible explicit cast raises a
compiler-managed `InvalidCastException`. Null casts stay null and null type
tests return false. This specific guard does not imply general cast-exception
support for arbitrary Udon types.

Field layouts place base-class fields first and include a runtime type tag.
Rebuild all Udon programs and rebake scene/prefab data after updating to 0.3.8;
older snapshots have an incompatible layout. Cyclic asset graphs and nesting
beyond 128 assets produce bake errors instead of unbounded recursion.

Reject data-field writes, properties, instance/static/virtual methods, Unity
object APIs on custom data assets, `new`, `ScriptableObject.CreateInstance`,
casts to `object`/native asset types, interfaces, and data-array covariance.
Data-asset arrays reject native methods such as `GetValue`, `SetValue`, `Clone`,
and `GetType`; use typed indexing and array length rather than exposing mutable
snapshot internals. Arbitrary custom classes, collections,
multidimensional/jagged data arrays, `[SerializeReference]`, and
`[UdonSynced]` data assets/arrays remain unsupported.
Copy values into ordinary gameplay state to mutate or synchronize them.

The optional `ScriptableObjectShopExample.prefab` and
`ScriptableObjectEquipmentExample.prefab` demonstrate local purchases, not
multiplayer synchronization. The equipment example uses weapon/spell definitions,
nested economy assets, and a base-typed catalog. See the pinned
[data guide](https://github.com/LogicCuteGuy/LCGUdonSharp/blob/0.3.8/Example/ScriptableObjects/README.md)
for setup, supported types, and defensive-copy/cast examples.

## Collections, JSON, and synchronization

LCGUdonSharp 0.3.x supports exact `List<T>` and
`Dictionary<TKey,TValue>` definitions with documented constructors,
initializers, typed indexers, `foreach`, common mutation/search operations,
`TryGetValue`, keys/values, and typed `ToArray`. Fields, nested collections,
and arrays of collections use the same lowered proxy storage; null and empty
values remain distinct.

The `System.Text.Json` facade is backed by `VRCJson`. String-key dictionaries
serialize as JSON objects; other JSON-safe keys use the package's versioned
dictionary envelope. Object references, NaN, and Infinity are rejected.
Installing another real `System.Text.Json` assembly can cause a namespace/type
conflict.

Synchronized collections require a Manual-sync behaviour and a non-Inspector
field marked `[UdonSynced, NonSerialized]`. The compiler transports a hidden
JSON payload, while ownership transfer and `RequestSerialization()` remain the
author's responsibility. Continuous sync, `FieldChangeCallback`, Inspector
serialization, and statically non-JSON-safe element types are rejected.

The compiler remains the final authority. If its diagnostic is narrower than this
summary, follow the diagnostic and update this reference from the package's
current tests and README.

## Async SDK adapters

The package currently documents adapters for string and image downloads, video
load/end, GPU readback, serialization, and Creator Economy list requests. Keep
the original VRChat callback: its body runs first, followed by the generated
continuation. The compiler permits one SDK await per behaviour, not one per
method.

## Manual packet networking

`[LCGPacket]` is an experimental transport and is not interchangeable with
`[UdonSynced]`:

- Packet fields coalesce repeated writes in a frame; `ForceSendPacket` bypasses
  unchanged-value suppression.
- Packet methods are `void`, accept at most eight supported arguments, and may
  be broadcast or targeted through the package mailbox.
- Authority and replay checks validate received frames. Object-owner fields
  still require ownership before mutation.
- Packet fields are session-only rather than persistent storage. Zone entry
  and `OnPlayerRestored` request current scene-field and object snapshots in
  0.3.6; this recovers current state, not historical packet-method calls.
- `LCGNetworkZone` scopes LCG packet recipients, ownership, and converted
  `VRC_ObjectSync` traffic. Continuous behaviours without synced fields are
  accepted automatically (introduced in 0.3.5).
- Native `[UdonSynced]` fields under a zone fail closed by default. Enable
  **Allow Native Sync Passthrough** explicitly for compatible third-party
  hierarchies. Native fields retain VRChat sync semantics and remain
  instance-wide, not zone-scoped or optimized by the zone. Do not treat this
  setting as zone-scoped Continuous field synchronization or interpolation.
- Unsupported networked Udon Graph behaviours, overlapping parent/child zones,
  and PlayerObject templates sharing a zone hierarchy still fail closed.

### Snapshot recovery and ownership handoff

Local snapshot recovery permits up to five additional attempts with bounded
backoff, stops when the player exits the zone, and restarts after a relevant
restore event. Test late join and re-entry with multiple VRChat clients.

If VRChat assigns an object to an outside player after its owner disconnects,
the newly assigned owner repairs ownership through callbacks and a finite
recovery window. Existing ownership by valid zone members is preserved; an
empty zone keeps VRChat's fallback owner until a member enters. Handoff is
initiated by the current owner; leaving the zone does not prevent that owner
from handing off, while outside claimants and outside destinations remain
rejected.

### Object motion and examples

Inside a zone, Play/Build converts `VRC_ObjectSync` to the LCG motion relay.
Call `LCGNetwork.RequestObjectSync(gameObject)` after script-driven movement;
pickups synchronize automatically while held. The motion queue retains the
latest unsent sample per object/recipient, preserving teleport and re-entry
discontinuities. It is separate from the gameplay RPC queue.

Objects for one recipient share mailbox batches of at most 900 bytes. The
scene-wide motion scheduler permits at most 40 events/second and approximately
6 KB/second including conservative overhead. It pauses during congestion or
when the SDK outgoing queue exceeds eight events. More recipients share this
budget; increasing producer frequency does not increase it. These limits apply
to motion, not unrelated gameplay or native synchronization.

Remote objects interpolate with bounded velocity prediction. Remote rigidbodies
stay kinematic until the local player takes ownership, when physics is restored.
Transport counters measure local routing rather than remote delivery or real
network throughput; validate crowded-world performance with VRChat clients.

The optional samples include `NetworkExamples.prefab` (native/LCG lamps and a
moving cube) and `HighBandwidthExamples.prefab` (native payload and LCG motion
load generators). Both load generators start stopped. Keep native examples
outside the zone unless intentionally using native-sync passthrough. See the
[networking guide](https://github.com/LogicCuteGuy/LCGUdonSharp/blob/0.3.8/Example/Networking/README.md)
and [Thai setup guide](https://github.com/LogicCuteGuy/LCGUdonSharp/blob/0.3.8/Example/Networking/README.th.md).

The packet wire protocol remains experimental. Recompile UdonSharp programs
and rebuild worlds after upgrading to 0.3.6: older builds cannot decode the
new motion batch envelope.

## Stock rules that still apply

Do not relax these merely because the LCG profile is active:

- Only the exact compiler-lowered `List<T>` and `Dictionary<TKey,TValue>`
  collection shapes documented above are available; other generic heap
  collections remain unavailable.
- `yield return`, `StartCoroutine`, runtime delegates, and `AddListener` remain
  unavailable unless a future package version explicitly adds them.
- Native Udon ownership and `[UdonSynced]` serialization rules are unchanged.
- Every UdonSharp behaviour `.cs` still needs its paired program `.asset`;
  ordinary ScriptableObject data classes do not.
- The package currently requires exactly VRChat Worlds SDK `3.10.5`.
