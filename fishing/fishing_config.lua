Fishing_Config = {}
Fishing_Config.Core = exports['qb-core']:GetCoreObject() --can change the 'qb-core' here if you changed the script name else leave it alone
---Select ONE of the 3 methods below for interacting with the AI
Fishing_Config.UseTarget = true --if you want to use qb-target to interact with the AI
Fishing_Config.useDrawText = false --if you want to use draw text to interact with the AI
Fishing_Config.UseQBMenu = false --if you want to use ab-menu to interact with the AI

Fishing_Config.qbtargetScriptName = "qb-target" --new script name here if you changed qb-target name else leave it alone

Fishing_Config.debug = false --you can ignore this. just a tool for me to help out people who have issues

-- variables for all the text in the script. translate to whatever you like
Fishing_Config.locale = {

  --lua
  ["cant_now"] = "You cant do that now",
  ["aim_to_water"] = "Aim toward the water!",
  ["cant_fish"] = "Can't fish here",
  ["got_away"] = "The fish got away",
  ["money_add"] = "you recieved $", --this will have the amount stringed to it. "you recieved $1000"
  ["nothing_sell"] = "Nothing To Sell",
  ['draw_text_sell'] = "[E] Sell Fish", --only used if you have useDrawText = true
  ["cutting_bait"] = "Cutting Bait...",
  ["cancel_bait"] = "Cutting Bait Has Been Canceled!",
  ['set_bait'] = "Setting New Bait",

  --js
  ["hook"] = "HOOK!",
  ["success"] = "SUCCESS",
  ["got_away2"] = "GOT AWAY",
  ["fail"] = "FAIL",
  ["fish_on"] = "FISH ON!",
  ["too_soon"] = "TOO EARLY!",

  --qb-target ignore if not using qb-target
  ['sell_fish_legal'] = "Sell Fish",
  ['sell_fish_illegal'] = "Sell illegal Fish"
}

Fishing_Config.difficulty = {
    ['easy'] = {                                 --*I would probably not touch these, or save the original values if you do*
        tensionIncrease =  {min = 35, max = 40}, --speed of tension increase. lower = harder
        tensionDecrease =  {min = 50, max = 55}, --speed of tension decrease. lower = easier
        progressIncrease = {min = 1,  max = 8},  --speed of percent increase. lower = easier
        progressDecrease = {min = 50, max = 55}, --speed of percent decrease. lower = harder
    },
    ['medium'] = {
        tensionIncrease =  {min = 30, max = 35},
        tensionDecrease =  {min = 55, max = 60},
        progressIncrease = {min = 5,  max = 13},
        progressDecrease = {min = 45, max = 50},
    },
    ['hard'] = {
        tensionIncrease =  {min = 25, max = 30},
        tensionDecrease =  {min = 60, max = 65},
        progressIncrease = {min = 8,  max = 17},
        progressDecrease = {min = 40, max = 45},
    },
}

Fishing_Config.BaitTypes = { --list your bait types here. it is possible to create your own bait types if you want, you just need to go and create the item for it as well. these should be the item spawn name of the bait.
    "none",
    "legalbait",
    "illegalbait"
}

Fishing_Config.IllegalBaitTypes = { --put whatever bait types you have that are considered illegal here. when someone uses one of these bait types it will have a chance of calling the police
    ["illegalbait"] = true,
}

Fishing_Config.PoliceNotifChance = 10 --% chance out of 100 to call police when using illegal bait

RegisterNetEvent("NW_Fishing:AlertPolice", function()
    --add police notification here for illegal fishing if you want
end)

Fishing_Config.ValidBaitTypesForZone = { --this will set which baits can be used in which zones. make sure if you set a bait type to true here you make a loot table for that bait type in the correct zone in the Config.FishTable Below               
    ['alamo'] = {                --always include ["none"] = true for all zones.
        ["none"] = true, 
        ["legalbait"] = true,
        ["illegalbait"] = false
    },
    ['ocean'] = { 
        ["none"] = true, 
        ["legalbait"] = true, 
        ["illegalbait"] = true
    },
    ['river'] = { 
        ["none"] = true, 
        ["legalbait"] = true,
        ["illegalbait"] = false
    },
}

