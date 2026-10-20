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
| `//mm offset <x> <y>` | Nudge the current floor's map by image pixels, for this session |
| `//mm offsets` | List the offsets set this session |
| `//mm scale <x> [y]` | Try a different scale for every map of this content |
| `//mm info` / `//mm print` | Widescan data for your target / for everything in the last scan |
| `//mm scan_interval <seconds>` | How often to widescan |

Drag the map to move it.

## Adding content

Each content folder has a `definition.lua` (see `MinimapDefinition` in `shared/minimap.lua`):

- the zones it covers;
- landmarks for working out which map you're on;
- each map's image and calibration (`ref_world`, `ref_pixel`, scale);
- the layers of dots to draw.

Register it in `manager.lua`.

## Tests

```
busted tests
```

Run from the addon folder; `tests/test_setup.lua` stands in for Windower.
