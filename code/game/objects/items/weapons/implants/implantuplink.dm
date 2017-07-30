/obj/item/weapon/implant/uplink
	name = "uplink implant"
	desc = "Sneeki breeki."
	icon = 'icons/obj/radio.dmi'
	icon_state = "radio"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	var/starting_tc = 0

/obj/item/weapon/implant/uplink/New()
	hidden_uplink = new(src)
	hidden_uplink.telecrystals = starting_tc
	..()

/obj/item/weapon/implant/uplink/implant(mob/living/target, mob/user, silent = 0)
	for(var/X in target.implants)
		if(istype(X, type))
			var/obj/item/weapon/implant/imp_e = X
			imp_e.hidden_uplink.telecrystals += hidden_uplink.telecrystals
			qdel(src)
			return 1

	if(..())
		hidden_uplink.owner = "[user.key]"
		return 1
	return 0

/obj/item/weapon/implant/uplink/activate()
	if(hidden_uplink)
		hidden_uplink.interact(usr)

/obj/item/weapon/implanter/uplink
	name = "implanter (uplink)"
	imp_type = /obj/item/weapon/implant/uplink

/obj/item/weapon/implanter/uplink/precharged
	name = "implanter (precharged uplink)"
	imp_type = /obj/item/weapon/implant/uplink/precharged

/obj/item/weapon/implant/uplink/precharged
	starting_tc = 10