Fishing_Config.FishTable = {
    ['sea'] = {
        [1] = {["name"] = "swordfish",      ["prop"] = "a_c_fish",                      ["ped"] = true, ["diff"] = "easy",     ["chance"] = 5,     ["trash"] = false},
        [2] = {["name"] = "tunafish",       ["prop"] = "a_c_fish",                      ["ped"] = true, ["diff"] = "easy",     ["chance"] = 5,     ["trash"] = false},
        [3] = {["name"] = "mahifish",       ["prop"] = "a_c_fish",                      ["ped"] = true, ["diff"] = "easy",     ["chance"] = 5,     ["trash"] = false},
        [4] = {["name"] = "halibut",        ["prop"] = "a_c_fish",                      ["ped"] = true, ["diff"] = "medium",   ["chance"] = 7,     ["trash"] = false},
        [5] = {["name"] = "redfish",        ["prop"] = "a_c_fish",                      ["ped"] = true, ["diff"] = "medium",   ["chance"] = 7,     ["trash"] = false},
        [6] = {["name"] = "bluefish",       ["prop"] = "a_c_fish",                      ["ped"] = true, ["diff"] = "medium",   ["chance"] = 7,     ["trash"] = false},
        [7] = {["name"] = "seaturtle",      ["prop"] = "a_c_fish",                      ["ped"] = true, ["diff"] = "hard",     ["chance"] = 2,     ["trash"] = false},
    },
    ['lake'] = {
        [1] = {["name"] = "salmon",         ["prop"] = "a_c_fish",                      ["ped"] = true, ["diff"] = "easy",       ["chance"] = 2,     ["trash"] = false},
        [2] = {["name"] = "perch",          ["prop"] = "a_c_fish",                      ["ped"] = true, ["diff"] = "easy",       ["chance"] = 2,     ["trash"] = false},
        [3] = {["name"] = "bass",           ["prop"] = "a_c_fish",                      ["ped"] = true, ["diff"] = "easy",       ["chance"] = 2,     ["trash"] = false},
        [4] = {["name"] = "tilapia",        ["prop"] = "a_c_fish",                      ["ped"] = true, ["diff"] = "medium",     ["chance"] = 5,     ["trash"] = false},
        [5] = {["name"] = "catfish",        ["prop"] = "a_c_fish",                      ["ped"] = true, ["diff"] = "medium",     ["chance"] = 5,     ["trash"] = false},
        [6] = {["name"] = "shad",           ["prop"] = "a_c_fish",                      ["ped"] = true, ["diff"] = "medium",     ["chance"] = 5,     ["trash"] = false},
        [7] = {["name"] = "rainbowfish",    ["prop"] = "a_c_fish",                      ["ped"] = true, ["diff"] = "medium",     ["chance"] = 5,     ["trash"] = false},
  },
  ['swan'] = {
      [1] = {["name"] = "salmon",         ["prop"] = "a_c_fish",                      ["ped"] = true, ["diff"] = "easy",       ["chance"] = 2,     ["trash"] = false},
      [2] = {["name"] = "perch",          ["prop"] = "a_c_fish",                      ["ped"] = true, ["diff"] = "easy",       ["chance"] = 2,     ["trash"] = false},
      [3] = {["name"] = "bass",           ["prop"] = "a_c_fish",                      ["ped"] = true, ["diff"] = "easy",       ["chance"] = 2,     ["trash"] = false},
      [4] = {["name"] = "tilapia",        ["prop"] = "a_c_fish",                      ["ped"] = true, ["diff"] = "medium",     ["chance"] = 5,     ["trash"] = false},
      [5] = {["name"] = "catfish",        ["prop"] = "a_c_fish",                      ["ped"] = true, ["diff"] = "medium",     ["chance"] = 5,     ["trash"] = false},
      [6] = {["name"] = "shad",           ["prop"] = "a_c_fish",                      ["ped"] = true, ["diff"] = "medium",     ["chance"] = 5,     ["trash"] = false},
      [7] = {["name"] = "rainbowfish",    ["prop"] = "a_c_fish",                      ["ped"] = true, ["diff"] = "medium",     ["chance"] = 5,     ["trash"] = false},
    },
}

--polyzones for all the fishing spaces. dont touch unless you know what you are doing

local insidePier1 = false
local insidePier2 = false
local insidePier3 = false
local insidePier4 = false
local insidePier5 = false
local insidePier6 = false
local insidePier7 = false
local insideFish1 = false
local insideFish2 = false
local insideFish3 = false
local insideArea1 = false
local insideArea8 = false
local insidePls   = false
local insideAlamo = false
local insideriver1 = false
local insideriver2 = false
local insideriver3 = false

--Name: river1 | Tue May 31 2022
local river1 = PolyZone:Create({
  vector2(-2046.97, 2759.09),
  vector2(-1301.52, 2928.79),
  vector2(-768.18, 3080.30),
  vector2(-334.85, 3146.97),
  vector2(83.33, 3498.48),
  vector2(262.12, 3413.64),
  vector2(19.70, 2968.18),
  vector2(-356.06, 2846.97),
  vector2(-771.21, 2737.88),
  vector2(-1177.27, 2583.33),
  vector2(-1559.09, 2465.15),
  vector2(-2025.76, 2398.48),
  vector2(-2607.58, 2371.21),
  vector2(-2777.27, 2374.24),
  vector2(-2680.30, 2868.18)
 }, {
  name="river1",
  --minZ=0,
  --maxZ=800
 })

--Name: river2 | Tue May 31 2022
local river2 = PolyZone:Create({
  vector2(-1577.27, 1553.03),
  vector2(-1546.97, 1753.03),
  vector2(-1525.76, 1877.27),
  vector2(-1491.67, 2033.33),
  vector2(-1729.55, 2050.76),
  vector2(-1484.09, 2260.98),
  vector2(-1575.76, 2465.15),
  vector2(-1471.21, 2493.94),
  vector2(-1365.15, 2207.58),
  vector2(-1353.79, 1990.91),
  vector2(-1400.76, 1746.97),
  vector2(-1407.58, 1601.52)
 }, {
  name="river2",
  --minZ=0,
  --maxZ=800
 })
--Name: river3 | Tue May 31 2022
local river3 = PolyZone:Create({
  vector2(-195.45, 4216.67),
  vector2(-110.61, 4307.58),
  vector2(-328.79, 4553.03),
  vector2(-850.00, 4562.12),
  vector2(-1316.67, 4531.82),
  vector2(-1704.55, 4662.12),
  vector2(-1816.67, 4756.06),
  vector2(-2053.03, 4559.09),
  vector2(-1634.85, 4325.76),
  vector2(-1513.64, 4219.70)
 }, {
  name="river3",
  --minZ=0,
  --maxZ=800
 })

--Name: pier1 | 2021-01-12T23:45:17Z
local pier1 = PolyZone:Create({
    vector2(-3428.3308105469, 951.81042480469),
    vector2(-3428.3774414063, 983.30786132813),
    vector2(-3408.8615722656, 983.28839111328),
    vector2(-3408.7917480469, 970.98431396484),
    vector2(-3323.1303710938, 970.91625976563),
    vector2(-3323.1264648438, 964.23559570313),
    vector2(-3408.8974609375, 963.92547607422),
    vector2(-3408.8547363281, 951.81213378906)
  }, {
    name="pier1",
    --debugPoly=true,
    --minZ = 8.2915201187134,
    --maxZ = 8.3466939926147
  })
  
