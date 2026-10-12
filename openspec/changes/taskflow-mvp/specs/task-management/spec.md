## Purpose

Lets a signed-in developer create, prioritize, track, complete and remove personal tasks, and find the same task data intact when they return later.

## ADDED Requirements

### Requirement: Create a task
The system SHALL let a signed-in user create a task with a required title and an optional priority, description and due date. A new task SHALL have the status Todo and SHALL belong to the user who created it.
**Rationale**: A title is the minimum that makes a task actionable; priority, description and due date are useful but must not slow down capture.

#### Scenario: Create with title only
- **WHEN** a user submits a new task with only a title
- **THEN** the task is saved with status Todo, priority None, no description and no due date

#### Scenario: Create with all fields
- **WHEN** a user submits a title, a description, a due date and the priority High
- **THEN** the task is saved with those values and status Todo

#### Scenario: Reject a blank title
- **WHEN** a user submits a task whose title is empty or only whitespace
- **THEN** the task is not saved and the user is told the title is required

### Requirement: Fixed priority values
The system SHALL accept only the priorities High, Medium, Low and None. None SHALL mean no priority has been set and SHALL be the priority of a task created without one.
**Rationale**: A small fixed set keeps prioritizing a one-click decision and keeps the data consistent; an explicit None means unprioritized tasks need no special-case handling and can be returned to that state; custom priorities are out of scope.

#### Scenario: Set a valid priority
- **WHEN** a user changes a task's priority to Low
- **THEN** the task shows priority Low on every later view

#### Scenario: Remove a priority
- **WHEN** a user changes a task's priority to None
- **THEN** the task shows priority None on every later view

#### Scenario: Reject an unknown priority
- **WHEN** a request sets a priority that is not High, Medium, Low or None
- **THEN** the change is rejected and the task keeps its previous priority

### Requirement: Fixed status values
The system SHALL accept only the statuses Todo and Closed.
**Rationale**: Two states cover the core workflow of capturing and finishing work; more states are out of scope.

#### Scenario: Reject an unknown status
- **WHEN** a request sets a status that is not Todo or Closed
- **THEN** the change is rejected and the task keeps its previous status

### Requirement: Complete a task
The system SHALL let a user complete a Todo task, which sets its status to Closed.
**Rationale**: Completing work is the end of the core workflow and must be a single, obvious action.

#### Scenario: Complete a Todo task
- **WHEN** a user completes a task whose status is Todo
- **THEN** the task's status becomes Closed

### Requirement: Reopen a task
The system SHALL let a user reopen a Closed task, which sets its status to Todo.
**Rationale**: Work is sometimes closed by mistake or comes back; users should not have to recreate the task.

#### Scenario: Reopen a Closed task
- **WHEN** a user reopens a task whose status is Closed
- **THEN** the task's status becomes Todo and its other fields are unchanged

### Requirement: Edit a task
The system SHALL let a user change a task's title, description, due date and priority, and SHALL apply the same validation as on creation. A user SHALL be able to clear the description and the due date.
**Rationale**: Tasks change as understanding changes; optional fields must be removable as well as settable.

#### Scenario: Update the due date
- **WHEN** a user sets a new due date on a task
- **THEN** the task shows the new due date on every later view

#### Scenario: Clear the due date
- **WHEN** a user clears the due date of a task
- **THEN** the task has no due date

#### Scenario: Reject an invalid due date
- **WHEN** a request supplies a due date that is not a valid calendar date
- **THEN** the change is rejected and the task keeps its previous due date

### Requirement: View own tasks
The system SHALL let a user view their own tasks, including title, description, due date, priority and status, and SHALL NOT show tasks that have been deleted.
**Rationale**: Returning later to find the same data is the outcome the product exists for.

#### Scenario: Tasks persist across sessions
- **WHEN** a user creates a task, signs out, and signs in again later
- **THEN** the task is listed with the same title, description, due date, priority and status

#### Scenario: Deleted tasks are hidden
- **WHEN** a user lists their tasks after deleting one
- **THEN** the deleted task is not listed

### Requirement: Delete a task
The system SHALL let a user delete a task. Deletion SHALL be a soft delete: the task stops appearing to the user and cannot be viewed, edited, completed or reopened by the user, but its data SHALL be retained. The system SHALL NOT offer the user a way to restore it.
**Rationale**: Retained data allows recovery by the project owner after a mistake without adding a restore feature to the MVP.

#### Scenario: Delete a task
- **WHEN** a user deletes a task
- **THEN** the task no longer appears in the user's task list

