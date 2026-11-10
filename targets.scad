// Scaled IPSC targets for dry fire / airsoft practice.
//
// Geometry read off the IPSC target diagram (ipsc.org "The IPSC Target",
// see ~/Documents/make-ready/kb/equipment/targets-and-mags.md).
// All real-world dimensions are in cm and scaled to mm at the end.
//
// Angular size rule: a 1:N target at home distance d looks like the real
// target at N*d. E.g. 1:5 at 2 m = full target at 10 m.
//
// Render one part at a time, e.g.:
//   openscad -D 'scale_n=5' -D 'part="target"' -o target_1-5.stl targets.scad

/* [Main] */
// Scale denominator: 4 = 1:4, 5 = 1:5, 6 = 1:6
scale_n = 5;
// What to render
part = "target"; // [target, mini, popper, mini_popper, round_plate, square_plate, stand, plate, assembly]
// Which part the stand is sized for ("all": one stand that fits every part)
stand_for = "all"; // [all, target, mini, popper, mini_popper, round_plate, square_plate]

/* [Plate] */
// Plate thickness in mm (not scaled)
thickness = 2.0;
// "groove": zone lines cut into the face. "raised": zones stepped up so you
// can change filament colour at a layer height (heights echoed to console).
zone_style = "raised"; // [groove, raised]
// Groove width and depth in mm
groove_w = 1.2;
groove_d = 0.8;
// Height of each raised step in mm
step_h = 0.6;
// Two hanging holes in the side D strips (0 = none), mm diameter
hang_hole = 4;

/* [Stand] */
// Slot clearance around the plate in mm
slot_clearance = 0.3;
// Index key: a tapered ledge on the face at the bottom centre of every part,
// narrow at the bottom, full width at the top. It drops into a matching
// notch in the front wall of the slot: loose at first, snug when seated. mm.
key_top = 12;
key_bottom = 6;
key_t = 1.5;
// Gap on each side of the key when fully seated (0 = friction fit)
key_clearance = 0.05;
// Stand footprint in mm
stand_w = 60;
stand_d = 40;
// Lean the target back this many degrees (0 = upright)
stand_tilt = 5;
stand_h = 12;

/* [Steel] */
// Metal plate sizes in real-world cm (IPSC: round 20-30, square 15-30)
round_plate_cm = 20;
square_plate_cm = 15;
// Height of the plate's bottom edge above the ground, real-world cm. The rules
// mount plates on stakes "at least 1 m high"; 50 keeps the print short and stiff.
plate_stake_cm = 50;
// Stake width in mm (not scaled). It widens near the bottom to carry the key.
stake_w = 8;

$fn = 64;

s = 10 / scale_n; // cm -> mm, then scaled

// ---- Real-size outlines (cm, origin top-left, y down) ----
// Outer edge incl. the 0.5 cm non-scoring border.
outer_cm = [[15,0],[30,0],[45,19],[45,38],[30,57],[15,57],[0,38],[0,19]];
// C zone (shares the top edge with the target).
c_cm     = [[15,0],[30,0],[37.5,19],[37.5,33.5],[27.5,45],[17.5,45],[7.5,33.5],[7.5,19]];
// A zone, 15 x ~32.5 cm. The upper side start (17) is not dimensioned on the
// diagram; read off the drawing.
a_cm     = [[20,2.5],[25,2.5],[30,17],[30,27.5],[25,35],[20,35],[15,27.5],[15,17]];

// Mini target is ~2/3 of the full target (30 x 37.5 cm per IPSC B3).
mini_k = 30 / 45;

function flip(pts, h) = [for (p = pts) [p[0], h - p[1]]];   // y up for OpenSCAD
function sc(pts, k)   = [for (p = pts) p * k];

module outline(pts, k) { polygon(sc(flip(pts, 57), k * s)); }

