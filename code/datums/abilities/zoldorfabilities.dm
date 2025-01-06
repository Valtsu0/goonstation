//Zoldorf Abilities
/datum/abilityHolder/zoldorf
	topBarRendered = 1
	pointName = "Souls"
	regenRate = 0
	notEnoughPointsMessage = SPAN_ALERT("You do not have enough souls to use that ability.")
	cast_while_dead = 1

/atom/movable/screen/ability/topBar/zoldorf
	tens_offset_x = 19
	tens_offset_y = 7
	secs_offset_x = 23
	secs_offset_y = 7

/datum/targetable/zoldorfAbility
	icon = 'icons/obj/zoldorf.dmi'
	icon_state = "background"
	cooldown = 0
	last_cast = 0
	targeted = 1
	target_anything = 1
	preferred_holder_type = /datum/abilityHolder/zoldorf

	New()
		var/atom/movable/screen/ability/topBar/zoldorf/B = new /atom/movable/screen/ability/topBar/zoldorf(null)
		B.icon = src.icon
		B.icon_state = src.icon_state
		B.owner = src
		B.name = src.name
		B.desc = src.desc
		src.object = B

	cast(atom/target)
		. = ..()
		if (!holder || !holder.owner)
			return 1

/datum/targetable/zoldorfAbility/fortune //yay mad libs. its basically a bunch of input checks and dynamic popups and some animations while its active :)
	name = "Tell Fortune"
	desc = "Weave your own words into a fortune."
	icon_state = "fortune"
	targeted = 0
	cooldown = 100

	//backups just in case the fortune generation pools changed since 2016
	var/list/fortune_strings = list()
	//other zoldorf fortune information
	var/regex/parser_regex

	New()
		src.parser_regex = regex(@"(\(.*?\))")
		..()

	proc/getStrings(var/category)
		if (!(category in src.fortune_strings))
			src.fortune_strings[category] = strings("zoldorf.txt", category)
			sortList(src.fortune_strings[category], /proc/cmp_text_asc)
		return src.fortune_strings[category]

	proc/ZoldorfParser(var/string, var/max_loops=20)
		while (max_loops)
			max_loops--
			if (!src.parser_regex.Find(string))
				return string
			var/category = copytext(src.parser_regex.match, 2, -1)
			if (findtext(category, "/"))
				category = tgui_input_list(usr, src.parser_regex.Replace(string, "______"), "Choose a category", splittext(category, "/"))

			var/result
			if (category == "number")
				result = get_english_num(tgui_input_number(usr, src.parser_regex.Replace(string, "______"), "number", 1, 999999, 0))
			else
				result = tgui_input_list(usr, src.parser_regex.Replace(string, "______"), category, src.getStrings(category))
			string = src.parser_regex.Replace(string, result)

	cast(atom/target)
		var/sentence
		var/speechinput
		var/list/sentences = list()
		var/mob/zoldorf/user = holder.owner
		var/infothing
		var/list/sounds_working = list('sound/misc/automaton_scratch.ogg','sound/machines/mixer.ogg')
		var/maxlines

		if((user.loc != user.homebooth)&&(user.homebooth != null))
			boutput(user,SPAN_ALERT("<b>You must be in your booth to use this ability!</b>"))
			return 1
		. = ..()
		var/obj/machinery/playerzoldorf/pz = user.loc
		var/list/zoldorflist = list(SPAN_NOTICE("[pz] makes a mystical gesture!</b>"),SPAN_NOTICE("[pz] rocks back and forth!"))
		if((user.abilityHolder.points <= 3)&&(user.abilityHolder.points > 0))
			maxlines = user.abilityHolder.points + 3
		else if(user.abilityHolder.points > 3)
			maxlines = 6
		else if(user.abilityHolder.points == 0)
			maxlines = 3

		pz.UpdateOverlays(image('icons/obj/zoldorf.dmi',"fortunetelling"),"fortunetelling")

		pz.visible_message(SPAN_NOTICE("[pz] wakes up!"))
		playsound(pz.loc, 'sound/machines/fortune_riff.ogg', 60, 1)

		if(user.firstfortune == 1)
			speechinput = tgui_input_list(usr, "Which titles would you like? (i.e. 'great and powerful')", "Adjective", src.getStrings("adjective"))
			if(speechinput)
				user.fortunemessage += "The [speechinput] and "
			else
				user.fortunemessage = null
				pz.ClearSpecificOverlays("fortunetelling")
				return 1
			speechinput = tgui_input_list(usr, "Which titles would you like? (i.e. 'great and powerful')", "Adjective", src.getStrings("adjective"))
			if(speechinput)
				user.fortunemessage += "[speechinput]"
			else
				user.fortunemessage = null
				pz.ClearSpecificOverlays("fortunetelling")
				return 1
			user.firstfortune = 0

		//add sentences to a list to support multiple lines
		for(var/i=1,i<=maxlines,i++)
			sentence = ZoldorfParser("(sentence)")
			if(sentence)
				boutput(holder.owner, SPAN_SUCCESS("[sentence]"))
				sentences.Add(sentence)
				sentence = ""

			pz.visible_message(pick(zoldorflist))
			playsound(pz.loc, pick(sounds_working), 40, 1)
		pz.ClearSpecificOverlays("fortunetelling")
		if(!sentences.len)
			return 1
		infothing = "<font face='System' size='3'><center>YOUR FORTUNE</center><br><br>\
		[user.fortunemessage] [holder.owner] has [pick(src.getStrings("read"))] your [pick(src.getStrings("mystical"))]!<br><br>"
		for(var/i=1,i<=sentences.len,i++)
			infothing += sentences[i]
			infothing += "<br><br>"
		infothing += "</font>"

		if(!istype(holder.owner.loc,/obj/machinery/playerzoldorf))
			return 1
		var/obj/item/paper/thermal/playerfortune/pf = new(get_turf(holder.owner))
		pf.info = infothing
		pf.layer = 7

		playsound(pz.loc, 'sound/machines/fortune_laugh.ogg', 65, 1)
		pz.visible_message(SPAN_SAY("[SPAN_NAME("[pz]")] beeps, \"Ha ha ha ha ha!\""))


