/*
 * Generate one desk block.
 *
 * desk_height : Thickness of your desktop
 * cable_max_diameter : Maximum diameter of cable you will pass in the desk : mandatory to align depth of all the pieces you will print for a given desk
 * cable_diameter : Diameter of the cable you will pass for this piece. If set to 0, no cable passthrough
 * with_hook : Do you need a cable holder hook below the piece ?
 * with_left_slot : Do you need a slot to attach another piece on the left ?
 * with_right_slot : Do you need a slot to attach another piece on the right ?
 */
module deskBlock(desk_height, cable_max_diameter, cable_diameter, with_hook, with_left_slot, with_right_slot) {

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

    module rigthSlot() {
        translate([holder_block_width, cable_max_diameter - holder_wall_thickness - 1, 0]) {
            linear_extrude(height = holder_block_height - holder_floors_height)
                polygon(points = [[1, - 2], [1, 2], [- 1, 0]]);
        }
        translate([holder_block_width, 0, holder_block_height - holder_floors_height])
            cube([1, holder_block_depth + holder_floors_depth, holder_floors_height]);
    }

    module leftSlot() {
        // slot extra space between left and right
        slot_extra = 0.1;
        difference() {
            union() {
                translate([- 1, 0, 0]) cube([1, holder_block_depth, holder_block_height - holder_floors_height]);
                translate([- 1, holder_block_depth, 0]) cube([1, holder_floors_depth, holder_floors_height]);
            }
            translate([- 1, cable_max_diameter - holder_wall_thickness - 1, - 1]) {
                linear_extrude(height = holder_block_height - holder_floors_height + 2)
                    polygon(points = [[1, - 2 - slot_extra], [1, 2 + slot_extra], [- 1 - slot_extra, 0]]);
            }
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

    union() {
        difference() {
            holder();
            if (cable_diameter > 0) cableHole();
        }
        if (with_hook) hook();
        if (with_right_slot) rigthSlot();
        if (with_left_slot) leftSlot();
    }
}

/*deskBlock(34, 10, 6, false, true, false);
translate([14, 0, 0]) deskBlock(34, 10, 7, false, false, false);
translate([14*2, 0, 0]) deskBlock(34, 10, 6, true, false, true);*/

deskBlock(34, 10, 7, true, true, true);
