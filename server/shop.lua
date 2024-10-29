local QBCore = exports['qb-core']:GetCoreObject()

-- Osta arpa
RegisterNetEvent('qb-scratchcard:server:buyCard', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    -- Tarkista onko pelaajalla varaa
    if Player.Functions.GetMoney('cash') >= Config.ScratchCardPrice then
        -- Veloita raha
        if Player.Functions.RemoveMoney('cash', Config.ScratchCardPrice, "scratch-card-purchase") then
            -- Anna arpa
            Player.Functions.AddItem('scratch_card', 1)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['scratch_card'], "add")
            TriggerClientEvent('QBCore:Notify', src, 'Ostit Neo-Ässä arvan!', 'success')
        end
    else
        TriggerClientEvent('QBCore:Notify', src, 'Sinulla ei ole tarpeeksi rahaa!', 'error')
    end
end)

-- Myy arpa takaisin
RegisterNetEvent('qb-scratchcard:server:sellCard', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    -- Tarkista onko pelaajalla arpa
    if Player.Functions.GetItemByName('scratch_card') then
        -- Poista arpa
        if Player.Functions.RemoveItem('scratch_card', 1) then
            -- Anna palautusraha
            Player.Functions.AddMoney('cash', Config.SellBackPrice, "scratch-card-sellback")
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['scratch_card'], "remove")
            TriggerClientEvent('QBCore:Notify', src, 'Myit arvan takaisin ' .. Config.SellBackPrice .. '€!', 'success')
        end
    else
        TriggerClientEvent('QBCore:Notify', src, 'Sinulla ei ole arpaa myytäväksi!', 'error')
    end
end)