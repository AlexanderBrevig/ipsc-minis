#!/usr/bin/env bash
# Render STLs for all scales and the README preview.
# Usage: ./render.sh [scale ...]   (default: 4 5 6)
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p stl
scales=("${@:-4 5 6}")
for n in ${scales[@]}; do
  echo "1:$n"
  openscad -q -D "scale_n=$n" -o "stl/target_1-$n.stl" targets.scad
  openscad -q -D "scale_n=$n" -D 'part="stand"' -o "stl/stand_1-$n.stl" targets.scad
done
openscad -q -D 'part="assembly"' --camera=0,0,60,60,0,35,420 --imgsize=600,600 -o preview.png targets.scad
