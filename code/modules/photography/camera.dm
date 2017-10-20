
#define CAMERA_PICTURE_SIZE_HARD_LIMIT 10

/obj/item/device/camera
	name = "camera"
	icon = 'icons/obj/items_and_weapons.dmi'
	desc = "A polaroid camera."
	icon_state = "camera"
	item_state = "electropack"
	var/state_on = "camera"
	var/state_off = "camera_off"
	w_class = WEIGHT_CLASS_SMALL
	flags_1 = CONDUCT_1
	slot_flags = SLOT_BELT
	materials = list(MAT_METAL=2000)
	var/pictures_max = 10
	var/pictures_left = 10
	var/on = TRUE
	var/cooldown = 64
	var/blending = FALSE		//lets not take pictures while the previous is still processing!
	var/see_ghosts = FALSE	//for the spoop of it
	var/sound/custom_sound
	var/picture_size_x = 1
	var/picture_size_y = 1

/obj/item/device/camera/CheckParts(list/parts_list)
	..()
	var/obj/item/device/camera/C = locate(/obj/item/device/camera) in contents
	if(C)
		pictures_max = C.pictures_max
		pictures_left = C.pictures_left
		visible_message("[C] has been imbued with godlike power!")
		qdel(C)

/obj/item/device/camera/spooky
	name = "camera obscura"
	desc = "A polaroid camera, some say it can see ghosts!"
	see_ghosts = TRUE

/obj/item/device/camera/detective
	name = "Detective's camera"
	desc = "A polaroid camera with extra capacity for crime investigations."
	pictures_max = 30
	pictures_left = 30
	cooldown = 32

/obj/item/device/camera/attack(mob/living/carbon/human/M, mob/user)
	return

/obj/item/device/camera/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/device/camera_film))
		if(pictures_left)
			to_chat(user, "<span class='notice'>[src] still has some film in it!</span>")
			return
		if(!user.temporarilyRemoveItemFromInventory(I))
			return
		to_chat(user, "<span class='notice'>You insert [I] into [src].</span>")
		qdel(I)
		pictures_left = pictures_max
		return
	..()

/obj/item/device/camera/examine(mob/user)
	..()
	to_chat(user, "It has [pictures_left] photos left.")

/obj/item/device/camera/proc/can_target(atom/target, mob/user, prox_flag)
	if(!on || blending || !pictures_left || (!isturf(target) && !isturf(target.loc)) || !((isAI(user) && GLOB.cameranet.checkTurfVis(get_turf(target))) || ((user.client && (get_turf(target) in get_hear(user.client.view, user)) || (get_turf(target) in get_hear(world.view, user))))))
		return FALSE
	return TRUE

/obj/item/device/camera/afterattack(atom/target, mob/user, flag)
	if(!can_target(target, user, flag))
		return

	on = FALSE
	addtimer(CALLBACK(src, .proc/cooldown), cooldown)

	INVOKE_ASYNC(src, .proc/captureimage, target, user, flag, picture_size_x, picture_size_y)


	icon_state = state_off

/obj/item/device/camera/proc/cooldown()
	icon_state = state_on
	on = TRUE

/obj/item/device/camera/proc/captureimage(atom/target, mob/user, flag, size_x = 1, size_y = 1)
	blending = TRUE
	var/turf/target_turf = get_turf(target)
	if(!isturf(target_turf))
		blending = FALSE
		return FALSE
	size_x = Clamp(size_x, 0, CAMERA_PICTURE_SIZE_HARD_LIMIT)
	size_y = Clamp(size_y, 0, CAMERA_PICTURE_SIZE_HARD_LIMIT)
	var/list/desc = list()
	var/ai_user = isAI(user)
	var/list/seen
	var/viewr = user.client? user.client.view + max(size_x, size_y) : world.view + max(size_x, size_y)
	var/viewc = user.client? user.client.eye : target
	seen = get_hear(viewr, viewc)
	var/list/turfs = list()
	var/list/mobs = list()
	var/blueprints = FALSE
	for(var/turf/T in block(locate(target_turf.x - size_x, target_turf.y - size_y, target_turf.z), locate(target_turf.x + size_x, target_turf.y + size_y, target_turf.z)))
		if((ai_user && GLOB.cameranet.checkTurfVis(T)) || T in seen)
			turfs[T] = TRUE
			for(var/mob/M in T)
				mobs[M] = TRUE
			if(locate(/obj/item/areaeditor/blueprints) in T)
				blueprints = TRUE
			CHECK_TICK
	for(var/i in mobs)
		desc += camera_get_mobdesc(i)
	var/psize_x = (size_x * 2 + 1) * world.icon_size
	var/psize_y = (size_y * 2 + 1) * world.icon_size

	var/icon/temp = getFlatIconSquare(target_turf, 1, psize_x, psize_y, turfs)

	var/icon/small_img = icon(temp)
	var/icon/ic = icon('icons/obj/items_and_weapons.dmi',"photo")
	small_img.Scale(8, 8)
	ic.Blend(small_img,ICON_OVERLAY, 13, 13)
	var/datum/picture/P = new("picture", desc.Join(""), temp, ic, psize_x, psize_y, blueprints)
	after_picture(user, P, flag)
	blending = FALSE

