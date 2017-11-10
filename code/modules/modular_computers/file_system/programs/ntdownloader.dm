/datum/computer_file/program/exonetdownload
	filename = "ntndownloader"
	filedesc = "Software Download Tool"
	program_icon_state = "generic"
	extended_desc = "This program allows downloads of software from official NT repositories"
	unsendable = 1
	undeletable = 1
	size = 4
	requires_exonet = 1
	requires_exonet_feature = exonet_SOFTWAREDOWNLOAD
	available_on_exonet = 0
	ui_header = "downloader_finished.gif"
	tgui_id = "ntos_net_downloader"

	var/datum/computer_file/program/downloaded_file = null
	var/hacked_download = 0
	var/download_completion = 0 //GQ of downloaded data.
	var/download_netspeed = 0
	var/downloaderror = ""
	var/obj/item/device/modular_computer/my_computer = null

/datum/computer_file/program/exonetdownload/proc/begin_file_download(filename)
	if(downloaded_file)
		return 0

	var/datum/computer_file/program/PRG = GLOB.exonet_global.find_exonet_file_by_name(filename)

	if(!PRG || !istype(PRG))
		return 0

	// Attempting to download antag only program, but without having emagged computer. No.
	if(PRG.available_on_syndinet && !computer.emagged)
		return 0

	var/obj/item/computer_hardware/hard_drive/hard_drive = computer.all_components[MC_HDD]

	if(!computer || !hard_drive || !hard_drive.can_store_file(PRG))
		return 0

	ui_header = "downloader_running.gif"

	if(PRG in GLOB.exonet_global.available_station_software)
		generate_network_log("Began downloading file [PRG.filename].[PRG.filetype] from exonet Software Repository.")
		hacked_download = 0
	else if(PRG in GLOB.exonet_global.available_antag_software)
		generate_network_log("Began downloading file **ENCRYPTED**.[PRG.filetype] from unspecified server.")
		hacked_download = 1
	else
		generate_network_log("Began downloading file [PRG.filename].[PRG.filetype] from unspecified server.")
		hacked_download = 0

	downloaded_file = PRG.clone()

/datum/computer_file/program/exonetdownload/proc/abort_file_download()
	if(!downloaded_file)
		return
	generate_network_log("Aborted download of file [hacked_download ? "**ENCRYPTED**" : "[downloaded_file.filename].[downloaded_file.filetype]"].")
	downloaded_file = null
	download_completion = 0
	ui_header = "downloader_finished.gif"

/datum/computer_file/program/exonetdownload/proc/complete_file_download()
	if(!downloaded_file)
		return
	generate_network_log("Completed download of file [hacked_download ? "**ENCRYPTED**" : "[downloaded_file.filename].[downloaded_file.filetype]"].")
	var/obj/item/computer_hardware/hard_drive/hard_drive = computer.all_components[MC_HDD]
	if(!computer || !hard_drive || !hard_drive.store_file(downloaded_file))
		// The download failed
		downloaderror = "I/O ERROR - Unable to save file. Check whether you have enough free space on your hard drive and whether your hard drive is properly connected. If the issue persists contact your system administrator for assistance."
	downloaded_file = null
	download_completion = 0
	ui_header = "downloader_finished.gif"

/datum/computer_file/program/exonetdownload/process_tick()
	if(!downloaded_file)
		return
	if(download_completion >= downloaded_file.size)
		complete_file_download()
	// Download speed according to connectivity state. exonet server is assumed to be on unlimited speed so we're limited by our local connectivity
	download_netspeed = 0
	// Speed defines are found in misc.dm
	switch(exonet_status)
		if(1)
			download_netspeed = exonetSPEED_LOWSIGNAL
		if(2)
			download_netspeed = exonetSPEED_HIGHSIGNAL
		if(3)
			download_netspeed = exonetSPEED_ETHERNET
	download_completion += download_netspeed

/datum/computer_file/program/exonetdownload/ui_act(action, params)
	if(..())
		return 1
	switch(action)
		if("PRG_downloadfile")
			if(!downloaded_file)
				begin_file_download(params["filename"])
			return 1
		if("PRG_reseterror")
			if(downloaderror)
				download_completion = 0
				download_netspeed = 0
				downloaded_file = null
				downloaderror = ""
			return 1
	return 0

/datum/computer_file/program/exonetdownload/ui_data(mob/user)
	my_computer = computer

	if(!istype(my_computer))
		return

	var/list/data = get_header_data()

	// This IF cuts on data transferred to client, so i guess it's worth it.
	if(downloaderror) // Download errored. Wait until user resets the program.
		data["error"] = downloaderror
	else if(downloaded_file) // Download running. Wait please..
		data["downloadname"] = downloaded_file.filename
		data["downloaddesc"] = downloaded_file.filedesc
		data["downloadsize"] = downloaded_file.size
		data["downloadspeed"] = download_netspeed
		data["downloadcompletion"] = round(download_completion, 0.1)
	else // No download running, pick file.
		var/obj/item/computer_hardware/hard_drive/hard_drive = my_computer.all_components[MC_HDD]
		data["disk_size"] = hard_drive.max_capacity
		data["disk_used"] = hard_drive.used_capacity
		var/list/all_entries[0]
		for(var/A in GLOB.exonet_global.available_station_software)
			var/datum/computer_file/program/P = A
			// Only those programs our user can run will show in the list
			if(!P.can_run(user,transfer = 1) || hard_drive.find_file_by_name(P.filename))
				continue
			all_entries.Add(list(list(
			"filename" = P.filename,
			"filedesc" = P.filedesc,
			"fileinfo" = P.extended_desc,
			"compatibility" = check_compatibility(P),
			"size" = P.size
			)))
		data["hackedavailable"] = 0
		if(computer.emagged) // If we are running on emagged computer we have access to some "bonus" software
			var/list/hacked_programs[0]
			for(var/S in GLOB.exonet_global.available_antag_software)
				var/datum/computer_file/program/P = S
				if(hard_drive.find_file_by_name(P.filename))
					continue
				data["hackedavailable"] = 1
				hacked_programs.Add(list(list(
				"filename" = P.filename,
				"filedesc" = P.filedesc,
				"fileinfo" = P.extended_desc,
				"size" = P.size
				)))
			data["hacked_programs"] = hacked_programs

		data["downloadable_programs"] = all_entries

	return data

/datum/computer_file/program/exonetdownload/proc/check_compatibility(datum/computer_file/program/P)
	var/hardflag = computer.hardware_flag

	if(P && P.is_supported_by_hardware(hardflag,0))
		return "Compatible"
	return "Incompatible!"

/datum/computer_file/program/exonetdownload/kill_program(forced)
	abort_file_download()
	return ..(forced)