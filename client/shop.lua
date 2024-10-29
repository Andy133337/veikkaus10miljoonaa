local QBCore = exports['qb-core']:GetCoreObject()
local ped = nil
local blip = nil

-- Luo myyjä-NPC
local function CreateShopPed()
    RequestModel(GetHashKey(Config.ShopPed.model))
    while not HasModelLoaded(GetHashKey(Config.ShopPed.model)) do
        Wait(1)
    end

    ped = CreatePed(4, GetHashKey(Config.ShopPed.model), Config.ShopLocation.x, Config.ShopLocation.y, Config.ShopLocation.z - 1, Config.ShopLocation.w, false, true)
    SetEntityHeading(ped, Config.ShopLocation.w)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)

    if Config.ShopPed.scenario then
        TaskStartScenarioInPlace(ped, Config.ShopPed.scenario, 0, true)
    end
end

-- Luo blippi kartalle
local function CreateShopBlip()
    blip = AddBlipForCoord(Config.ShopLocation.x, Config.ShopLocation.y, Config.ShopLocation.z)
    SetBlipSprite(blip, Config.Blip.sprite)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, Config.Blip.scale)
    SetBlipColour(blip, Config.Blip.color)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.Blip.label)
    EndTextCommandSetBlipName(blip)
end

-- Avaa kaupan UI
local function OpenShopUI()
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "openShop"
    })
end

-- NUI Callbacks
RegisterNUICallback('buyCard', function(data, cb)
    TriggerServerEvent('qb-scratchcard:server:buyCard')
    cb('ok')
end)

RegisterNUICallback('sellCard', function(data, cb)
    TriggerServerEvent('qb-scratchcard:server:sellCard')
    cb('ok')
end)

RegisterNUICallback('closeShop', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

-- Tarkista etäisyys myyjään
CreateThread(function()
    CreateShopPed()
    CreateShopBlip()
    
    while true do
        local sleep = 1000
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)
        local dist = #(coords - vector3(Config.ShopLocation.x, Config.ShopLocation.y, Config.ShopLocation.z))
        
        if dist < 3.0 then
            sleep = 0
            DrawText3D(Config.ShopLocation.x, Config.ShopLocation.y, Config.ShopLocation.z + 1.0, "[E] Neo-Ässä Kioski")
            
            if dist < 2.0 and IsControlJustReleased(0, 38) then -- E näppäin
                OpenShopUI()
            end
        end
        
        Wait(sleep)
    end
end)

-- 3D tekstin piirto
function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)
    local factor = (string.len(text)) / 370
    DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 41, 11, 41, 68)
end