local Translations = {
    info = {
        scratch_card = "Neo-Ässä Raaputusarpa",
        no_card = "Sinulla ei ole arpaa!",
        card_bought = "Ostit Neo-Ässä arvan!",
        card_sold = "Myit arvan takaisin!",
        not_enough_money = "Sinulla ei ole tarpeeksi rahaa!",
        scratch_instruction = "Raaputa paljastaaksesi voittosummat!",
        congratulations = "Onneksi olkoon!",
        jackpot_win = "ONNEKSI OLKOON! Voitit"
    }
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})