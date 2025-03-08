# AshOutstanding

[![Module Version](https://img.shields.io/hexpm/v/ash_outstanding)](https://hex.pm/packages/ash_outstanding)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen)](https://hexdocs.pm/ash_outstanding/)
[![License](https://img.shields.io/hexpm/l/ash_outstanding)](https://github.com/matt-beanland/ash_outstanding/blob/master/LICENSE.md)

Ash resource extension for implementing `Outstanding` protocol, which by default is deliberately not implemented for custom structs.

Implementing Outstanding on your Ash Resources is useful when you have an expected / actual twin, and want to establish whether/which expectations are outstanding given actual.

This is a powerful concept, particularly as expectations are declarations of intent, and we want to separate the concerns of whether we've sufficiently met our expectations from how to deal with what is outstanding. Ash itself is highly declarative, creating and exploiting Spark DSL. 

This extension employs Spark DSL to allow you to declare how your Ash Resource should implement Outstanding.

## Installation

Add to the deps:

```elixir
def deps do
  [
    {:ash_outstanding, "~> 0.1.0"},
  ]
end
```

## Usage

Add `AshOutstanding.Resource` to `extensions` list within `use Ash.Resource` options:

```elixir
defmodule Example.Resource do
  use Ash.Resource,
    extensions: [AshOutstanding.Resource]
end
```

### Configuration

Generally you will want to configure your Ash Resource so that outstanding?(expected, actual) is true when the essentials of your Ash Resource are satisfied. This may align to expecting actual to sufficiently attributes which are mandatory and/or fundamental to Ash identities. These attributes are configured using the expect list.

- expect, provide list of Ash Record fields which can have have expectations

Here is an example `outstanding` dsl section, which configures a Specification resource so that we can set expectations on any or all of the values of keys :name, :major_version and :version while ignoring other fields in the expected/actual resource.
When nil_outstanding?(expected, actual) is true, outstanding(expected, actual) returns nil
When nil_outstanding?(expected, actual) is false, outstanding(expected, actual) returns a struct of your Ash Record with just the unmet expectations.

```elixir
defmodule Specification.Resource do
  use Ash.Resource,
    extensions: [AshOutstanding.Resource]

  outstanding do
    expect [:name, :major_version, :version]
  end
end
```

## Using Outstanding on your resource

We don't need to set all of the expectations, by default a missing expectation or explict nil means we have no expectation (so nothing will be outstanding)

In the following example we require the access specification to be major version 2. We don't match version as we aren't concerned with minor or trival versions.
```elixir
use Outstand

expected = %Specification.Resource{name: access, major_version: 2}
actual = %Specification.Resource{name: access, major_version: 1}
expected >>> actual
false
expected --- actual
%Specification.Resource{major_version: 2}
```

If we are happy with either major_version: 1 or 2, we can use a range

```elixir
use Outstand
expected = %Specification.Resource{name: access, major_version: 1..2}
actual = %Specification.Resource{name: access, major_version: 1}
expected >>> actual
true
expected --- actual
nil
```

Outstanding supports regex, here we use a regex to expect version: is at least v1.1
We don't need an expectation on major version.

```elixir
use Outstand
expected = %Specification.Resource{name: access, version: ~r/v1.1/}
actual = %Specification.Resource{name: access, version: v1.1.17}
expected >>> actual
true
expected --- actual
nil
```

Outstanding supports expected functions. Arity/1 and arity/2 expected functions use actual as a parameter. Arity/2 expected functions take an argument list, and this can be a list of 'prototype' expected resources used in an Outstand or your own expected function.

You may need to ensure your expected/actual Ash Resources are appropriately loaded, depending on what key/values you expect.

## Links

[`Outstanding` docs](https://hexdocs.pm/outstanding).
