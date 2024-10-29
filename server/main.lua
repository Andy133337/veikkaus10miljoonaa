local QBCore = exports['qb-core']:GetCoreObject()

-- Aktiiviset arvat ja niiden voitot
local activeCards = {}

-- Rekisteröi arpa käytettäväksi esineeksi
QBCore.Functions.CreateUsableItem("scratch_card", function(source)
    local src = source
    TriggerClientEvent('qb-scratchcard:client:useScratchCard', src)
end)

-- Generoi sarjanumero
local function GenerateSerial()
    local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local serial = "AS"
    for i = 1, 8 do
        local rand = math.random(1, #chars)
        serial = serial .. string.sub(chars, rand, rand)
    end
    return serial
end

-- Generoi uniikki tunniste arvalle
local function GenerateCardId()
    return tostring(os.time()) .. tostring(math.random(1000, 9999))
end

-- Laske voitto palvelimella
local function CalculateWin()
    local random = math.random(1, 1000) / 10 -- 0.1-100.0
    local currentChance = 0
    
    for _, prize in ipairs(Config.CardTypes.assa.chances) do
        currentChance = currentChance + prize.chance
        if random <= currentChance then
            return prize.amount
        end
    end
    
    return Config.CardTypes.assa.minPrize
end

-- Arvan luonti
RegisterNetEvent('qb-scratchcard:server:createCard', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if Player then
        -- Tarkista onko pelaajalla arpa
        if Player.Functions.RemoveItem('scratch_card', 1) then
            local cardId = GenerateCardId()
            local winAmount = CalculateWin()
            local serial = GenerateSerial()
            
            -- Tallenna arvan tiedot
            activeCards[cardId] = {
                player = src,
                winAmount = winAmount,
                serial = serial,
                used = false,
                created = os.time()
            }
            
            -- Lähetä arvan tiedot clientille
            TriggerClientEvent('qb-scratchcard:client:receiveCard', src, cardId, winAmount, serial)
        else
            TriggerClientEvent('QBCore:Notify', src, 'Sinulla ei ole arpaa!', 'error')
        end
    end
end)

-- Voiton lunastus
RegisterNetEvent('qb-scratchcard:server:claimPrize', function(cardId, clientWinAmount, clientSerial)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    -- Tarkista arvan oikeellisuus
    local card = activeCards[cardId]
    if not card or card.used or card.player ~= src then
        return
    end
    
    -- Tarkista että voittosumma ja sarjanumero täsmäävät
    if card.winAmount ~= clientWinAmount or card.serial ~= clientSerial then
        return
    end
    
    -- Merkitse arpa käytetyksi
    card.used = true
    
    -- Lisää voittorahat
    Player.Functions.AddMoney('cash', card.winAmount)
    
    if card.winAmount >= 1000 then
        TriggerClientEvent('QBCore:Notify', src, 'ONNEKSI OLKOON! Voitit ' .. card.winAmount .. '€!', 'success')
        -- Ilmoita kaikille isosta voitosta
        TriggerClientEvent('chat:addMessage', -1, {
            template = '<div class="chat-message-jackpot"><b>NEO-ÄSSÄ:</b> {0}</div>',
            args = { 'Joku onnekas voitti juuri ' .. card.winAmount .. '€!' }
        })
    else
        TriggerClientEvent('QBCore:Notify', src, 'Onneksi olkoon! Voitit ' .. card.winAmount .. '€!', 'success')
    end
    
    -- Poista arpa aktiivisista arvoista
    activeCards[cardId] = nil
end)