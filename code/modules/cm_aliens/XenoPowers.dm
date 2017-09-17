

/mob/living/carbon/Xenomorph/proc/Pounce(atom/T)

	if(!T) return

	if(!check_state())
		return

	if(usedPounce)
		src << "<span class='warning'>You must wait before pouncing.</span>"
		return

	if(!check_plasma(10))
		return

	visible_message("<span class='xenowarning'>\The [src] pounces at \the [T]!</span>", \
	"<span class='xenowarning'>You pounce at \the [T]!</span>")
	usedPounce = 30 //About 12 seconds
	flags_pass = PASSTABLE
	use_plasma(10)
	if(readying_tail)
		readying_tail = 0
	throw_at(T, 6, 2, src) //Victim, distance, speed
	spawn(6)
		if(!hardcore)
			flags_pass = initial(flags_pass) //Reset the passtable.
		else
			flags_pass = 0 //Reset the passtable.

	spawn(usedPounce)
		usedPounce = 0
		src << "<span class='notice'>You get ready to pounce again.</span>"
		for(var/X in actions)
			var/datum/action/A = X
			A.update_button_icon()

	return 1

/mob/living/carbon/Xenomorph/proc/vent_crawl()
	set name = "Crawl through Vent"
	set desc = "Enter an air vent and crawl through the pipe system."
	set category = "Alien"
	if(!check_state())
		return
	var/pipe = start_ventcrawl()
	if(pipe)
		handle_ventcrawl(pipe)



//Note: All the neurotoxin projectile items are stored in XenoProcs.dm
/mob/living/carbon/Xenomorph/proc/xeno_spit(atom/T)

	if(!check_state())
		return

	if(!isturf(loc))
		src << "<span class='warning'>You can't spit from here!</span>"
		return

	if(has_spat > world.time)
		src << "<span class='warning'>You must wait for your spit glands to refill.</span>"
		return

	if(!check_plasma(ammo.spit_cost))
		return

	var/turf/current_turf = get_turf(src)

	if(!current_turf)
		return

	visible_message("<span class='xenowarning'>\The [src] spits at \the [T]!</span>", \
	"<span class='xenowarning'>You spit at \the [T]!</span>" )
	var/sound_to_play = pick(1, 2) == 1 ? 'sound/voice/alien_spitacid.ogg' : 'sound/voice/alien_spitacid2.ogg'
	playsound(src.loc, sound_to_play, 25, 1)

	var/obj/item/projectile/A = rnew(/obj/item/projectile, current_turf)
	A.generate_bullet(ammo)
	A.permutated += src
	A.def_zone = get_organ_target()
	A.fire_at(T, src, null, ammo.max_range, ammo.shell_speed)
	has_spat = world.time + spit_delay + ammo.added_spit_delay
	use_plasma(ammo.spit_cost)
	cooldown_notification(spit_delay + ammo.added_spit_delay, "spit")

	return TRUE

/mob/living/carbon/Xenomorph/proc/cooldown_notification(cooldown, message)
	set waitfor = 0
	sleep(cooldown)
	switch(message)
		if("spit")
			src << "<span class='notice'>You feel your neurotoxin glands swell with ichor. You can spit again.</span>"
	for(var/X in actions)
		var/datum/action/A = X
		A.update_button_icon()