/datum/targetable/zoldorfAbility/addsoul //debug tool
	name = "Add Soul"
	desc = "Adds a soul."
	icon_state = "addsoul"
	targeted = 0
	cooldown = 0

	cast(atom/target)
		var/mob/zoldorf/user = holder.owner
		if((user.loc != user.homebooth)&&(user.homebooth != null))
			boutput(user,SPAN_ALERT("<b>You must be in your booth to use this ability!</b>"))
			return
		. = ..()
		var/obj/machinery/playerzoldorf/pz = user.loc

		user.abilityHolder.points++
		pz.storedsouls++

/datum/targetable/zoldorfAbility/removesoul //also a debug tool
	name = "Remove Soul"
	desc = "Removes a soul."
	icon_state = "removesoul"
	targeted = 0
	cooldown = 0

	cast(atom/target)
		var/mob/zoldorf/user = holder.owner
		if((user.loc != user.homebooth)&&(user.homebooth != null))
			boutput(user,SPAN_ALERT("<b>You must be in your booth to use this ability!</b>"))
			return
		. = ..()
		var/obj/machinery/playerzoldorf/pz = user.loc

		user.abilityHolder.points--
		pz.storedsouls--

/datum/targetable/zoldorfAbility/omen //calls the omen proc of the zoldorf's booth
	name = "Omen"
	desc = "Changes the color of your crystal ball."
	icon_state = "omen"
	targeted = 0
	cooldown = 100

	cast(atom/target)
		var/mob/zoldorf/user = holder.owner
		if((user.loc != user.homebooth)&&(user.homebooth != null))
			boutput(user,SPAN_ALERT("<b>You must be in your booth to use this ability!</b>"))
			return 1
		. = ..()
		var/obj/machinery/playerzoldorf/pz = user.loc
		pz.omen = 1
		return !pz.omen(user)

/datum/targetable/zoldorfAbility/brand
	name = "Brand"
	desc = "Brands a visible fortune."
	icon_state = "brand"
	targeted = 1
	cooldown = 600

	cast(atom/target)
		var/mob/zoldorf/user = holder.owner
		if((user.loc != user.homebooth)&&(user.homebooth != null))
			boutput(user,SPAN_ALERT("<b>You must be in your booth to use this ability!</b>"))
			return 1
		. = ..()
		var/obj/machinery/playerzoldorf/pz = user.loc
		if(istype(target,/obj/item/paper/thermal/playerfortune))
			var/obj/item/paper/thermal/playerfortune/f = target
			if(f.branded)
				boutput(holder.owner,SPAN_ALERT("<b>This fortune is already branded!</b>"))
				return 1
			else
				f.icon = 'icons/obj/zoldorf.dmi'
				f.icon_state = "branded"
				SPAWN(3.2 SECONDS)
					f.icon_state = "fortunepaper"
				f.branded = 1
				f.referencedorf = pz
				boutput(holder.owner, SPAN_SUCCESS("<b>You have successfully branded a fortune! The next player to examine it will be targetable by Astral Projection.</b>"))

		else
			boutput(holder.owner, SPAN_ALERT("<b>You must target a fortune!</b>"))
			return 1

