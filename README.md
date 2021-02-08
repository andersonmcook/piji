# Piji

Distributed cache using Erlang's `pg`.

[pg](https://erlang.org/doc/man/pg.html)
[pg Source](https://github.com/erlang/otp/blob/master/lib/kernel/src/pg.erl)

## TODO

How do you know that a pid is on a certain node? Or rather, how do you know when a node does not have a cache for a certain key?

Might want a module-based dynamic supervisor to see if it has local children.

And then we can maybe start it.

Every time a Worker is started, we can replicate the state to all the members.

- [ ] Once a value is written to the cache, all nodes will have a copy
- [ ] Whenever a node goes down and comes back up and a cache request is made at that node, it will have a copy again
- [ ] When the cache is updated at one node, it will be updated at all nodes

## Running

``` sh
iex --sname a --cookie hey -S mix
```

``` sh
iex --sname b --cookie hey -S mix
```

Get something from the cache. Make an update. Restart a node. Get something from the cache on the fresh node.


## Running in Docker
``` sh
docker-compose up
# In a separate tab
curl http:localhost:4000/1
```

## Caveats

The Piji.Cache module makes the assumption that any connected nodes are the same application/has the same functions.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `piji` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:piji, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/piji](https://hexdocs.pm/piji).