--Name: Pier2 | 2021-01-13T00:03:02Z
local pier2 = PolyZone:Create({
  vector2(3867.8747558594, 4465.3662109375),
  vector2(3867.8332519531, 4462.0268554688),
  vector2(3860.1066894531, 4461.9555664063),
  vector2(3860.0639648438, 4458.2353515625),
  vector2(3850.5129394531, 4458.330078125),
  vector2(3850.4011230469, 4462.1640625),
  vector2(3838.6550292969, 4462.2397460938),
  vector2(3839.9389648438, 4465.3891601563)
}, {
  name="Pier2",
  --debugPoly=true,
  --minZ = 1.8629994392395,
  --maxZ = 2.7439646720886
})

--Name: Pier3 | 2021-01-13T00:12:00Z
local pier3 = PolyZone:Create({
    vector2(3440.8439941406, 5175.9111328125),
    vector2(3447.1306152344, 5167.0336914063),
    vector2(3443.9841308594, 5161.3930664063),
    vector2(3436.3649902344, 5156.2016601563),
    vector2(3426.7873535156, 5154.4633789063),
    vector2(3417.3869628906, 5160.7392578125),
    vector2(3416.2985839844, 5176.5361328125),
    vector2(3426.8181152344, 5183.7309570313),
    vector2(3430.6743164063, 5184.927734375),
    vector2(3434.4428710938, 5184.0830078125),
    vector2(3437.4489746094, 5182.986328125)
  }, {
    name="Pier3",
    --debugPoly=true,
    --minZ = 2.6028101444244,
    --maxZ = 8.0002679824829
  })
  

  --Name: Pier5 | 2021-01-13T00:30:16Z
local pier5 = PolyZone:Create({
    vector2(-1735.5949707031, -1123.0395507813),
    vector2(-1791.8107910156, -1190.1579589844),
    vector2(-1781.6818847656, -1198.9008789063),
    vector2(-1811.2736816406, -1234.1821289063),
    vector2(-1802.1579589844, -1241.64453125),
    vector2(-1826.2989501953, -1270.3895263672),
    vector2(-1865.6851806641, -1237.3530273438),
    vector2(-1859.9000244141, -1230.4180908203),
    vector2(-1879.8497314453, -1213.5169677734),
    vector2(-1832.2253417969, -1156.7065429688),
    vector2(-1805.8785400391, -1178.3756103516),
    vector2(-1749.3967285156, -1111.7651367188)
  }, {
    name="Pier5",
    --debugPoly=true,
    --minZ = 8.8172740936279,
    --maxZ = 13.317274093628
  })

  --Name: Pier6 | 2021-01-13T00:35:07Z
local pier6 = PolyZone:Create({
    vector2(-1615.7585449219, 5261.12109375),
    vector2(-1607.4755859375, 5265.162109375),
    vector2(-1603.4252929688, 5256.1528320313),
    vector2(-1605.3834228516, 5255.3256835938),
    vector2(-1579.3049316406, 5198.7348632813),
    vector2(-1592.9252929688, 5211.2744140625)
  }, {
    name="Pier6",
    --debugPoly=true,
    --minZ = 1.7037554979324,
    --maxZ = 4.8037557601929
  })
  
local fish1 = PolyZone:Create({
    vector2(-3825.7785644531, 1526.8626708984),
    vector2(-4096.8310546875, 1553.6392822266),
    vector2(-3900.978515625, 2337.0278320313),
    vector2(-3610.0236816406, 2350.9694824219),
    vector2(-3558.0751953125, 1921.9122314453)
  }, {
    name="Fish1",
    --debugPoly=true,
    --minZ = 8.3466796875,
    --maxZ = 8.3466796875
  })
--Name: fish2 | 2021-01-19T05:06:40Z
local fish2 = PolyZone:Create({
    vector2(-1123.4390869141, 7245.9287109375),
    vector2(-530.41833496094, 7057.4970703125),
    vector2(-1435.2729492188, 6426.224609375),
    vector2(-1977.0452880859, 6724.8681640625)
  }, {
    name="Fish2",
    --debugPoly=true,
    --minZ = 9.9427719116211,
    --maxZ = 9.9427719116211
  })
--Name: fish3 | 2021-01-19T05:12:25Z
local fish3 = PolyZone:Create({
    vector2(4514.0, 5360.8212890625),
    vector2(5059.1123046875, 4454.6508789063),
    vector2(4751.0551757813, 4024.9619140625),
    vector2(4352.9736328125, 4611.7631835938),
    vector2(4073.578125, 5527.55078125),
    vector2(4403.5224609375, 6306.8364257813),
    vector2(4703.34375, 5946.0888671875),
    vector2(4670.7153320313, 5577.056640625)
  }, {
    name="Fish3",
    --debugPoly=true,
    --minZ = 34.265563964844,
    --maxZ = 34.265563964844
  })
