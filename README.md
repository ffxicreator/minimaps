# Minimaps

A Windower addon that shows a minimap for instanced content you can't see the map of in game: your position,
party, nearby enemies (via widescan) and points of interest on each floor.

Supported content:

- **Nyzul Isle**: lamps, leaders, specified enemies, the Rune of Transfer
- **Odyssey (Sheol A, B and C)**, both Walk of Echoes copies: confluxes, translocators, the exit, chests in range

The minimap appears on its own when you enter a supported zone.

## Commands

`//mm` (or `//minimaps`) acts on the minimap for the zone you're in.

| Command | |
|---|---|
| `//mm show` / `//mm hide` | Show or hide it |
| `//mm zoom in` / `out` / `<value>` | Resize it (0.5 - 4.0); size and position are saved |
| `//mm offset <x> <y>` | Nudge the current floor's map by image pixels, for this session (debugging) |
| `//mm offsets` | List the offsets set this session (debugging)  |
| `//mm scale <x> [y]` | Try a different scale for every map of this content (debugging)  |
| `//mm info` / `//mm print` | Widescan data for your target / for everything in the last scan (debugging) |
| `//mm scan_interval <seconds>` | How often to widescan |

Drag the map to move it.

