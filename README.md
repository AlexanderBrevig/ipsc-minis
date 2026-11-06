# ipsc-minis

Scaled, 3D-printable targets for dry-fire and airsoft practice, following the
IPSC handgun target dimensions. One OpenSCAD file, with the scale as a parameter.

![Target standing in its stand](preview.png)

## Why scale?

A target that is 1:N in size, placed at distance *d*, looks the same to your
eye as the full-size target at *N × d*. You can practise target acquisition
and transitions at realistic angular sizes in a small room.

| Scale | Target size | At 2 m it looks like | At 3 m | At 6 m |
|---|---|---|---|---|
| 1:4 | 112.5 × 142.5 mm | 8 m | 12 m | 24 m |
| 1:5 | 90 × 114 mm | 10 m | 15 m | 30 m |
| 1:6 | 75 × 95 mm | 12 m | 18 m | 36 m |

Scale the spacing between targets by the same factor. Two targets 1 m apart
at 1:5 should stand 20 cm apart.

Note: only the angular size matches. Your eye still focuses at the real
distance.

## Usage

**Download:** ready-made STLs for 1:4, 1:5 and 1:6 (targets and stands) are
attached to each [release](https://github.com/AlexanderBrevig/ipsc-minis/releases),
built from the `.scad` of that version.

**Build yourself:** open `targets.scad` in OpenSCAD and use the Customizer, or
render from the command line:

```sh
openscad -D scale_n=5 -o target_1-5.stl targets.scad
openscad -D scale_n=5 -D 'part="stand"' -o stand_1-5.stl targets.scad
```

With Nix:

```sh
nix develop               # shell with OpenSCAD
nix run .#render          # all scales → stl/ + preview.png
nix run .#render -- 4 8   # chosen scales
```

### Parameters

| Parameter | Default | Meaning |
|---|---|---|
| `scale_n` | 5 | Scale denominator (4 = 1:4) |
| `part` | `target` | `target`, `mini` (IPSC Mini Target), `stand`, `popper`, `plate` (target + stand on one bed), `assembly` (preview only) |
| `thickness` | 2.0 | Plate thickness, mm (not scaled) |
| `zone_style` | `raised` | `raised`: C and A zones stepped up for colour changes. `groove`: zone lines cut into the face |
| `step_h` | 0.6 | Height of each raised step, mm |
| `groove_w`, `groove_d` | 1.2, 0.8 | Groove width and depth, mm |
| `hang_hole` | 4 | Diameter of the two hanging holes in the side D zones (0 = none) |
| `slot_clearance` | 0.3 | Gap on each side of the plate in the stand slot, mm |
| `stand_tilt` | 5 | Lean the target back this many degrees (0 = upright) |

The stand grows with the target: wider and deeper for larger scales.

## Printing

- Print flat, no supports.
- **PETG** is recommended. PLA works for dry fire but is brittle if hit.
- For `zone_style = "raised"`, change filament at **Z = 2.0 mm** (C zone) and
  **Z = 2.6 mm** (A zone). The heights are echoed to the OpenSCAD console and
  shift if you change `thickness` or `step_h`. A light A zone on a dark
  target is easy to find.
- Print a 1:6 target and stand first to check the slot fit, then adjust
  `slot_clearance`.

## Airsoft

The targets are mainly for dry fire. If you shoot BBs at them:

- Wear eye protection, and so should everyone in the room. A stiff plate
  bounces BBs back.
- Hang the target by its side holes in front of a curtain or a box with a
  towel. A swinging target takes energy out of the BB and shows the hit.
- Use PETG, 3 mm, 100 % infill for more durability.

## Accuracy

- Outer shape, C zone and A zone follow the dimensions on the IPSC target
  diagram. The upper side corners of the A zone are not dimensioned there and
  were read off the drawing.
- The Mini Target is the full target scaled to 30 cm wide (2/3), as in the
  rulebook.
- **The popper is approximate.** Height, head and base match the IPSC Popper;
  the neck shape does not come from a diagram.

## Disclaimer

Not affiliated with or endorsed by IPSC (International Practical Shooting
Confederation). "IPSC" is used only to describe the target dimensions these
models follow.

## Licence

Code (`targets.scad`, scripts) under the [MIT licence](LICENSE).
Models (STLs, renders) under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).