local area8 = PolyZone:Create({
    vector2(-1786.36, -973.48),
    vector2(-1823.86, -867.42),
    vector2(-1939.77, -716.67),
    vector2(-2022.73, -617.42),
    vector2(-2104.55, -553.79),
    vector2(-2112.50, -543.94),
    vector2(-2111.74, -518.18),
    vector2(-2146.97, -487.12),
    vector2(-2171.97, -456.82),
    vector2(-2212.12, -442.42),
    vector2(-2276.89, -393.18),
    vector2(-2347.73, -353.79),
    vector2(-2371.59, -339.39),
    vector2(-2419.32, -331.82),
    vector2(-2478.03, -296.21),
    vector2(-2656.44, -182.58),
    vector2(-2727.65, -103.41),
    vector2(-2807.20, -62.88),
    vector2(-2861.74, -41.67),
    vector2(-2926.14, -40.53),
    vector2(-3066.29, 23.48),
    vector2(-3091.29, 78.41),
    vector2(-3101.52, 182.58),
    vector2(-3152.27, 246.97),
    vector2(-3155.30, 285.61),
    vector2(-3138.64, 326.89),
    vector2(-3121.97, 374.24),
    vector2(-3080.68, 471.21),
    vector2(-3074.62, 507.20),
    vector2(-3095.83, 614.39),
    vector2(-3135.23, 683.33),
    vector2(-3183.33, 773.48),
    vector2(-3229.92, 853.03),
    vector2(-3235.98, 889.77),
    vector2(-3274.62, 925.76),
    vector2(-3296.97, 956.44),
    vector2(-3399.62, 957.20),
    vector2(-3398.86, 945.08),
    vector2(-3421.21, 943.56),
    vector2(-3948.48, 942.42),
    vector2(-3907.58, -2028.79)
   }, {
    name="8",
    --debugPoly=true,
    --minZ=0,
    --maxZ=800
   })

    
