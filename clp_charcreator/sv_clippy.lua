ESX              = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('clp_character:saveidentite')
AddEventHandler('clp_character:saveidentite', function(sexe, prenom, nom, datedenaissance, taille)
    _source = source
    mySteamID = GetPlayerIdentifiers(_source)
    mySteam = mySteamID[1]
    print("^3Clippy save")

    MySQL.Async.execute('UPDATE `users` SET `firstname` = @firstname, `lastname` = @lastname, `dateofbirth` = @dateofbirth, `sex` = @sex, `height` = @height WHERE identifier = @identifier', {
      ['@identifier']		= mySteam,
      ['@firstname']		= prenom,
      ['@lastname']		= nom,
      ['@dateofbirth']	= datedenaissance,
      ['@sex']			= sexe,
      ['@height']			= taille
    }, function(rowsChanged)
      if callback then
        callback(true)
      end
    end)
end)