//Corrosive acid is consolidated -- it checks for specific castes for strength now, but works identically to each other.
//The acid items are stored in XenoProcs.
/mob/living/carbon/Xenomorph/proc/corrosive_acid(atom/O, acid_type, plasma_cost)

	if(!O.Adjacent(src))
		src << "<span class='warning'>\The [O] is too far away.</span>"
		return

	face_atom(O)

	var/wait_time = 10

	//OBJ CHECK
	if(isobj(O))
		var/obj/I = O
		if(I.unacidable || istype(I, /obj/machinery/computer) || istype(I, /obj/effect)) //So the aliens don't destroy energy fields/singularies/other aliens/etc with their acid.
			src << "<span class='warning'>You cannot dissolve \the [I].</span>" // ^^ Note for obj/effect.. this might check for unwanted stuff. Oh well
			return
		if(istype(O, /obj/structure/window_frame/almayer/colony/reinforced) && acid_type != /obj/effect/xenomorph/acid/strong)
			src << "<span class='warning'>This [O.name] is too tough to be melted by your weak acid.</span>"
			return
	//TURF CHECK
	else if(istype(O, /turf/simulated) || istype(O, /turf/unsimulated))
		var/turf/T = O
		//R WALL
		if(istype(T, /turf/unsimulated/floor) || istype(T, /turf/simulated/shuttle) || istype(T, /turf/simulated/floor) || istype(T,/turf/simulated/mineral) || istype(T,/turf/unsimulated/wall/gm) || istype(T,/turf/simulated/wall/r_wall/unmeltable) || istype(T,/turf/simulated/wall/sulaco/unmeltable) || istype(T, /turf/simulated/wall/almayer/outer) || istype(T, /turf/simulated/wall/almayer/research))
			src << "<span class='warning'>You cannot dissolve \the [T].</span>"
			return
		if(istype(T, /turf/simulated/wall/r_wall) && acid_type != /obj/effect/xenomorph/acid/strong)
			src << "<span class='warning'>This [T.name] is too tough to be melted by your weak acid.</span>"
			return

		if (istype(T, /turf/simulated/wall/r_wall))
			src << "<span class='xenowarning'>You begin generating enough acid to melt through \the [T].</span>"
			wait_time = 100
		else if (istype(T, /turf/simulated/wall) || istype(T, /turf/unsimulated/wall))
			src << "<span class='xenowarning'>You begin generating enough acid to melt through \the [T].</span>"
			wait_time = 50

	else
		src << "<span class='warning'>You cannot dissolve \the [O].</span>"
		return

	if(!do_after(src, wait_time, TRUE, 5, BUSY_ICON_CLOCK))
		return

	if(!check_state())
		return

	if(!O || !get_turf(O)) //Some logic.
		return

	if(!check_plasma(plasma_cost))
		return
	use_plasma(plasma_cost)

	var/obj/effect/xenomorph/acid/A = new acid_type(get_turf(O), O)
	if(isturf(O))
		A.icon_state += "_wall"

	if(istype(O, /obj/structure) || istype(O, /obj/machinery)) //Always appears above machinery
		A.layer = O.layer + 0.1
	else //If not, appear on the floor (turf layer is 2, vents are 2.4)
		A.layer = 2.41

	if(!isturf(O))
		msg_admin_attack("[src.name] ([src.ckey]) spat acid on [O].")
		attack_log += text("\[[time_stamp()]\] <font color='green'>Spat acid on [O]</font>")
	visible_message("<span class='xenowarning'>\The [src] vomits globs of vile stuff all over \the [O]. It begins to sizzle and melt under the bubbling mess of acid!</span>", \
	"<span class='xenowarning'>You vomit globs of vile stuff all over \the [O]. It begins to sizzle and melt under the bubbling mess of acid!</span>")



/mob/living/carbon/Xenomorph/proc/tail_attack()
	set name = "Ready Tail Attack (20)"
	set desc = "Wind up your tail for a devastating stab on your next harm attack. Drains plasma when active."
	set category = "Alien"

	if(!check_state())
		return

	if(!readying_tail)
		if(!check_plasma(20))
			return
		storedplasma -= 20
		visible_message("<span class='warning'>\The [src]'s tail starts to coil like a spring.</span>", \
		"<span class='notice'>You begin to ready your tail for a vicious attack. This will drain plasma to keep active.</span>")
		readying_tail = 1
	else
		visible_message("<span class='notice'>\The [src]'s tail relaxes.</span>", \
		"<span class='notice'>You relax your tail. You are no longer readying a tail attack.</span>")
		readying_tail = 0




/mob/living/carbon/Xenomorph/verb/hive_status()
	set name = "Hive Status"
	set desc = "Check the status of your current hive."
	set category = "Alien"

	check_hive_status()


