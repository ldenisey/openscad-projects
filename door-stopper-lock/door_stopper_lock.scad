/*
 * Configuration. Check readme for more information about naming and how to configure this model.
 */

//---------------------------- Door and door stopper characteristics  -------------------------

// Door stopper diameter = stopper holder internal diameter.
stopper_base_diameter = 27;

// Height of the base of the stopper holder.
stopper_base_height = 17;

// Diameter of the stopper bumper.
stopper_bumper_diameter = 34;

// Wether the stopper holder should be closed (full circle, required stopper to be unscrewed) or opened (will be slide onto the stopper, easier to put but not a tight fit)
closed_stopper_holder = false;

// Door thickness
door_thickness = 40;

// Floor/door space
door_to_floor_height = 11;

//-------------------------- Optional stopper spacer ----------------------------

// 1 to generate a stopper holder spacer, 0 to skip it. The stopper holder spacer is the part between the stopper holder and the locked door. Usefull if you want to "extend" the stopper and add an extra gap between the stopper and the locked door.
stopper_spacer = 0;

// Length of the stopper holder spacer 
stopper_spacer_length = 30;

//------------------------- Optional design settings -------------------------

// Minimum height of the spacer : should be high enough to resist slamming door.
stopper_spacer_min_height = 4;

// Stopper/closed door height. If stopper_spacer is requested, must be greater than under_door_height.
stopper_spacer_height = door_to_floor_height + stopper_spacer_min_height;

// How round should the edge of the spacer
stopper_spacer_round_edge_radius = 2;

// Height of the split
stopper_spacer_split_height = 0.2;

// Width of the notch (i.e. every parts but stopper holder)
notch_width = 10;

// Length of the foot bumper
foot_bumper_length = 15;

// Thickness of the stopper holder
stopper_holder_thickness = 5;

// Length of the stopper holder handles
stopper_holder_handles_length = 10;

// Height of the part under the door. Must be lower than door_to_floor_height obviously. Anyway, must be lower enough to be flexible but big enough to resist flexion.
under_door_height = 4;

// Length of the part in front of the door
front_door_wall_length = 4;

// Space needed to ease door unlock and avoid front wall to scratch the bottom of the door.
front_door_wall_floor_extra_space = 2;

//-------------------- Computed values : do not modify ----------------------
$fn = 200;
stopper_holder_diameter = stopper_base_diameter + stopper_holder_thickness;
stopper_bumper_extra_length = max(0, (stopper_bumper_diameter - stopper_base_diameter) / 2);
stopper_spacer_split = stopper_base_height > door_to_floor_height + stopper_spacer_min_height ? true : false;

/*
 * Configuration checks.
 */
module checkConfiguration() {
    if (stopper_base_diameter > stopper_bumper_diameter) {
        echo("Warning : stopper_bumper_diameter can not be lower than stopper_base_diameter.");
    }

    if (stopper_spacer != 0 && stopper_spacer != 1) {
        echo("Warning : stopper_spacer should be valued as a boolean with 0 or 1 value.");
    }

    if (stopper_spacer == 1 && stopper_spacer_height < door_to_floor_height) {
        echo("If stopper_spacer is set, stopper_spacer_height can not be lower than door_to_floor_height, else the door will move above the spacer and reach the stopper.");
    }
}

/*
 * Stopper holder modules
 */
module stopperHolder() {
    // Create stopper holder
    if (closed_stopper_holder) {
        stopperHolderClosed();
    } else {
        stopperHolderOpened();
    }

    // Create stopper holder base : cube to give a flat side and compensate stopper_base_diameter/stopper_bumper_diameter difference if any.
    difference() {
        translate([0, - notch_width / 2, 0]) cube([stopper_holder_diameter / 2 + stopper_bumper_extra_length, notch_width, stopper_base_height]);
        translate([0, 0, - 1]) cylinder(h = stopper_base_height + 2, d = stopper_base_diameter);
    }
}

module stopperHolderClosed() {
    difference() {
        cylinder(h = stopper_base_height, d = stopper_holder_diameter);
        translate([0, 0, - 1]) cylinder(h = stopper_base_height + 2, d = stopper_base_diameter);
    }
}

module stopperHolderOpened() {
    // Create closed holder and remove 1/3 of the ring
    difference() {
        stopperHolderClosed();
        translate([- 7 / 6 * stopper_holder_diameter, - 1 / 2 * stopper_holder_diameter, - 1]) cube([stopper_holder_diameter, stopper_holder_diameter, stopper_base_height + 2]);
    }

    // Compute internal and external circles y position (thanks Pythagoras :-))
    internal_y = sqrt(pow(stopper_base_diameter / 2, 2) - pow(stopper_holder_diameter / 6, 2));
    external_y = sqrt(8) * stopper_holder_diameter / 6;

    // Create handles for opened stopper holder
    handleThickness = external_y - internal_y;
    translate([0, internal_y, 0]) stopperHolderHandle(handleThickness);
    translate([0, - internal_y - (handleThickness), 0]) stopperHolderHandle(handleThickness);
}

