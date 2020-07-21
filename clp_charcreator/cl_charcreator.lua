local sexeSelect = 0
local teteSelect = 0
local colorPeauSelect = 0
local cheveuxSelect = 0
local bebarSelect = -1
local poilsCouleurSelect = 0
local ImperfectionsPeau = 0
local face, acne, skin, eyecolor, skinproblem, freckle, wrinkle, hair, haircolor, eyebrow, beard, beardcolor
local camfin = false

PMenu = {}
PMenu.Data = {}

local playerPed = PlayerPedId()
local incamera = false
local board_scaleform
local handle
local board
local board_model = GetHashKey("prop_police_id_board")
local board_pos = vector3(0.0,0.0,0.0)
local overlay
local overlay_model = GetHashKey("prop_police_id_text")
local isinintroduction = false
local pressedenter = false
local introstep = 0
local timer = 0
local inputgroups = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31}
local enanimcinematique = false
local guiEnabled = false

local sound = false

Citizen.CreateThread(function()
	while true do
        if guiEnabled then
            print("^3Clippy save")
            TriggerEvent('es:setMoneyDisplay', 0.0)
            TriggerEvent('esx_status:setDisplay', 0.0)
            DisplayRadar(false)
            TriggerEvent('ui:toggle', false)
			DisableControlAction(0, 1,   true) -- LookLeftRight
			DisableControlAction(0, 2,   true) -- LookUpDown
			DisableControlAction(0, 106, true) -- VehicleMouseControlOverride
			DisableControlAction(0, 142, true) -- MeleeAttackAlternate
			DisableControlAction(0, 30,  true) -- MoveLeftRight
			DisableControlAction(0, 31,  true) -- MoveUpDown
			DisableControlAction(0, 21,  true) -- disable sprint
			DisableControlAction(0, 24,  true) -- disable attack
			DisableControlAction(0, 25,  true) -- disable aim
			DisableControlAction(0, 47,  true) -- disable weapon
			DisableControlAction(0, 58,  true) -- disable weapon
			DisableControlAction(0, 263, true) -- disable melee
			DisableControlAction(0, 264, true) -- disable melee
			DisableControlAction(0, 257, true) -- disable melee
			DisableControlAction(0, 140, true) -- disable melee
			DisableControlAction(0, 141, true) -- disable melee
			DisableControlAction(0, 143, true) -- disable melee
			DisableControlAction(0, 75,  true) -- disable exit vehicle
			DisableControlAction(27, 75, true) -- disable exit vehicle
		end
		Citizen.Wait(10)
	end
end)

function spawncinematiqueplayer()
    guiEnabled = true
    local playerPed = PlayerPedId()
    pressedenter = true
    local introcam
    TriggerEvent('chat:clear')
    TriggerEvent('chat:toggleChat')
    SetEntityVisible(playerPed, false, false)
    FreezeEntityPosition(GetPlayerPed(-1), true)
    SetFocusEntity(playerPed)
    Wait(1)
    SetOverrideWeather("EXTRASUNNY")
    NetworkOverrideClockTime(19, 0, 0)
    BeginSrl()
    introstep = 1
    isinintroduction = true
    Wait(1)
    DoScreenFadeIn(500)
    if introstep == 1 then
        introcam = CreateCam("DEFAULT_SCRIPTED_CAMERA", false)
        SetCamActive(introcam, true)
        SetFocusArea(754.2219, 1226.831, 356.5081, 0.0, 0.0, 0.0)
        SetFocusArea(-57.43, -1012.55, 56.26, 0.0, 0.0, 0.0)
        SetCamParams(introcam, 754.2219, 1226.831, 356.5081, -14.367, 0.0, 157.3524, 42.2442, 0, 1, 1, 2)
        SetCamParams(introcam, -57.43, -1012.55, 56.26, -9.6114, 0.0, 157.8659, 44.8314, 120000, 0, 0, 2)
        ShakeCam(introcam, "HAND_SHAKE", 0.50)
        RenderScriptCams(true, false, 3000, 1, 1)
        return
    end
end

Citizen.CreateThread(function()
    while true do 
        Wait(0)
        local playerPed = PlayerPedId()

        if pressedenter then 
            print("^3Clippy save")
            ESX.DrawMissionText("Appuyez sur ~g~ENTER ~s~pour valider votre entrée.", 500)
            if IsControlJustPressed(1, 191) then 
                ESX.ShowNotification("~g~Vous avez validé votre entrée.")
                ESX.ShowNotification("~g~Vous avez été replacé à votre ancienne position.")
                ESX.ShowNotification("~g~Connexion au vocal réussie.")
                destorycam()
                spawncinematiqueplayer(false)
                DoScreenFadeOut(0)
                enanimcinematique = false
                pressedenter = false
                guiEnabled = false
                isinintroduction = false
                TriggerEvent("playerSpawned")
                SetEntityVisible(playerPed, true, false)
                FreezeEntityPosition(GetPlayerPed(-1), false)
                DestroyCam(createdCamera, 0)
                DestroyCam(createdCamera, 0)
                RenderScriptCams(0, 0, 1, 1, 1)
                createdCamera = 0
                ClearTimecycleModifier("scanline_cam_cheap")
                SetFocusEntity(GetPlayerPed(PlayerId()))   
                DoScreenFadeIn(1500)
                TriggerEvent('es:setMoneyDisplay', 1.0)
                TriggerEvent('esx_status:setDisplay', 1.0)
                DisplayRadar(true)
                TriggerEvent('ui:toggle', true)
            end
        end
    end
end)


local function LoadScaleform (scaleform)
	local handle = RequestScaleformMovie(scaleform)
	if handle ~= 0 then
		while not HasScaleformMovieLoaded(handle) do
			Citizen.Wait(0)
		end
	end
	return handle
end


local function CreateNamedRenderTargetForModel(name, model)
	local handle = 0
	if not IsNamedRendertargetRegistered(name) then
		RegisterNamedRendertarget(name, 0)
	end
	if not IsNamedRendertargetLinked(model) then
		LinkNamedRendertarget(model)
	end
	if IsNamedRendertargetRegistered(name) then
		handle = GetNamedRendertargetRenderId(name)
	end

	return handle
end

Citizen.CreateThread(function()
	board_scaleform = LoadScaleform("mugshot_board_01")
	handle = CreateNamedRenderTargetForModel("ID_Text", overlay_model)


	while handle do
		SetTextRenderId(handle)
		Set_2dLayer(4)
		Citizen.InvokeNative(0xC6372ECD45D73BCD, 1)
		DrawScaleformMovie(board_scaleform, 0.405, 0.37, 0.81, 0.74, 255, 255, 255, 255, 0)
		Citizen.InvokeNative(0xC6372ECD45D73BCD, 0)
		SetTextRenderId(GetDefaultScriptRendertargetRenderId())

		Citizen.InvokeNative(0xC6372ECD45D73BCD, 1)
		Citizen.InvokeNative(0xC6372ECD45D73BCD, 0)
		Wait(0)
	end
end)

