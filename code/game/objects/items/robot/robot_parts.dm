/obj/item/robot_parts
	name = "robot parts"
	icon = 'icons/obj/items/robot_parts.dmi'
	item_state = "buildpipe"
	icon_state = "blank"
	flags_atom = CONDUCT
	flags_equip_slot = ITEM_SLOT_BELT
	var/list/part

/obj/item/robot_parts/l_arm
	name = "robot left arm"
	desc = "A skeletal limb wrapped in pseudomuscles, with a low-conductivity case."
	icon_state = "l_arm"
	part = list(BODY_ZONE_L_ARM, BODY_ZONE_PRECISE_L_HAND)

/obj/item/robot_parts/r_arm
	name = "robot right arm"
	desc = "A skeletal limb wrapped in pseudomuscles, with a low-conductivity case."
	icon_state = "r_arm"
	part = list(BODY_ZONE_R_ARM, BODY_ZONE_PRECISE_R_HAND)

/obj/item/robot_parts/l_leg
	name = "robot left leg"
	desc = "A skeletal limb wrapped in pseudomuscles, with a low-conductivity case."
	icon_state = "l_leg"
	part = list(BODY_ZONE_L_LEG, BODY_ZONE_PRECISE_L_FOOT)

/obj/item/robot_parts/r_leg
	name = "robot right leg"
	desc = "A skeletal limb wrapped in pseudomuscles, with a low-conductivity case."
	icon_state = "r_leg"
	part = list(BODY_ZONE_R_LEG, BODY_ZONE_PRECISE_R_FOOT)

/obj/item/robot_parts/chest
	name = "robot torso"
	desc = "A heavily reinforced case containing cyborg logic boards, with space for a standard power cell."
	icon_state = "chest"

/obj/item/robot_parts/head
	name = "robot head"
	desc = "A standard reinforced braincase, with spine-plugged neural socket and sensor gimbals."
	icon_state = "head"

/obj/item/robot_parts/robot_suit
	name = "robot endoskeleton"
	desc = "A complex metal backbone with standard limb sockets and pseudomuscle anchors."
	icon_state = "robo_suit"
