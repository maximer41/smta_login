--[[
			AUTOR: xMaximerr <xmaximerr.programmer@vp.pl>
			GAMEMODE: SouthMTA <southmta.pl>
			Nie masz prawa używać tego kodu bez mojej zgody!
--]]


local sW,sH=guiGetScreenSize()
local myScreenSource=dxCreateScreenSource(sW, sH)

local guis={}
local funcs={
	cameraTimer=nil,
	cams={
		{2107.4772949219, -1813.9256591797, 111.87640380859, 2106.6604003906, -1813.4007568359, 111.63723754883},
		{2659.9587402344, -983.78662109375, 153.82440185547, 2659.3950195313, -984.57855224609, 153.58952331543},
		{1866.2662353516, -1250.1274414063, 36.552398681641, 1867.1387939453, -1249.6627197266, 36.40177154541},
		{1542.9927978516, -1734.1137695313, 30.229000091553, 1542.3175048828, -1733.4067382813, 30.018852233887},
		{1348.5921630859, -911.85089111328, 72.795303344727, 1349.2884521484, -911.13623046875, 72.72827911377},
		{1111.7535400391, -1647.607421875, 103.02819824219, 1110.8531494141, -1647.9403076172, 102.74813079834}
	},
}

function setCameraMode(state)
	if state=="on" then
		local random=math.random(1,#funcs.cams)
		setCameraMatrix(funcs.cams[random][1], funcs.cams[random][2], funcs.cams[random][3], funcs.cams[random][4], funcs.cams[random][5], funcs.cams[random][6])
		funcs.cameraTimer = setTimer(setCameraMode,1000*15,0,"change")

		sound = playSound("files/intro.mp3", true)
		setSoundVolume(sound, 1.0)

	elseif state=="change" then
		fadeCamera(false, 0.5)

		setTimer(function()
			local random=math.random(1,#funcs.cams)
			setCameraMatrix(funcs.cams[random][1], funcs.cams[random][2], funcs.cams[random][3], funcs.cams[random][4], funcs.cams[random][5], funcs.cams[random][6])
			fadeCamera(true, 0.5)
		end, 1000, 1)

	elseif state=="off" then
		killTimer(funcs.cameraTimer)

	elseif state=="stop music" then
		stopSound(sound)
	end
end

local function logIn()
	if guiGetEnabled(guis.login_gui) then
		if guiCheckBoxGetSelected(guis.remember) then
			if not fileExists("@:smta_login/login_data.xml") then
				local xml = xmlCreateFile("@:smta_login/login_data.xml", "login_data")
				local node = xmlCreateChild(xml, "account")
				xmlNodeSetAttribute(node, "login", exports.smta_editboxes:getEditboxText(guis.login_edit))
				xmlNodeSetAttribute(node, "pass", exports.smta_editboxes:getEditboxText(guis.pass_edit))
				xmlSaveFile(xml)
				xmlUnloadFile(xml)
			else
				local xml = xmlLoadFile("@:smta_login/login_data.xml")
				local node = xmlFindChild(xml, "account", 0)
				xmlDestroyNode(node)

				local new_node = xmlCreateChild(xml, "account")
				xmlNodeSetAttribute(new_node, "login", exports.smta_editboxes:getEditboxText(guis.login_edit))
				xmlNodeSetAttribute(new_node, "pass", exports.smta_editboxes:getEditboxText(guis.pass_edit))
				xmlSaveFile(xml)
				xmlUnloadFile(xml)
			end
		else
			if fileExists("@:smta_login/login_data.xml") then
				fileDelete("@:smta_login/login_data.xml")
			end
		end

		guiSetEnabled(guis.login_gui,false)
		triggerServerEvent("l_tryLogin", localPlayer, exports.smta_editboxes:getEditboxText(guis.login_edit), exports.smta_editboxes:getEditboxText(guis.pass_edit))
	end
end

addEventHandler("onClientResourceStart",getResourceRootElement(getThisResource()),function()
	if not getElementData(localPlayer,"k:data") then
		guis.login_gui = guiCreateStaticImage((sW-700)/2, (sH-429)/2, 700, 429, "files/login.png", false)

		guis.features = guiCreateLabel(470, 139, 216, 298, "20/03/2020: Wprowadzenie oficjalnej wersji Alpha.\n14/04/2020: Dodanie postaci do profilów na forum.", false, guis.login_gui)
		guiLabelSetHorizontalAlign(guis.features, "left", true)
		guis.remember = guiCreateCheckBox(294, 297, 168, 25, "Pamiętaj dane logowania", false, false, guis.login_gui)
		guis.login_button = guiCreateButton(300, 261, 148, 36, "", false, guis.login_gui)
		guiSetAlpha(guis.login_button, 0.00)
		guis.login_edit=exports.smta_editboxes:createEditbox({(sW-580)/2, (sH+58)/2, 243, 23, "", false, 35})
		guis.pass_edit=exports.smta_editboxes:createEditbox({(sW-580)/2, (sH+158)/2, 228, 23, "", true, 20})

		addEventHandler("onClientGUIClick",guis.login_button,logIn,false)

		bindKey("enter", "down", logIn)

		setCameraMode("on")
		exports.smta_blur:setBlur(0)
		fadeCamera(true)
		showCursor(true)
		setPlayerHudComponentVisible("all", false)
		showChat(false)
		setFarClipDistance(1500)

		if fileExists("@:smta_login/login_data.xml") then
			local xml = xmlLoadFile("@:smta_login/login_data.xml")
			local x = xmlNodeGetChildren(xml)
			for _,v in ipairs(x) do
				local attributes = xmlNodeGetAttributes(v)
				exports.smta_editboxes:setEditboxText(guis.login_edit,attributes.login)
				exports.smta_editboxes:setEditboxText(guis.pass_edit,attributes.pass)
			end

			guiCheckBoxSetSelected(guis.remember,true)
		end

		if sW<1024 and sH<768 then
			exports.smta_notifications:showBox("Upss! Twoja rozdzielczość ekranu jest bardzo mała, mogą wystąpić problemy z elementami graficznymi serwisu.")
		end
	end
end)

addEvent("l_hide", true)
addEventHandler("l_hide", localPlayer, function()
	destroyElement(guis.login_gui)

	exports.smta_editboxes:destroyEditbox(guis.login_edit)
	exports.smta_editboxes:destroyEditbox(guis.pass_edit)

	showCursor(false)
	unbindKey("enter", "down", logIn)
	
	setCameraMode("off")
	
	exports.smta_blur:removeBlur()

	setPlayerHudComponentVisible("crosshair", true)
end)

addEvent("l_setEnabled", true)
addEventHandler("l_setEnabled", localPlayer, function(type)
	if isElement(guis.login_gui) then
		guiSetEnabled(guis.login_gui,type)
	end
end)