local function CallScaleformMethod (scaleform, method, ...)
	local t
	local args = { ... }

	BeginScaleformMovieMethod(scaleform, method)

	for k, v in ipairs(args) do
		t = type(v)
		if t == 'string' then
			PushScaleformMovieMethodParameterString(v)
		elseif t == 'number' then
			if string.match(tostring(v), "%.") then
				PushScaleformMovieFunctionParameterFloat(v)
			else
				PushScaleformMovieFunctionParameterInt(v)
			end
		elseif t == 'boolean' then
			PushScaleformMovieMethodParameterBool(v)
		end
	end
	EndScaleformMovieMethod()
end


function KeyboardInput(inputText, maxLength) -- Thanks to Flatracer for the function.
    AddTextEntry('FMMC_KEY_TIP12', "")
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP12", "", inputText, "", "", "", maxLength)
    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
        Citizen.Wait(0)
    end
    if UpdateOnscreenKeyboard() ~= 2 then
        result = GetOnscreenKeyboardResult()
        Citizen.Wait(500)
        return result
    else
        Citizen.Wait(500)
        return nil
    end
end

function CreateBoard(ped)
    print("^3Clippy save")
    local plyData = ESX.GetPlayerData()
    RequestModel(board_model)
    while not HasModelLoaded(board_model) do Wait(0) end
    RequestModel(overlay_model)
    while not HasModelLoaded(overlay_model) do Wait(0) end
    board = CreateObject(board_model, GetEntityCoords(ped), false, true, false)
    overlay = CreateObject(overlay_model, GetEntityCoords(ped), false, true, false)
    AttachEntityToEntity(overlay, board, -1, 4103, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
    ClearPedWetness(ped)
    ClearPedBloodDamage(ped)
    ClearPlayerWantedLevel(PlayerId())
    SetCurrentPedWeapon(ped, GetHashKey("weapon_unarmed"), 1)
    AttachEntityToEntity(board, ped, GetPedBoneIndex(ped, 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0, 0, 0, 0, 2, 1)
    CallScaleformMethod(board_scaleform, 'SET_BOARD', plyData.job.label, GetPlayerName(PlayerId()), 'LOS SANTOS POLICE DEPT', '' , 0, 1, 116)
end

local FirstSpawn     = true
local LastSkin       = nil
local PlayerLoaded   = false

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	PlayerLoaded = true
end)

AddEventHandler('playerSpawned', function()
	Citizen.CreateThread(function()
		while not PlayerLoaded do
			Citizen.Wait(10)
		end
		if FirstSpawn then
			ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
				if skin == nil then
					TriggerEvent('clp_charact:create')
				else
                    TriggerEvent('skinchanger:loadSkin', skin)
                    TriggerEvent('topserveur:openme')
                    spawncinematiqueplayer()
				end
			end)
			FirstSpawn = false
		end
	end)
end)

function createcamvisage(default)
    DisplayRadar(false)
    TriggerEvent('esx_status:setDisplay', 0.0)
    RenderScriptCams(false, false, 0, 1, 0)
    DestroyCam(cam, false)
    if (not DoesCamExist(cam)) then
        if default then
            cam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', 410.72, -998.68, -98.3, 0.0, 0.0, 88.455696105957, 15.0, false, 0)
        else
            cam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', 410.72, -998.68, -98.3, 0.0, 0.0, 88.455696105957, 15.0, false, 0)
        end
        SetCamActive(cam, true)
        RenderScriptCams(true, false, 0, true, false)
    end
end

function createcamcinematique(default)
    DisplayRadar(false)
    TriggerEvent('esx_status:setDisplay', 0.0)
    RenderScriptCams(false, false, 0, 1, 0)
    DestroyCam(cam, false)
    if (not DoesCamExist(cam)) then
        if default then
            cam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', -490.69, -667.96, 47.43, -35.0, 0.0, 180.16, 40.0, false, 0)
        else
            cam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', -490.69, -667.96, 47.43, -35.0, 0.0, 180.16, 40.0, false, 0)
        end
        SetCamActive(cam, true)
        RenderScriptCams(true, false, 0, true, false)
    end
end


function createcamyeux(default)
    DisplayRadar(false)
    TriggerEvent('esx_status:setDisplay', 0.0)
    RenderScriptCams(false, false, 0, 1, 0)
    DestroyCam(cam, false)
    if (not DoesCamExist(cam)) then
        if default then
            cam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', 410.72, -998.68, -98.3, 0.0, 0.0, 88.455696105957, 10.0, false, 0)
        else
            cam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', 410.72, -998.68, -98.3, 0.0, 0.0, 88.455696105957, 10.0, false, 0)
        end
        SetCamActive(cam, true)
        RenderScriptCams(true, false, 0, true, false)
    end
end

function createcamtorse(default)
    DisplayRadar(false)
    TriggerEvent('esx_status:setDisplay', 0.0)
    RenderScriptCams(false, false, 0, 1, 0)
    DestroyCam(cam, false)
    if (not DoesCamExist(cam)) then
        if default then
            cam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', 410.72, -998.68, -98.3, 0.0, 0.0, 88.455696105957, 10.0, false, 0)
        else
            cam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', 410.72, -998.68, -98.3, 0.0, 0.0, 88.455696105957, 10.0, false, 0)
        end
        SetCamActive(cam, true)
        RenderScriptCams(true, false, 0, true, false)
    end
end


function createcam(default)
    DisplayRadar(false)
    TriggerEvent('esx_status:setDisplay', 0.0)
    RenderScriptCams(false, false, 0, 1, 0)
    DestroyCam(cam, false)
    if (not DoesCamExist(cam)) then
        if default then
            cam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', 410.2, -998.60, -98.5, -18.0, 0.0, 89.60, 70.0, false, 0)
        else
            cam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', 410.2, -998.60, -98.5, -18.0, 0.0, 89.60, 70.0, false, 0)
        end
        SetCamActive(cam, true)
        RenderScriptCams(true, false, 0, true, false)
    end
end

function createcamfin(default)
    DisplayRadar(false)
    TriggerEvent('esx_status:setDisplay', 0.0)
    RenderScriptCams(false, false, 0, 1, 0)
    DestroyCam(cam, false)
    if (not DoesCamExist(cam)) then
        if default then
            cam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', 414.64, -998.16, -98.68, 0.0, 0.0, 88.455696105957, 60.0, false, 0)
        else
            cam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', 414.64, -998.16, -98.68, 0.0, 0.0, 88.455696105957, 60.0, false, 0)
        end
        SetCamActive(cam, true)
        RenderScriptCams(true, false, 0, true, false)
    end
