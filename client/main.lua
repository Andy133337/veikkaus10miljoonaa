local QBCore = exports['qb-core']:GetCoreObject()
local currentCard = nil

-- Arvan käyttö
RegisterNetEvent('qb-scratchcard:client:useScratchCard', function()
    if not currentCard then
        TriggerServerEvent('qb-scratchcard:server:createCard')
    end
end)

-- Vastaanota arvan tiedot palvelimelta
RegisterNetEvent('qb-scratchcard:client:receiveCard', function(cardId, winAmount, serial)
    if not currentCard then
        currentCard = {
            id = cardId,
            winAmount = winAmount,
            serial = serial
        }
        
        SetNuiFocus(true, true)
        SendNUIMessage({
            action = "openScratchCard",
            winAmount = winAmount,
            serial = serial
        })
        
        TriggerEvent('QBCore:Notify', 'Raaputa paljastaaksesi voittosummat!', 'primary')
    end
end)

-- NUI Callbacks
RegisterNUICallback('closeScratchCard', function()
    SetNuiFocus(false, false)
    currentCard = nil
end)

RegisterNUICallback('claimPrize', function(data)
    if currentCard and data.winAmount == currentCard.winAmount and data.serial == currentCard.serial then
        TriggerServerEvent('qb-scratchcard:server:claimPrize', currentCard.id, data.winAmount, data.serial)
    end
end)