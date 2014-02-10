///////////////////////////////////
// Antag Datum
///////////////////////////////////
/antag_role/group/vox_raider
	name="Vox Raider"
	id="raider"
	flags = 0
	disallow_job = 1
	special_role = "Vox Raider"

	be_flag = BE_RAIDER

	min_players = 4
	max_players = 6

	// GROUP
	var/index=1
	var/list/turf/spawnpoints = list()

	var/obj/item/weapon/implant/cortical/cortical_stack

/antag_role/group/vox_raider/calculateRoleNumbers()
	return

/antag_role/group/vox_raider/OnPostSetup()
	Equip()
	update_cult_icons_added(antag)
	return 1

/antag_role/group/vox_raider/Drop()
	..()
	antag.current << "Your link to the Shoal has been severed."
	log_admin("[antag.current] ([ckey(antag.current.key)] has been de-linked from the Shoal. (Non-antag vox ahoy)")

/antag_role/group/vox_raider/proc/GetNumAlive()
	var/num_alive=0
	var/check_return = 0
	if(ticker && istype(ticker.mode,/datum/game_mode/heist))
		check_return = 1
	for(var/datum/mind/vox in group.minds)
		var/antag_role/group/vox_raider/raider=vox.antag_roles["raider"]
		if(!vox.current)
			continue
		if(vox.current.stat == DEAD)
			continue
		if(check_return)
			if(get_area(raider.cortical_stack) != locate(/area/shuttle/vox/station))
				continue
		num_alive++
	return num_alive

/antag_role/group/vox_raider/proc/GetNumLeftBehind()
	var/count=0
	for(var/datum/mind/vox in group.minds)
		var/antag_role/group/vox_raider/raider=vox.antag_roles["raider"]
		if(get_area(raider.cortical_stack) != locate(/area/shuttle/vox/station))
			count++
	return count
/antag_role/group/vox_raider/ForgeGroupObjectives()
	//Build a list of spawn points.
	for(var/obj/effect/landmark/L in landmarks_list)
		if(L.name == "voxstart")
			spawnpoints += get_turf(L)
			del(L)
			continue

	//Commented out for testing.
	/* var/i = 1
	var/max_objectives = pick(2,2,2,3,3)
	var/list/objs = list()
	while(i<= max_objectives)
		var/list/goals = list("kidnap","loot","salvage")
		var/goal = pick(goals)
		var/datum/objective/heist/O

		if(goal == "kidnap")
			goals -= "kidnap"
			O = new /datum/objective/heist/kidnap()
		else if(goal == "loot")
			O = new /datum/objective/heist/loot()
		else
			O = new /datum/objective/heist/salvage()
		O.choose_target()
		objs += O

		i++

	//-All- vox raids have these two objectives. Failing them loses the game.
	objs += new /datum/objective/heist/inviolate_crew
	objs += new /datum/objective/heist/inviolate_death */

	if(prob(25))
		objectives += new /datum/group_objective/targetted/heist/kidnap(src)
	objectives += new /datum/group_objective/heist/loot(src)
	objectives += new /datum/group_objective/heist/salvage(src)
	objectives += new /datum/group_objective/heist/inviolate_crew(src)
	objectives += new /datum/group_objective/heist/inviolate_death(src)


/antag_role/group/vox_raider/proc/Equip(var/from_editmemory=0)

	var/mob/living/carbon/human/vox = antag.current
	if(!from_editmemory)
		antag.current.loc = group:spawnpoints[group:index++]

		var/sounds = rand(2,8)
		var/i = 0
		var/newname = ""

		while(i<=sounds)
			i++
			newname += pick(list("ti","hi","ki","ya","ta","ha","ka","ya","chi","cha","kah"))

		vox.real_name = capitalize(newname)
		vox.name = vox.real_name
		antag.name = vox.name
	vox.age = rand(12,20)
	vox.dna.mutantrace = "vox"
	vox.set_species("Vox")
	vox.languages = list() // Removing language from chargen.
	vox.flavor_text = ""
	vox.add_language("Vox-pidgin")
	vox.h_style = "Short Vox Quills"
	vox.f_style = "Shaved"
	for(var/datum/organ/external/limb in vox.organs)
		limb.status &= ~(ORGAN_DESTROYED | ORGAN_ROBOT)
	vox.equip_vox_raider()

	cortical_stack = new(vox)
	cortical_stack.imp_in = src
	cortical_stack.implanted = 1
	var/datum/organ/external/affected = vox.get_organ("head")
	affected.implants += cortical_stack

	vox.regenerate_icons()

/antag_role/group/vox_raider/Greet(you_are=1)
	antag.current << {"\blue <B>You are a Vox Raider, fresh from the Shoal!</b>
The Vox are a race of cunning, sharp-eyed nomadic raiders and traders endemic to Tau Ceti and much of the unexplored galaxy. You and the crew have come to the Exodus for plunder, trade or both.
Vox are cowardly and will flee from larger groups, but corner one or find them en masse and they are vicious.
Use :V to voxtalk, :H to talk on your encrypted channel, and <b>don't forget to turn on your nitrogen internals!</b>"}

	MemorizeObjectives()

	Equip()


/antag_role/group/vox_raider/DeclareAll()
	var/text = ""
	if(objectives.len)
		text += "<br /><b>The vox raiders' objectives were:</b>"
		for(var/obj_count=1, obj_count <= objectives.len, obj_count++)
			var/datum/group_objective/objective = objectives[obj_count]
			text += "<br /><b>Objective #[obj_count]:</b> [objective.declare()]"

	text += "<br /><FONT size = 2><B>The raiders were:</B></FONT>"
	for(var/datum/mind/mind in minds)
		var/antag_role/R=mind.antag_roles[id]
		R.Declare()

/antag_role/group/vox_raider/Declare()
	var/text= "<br>[antag.key] was [antag.name] ("
	if(antag.current)
		if (get_area(cortical_stack) != locate(/area/shuttle/vox/station))
			text += "left behind"
		else if(antag.current.stat == DEAD)
			text += "died"
		else
			text += "survived"
		if(antag.current.real_name != antag.name)
			text += " as [antag.current.real_name]"
	else
		text += "body destroyed"
	text += ")"

	world << text

/antag_role/group/vox_raider/EditMemory(var/datum/mind/M)
	var/text="[name]"
	if (ticker.mode.config_tag=="cult")
		text = uppertext(text)
	text = "<i><b>[text]</b></i>: "
	if (M.assigned_role in command_positions)
		text += "<b>HEAD</b>|officer|employee|cultist"
	else if (M.assigned_role in list("Security Officer", "Detective", "Warden"))
		text += "head|<b>OFFICER</b>|employee|cultist"
	else if (M.antag_roles["cultist"])
		text += {"head|officer|<a href='?src=\ref[src];remove_role=cultist'>employee</a>|<b>CULTIST</b>
<ul>
	<li>Give <a href='?src=\ref[src];mind=\ref[M];give=tome'>tome</a></li>
	<li>Give <a href='?src=\ref[src];mind=\ref[M];give=amulet'>amulet</a></li>
</ul>"}
	else
		text += "head|officer|<b>EMPLOYEE</b>|<a href='?src=\ref[src];assign_role=cultist'>cultist</a>"

/antag_role/group/vox_raider/RoleTopic(href, href_list, var/datum/mind/M)
	if("give" in href_list)
		switch(href_list["give"])
			if("gear")
				var/antag_role/group/vox_raider/raider = M.antag_roles["cultist"]
				if (!raider.Equip(1))
					usr << "\red Spawning amulet failed!"