/datum/targetable/zoldorfAbility/astral
	name = "Astral Projection"
	desc = "Allows you to observe a branded entity."
	icon_state = "astralprojection"
	targeted = 0
	cooldown = 0

	cast(atom/target)
		. = ..()
		var/mob/zoldorf/user = holder.owner
		var/destination
		if(istype(user.loc,/obj/machinery/playerzoldorf))
			var/obj/machinery/playerzoldorf/pz = user.loc
			user.homebooth = pz
			var/staticiterations = length(pz.brandlist)
			for(var/i=1,i<=staticiterations,i++)
				if(pz.brandlist[i]==null)
					pz.brandlist -= pz.brandlist[i]
					staticiterations--
					i--
			destination = input("Whom do you wish to observe?", "Target", null) as null|anything in pz.brandlist
		else
			var/obj/machinery/playerzoldorf/pz = user.homebooth
			destination = input("Whom do you wish to observe?", "Target", null) as null|anything in pz.brandlist
		if((!istype(user.loc,/obj/machinery/playerzoldorf)) && (!istype(user.loc,/mob/)))
			return
		if(!destination)
			return
		if(destination == user.loc)
			return
		if(destination == "home")
			if(user.homebooth)
				user.stopObserving()
			else
				return
		else
			user.observeMob(destination)

/datum/targetable/zoldorfAbility/medium
	name = "Medium"
	desc = "Allows you to hear dead chat for 30 seconds."
	icon_state = "medium"
	targeted = 0
	cooldown = 3000

	cast(atom/target) //uses omen for the crystal ball animation and light, required setting the zoldorf to stat 2 to hear dead chat easily.
		var/mob/zoldorf/user = holder.owner
		var/obj/machinery/playerzoldorf/pz = user.homebooth
		if((user.loc != user.homebooth)&&(user.homebooth != null))
			boutput(user,SPAN_ALERT("<b>You must be in your booth to use this ability!</b>"))
			return 1
		. = ..()
		if(!pz.omen)
			pz.omen(user)
		else
			boutput(user,SPAN_ALERT("<b>You must disable your current omen in order to activate the ghost light!</b>"))
			return 1

/datum/targetable/zoldorfAbility/manifest //spooky time
	name = "Manifest"
	desc = "Temporarily become a visible spirit."
	icon_state = "manifest"
	targeted = 0
	cooldown = 0
	pointCost = 1
	special_screen_loc = "TOP,LEFT+7"

	cast(atom/target)
		var/mob/zoldorf/user = holder.owner
		if((user.loc != user.homebooth)&&(user.homebooth != null))
			boutput(user,SPAN_ALERT("<b>You must be in your booth to use this ability!</b>"))
			return 1
		. = ..()
		var/obj/machinery/playerzoldorf/pz = user.loc
		pz.storedsouls--
		var/boothloc = get_turf(pz)
		var/list/deadpeople = list()
		for (var/mob/M in mobs)
			if (istype(M, /mob/new_player))
				continue
			if(istype(M,/mob/dead/observer) || istype(M,/mob/zoldorf))
				deadpeople += M.real_name

		var/mob/sg = user.make_seance(null,user,deadpeople)
		sg.set_loc(boothloc)
		var/obj/ectoplasm = new /obj/item/reagent_containers/food/snacks/ectoplasm
		ectoplasm.set_loc(boothloc)
		sleep(60 SECONDS)
		if(sg?.mind)
			sg.mind.transfer_to(user)
			qdel(sg)

/datum/targetable/zoldorfAbility/seance //mega spooky time
	name = "Seance"
	desc = "Manifests all visible spirits and souldorfs!"
	icon_state = "seance"
	targeted = 0
	cooldown = 0
	pointCost = 5
	special_screen_loc = "TOP,LEFT+8"

	cast(atom/target)
		var/mob/zoldorf/user = holder.owner
		if((user.loc != user.homebooth)&&(user.homebooth != null))
			boutput(user,SPAN_ALERT("<b>You must be in your booth to use this ability!</b>"))
			return 1
		. = ..()
		var/obj/machinery/playerzoldorf/pz = user.loc
		pz.storedsouls--
		pz.lightrfade(5)
		var/list/deadpeople = list()
		for (var/mob/M in mobs)
			var/mob/the_mob = M
			if (istype(the_mob, /mob/new_player))
				continue
			if(istype(the_mob,/mob/dead/observer) || istype(the_mob,/mob/zoldorf))
				if(!M.client || !M.mind)
					continue
				deadpeople += M.real_name
				if(the_mob == user || (the_mob.client && (get_turf(the_mob) in range(the_mob.client.view, get_turf(user)))))
					var/mobloc = get_turf(the_mob) // TODO add consent
					var/mob/living/intangible/seanceghost/sg
					if(istype(the_mob,/mob/zoldorf))
						sg = the_mob.make_seance(null,the_mob,deadpeople)
					else
						sg = the_mob.make_seance(the_mob,null,deadpeople)
					sg.set_loc(mobloc)
					var/obj/ectoplasm = new /obj/item/reagent_containers/food/snacks/ectoplasm
					ectoplasm.set_loc(mobloc)
					SPAWN(600)
						if(sg?.mind)
							if(istype(the_mob,/mob/zoldorf))
								sg.mind.transfer_to(the_mob)
								qdel(sg)
							else
								sg.gib(1) // TODO does this all make them uncloneable?
		sleep(55 SECONDS)
		pz.lightfade(5)
		pz.remove_simple_light("zoldorf")

