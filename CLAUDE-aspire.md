# .NET Aspire conventions

Conventions for repos that run their local dev stack through a .NET Aspire AppHost.
No project-specific values here (resource names, ports, Worker/npm wiring) -- those
belong in the consuming repo's `CLAUDE.md`.

- The AppHost (`src/<Name>.AppHost`) is local-dev orchestration only. Nothing deployed
  references it, and production does not depend on it.
- Run it with `dotnet run --project src/<Name>.AppHost`. The Aspire CLI is not required
  (hence `NoWarn` for `ASPIRE010`).
- Keep ports fixed (in `launchSettings.json` and resource definitions). Aspire-assigned
  ports and injected env vars must never reach the browser; anything the browser calls
  needs a stable URL.
- `Initialize-Project.ps1 -IncludeAspire` adds the AppHost to the `.slnx` like every other
  project, and the solution-wide restore and build succeed with it.
- Pin `Aspire.AppHost.Sdk` and every `Aspire.Hosting.*` integration package to the same
  version, and bump them together. Do not add a `PackageVersion` for
  `Aspire.Hosting.AppHost`: the SDK references it implicitly and central pinning fails
  restore with NU1009.
- The AppHost is excluded from SonarCloud coverage (`**/<Name>.AppHost/**` in
  `SONAR_EXCLUSIONS`); it has no unit-testable logic.