--Name: 1 | Wed May 05 2021
local area1 = PolyZone:Create({
    vector2(1577.65, 6658.33),
    vector2(1584.47, 6668.56),
    vector2(1600.76, 6669.70),
    vector2(1609.09, 6678.79),
    vector2(1621.59, 6668.18),
    vector2(1645.83, 6662.88),
    vector2(1661.74, 6665.91),
    vector2(1668.18, 6675.76),
    vector2(1678.79, 6665.91),
    vector2(1691.67, 6667.42),
    vector2(1693.94, 6676.14),
    vector2(1712.50, 6676.14),
    vector2(1727.27, 6672.73),
    vector2(1735.23, 6666.67),
    vector2(1746.59, 6678.41),
    vector2(1756.44, 6679.17),
    vector2(1761.74, 6666.29),
    vector2(1776.52, 6660.98),
    vector2(1784.47, 6667.05),
    vector2(1796.21, 6668.18),
    vector2(1807.58, 6668.56),
    vector2(1814.02, 6676.14),
    vector2(1832.95, 6671.21),
    vector2(1840.91, 6667.80),
    vector2(1850.38, 6676.52),
    vector2(1865.91, 6673.48),
    vector2(1878.03, 6671.59),
    vector2(1889.02, 6659.47),
    vector2(1901.14, 6657.58),
    vector2(1908.71, 6654.17),
    vector2(1912.88, 6648.11),
    vector2(1917.80, 6650.38),
    vector2(1922.73, 6661.36),
    vector2(1923.86, 6671.97),
    vector2(1920.45, 6692.05),
    vector2(1915.53, 6697.35),
    vector2(1936.74, 6700.38),
    vector2(1955.30, 6709.47),
    vector2(1981.82, 6725.38),
    vector2(2013.26, 6740.91),
    vector2(2045.83, 6737.50),
    vector2(2078.41, 6737.88),
    vector2(2096.97, 6728.03),
    vector2(2131.44, 6692.05),
    vector2(2158.71, 6717.80),
    vector2(2184.47, 6730.68),
    vector2(2206.44, 6727.65),
    vector2(2215.53, 6719.32),
    vector2(2231.82, 6726.89),
    vector2(2254.55, 6733.33),
    vector2(2305.30, 6704.55),
    vector2(2325.76, 6674.62),
    vector2(2337.12, 6645.45),
    vector2(2354.55, 6628.41),
    vector2(2401.14, 6621.97),
    vector2(2445.45, 6602.65),
    vector2(2484.09, 6586.36),
    vector2(2504.92, 6586.36),
    vector2(2535.23, 6603.41),
    vector2(2555.68, 6609.85),
    vector2(2573.86, 6594.70),
    vector2(2583.33, 6596.59),
    vector2(2589.77, 6593.94),
    vector2(2600.76, 6586.36),
    vector2(2621.97, 6567.05),
    vector2(2616.67, 6549.62),
    vector2(2619.32, 6533.71),
    vector2(2623.48, 6519.32),
    vector2(2633.71, 6520.08),
    vector2(2649.24, 6533.71),
    vector2(2654.55, 6544.32),
    vector2(2665.15, 6540.91),
    vector2(2678.79, 6526.52),
    vector2(2705.30, 6523.11),
    vector2(2729.92, 6540.53),
    vector2(2739.39, 6532.20),
    vector2(2739.39, 6525.00),
    vector2(2748.48, 6527.65),
    vector2(2753.41, 6520.45),
    vector2(2744.70, 6513.64),
    vector2(2749.24, 6499.24),
    vector2(2760.23, 6502.27),
    vector2(2762.50, 6511.74),
    vector2(2773.11, 6510.61),
    vector2(2783.33, 6515.15),
    vector2(2799.62, 6513.26),
    vector2(2800.00, 6506.06),
    vector2(2813.26, 6495.08),
    vector2(2803.03, 6491.67),
    vector2(2809.85, 6476.52),
    vector2(2809.85, 6462.50),
    vector2(2814.77, 6447.35),
    vector2(2812.12, 6442.80),
    vector2(2827.27, 6436.36),
    vector2(2845.83, 6428.79),
    vector2(2862.88, 6433.33),
    vector2(2879.55, 6428.79),
    vector2(2887.50, 6418.56),
    vector2(2890.91, 6392.42),
    vector2(2892.80, 6379.55),
    vector2(2888.64, 6354.17),
    vector2(2921.21, 6367.05),
    vector2(2941.67, 6377.65),
    vector2(2969.70, 6381.06),
    vector2(2975.76, 6369.32),
    vector2(2980.68, 6360.98),
    vector2(2999.24, 6362.12),
    vector2(3025.76, 6345.45),
    vector2(3034.47, 6331.06),
    vector2(3047.35, 6318.56),
    vector2(3057.58, 6329.55),
    vector2(3051.89, 6339.02),
    vector2(3068.94, 6346.97),
    vector2(3081.82, 6353.79),
    vector2(3095.45, 6347.35),
    vector2(3120.08, 6349.62),
    vector2(3156.06, 6353.41),
    vector2(3168.56, 6342.42),
    vector2(3174.62, 6324.62),
    vector2(3172.73, 6317.42),
    vector2(3176.89, 6310.98),
    vector2(3199.62, 6300.00),
    vector2(3210.98, 6300.76),
    vector2(3218.18, 6304.92),
    vector2(3231.44, 6301.89),
    vector2(3239.77, 6292.05),
    vector2(3248.86, 6285.98),
    vector2(3240.53, 6282.58),
    vector2(3245.83, 6274.24),
    vector2(3250.76, 6259.09),
    vector2(3254.17, 6235.98),
    vector2(3259.09, 6225.76),
    vector2(3266.67, 6220.08),
    vector2(3254.17, 6208.71),
    vector2(3247.35, 6197.35),
    vector2(3248.86, 6184.47),
    vector2(3248.86, 6170.08),
    vector2(3247.35, 6159.09),
    vector2(3239.02, 6153.79),
    vector2(3240.91, 6138.64),
    vector2(3249.24, 6138.64),
    vector2(3275.76, 6138.26),
    vector2(3290.53, 6142.05),
    vector2(3319.70, 6122.73),
    vector2(3355.68, 6120.45),
    vector2(3361.74, 6098.86),
    vector2(3379.92, 6109.09),
    vector2(3398.86, 6122.73),
    vector2(3422.73, 6134.85),
    vector2(3425.76, 6129.92),
    vector2(3432.95, 6109.47),
    vector2(3418.94, 6101.52),
    vector2(3418.18, 6076.52),
    vector2(3419.70, 6058.71),
    vector2(3415.53, 6047.35),
    vector2(3408.33, 6041.29),
    vector2(3405.68, 6004.92),
    vector2(3401.52, 5992.80),
    vector2(3403.41, 5980.68),
    vector2(3414.39, 5965.53),
    vector2(3420.83, 5966.29),
    vector2(3430.30, 5965.91),
    vector2(3436.36, 5947.35),
    vector2(3439.77, 5928.79),
    vector2(3434.09, 5920.83),
    vector2(3424.62, 5913.26),
    vector2(3425.76, 5885.98),
    vector2(3435.23, 5871.97),
    vector2(3444.32, 5859.09),
    vector2(3430.30, 5848.11),
    vector2(3410.61, 5839.39),
    vector2(3401.14, 5837.12),
    vector2(3401.89, 5818.56),
    vector2(3398.48, 5799.24),
    vector2(3392.80, 5773.48),
    vector2(3387.88, 5752.65),
    vector2(3378.03, 5723.48),
    vector2(3370.83, 5703.03),
    vector2(3361.74, 5692.42),
    vector2(3357.58, 5684.47),
    vector2(3359.09, 5672.35),
    vector2(3367.80, 5662.50),
    vector2(3378.41, 5638.64),
    vector2(3380.30, 5621.59),
    vector2(3374.24, 5609.47),
    vector2(3372.73, 5589.77),
    vector2(3377.65, 5573.11),
    vector2(3376.52, 5564.39),
    vector2(3395.45, 5551.14),
    vector2(3399.24, 5540.91),
    vector2(3417.05, 5540.53),
    vector2(3426.14, 5526.52),
    vector2(3434.85, 5526.14),
    vector2(3436.36, 5513.64),
    vector2(3454.92, 5509.47),
    vector2(3468.56, 5509.85),
    vector2(3472.35, 5502.27),
    vector2(3465.91, 5490.91),
    vector2(3475.38, 5476.14),
    vector2(3467.42, 5467.42),
    vector2(3463.64, 5457.95),
    vector2(3455.68, 5442.05),
    vector2(3436.74, 5421.59),
    vector2(3407.20, 5424.62),
    vector2(3389.39, 5403.41),
    vector2(3364.77, 5392.80),
    vector2(3343.94, 5391.67),
    vector2(3319.70, 5373.86),
    vector2(3298.86, 5356.06),
    vector2(3273.86, 5353.79),
    vector2(3258.33, 5344.32),
    vector2(3241.67, 5326.52),
    vector2(3217.80, 5326.52),
    vector2(3202.65, 5316.29),
    vector2(3207.20, 5300.38),
    vector2(3215.91, 5279.55),
    vector2(3235.61, 5254.92),
    vector2(3247.35, 5234.47),
    vector2(3301.14, 5231.06),
    vector2(3316.29, 5220.08),
    vector2(3319.32, 5210.98),
    vector2(3337.88, 5193.94),
    vector2(3348.11, 5188.64),
    vector2(3356.82, 5172.73),
    vector2(3360.61, 5165.15),
    vector2(3348.11, 5128.79),
    vector2(3326.89, 5120.83),
    vector2(3318.18, 5111.36),
    vector2(3296.97, 5109.85),
    vector2(3265.15, 5110.98),
    vector2(3244.70, 5111.74),
    vector2(3225.76, 5107.95),
    vector2(3211.36, 5104.17),
    vector2(3204.92, 5096.97),
    vector2(3188.64, 5091.67),
    vector2(3173.48, 5088.64),
    vector2(3157.58, 5080.30),
    vector2(3154.17, 5071.59),
    vector2(3180.30, 5071.97),
    vector2(3214.39, 5077.65),
    vector2(3230.30, 5075.00),
    vector2(3241.29, 5085.98),
    vector2(3255.30, 5088.64),
    vector2(3269.32, 5078.79),
    vector2(3282.58, 5079.55),
    vector2(3294.32, 5071.59),
    vector2(3314.77, 5067.05),
    vector2(3328.79, 5064.02),
    vector2(3345.45, 5063.26),
    vector2(3354.55, 5057.58),
    vector2(3355.30, 5052.65),
    vector2(3372.73, 5049.24),
    vector2(3389.02, 5035.61),
    vector2(3395.83, 5036.36),
    vector2(3410.61, 5027.65),
    vector2(3414.02, 5019.32),
    vector2(3417.05, 5008.33),
    vector2(3431.44, 5003.41),
    vector2(3435.23, 4991.29),
    vector2(3445.45, 4981.44),
    vector2(3446.59, 4973.11),
    vector2(3443.56, 4962.88),
    vector2(3444.32, 4951.14),
    vector2(3447.73, 4943.94),
    vector2(3460.98, 4943.18),
    vector2(3471.21, 4938.64),
    vector2(3477.27, 4927.27),
    vector2(3481.44, 4917.80),
    vector2(3506.06, 4913.26),
    vector2(3512.50, 4900.76),
    vector2(3521.59, 4882.95),
    vector2(3529.55, 4876.52),
    vector2(3528.41, 4867.42),
    vector2(3526.89, 4859.85),
    vector2(3534.85, 4854.17),
    vector2(3542.80, 4851.89),
    vector2(3546.59, 4843.56),
    vector2(3544.70, 4834.85),
    vector2(3547.73, 4822.73),
    vector2(3550.00, 4811.74),
    vector2(3543.56, 4805.68),
    vector2(3535.98, 4798.48),
    vector2(3530.30, 4789.02),
    vector2(3533.33, 4778.41),
    vector2(3543.56, 4773.48),
    vector2(3536.74, 4765.91),
    vector2(3537.88, 4756.44),
    vector2(3550.38, 4743.56),
    vector2(3560.98, 4731.44),
    vector2(3571.59, 4718.56),
    vector2(3583.33, 4714.39),
    vector2(3596.97, 4701.14),
    vector2(3613.26, 4696.97),
    vector2(3625.76, 4699.24),
    vector2(3636.74, 4699.62),
    vector2(3644.32, 4692.42),
    vector2(3635.98, 4687.12),
    vector2(3633.33, 4682.20),
    vector2(3639.77, 4673.48),
    vector2(3640.15, 4665.15),
    vector2(3636.74, 4660.61),
    vector2(3640.15, 4653.41),
    vector2(3635.98, 4637.50),
    vector2(3635.98, 4625.00),
    vector2(3645.08, 4619.70),
    vector2(3654.55, 4634.85),
    vector2(3668.94, 4653.41),
    vector2(3685.98, 4666.29),
    vector2(3714.02, 4667.80),
    vector2(3735.61, 4659.09),
    vector2(3742.42, 4645.45),
    vector2(3736.36, 4637.12),
    vector2(3730.30, 4624.24),
    vector2(3738.64, 4620.08),
    vector2(3755.30, 4617.42),
    vector2(3762.88, 4596.59),
    vector2(3764.02, 4576.14),
    vector2(3770.45, 4562.12),
    vector2(3774.62, 4547.73),
    vector2(3771.21, 4535.23),
    vector2(3788.26, 4532.95),
    vector2(3796.97, 4530.68),
    vector2(3810.61, 4515.15),
    vector2(3824.24, 4489.39),
    vector2(3829.55, 4462.88),
    vector2(3833.71, 4453.79),
    vector2(3830.68, 4443.18),
    vector2(4115.15, 4429.55),
    vector2(4978.79, 4419.70),
    vector2(4977.27, 8250.00),
    vector2(1571.21, 8277.27)
   }, {
    name="1",
    --debugPoly=true,
    --minZ=0,
    --maxZ=800
   })

