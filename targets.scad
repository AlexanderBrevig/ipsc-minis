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
part = "target"; // [target, mini, stand, popper, plate, assembly]

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
// Stand footprint in mm
stand_w = 60;
stand_d = 40;
// Lean the target back this many degrees (0 = upright)
stand_tilt = 5;
stand_h = 12;

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
            linear_extrude(thickness) outline(outer_cm, k);
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

// Table stand: a wide, low foot with a slot the plate's bottom edge drops
// into. Sized from the target so every scale gets a matching stand.
module stand(k = 1) {
    slot   = thickness + 2 * slot_clearance;
    edge_w = 15 * k * s;                      // flat bottom edge of the target
    w      = max(stand_w, edge_w + 30);
    d      = max(stand_d, 57 * k * s * 0.35); // deeper foot for taller targets
    difference() {
        hull() {
            translate([-w/2, -d/2, 0]) cube([w, d, 2]);
            translate([-w/2 + 6, -slot/2 - 4, 0]) cube([w - 12, slot + 8, stand_h]);
        }
        // Slot, tilted back by stand_tilt so the target leans away from you.
        translate([0, 0, 2])
            rotate([-stand_tilt, 0, 0])
                translate([-w/2 - 1, -slot/2, 0]) cube([w + 2, slot, stand_h * 2]);
    }
}

// Target standing in its foot, for checking the fit on screen only.
module assembly(k = 1) {
    stand(k);
    color("gray")
        translate([-22.5 * k * s, thickness/2, 2])
            rotate([-stand_tilt, 0, 0]) rotate([90, 0, 0]) target_plate(k);
}

// Approximate IPSC popper: 85 cm tall, 30 cm head, 15 cm base. The neck shape
// is not taken from a diagram; treat it as a stand-in.
module popper(k = 1) {
    linear_extrude(thickness)
        scale(k * s) union() {
            translate([0, 70]) circle(r = 15);
            polygon([[-7.5,0],[7.5,0],[5,60],[8,70],[-8,70],[-5,60]]);
        }
}

if (part == "target") target_plate(1);
else if (part == "mini") target_plate(mini_k);
else if (part == "popper") popper(1);
else if (part == "stand") stand();
else if (part == "assembly") assembly();
else if (part == "plate") {
    // Target + its stand laid out for one print.
    target_plate(1);
    translate([45 * s + 20 + max(stand_w, 15 * s + 30)/2, max(stand_d, 57 * s * 0.35)/2, 0]) stand();
}
