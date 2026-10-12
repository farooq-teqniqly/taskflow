## Purpose

Decides who may use the product and in what role, so that only people the project owner has approved can sign in and see their own tasks.

## ADDED Requirements

### Requirement: Sign-in is limited to whitelisted emails
The system SHALL let a person use the application only if the email address from their sign-in is on the whitelist. Every other request SHALL be refused.
**Rationale**: The MVP is for named individual developers; an allow-list keeps the audience small and known.

#### Scenario: Whitelisted email signs in
- **WHEN** a person signs in with an email address on the whitelist
- **THEN** they can use the application

#### Scenario: Email not on the whitelist
- **WHEN** a person signs in with an email address that is not on the whitelist
- **THEN** access is refused and no task data is shown

#### Scenario: Unauthenticated request
- **WHEN** a request carries no verified sign-in identity
- **THEN** it is refused and no task data is returned

### Requirement: Email matching ignores case
The system SHALL compare email addresses case-insensitively when checking the whitelist.
**Rationale**: Email providers and sign-in identities may differ in letter case for the same mailbox; a case mismatch must not lock out an approved person.

#### Scenario: Different letter case
- **WHEN** the whitelist holds an address in lower case and the person signs in with the same address in mixed case
- **THEN** access is granted

### Requirement: Admin and User roles
The system SHALL give each whitelisted person exactly one role, Admin or User. Whitelisted individual developers SHALL have the role User. An Admin SHALL have no task features beyond those of a User in the MVP.
**Rationale**: The Admin role exists to mark who owns the whitelist; keeping task behavior identical avoids a second permission model to build and test.

#### Scenario: Developer has User role
- **WHEN** a whitelisted individual developer signs in
- **THEN** the system treats them as a User

#### Scenario: Admin uses tasks like a User
- **WHEN** an Admin signs in and manages tasks
- **THEN** they can manage only their own tasks, the same as a User

### Requirement: First Admin is provisioned outside the app
The system SHALL start with the project owner's email on the whitelist as an Admin, provisioned ahead of time and not through the application. The application SHALL NOT offer any screen or interface to add, remove or change whitelisted emails or roles.
**Rationale**: Bootstrapping the first Admin outside the app avoids a chicken-and-egg problem, and deferring whitelist management keeps the MVP on the task workflow.

#### Scenario: Project owner is the first Admin
- **WHEN** the project owner signs in on a newly set up system
- **THEN** they are accepted with the role Admin

#### Scenario: No in-app whitelist management
- **WHEN** an Admin looks for a way to add a whitelisted email in the application
- **THEN** none is offered

### Requirement: Tasks are keyed to the signed-in identity
The system SHALL associate each task with the signed-in user's email identity, so the same person sees the same tasks on any device.
**Rationale**: "Return later and find the same data" requires a stable identity, not a browser-local one.

#### Scenario: Same person, second device
- **WHEN** a user creates a task on one device and signs in with the same email on another
- **THEN** the task is listed on the second device