--Name: pls | Wed May 19 2021
local pls = PolyZone:Create({
    vector2(-3308.33, 967.80),
    vector2(-3241.67, 1327.65),
    vector2(-3184.47, 1440.15),
    vector2(-3068.56, 1514.02),
    vector2(-3034.09, 1559.09),
    vector2(-3123.86, 1634.85),
    vector2(-3181.06, 1700.38),
    vector2(-3182.58, 1781.82),
    vector2(-3142.05, 1843.56),
    vector2(-3112.50, 1854.55),
    vector2(-3091.29, 1885.23),
    vector2(-3068.56, 1887.50),
    vector2(-3106.82, 1953.79),
    vector2(-3036.74, 2236.36),
    vector2(-2958.71, 2240.91),
    vector2(-2939.02, 2276.52),
    vector2(-2875.76, 2260.23),
    vector2(-2788.64, 2393.94),
    vector2(-2783.33, 2533.71),
    vector2(-2748.86, 2782.95),
    vector2(-2737.50, 2965.53),
    vector2(-2758.33, 3016.29),
    vector2(-3023.11, 3241.29),
    vector2(-3110.23, 3236.74),
    vector2(-3159.85, 3262.50),
    vector2(-3092.05, 3360.61),
    vector2(-3110.98, 3401.14),
    vector2(-3036.36, 3433.33),
    vector2(-3062.88, 3489.39),
    vector2(-2918.94, 3557.58),
    vector2(-2833.71, 3576.14),
    vector2(-2786.36, 3565.53),
    vector2(-2659.47, 3553.79),
    vector2(-2603.79, 3592.80),
    vector2(-2541.67, 3800.38),
    vector2(-2546.21, 3900.76),
    vector2(-2487.12, 4046.97),
    vector2(-2496.97, 4146.59),
    vector2(-2405.30, 4328.79),
    vector2(-2277.65, 4454.92),
    vector2(-2213.64, 4557.58),
    vector2(-2183.33, 4604.55),
    vector2(-1949.24, 4577.27),
    vector2(-1835.98, 4690.91),
    vector2(-1868.18, 4785.23),
    vector2(-1730.30, 4923.11),
    vector2(-1770.08, 5035.98),
    vector2(-1778.03, 5051.89),
    vector2(-1757.20, 5071.59),
    vector2(-1770.08, 5095.45),
    vector2(-1696.59, 5081.44),
    vector2(-1698.11, 5107.20),
    vector2(-1617.42, 5098.11),
    vector2(-1596.97, 5174.62),
    vector2(-1569.32, 5183.33),
    vector2(-1540.53, 5163.64),
    vector2(-1533.33, 5212.88),
    vector2(-1476.89, 5214.39),
    vector2(-1428.79, 5187.88),
    vector2(-1395.08, 5239.77),
    vector2(-1395.45, 5338.26),
    vector2(-1365.15, 5366.67),
    vector2(-1151.89, 5386.36),
    vector2(-1050.76, 5505.68),
    vector2(-907.20, 5620.08),
    vector2(-915.91, 5736.36),
    vector2(-871.21, 5842.80),
    vector2(-864.39, 5877.65),
    vector2(-941.29, 6017.05),
    vector2(-990.15, 6221.21),
    vector2(-946.21, 6218.94),
    vector2(-854.17, 6065.15),
    vector2(-810.23, 6000.76),
    vector2(-764.77, 6015.91),
    vector2(-652.27, 6162.50),
    vector2(-640.15, 6307.95),
    vector2(-618.56, 6363.26),
    vector2(-470.08, 6449.62),
    vector2(-371.97, 6488.26),
    vector2(-286.36, 6564.77),
    vector2(-265.15, 6598.48),
    vector2(-263.64, 6648.48),
    vector2(-219.32, 6647.73),
    vector2(-145.45, 6701.89),
    vector2(-64.77, 6806.82),
    vector2(-31.44, 6893.94),
    vector2(-29.92, 6965.53),
    vector2(23.48, 7037.12),
    vector2(40.91, 7064.02),
    vector2(48.11, 7214.77),
    vector2(77.65, 7187.50),
    vector2(138.26, 7079.55),
    vector2(227.65, 7061.74),
    vector2(341.29, 6937.50),
    vector2(420.08, 6857.95),
    vector2(412.12, 6838.26),
    vector2(467.80, 6751.52),
    vector2(730.68, 6639.02),
    vector2(840.15, 6653.03),
    vector2(996.21, 6604.55),
    vector2(1070.83, 6614.02),
    vector2(1171.21, 6582.95),
    vector2(1337.50, 6616.67),
    vector2(1346.59, 6603.03),
    vector2(1371.59, 6614.02),
    vector2(1444.32, 6620.45),
    vector2(1462.12, 6613.64),
    vector2(1514.02, 6621.21),
    vector2(1576.52, 6659.47),
    vector2(1874.24, 8292.42),
    vector2(-3865.15, 8280.30),
    vector2(-3819.70, 959.85),
    vector2(-3421.21, 961.36),
    vector2(-3422.73, 979.17),
    vector2(-3400.00, 978.79),
    vector2(-3400.00, 967.05)
   }, {
    name="pls",
    --debugPoly=true,
    --minZ=0,
    --maxZ=800
    })