end

function createcamjambe(default)
    DisplayRadar(false)
    TriggerEvent('esx_status:setDisplay', 0.0)
    RenderScriptCams(false, false, 0, 1, 0)
    DestroyCam(cam, false)
    if (not DoesCamExist(cam)) then
        if default then
            cam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', 410.2, -998.60, -98.9, -18.0, 0.0, 89.60, 50.0, false, 0)
        else
            cam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', 410.2, -998.60, -98.9, -18.0, 0.0, 89.60, 50.0, false, 0)
        end
        SetCamActive(cam, true)
        RenderScriptCams(true, false, 0, true, false)
    end
end

function createcamchaussure(default)
    DisplayRadar(false)
    TriggerEvent('esx_status:setDisplay', 0.0)
    RenderScriptCams(false, false, 0, 1, 0)
    DestroyCam(cam, false)
    if (not DoesCamExist(cam)) then
        if default then
            cam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', 410.2, -998.60, -99.1, -21.0, 0.0, 89.60, 50.0, false, 0)
        else
            cam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', 410.2, -998.60, -99.1, -21.0, 0.0, 89.60, 50.0, false, 0)
        end
        SetCamActive(cam, true)
        RenderScriptCams(true, false, 0, true, false)
    end
end

function createcamtorse(default)
    DisplayRadar(false)
    TriggerEvent('esx_status:setDisplay', 0.0)
    RenderScriptCams(false, false, 0, 1, 0)
    DestroyCam(cam, false)
    if (not DoesCamExist(cam)) then
        if default then
            cam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', 410.72, -998.68, -98.75, 0.0, 0.0, 88.455696105957, 27.0, false, 0)
        else
            cam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', 410.72, -998.68, -98.75, 0.0, 0.0, 88.455696105957, 27.0, false, 0)
        end
        SetCamActive(cam, true)
        RenderScriptCams(true, false, 0, true, false)
    end
end

function CreateCamEnter()
    cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", 415.55, -998.50, -99.29, 0.00, 0.00, 89.75, 50.00, false, 0)
    SetCamActive(cam, true)
    RenderScriptCams(true, false, 2000, true, true) 
end

function SpawnCharacter()
    cam2 = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", 411.30, -998.62, -99.01, 0.00, 0.00, 89.75, 50.00, false, 0)
    PointCamAtCoord(cam2, 411.30, -998.62, -99.01)
    SetCamActiveWithInterp(cam2, cam, 5000, true, true)
end

function destorycam()
    RenderScriptCams(false, false, 0, 1, 0)
    DestroyCam(cam, false)
    TriggerServerEvent('barbershop:removeposition')
end


function openCinematique()
    print("^3Clippy save")
	hasCinematic = not hasCinematic
	if not hasCinematic then
        SendNUIMessage({openCinema = false})
        TriggerEvent('es:setMoneyDisplay', 1.0)
        TriggerEvent('esx_status:setDisplay', 1.0)
        DisplayRadar(true)
        TriggerEvent('ui:toggle', true)
	elseif hasCinematic then
		SendNUIMessage({openCinema = true})
		TriggerEvent('es:setMoneyDisplay', 0.0)
		TriggerEvent('esx_status:setDisplay', 0.0)
		DisplayRadar(false)
		TriggerEvent('ui:toggle', false)
	end
end

