ESX = exports.es_extended:getSharedObject()

ESX.RegisterCommand("getChiaviAuto", Config.Admin_Groups, function(xPlayer, args, showError)
    local veicolo = GetVehiclePedIsIn(GetPlayerPed(xPlayer.source))

    if not DoesEntityExist(veicolo) then xPlayer.showNotification(IM_Lang.err_no_on_vehicle, "error") return end

    local t = ESX.Math.Trim(GetVehicleNumberPlateText(veicolo))

    exports.ox_inventory:AddItem(xPlayer.source, Config.Item_Chiavi, 1, {
        targa = t,
        description = string.format("Targa: %s", t),
    })

    xPlayer.showNotification(IM_Lang.noti_keys_gave)
end, false, { help = "Prendi le chiavi dell'auto dove ti trovi" })

lib.callback.register("dream_garage:getVeicoliByOwner", function(source)
    local result = MySQL.query.await("SELECT * FROM owned_vehicles WHERE owner = ?", { ESX.GetPlayerFromId(source).identifier })

    return result[1] and result or nil
end)

function checkChiavi(listaTarghe, targa)
    for index, value in ipairs(listaTarghe) do
        if value == targa then
            return true
        end
    end

    return false
end

function TableConcat(t1,t2)
    for i=1,#t2 do
        t1[#t1+1] = t2[i]
    end
    return t1
end

lib.callback.register("dream_garage:getVeicoliGarage", function(source, garage)
    local xPlayer = ESX.GetPlayerFromId(source)
    local chiavi = exports.ox_inventory:Search(xPlayer.source, 1, Config.Item_Chiavi, nil)
    local targhe = {}
    local veicoliCiulati = {}

    for k,v in pairs(chiavi) do
        if not v.metadata then return nil end

        local metadata = v.metadata
        local targa = tostring(metadata.targa)
        table.insert(targhe, targa)

        local veicoli = MySQL.query.await("SELECT * FROM owned_vehicles WHERE plate = ? AND owner != ?", { targa, ESX.GetPlayerFromId(source).identifier })
        if veicoli[1] then
            table.insert(veicoliCiulati, veicoli[1])
        end
    end

    local veicoliTuoi = MySQL.query.await("SELECT * FROM owned_vehicles WHERE owner = ?", { ESX.GetPlayerFromId(source).identifier })
    local result = TableConcat(veicoliTuoi, veicoliCiulati)

    if result[1] then
        local veicoli = {}

        for k,v in ipairs(result) do
            local proprietario = MySQL.query.await("SELECT firstname, lastname FROM users WHERE identifier = ?", { v.owner })
            local haLeChiavi = checkChiavi(targhe, v.plate)

            if proprietario[1] then
                table.insert(veicoli, {
                    targa = v.plate,
                    veicolo = v.veicolo,
                    proprietario = proprietario[1].firstname.." "..proprietario[1].lastname,
                    modello = v.modello,
                    vehicle = v.vehicle,
                    sequestrato = v.sequestrato,            
                    haLeChiavi = haLeChiavi
                })
            end
        end

        while next(veicoli) == nil do Wait(1) end

        return veicoli
    else
        return nil
    end
end)

lib.callback.register("dream_garage:getVeicoliGarageCasa", function(source, garage)
    local xPlayer = ESX.GetPlayerFromId(source)
    local chiavi = exports.ox_inventory:Search(xPlayer.source, 1, Config.Item_Chiavi, nil)
    local result = {}

    for k,v in pairs(chiavi) do
        if not v.metadata then return nil end

        local metadata = v.metadata
        local targa = tostring(metadata.targa)

        local veicoli = MySQL.query.await("SELECT * FROM owned_vehicles WHERE plate = ? AND garageCasa = ?", { targa, garage })

        for _,i in ipairs(veicoli) do
            table.insert(result, i)
        end
    end

    if result[1] then
        local veicoli = {}

        for k,v in ipairs(result) do
            local proprietario = MySQL.query.await("SELECT firstname, lastname FROM users WHERE identifier = ?", { v.owner })

            if proprietario[1] then
                table.insert(veicoli, {
                    targa = v.plate,
                    veicolo = v.veicolo,
                    proprietario = proprietario[1].firstname.." "..proprietario[1].lastname,
                    modello = v.modello,
                    vehicle = v.vehicle,
                    sequestrato = v.sequestrato
                })
            end
        end

        while next(veicoli) == nil do Wait(1) end

        return veicoli
    else
        return nil
    end
end)

lib.callback.register("dream_garage:getVeicoli", function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local chiavi = exports.ox_inventory:Search(xPlayer.source, 1, Config.Item_Chiavi, nil)
    local result = {}

    for k,v in pairs(chiavi) do
        if not v.metadata then return nil end

        local metadata = v.metadata
        local targa = tostring(metadata.targa)

        local veicoli = MySQL.query.await("SELECT * FROM owned_vehicles WHERE plate = ?", { targa })

        for _,i in ipairs(veicoli) do
            table.insert(result, i)
        end
    end

    if result[1] then
        local veicoli = {}

        for k,v in ipairs(result) do
            local proprietario = MySQL.query.await("SELECT firstname, lastname FROM users WHERE identifier = ?", { v.owner })

            if proprietario[1] then
                table.insert(veicoli, {
                    label = v.modello.." - "..v.plate,
                    targa = v.plate,
                    veicolo = v.veicolo,
                    proprietario = proprietario[1].firstname.." "..proprietario[1].lastname,
                    modello = v.modello,
                    vehicle = v.vehicle,
                    garage = v.garage
                })
            end
        end

        while next(veicoli) == nil do Wait(1) end

        return veicoli
    else
        return nil
    end
end)

lib.callback.register("dream_garage:getVeicoliSequestrati", function(source)
    local result = MySQL.query.await("SELECT * FROM owned_vehicles WHERE sequestrato = 1")

    if result[1] then
        local veicoli = {}

        for k,v in ipairs(result) do
            local proprietario = MySQL.query.await("SELECT firstname, lastname FROM users WHERE identifier = ?", { v.owner })

            if proprietario[1] then
                table.insert(veicoli, {
                    targa = v.plate,
                    veicolo = v.veicolo,
                    proprietario = proprietario[1].firstname.." "..proprietario[1].lastname,
                    modello = v.modello,
                    vehicle = v.vehicle
                })
            end
        end

        while next(veicoli) == nil do Wait(1) end

        return veicoli
    else
        return nil
    end
end)

lib.callback.register("dream_garage:checkVeicoloFuori", function(source, targa)
    local result = MySQL.query.await("SELECT fuori FROM owned_vehicles WHERE plate = ?", { targa })

    if result[1] then
        return result[1].fuori == 1 and true or false
    else
        return false
    end
end)

lib.callback.register("dream_garage:canDeposito", function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local chiavi = exports.ox_inventory:Search(xPlayer.source, 1, Config.Item_Chiavi, nil)
    local result = {}

    for k, v in pairs(chiavi) do
        table.insert(result, v)
    end

    for k,v in pairs(result) do
        if v.metadata == nil then return nil end
    end

    return result
end)

RegisterServerEvent("dream_garage:updateDannoVeicoloCasa", function(targa, garage, danno)
    print(string.format("DEPOSITO GARAGE: Veicolo targato %s è stato depositato nel Garage %s", targa, garage))
    SetInGarageCasa(targa, garage, danno)
end)

SetInGarageCasa = function(targa, garage, danno)
    MySQL.update("UPDATE owned_vehicles SET garageCasa = ?, vehicle = ? WHERE plate = ?;", { garage, danno, targa })
end

RegisterServerEvent("dream_garage:updateDannoVeicolo", function(targa, garage, danno)
    print(string.format("DEPOSITO GARAGE: Veicolo targato %s è stato depositato nel Garage %s", targa, garage))
    SetInGarage(targa, garage, danno)
end)

SetInGarage = function(targa, garage, danno)
    MySQL.update("UPDATE owned_vehicles SET garage = ?, vehicle = ? WHERE plate = ?;", { garage, danno, targa }, function()
        local result = MySQL.query.await("SELECT garage FROM owned_vehicles WHERE plate = ?;", { targa })

        if result[1].garage == 0 then SetInGarage(targa, garage, danno) return end
    end)
end

RegisterServerEvent("dream_garage:updateFuoriDentro", function(targa, s)
    MySQL.update("UPDATE owned_vehicles SET fuori = ? WHERE plate = ?", { s == "fuori" and true or false, targa })       
end)

RegisterServerEvent("dream_garage:updateSequestro", function(targa, s)
    MySQL.update("UPDATE owned_vehicles SET sequestrato = ? WHERE plate = ?", { s and 1 or 0, targa })
    MySQL.update("UPDATE owned_vehicles SET fuori = ? WHERE plate = ?", { false, targa })  
end)


-- Registra il comando per accedere al recupero delle chiavi aziendali
RegisterCommand('chiaviAziendali', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local job = xPlayer.getJob()

    -- Controlla se il giocatore è un "boss"
    if job.grade_name == "boss" then
        local jobName = job.name

        -- Query al database per ottenere i veicoli aziendali
        MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE owner = @job', {
            ['@job'] = jobName
        }, function(result)
            if result and #result > 0 then
                local vehicles = {}

                -- Costruisci una lista di veicoli aziendali
                for i = 1, #result, 1 do
                    table.insert(vehicles, {
                        modello = result[i].modello,
                        plate = result[i].plate
                    })
                end

                -- Invia la lista dei veicoli al client e mostra il menu
                TriggerClientEvent('dream_garage:openVehicleMenu', source, vehicles)
            else
                xPlayer.showNotification("Nessun veicolo aziendale trovato.")
            end
        end)
    else
        xPlayer.showNotification("Non hai i permessi per accedere alle chiavi aziendali.")
    end
end)

-- Evento per consegnare le chiavi al giocatore
RegisterNetEvent('dream_garage:giveVehicleKey')
AddEventHandler('dream_garage:giveVehicleKey', function(vehiclePlate, vehicleModel)
    local xPlayer = ESX.GetPlayerFromId(source)

    -- Crea i metadati con la targa e la descrizione (modello e targa)
    local metadata = {
        plate = vehiclePlate,
        description = vehicleModel .. " [" .. vehiclePlate .. "]"  -- Assicura che il modello sia incluso qui
    }

    -- Aggiungi l'item chiave all'inventario del giocatore con i metadati corretti
    xPlayer.addInventoryItem('vehicle_key', 1, metadata)

    -- Notifica il giocatore
    xPlayer.showNotification("Hai ricevuto la chiave del veicolo " .. vehicleModel .. " [" .. vehiclePlate .. "]")
end)