--Name: alamo | Wed May 19 2021
local alamo = PolyZone:Create({
    vector2(126.47, 3426.16),
    vector2(170.03, 3410.63),
    vector2(332.13, 3516.68),
    vector2(321.52, 3575.01),
    vector2(381.74, 3606.82),
    vector2(637.77, 3571.22),
    vector2(892.37, 3646.98),
    vector2(1199.15, 3621.99),
    vector2(1305.58, 3665.16),
    vector2(1379.11, 3727.29),
    vector2(1439.33, 3734.10),
    vector2(1512.81, 3768.57),
    vector2(1571.52, 3814.78),
    vector2(1606.36, 3843.94),
    vector2(1628.71, 3873.86),
    vector2(1658.25, 3885.23),
    vector2(1734.75, 3940.15),
    vector2(1854.06, 3970.07),
    vector2(1971.85, 3949.24),
    vector2(2030.25, 3886.38),
    vector2(2065.48, 3845.85),
    vector2(2154.10, 3874.26),
    vector2(2239.70, 3866.30),
    vector2(2361.66, 3970.84),
    vector2(2406.73, 4050.76),
    vector2(2402.18, 4152.27),
    vector2(2401.09, 4274.64),
    vector2(2435.56, 4403.81),
    vector2(2452.60, 4475.77),
    vector2(2418.51, 4529.18),
    vector2(2423.44, 4586.38),
    vector2(2362.46, 4653.80),
    vector2(2224.95, 4677.67),
    vector2(2120.42, 4662.52),
    vector2(2051.49, 4586.76),
    vector2(1894.69, 4540.56),
    vector2(1801.14, 4541.31),
    vector2(1626.54, 4521.62),
    vector2(1547.38, 4418.60),
    vector2(1463.30, 4363.30),
    vector2(1395.12, 4325.42),
    vector2(1325.33, 4283.35),
    vector2(1260.19, 4329.94),
    vector2(1216.25, 4340.55),
    vector2(1141.64, 4314.41),
    vector2(942.04, 4301.53),
    vector2(887.88, 4283.73),
    vector2(889.02, 4208.36),
    vector2(873.07, 4165.56),
    vector2(768.92, 4160.25),
    vector2(629.53, 4199.26),
    vector2(551.08, 4175.78),
    vector2(466.24, 4262.89),
    vector2(359.42, 4316.30),
    vector2(197.32, 4337.89),
    vector2(56.81, 4432.58),
    vector2(-12.12, 4437.13),
    vector2(-60.98, 4364.40),
    vector2(-90.52, 4271.61),
    vector2(-126.51, 4236.38),
    vector2(-187.10, 4201.54),
    vector2(-226.92, 4110.62),
    vector2(-234.50, 4067.82),
    vector2(-217.08, 4003.81),
    vector2(-214.43, 3912.15),
    vector2(-203.06, 3806.46),
    vector2(-145.49, 3687.53),
    vector2(-94.36, 3658.36),
    vector2(38.58, 3751.52),
    vector2(118.88, 3748.87),
    vector2(132.51, 3654.56),
    vector2(125.69, 3545.48),
    vector2(120.77, 3482.23),
    vector2(120.39, 3438.29)
   }, {
    name="Alamo",
    --debugPoly=true,
    --minZ=0,
    --maxZ=800
   })

