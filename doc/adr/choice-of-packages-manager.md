# Choice of package manager

## Context and Problem Statement

We need to install and configure external dependencies to build and operate the service.
We also needs a workflow to build and distribute the service application.

## Considered Options

- RPM package
- Container image
- Ansible role
- Nix expression

## Decision Outcome

Chosen option: "Nix expression", because it comes out best (see below).

### Positive Consequences

- We need to start defining the whole runtime stack instead of per component.
- We need to use the a single environment instead of multiple one for development and deployment.

### Negative Consequences

- Nix requires using an extra language.

## Pros and Cons of the Options

### RPM package

- Good, because it is battle tested.
- Good, because it respects the Linux Filesystem Hierarchy Standard (FHS).
- Good, because it has strong community support.
- Bad, because it requires energy to manage dependencies.

### Container image

- Good, because it is popular.
- Bad, because it is inefficient and tedious to work with.

### Ansible roles

- Good, because it is simple.
- Bad, because it is hard to make it idempotent or reproducable.

## Nix expression

- Good, because it is programable.
- Bad, because the language is hard to use.
- Bad, because it is not standard and it induces a new set of problems.
