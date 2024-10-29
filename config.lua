Config = {}

Config.ScratchCardPrice = 4 -- Hinta euroissa
Config.SellBackPrice = 2 -- Palautushinta euroissa

Config.ShopLocation = vector4(24.47, -1347.47, 29.5, 271.66) -- Uusi sijainti lähellä 24/7 kauppaa

Config.ShopPed = {
    model = "a_m_m_business_01",
    scenario = "WORLD_HUMAN_STAND_MOBILE"
}

Config.Blip = {
    sprite = 605,
    color = 46,
    scale = 0.7,
    label = "Neo-Ässä Kioski"
}

Config.CardTypes = {
    assa = {
        name = "Neo-Ässä",
        minPrize = 3,
        maxPrize = 100000,
        chances = {
            {amount = 3, chance = 30},
            {amount = 10, chance = 15},
            {amount = 30, chance = 10},
            {amount = 1000, chance = 1},
            {amount = 100000, chance = 0.1}
        }
    }
}