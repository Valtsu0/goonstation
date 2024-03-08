/proc/add_faith(amount)
	for (var/datum/trait/job/chaplain/chap in by_type[/datum/trait/job/chaplain])
		chap.faith += ((amount > 0) ? (amount * chap.faith_mult) : amount)

/proc/get_chaplain_trait(mob/target)
	return target.traitHolder?.getTrait("training_chaplain")

/proc/get_chaplain_faith(mob/target)
	var/datum/trait/job/chaplain/chap_trait = get_chaplain_trait(target)
	if (chap_trait)
		return chap_trait.faith

/proc/modify_chaplain_faith(mob/target, amount)
	var/datum/trait/job/chaplain/chap_trait = get_chaplain_trait(target)
	if (chap_trait)
		if(amount > 0)
			amount *= chap_trait.faith_mult
		chap_trait.faith += amount
		return chap_trait.faith
