ESX = exports.es_extended:getSharedObject()

RegisterNetEvent("dream_garage:menuGestioneVeicoli", function()
    lib.callback("dream_garage:getVeicoli", GetPlayerServerId(PlayerId()), function(veicoli)
        if veicoli then
            local elements = {}

            for k,v in ipairs(veicoli) do
                table.insert(elements, {
                    title = v.label,
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

                        if not veicolofuori then
                            local pos = Config.Garages[v.garage].Pos.Garage

                            SetNewWaypoint(pos.x, pos.y)
                            ESX.ShowNotification(IM_Lang.noti_pos_vehicle)
                        else
                            for _, vec in pairs(ESX.Game.GetVehicles()) do
                                if ESX.Math.Trim(GetVehicleNumberPlateText(vec)) == ESX.Math.Trim(v.targa) or ESX.Game.GetVehicleProperties(vec).plate == ESX.Math.Trim(v.targa) then
                                    if DoesEntityExist(vec) then
                                        ESX.ShowNotification("Il veicolo non si trova in alcun garage")
                                    else
                                        local pos = Config.Garages[v.garage].Pos.Garage

                                        SetNewWaypoint(pos.x, pos.y)
                                        ESX.ShowNotification(IM_Lang.noti_pos_vehicle)
                                    end
                                end
                            end
                        end
                    end
                })
            end

            while #elements < #veicoli do Wait(1) end

            lib.registerContext({
                id = "menu_gestione_veicoli",
                title = IM_Lang.vm_title,
                options = elements,
            })
    
            lib.showContext("menu_gestione_veicoli")
        else
            ESX.ShowNotification(IM_Lang.err_no_vehicle_found, "error")
        end
    end)
end)