Favorite Repository Index
=========================

- [tl;dr](#tldr)
- [Motivation](#motivation)
- [The Challenge](#challenge)
- [Roadmap](#roadmap)
  - [Packages Management](#packages-management)
  - [Database](#database)
  - [Interfaces Definition](#interfaces-definition)
  - [Api Service](#api-structure)
  - [GitHub Queries](#github-queries)
  - [Database Queries](#database-queries)
  - [Client API](#client-api)
  - [Proxy](#proxy)
  - [User Interface](#user-interface)
  - [Left Over](#left-over)



<a id="tldr"></a>

# tl;dr

This project implements a simple service named Favorite Repository Index (FRI).

The goal is to implement an incremental roadmap using architectural decision records ([ADR](https://adr.github.io)).

![img](doc/architecture.png)

![img](doc/sequence.png)


<a id="motivation"></a>

# Motivation

I introduced a purely functional and strongly typed component, named [Lentille](https://github.com/change-metrics/lentille), while working on adding task datas to the [Monocle](https://github.com/change-metrics/monocle) service. I used Lentille to showcase a practical application of the Haskell language: performing data processing of the bugzilla API. Then, I investigated how one could leverage this approach for the rest of the service, in particular, the web api and client which are written in Python and Javascript.

So my idea was to use an IDL such as OpenAPI or Protobuf to implement the next features while keeping the existing code in place. Before working around the existing code base, I wanted to investigate using Haskell and gRPC in a greenfield project first.

I'm pretty satisfied with the result, and I'm eager to share my approach with you!


<a id="challenge"></a>

# The Challenge

TODO: define the goal and challenge of monocle


<a id="roadmap"></a>

# Roadmap

TODO: map roadmap to commits


<a id="packages-management"></a>

## Packages Management

```markdown
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

- Reproducible, by pinning the dependencies we control the entire stack.
- Mature ecosystem, nixpkgs features many packages.
- Enable efficient distribution.

### Negative Consequences

- Require an extra language.
- Nix introduces new issues.

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
```

-   A shell environment with development tools installed:

```
$ nix-shell --pure
[nix-shell]$ which strace
/nix/store/6yf85zvdchma8khwa7gl4ng6h3b4yr9n-strace-5.11/bin/strace
```

-   A derivation to start a service:

```
$ $(nix-build --attr db.start)
Starting the database...
```


<a id="database"></a>

## Database

```markdown
ADR: https://github.com/change-metrics/monocle/blob/master/doc/adr/0002-choice-of-elasticsearch.md
```

-   elasticsearch service deployment:

```
$ elk-start
Starting the database...

$ curl localhost:9242
{ "name": "fri", ..., "tagline" : "You Know, for Search"}

$ elk-stop
Stoping the database...

$ elk-destroy
Deleting the database...
```


<a id="interfaces-definition"></a>

## Interfaces Definition

```markdown
ADR: https://github.com/change-metrics/monocle/issues/346
```

-   protobuf definitions of the api: [fri.proto](./protos/fri.proto)

-   haskell, javascript and python code generation:

```
$ protobuf-codegen
Haskell bindings:
compile-proto-file --proto protos/fri.proto --out src/

Python bindings:
python3 -m grpc_tools.protoc -Iprotos --python_out=python/ --grpc_python_out=python/ fri.proto

Javascript bindings:
protoc -I=protos fri.proto --js_out=import_style=commonjs:javascript/src/ --grpc-web_out=import_style=commonjs,mode=grpcwebtext:javascript/src/
```


<a id="api-structure"></a>

## Api Service

```markdown
ADR: https://github.com/change-metrics/lentille/blob/main/doc/adr/0002-choice-of-language.md
```

-   A package set with relude version 1.0:

```
$ nix-shell --pure --command "ghc-pkg list relude"
    relude-1.0.0.1
```

-   A REPL:

```
$ cabal repl -O0
Ok, five modules loaded.
λ> import Api
λ> :type Api.run
Api.run :: Int -> IO ()
```

-   A CLI to start the service

```
$ cabal run fri-api -- --elk-url localhost:9242 --port 8042
fri-api running on :8042
```


<a id="github-queries"></a>

## GitHub Queries

-   A haskell module to define crawler function [FriGitHub](./src/FriGitHub.hs):

```haskell
getFavorites :: MonadIO m => UserName -> m [Repo]
```

-   REPL tutorial:

```haskell
λ> FriGitHub.getFavorites "TristanCacqueray"
[ Repo {repoName = "haskellfoundation/matchmaker", repoTopic = [], repoDescription = "Find your open-soulmate <\128156>"}
, Repo {repoName = "Gabriel439/grace", repoTopic = [], repoDescription = "A ready-to-fork interpreted, typed, and functional language"}
, ...]
```


<a id="database-queries"></a>

## Database Queries

-   TODO: A document mapping

-   TODO: A haskell module to define repositories index and search function:

```haskell
indexRepos :: MonadBH m => [Repo] -> m ()
searchRepos :: MonadBH m => Username -> m [Repo]
```

-   REPL tutorial:

```haskell
λ> TODO
```


<a id="client-api"></a>

## Client API

-   TODO: API implementation

-   REPL tutorial:

```haskell
λ> TODO
```


<a id="proxy"></a>

## Proxy

```markdown
ADR: https://github.com/change-metrics/monocle/issues/345
```

-   envoy service deployment:

```
$ envoy -c conf/envoy.yaml
starting main dispatch loop
```


<a id="user-interface"></a>

## User Interface

-   Live development server:

```
$ cd javascript; pnpm start
> react-scripts start
```


<a id="left-over"></a>

## Left Over

-   Authentication (openid, jwt, &#x2026;).
-   Standalone cli (compose service function in a TUI).
-   Distribution (container, vm, ansible, &#x2026;).
-   Service auto scaling.
-   CI with cachix.
