Config = {}

Config.account = {								-- Account configs
	['fisher'] = 'bank',						-- Change here the account that should be used with fisher expenses
}

Config.job = "false"							-- Required job name to open the menu (set as false to disable the permission)

-- Here are the places where the person can open the business menu
-- You can add as many locations as you like, just use the location already created as an example
Config.fishing_locations = {
	["fishing_1"] = {		
		['menu_location'] = {848.32, -899.26, 25.25},	-- Coordinate to open the menu (vector3)
		['garage_locations'] = {						-- Garage coordinates, where the business vehicles will spawn (vector4)
			{856.32, -895.12, 25.41}--{854.29, -899.33, 25.35, 269.83},
			--{854.43, -905.59, 25.35, 273.32},
		},
		['boat_garage_locations'] = {						-- Garage coordinates, where the business vehicles will spawn (vector4)
			{856.32, -895.12, 25.41}--{854.29, -899.33, 25.35, 269.83},
		--{854.43, -905.59, 25.35, 273.32},
		},
		['blips'] = {							-- Create the blips on map
			['id'] = 410,						-- Blip ID [Set this value 0 to dont have blip]
			['name'] = "Fishing job",			-- Blip Name
			['color'] = 3,						-- Blip Color
			['scale'] = 0.6,					-- Blip Scale
		}
	},
	["fishing_2"] = {
		['menu_location'] = {708.0, -1082.99, 22.4},
		['garage_locations'] = {
			{854.29, -899.33, 25.35, 269.83},
			{854.43, -905.59, 25.35, 273.32},
		},
		['blips'] = {							-- Create the blips on map
			['id'] = 410,						-- Blip ID [Set this value 0 to dont have blip]
			['name'] = "Fishing job",			-- Blip Name
			['color'] = 3,						-- Blip Color
			['scale'] = 0.6,					-- Blip Scale
		}
	},
}

Config.available_contracts = {
	['definitions'] = {
		['time_to_new_contracts'] = 2, 						-- Time (in mins) to generate new contracts to the contracts page
		['max_contracts'] = 6,								-- Max available contracts
	},
	['contracts'] = {										-- Contracts that will be generated
		{
			['name'] = 'Atum',								-- Contract name
			['description'] = 'xxxxxx',	-- Contract description
			['image'] = 'images/deliveries/delivery.jpg',	-- Suggested size 666x375
			['reward'] = {									-- Rewards the player will receive when finishing this contract
				['money_min'] = 1000,						-- Money min amount
				['money_max'] = 2000						-- Money max amount
			},
			['required_items'] = {							-- Fishes required to delivery in this contract
				{
					['name'] = 'atum',						-- Fish ID
					['display_name'] = 'Atum',				-- Fish display name
					['amount'] = 3							-- Amount
				},
				{
					['name'] = 'tubas',
					['display_name'] = 'Tubas',
					['amount'] = 1
				}
			}
		},
		{
			['name'] = 'Water',
			['description'] = 'Some quick example text to build on the card title and make up the bulk.',
			['image'] = 'images/deliveries/delivery.jpg',
			['reward'] = {									-- The rewards can be items too, just set the item and the amount
				['item'] = 'beer',
				['display_name'] = 'Beer',
				['amount'] = 5
			},
			['required_items'] = {
				{
					['name'] = 'atum',
					['display_name'] = 'Atum',
					['amount'] = 3
				},
				{
					['name'] = 'tubas',
					['display_name'] = 'Tubas',
					['amount'] = 1
				}
			}
		}
	}
}

Config.vehicle_sell_price_multiplier = 0.7		-- Value you receive when selling the used item
Config.available_items_store = {
	['vehicle'] = {
		['weevil'] = {
			['name'] = 'Rubble',
			['description'] = 'A truck to carry out all your fishes',
			['price'] = 3100,
			['image'] = 'images/vehicles/rubble.png',
			['repair_price'] = 400,
			['refuel_price'] = 10
		},
	},
	['boat'] = {
		['weevil'] = {
			['name'] = 'Weevil',
			['description'] = 'A truck to carry out all your fishes',
			['price'] = 3100,
			['image'] = 'images/vehicles/rubble.png',
			['repair_price'] = 400,
			['refuel_price'] = 10
		},
	},
	['property'] = {
		['weevil'] = {
			['name'] = 'Weevil',
			['price'] = 3100,
			['warehouse_capacity'] = 100,
			['image'] = 'images/vehicles/rubble.png',
			['location'] = {854.28, -898.53, 25.35}
		},
	}
}

Config.vehicle_blips = {						-- Configure here the vehicle blips created in the script
	['sprite'] = 477,							-- Vehicle blip sprite when the vehicle is spawned
	['color'] = 26								-- Vehicle blip color
}

--[[
	Amount of exp you need to reach each level
	Example:
	[1] = 100,
	[2] = 200,
	This means that to reach level 1 you need 100 EXP, to reach level 2 you need 200 EXP
	When leveling up, the player receives 1 skill point
	Level 30 is the maximum
]]
Config.required_xp_to_levelup = {
	[1] = 1000,
	[2] = 2000,
	[3] = 3000,
	[4] = 4000,
	[5] = 5000,
	[6] = 6000,
	[7] = 7000,
	[8] = 8000,
	[9] = 9000,
	[10] = 10000,
	[11] = 11000,
	[12] = 12000,
	[13] = 13000,
	[14] = 14000,
	[15] = 16000,
	[16] = 18000,
	[17] = 20000,
	[18] = 22000,
	[19] = 24000,
	[20] = 26000,
	[21] = 28000,
	[22] = 30000,
	[23] = 35000,
	[24] = 40000,
	[25] = 45000,
	[26] = 50000,
	[27] = 55000,
	[28] = 60000,
	[29] = 65000,
	[30] = 100000 -- Max
}

--[[
	Maximum loan amount a person can take per level (the higher the level, the bigger the loan)
	Example:
	[0] = 20000,
	[10] = 50000,
	[20] = 200000
	This means that at level 0 to level 10, you can get a loan of 20 thousand. From level 10 to 20, you can take a maximum of 50 thousand ....
]]
Config.max_loan_per_level = {
	[0] = 40000,
	[10] = 100000,
	[20] = 250000,
	[30] = 600000
}

-- Loan amounts and amount that is charged per day
Config.loans = {
	['cooldown'] = 86400, -- Time (in seconds) that the loan will be charged to the player (86400 = 24 hours)
	['amount'] = {
		--[[
			It is possible to configure 4 loan values ​​and each loan has its own settings
			Example:
			[1] = {
				20000,	[Loan amount]: 20,000
				400, 	[Amount that the player pays each day]: This amount must be greater than the amount below, so in this case, when finalizing the payment of all installments, the player will pay 24 thousand (4 thousand of interest)
				200 	[Base amount to calculate interest]: The above value subtracted from this (240 - 200) will be the amount of interest: 40 interest per day
			},
		]]
		[1] = {20000,400,200},
		[2] = {50000,950,500},
		[3] = {100000,1800,1000},
		[4] = {400000,7000,4000}
	}
}

Config.delivery_locations = {
	{867.69, -898.73, 25.79},
	{867.34, -884.69, 25.77}
}

Config.create_table = true