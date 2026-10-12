# GitHub Copilot repository instructions

Repository-level custom instructions for Copilot code review. Mirrors
`.pr_agent.toml`'s `[pr_reviewer].extra_instructions` -- keep the two in sync.

The list below covers baseline conventions that bot reviewers reliably misread
as defects. Add project-specific exemptions underneath it, each with the
reason and, where one exists, the issue or PR that decided it -- an
unexplained exemption is indistinguishable from a bug being waved through.

Respect these deliberate baseline conventions and do not flag them as defects:

- Any DI-injected constructor dependency (HttpClient, DbContext, ILogger<T>,
  and application services) is trusted and intentionally not null-guarded. Only
  non-DI public/internal entry points guard their reference-type parameters --
  flag a missing guard there, never on an injected dependency.
- xUnit test classes are public sealed on purpose. The baseline defaults types
  to internal sealed but names this exact exception: a type a framework must
  discover. Do not suggest making test classes internal.
- *.Logging.cs partial void Log... methods are [LoggerMessage] source-generated;
  the generator supplies the bodies, so they are not unimplemented partials.
- Classes and structs use explicit constructors with _field backing fields, not
  primary constructors (IDE0290 is off). Do not suggest converting them. Exception:
  when a constructor parameter's only destination is a public mutable auto-property
  with no additional accessor logic (a working-value view-model, e.g. an editable-row
  type like `Name { get; set; }` seeded from the constructor), assigning directly to
  the property is correct -- do not flag it for missing a `_field` backing field.
  The rule does not apply to records at all (`sealed record`, `readonly record
  struct`): the baseline calls for positional syntax on pure data carriers (DTOs,
  value objects, outcome hierarchies), so do not flag a record's positional
  constructor for lacking explicit constructors or `_field` backing fields.
- EF Core-generated migration classes under Migrations/ (including the model
  snapshot) are public partial by generator design; regeneration reverts
  hand-edits, so do not flag their public surface or suggest sealing them.
- EF Core read-only queries use AsNoTracking by convention, but write/upsert
  paths that load an entity to modify and save it require change tracking; do
  not flag those as missing AsNoTracking.
- A `sealed partial class` for a Razor component's code-behind file does not
  conflict with the compiler-generated (unsealed) partial from the `.razor`
  file. C# allows one partial declaration to add `sealed` without the others
  repeating it; a conflict only arises between contradictory modifiers (e.g.
  `sealed` vs `abstract`). Do not flag a `sealed partial class` code-behind file
  as a conflict on that basis alone -- contradictory modifiers are still worth
  flagging. Reason: reviewers repeatedly reported this valid Razor pattern as a
  conflict (decided in #16).
