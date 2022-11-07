
// Depth of the spacer in mm
depth = 4.5;

// -------------------------------------------------------------------
// Body refer to the main square surface
body_x = 53;
body_y = 45;
body_angle_radius = 5;
body_hole_radius = 13.25;
body_disalignment_y = 2.5;

// Wings refers to the two trapezes with screw holes on each side of the body
wing_y_base = 18;
wing_y_top = 8;
wing_corner_radius = 1.5 / 2;
wing_x = 12;

$fn = 150;

module body() {
    difference() {
        translate([0, body_disalignment_y, 0])  hull() {
            translate([body_x / 2 - body_angle_radius, body_y / 2 - body_angle_radius, 0])
                circle(r = body_angle_radius);
            translate([body_x / 2 - body_angle_radius, - (body_y / 2 - body_angle_radius), 0])
                circle(r = body_angle_radius);
            translate([- (body_x / 2 - body_angle_radius), body_y / 2 - body_angle_radius, 0])
                circle(r = body_angle_radius);
            translate([- (body_x / 2 - body_angle_radius), - (body_y / 2 - body_angle_radius), 0])
                circle(r = body_angle_radius);
        };
        circle(r = body_hole_radius);
    };
}

module wing() {
    module half_wing() {
        translate([body_x/2,0,0])
        difference() {
            hull(){
                translate([wing_x - wing_corner_radius, wing_y_top/2 - wing_corner_radius, 0])
                    circle(r = wing_corner_radius);
                polygon([[0,0], [0, (wing_y_base)/2], [wing_x ,0]]);
            }
            translate([5.5,0,0]) circle(r=2);
        }
    }

    half_wing();
    mirror([0,1,0]) {
        half_wing();
    }
}

linear_extrude(height=depth) {
    body();
    wing();
    mirror([1,0,0]) {
        wing();
    }
}
