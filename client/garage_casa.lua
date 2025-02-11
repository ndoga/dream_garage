ESX = exports.es_extended:getSharedObject()

RegisterNetEvent("dream_garage:openGarageCasa", function(casa, garage)
    OpenGarageCasa(casa, garage)
end)

OpenGarageCasa = function(casa, garage)
    lib.callback("dream_garage:getVeicoliGarageCasa", GetPlayerServerId(PlayerId()), function(veicoli)
        if veicoli then
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
    
                local disabilitato = false
    
                if veicolofuori or v.sequestato then disabilitato = true end

                table.insert(elementi, {
                    title = v.modello.." - "..v.targa,
                    description = v.sequestrato == 1 and "Proprietario: "..v.proprietario.."\nVeicolo Sequestrato" or "Proprietario: "..v.proprietario,
                    arrow = v.sequestato == 0 and true or false,
                    disabled = disabilitato,
                    event = "dream_garage:menuVeicoloCasa",
                    args = { v = v, garage = garage }
                })
            end

            lib.registerContext({
                id = "menu_garage_casa",
                title = "Garage Casa",
                options = elementi,
            })
    
            lib.showContext("menu_garage_casa")
        else
            ESX.ShowNotification(IM_Lang.err_no_vehicle, "error")
        end
    end, casa)
end

RegisterNetEvent("dream_garage:menuVeicoloCasa", function(args)
    local v = args.v
    local Garage = args.garage
    
    lib.registerContext({
        id = "menu_veicolo_casa",
        title = "Garage Casa",
        menu = "menu_garage_casa",
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
                        ESX.ShowNotification(IM_Lang.err_vehicle_out, 'error')
                        TriggerServerEvent("dream_garage:updateFuoriDentro", v.targa, "fuori")
                    else
                        ESX.Game.SpawnVehicle(v.veicolo, Garage, Garage.h, function(veicolo)
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

    lib.showContext("menu_veicolo_casa")
end)