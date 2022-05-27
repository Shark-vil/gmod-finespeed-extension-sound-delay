local function init_lang()
	language.Add(
		'ext.finespeed.enable',
		'Sound Delay'
	)

	language.Add(
		'ext.finespeed.enable.help',
		'Adds a delay between footstep sounds if the speed is different from the standard. This is a global setting and turning it off will disable it for all players.'
	)
end

local function init_menu(panel)
	panel:AddControl('CheckBox', {
		['Label'] = '#ext.finespeed.enable',
		['Command'] = 'ext_finespeed_enable',
		['Help'] = true
	});
end

hook.Add('PopulateToolMenu', 'Ext.FineSpeed.Menu', function()
	init_lang()

	spawnmenu.AddToolMenuOption(
		'Options',
		'FineSpeed',
		'FineSpeed_Options_Ext',
		'Extension',
		'',
		'',
		init_menu
	)
end)