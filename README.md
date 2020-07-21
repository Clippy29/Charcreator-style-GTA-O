# Charcreator-style-GTA-O
I share my Charcreator style GTA:O. Dependencys : skinchanger, instance. No support.
Pour fix le bug du double menu, retirer ces lignes dans l'esx_skin :

AddEventHandler('playerSpawned', function()
	Citizen.CreateThread(function()
		while not PlayerLoaded do
			Citizen.Wait(10)
		end

		if FirstSpawn then
			ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
				if skin == nil then
					TriggerEvent('skinchanger:loadSkin', {sex = 0}, OpenSaveableMenu)
				else
					TriggerEvent('skinchanger:loadSkin', skin)
				end
			end)

			FirstSpawn = false
		end
	end)
end)

Screen : https://streamable.com/mwychn
