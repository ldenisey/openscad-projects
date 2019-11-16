/*
 * Must be customized to fit your needs.
 */

// Thickness of your desktop
desk_height = 34;

// Maximum diameter of cable you will pass in the desk : mandatory to align depth of all the pieces you will print for a given desk
cable_max_diameter = 10;

// Diameter of the cable you will pass for this piece. If set to 0, no cable passthrough
cable_diameter = 10;

/*
 * Can be customized for fine tuning.
 */
// Hook thickness
hook_thickness = 2;

// Thickness of parts that goes over and under the desk
holder_floors_height = 2;

// Extra material between the cable and the desk, should be at least as big as the hook thickness
holder_wall_thickness = hook_thickness;

// Depth of the part that goes over the desk
holder_floors_depth = 10;

// How low should be the hook
hook_height = desk_height / 2;

// How deep should the hook
hook_depth = holder_floors_depth;

// Clip diameter
clip_diameter = 7;

// Clip thickness
clip_depth = holder_wall_thickness / 2;

// Clip extra space between left and right
clip_extra = 0.2;

/*
 * Do not modify below this comment.
 * Axis : x = width, y = depth, z = height
 */
$fn = 100;
holder_block_width = cable_max_diameter + 2 * holder_wall_thickness;
holder_block_depth = cable_max_diameter + holder_wall_thickness;
holder_block_height = desk_height + (2 * holder_floors_height);
cable_radius = cable_diameter / 2;

module hook() {
    translate([holder_wall_thickness, cable_max_diameter, - hook_height]) {
        cube([holder_block_width - (2 * holder_wall_thickness), holder_wall_thickness, hook_height]);
        difference() {
            cube([holder_block_width - (2 * holder_wall_thickness), hook_depth + holder_wall_thickness, hook_height / 2]);
            translate([- 1, - 1, holder_wall_thickness]) cube([holder_block_width - (2 * holder_wall_thickness) + 2, hook_depth + 1, hook_height - holder_wall_thickness + 1]);
        }
    }
}

module cableHole() {
    translate([holder_block_width / 2, cable_radius, - 1])  union() {
        cylinder(h = holder_block_height + 2, d = cable_diameter);
        translate([- cable_radius, - cable_radius - 1, 0]) cube([cable_diameter, cable_radius + 1, holder_block_height + 2]);
    }
}

module clip(extra = 0) {
    // Translate so that the center of the module is the center of the cylinder to ease further translations
    translate([0, (clip_depth + extra) / 2, 0]) {
        rotate(90, [1, 0, 0]) cylinder(h = clip_depth + extra, d = clip_diameter + extra);
        translate([clip_diameter / 4, - (clip_depth + extra) / 2, 0]) sphere(d = 2 * clip_depth + extra);
    }
}

module rigthClip() {
    translate([holder_block_width, holder_block_depth - (clip_depth + clip_extra), holder_block_height / 2]) {
        clip(0);
    }
}

module leftClip() {
    diameter = clip_diameter + clip_extra;
    depth = clip_depth + clip_extra;
    sphere_diameter = 2 * clip_depth + clip_extra;
    translate([0, holder_block_depth - (clip_depth + clip_extra), holder_block_height / 2]) {
        clip(clip_extra);
        translate([- (diameter * 3 / 4), - sphere_diameter * 3 / 8, - sphere_diameter / 4])
            cube([diameter, sphere_diameter * 3 / 4, sphere_diameter / 2]);
    }
}

module holder() {
    union() {
        difference() {
            cube([holder_block_width, holder_block_depth + holder_floors_depth, holder_block_height]);
            translate([- 1, holder_block_depth, holder_floors_height]) cube([holder_block_width + 2, holder_floors_depth + 1, desk_height]);
        }
    }
}

/*
 * with_hook : Do you need a cable holder hook below the piece ?
 * with_left_clip : Do you need a clip to attach another piece on the left ?
 * with_right_clip : Do you need a clip to attach another piece on the right ?
 */
module deskBlock(with_hook, with_left_clip, with_right_clip) {
    union() {
        difference() {
            holder();
            if (cable_diameter > 0) cableHole();
            if (with_left_clip) leftClip();
        }
        if (with_hook) hook();
        if (with_right_clip) rigthClip();
    }
}

deskBlock(false, true, true);
