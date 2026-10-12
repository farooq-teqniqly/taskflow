# TaskFlow conventions

Baseline conventions (imported below) come from farooq-teqniqly/claude-templates;
update the template first, then re-sync the copy.

@CLAUDE-baseline.md
@CLAUDE-domain-driven-design.md
@CLAUDE-blazor-ui.md
@CLAUDE-aspire.md

## What this is

Individual developers lose actionable work across notes and chat. Taskflow gives individual developers thr ability to create and prioritize tasks, update status, and return later to find the same task data intact.

## Project-specific rules

### Back-end API's

Must be implemented using vanilla javascript (no TypeScript).
Use Vite testing framework.
Use Cloudfare D1 for database storage.
Use Cloudfare R2 for blob storage.
See [Trainfree](https://github.com/farooq-teqniqly/trainfree) as a pattern to follow.

### Deployment

Deployment of front-end/back-end is via Cloudfare workers.
Front-end worker is separate from back-end workers.
Preferred to have each back-end API in its own worker, not shared.
See [Trainfree](https://github.com/farooq-teqniqly/trainfree) as a pattern to follow.

### Access Control

Cloudfare Access is the preferred authentication method.
See [Trainfree](https://github.com/farooq-teqniqly/trainfree) as a pattern to follow.
