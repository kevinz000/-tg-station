
//Projectile dampening field that slows projectiles and lowers their damage for an energy cost deducted every 1/5 second.
//Only use square radius for this!
/datum/proximity_monitor/advanced/peaceborg_dampener
	name = "\improper Hyperkinetic Dampener Field"
	setup_edge_turfs = TRUE
	setup_field_turfs = TRUE
	field_shape = FIELD_SHAPE_RADIUS_SQUARE
	var/obj/item/borg/projectile_dampen/projector = null
	var/list/obj/item/projectile/tracked
	var/list/obj/item/projectile/staging
	use_host_turf = TRUE

/datum/proximity_monitor/advanced/peaceborg_dampener/New()
	START_PROCESSING(SSfields, src)
	tracked = list()
	staging = list()
	edgeturf_south = mutable_appearance('icons/effects/fields.dmi', icon_state = "projectile_dampen_south")
	edgeturf_north = mutable_appearance('icons/effects/fields.dmi', icon_state = "projectile_dampen_north")
	edgeturf_west = mutable_appearance('icons/effects/fields.dmi', icon_state = "projectile_dampen_west")
	edgeturf_east = mutable_appearance('icons/effects/fields.dmi', icon_state = "projectile_dampen_east")
	northwest_corner = mutable_appearance('icons/effects/fields.dmi', icon_state = "projectile_dampen_northwest")
	southwest_corner = mutable_appearance('icons/effects/fields.dmi', icon_state = "projectile_dampen_southwest")
	northeast_corner = mutable_appearance('icons/effects/fields.dmi', icon_state = "projectile_dampen_northeast")
	southeast_corner = mutable_appearance('icons/effects/fields.dmi', icon_state = "projectile_dampen_southeast")
	generic_edge = mutable_appearance('icons/effects/fields.dmi', icon_state = "projectile_dampen_generic")
	..()

/datum/proximity_monitor/advanced/peaceborg_dampener/Destroy()
	STOP_PROCESSING(SSfields, src)
	return ..()

/datum/proximity_monitor/advanced/peaceborg_dampener/process()
	if(!istype(projector))
		qdel(src)
	var/list/ranged = list()
	for(var/obj/item/projectile/P in range(current_range, get_turf(host)))
		ranged += P
	for(var/obj/item/projectile/P in tracked)
		if(!(P in ranged) || !P.loc)
			release_projectile(P)
	for(var/mob/living/silicon/robot/R in range(current_range, get_turf(host)))
		if(R.has_buckled_mobs())
			for(var/mob/living/L in R.buckled_mobs)
				L.visible_message("<span class='warning'>[L] is knocked off of [R] by the charge in [R]'s chassis induced by [name]!</span>")	//I know it's bad.
				L.Weaken(3)
				R.unbuckle_mob(L)
				do_sparks(5, 0, L)
	..()

/datum/proximity_monitor/advanced/peaceborg_dampener/proc/capture_projectile(obj/item/projectile/P, track_projectile = TRUE)
	if(P in tracked)
		return
	projector.dampen_projectile(P, track_projectile)
	if(track_projectile)
		tracked += P

/datum/proximity_monitor/advanced/peaceborg_dampener/proc/release_projectile(obj/item/projectile/P)
	projector.restore_projectile(P)
	tracked -= P

/datum/proximity_monitor/advanced/peaceborg_dampener/field_edge_uncrossed(atom/movable/AM, obj/effect/abstract/proximity_checker/advanced/field_edge/F)
	if(!is_turf_in_field(get_turf(AM), src))
		if(istype(AM, /obj/item/projectile))
			if(AM in tracked)
				release_projectile(AM)
			else
				capture_projectile(AM, FALSE)
	return ..()

/datum/proximity_monitor/advanced/peaceborg_dampener/field_edge_crossed(atom/movable/AM, obj/effect/abstract/proximity_checker/advanced/field_edge/F)
	if(istype(AM, /obj/item/projectile) && !(AM in tracked) && staging[AM] && !is_turf_in_field(staging[AM], src))
		capture_projectile(AM)
	staging -= AM
	return ..()

/datum/proximity_monitor/advanced/peaceborg_dampener/field_edge_canpass(atom/movable/AM, obj/effect/abstract/proximity_checker/advanced/field_edge/F, turf/entering)
	if(istype(AM, /obj/item/projectile))
		staging[AM] = get_turf(AM)
	. = ..()
	if(!.)
		staging -= AM	//This one ain't goin' through.
