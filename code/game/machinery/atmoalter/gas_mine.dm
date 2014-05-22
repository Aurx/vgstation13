/obj/machinery/networked/atmos/miner
	name = "gas miner"
	desc = "Gasses mined from the gas giant below (above?) flow out through this massive vent."
	icon = 'icons/obj/atmospherics/miner.dmi'
	icon_state = "miner"
	power_channel=ENVIRON

	m_amt=10*CC_PER_SHEET_METAL
	w_type = RECYK_METAL

	var/datum/gas_mixture/air_contents

	var/on=1

	var/max_external_pressure=10000 // 10,000kPa ought to do it.
	var/internal_pressure=4500 // Bottleneck

	var/light_color = "#FFFFFF"

/obj/machinery/networked/atmos/miner/New()
	..()
	air_contents = new
	air_contents.volume=1000
	air_contents.temperature = T20C
	AddAir()
	air_contents.update_values()
	update_icon()

// Critical equipment.
/obj/machinery/networked/atmos/miner/ex_act(severity)
	return

// Critical equipment.
/obj/machinery/networked/atmos/miner/blob_act()
	return

/obj/machinery/networked/atmos/miner/power_change()
	..()
	update_icon()

/obj/machinery/networked/atmos/miner/attack_ghost(var/mob/user)
	return

/obj/machinery/networked/atmos/miner/attack_hand(var/mob/user)
	..()
	on=!on
	update_icon()

/obj/machinery/networked/atmos/miner/attack_ai(var/mob/user)
	..()
	on=!on
	update_icon()

// Add air here.  DO NOT CALL UPDATE_VALUES OR UPDATE_ICON.
/obj/machinery/networked/atmos/miner/proc/AddAir()
	return

/obj/machinery/networked/atmos/miner/update_icon()
	src.overlays = 0
	if(stat & NOPOWER)
		return
	if(on)
		var/new_icon_state="on"
		var/new_color = light_color
		if(stat & BROKEN)
			new_icon_state="broken"
			new_color="#FF0000"
		var/image/I = image(icon, icon_state=new_icon_state, dir=src.dir)
		I.color=new_color
		overlays += I

/obj/machinery/networked/atmos/miner/process()
	if(stat & NOPOWER)
		return
	if (!on)
		return

	var/oldstat=stat
	if(!istype(loc,/turf/simulated))
		stat |= BROKEN
	else
		stat &= ~BROKEN
	if(stat!=oldstat)
		update_icon()
	if(stat & BROKEN)
		return

	var/datum/gas_mixture/environment = loc.return_air()
	var/environment_pressure = environment.return_pressure()

	var/datum/gas_mixture/pumped = new
	pumped.copy_from(air_contents)

	var/pressure_delta = 10000

	pressure_delta = min(pressure_delta, (internal_pressure - environment_pressure))

	if(pressure_delta > 0.1)
		var/transfer_moles = pressure_delta*environment.volume/(pumped.temperature * R_IDEAL_GAS_EQUATION)

		var/datum/gas_mixture/removed = pumped.remove(transfer_moles)

		loc.assume_air(removed)

/obj/machinery/networked/atmos/miner/sleeping_agent
	name = "\improper N2O Gas Miner"
	light_color = "#FFCCCC"

	AddAir()
		var/datum/gas/sleeping_agent/trace_gas = new
		air_contents.trace_gases += trace_gas
		trace_gas.moles = internal_pressure*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)

/obj/machinery/networked/atmos/miner/nitrogen
	name = "\improper N2 Gas Miner"
	light_color = "#CCFFCC"

	AddAir()
		air_contents.nitrogen = internal_pressure*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)

/obj/machinery/networked/atmos/miner/oxygen
	name = "\improper O2 Gas Miner"
	light_color = "#007FFF"

	AddAir()
		air_contents.oxygen = internal_pressure*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)

/obj/machinery/networked/atmos/miner/toxins
	name = "\improper Plasma Gas Miner"
	light_color = "#FF0000"

	AddAir()
		air_contents.toxins = internal_pressure*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)

/obj/machinery/networked/atmos/miner/carbon_dioxide
	name = "\improper CO2 Gas Miner"
	light_color = "#CDCDCD"

	AddAir()
		air_contents.carbon_dioxide = internal_pressure*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)


/obj/machinery/networked/atmos/miner/air
	name = "\improper Air Miner"
	desc = "You fucking cheater."
	light_color = "#70DBDB"

	on = 0

	AddAir()
		air_contents.carbon_dioxide = internal_pressure*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)