#### Scenario: Act on a deleted task
- **WHEN** a user tries to edit, complete or reopen a task they previously deleted
- **THEN** the system reports that the task does not exist and changes nothing

### Requirement: Task identifiers
The system SHALL give each task a unique identifier in the same format as the Trainfree project: a fixed three-letter prefix, a hyphen, and six characters drawn from the alphabet `ABCDEFGHJKMNPQRSTVWXYZ23456789`. Task identifiers SHALL use the prefix `TSK`. The system SHALL reject a request that names a task by a malformed identifier.
**Rationale**: Short, prefixed identifiers are readable and type-evident in logs and URLs, and match the sibling project so tooling and habits carry over.

#### Scenario: New task gets an identifier
- **WHEN** a user creates a task
- **THEN** the task has an identifier of the form `TSK-` followed by six characters from the allowed alphabet

#### Scenario: Malformed identifier
- **WHEN** a request names a task with an identifier that does not match the format
- **THEN** the request is rejected as invalid, not reported as a missing task

### Requirement: Task ownership isolation
The system SHALL let a user view or change only the tasks they own. A request for another user's task SHALL be answered as if the task does not exist.
**Rationale**: Tasks are personal work; answering "not found" for someone else's task avoids revealing which tasks exist.

#### Scenario: Read another user's task
- **WHEN** a user requests a task owned by a different user
- **THEN** the system reports that the task does not exist

#### Scenario: Modify another user's task
- **WHEN** a user tries to edit, complete, reopen or delete a task owned by a different user
- **THEN** the system reports that the task does not exist and the task is unchanged

## Decisions

- Chose an explicit priority value None as the default, over making priority required or storing a missing value. A required priority would be right if usage shows users want to be forced to decide; a missing value would be right only if None needed to be distinguished from "never looked at", which nothing in the brief asks for.
- Every table that stores an entity carries `created_at` and `updated_at` columns (the Trainfree convention: text timestamps, both non-null). The tasks table also carries `user_deleted_at`, which is empty for a live task and holds the deletion time once a user deletes it; a task is hidden from users exactly when it is set. A single `deleted` flag would be right only if the time of deletion never mattered; it is cheap to keep and helps manual recovery.
- Entity identifiers follow the Trainfree scheme (prefix, hyphen, six characters from `ABCDEFGHJKMNPQRSTVWXYZ23456789`, generated from a cryptographically secure source) and live in a unique text column next to an internal integer key. Chose this over UUIDs or plain integers on the grounds of reuse and readability; UUIDs would be right if identifiers ever had to be generated by several systems with no shared collision handling. The task prefix `TSK` and the user prefix `USR` are this change's choices, not inherited from Trainfree.
- Chose "not found" for other users' tasks over "forbidden". "Forbidden" would be right if a future sharing feature needs to tell a user that a task exists but is off limits.
- Chose a minimal validation set (title required, valid date, fixed priority and status) with no length limits in this change. Length limits would be right once storage or display constraints are known; add them as a later requirement.
- Chose to let Admins use tasks like Users (their own tasks only) over giving them no task access. Admin-only tasks would be right only if the Admin role were ever split from daily use, which the brief does not suggest.
- Persistent storage and deployment follow the repository's project rules (Cloudflare D1 for storage, vanilla JavaScript back end); they are not behavior and are decided in tasks, not here.

## Requirement coverage

Anchor: milestone #1 (TaskFlow MVP)

| # | Anchor requirement | Covered by |
|---|--------------------|-----------|
| 1 | Create tasks | Req: Create a task |
| 2 | Prioritize tasks (fixed High, Medium, Low; None when unset) | Req: Fixed priority values |
| 3 | Update status (fixed Todo, Closed) | Req: Fixed status values |
| 4 | Complete a task (core workflow) | Req: Complete a task |
| 5 | Reopen a Closed task | Req: Reopen a task |
| 6 | Task CRUD: read and update | Req: View own tasks; Req: Edit a task |
| 7 | Optional description and optional due date | Req: Create a task; Req: Edit a task |
| 8 | Soft delete, no user restore | Req: Delete a task |
| 9 | Return later to find the same task data intact (persistent storage) | Req: View own tasks (scenario: Tasks persist across sessions) |
| 10 | Validation | Req: Create a task; Req: Fixed priority values; Req: Fixed status values; Req: Edit a task |
| 11 | Each user sees and changes only their own tasks (assumption) | Req: Task ownership isolation |
| 12 | Sign-in restricted to a whitelist of emails | Spec: access-control |
| 13 | Admin and User roles; first Admin provisioned outside the app | Spec: access-control |
