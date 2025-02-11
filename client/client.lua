ESX = exports.es_extended:getSharedObject()

CreateThread(function()
    for k,v in ipairs(Config.Garages) do
        local hash_garage = GetHashKey(Config.Ped_Garage)

        RequestModel(hash_garage)
    
        while not HasModelLoaded(hash_garage) do Wait(1) end

        local garage = v.Pos.Garage
        local ped_garage = CreatePed(Config.Ped_Garage, hash_garage, garage.x, garage.y, garage.z-1.0, garage.h, false, true)

        FreezeEntityPosition(ped_garage, true)
        SetEntityInvincible(ped_garage, true)
        SetBlockingOfNonTemporaryEvents(ped_garage, true)

        exports.ox_target:addLocalEntity(ped_garage, {
            {
                label = "Accedi al Garage",
                name = "accedi_garage",
                icon = "fas fa-car",
                onSelect = function()
                    OpenGarage(k)
                end
            }
        })

        lib.zones.box({
            coords = vector3(v.Pos.Vehicle.x, v.Pos.Vehicle.y, v.Pos.Vehicle.z),
            size = vector3(5.0, 5.0, 5.0),
            rotation = 1.0,
            onEnter = function()
                if IsPedInAnyVehicle(cache.ped, false) then
                    ESX.ShowHelpNotification(IM_Lang.help_deposito)
                    inZone = k
                end
            end,
            onExit = function()
                ESX.Chiudi()
                inZone = false
            end
        })

        if v.Blip.Attivo then
            local b = v.Blip

            local blip = AddBlipForCoord(garage.x, garage.y, garage.z)

            SetBlipSprite(blip, b.Sprite)
            SetBlipDisplay(blip, 4)
            SetBlipScale (blip, b.Grandezza)
            SetBlipColour(blip, b.Colore)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(v.Label)
            EndTextCommandSetBlipName(blip)
        end
    end
end)

CreateThread(function()
    for k,v in ipairs(Config.Pounds) do
        local hash_pound = GetHashKey(Config.Ped_Pound)

        RequestModel(hash_pound)

        while not HasModelLoaded(hash_pound) do Wait(1) end

        local pound = v.Pos.Impound
        local ped_pound = CreatePed(Config.Ped_Pound, hash_pound, pound.x, pound.y, pound.z-1.0, pound.h, false, true)

        FreezeEntityPosition(ped_pound, true)
        SetEntityInvincible(ped_pound, true)
        SetBlockingOfNonTemporaryEvents(ped_pound, true)

        exports.ox_target:addLocalEntity(ped_pound, {
            {
                label = "Accedi al Dissequestro",
                name = "accedi_dissequestro",
                icon = "fas fa-car",
                groups = v.Job,
                onSelect = function()
                    OpenDissequestro(k)
                end
            }
        })

        if v.Blip.Attivo then
            local b = v.Blip

            local blip = AddBlipForCoord(pound.x, pound.y, pound.z)

            SetBlipSprite(blip, b.Sprite)
            SetBlipDisplay(blip, 4)
            SetBlipScale (blip, b.Grandezza)
            SetBlipColour(blip, b.Colore)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(v.Label)
            EndTextCommandSetBlipName(blip)
        end
    end

    exports.ox_target:addGlobalVehicle({
        {
            label = "Sequestra Veicolo",
            name = "sequestra",
            icon = "fas fa-car-side",
            groups = Config.FdO,
            distance = 2.0,
            onSelect = function(data)
                local targa = ESX.Math.Trim(GetVehicleNumberPlateText(data.entity))

                Sequestra(data.entity, targa)
            end
        }
    })
end)

CreateThread(function()
    for k,v in ipairs(Config.Recupero_Chiavi) do
        local hash_recupero = GetHashKey(Config.Ped_Recupero_Chiavi)

        RequestModel(hash_recupero)

        while not HasModelLoaded(hash_recupero) do Wait(1) end

        local recupero = v.Pos
        local ped_recupero = CreatePed(Config.Ped_Recupero_Chiavi, hash_recupero, recupero.x, recupero.y, recupero.z-1.0, recupero.h, false, true)

        FreezeEntityPosition(ped_recupero, true)
        SetEntityInvincible(ped_recupero, true)
        SetBlockingOfNonTemporaryEvents(ped_recupero, true)

        exports.ox_target:addLocalEntity(ped_recupero, {
            {
                label = "Accedi al Recupero Chiavi",
                name = "accedi_recupero",
                icon = "fas fa-key",
                onSelect = function()
                    OpenRecuperoChiavi(k)
                end
            }
        })

        if v.Blip.Attivo then
            local b = v.Blip

            local blip = AddBlipForCoord(recupero.x, recupero.y, recupero.z)

            SetBlipSprite(blip, b.Sprite)
            SetBlipDisplay(blip, 4)
            SetBlipScale (blip, b.Grandezza)
            SetBlipColour(blip, b.Colore)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(v.Label)
            EndTextCommandSetBlipName(blip)
        end
    end
end)