RegisterNetEvent('clp_character:SpawnCharacter')
AddEventHandler('clp_character:SpawnCharacter', function(spawn)
    print("^3Clippy save")
    SetRunSprintMultiplierForPlayer(PlayerId(),1.49)
    openCinematique()
    SetOverrideWeather("EXTRASUNNY")
    SetWeatherTypePersist("EXTRASUNNY")
    NetworkOverrideClockTime(16, 0, 0)
    PlaySoundFrontend(-1, "CHARACTER_SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0)
    TriggerServerEvent('SavellPlayer')
    RenderScriptCams(0, 0, 1, 1, 1)
    ClearTimecycleModifier("scanline_cam_cheap")
    SetFocusEntity(GetPlayerPed(PlayerId()))
    DoScreenFadeOut(0)
    SetEntityCoords(PlayerPedId(), -491.0, -737.32, 23.92-0.98)
    SetEntityHeading(PlayerPedId(), 359.3586730957)
    createcamcinematique(true)
    FreezeEntityPosition(PlayerPedId(), false)
    DoScreenFadeIn(1500)
    ClearPedTasks(GetPlayerPed(-1))
    TaskPedSlideToCoord(PlayerPedId(), -491.68, -681.96, 33.2, 359.3586730957, 1.0)
    Citizen.Wait(21000)
    openCinematique()
    SetTimecycleModifier('')
    PlaySoundFrontend(-1, "CHARACTER_SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0)
    TriggerEvent('instance:close')
    for i = 0, 357 do
        EnableAllControlActions(i)
    end
    destorycam()
    SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
end)

function startAnims(lib, anim)
	ESX.Streaming.RequestAnimDict(lib, function()
		TaskPlayAnim(PlayerPedId(), lib, anim, 8.0, 8.0, -1, 14, 0, false, false, false)
	end)
end

local isCameraActive = false

local creationPerso = {
    Base = { Header = {"commonmenu", "interaction_bgd"}, Color = {color_black}, Blocked = true , HeaderColor = {0, 255, 220}, Title = "Menu création"},
	Data = { currentMenu = "Nouveau personnage" },
	Events = {onSelected = function(self, _, btn)
            if btn.name == "Traits du visage" then 
                OpenMenu("Traits du visage")
            elseif btn.name == "Apparence" then
                OpenMenu("Apparence")
            elseif btn.name == "Barbe" then 
                OpenMenu("Barbe")
            elseif btn.name == "Pilosité" then 
                OpenMenu("Pilosité")
            elseif btn.name == "Maquillage" then 
                OpenMenu("Maquillage")
            elseif btn.name == "Tenues" then 
                OpenMenu("Tenues")
            elseif btn.name == "Bras" then 
                OpenMenu("Bras")
            elseif btn.name == "Prénom" then 
                local result = KeyboardInput("", 30)
                if result ~= nil then
                    ResultPrenom = result
                 end
            elseif btn.name == "Nom" then 
                local result = KeyboardInput("", 30)
                if result ~= nil then
                    ResultNom = result
                end
             elseif btn.name == "Date de naissance" then 
                local result = KeyboardInput("", 30)
                if result ~= nil then
                    ResultDateDeNaissance = result
                end
            elseif btn.name == "Lieu de naissance" then 
                local result = KeyboardInput("", 30)
                if result ~= nil then
                    ResultLieuNaissance = result
                end
            elseif btn.name == "Taille" then 
                local result = KeyboardInput("", 30)
                if result ~= nil then
                    ResultTaille = result
                end
            elseif btn.name == "Sexe" then 
                local result = KeyboardInput("", 30)
                if result ~= nil then
                    ResultSexe = result
                end
            elseif btn.name == "~g~Continuer & Sauvegarder" then
                    isCameraActive = false
                    TriggerServerEvent('clp_character:saveidentite', ResultSexe, ResultPrenom, ResultNom, ResultDateDeNaissance, ResultTaille)
                    CreateBoard(GetPlayerPed(-1))
                    startAnims("mp_character_creation@customise@male_a", "drop_outro")
                    TriggerEvent('skinchanger:getSkin', function(skin)
                        LastSkin = skin
                    end)
                    TriggerEvent('skinchanger:getSkin', function(skin)
                    TriggerServerEvent('esx_skin:save', skin)
                    end)
                    incamera = true
                    createcam(false)
                    self:CloseMenu(true)
                    createcamfin(false)
                    SetTimecycleModifier('scanline_cam_cheap')
                    local cam = {}
                    cam = CreateCam("DEFAULT_SCRIPTED_Camera", 1)
                    SetCamCoord(cam, 414.54, -998.27, -98.5)
                    RenderScriptCams(1, 0, 0, 1, 1)
                    PointCamAtCoord(cam, 408.89, -998.42, -99.0)
                    DoScreenFadeIn(1500)
                    PlaySoundFrontend(-1, "Parcel_Vehicle_Lost", "GTAO_FM_Events_Soundset", 1)
                    while GetCamFov(cam) >= 32.0 do
                        Wait(0)
                        SetCamFov(cam, GetCamFov(cam)-0.05)
                    end
                    FreezeEntityPosition(GetPlayerPed(-1), false)
                    startAnims("mp_character_creation@lineup@male_a", "outro")
                    PlaySoundFrontend(-1, "ScreenFlash", "MissionFailedSounds", 1)
                    DoScreenFadeOut(10500)
                    Citizen.Wait(8500)
                    destorycam()
                    ClearPedTasksImmediately(GetPlayerPed(-1))
                    DeleteObject(board)
                    DeleteObject(overlay)
                    PlaySoundFrontend(-1, "1st_Person_Transition", "PLAYER_SWITCH_CUSTOM_SOUNDSET", 1)
                    TriggerEvent('clp_character:SpawnCharacter')
            end
        end,
        onSlide = function(menuData, currentButton, currentSlt, PMenu)
            local currentMenu, ped = menuData.currentMenu, GetPlayerPed(-1)
            if currentMenu == "Nouveau personnage" then
                createcam(true)
                if currentSlt ~= 1 then return end
                currentButton = currentButton.slidenum - 1
                sex = currentButton
                TriggerEvent('skinchanger:change', 'sex', sex)
            end
            if currentMenu == "Apparence" then
                createcamvisage(true)
                if currentSlt ~= 1 then return end
                currentButton = currentButton.slidenum - 1
                face = currentButton
                TriggerEvent('skinchanger:change', 'face', face)
            end
            if currentMenu == "peau" then
                createcam(true)
                if currentSlt ~= 1 then return end
                local currentButton = currentButton.slidenum - 1
                skin = currentButton
                TriggerEvent('skinchanger:change', 'skin', skin)
            end
            if currentMenu == "type de la barbe" then
                createcamvisage(true)
                if currentSlt ~= 1 then return end
                local currentButton = currentButton.slidenum - 1
                beard = currentButton
                TriggerEvent('skinchanger:change', 'beard_1', beard)
            end
            if currentMenu == "couleur de la barbe" then
                createcamvisage(true)
                if currentSlt ~= 1 then return end
                local currentButton = currentButton.slidenum - 1
                beard3 = currentButton
                TriggerEvent('skinchanger:change', 'beard_3', beard3)
            end
            if currentMenu == "taille de la barbe" then
                createcamvisage(true)
                if currentSlt ~= 1 then return end
                local currentButton = currentButton.slidenum - 1
                beard2 = currentButton
                TriggerEvent('skinchanger:change', 'beard_2', beard2)
            end
            if currentMenu == "couleur des yeux" then
                createcamyeux(true)
                if currentSlt ~= 1 then return end
                local currentButton = currentButton.slidenum - 1
                eyecolor = currentButton
                TriggerEvent('skinchanger:change', 'eye_color', eyecolor)
            end
            if currentMenu == "type de cheveux" then
                createcamvisage(true)
                if currentSlt ~= 1 then return end
                local currentButton = currentButton.slidenum - 1
                hair = currentButton
                TriggerEvent('skinchanger:change', 'hair_1', hair)
            end
            if currentMenu == "couleur des cheveux" then
                createcamvisage(true)
                if currentSlt ~= 1 then return end
                local currentButton = currentButton.slidenum - 1
                hair2 = currentButton
                TriggerEvent('skinchanger:change', 'hair_color_1', hair2)
            end
            if currentMenu == "type des sourcils" then
                createcamvisage(true)
                if currentSlt ~= 1 then return end
                local currentButton = currentButton.slidenum - 1
        
                eyebrow = currentButton
                TriggerEvent('skinchanger:change', 'eyebrows_1', eyebrow)
            end
            if currentMenu == "taille des sourcils" then
                createcamvisage(true)
                if currentSlt ~= 1 then return end
                local currentButton = currentButton.slidenum - 1
        
                eyebrow = currentButton
                TriggerEvent('skinchanger:change', 'eyebrows_2', eyebrow)
            end
            if currentMenu == "vos imperfections" then
                createcamvisage(true)
                if currentSlt ~= 1 then return end
                local skinproblem = currentButton.slidenum - 1
                TriggerEvent('skinchanger:change', 'complexion_1', skinproblem)
            end
            if currentMenu == "opacité des imperfections" then
                createcamvisage(true)
                if currentSlt ~= 1 then return end
                local skinproblem2 = currentButton.slidenum - 1
                TriggerEvent('skinchanger:change', 'complexion_2', skinproblem2)
            end
            if currentMenu == "taches de rousseur" then
                createcamvisage(true)
                if currentSlt ~= 1 then return end
                local freckle = currentButton.slidenum - 1
                TriggerEvent('skinchanger:change', 'moles_1', freckle)
            end
            if currentMenu == "opacité des taches de rousseurs" then
                createcamvisage(true)
                if currentSlt ~= 1 then return end
                local freckle2 = currentButton.slidenum - 1
                TriggerEvent('skinchanger:change', 'moles_2', freckle2)
            end
            if currentMenu == "rides" then
                createcamvisage(true)
                if currentSlt ~= 1 then return end
                local wrinkle = currentButton.slidenum - 1
                TriggerEvent('skinchanger:change', 'age_1', wrinkle)
            end
            if currentMenu == "opacité des rides" then
                createcamvisage(true)
                if currentSlt ~= 1 then return end
                local wrinkle2 = currentButton.slidenum - 1
                TriggerEvent('skinchanger:change', 'age_2', wrinkle2)
            end
            if currentMenu == "votre acné" then
                createcamvisage(true)
                if currentSlt ~= 1 then return end
                local acne = currentButton.slidenum - 1
        
                SetPedHeadOverlay(GetPlayerPed(-1), 0, acne, 1.0)
            end
            if currentMenu == "dommages uv" then
                createcamvisage(true)
                if currentSlt ~= 1 then return end
                local sun1 = currentButton.slidenum - 1
                TriggerEvent('skinchanger:change', 'sun_1', sun1)
            end
            if currentMenu == "opacité des dommages uv" then
                createcamvisage(true)
                if currentSlt ~= 1 then return end
                local sun2 = currentButton.slidenum - 1
                TriggerEvent('skinchanger:change', 'sun_2', sun2)
            end
            if currentMenu == "teint" then
                createcamvisage(true)
                if currentSlt ~= 1 then return end
                local complexion1 = currentButton.slidenum - 1
                TriggerEvent('skinchanger:change', 'complexion_1', complexion1)
            end
            if currentMenu == "opacité du teint" then
                createcamvisage(true)
                if currentSlt ~= 1 then return end
                local complexion2 = currentButton.slidenum - 1
                TriggerEvent('skinchanger:change', 'complexion_2', complexion2)
            end
            if currentMenu == "rougeurs" then
                createcamvisage(true)
                if currentSlt ~= 1 then return end
                local blush1 = currentButton.slidenum - 1
                TriggerEvent('skinchanger:change', 'blush_1', blush1)
            end
            if currentMenu == "opacité des rougeurs" then
                createcamvisage(true)
                if currentSlt ~= 1 then return end
                local blush2 = currentButton.slidenum - 1
                TriggerEvent('skinchanger:change', 'blush_2', blush2)
            end
            if currentMenu == "couleur des rougeurs" then
                createcamvisage(true)
                if currentSlt ~= 1 then return end
                local blush3 = currentButton.slidenum - 1
                TriggerEvent('skinchanger:change', 'blush_3', blush3)
            end
            if currentMenu == "boutons" then
                createcamvisage(true)
                if currentSlt ~= 1 then return end
                local blemishes1 = currentButton.slidenum - 1
                TriggerEvent('skinchanger:change', 'blemishes_1', blemishes1)
            end
            if currentMenu == "opacité des boutons" then
                createcamvisage(true)
                if currentSlt ~= 1 then return end
                local blemishes2 = currentButton.slidenum - 1
                TriggerEvent('skinchanger:change', 'blemishes_2', blemishes2)
            end
            if currentMenu == "imperfections du corp" then
                createcamtorse(true)
                if currentSlt ~= 1 then return end
                local bodyb1 = currentButton.slidenum - 1
                TriggerEvent('skinchanger:change', 'bodyb_1', bodyb1)
            end
            if currentMenu == "opacité imperfections du corp" then
                createcamtorse(true)
                if currentSlt ~= 1 then return end
                local bodyb2 = currentButton.slidenum - 1
                TriggerEvent('skinchanger:change', 'bodyb_2', bodyb2)
            end
            if currentMenu == "poils du torse" then
                createcamtorse(true)
                if currentSlt ~= 1 then return end
                local chest1 = currentButton.slidenum - 1
                TriggerEvent('skinchanger:change', 'chest_1', chest1)
            end
            if currentMenu == "taille des poils du torse" then
                createcamtorse(true)
                if currentSlt ~= 1 then return end
                local chest2 = currentButton.slidenum - 1
                TriggerEvent('skinchanger:change', 'chest_2', chest2)
            end
            if currentMenu == "couleur des poils du torse" then
                createcamtorse(true)
                if currentSlt ~= 1 then return end
                local chest3 = currentButton.slidenum - 1
                TriggerEvent('skinchanger:change', 'chest_3', chest3)
            end
            if currentMenu == "type de maquillage" then
                createcamvisage(true)
                if currentSlt ~= 1 then return end
                local makeup1 = currentButton.slidenum - 1
                TriggerEvent('skinchanger:change', 'makeup_1', makeup1)
            end
            if currentMenu == "opacité du maquillage" then
                createcamvisage(true)
                if currentSlt ~= 1 then return end
                local makeup2 = currentButton.slidenum - 1
                TriggerEvent('skinchanger:change', 'makeup_2', makeup2)
            end
            if currentMenu == "couleur du maquillage" then
                createcamvisage(true)
                if currentSlt ~= 1 then return end
                local makeup3 = currentButton.slidenum - 1
                TriggerEvent('skinchanger:change', 'makeup_3', makeup3)
            end
            if currentMenu == "type de rouge à lèvres" then
                createcamvisage(true)
                if currentSlt ~= 1 then return end
                local lipstick1 = currentButton.slidenum - 1
                TriggerEvent('skinchanger:change', 'lipstick_1', lipstick1)
            end
            if currentMenu == "opacité du rouge à lèvres" then
                createcamvisage(true)
                if currentSlt ~= 1 then return end
                local lipstick2 = currentButton.slidenum - 1
                TriggerEvent('skinchanger:change', 'lipstick_2', lipstick2)
            end
            if currentMenu == "couleur du rouge à lèvres" then
                createcamvisage(true)
                if currentSlt ~= 1 then return end
                local lipstick3 = currentButton.slidenum - 1
                TriggerEvent('skinchanger:change', 'lipstick_3', lipstick3)
            end
            if currentMenu == "type de bras" then
                createcam(true)
                if currentSlt ~= 1 then return end
                local arms = currentButton.slidenum - 1
                TriggerEvent('skinchanger:change', 'arms', arms)
            end
            if currentMenu == "couleur des bras" then
                createcam(true)
                if currentSlt ~= 1 then return end
                local arms2 = currentButton.slidenum - 1
                TriggerEvent('skinchanger:change', 'arms_2', arms2)
            end
            if currentMenu == "t-shirt" then
                createcamtorse(true)
                if currentSlt ~= 1 then return end
                local tshirt1 = currentButton.slidenum - 1
                TriggerEvent('skinchanger:change', 'tshirt_1', tshirt1)
            end
            if currentMenu == "couleur t-shirt" then
                createcamtorse(true)
                if currentSlt ~= 1 then return end
                local tshirt2 = currentButton.slidenum - 1
                TriggerEvent('skinchanger:change', 'tshirt_2', tshirt2)
            end
            if currentMenu == "veste" then
                createcamtorse(true)
                if currentSlt ~= 1 then return end
                local torso1 = currentButton.slidenum - 1
                TriggerEvent('skinchanger:change', 'torso_1', torso1)
            end
            if currentMenu == "couleur veste" then
                createcamtorse(true)
                if currentSlt ~= 1 then return end
                local torso2 = currentButton.slidenum - 1
                TriggerEvent('skinchanger:change', 'torso_2', torso2)
            end
            if currentMenu == "bas" then
                createcamjambe(true)
                if currentSlt ~= 1 then return end
                local pants1 = currentButton.slidenum - 1
                TriggerEvent('skinchanger:change', 'pants_1', pants1)
            end
            if currentMenu == "couleur du bas" then
                createcamjambe(true)
                if currentSlt ~= 1 then return end
                local pants2 = currentButton.slidenum - 1
                TriggerEvent('skinchanger:change', 'pants_2', pants2)
            end
            if currentMenu == "chaussures" then
                createcamchaussure(true)
                if currentSlt ~= 1 then return end
                local shoes1 = currentButton.slidenum - 1
                TriggerEvent('skinchanger:change', 'shoes_1', shoes1)
            end
            if currentMenu == "couleur des chaussures" then
                createcamchaussure(true)
                if currentSlt ~= 1 then return end
                local shoes2 = currentButton.slidenum - 1
                TriggerEvent('skinchanger:change', 'shoes_2', shoes2)
            end
        end,
    },
	Menu = {
        ["Nouveau personnage"] = {
            useFilter = true,
			b = {
                {name = "Skin", slidemax = 1, Description = "~r~Attention ! ~s~Les skin 'ped' ne peuvent être que très légèrement modifiés."},
                {name = "Apparence", ask = "→", askX = true, Description = "Choisissez votre apparence."},
                {name = "Maquillage", ask = "→", askX = true, Description = "Choisissez votre maquillage."},
                {name = "Traits du visage", ask = "→", askX = true, Description = "Choisissez vos traits du visage."},
                {name = "Tenues", ask = "→", askX = true, Description = "Choisissez votre tenue."},
                {name = "Identité", ask = "→", askX = true, Description = "Choisissez votre identité."},
			}
        },
        ["Tenues"] = {   
            useFilter = true,        
			b = {
                {name = "T-Shirt", ask = "→", askX = true, Description = "Choisissez votre t-shirt."},
                {name = "Couleur T-Shirt", ask = "→", askX = true, Description = "Choisissez votre couleur de t-shirt."},
                {name = "Veste", ask = "→", askX = true, Description = "Choisissez votre veste."},
                {name = "Couleur veste", ask = "→", askX = true, Description = "Choisissez votre couleur de veste."},
                {name = "Bas", ask = "→", askX = true, Description = "Choisissez votre bas."},
                {name = "Couleur du bas", ask = "→", askX = true, Description = "Choisissez votre couleur de bas."},
                {name = "Chaussures", ask = "→", askX = true, Description = "Choisissez vos chaussures."},
                {name = "Couleur des chaussures", ask = "→", askX = true, Description = "Choisissez votre couleur de chaussure."},
            }
        },
        ["identité"] = {
			b = {
                {name = "Prénom", ask = "'Aslan'", askX = true, Description = "Choisissez votre prénom."},
                {name = "Nom", ask = "'Doblow'", askX = true, Description = "Choisissez votre nom."},
                {name = "Date de naissance", ask = "JJ/MM/AAAA", askX = true, Description = "Choisissez votre date de naissance."},
                {name = "Lieu de naissance", ask = "'Los Santos'", askX = true, Description = "Choisissez votre lieu de naissance."},
                {name = "Taille", ask = "'170'", askX = true, Description = "Choisissez votre taille."},
                {name = "Sexe", ask = "'m/f'", askX = true, Description = "Choisissez votre sexe."},
                {name = "~g~Continuer & Sauvegarder", Description = "~r~Attention ! ~s~Si vous acceptez cette étape, vous ne pourrez plus revenir en arrière."},
			}
        },
        ["Apparence"] = {   
            useFilter = true,        
			b = {
                {name = "Visage", slidemax = 45, Description = "Choisissez votre visage."},
                {name = "Peau", ask = "→", askX = true, Description = "Choisissez votre couleur de peau."},
                {name = "Bras", ask = "→", askX = true, Description = "Choisissez vos bras."},
                {name = "Pilosité", ask = "→", askX = true, Description = "Choisissez votre pilosité."},
                {name = "Couleur des yeux", ask = "→", askX = true, Description = "Choisissez votre couleur des yeux."},
                {name = "Imperfections du corp", ask = "→", askX = true, Description = "Choisissez vos imperfections du corp."},
                {name = "Opacité imperfections du corp", ask = "→", askX = true, Description = "Choisissez l'opacité de vos imperfections."},
            }
        },
        ["Maquillage"] = { 
            useFilter = true,          
			b = {
                {name = "Type de maquillage", ask = "→", askX = true, Description = "Choisissez votre type de maquillage."},
                {name = "Opacité du maquillage", ask = "→", askX = true, Description = "Choisissez la taille de votre maquillage."},
                {name = "Couleur du maquillage", ask = "→", askX = true, Description = "Choisissez la couleur de votre maquillage."},
                {name = "Type de rouge à lèvres", ask = "→", askX = true, Description = "Choisissez votre type de rouge à lèvres."},
                {name = "Opacité du rouge à lèvres", ask = "→", askX = true, Description = "Choisissez la taille de votre rouge à lèvres."},
                {name = "Couleur du rouge à lèvres", ask = "→", askX = true, Description = "Choisissez la couleur de votre rouge à lèvres."},
            }
        },
        ["Traits du visage"] = {     
            useFilter = true,      
			b = {
                {name = "Rides", ask = "→", askX = true, Description = "Choisissez vos rides."},
                {name = "Opacité des rides", ask = "→", askX = true, Description = "Choisissez la taille de vos rides."},
                {name = "Dommages UV", ask = "→", askX = true, Description = "Choisissez vos dommages UV."},
                {name = "Opacité des dommages UV", ask = "→", askX = true, Description = "Choisissez l'opacité de vos dommages UV."},
                {name = "Boutons", ask = "→", askX = true, Description = "Choisissez vos boutons."},
                {name = "Opacité des boutons", ask = "→", askX = true, Description = "Choisissez l'opacité de vos boutons."},
                {name = "Teint", ask = "→", askX = true, Description = "Choisissez votre teint."},
                {name = "Opacité du teint", ask = "→", askX = true, Description = "Choisissez l'opacité de votre teint."},
                {name = "Taches de rousseur", ask = "→", askX = true, Description = "Choisissez vos taches de rousseur."},
                {name = "Opacité des taches de rousseurs", ask = "→", askX = true, Description = "Choisissez l'opacité de vos tahes de rousseur."},
                {name = "Rougeurs", ask = "→", askX = true, Description = "Choisissez vos rougeurs."},
                {name = "Opacité des rougeurs", ask = "→", askX = true, Description = "Choisissez l'opacité des rougeurs."},
                {name = "Couleur des rougeurs", ask = "→", askX = true, Description = "Choisissez la couleur de vos rougeurs."},
            }
        },
        ["Pilosité"] = {     
            useFilter = true,      
			b = {
                {name = "Type de cheveux", ask = "→", askX = true, Description = "Choisissez votre type de coiffure."},
                {name = "Couleur des cheveux", ask = "→", askX = true, Description = "Choisissez la couleur de votre coiffure."},
                {name = "Taille de la barbe", ask = "→", askX = true, Description = "Choisissez la taille de votre barbe."},
                {name = "Type de la barbe", ask = "→", askX = true, Description = "Choisissez votre type de barbe."},
                {name = "Couleur de la barbe", ask = "→", askX = true, Description = "Choisissez la couleur de votre barbe."},
                {name = "Type des sourcils", ask = "→", askX = true, Description = "Choisissez le type de sourcils."},
                {name = "Taille des sourcils", ask = "→", askX = true, Description = "Choisissez la taille de vos sourcils."},
                {name = "Poils du torse", ask = "→", askX = true, Description = "Choisissez le type de poils de torse."},
                {name = "Taille des poils du torse", ask = "→", askX = true, Description = "Choisissez la taille de vos poils de torse."},
                {name = "Couleur des poils du torse", ask = "→", askX = true, Description = "Choisissez la couleur de vos poils de torse."},
            }
        },
        ["chaussures"] = {            
            b = {
                { name = "Chaussures", slidemax = 114, Description = "Choisissez vos chaussures."},
            }
        },
        ["couleur des chaussures"] = {            
            b = {
                { name = "Couleur des chaussures", slidemax = 20, Description = "Choisissez votre couleur de chaussure."},
            }
        },
        ["bas"] = {            
            b = {
                { name = "Bas", slidemax = 114, Description = "Choisissez votre bas."},
            }
        },
        ["couleur du bas"] = {            
            b = {
                { name = "Couleur du bas", slidemax = 20, Description = "Choisissez votre couleur de bas."},
            }
        },
        ["veste"] = {            
            b = {
                { name = "Veste", slidemax = 289, Description = "Choisissez votre veste."},
            }
        },
        ["couleur veste"] = {            
            b = {
                { name = "Couleur Veste", slidemax = 20, Description = "Choisissez votre couleur de veste."},
            }
        },
        ["couleur t-shirt"] = {            
            b = {
                { name = "Couleur T-Shirt", slidemax = 20, Description = "Choisissez votre couleur de t-shirt."},
            }
        },
        ["t-shirt"] = {            
            b = {
                { name = "T-Shirt", slidemax = 143, Description = "Choisissez votre t-shirt."},
            }
        },
        ["Bras"] = {            
            b = {
                { name = "Type de bras", ask = "→", askX = true, Description = "Choisissez votre type de bras."},
                { name = "Couleur des bras", ask = "→", askX = true, Description = "Choisissez votre couleur de bras."},
            }
        },
        ["type de bras"] = {            
            b = {
                { name = "Type de bras", slidemax = 163, Description = "Choisissez votre type de bras."},
            }
        },
        ["couleur des bras"] = {            
            b = {
                { name = "Couleur des bras", slidemax = 10, Description = "Choisissez votre couleur de bras."},
            }
        },
        ["type de maquillage"] = {            
            b = {
                { name = "Type de maquillage", slidemax = 71, Description = "Choisissez votre type de maquillage."},
            }
        },
        ["opacité du maquillage"] = {
            b = {
                { name = "Opacité du maquillage", slidemax = 10, Description = "Choisissez la taille de votre maquillage."},
            }
        },
        ["couleur du maquillage"] = {            
            b = {
                { name = "Couleur du maquillage", slidemax = 63, Description = "Choisissez la couleur de votre maquillage."},
            }
        },
        ["type de rouge à lèvres"] = {
            b = {
                { name = "Type de rouge à lèvres", slidemax = 9, Description = "Choisissez votre type de rouge à lèvres."},
            }
        },
        ["opacité du rouge à lèvres"] = {            
            b = {
                { name = "Opacité du rouge à lèvres", slidemax = 10, Description = "Choisissez la taille de votre rouge à lèvres."},
            }
        },
        ["couleur du rouge à lèvres"] = {            
            b = {
                { name = "Couleur du rouge à lèvres", slidemax = 63, Description = "Choisissez la couleur de votre rouge à lèvres."},
            }
        },
        ["imperfections du corp"] = {            
			b = {
                { name = "Imperfections du corp", slidemax = 11, Description = "Choisissez vos imperfections du corp."},
            }
        },
        ["opacité imperfections du corp"] = {
            b = {
                { name = "Opacité imperfections du corp", slidemax = 10, Description = "Choisissez l'opacité de vos imperfections."},
            }
        },
        ["boutons"] = {            
			b = {
                { name = "Boutons", slidemax = 23, Description = "Choisissez vos boutons."},
            }
        },
        ["opacité des boutons"] = {
            b = {
                { name = "Opacité des boutons", slidemax = 10, Description = "Choisissez l'opacité de vos boutons."},
            }
        },
        ["rougeurs"] = {            
			b = {
                { name = "Rougeurs", slidemax = 32, Description = "Choisissez vos rougeurs."},
            }
        },
        ["opacité des rougeurs"] = {
            b = {
                { name = "Opacité des rougeurs", slidemax = 10, Description = "Choisissez l'opacité des rougeurs."},
            }
        },
        ["couleur des rougeurs"] = {            
			b = {
                { name = "Couleur des rougeurs", slidemax = 63, Description = "Choisissez la couleur de vos rougeurs."},
            }
        },
        ["poils du torse"] = {            
			b = {
                { name = "Poils du torse", slidemax = 16, Description = "Choisissez le type de poils de torse."},
            }
        },
        ["taille des poils du torse"] = {
            b = {
                { name = "Taille des poils du torse", slidemax = 10, Description = "Choisissez la taille de vos poils de torse."},
            }
        },
        ["couleur des poils du torse"] = {            
			b = {
                { name = "Couleur des poils du torse", slidemax = 63, Description = "Choisissez la couleur de vos poils de torse."},
            }
        },
        ["teint"] = {            
			b = {
                { name = "Teint", slidemax = 11, Description = "Choisissez votre teint."},
            }
        },
        ["opacité du teint"] = {
            b = {
                { name = "Opacité du teint", slidemax = 10, Description = "Choisissez l'opacité de votre teint."},
            }
        },
        ["dommages uv"] = {            
			b = {
                { name = "Dommages UV", slidemax = 10, Description = "Choisissez vos dommages UV."},
            }
        },
        ["opacité des dommages uv"] = {
            b = {
                { name = "Opacité des dommages UV", slidemax = 10, Description = "Choisissez l'opacité de vos dommages UV."},
            }
        },
        ["couleur de la barbe"] = {            
			b = {
                { name = "Couleur de la barbe", slidemax = 63, Description = "Choisissez la couleur de votre barbe."},
            }
        },
        ["type de la barbe"] = {            
			b = {
                { name = "Type de la barbe", slidemax = 28, Description = "Choisissez votre type de barbe."},
            }
        },
        ["taille de la barbe"] = {            
			b = {
                { name = "Taille de la barbe", slidemax = 10, Description = "Choisissez la taille de votre barbe."},
            }
        },
        ["votre acné"] = {            
			b = {
                { name = "Acné", slidemax = 15},
            }
        },
        ["rides"] = {            
			b = {
                { name = "Rides", slidemax = 15, Description = "Choisissez vos rides."},
            }
        },
        ["opacité des rides"] = {            
			b = {
                { name = "Opacité des rides", slidemax = 10, Description = "Choisissez la taille de vos rides."},
            }
        },
        ["taches de rousseur"] = {            
			b = {
                { name = "Taches de rousseurs", slidemax = 17, Description = "Choisissez vos taches de rousseur."},
            }
        },
        ["opacité des taches de rousseurs"] = {
            b = {
                { name = "Opacité des taches de rousseurs", slidemax = 10, Description = "Choisissez l'opacité de vos tahes de rousseur."},
            }
        },
        ["votre tête"] = {
			b = {
                { name = "Visage", slidemax = 45 },
			}
        },
        ["peau"] = {
			b = {
				{ name = "Peau", slidemax = 45, Description = "Choisissez votre couleur de peau."},
			}
        },
        ["couleur des yeux"] = {
			b = {
				{ name = "Couleur des yeux", slidemax = 31, Description = "Choisissez votre couleur des yeux."},
			}
        },
        ["type de cheveux"] = {
			b = {
				{ name = "Type de cheveux", slidemax = 73, Description = "Choisissez votre type de coiffure."}
			}
        },
        ["couleur des cheveux"] = {
			b = {
				{ name = "Couleur des cheveux", slidemax = 63, Description = "Choisissez la couleur de votre coiffure."}
			}
        },
        ["type des sourcils"] = {
			b = {
				{ name = "Type des sourcils", slidemax = 33, Description = "Choisissez le type de sourcils."},
			}
        },
        ["taille des sourcils"] = {
			b = {
				{ name = "Taille des sourcils", slidemax = 10, Description = "Choisissez la taille de vos sourcils."},
			}
        },
	}
}

function AnimationIntro()
    RequestAnimDict("mp_character_creation@lineup@male_a")
    Citizen.Wait(100)
    startAnims("mp_character_creation@lineup@male_a", "intro")
    Citizen.Wait(5700)
    RequestAnimDict("mp_character_creation@customise@male_a")
    Citizen.Wait(100)
    TaskPlayAnim(PlayerPedId(), "mp_character_creation@customise@male_a", "loop", 1.0, 1.0, -1, 0, 1, 0, 0, 0)
    Citizen.Wait(2250)
end

TriggerEvent('instance:registerType', 'skin')
TriggerEvent('instance:registerType', 'property')

RegisterNetEvent('clp_charact:create')
AddEventHandler('clp_charact:create', function()
    DisplayRadar(false)
    TriggerEvent('esx_status:setDisplay', 0.0)
    TriggerEvent('instance:create', 'skin')
    TriggerEvent('skinchanger:change', 'tshirt_1', 15)
    TriggerEvent('skinchanger:change', 'torso_1', 15)
    TriggerEvent('skinchanger:change', 'arms', 15)
    TriggerEvent('skinchanger:change', 'pants_1', 14)
    TriggerEvent('skinchanger:change', 'shoes_1', 34)
    isCameraActive = true
    for i = 0, 357 do
        DisableAllControlActions(i)
    end
    CreateCamEnter()
    SpawnCharacter()
    SetEntityCoords(GetPlayerPed(-1), 409.4, -1001.64, -99.0-0.98, 0.0, 0.0, 0.0, 10)
    SetEntityHeading(GetPlayerPed(-1), 2.9283561706543)
    CreateBoard(GetPlayerPed(-1))
    AnimationIntro()
    SetEntityCoords(GetPlayerPed(-1), 408.8, -998.64, -99.0-0.98, 0.0, 0.0, 0.0, 10)
    SetEntityHeading(GetPlayerPed(-1), 268.72219848633)
    Citizen.Wait(700)
    CreateMenu(creationPerso)
    FreezeEntityPosition(GetPlayerPed(-1), true)
    incamera = true
    ClearPedTasks(GetPlayerPed(-1))
    DeleteObject(board)
    DeleteObject(overlay)
end)


RegisterCommand('character1', function()    
    TriggerEvent('instance:create', 'skin')
    TriggerEvent('skinchanger:change', 'tshirt_1', 15)
    TriggerEvent('skinchanger:change', 'torso_1', 15)
    TriggerEvent('skinchanger:change', 'arms', 15)
    TriggerEvent('skinchanger:change', 'pants_1', 14)
    TriggerEvent('skinchanger:change', 'shoes_1', 34)
    isCameraActive = true
    for i = 0, 357 do
        DisableAllControlActions(i)
    end
    createcam(true)
    SetEntityCoords(GetPlayerPed(-1), 409.4, -1001.64, -99.0-0.98, 0.0, 0.0, 0.0, 10)
    SetEntityHeading(GetPlayerPed(-1), 2.9283561706543)
    CreateBoard(GetPlayerPed(-1))
    AnimationIntro()
    SetEntityCoords(GetPlayerPed(-1), 408.8, -998.64, -99.0-0.98, 0.0, 0.0, 0.0, 10)
    SetEntityHeading(GetPlayerPed(-1), 268.72219848633)
    CreateMenu(creationPerso)
    FreezeEntityPosition(GetPlayerPed(-1), true)
    incamera = true
    ClearPedTasks(GetPlayerPed(-1))
    DeleteObject(board)
    DeleteObject(overlay)
end)


RegisterNetEvent('instance:onCreate')
AddEventHandler('instance:onCreate', function(instance)
	if instance.type == 'skin' then
		TriggerEvent('instance:enter', instance)
	end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if isCameraActive then
            if IsControlJustPressed(1, 107) then 
                SetEntityHeading(PlayerPedId(), 0.50)
            elseif IsControlJustPressed(1, 108) then 
                SetEntityHeading(PlayerPedId(), 193.26)
            elseif IsControlJustPressed(1, 112) then 
                SetEntityHeading(PlayerPedId(), 268.72219848633)
            elseif IsControlJustPressed(1, 111) then 
                SetEntityHeading(PlayerPedId(), 91.04)
            end
        end
    end
end)