module target_plate(k = 1) {
    w = 45 * k * s;
    h = 57 * k * s;
    difference() {
        union() {
            color("burlywood") linear_extrude(thickness) outline(outer_cm, k);
            if (zone_style == "raised") {
                // D border step (inside the 0.5 cm border) is the base plate.
                color("orange") translate([0,0,thickness]) linear_extrude(step_h) outline(c_cm, k);
                color("white") translate([0,0,thickness + step_h]) linear_extrude(step_h) outline(a_cm, k);
            }
        }
        if (zone_style == "groove") {
            for (z = [c_cm, a_cm])
                translate([0,0,thickness - groove_d])
                    linear_extrude(groove_d + 0.01)
                        difference() {
                            offset(delta =  groove_w/2) outline(z, k);
                            offset(delta = -groove_w/2) outline(z, k);
                        }
        }
        if (hang_hole > 0)
            for (x = [3.75, 41.25])
                translate([x * k * s, h - 28 * k * s, -1]) cylinder(d = hang_hole, h = 50);
    }
    if (zone_style == "raised") {
        echo(str("Colour change for C zone at Z = ", thickness, " mm"));
        echo(str("Colour change for A zone at Z = ", thickness + step_h, " mm"));
    }
    echo(str("Target size: ", w, " x ", h, " mm (1:", scale_n, ")"));
}

// Footprint [w, d] in mm of a stand for a part with this bottom edge and
// height (mm): deeper foot for taller parts.
function stand_size(edge, h) = [max(stand_w, edge + 30), max(stand_d, h * 0.35)];

key_h = stand_h - 2;   // the key runs the full depth of the slot

// Index key on the part's face, bottom centre: a tapered ledge, narrow at the
// bottom and full width at the top. Lying flat it sits on top of the plate,
// so the print-bed side stays flat.
module key() {
    translate([0, 0, thickness]) linear_extrude(key_t)
        polygon([[-key_bottom/2, 0], [key_bottom/2, 0], [key_top/2, key_h], [-key_top/2, key_h]]);
}

// Table stand: a wide, low foot with a slot the part's bottom edge drops
// into, and a notch in the slot's front wall that takes the part's key.
// The notch has the key's taper, so the key enters loosely and tightens as
// it seats; it also centres the part. Any stand holds any part; the size only
// sets how steady it stands.
module stand(edge, h) {
    slot = thickness + 2 * slot_clearance;
    w    = stand_size(edge, h)[0];
    d    = stand_size(edge, h)[1];
    kb   = key_bottom + 2 * key_clearance;
    kt   = key_top + 2 * key_clearance;
    difference() {
        hull() {
            translate([-w/2, -d/2, 0]) cube([w, d, 2]);
            translate([-w/2 + 6, -slot/2 - 4, 0]) cube([w - 12, slot + 8, stand_h]);
        }
        // Slot and key notch, tilted back by stand_tilt so the part leans away
        // from you. The face (and the key) point -y, towards the shooter.
        translate([0, 0, 2])
            rotate([-stand_tilt, 0, 0]) {
                translate([-w/2 - 1, -slot/2, 0]) cube([w + 2, slot, stand_h * 2]);
                translate([0, -slot/2 + 0.01, 0]) rotate([90, 0, 0])
                    linear_extrude(key_t + 0.01)
                        polygon([[-kb/2, 0], [kb/2, 0], [kt/2, key_h], [kt/2, stand_h * 2],
                                 [-kt/2, stand_h * 2], [-kt/2, key_h]]);
            }
    }
}

// ---- Steel (IPSC Handgun Rules, appendices C2 and C3) ----
// Metal targets have no zones or border and are painted one colour, so they
// are printed flat in a single colour. Origin bottom centre, y up, cm.

// Popper profile from the C2 drawing: a straight tapered body from the base
// up to a chord of the head circle, where it meets the circle.
module popper_2d(base, chord, r, top) {
    cy = top - r;                               // head centre
    yc = cy - sqrt(r * r - pow(chord / 2, 2));  // body meets the circle here
    translate([0, cy]) circle(r);
    polygon([[-base/2, 0], [base/2, 0], [chord/2, yc], [-chord/2, yc]]);
}

// Metal plate on a stake. The stake width is in mm (not scaled) so it stays
// printable; its height is real-world cm.
module metal_plate_2d(round) {
    size = round ? round_plate_cm : square_plate_cm;
    translate([0, plate_stake_cm + size / 2])
        if (round) circle(d = size); else square(size, center = true);
    translate([-stake_w / s / 2, 0]) square([stake_w / s, plate_stake_cm + size / 2]);
}