/obj/item/device/camera/proc/camera_get_mobdesc(mob/M)
	var/list/mob_details
	if(M.invisibility)
		if(see_ghosts && isobserver(M))
			mob_details += "You can also see a g-g-g-g-ghooooost!"
		else
			return mob_details
	var/list/holding = list()
	if(isliving(M))
		var/mob/living/L = M
		for(var/obj/item/I in L.held_items)
			if(!holding)
				holding += "[L.p_they(TRUE)] [L.p_are()] holding \a [I]"
			else
				holding += " and \a [I]"
		holding = holding.Join()
		mob_details += "You can also see [L] on the photo[L.health < (L.maxHealth * 0.75) ? " - [L] looks hurt":""].[holding ? " [holding]":"."]."
	return mob_details

/proc/getFlatIconSquare(atom/A, _range = 1, psize_x_override, psize_y_override, list/turfs_override)
	var/turf/T = get_turf(A)
	if(!istype(A) || !isturf(get_turf(A)))
		return
	return doGetFlatIconSquare(islist(turfs_override)? turfs_override : range(_range, T), T, psize_x_override? psize_x_override : (_range * 2 + 1) * world.icon_size, psize_y_override? psize_y_override : (_range * 2 + 1) * world.icon_size)

/proc/doGetFlatIconSquare(list/turfs, turf/center, psize_x = 96, psize_y = 96, see_invisibility = 0, see_ghosts = FALSE)
	var/icon/res = icon('icons/effects/96x96.dmi', "")
	res.Blend("#000", ICON_OVERLAY)
	res.Scale(psize_x, psize_y)

	var/list/atoms = list()
	for(var/turf/T in turfs)
		atoms[T] = TRUE
		for(var/atom/movable/A in T)
			if(A.invisibility > see_invisibility)
				if(!isobserver(A) || !see_ghosts)
					continue
			atoms[A] = TRUE
		CHECK_TICK

	var/list/sorted = list()
	var/j
	for(var/i = 1 to atoms.len)
		var/atom/c = atoms[i]
		for(j = sorted.len, j > 0, --j)
			var/atom/c2 = sorted[j]
			if(c2.layer <= c.layer)
				break
		sorted.Insert(j+1, c)
		CHECK_TICK

	var/xcomp = Floor(psize_x / 2) - 15
	var/ycomp = Floor(psize_y / 2) - 15
	for(var/atom/A in sorted)
		var/xo = (A.x - center.x) * world.icon_size + A.pixel_x + xcomp
		var/yo = (A.y - center.y) * world.icon_size + A.pixel_y + ycomp
		if(ismovableatom(A))
			var/atom/movable/AM = A
			xo += AM.step_x
			yo += AM.step_y
		var/icon/img = getFlatIcon(A)
		res.Blend(img, blendMode2iconMode(A.blend_mode), xo, yo)
		CHECK_TICK


	return res

/obj/item/device/camera/proc/after_picture(mob/user, datum/picture/picture, proximity_flag)
	if(istype(custom_sound))				//This is where the camera actually finishes its exposure.
		playsound(src, custom_sound, 75, 1, -3)
	else
		playsound(src, pick('sound/items/polaroid1.ogg', 'sound/items/polaroid2.ogg'), 75, 1, -3)
	printpicture(user, picture)

/obj/item/device/camera/proc/printpicture(mob/user, datum/picture/picture) //Normal camera proc for creating photos
	var/obj/item/photo/p = new/obj/item/photo(get_turf(src), picture)
	if(in_range(src, user)) //needed because of TK
		user.put_in_hands(p)
		pictures_left--
		to_chat(user, "<span class='notice'>[pictures_left] photos left.</span>")
		var/name1 = input(user, "Set a name for this photo, or leave blank. 32 characters max.", "Name") as text|null
		var/caption = input(user, "Set a caption for this photo, or leave blank. 256 characters max.", "Caption") as text|null
		if(name1)
			name1 = copytext(name, 1, 33)
			picture.picture_name = name1
		if(caption)
			caption = copytext(caption, 1, 257)
			picture.caption = caption
		p.init_photo(picture)
