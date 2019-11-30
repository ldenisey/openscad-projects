$fn = 100;

/*
 * Basic U shape screwable holder :
 *
 *           _______                    _______
 *          /__O__ /|                  /__O__ /
 *                 ||__________________||         ↑h
 *      d/         |/__________________|/         ↓
 *
 *                 ←-------- w -------→
 *
 * s (mm) : Screw diameter
 * h (mm) : Height
 * w (mm) : Width
 * d (mm) : Depth
 * t (mm) : Thickness of the plastic
 *
 * The dimensions are interior ones, meaning iof w=10 and t=1, external width of the hook is 12 = w + 2 * t
 */
module screwableHolder(h, w, d, t = 2, s = 4) {
    difference() {
        cube([w + 2 * t, d, h + t]);
        translate([t, - 1, t]) cube([w, d + 2, h + 1]);
    }
    translate([w + 2 * t, 0, h]) screwBar(d = d, t = t, s = s);
    translate([- (s + 3 * t), 0, h]) screwBar(d = d, t = t, s = s);
}

module screwBar(d, t, s) {
    width = s + 3 * t;
    difference() {
        cube([width, d, t]);
        translate([width / 2, d / 2, - 1]) cylinder(h = t + 2, r1 = (s + t + 1) / 2, r2 = (s - 1) / 2);
    }
}

screwableHolder(h = 38, w = 54, d = 10);