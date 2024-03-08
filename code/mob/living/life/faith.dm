
/datum/lifeprocess/faith

	process(var/datum/gas_mixture/environment)
		var/mult = get_multiplier()

		if (isunconscious(owner) || isdead(owner) || !owner.mind || isghostcritter(owner) || isintangible(owner) || !isliving(owner))
			// do nothing
		else if (owner.traitHolder.hasTrait("training_chaplain"))
			modify_chaplain_faith(owner, min(FAITH_STARTING / max(1, get_chaplain_faith(owner)), 5) * mult) // helps chaplains get back to normal
		else if (!istype(get_area(owner), /area/station/chapel))
			// others need to be in the chapel
		else if (isvampire(owner) || isvampiricthrall(owner) || iswraith(owner) || owner.bioHolder.HasEffect("revenant"))
			// vampires are unholy and will not produce faith unless they are a chaplain
		else if (owner.traitHolder.hasTrait("atheist"))
		else
			add_faith(FAITH_GEN_BASE * mult)
		..()