local area10 = PolyZone:Create({
 vector2(1020.18, -2634.50),
 vector2(1247.52, -2676.91),
 vector2(1574.89, -2704.18),
 vector2(1865.88, -2628.44),
 vector2(2062.91, -2389.13),
 vector2(2250.85, -2113.46),
 vector2(2538.81, -2068.02),
 vector2(2629.75, -1871.11),
 vector2(2590.35, -1713.59),
 vector2(2514.57, -1601.50),
 vector2(2460.00, -1462.15),
 vector2(2444.85, -1340.98),
 vector2(2460.00, -1213.75),
 vector2(2563.06, -1134.99),
 vector2(2644.91, -1113.78),
 vector2(2611.56, -919.90),
 vector2(2735.65, -816.50),
 vector2(2781.12, -725.62),
 vector2(2750.81, -577.18),
 vector2(2839.75, -443.76),
 vector2(2788.22, -49.95),
 vector2(2709.41, 56.08),
 vector2(2763.97, 395.53),
 vector2(2824.59, 478.83),
 vector2(2865.51, 712.09),
 vector2(2862.48, 771.16),
 vector2(2812.47, 802.97),
 vector2(2771.55, 880.22),
 vector2(2745.78, 971.10),
 vector2(2726.08, 1054.41),
 vector2(2720.33, 1279.95),
 vector2(2777.93, 1428.39),
 vector2(2820.36, 1640.44),
 vector2(2862.80, 1840.38),
 vector2(2887.05, 2052.43),
 vector2(2971.92, 2194.81),
 vector2(3123.48, 2300.84),
 vector2(3320.51, 2721.91),
 vector2(3469.04, 2937.00),
 vector2(3602.27, 3150.24),
 vector2(3838.70, 3592.53),
 vector2(3720.40, 3714.04),
 vector2(3705.24, 3823.10),
 vector2(3811.33, 3968.51),
 vector2(3884.08, 4059.39),
 vector2(3811.33, 4247.21),
 vector2(3735.55, 4435.03),
 vector2(3690.09, 4571.35),
 vector2(3490.03, 4734.93),
 vector2(3383.94, 4965.16),
 vector2(3283.89, 5107.84),
 vector2(3232.36, 5232.04),
 vector2(3186.89, 5298.69),
 vector2(3174.76, 5383.51),
 vector2(3326.32, 5441.07),
 vector2(3344.51, 5550.12),
 vector2(3286.92, 5692.50),
 vector2(3251.16, 5959.84),
 vector2(3166.29, 6141.60),
 vector2(3135.98, 6244.60),
 vector2(4627.32, 6359.71),
 vector2(4472.99, 2795.72),
 vector2(4448.75, -1227.24),
 vector2(2872.53, -3553.76),
 vector2(1408.39, -3670.64),
 vector2(1372.02, -2901.19),
 vector2(974.42, -2801.44)
}, {
 name="area10",
 --debugPoly = true,
 --minZ=0,
 --maxZ=800
})

local area15 = PolyZone:Create({
 vector2(-1208.33, -1843.18),
 vector2(-1421.97, -1480.30),
 vector2(-1509.09, -1204.17),
 vector2(-1660.23, -1044.70),
 vector2(-1798.48, -867.80),
 vector2(-1942.80, -690.15),
 vector2(-3125.76, -1295.45),
 vector2(-2301.52, -2277.27)
}, {
 name="area15",
 --debugPoly = true,
 --minZ=0,
 --maxZ=800
})
local area = false

function fishingSpot()
    area = false
    local plyPos = GetEntityCoords(PlayerPedId())

    insidePier1 = pier1:isPointInside(plyPos)
    insidePier2 = pier2:isPointInside(plyPos)
    insidePier3 = pier3:isPointInside(plyPos)
    insidePier5 = pier5:isPointInside(plyPos)
    insidePier6 = pier6:isPointInside(plyPos)
    insideFish1 = fish1:isPointInside(plyPos)
    insideFish2 = fish2:isPointInside(plyPos)
    insideArea1 = area1:isPointInside(plyPos)
    insideArea8 = area8:isPointInside(plyPos)
    insideArea10 = area10:isPointInside(plyPos)
    insideArea15 = area15:isPointInside(plyPos)
    insidePls = pls:isPointInside(plyPos)
    insideAlamo = alamo:isPointInside(plyPos)
    if insideriver1 or insideriver2 or insideriver3 then
        area = 'river'
    elseif insideAlamo then
        area = 'alamo'
    elseif insidePier1 or insidePier2 or insidePier3 or insidePier4 or insidePier5 or insidePier6 or insideArea1 or insideArea8 or insidePls or insideFish1 or insideFish2 or insideArea10 or insideArea15 then
        area = 'ocean'
    end
    return area
end