#!/usr/bin/env bash
# Render STLs for all scales, and the README preview unless NO_PREVIEW is set.
# Usage: ./render.sh [scale ...]   (default: 4 5 6)
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p stl
scales=("${@:-4 5 6}")
for n in ${scales[@]}; do
  echo "1:$n"
  openscad -q -D "scale_n=$n" -o "stl/target_1-$n.stl" targets.scad
  openscad -q -D "scale_n=$n" -D 'part="stand"' -o "stl/stand_1-$n.stl" targets.scad
  for p in mini popper mini_popper round_plate square_plate; do
    openscad -q -D "scale_n=$n" -D "part=\"$p\"" -o "stl/${p}_1-$n.stl" targets.scad
  done
done
# Image export needs OpenGL and a display, so CI skips it (preview.png is committed).
if [ -z "${NO_PREVIEW:-}" ]; then
  openscad -q -D 'part="assembly"' --camera=0,0,70,65,0,25,850 --imgsize=900,500 -o preview.png targets.scad
fi
