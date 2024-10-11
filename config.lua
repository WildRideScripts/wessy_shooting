
Config = {}

Config.messageDict = "pm_awards_mp"
Config.messageIcon = "awards_set_a_013"
Config.DrawCircleDistance = 50
Config.StartWaitTime = 5
Config.ShowResultPlayerRange = 25.0

Config.shootingLocations = {
    ["armadillo"] = { 
        startCoord = { x = -3671.54, y = -2586.83, z = -14.73 },
        scoreBoard = { x = -3671.70, y = -2575.11, z = -10.94 },
        showBlip = true,
        blipSprite = 639638961,
        blipLabel = "Schießstand",
        items = {
            { hash = "p_jug01x", x = -3674.34326171875, y = -2575.642333984375, z = -13.78217601776123, h = 13.99999904632568 }, --s_drinkshootmg05x
            { hash = "p_bottlebrandy01x", x = -3673.49462890625, y = -2575.18408203125, z = -13.65089797973632, h = 12.68623733520507 },
            { hash = "s_drinkshootmg01x", x = -3672.945068359375, y = -2575.206298828125, z = -13.63105201721191, h = -48.99140930175781 },
            { hash = "s_drinkshootmg02x", x = -3672.425537109375, y = -2575.218017578125, z = -13.6507978439331, h = -28.33608245849609 },
            { hash = "p_bottlecognac01x", x = -3671.03125, y = -2575.534423828125, z = -13.76169395446777, h = -2.07417273521423 },
            { hash = "p_jug01x", x = -3670.728759765625, y = -2575.24560546875, z = -13.72185039520263, h = 8.31044483184814 },
            { hash = "p_bottle013x", x = -3670.449462890625, y = -2575.60205078125, z = -13.76916027069091, h = -64.31726837158203 },
            { hash = "p_jug01x", x = -3669.109619140625, y = -2575.642578125, z = -13.94117069244384, h = -9.32440185546875 },
            { hash = "p_bottlechampagne01x", x = -3670.118896484375, y = -2576.96435546875, z = -14.37495613098144, h = -5.00410509109497 },
        },
        itemSpawnAmount = 6,
    },
}

Config.Language = {
    areaTitle = "Probiere es nochmal",
    areaDesc = "Du hast die Area verlassen!",
    cheaterTitle = "Probiere es nochmal",
    cheaterDesc = "Da hat wohl jemand einen schnelleren Finger als du!",
    startprompt = "Shooting Arena starten mit [LEERTASTE]",
    scoreTitle = "Shooting Arena",
    scoreDesc = "Lucky Luke wäre Neidisch! \nDeine Wertung: ~e~",
    scoreDesc2 = "s~q~ (",
    scoreDesc3 = " Ziele)",
    startTitle = "Shooting Arena",
    startDesc = "Mach dich Bereit! In 5 Sekunden geht es los...",
}