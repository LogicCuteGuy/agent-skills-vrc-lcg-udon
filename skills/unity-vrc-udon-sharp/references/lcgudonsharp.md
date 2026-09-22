# LCGUdonSharp Compiler Profile

Use this profile only when the Unity project installs
`com.logiccuteguy.lcgudonsharp`. The verified package contract is LCGUdonSharp
`0.3.2` on Unity `2022.3` with VRChat Worlds SDK `3.10.5`.

This reference overrides the stock compiler restrictions only where it says so.
Ownership, serialization, UdonVM API availability, event signatures, and all
other runtime rules in this Skill still apply.

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
- Packet fields are session-only and are not replayed to late joiners.
- `LCGNetworkZone` restricts recipients and ownership. `[UdonSynced]` under a
  zone, unsupported Continuous/Udon Graph behaviours, overlapping parent/child
  zones, and PlayerObject templates sharing a zone hierarchy fail closed.

The packet wire protocol is experimental and may change between package
versions. After an upgrade, recompile all UdonSharp programs and rebuild the
world.

## Stock rules that still apply

Do not relax these merely because the LCG profile is active:

- Only the exact compiler-lowered `List<T>` and `Dictionary<TKey,TValue>`
  collection shapes documented above are available; other generic heap
  collections remain unavailable.
- `yield return`, `StartCoroutine`, runtime delegates, and `AddListener` remain
  unavailable unless a future package version explicitly adds them.
- Native Udon ownership and `[UdonSynced]` serialization rules are unchanged.
- Every UdonSharp `.cs` still needs its paired program `.asset`.
- The package currently requires exactly VRChat Worlds SDK `3.10.5`.
