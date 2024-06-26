/obj/item/weapon_part
	name = "Weapon Part"
	desc = "A weapon part."
	icon = 'icons/obj/items/MedievalMatSci.dmi'
	icon_state = "spear"
	inhand_image_icon = 'icons/mob/inhand/hand_matsciweapons.dmi'
	item_state = "staff_crystal"
	var/length = 1
	var/next_x = 0
	var/next_y = 0
	var/previous_x = 0
	var/previous_y = 0

	//var/inhand_next = [[[0, 0], [0, 0], [0, 0], [0, 0]], [[0, 0], [0, 0], [0, 0], [0, 0]]] // is this really the most sane way to do this?

	color = "#ffffff"

	New()
		..()
		setMaterial(getMaterial("bohrum"))

/obj/item/weapon_part/head
/obj/item/weapon_part/head/dagger
	icon_state = "Weapon_Daggerblade"
	hit_type = DAMAGE_STAB
	previous_x = 17
	previous_y = 16

/obj/item/weapon_part/head/blade
	icon_state = "Part_Blade"
	item_state = "head_dagger"
	hit_type = DAMAGE_CUT
	length = 4
	previous_x = 13
	previous_y = 12


/obj/item/weapon_part/handle
	var/list/inhand_overlays_l = list()
	var/list/inhand_overlays_r = list()
	var/obj/item/weapon_part/head/head

	proc/buildOverlays()
		overlays.Cut()
		var/image/imgShaft = image(src.icon, icon_state = src.icon_state)
		imgShaft.color = src.material.getColor()
		imgShaft.alpha = src.material.getAlpha()
		imgShaft.appearance_flags = RESET_ALPHA | RESET_COLOR
		overlays += imgShaft
		if(head)
			var/image/imgHead = image(src.icon, icon_state = src.head.icon_state)
			imgHead.color = head.material.getColor()
			imgHead.alpha = head.material.getAlpha()
			imgHead.appearance_flags = RESET_ALPHA | RESET_COLOR
			imgHead.pixel_x = src.next_x - head.previous_x
			imgHead.pixel_y = src.next_y - head.previous_y
			overlays += imgHead
		return

/obj/item/weapon_part/handle/update_inhand(hand, hand_offset)
	..()
	if (hand == "R")
		inhand_image.overlays += image('icons/mob/inhand/hand_matsciweapons.dmi', "head_dagger-R")
		inhand_image.overlays -= image('icons/mob/inhand/hand_matsciweapons.dmi', "head_dagger-L")
	else
		inhand_image.overlays += image('icons/mob/inhand/hand_matsciweapons.dmi', "head_dagger-L")
		inhand_image.overlays -= image('icons/mob/inhand/hand_matsciweapons.dmi', "head_dagger-R")

/obj/item/weapon_part/handle/small
	name = "Small handle"
	desc = "Often used for daggers."
	icon_state = "Weapon_Daggergrip"
	item_state = "handle_dagger"
	next_x = 17
	next_y = 16
	New()
		..()
		buildOverlays()
		src.setItemSpecial(/datum/item_special/double)

/obj/item/weapon_part/handle/short
	name = "short handle"
	desc = "Often used for swords."
	icon_state = "Part_Handle"
	length = 2
	next_x = 22
	next_y = 21
	New()
		..()
		buildOverlays()
		src.setItemSpecial(/datum/item_special/swipe)

/obj/item/weapon_part/handle/long
	name = "long handle"
	desc = "Often used for spears."
	icon_state = "Weapon_Spearshaft"
	length = 6
	next_x = 24
	next_y = 24
	New()
		..()
		buildOverlays()
		src.setItemSpecial(/datum/item_special/rangestab)