module stopperHolderHandle(handleThickness) {
    translate([- stopper_holder_handles_length - (1 / 6 * stopper_holder_diameter), 0, 0]) {
        cube([stopper_holder_handles_length, handleThickness, stopper_base_height]);
        translate([0, handleThickness / 2, 0]) cylinder(h = stopper_base_height, d = handleThickness);
    }
}

/*
 * Stopper holder spacer modules
 */
module stopperHolderSpacer() {
    spacer_door_z = max(stopper_base_height, stopper_spacer_height);
    translate([stopper_holder_diameter / 2 + stopper_bumper_extra_length, 0, 0]) {
        difference() {
            stopperHolderSpacerRaw();
            if (stopper_spacer_split) {
                translate([0, - notch_width / 2 - 1, - 1]) cube([stopper_spacer_length + 1, notch_width + 2, door_to_floor_height + 1 + stopper_spacer * stopper_spacer_split_height]);
            }
        }
    }
}

module stopperHolderSpacerRaw() {
    // Main trapezoid prism
    translate([0, notch_width / 2, 0])rotate([90, 0, 0]) linear_extrude(height = notch_width)
        polygon(points = [[0, 0], [stopper_spacer_length - stopper_spacer_round_edge_radius, 0],
        [stopper_spacer_length - stopper_spacer_round_edge_radius, stopper_spacer_height], [0, stopper_base_height]]);

    // Spacer front with rounded edges
    translate([stopper_spacer_length - stopper_spacer_round_edge_radius, 0, door_to_floor_height]) {
        translate([0, notch_width / 2 - stopper_spacer_round_edge_radius, 0]) stopperHolderSpacerRoundedEdge();
        translate([0, - notch_width / 2 + stopper_spacer_round_edge_radius, 0]) stopperHolderSpacerRoundedEdge();
        translate([0, - notch_width / 2 + stopper_spacer_round_edge_radius, 0])
            cube([stopper_spacer_round_edge_radius, notch_width - 2 * stopper_spacer_round_edge_radius, stopper_spacer_height - door_to_floor_height]);
    }

    // Bottom cube
    translate([stopper_spacer_length - stopper_spacer_round_edge_radius, - notch_width / 2, 0]) cube([stopper_spacer_round_edge_radius, notch_width, door_to_floor_height]);
}

module stopperHolderSpacerRoundedEdge() {
    difference() {
        cylinder(h = stopper_spacer_height - door_to_floor_height, r = stopper_spacer_round_edge_radius);
        translate([- stopper_spacer_round_edge_radius - 1, - stopper_spacer_round_edge_radius - 1, - 1])
            cube([stopper_spacer_round_edge_radius + 1, 2 * stopper_spacer_round_edge_radius + 2, stopper_spacer_height - door_to_floor_height + 2]);
    }
}

/*
 * Door notch modules
 */
module doorNotch() {
    translate([stopper_holder_diameter / 2 + stopper_bumper_extra_length + stopper_spacer * stopper_spacer_length, - notch_width / 2, door_to_floor_height - under_door_height]) {
        // Create part under the door
        doorNotchBaseAnchor();

        translate([door_thickness, 0, 0]) {
            // Create front door wall
            doorNotchFrontDoorWall();

            // Create foot bumper
            doorNotchFootBumper();
        }
    }
}

module doorNotchBaseAnchor() {
    translate([stopper_spacer_split ? - stopper_spacer * stopper_spacer_length : 0, 0, 0]) {
        cube([door_thickness + (stopper_spacer_split ? stopper_spacer * stopper_spacer_length : 0), notch_width, under_door_height]);
        translate([0, notch_width, under_door_height - door_to_floor_height]) rotate([90, 0, 0]) linear_extrude(height = notch_width)
            polygon(points = [[0, 0], [door_thickness / 4, door_to_floor_height - under_door_height], [0, door_to_floor_height - under_door_height]]);
    }
}

module doorNotchFrontDoorWall() {
    cube([front_door_wall_length / 2, notch_width, door_to_floor_height - front_door_wall_floor_extra_space - front_door_wall_length / 2]);
    translate([front_door_wall_length / 2, notch_width, door_to_floor_height - front_door_wall_floor_extra_space - front_door_wall_length / 2]) rotate([90, 0, 0]) difference() {
        cylinder(h = notch_width, d = front_door_wall_length);
        translate([0, - front_door_wall_length / 2 - 1, - 1]) cube([front_door_wall_length / 2 + 1, front_door_wall_length + 2, notch_width + 2]);
    }
}

module doorNotchFootBumper() {
    translate([front_door_wall_length, 0, 0]) {
        polygonX = foot_bumper_length - under_door_height / 2 + front_door_wall_length / 2;
        translate([- front_door_wall_length / 2, notch_width, 0]) rotate([90, 0, 0]) linear_extrude(height = notch_width)
            polygon(points = [[0, 0], [polygonX, under_door_height - 2], [polygonX, under_door_height],
            [0, door_to_floor_height - front_door_wall_floor_extra_space]]);
        translate([foot_bumper_length - under_door_height / 2, notch_width, under_door_height - 1]) rotate([90, 0, 0]) cylinder(h = notch_width, d = 2);
    }
}

/*
 * Assembly
 */
checkConfiguration();
stopperHolder();
if (stopper_spacer == 1) {
    stopperHolderSpacer();
}
doorNotch();
