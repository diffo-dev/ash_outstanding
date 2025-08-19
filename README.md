# AshOutstanding

[![Module Version](https://img.shields.io/hexpm/v/ash_outstanding)](https://hex.pm/packages/ash_outstanding)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen)](https://hexdocs.pm/ash_outstanding/)
[![License](https://img.shields.io/hexpm/l/ash_outstanding)](https://github.com/diffo-dev/ash_outstanding/blob/master/LICENSE.md)

Ash resource extension for implementing `Outstanding` protocol, which by default is deliberately not implemented for custom structs.

Implementing Outstanding on your Ash Resources is useful when you have an expected / actual twin, and want to establish whether/which expectations are outstanding given actual.

This is a powerful concept, particularly as expectations are declarations of intent, and we want to separate the concerns of whether we've sufficiently met our expectations from how to deal with what is outstanding. Ash itself is highly declarative, creating and exploiting Spark DSL. 

This extension employs Spark DSL to allow you to declare how your Ash Resource should implement Outstanding.

## Installation

Add to the deps:

```elixir
def deps do
  [
    {:ash_outstanding, "~> 0.2.1"},
  ]
end
```
## Tutorial

To get started you need a running instance of [Livebook](https://livebook.dev/)

[![Run in Livebook](https://livebook.dev/badge/v1/blue.svg)](https://livebook.dev/run?url=https%3A%2F%2Fgithub.com%2Fdiffo%2Ddev%2Fash%5Foutstanding%2Fblob%2Fdev%2Fash%5Foutstanding%5Fextension.livemd)

## Usage

Add `AshOutstanding.Resource` to `extensions` list within `use Ash.Resource` options:

```elixir
defmodule Example.Resource do
  use Ash.Resource,
    extensions: [AshOutstanding.Resource]
end
```

### Configuration

Generally you will want to configure your Ash Resource so that outstanding?(expected, actual) is true when the essentials of your Ash Resource are satisfied. What this really means will be specific to each resource in your domain.

 By defaults this includes public fields which aren't sensitive. This includes attributes, calculations and aggregates.

```elixir
defmodule Specification.Resource do
  use Ash.Resource,
    extensions: [AshOutstanding.Resource]

end
```

You have more control using the expect keyword.

- expect, provide list of Ash Record fields which can have have expectations, or a behaviour configuration map.

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

The behaviour configuration map options are:

* private? - Whenever to expect private fields (defaults false)
* sensitive? - Whenever to pick sensitive fields (defaults false)
* include - Fields to expect. In addition to public?: true && sensitive?: false fields.
* exclude - Fields not to expect.

```elixir
outstanding do
  # Pick only those listed keys
  expect [:only_some_field]

  # Expect all fields including public?: false and sensitive?: true
  expect %{private?: true, sensitive?: true}

  # Expect default fields with specific includsions and exclusions
  expect %{include: [:ok_private_field], exclude: [:irrelevant_public_field]}
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

Outstanding supports expected functions. Arity 1 and 2 expected functions use actual as a parameter. Arity 2 expected functions take an argument list, and this can be a list of 'prototype' expected resources used in an Outstand or your own expected function.

You may need to ensure your expected/actual Ash Resources are appropriately loaded, depending on what key/values you expect.

The __meta__ field is nil expectation.

## Customize

A dsl option is provided which will insert a custom arity 3 function into the outstanding pipeline.

Below customize is used to ensure that outstanding is enriched with expected.id

```elixir
defmodule Specification.Resource do
  use Ash.Resource,
    extensions: [AshOutstanding.Resource]

  outstanding do
    expect [:name, :major_version, :version]
    customize fn outstanding, expected, _actual ->
      case outstanding do
        nil ->
          outstanding
        %_{} ->
          outstanding
          |> Map.put(:id, expected.id)
      end
    end
  end
end
```

## Using Outstanding in Ash Expressions
Ash Expressions can call outstanding(expected, actual) and is_outstanding(expected, actual) via custom expressions. This is particularly useful when combined with relationships, as a supervising resource can manage its expectations of a supervised resource.

AshOutstanding includes the Outstanding and IsOutstanding custom expressions for the Ash.DataLayer.Simple, Ash.DataLayer.ETS, [AshCsv.DataLayer](https://github.com/ash-project/ash_csv) and [AshNeo4j.DataLayer](https://github.com/diffo-dev/ash_neo4j)

To make these available add to your config.exs:
```elixir
config :ash, :custom_expressions, [AshOutstanding.Expressions.Outstanding, AshOutstanding.Expressions.IsOutstanding]
```

## Acknowledgements

Thanks to [Telstra](https://www.telstra.com.au/) for supporting innovation in orchestration and inventory shared-tech which resulted in the award winning difference engine [2024 TMF Excellence Award in Autonomous Networks](https://www.tmforum.org/about/awards-and-recognition/excellence-awards/winners-2024/) powering three network service entities enabling outstanding product experience [2025 TMF Excellence Award in Customer Experience](https://www.tmforum.org/about/awards-and-recognition/excellence-awards/winners-2025/) and inspiring both this open source and internal shared-tech.

Thanks to [Dmitry Maganov](https://github.com/vonagam) for [ash_jason](https://github.com/vonagam/ash_jason) which was an exemplar.

Kudos to the [Ash Core](https://github.com/ash-project) for [ash](https://github.com/ash-project/ash) 🚀

## Links
[Diffo.dev](https://www.diffo.dev)
[`Outstanding` protocol docs](https://hexdocs.pm/outstanding/)
[`Outstanding` protocol livebook] (https://livebook.dev/run/?url=https%3A%2F%2Fgithub.com%2Fdiffo-dev%2Foutstanding%2Fblob%2Fdev%2Foutstanding.livemd)
