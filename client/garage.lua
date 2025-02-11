ESX = exports.es_extended:getSharedObject()

local cam
local cam2
local cam3
local veh = nil

local inZone = false

OpenGarage = function(id)
    lib.callback("dream_garage:getVeicoliGarage", GetPlayerServerId(PlayerId()), function(veicoli)
        if veicoli then
            local Garage = Config.Garages[id]
            local pos = GetEntityCoords(cache.ped)
            local c = Garage.Pos.Cam

            cam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', pos.x, pos.y, pos.z, 0.0, 0.0, 0.0, 50.0, false)
            PointCamAtCoord(cam, pos.x, pos.y, pos.z)
            SetCamActiveWithInterp(cam2, cam, 900, true, true)
            cam2 = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', c.x, c.y, c.z, c.rx, c.ry, c.rz, 70.0, false)
            PointCamAtCoord(cam, pos.x, pos.y, pos.z)
            SetCamActiveWithInterp(cam2, cam, 900, true, true)
            SetCamActive(cam2, true)
            RenderScriptCams(true, false, 1, true, true)

            local elementi = {}

            for k,v in pairs(veicoli) do
                local veicolofuori = nil

                lib.callback("dream_garage:checkVeicoloFuori", GetPlayerServerId(PlayerId()), function(bool)
                    if bool and CheckSpawn(v.targa) then
                        veicolofuori = true
                        TriggerServerEvent("dream_garage:updateFuoriDentro", v.targa, "fuori")
                    else
                        if not CheckSpawn(v.targa) then
                            veicolofuori = false
                            TriggerServerEvent("dream_garage:updateFuoriDentro", v.targa, "dentro")
                        else
                            veicolofuori = true
                            TriggerServerEvent("dream_garage:updateFuoriDentro", v.targa, "fuori")
                        end
                    end
                end, v.targa)

                while veicolofuori == nil do
                    Wait(1)
                end

                local disabilitato = true
                local testo = "Proprietario: "..v.proprietario

                if v.sequestrato == 1 then
                    testo = testo.."\nVeicolo Sequestrato"
                elseif veicolofuori == 1 then
                    testo = testo.."\nVeicolo Fuori"
                elseif not v.haLeChiavi then
                    testo = testo.."\nNon hai le chiavi"
                else
                    disabilitato = false
                end

                table.insert(elementi, {
                    title = v.modello.." - "..v.targa,
                    description = testo,
                    arrow = not disabilitato,
                    disabled = disabilitato,
                    event = "dream_garage:menuVeicolo",
                    args = { v = v, Garage = Garage }
                })
            end

            lib.registerContext({
                id = "menu_garage",
                title = Garage.Label,
                onExit = function()
                    RenderScriptCams(false, false, 1, true, true)
                    ESX.Game.DeleteVehicle(veh)
                    veh = nil
                end,
                onBack = function()
                    ESX.Game.DeleteVehicle(veh)
                    veh = nil
                end,
                options = elementi,
            })
    
            lib.showContext("menu_garage")
        else
            ESX.ShowNotification(IM_Lang.err_no_vehicle, "error")
        end
    end, id)
end

RegisterNetEvent("dream_garage:menuVeicolo", function(args)
    local v = args.v
    local Garage = args.Garage

    if ESX.Game.IsSpawnPointClear(Garage.Pos.Vehicle, 3.0) then
        CaricaModello(v.veicolo)
        ESX.Game.SpawnLocalVehicle(v.veicolo, Garage.Pos.Vehicle, Garage.Pos.Vehicle.h, function(veicolo)
            local statoveicolo = json.decode(v.vehicle)

            veh = veicolo
            statoveicolo.plate = "dream"

            ESX.Game.SetVehicleProperties(veicolo, statoveicolo)
        end)
    else
        ESX.ShowNotification(IM_Lang.err_spawn_blocked, 'error')
    end
    
    lib.registerContext({
        id = "menu_veicolo",
        title = Garage.Label,
        menu = "menu_garage",
        onExit = function()
            RenderScriptCams(false, false, 1, true, true)
            ESX.Game.DeleteVehicle(veh)
            veh = nil
        end,
        onBack = function()
            ESX.Game.DeleteVehicle(veh)
            veh = nil
        end,
        options = {
            {
                title = "Prendi veicolo",
                onSelect = function()
                    local veicolofuori = nil

                    lib.callback("dream_garage:checkVeicoloFuori", GetPlayerServerId(PlayerId()), function(bool)
                        if bool and CheckSpawn(v.targa) then
                            veicolofuori = true
                            TriggerServerEvent("dream_garage:updateFuoriDentro", v.targa, "fuori")
                        else
                            if not CheckSpawn(targa) then
                                veicolofuori = false
                                TriggerServerEvent("dream_garage:updateFuoriDentro", targa, "dentro")
                            else
                                veicolofuori = true
                                TriggerServerEvent("dream_garage:updateFuoriDentro", targa, "fuori")
                            end
                        end
                    end, v.targa)

                    while veicolofuori == nil do
                        Wait(1)
                    end

                    if veicolofuori then
                        ESX.Game.DeleteVehicle(veh)
                        RenderScriptCams(false, false, 1, true, true)
                        ESX.ShowNotification(IM_Lang.err_vehicle_out, 'error')
                        TriggerServerEvent("dream_garage:updateFuoriDentro", v.targa, "fuori")
                    else
                        local pos = GetEntityCoords(cache.ped)
                        local Pos_Vehicle = Garage.Pos.Vehicle
                        local Pos_Cam = Garage.Pos.Cam

                        cam3 = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', Pos_Vehicle.x, Pos_Vehicle.y, Pos_Vehicle.z, Pos_Cam.rx, Pos_Cam.ry, Pos_Cam.rz, 100.0, false)
                        PointCamAtCoord(cam2, pos.x, pos.y, pos.z)
                        SetCamActiveWithInterp(cam3, cam2, 900, true, true)
                        SetCamActive(cam3, true)
                        RenderScriptCams(true, false, 1, true, true)

                        while not IsCamRendering(cam3) do
                            Wait(1)
                        end

                        RenderScriptCams(false, false, 1, true, true)
                        ESX.Game.DeleteVehicle(veh)

                        ESX.Game.SpawnVehicle(v.veicolo, Pos_Vehicle, Pos_Vehicle.h, function(veicolo)
                            ESX.Game.SetVehicleProperties(veicolo, json.decode(v.vehicle))

                            SetVehicleNumberPlateText(veicolo, string.gsub(v.targa, " ", ""))
                            SetPedIntoVehicle(cache.ped, veicolo, -1)
                            TriggerServerEvent("dream_garage:updateFuoriDentro", v.targa, "fuori")
                        end)
                    end
                end,
            }  
        },
    })

    lib.showContext("menu_veicolo")
end)