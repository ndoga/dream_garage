ESX = exports.es_extended:getSharedObject()

ESX.RegisterUsableItem(Config.Item_Chiavi, function(source, icimin, i)
    local xPlayer = ESX.GetPlayerFromId(source)

    TriggerClientEvent("dream_garage:apriVeicolo", xPlayer.source, i.metadata.targa)
end)

-- RegisterServerEvent("dream_garage:giveVehicleKey", function(targa)
--     local xPlayer = ESX.GetPlayerFromId(source)
--     local t = ESX.Math.Trim(targa)
--     -- local result = MySQL.query.await("SELECT * FROM owned_vehicles WHERE plate = ?", { t })

--     -- if not result[1] then return end

--     exports.ox_inventory:AddItem(xPlayer.source, Config.Item_Chiavi, 1, {
--         targa = t,
--         description = string.format("Targa: %s", t),
--     })
-- end)

RegisterServerEvent("dream_garage:giveVehicleKey", function(targa)
    local xPlayer = ESX.GetPlayerFromId(source)
    local t = ESX.Math.Trim(targa)

    -- Ottieni i dati del veicolo dal database
    local result = MySQL.query.await("SELECT * FROM owned_vehicles WHERE plate = ?", { t })

    -- Verifica se il veicolo esiste
    if not result[1] then
        xPlayer.showNotification("Veicolo non trovato.")
        return
    end

    -- Ottieni il modello del veicolo dalla query
    local vehicleModel = result[1].modello or "Modello sconosciuto"

    -- Aggiungi l'item chiave all'inventario con i metadati (targa e modello)
    exports.ox_inventory:AddItem(xPlayer.source, Config.Item_Chiavi, 1, {
        targa = t,
        description = string.format("Modello: %s \n Targa: %s", vehicleModel, t),  -- Metadata item

    })

    -- Notifica il giocatore che ha ricevuto la chiave
    xPlayer.showNotification(string.format("Hai ricevuto la chiave per il veicolo %s [%s]", vehicleModel, t))
end)


lib.callback.register("dream_garage:checkItem", function(source)
    return ESX.GetPlayerFromId(source).getInventoryItem(Config.Item_Chiavi).count >= 1
end)

CheckAdmin = function(xPlayer)
    for k,v in ipairs(Config.Admin_Groups) do
        if xPlayer.group == v then return true end
    end
end