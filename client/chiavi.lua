ESX = exports.es_extended:getSharedObject()

RegisterNetEvent("dream_garage:apriVeicolo", function(targa)
    local checkItem = lib.callback.await("dream_garage:checkItem", GetPlayerServerId(PlayerId()))

    if checkItem then
        local veicolo, coords = lib.getClosestVehicle(GetEntityCoords(cache.ped), 20.0, false)

        if not DoesEntityExist(veicolo) then return end

        RequestAnimDict("anim@mp_player_intmenu@key_fob@")

        local t = ESX.Math.Trim(targa)
        local t1 = ESX.Math.Trim(ESX.Game.GetVehicleProperties(veicolo).plate)
        local t2 = ESX.Math.Trim(GetVehicleNumberPlateText(veicolo))

        if t == t1 or t == t2 then
            local stato = GetVehicleDoorLockStatus(veicolo)

            if stato == 1 then
                SetVehicleDoorsLocked(veicolo, 2)
                PlayVehicleDoorCloseSound(veicolo, 1)

                ESX.ShowNotification("Veicolo chiuso", "error")

                SetVehicleLights(veicolo, 2)
                Wait(150)
                SetVehicleLights(veicolo, 0)
                Wait(150)
                SetVehicleLights(veicolo, 2)
                Wait(150)
                SetVehicleLights(veicolo, 0)
            else
                SetVehicleDoorsLocked(veicolo, 1)
                PlayVehicleDoorCloseSound(veicolo, 0)

                ESX.ShowNotification("Veicolo aperto")

                SetVehicleLights(veicolo, 2)
                Wait(150)
                SetVehicleLights(veicolo, 0)
                Wait(150)
                SetVehicleLights(veicolo, 2)
                Wait(150)
                SetVehicleLights(veicolo, 0)
            end
        end
    end
end)