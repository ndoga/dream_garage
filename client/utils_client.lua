ESX = exports.es_extended:getSharedObject()

lib.addKeybind({
    name = "deposita_veicolo",
    description = "Deposita veicolo al Garage",
    defaultKey = "E",
    onReleased = function()
        if inZone then
            if IsPedInAnyVehicle(cache.ped, false) then
                lib.callback("dream_garage:canDeposito", GetPlayerServerId(PlayerId()), function(result)
                    local veicolo = GetVehiclePedIsIn(cache.ped, false)

                    if IsPedInAnyVehicle(cache.ped, false) then
                        for k,v in pairs(result) do
                            local vehicle = ESX.Game.GetVehicleProperties(veicolo)

                            if v.metadata ~= nil and (v.metadata.targa == vehicle.plate or v.metadata.targa == GetVehicleNumberPlateText(veicolo)) then
                                ESX.TriggerServerCallback("dream_noleggioVeicoli:checkDelete", function(checkDelete)
                                    TriggerServerEvent("dream_garage:updateDannoVeicolo", vehicle.plate, inZone, json.encode(vehicle))
                                    TaskLeaveVehicle(cache.ped, veicolo, 0)
                                    Wait(2000)
                                    ESX.Game.DeleteVehicle(veicolo)
                                    veh = nil
                                    inZone = false
                                                            
                                    if checkDelete then
                                        ESX.ShowNotification("Hai terminato il periodo di noleggio! Il veicolo è stato riconsegnato!")
                                    end
                                end, vehicle.plate)
                            end
                        end
                    end
                end)
            else
                ESX.ShowNotification(IM_Lang.err_no_vehicles, 'error')
            end
        end
    end
})

CheckSpawn = function(targa)
    for _, veic in pairs(ESX.Game.GetVehicles()) do
        if ESX.Math.Trim(ESX.Game.GetVehicleProperties(veic).plate) == ESX.Math.Trim(targa) then
            if DoesEntityExist(veic) then
                return true
            end
        end
    end
end

CaricaModello = function(model)
    local DrawScreenText = function(text, red, green, blue, alpha)
        SetTextFont(4)
        SetTextScale(0.0, 0.5)
        SetTextColour(red, green, blue, alpha)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(1, 0, 0, 0, 255)
        SetTextDropShadow()
        SetTextOutline()
        SetTextCentre(true)
        BeginTextCommandDisplayText("STRING")
        AddTextComponentSubstringPlayerName(text)
        EndTextCommandDisplayText(0.5, 0.5)
    end
    if not IsModelValid(model) then
        return ESX.ShowNotification('Quest\'auto non esiste', "error")
    end
	if not HasModelLoaded(model) then
		RequestModel(model)
	end
	while not HasModelLoaded(model) do
		Wait(0)
		DrawScreenText("Caricamento modello " .. GetLabelText(GetDisplayNameFromVehicleModel(model)) .. "...", 255, 255, 255, 150)
	end
end

CheckItemChiavi = function(targa)
    local items = exports.ox_inventory:Search("slots", Config.Item_Chiavi)
    local t = ESX.Math.Trim(targa)

    for _, v in pairs(items) do
        return ESX.Math.Trim(v.metadata.targa) == t
    end
end