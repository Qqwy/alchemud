# AlcheMUD

This is a very early attempt to create a Multi-User-Dungeon using the programming language Elixir.

Some inspiration is taken from the never-finished [Erlmud by zxq9](http://zxq9.com/erlmud/html/).



## Changelog:

2016-05-11

- Barebones start

2016-05-14

- Location manager
- Loading locations from persistence
- Connecting locations through ways
- re-connecting locations+ways whenever locations go down and come back up.
- adding Entities to locations.
- Telnet-listener using Ranch.

2016-05-15

- Better support for Telnet stuff
- Connection Abstraction layer 

## Roadmap

- Player logging in: Player processes, PlayerManager, PlayerSupervisor
- Global commands (Chat, options)
- Characters: Being started by a player, inhabiting the world.
- Commands that are passed to the character (and then to the world)
- Entities as state-machines
- Entities can be containers
- Entities can be moved between containers
- Persistence of world -> hard disk.
- Loading of persisted world.
- (How to implement difference between 'cyclic (resetting every so often)' world and 'persistent' (player data) world)?


## Maybe sometime in the future

- MXP, GMCP, etc. MUD-protocol support.
- Text-writing using markdown -> compiles to either ANSI-escaped telnet, MXP, HTML for websocket-connections, etc.
- MPS-support with sounds/music <3 !
- World-building from within.