/proc/check_hive_status()
	var/dat = "<html><head><title>Hive Status</title></head><body>"

	var/count = 0
	var/queen_list = ""
	//var/exotic_list = ""
	//var/exotic_count = 0
	var/boiler_list = ""
	var/boiler_count = 0
	var/crusher_list = ""
	var/crusher_count = 0
	var/praetorian_list = ""
	var/praetorian_count = 0
	var/ravager_list = ""
	var/ravager_count = 0
	var/carrier_list = ""
	var/carrier_count = 0
	var/hivelord_list = ""
	var/hivelord_count = 0
	var/hunter_list = ""
	var/hunter_count = 0
	var/spitter_list = ""
	var/spitter_count = 0
	var/drone_list = ""
	var/drone_count = 0
	var/runner_list = ""
	var/runner_count = 0
	var/sentinel_list = ""
	var/sentinel_count = 0
	var/larva_list = ""
	var/larva_count = 0
	for(var/mob/living/carbon/Xenomorph/X in living_mob_list)
		var/area/A = get_area(X)
		var/xenoinfo = "<tr><td>[X.name] "
		if(!X.client) xenoinfo += " <i>(SSD)</i>"
		if(X.stat == DEAD)
			count++ //Dead players shouldn't be on this list, but who knows
			xenoinfo += " <b><font color=red>(DEAD)</font></b></td></tr>"
		else xenoinfo += " <b><font color=green>([A ? A.name : null])</b></td></tr>"

		if(isXenoQueen(X))
			queen_list += xenoinfo
		if(isXenoBoiler(X))
			boiler_list += xenoinfo
			boiler_count++
		if(isXenoCrusher(X))
			crusher_list += xenoinfo
			crusher_count++
		if(isXenoPraetorian(X))
			praetorian_list += xenoinfo
			praetorian_count++
		if(isXenoRavager(X))
			ravager_list += xenoinfo
			ravager_count++
		if(isXenoCarrier(X))
			carrier_list += xenoinfo
			carrier_count++
		if(isXenoHivelord(X))
			hivelord_list += xenoinfo
			hivelord_count++
		if(isXenoHunter(X))
			hunter_list += xenoinfo
			hunter_count++
		if(isXenoSpitter(X))
			spitter_list += xenoinfo
			spitter_count++
		if(isXenoDrone(X))
			drone_list += xenoinfo
			drone_count++
		if(isXenoRunner(X))
			runner_list += xenoinfo
			runner_count++
		if(isXenoSentinel(X))
			sentinel_list += xenoinfo
			sentinel_count++
		if(isXenoLarva(X))
			larva_list += xenoinfo
			larva_count++

	dat += "<b>Total Living Sisters: [count]</b><BR>"
	//if(exotic_count != 0) //Exotic Xenos in the Hive like Predalien or Xenoborg
		//dat += "<b>Ultimate Tier:</b> [exotic_count] Sisters</b><BR>"
	dat += "<b>Tier 3: [boiler_count + crusher_count + praetorian_count + ravager_count] Sisters</b> | Boilers: [boiler_count] | Crushers: [crusher_count] | Praetorians: [praetorian_count] | Ravagers: [ravager_count]<BR>"
	dat += "<b>Tier 2: [carrier_count + hivelord_count + hunter_count + spitter_count] Sisters</b> | Carriers: [carrier_count] | Hivelords: [hivelord_count] | Hunters: [hunter_count] | Spitters: [spitter_count]<BR>"
	dat += "<b>Tier 1: [drone_count + runner_count + sentinel_count] Sisters</b> | Drones: [drone_count] | Runners: [runner_count] | Sentinels: [sentinel_count]<BR>"
	dat += "<b>Larvas: [larva_count] Sisters<BR>"
	dat += "<table cellspacing=4>"
	dat += queen_list + boiler_list + crusher_list + praetorian_list + ravager_list + carrier_list + hivelord_list + hunter_list + spitter_list + drone_list + runner_list + sentinel_list + larva_list
	dat += "</table></body>"
	usr << browse(dat, "window=roundstatus;size=500x500")


/mob/living/carbon/Xenomorph/verb/toggle_xeno_mobhud()
	set name = "Toggle Xeno Status HUD"
	set desc = "Toggles the health and plasma hud appearing above Xenomorphs."
	set category = "Alien"

	xeno_mobhud = !xeno_mobhud
	var/datum/mob_hud/H = huds[MOB_HUD_XENO_STATUS]
	if(xeno_mobhud)
		H.add_hud_to(usr)
	else
		H.remove_hud_from(usr)



