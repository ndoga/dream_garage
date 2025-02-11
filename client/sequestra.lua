ESX = exports.es_extended:getSharedObject()

local cam
local cam2
local cam3
local veh_sequestro = nil

OpenDissequestro = function(id)
    lib.callback("dream_garage:getVeicoliSequestrati", GetPlayerServerId(PlayerId()), function(veicoli)
        if veicoli then
            local Dissequestro = Config.Pounds[id]
            local pos = GetEntityCoords(cache.ped)
            local pos_cam = Dissequestro.Pos.Cam

            cam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', pos.x, pos.y, pos.z, 0.0, 0.0, 0.0, 50.0, false)
            PointCamAtCoord(cam, pos.x, pos.y, pos.z)
            SetCamActiveWithInterp(cam2, cam, 900, true, true)
            cam2 = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', pos_cam.x, pos_cam.y, pos_cam.z, pos_cam.rx, pos_cam.ry, pos_cam.rz, 70.0, false)
            PointCamAtCoord(cam, pos.x, pos.y, pos.z)
            SetCamActiveWithInterp(cam2, cam, 900, true, true)
            SetCamActive(cam2, true)
            RenderScriptCams(true, false, 1, true, true)

            local elementi = {}
            
            for k,v in pairs(veicoli) do
                table.insert(elementi, {
                    title = v.modello.." - "..v.targa,
                    description = "Propietario: "..v.proprietario,
                    arrow = true,
                    event = "dream_garage:menuVeicoloSequestrato",
                    args = { v = v, Dissequestro = Dissequestro }
                })
            end

            lib.registerContext({
                id = "menu_sequestro",
                title = Dissequestro.Label,
                onExit = function()
                    RenderScriptCams(false, false, 1, true, true)
                end,
                options = elementi,
            })

            lib.showContext("menu_sequestro")
        else
            ESX.ShowNotification(IM_Lang.err_no_vehicle_impound, "error")
        end
    end)
end

RegisterNetEvent("dream_garage:menuVeicoloSequestrato", function(args)
    local Dissequestro = args.Dissequestro
    local v = args.v
    local pos_vehicle = Dissequestro.Pos.Vehicle

    if ESX.Game.IsSpawnPointClear(pos_vehicle, 3.0) then
        CaricaModello(v.veicolo)
        ESX.Game.SpawnLocalVehicle(v.veicolo, pos_vehicle, pos_vehicle.h, function(veicolo)
            veh_sequestro = veicolo
            ESX.Game.SetVehicleProperties(veicolo, json.decode(v.vehicle))
        end)
    else
        ESX.ShowNotification(IM_Lang.err_spawn_blocked, "error")
    end
    
    lib.registerContext({
        id = "menu_veicolo_sequestrato",
        title = Dissequestro.Label,
        menu = "menu_sequestro",
        onExit = function()
            RenderScriptCams(false, false, 1, true, true)
            ESX.Game.DeleteVehicle(veh_sequestro)
        end,
        onBack = function()
            ESX.Game.DeleteVehicle(veh_sequestro)
            veh_sequestro = nil
        end,
        options = {
            {
                title = "Recupera veicolo",
                onSelect = function()
                    local pos_cam = Dissequestro.Pos.Cam
                    local pos = GetEntityCoords(cache.ped)

                    cam3 = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', pos_vehicle.x, pos_vehicle.y, pos_vehicle.z, pos_cam.rx, pos_cam.ry, pos_cam.rz, 100.0, false)
                    PointCamAtCoord(cam2, pos.x, pos.y, pos.z)
                    SetCamActiveWithInterp(cam3, cam2, 900, true, true)
                    SetCamActive(cam3, true)
                    RenderScriptCams(true, false, 1, true, true)

                    while not IsCamRendering(cam3) do Wait(1) end

                    RenderScriptCams(false, false, 1, true, true)
                    ESX.Game.DeleteVehicle(veh_sequestro)
                    ESX.Game.SpawnVehicle(v.veicolo, pos_vehicle, pos_vehicle.h, function(veicolo)
                        ESX.Game.SetVehicleProperties(veicolo, json.decode(v.vehicle))
                        SetPedIntoVehicle(cache.ped, veicolo, -1)
                    end)

                    TriggerServerEvent("dream_garage:updateSequestro", v.targa, false)
                end,
            },   
        },
    })

    lib.showContext("menu_veicolo_sequestrato")
end)

Sequestra = function(entity, targa)
    local input = lib.inputDialog("Sequestro di un Veicolo", {
        { type = "input", label = "Targa", description = "Numero di targa del veicolo da sequestrare", default = targa, disabled = true },
    })

    if not input then return end

    ESX.Game.DeleteVehicle(entity)
    TriggerServerEvent("dream_garage:updateSequestro", targa, true)
    ESX.ShowNotification(IM_Lang.noti_vehicle_pounded, "success")
end