/datum/targetable/zoldorfAbility/color //a color changing ability for freed souldorfs :D
	name = "Change Color"
	desc = "Changes your soul color."
	icon_state = "changecolor"
	targeted = 0
	cooldown = 100

	cast(atom/target)
		. = ..()
		var/mob/zoldorf/user = holder.owner
		var/color
		color = input(user,"Which soul color would you like?") as color
		if(!color)
			return 1
		else
			user.color = color

/datum/targetable/zoldorfAbility/notes //notes past from zoldorf to zoldorf, pretty much paper code but stored in an ability with some tagging and admin logging
	name = "Notes"
	desc = "Leave notes for yourself and future zoldorfs."
	icon_state = "notes"
	targeted = 0

	cast(atom/target)
		var/mob/zoldorf/user = holder.owner
		. = ..()
		if(user.homebooth)
			var/obj/machinery/playerzoldorf/pz = user.homebooth
			var/list/selections = list("Read Notes","Add Note","Remove Note")
			var/selection

			selection = input("Choose an option", "Notes", null) as null|anything in selections

			if(!selection)
				return
			switch(selection)
				if("Read Notes")
					if(!pz.notes.len)
						boutput(user,SPAN_ALERT("<b>You have no saved notes!</b>"))
						return

					var/aaa //modified list data
					for(var/i=1,i<=pz.notes.len,i++)
						var/yeet = "<span>"
						yeet+=pz.notes[i]
						yeet+="<br><br></span>"
						aaa+=yeet
					tgui_message(usr, "[aaa]", "Notes")

				if("Add Note")
					var/note
					note = input("Note") as null|text
					if(!note)
						return
					note = strip_html(note,MAX_MESSAGE_LEN)
					note += " - [user.name]"
					logTheThing(LOG_SAY, user, "[user] has created a Zoldorf note: [note]")
					if(pz)
						pz.notes.Add(note)
						boutput(user,SPAN_SUCCESS("<b>Note added!</b>"))
				if("Remove Note")
					if(!pz.notes.len)
						boutput(user,SPAN_ALERT("<b>You have no saved notes!</b>"))
						return
					var/select
					select = input("Which note would you like to remove?", "Notes", null) as null|anything in pz.notes
					if(!select)
						return
					if(pz)
						pz.notes -= select
						boutput(user,SPAN_SUCCESS("<b>Note removed!</b>"))

/datum/targetable/zoldorfAbility/jar //where else would you store fragments of peoples' souls?
	name = "Soul Jar"
	desc = "Visual display of partial souls stored in the booth."
	icon_state = "jare"
	special_screen_loc = "TOP-1,LEFT"
	targeted = 0
	cooldown = 0

	cast(atom/target)
		var/mob/zoldorf/user = holder.owner
		. = ..()
		if(user.homebooth)
			var/obj/machinery/playerzoldorf/pz = user.homebooth
			boutput(user,SPAN_SUCCESS("<b>You have accumulated [pz.partialsouls]% of a soul!</b>"))

/datum/targetable/zoldorfAbility/help //pretty much a copy paste of wraith help just in case the tooltips dont take over on merge
	name = "Toggle Help Mode"
	desc = "Enter or exit help mode."
	icon_state = "helpoff"
	targeted = 0
	cooldown = 0
	helpable = 0
	special_screen_loc = "SOUTH,WEST"

	cast(atom/target)
		if (..())
			return 1
		if (holder.help_mode)
			holder.help_mode = 0
			src.object.icon_state = "helpoff"
			boutput(holder.owner, SPAN_NOTICE("<strong>Help Mode has been deactivated.</strong>"))
		else
			holder.help_mode = 1
			src.object.icon_state = "helpon"
			boutput(holder.owner, SPAN_SUCCESS("<strong>Help Mode has been activated. To disable it, click on this button again.</strong>"))
			boutput(holder.owner, SPAN_SUCCESS("Hold down Shift, Ctrl or Alt while clicking the button to set it to that key."))
			boutput(holder.owner, SPAN_SUCCESS("You will then be able to use it freely by holding that button and left-clicking a tile."))
			boutput(holder.owner, SPAN_SUCCESS("Alternatively, you can click with your middle mouse button to use the ability on your current tile."))
		holder.updateButtons()
