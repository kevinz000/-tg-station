
/obj/item/weapon/pie_cannon
	name = "pie cannon"
	desc = "Load cream pie for optimal results"
	force = 10
	icon_state = "piecannon"
	item_state = "powerfist"
	var/obj/item/weapon/reagent_containers/food/snacks/pie/loaded = null

/obj/item/weapon/pie_cannon/attackby(obj/item/I, mob/living/L)
	if(istype(I, /obj/item/weapon/reagent_containers/food/snacks/pie))
		if(!loaded)
			I.forceMove(src)
			loaded = I
			to_chat(L, "<span class='notice'>You load the [I] into the [src]!</span>")
			return
	return ..()

/obj/item/weapon/pie_cannon/afterattack(atom/target, mob/living/user, flag, params)
	if(!P)
		return ..()
	var/obj/item/projectile/launched = new /obj/item/projectile/pie
	launched.P = loaded
	loaded.forceMove(launched)
	launched.preparePixelProjectile(target, get_turf(target), user, params, 0)
	launched.forceMove(get_turf(src))
	launched.fire()

/obj/item/projectile/pie
	name = "pie"
	desc = "Think fast!"
	var/obj/item/weapon/reagent_containers/food/snacks/pie/P = null

/obj/item/projectile/pie/on_hit(atom/A)
	. = ..()
	if(P)
		P.forceMove(get_turf(A))
		P.throw_impact(A)