// Widened foot at the bottom of the stake (mm), wide enough to carry the key,
// tapering back to stake_w above the slot.
foot_w = key_top + 6;
module stake_foot_2d() {
    polygon([[-foot_w/2, 0], [foot_w/2, 0], [foot_w/2, key_h + 2], [stake_w/2, key_h + 10],
             [-stake_w/2, key_h + 10], [-foot_w/2, key_h + 2]]);
}

module steel(p) {
    linear_extrude(thickness) {
        scale(s)
            if      (p == "popper")       popper_2d(15, 20, 15, 85);
            else if (p == "mini_popper")  popper_2d(10, 13.5, 10, 56);
            else if (p == "round_plate")  metal_plate_2d(true);
            else if (p == "square_plate") metal_plate_2d(false);
        if (p == "round_plate" || p == "square_plate") stake_foot_2d();
    }
}

// C3 handgun sizes: round 20-30 cm, square 15-30 cm.
if (round_plate_cm < 20 || round_plate_cm > 30)
    echo(str("WARNING: round_plate_cm = ", round_plate_cm, " is outside the IPSC range 20-30 cm"));
if (square_plate_cm < 15 || square_plate_cm > 30)
    echo(str("WARNING: square_plate_cm = ", square_plate_cm, " is outside the IPSC range 15-30 cm"));

// [bottom edge width, height] in mm for each part that stands in a stand.
function part_dims(p) =
      p == "target"       ? [15 * s, 57 * s]
    : p == "mini"         ? [15 * mini_k * s, 57 * mini_k * s]
    : p == "popper"       ? [15 * s, 85 * s]
    : p == "mini_popper"  ? [10 * s, 56 * s]
    : p == "round_plate"  ? [foot_w, (plate_stake_cm + round_plate_cm) * s]
    : p == "square_plate" ? [foot_w, (plate_stake_cm + square_plate_cm) * s]
    : undef;

// The key must fit on the narrowest bottom edge.
if (key_top > min([for (q = ["target", "mini", "popper", "mini_popper"]) part_dims(q)[0]]) - 4)
    echo("WARNING: key_top is too wide for the smallest part at this scale");

// Stand dimensions for stand_for: "all" takes the widest edge and the tallest
// part, so one stand fits every part at this scale.
all_parts = ["target", "mini", "popper", "mini_popper", "round_plate", "square_plate"];
function stand_dims(p) = p == "all"
    ? [max([for (q = all_parts) part_dims(q)[0]]), max([for (q = all_parts) part_dims(q)[1]])]
    : part_dims(p);

// One printable part with its key, lying flat, bottom edge centred on x = 0.
module part_flat(p) {
    if (p == "target")    translate([-22.5 * s, 0]) target_plate(1);
    else if (p == "mini") translate([-22.5 * mini_k * s, 0]) target_plate(mini_k);
    else steel(p);
    key();
}

// Part standing in its stand, for checking the fit on screen only.
// In the assembly the face points -y (towards the shooter).
module on_stand(p) {
    dims = stand_dims(stand_for);
    stand(dims[0], dims[1]);
    translate([0, thickness/2, 2])
        rotate([-stand_tilt, 0, 0]) rotate([90, 0, 0])
            if (p == "target" || p == "mini") part_flat(p);   // keeps its zone colours
            else color("gray") part_flat(p);
}

steel_parts = ["popper", "mini_popper", "round_plate", "square_plate"];

if (len([for (q = all_parts) if (q == part) q]) > 0) part_flat(part);
else if (part == "stand") { dims = stand_dims(stand_for); stand(dims[0], dims[1]); }
else if (part == "assembly") {
    // Targets and steel side by side, for the README preview.
    lineup = concat(["target", "mini"], steel_parts);
    for (i = [0 : len(lineup) - 1])
        translate([(i - (len(lineup) - 1) / 2) * 80, 0, 0]) on_stand(lineup[i]);
}
else if (part == "plate") {
    // Target + its stand laid out for one print.
    dims = stand_dims(stand_for);
    size = stand_size(dims[0], dims[1]);
    part_flat("target");
    translate([22.5 * s + 20 + size[0] / 2, size[1] / 2, 0]) stand(dims[0], dims[1]);
}
