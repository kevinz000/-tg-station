
SUBSYSTEM_DEF(research)
	name = "Research"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_RESEARCH
	var/list/invalid_design_ids = list()		//associative id = number of times
	var/list/invalid_node_ids = list()			//associative id = number of times
	var/list/invalid_node_boost = list()		//associative id = error message
	var/list/obj/machinery/rnd/server/servers = list()
	var/datum/techweb/science/science_tech
	var/datum/techweb/admin/admin_tech
	var/list/techweb_nodes = list()				//associative id = node datum
	var/list/techweb_categories = list()		//category name = list(node.id = node)
	var/list/techweb_designs = list()			//associative id = node datum
	var/list/techweb_nodes_starting = list()	//associative id = node datum
	var/list/techweb_boost_items = list()		//associative double-layer path = list(node = point_discount)
	var/list/techweb_nodes_hidden = list()		//Nodes that should be hidden by default.
	var/single_server_income = 50
	var/multiserver_calculation = FALSE
	//20 wait = 2 seconds per tick
	//50 points per tick, 30 ticks per minute
	//Assuming avg round time is 50 minutes
	//30 * 50 * 50 = 75000 points in average round
	//Aiming for 1.5 hours to max R&D
	//1.5 hours = 90 minutes, 30 * 50 * 90 = 135000 points to max R&D.

/datum/controller/subsystem/research/Initialize()
	initialize_all_techweb_designs()
	initialize_all_techweb_nodes()
	science_tech = new /datum/techweb/science
	admin_tech = new /datum/techweb/admin
	autosort_categories()
	return ..()

/datum/controller/subsystem/research/process()
	handle_research_income()

/datum/controller/subsystem/research/proc/handle_research_income()
	var/bitcoins = 0
	if(multiserver_calculation)
		var/eff = calculate_server_coefficient()
		for(var/obj/machinery/rnd/server/miner in servers)
			bitcoins += (miner.mine() * eff)	//SLAVE AWAY, SLAVE.
	else
		for(var/obj/machinery/rnd/server/miner in servers)
			if(miner.working)
				bitcoins = single_server_income
				break			//Just need one to work.
	science_tech.research_points += bitcoins

/datum/controller/subsystem/research/proc/calculate_server_coefficient()	//Diminishing returns.
	var/amt = servers.len
	var/coeff = 100
	coeff = sqrt(coeff / amt)
	return coeff

/datum/controller/subsystem/research/proc/autosort_categories()
	for(var/i in techweb_nodes)
		var/datum/techweb_node/I = techweb_nodes[i]
		if(techweb_categories[I.category])
			techweb_categories[I.category][I.id] = I
		else
			techweb_categories[I.category] = list(I.id = I)
