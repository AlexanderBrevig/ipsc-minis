# ipsc-minis

Scaled 3D-printable targets following IPSC handgun target dimensions, for dry-fire and airsoft practice. Single OpenSCAD file (`targets.scad`); the scale is a parameter. Personal context, if present, is in `CLAUDE.local.md` (gitignored).

## Dimensions (source of truth: IPSC Handgun Competition Rules, appendices B2 Target, B3 Mini Target, C2 Poppers, C3 Metal Plates)
- Full target: 45 × 57 cm octagon incl. 0.5 cm non-scoring border. Outer sides from 19 to 38 cm; top and bottom edges 15–30 cm.
- A zone: 15 cm wide, top at 2.5 cm (edge 20–25 cm), sides 15/30 cm down to 27.5 cm, bottom at 35 cm (edge 20–25 cm).
- C zone: shares the top edge; sides 7.5/37.5 cm from 19 to 33.5 cm; bottom edge 17.5–27.5 cm at 45 cm.
- Mini Target: 30 × 37.5 cm (2/3 of full).
- Popper (C2): 85 cm tall, head r 15 cm (centre at 70 cm), straight body from 15 cm base to a 20 cm chord of the head. Mini Popper: 56 cm, r 10 (centre 46), base 10, chord 13.5. Whole head circle = calibration zone (shaded on the drawing).
- Metal plates (C3, handgun): round 20–30 cm Ø, square 15–30 cm; on stakes ≥ 1 m (default `plate_stake_cm` 50, deliberately not to scale).
- **Approximate, say so wherever it matters:** A-zone upper side corners (17 cm, read off the drawing, not dimensioned); metal plate stake height.

## Code notes
- Real-world geometry in cm (`outer_cm`, `c_cm`, `a_cm`; origin top-left, y down). `s = 10 / scale_n` converts to scaled mm; `flip()` turns y up.
- `thickness`, `step_h`, groove sizes, `slot_clearance`, `key_*` and `stake_w` are in mm and NOT scaled.
- `zone_style = "raised"` echoes filament-change heights; keep the echo if the steps change.
- Hanging holes sit in the side D strips (x 3.75 / 41.25 cm); keep them out of the A/C zones.
- One shared stand per scale: `stand_for = "all"` sizes it from the widest/tallest part (`stand_dims()`, `stand_size()`: width ≥ flat bottom edge + 30 mm, depth ≥ 35 % of part height). Rectangular foot with a straight slot; every part has a tapered index key (`key()`, on the face at the bottom centre, narrow at the bottom) that seats in a matching notch in the slot's front wall and grips by friction. Plate stakes widen to `foot_w` at the bottom to carry it; the slot is tilted by `stand_tilt` so the target leans away from the shooter. In `on_stand`/`assembly` the face points −y (towards the shooter). Steel is single-colour (rule 4.1.2.2), so no zones.

## Build and release
- `nix develop` gives OpenSCAD; `nix run .#render [-- 4 5 6]` runs `render.sh` → `stl/` + `preview.png`.
- `stl/` is gitignored: STLs are built by GitHub Actions and attached to releases so they always match the `.scad` of that tag. `preview.png` is committed for the README and rendered locally only (CI sets `NO_PREVIEW=1`: OpenSCAD image export needs OpenGL, which fails on the runner even under Xvfb); regenerate it when the geometry changes.
- Releases via release-please (`release-type: simple`): use **Conventional Commits** (`feat:`, `fix:`, `docs:`…). `ci.yml` renders on every push/PR (artifact); `release.yml` renders and uploads to the release when release-please creates one.
- Repo setting needed: Actions → "Allow GitHub Actions to create and approve pull requests".

## Licence and publishing
- Code (`targets.scad`, scripts): MIT. Models (STLs, renders): CC BY 4.0.
- Not affiliated with IPSC; describe dimensions as "following IPSC target dimensions". Never use the IPSC logo or imply endorsement.
- Sport framing only: no self-defence or "tactical" language, no human-like figures.
- MakerWorld: check the current guidelines before uploading (weapon/weapon-part ban; targets should be fine).

## Open items / ideas
- Untested: key/notch fit across printers (seating depth depends on printer tolerance), BB durability (PETG 2 mm vs 3 mm), stability of 1:6 on the stand.
- Ideas: no-shoot variant (white), multi-target arrays with scaled spacing, BB-trap box, falling (hinged) steel.

## Working style
- Honest pushback welcome; say how sure you are.
- Commit/push only when asked.
