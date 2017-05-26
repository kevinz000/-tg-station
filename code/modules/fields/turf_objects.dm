
/obj/effect/abstract/proximity_checker/advanced
	name = "field"
	desc = "Why can you see energy fields?!"
	icon = null
	icon_state = null
	alpha = 0
	invisibility = INVISIBILITY_ABSTRACT
	flags = ABSTRACT|ON_BORDER
	mouse_opacity = 0
	var/datum/proximity_monitor/advanced/parent
	var/mutable_appearance/self_appearance
	var/inactive = FALSE				//Setting this to TRUE deactivates most functions.

/obj/effect/abstract/proximity_checker/advanced/update_icon()
	if(inactive)
		invisibility = INVISIBILITY_ABSTRACT
	if(self_appearance)
		appearance = self_appearance

/obj/effect/abstract/proximity_checker/advanced/proc/set_active(active)
	inactive = active
	update_icon()

/obj/effect/abstract/proximity_checker/advanced/Initialize(mapload, _monitor)
	if(_monitor)
		parent = _monitor
	return ..()

/obj/effect/abstract/proximity_checker/advanced/center
	name = "field anchor"
	desc = "No."

/obj/effect/abstract/proximity_checker/advanced/field_turf
	name = "energy field"
	desc = "Get off my turf!"

/obj/effect/abstract/proximity_checker/advanced/field_turf/CanPass(atom/movable/AM, turf/target, height)
	if(inactive)
		return TRUE
	if(parent)
		return parent.field_turf_canpass(AM, src, target)
	return TRUE

/obj/effect/abstract/proximity_checker/advanced/field_turf/Crossed(atom/movable/AM)
	if(inactive)
		return TRUE
	if(parent)
		return parent.field_turf_crossed(AM, src)
	return TRUE

/obj/effect/abstract/proximity_checker/advanced/field_turf/Uncross(atom/movable/AM)
	if(inactive)
		return TRUE
	if(parent)
		return parent.field_turf_uncross(AM, src)
	return TRUE

/obj/effect/abstract/proximity_checker/advanced/field_turf/Uncrossed(atom/movable/AM)
	if(inactive)
		return TRUE
	if(parent)
		return parent.field_turf_uncrossed(AM, src)
	return TRUE

/obj/effect/abstract/proximity_checker/advanced/field_turf/BlockSuperconductivity()
	if(inactive)
		return FALSE
	if(parent)
		return parent.field_turf_block_air(src)
	return FALSE

/obj/effect/abstract/proximity_checker/advanced/field_edge
	name = "energy field edge"
	desc = "Edgy description here."

/obj/effect/abstract/proximity_checker/advanced/field_edge/CanPass(atom/movable/AM, turf/target, height)
	if(inactive)
		return TRUE
	if(parent)
		return parent.field_edge_canpass(AM, src, target)
	return TRUE

/obj/effect/abstract/proximity_checker/advanced/field_edge/Crossed(atom/movable/AM)
	if(inactive)
		return TRUE
	if(parent)
		return parent.field_edge_crossed(AM, src)
	return TRUE

/obj/effect/abstract/proximity_checker/advanced/field_edge/Uncross(atom/movable/AM)
	if(inactive)
		return TRUE
	if(parent)
		return parent.field_edge_uncross(AM, src)
	return TRUE

/obj/effect/abstract/proximity_checker/advanced/field_edge/Uncrossed(atom/movable/AM)
	if(inactive)
		return TRUE
	if(parent)
		return parent.field_edge_uncrossed(AM, src)
	return TRUE

/obj/effect/abstract/proximity_checker/advanced/field_edge/BlockSuperconductivity()
	if(inactive)
		return FALSE
	if(parent)
		return parent.field_edge_block_air(src)
	return FALSE

/proc/is_turf_in_field(turf/T, datum/proximity_monitor/advanced/F)	//Looking for ways to optimize this!
	for(var/obj/effect/abstract/proximity_checker/advanced/O in T)
		if(istype(O, /obj/effect/abstract/proximity_checker/advanced/field_edge))
			if(O.parent == F)
				return FIELD_EDGE
		if(O.parent == F)
			return FIELD_TURF
	return NO_FIELD
