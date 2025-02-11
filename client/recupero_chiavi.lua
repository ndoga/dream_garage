ESX = exports.es_extended:getSharedObject()

OpenRecuperoChiavi = function(id)
    lib.callback("dream_garage:getVeicoliByOwner", GetPlayerServerId(PlayerId()), function(veicoli)
        if veicoli then
            local Recupero = Config.Recupero_Chiavi[id]

            local elementi = {}

            for k,v in pairs(veicoli) do
                table.insert(elementi, {
                    title = v.modello.." - "..v.plate,
                    onSelect = function()
                        if not CheckItemChiavi(v.plate) then
                            exports.dream_pagamento:CheckPagamento(function(bool, CodiceConto)
                                if bool then
                                    exports.dream_pagamento:Paga(CodiceConto, Config.Prezzo_Recupero_Chiavi, "Recupero chiavi "..v.plate, nil, function(check)
                                        if check then
                                            TriggerServerEvent("dream_garage:giveVehicleKey", v.plate)
                                            ESX.ShowNotification(string.format(IM_Lang.noti_keys_buyed, v.plate))
                                        end
                                    end)
                                end
                            end)            
                        else
                            ESX.ShowNotification(IM_Lang.err_keys_already_buyed, "error")
                        end
                    end
                })
            end

            while next(elementi) == nil do Wait(1) end

            lib.registerContext({
                id = "menu_recupero",
                title = Recupero.Label,
                options = elementi
            })

            lib.showContext("menu_recupero")
        else
            ESX.ShowNotification(IM_Lang.err_no_vehicle_found, "error")
        end
    end)
end

RegisterNetEvent('dream_garage:openVehicleMenu')
AddEventHandler('dream_garage:openVehicleMenu', function(vehicles)
    local elements = {}

    -- Costruisci il menu con i veicoli
    for i = 1, #vehicles, 1 do
        table.insert(elements, {
            label = vehicles[i].modello .. " - " .. vehicles[i].plate,
            value = vehicles[i]
        })
    end

    -- Apri il menu
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_keys_menu', {
        title    = "Chiavi Veicoli Aziendali",
        align    = 'top-right',
        elements = elements
    }, function(data, menu)
        local selectedVehicle = data.current.value

        -- Invia l'evento al server per dare le chiavi del veicolo selezionato
        TriggerServerEvent('dream_garage:giveVehicleKey', selectedVehicle.plate, selectedVehicle.modello)

        menu.close()
    end, function(data, menu)
        menu.close()
    end)
end)

-- Evento per ricevere la chiave
-- RegisterNetEvent('dream_garage:giveVehicleKey')
-- AddEventHandler('dream_garage:giveVehicleKey', function(vehiclePlate, vehicleModel)
--     -- Notifica al giocatore
--     ESX.ShowNotification("Hai ricevuto la chiave del veicolo " .. vehicleModel .. " [" .. vehiclePlate .. "]")
-- end)
