let config = {};

window.addEventListener('message', async function (event) {
	var item = event.data;
	if (item.utils) {
		if (typeof Lang === 'undefined') {
			await Utils.loadLanguageModules(item.utils)
		}
	}
	if (item.resourceName) {
		Utils.setResourceName(item.resourceName)
	}
	if (item.openOwnerUI) {
		config = item.data.config;
		let fishing_life_users = item.data.fishing_life_users;
		let fishing_life_loans = item.data.fishing_life_loans;
		let fishing_available_contracts = item.data.fishing_available_contracts;
		let owned_vehicles = item.data.owned_vehicles
		let owned_properties = item.data.owned_properties
		let available_items_store = config.available_items_store;
		let upgrades = config.upgrades

		if (item.isUpdate != true) {
			// Open on first time
			renderStaticTexts();

			$('#css-toggle').prop('checked', fishing_life_users.dark_theme).change();
			openPage('profile');
		}

		/*
		* PLAYER INFO HEADER
		*/
		$("#player-info-level").text(Utils.numberFormat(config.player_level,0))
		$("#player-info-skill").text(Utils.numberFormat(fishing_life_users.skill_points,0))
		$("#player-info-money").text(Utils.currencyFormat(fishing_life_users.money,0))

		renderStatisticsPage();
		renderDeliveriesPage(fishing_available_contracts, fishing_life_users);
		renderStorePage(available_items_store);
		renderOwnedVehiclesPage(owned_vehicles,available_items_store);
		renderOwnedPropertiesPage(owned_properties,available_items_store);
		renderBankPage(fishing_life_users, item, fishing_life_loans);
		renderUpgradesPage(upgrades,fishing_life_users);

		createListeners();
	} else if(item.openPropertyUI){

		config = item.data.config;
		//$(".main").css("display", "none");
		renderStockPage(item.property)
		$(document).ready(function(){
			$("#stock-modal").modal({show: true});
		});
	}
	if (item.hidemenu){
		$(".main").css("display", "none");
	}
});

function createListeners() {
	$('.sidebar-navigation ul li').on('click', function () {
		$('li').removeClass('active');
		$(this).addClass('active');
	});

	$('.navigation-tabs-container .navigation-tab').on('click', function () {
		$('.navigation-tab').removeClass('selected');
		$(this).addClass('selected');
	});
}

function renderStaticTexts() {
	$(".pages").css("display", "none");
	$(".main").css("display", "");
	$(".main-page").css("display", "block");
	$('.sidebar-navigation ul li').removeClass('active');
	$('#sidebar-main').addClass('active');

	// Statistics page
	$('#main-page-title').text(Utils.translate('statistics_page_title'));
	$('#main-page-desc').text(Utils.translate('statistics_page_desc'));

	// Deliveries page
	$('#deliveries-title-div').html(`
		<h4 class="text-uppercase">${Utils.translate('deliveries_page_title')}</h4>
		<p>${Utils.translate('deliveries_page_desc')}</p>
	`);
	$('#new-contracts-text').text(Utils.translate('deliveries_contracts_time').format(config.contracts.time_to_new_contracts));

	
	// Upgrades page
	$('#upgrades-page-title').text(Lang[lang]['upgrades_page_title']);
	$('#upgrades-page-desc').text(Lang[lang]['upgrades_page_desc']);
	$('#stock-upgrade-desc').text(Lang[lang]['upgrade_page_stock_desc']);
	$('#vehicles-upgrade-desc').text(Lang[lang]['upgrade_page_vehicles_desc']);
	$('#boats-upgrade-desc').text(Lang[lang]['upgrade_page_boats_desc']);
	$('#properties-upgrade-desc').text(Lang[lang]['upgrade_page_properties_desc']);
	$('#rods-upgrade-desc').text(Lang[lang]['upgrade_page_rods_desc']);
	$('#lake-upgrade-desc').text(Lang[lang]['upgrade_page_lake_desc']);
	$('#swan-upgrade-desc').text(Lang[lang]['upgrade_page_swan_desc']);
	$('#sea-upgrade-desc').text(Lang[lang]['upgrade_page_sea_desc']);


	// Store page
	$('#store-title-div').html(`
		<h4 class="text-uppercase">${Utils.translate('store_page_title')}</h4>
		<p>${Utils.translate('store_page_desc')}</p>
	`);	
	
	// owned vehicle page
	$('#owned-vehicle-title-div').html(`
		<h4 class="text-uppercase">${Utils.translate('owned_vehicle_page_title')}</h4>
		<p>${Utils.translate('owned_vehicle_page_desc')}</p>
	`);

	// owned property page
	$('#owned-property-title-div').html(`
		<h4 class="text-uppercase">${Utils.translate('owned_property_page_title')}</h4>
		<p>${Utils.translate('owned_property_page_desc')}</p>
	`);

	// Bank page
	$('#bank-title-div').html(`
				<h4 class="text-uppercase">${Utils.translate('bank_page_title')}</h4>
				<p>${Utils.translate('bank_page_desc')}</p>
			`);
	$('#withdraw-money-btn').text(Utils.translate('bank_page_withdraw'));
	$('#deposit-money-btn').text(Utils.translate('bank_page_deposit'));
	$('#active-loans-title').text(`${Utils.translate('bank_page_active_loans')}`);
	$('#bank-balance-text').text(`${Utils.translate('bank_page_balance')}`);
	$('#bank-loans-title').text(`${Utils.translate('bank_page_loan_title')}`);
	$('#bank-loans-desc').html(`${Utils.translate('bank_page_loan_desc').format(Utils.currencyFormat(config.max_loan))}`);
	$('#bank-loans-btn').text(`${Utils.translate('bank_page_loan_button')}`);
	$('#loan-value-title').text(`${Utils.translate('bank_page_loan_value_title')}`);
	$('#loan-daily-title').text(`${Utils.translate('bank_page_loan_daily_title')}`);
	$('#loan-remaining-title').text(`${Utils.translate('bank_page_loan_remaining_title')}`);

	$('#loan-modal-title').text(`${Utils.translate('bank_page_loan_title')}`);
	$('#loan-modal-desc').text(`${Utils.translate('bank_page_loan_modal_desc')}`);
	$('#loan-modal-label-4').html(`<span style="font-weight: 600;">${Utils.currencyFormat(config.loans[0][0])}</span> ${Utils.translate('bank_page_loan_modal_item').format(Utils.currencyFormat(config.loans[0][1]))}`);
	$('#loan-modal-label-3').html(`<span style="font-weight: 600;">${Utils.currencyFormat(config.loans[1][0])}</span> ${Utils.translate('bank_page_loan_modal_item').format(Utils.currencyFormat(config.loans[1][1]))}`);
	$('#loan-modal-label-2').html(`<span style="font-weight: 600;">${Utils.currencyFormat(config.loans[2][0])}</span> ${Utils.translate('bank_page_loan_modal_item').format(Utils.currencyFormat(config.loans[2][1]))}`);
	$('#loan-modal-label-1').html(`<span style="font-weight: 600;">${Utils.currencyFormat(config.loans[3][0])}</span> ${Utils.translate('bank_page_loan_modal_item').format(Utils.currencyFormat(config.loans[3][1]))}`);
	$('#loan-modal-cancel').text(`${Utils.translate('bank_page_modal_cancel')}`);
	$('#loan-modal-submit').text(`${Utils.translate('bank_page_loan_modal_submit')}`);

	$('#deposit-modal-title').text(`${Utils.translate('bank_page_deposit_modal_title')}`);
	$('#deposit-modal-desc').text(`${Utils.translate('bank_page_deposit_modal_desc')}`);
	$('#deposit-modal-money-amount').attr('placeholder', Utils.translate('bank_page_modal_placeholder'));
	$('#deposit-modal-cancel').text(`${Utils.translate('bank_page_modal_cancel')}`);
	$('#deposit-modal-submit').text(`${Utils.translate('bank_page_deposit_modal_submit')}`);

	$('#withdraw-modal-title').text(`${Utils.translate('bank_page_withdraw_modal_title')}`);
	$('#withdraw-modal-desc').text(`${Utils.translate('bank_page_withdraw_modal_desc')}`);
	$('#withdraw-modal-money-amount').attr('placeholder', Utils.translate('bank_page_modal_placeholder'));
	$('#withdraw-modal-cancel').text(`${Utils.translate('bank_page_modal_cancel')}`);
	$('#withdraw-modal-submit').text(`${Utils.translate('bank_page_withdraw_modal_submit')}`);

	$('#nav-bar').html(`
		<li id="sidebar-profile" onclick="openPage('profile')" class="active">
			<i class="fas fa-user-circle"></i>
			<span class="tooltip">${Utils.translate('sidebar_profile')}</span>
		</li>
		<li onclick="openPage('deliveries')">
			<i class="fas fa-fish"></i>
			<span class="tooltip">${Utils.translate('sidebar_deliveries')}</span>
		</li>
		<li onclick="openPage('dive')">
			<i class="fas fa-swimmer"></i>
			<span class="tooltip">${Utils.translate('sidebar_dives')}</span>
		</li>
		<li onclick="openPage('upgrades','stock-upgrades')">
			<i class="fas fa-trophy"></i>
			<span class="tooltip">Habilidades</span>
		</li>
		<li onclick="openPage(4)">
			<i class="fas fa-cog"></i>
			<span class="tooltip">Equipamentos</span>
		</li>
		<li onclick="openPage('store','store-vehicle')">
			<i class="fas fa-shopping-cart"></i>
			<span class="tooltip">Lojas</span>
		</li>
		<li onclick="openPage('owned-vehicle','owned-vehicle')">
			<i class="fas fa-ship"></i>
			<span class="tooltip">Veiculos</span>
		</li>
		<li onclick="openPage('owned-property')">
			<i class="fas fa-warehouse"></i>
			<span class="tooltip">Propriedade</span>
		</li>
		<li onclick="openPage(8)">
			<i class="far fa-map"></i>
			<span class="tooltip">Guia</span>
		</li>
		<li onclick="openPage('bank')">
			<i class="fas fa-university"></i>
			<span class="tooltip">${Utils.translate('sidebar_bank')}</span>
		</li>
		<li onclick="closeUI()">
			<i class="fas fa-times"></i>
			<span class="tooltip">${Utils.translate('sidebar_close')}</span>
		</li>
	`);

	$('.navigation-tabs-container').empty();
	// $('#navigation-tab-farms').append(getTabHTML('farms'));
	$('#store-navigation-tab').append(getStoreTabHTML());
	$('#navigation-tab-upgrades').append(getUpgradesTabHTML());
	$('#owned-vehicle-navigation-tab').append(getOwnedVehicleTabHTML());
}

function renderStatisticsPage() {

}

function renderDeliveriesPage(fishing_available_contracts, fishing_life_users) {
	$('#list-available-contracts').empty();
	for (const contract of fishing_available_contracts) {
		let reward_html = ``;
		let reward_icon = ``;
		if (contract.money_reward) {
			reward_icon = 'coins';
			reward_html = Utils.currencyFormat(contract.money_reward, 0);
		} else {
			let items = JSON.parse(contract.item_reward);
			reward_icon = 'box';
			reward_html = `${items.amount}x ${items.display_name}`;
		}
		let start_button = `<button onclick="startContract(${contract.id})" type="button" class="btn btn-primary btn-block"><small>${Utils.translate('deliveries_start_button')}</small></button>`;
		if (fishing_life_users.user_id == contract.progress) {
			start_button = `<button onclick="cancelContract()" type="button" class="btn btn-outline-danger btn-block"><small>${Utils.translate('deliveries_cancel_button')}</small></button>`;
		}

		let required_items = JSON.parse(contract.required_items);

		$('#list-available-contracts').append(`
				<div class="col-3 mb-3">
					<div class="card h-100">
						<div>
							<img src="${contract.image}" class="card-img-top w-100">
						</div>
						<div class="card-body pt-2 px-0">
							<div class="mx-3">
								<h6 style="font-size: 17px; font-weight: 600;">${contract.name}</h6>
							</div>
							<div class="mx-3">
								<h6>${contract.description}</h6>
							</div>
							<div onclick="viewLocation(${contract.id})" class="view-location-container mx-3">
								<a class="text-primary" style="font-weight: 600;"><i class="fa-solid fa-map-pin mr-2"></i>${Utils.translate('deliveries_see_location')}</a>
							</div>
							<div class="my-2 card-line"></div>
							<div class="mx-3 d-flex align-items-center">
								<i class="fa-solid fa-fish text-primary"></i>
								<div class="d-flex flex-column ml-2">
									<span class="small text-muted">${Utils.translate('deliveries_required_items')}</span>
									<span style="font-weight: 600;">${required_items.map(item => `${item.amount}x ${item.display_name}`).join(', ')}</span>
								</div>
							</div>
							<div class="my-2 card-line"></div>
							<div class="mx-3 d-flex align-items-center">
								<i class="fa-solid fa-${reward_icon} text-primary"></i>
								<div class="d-flex flex-column ml-2">
									<span class="small text-muted">${Utils.translate('deliveries_reward')}</span>
									<span style="font-weight: 600;">${reward_html}</span>
								</div>
							</div>
							<div class="my-2 card-line"></div>
							<div class="mx-4">
								${start_button}
							</div>
						</div>
					</div>
				</div>
			`);
	}
}

function renderStorePage(available_items_store) {
	$('#store-vehicle-page-list').empty();
	$('#store-boat-page-list').empty();
	$('#store-property-page-list').empty();
	for (const vehicleIdx of Object.keys(available_items_store.vehicle)) {
		const vehicle = available_items_store.vehicle[vehicleIdx]
		if (vehicle) {
			let button_html = `<button onclick="buyVehicle('${vehicleIdx}','vehicle')" type="button" class="btn btn-primary btn-block mt-4"><small>${Utils.translate('store_page_vehicle_buy')}</small></button>`
			let store_vehicle_locked_background = ``
			//if (garage_upgrade_level < vehicle.level) {
			//	button_html = `<div class="d-flex align-items-center"><i class="fa-solid fa-lock text-muted"></i><span class=" ml-2 small">${Utils.translate('store_page_vehicle_unlock_text').format(vehicle.level)}</span></div>`
			//	store_locked_background = `store-locked-background`
			//}
			$('#store-vehicle-page-list').append(`
			<div class="col-3 mb-3">
			<div class="card h-100">
				<div class="card ${store_vehicle_locked_background}">
					<img src="${vehicle.image}" class="card-img-top w-100">
					<div class="card-body pt-0 px-0 pb-2">
						<div class="d-flex flex-row justify-content-between mt-3 px-3"> <span class="text-muted">${Utils.translate('store_page_vehicle_name')}</span>
							<h6>${vehicle.name}</h6>
						</div>
						<hr class="mt-2 mx-3">
						<div class="d-flex flex-row justify-content-between px-3">
							<div class="d-flex flex-column"><span class="text-muted">${Utils.translate('store_page_vehicle_price')}</span></div>
							<div class="d-flex flex-column">
								<h5 class="mb-0">${Utils.currencyFormat(vehicle.price)}</h5>
							</div>
						</div>
						<div class="mx-3 mt-3 mb-2">
							${button_html}
						</div>
					</div>
				</div>
				</div>
				</div>
			`);
		}
	}	
	
	for (const boatIdx of Object.keys(available_items_store.boat)) {
		const boat = available_items_store.boat[boatIdx]
		if (boat) {
			let button_html = `<button onclick="buyVehicle('${boatIdx}','boat')" type="button" class="btn btn-primary btn-block mt-4"><small>${Utils.translate('store_buy_boat')}</small></button>`
			let store_boat_locked_background = ``
			//if (garage_upgrade_level < vehicle.level) {
			//	button_html = `<div class="d-flex align-items-center"><i class="fa-solid fa-lock text-muted"></i><span class=" ml-2 small">${Utils.translate('store_page_vehicle_unlock_text').format(vehicle.level)}</span></div>`
			//	store_locked_background = `store-locked-background`
			//}
			$('#store-boat-page-list').append(`
			<div class="col-3 mb-3">
			<div class="card h-100">
				<div class="card ${store_boat_locked_background}">
					<img src="${boat.image}" class="card-img-top w-100">
					<div class="card-body pt-0 px-0 pb-2">
						<div class="d-flex flex-row justify-content-between mt-3 px-3"> <span class="text-muted">${Utils.translate('store_page_boat_name')}</span>
							<h6>${boat.name}</h6>
						</div>
						<hr class="mt-2 mx-3">
						<div class="d-flex flex-row justify-content-between px-3">
							<div class="d-flex flex-column"><span class="text-muted">${Utils.translate('store_page_vehicle_price')}</span></div>
							<div class="d-flex flex-column">
								<h5 class="mb-0">${Utils.currencyFormat(boat.price)}</h5>
							</div>
						</div>
						<div class="mx-3 mt-3 mb-2">
							${button_html}
						</div>
					</div>
				</div>
				</div>
				</div>
			`);
		}
	}	

	for (const propertyIdx of Object.keys(available_items_store.property)) {
		const property = available_items_store.property[propertyIdx]
		if (property) {
			let button_html = `<button onclick="buyProperty('${propertyIdx}','property')" type="button" class="btn btn-primary btn-block mt-4"><small>${Utils.translate('store_buy_property')}</small></button>`
			let store_property_locked_background = ``
			//if (garage_upgrade_level < vehicle.level) {
			//	button_html = `<div class="d-flex align-items-center"><i class="fa-solid fa-lock text-muted"></i><span class=" ml-2 small">${Utils.translate('store_page_vehicle_unlock_text').format(vehicle.level)}</span></div>`
			//	store_locked_background = `store-locked-background`
			//}
			$('#store-property-page-list').append(`
			<div class="col-3 mb-3">
			<div class="card h-100">
				<div class="card ${store_property_locked_background}">
					<img src="${property.image}" class="card-img-top w-100">
					<div class="card-body pt-0 px-0 pb-2">
						<div class="d-flex flex-row justify-content-between mt-3 px-3"> <span class="text-muted">${Utils.translate('store_page_boat_name')}</span>
							<h6>${property.name}</h6>
						</div>
						<hr class="mt-2 mx-3">
						<div class="d-flex flex-row justify-content-between px-3">
							<div class="d-flex flex-column"><span class="text-muted">${Utils.translate('store_page_vehicle_price')}</span></div>
							<div class="d-flex flex-column">
								<h5 class="mb-0">${Utils.currencyFormat(property.price)}</h5>
							</div>
						</div>
						<hr class="mt-2 mx-3">
						<div class="d-flex flex-row justify-content-between px-3">
							<div class="d-flex flex-column"><span class="text-muted">${Utils.translate('store_page_property_capacity')}</span></div>
							<div class="d-flex flex-column">
								<h5 class="mb-0">${property.warehouse_capacity}</h5>
							</div>
						</div>
						<hr class="mt-2 mx-3">
						<div class="d-flex flex-row justify-content-between m-auto">
							<div onclick="viewLocation(${propertyIdx})" class="view-location-container mx-3">
							<a class="text-primary" style="font-weight: 600;"><i class="fa-solid fa-map-pin"></i>${Utils.translate('deliveries_see_location')}</a>
						</div>
						</div>
						

						<div class="mx-3 mt-3 mb-2">
							${button_html}
						</div>
					</div>
				</div>
				</div>
				</div>
			`);
		}
	}	
}


function renderOwnedVehiclesPage(owned_vehicles,vehicles) {
	$('#owned-vehicle-page-list').empty();
	$('#owned-boat-page-list').empty();
	for (const vehicle_data of owned_vehicles.vehicles) {
		const vehicle = vehicles.vehicle[vehicle_data.vehicle]
		if (vehicle) {
			let vehicle_health_str = ``;
			let vehicle_fuel_str = ``;
			let health_color = `success`;
			let fuel_color = `amber`;
			if (vehicle_data.health < 900) {
				let remaining_health = Math.floor((1000 - vehicle_data.health)/10)
				let total_repair_price = vehicle.repair_price*remaining_health
				vehicle_health_str = `<a class="dropdown-item text-black-50" onclick="repairVehicle('${vehicle_data.id}')">${Utils.translate('vehicles_page_repair').format(Utils.currencyFormat(total_repair_price,0))}</a>`;

				if (vehicle_data.health < 200) {
					health_color = "danger"
				}
			}
			if (vehicle_data.fuel < 90) {
				let remaining_fuel = Math.floor(100 - vehicle_data.fuel)
				let total_refuel_price = vehicle.refuel_price*remaining_fuel
				vehicle_fuel_str = `<a class="dropdown-item text-black-50" onclick="refuelVehicle('${vehicle_data.id}')">${Utils.translate('vehicles_page_refuel').format(Utils.currencyFormat(total_refuel_price,0))}</a>`;

				if (vehicle_data.fuel < 20) {
					fuel_color = "danger"
				}
			}
			$('#owned-vehicle-page-list').append(`
				<li class="d-flex card-theme justify-content-between">
					<div style="width: 300px;" class="d-flex flex-row align-items-center">
						<img src="${vehicle.image}" class="img-width">
						<div class="ml-2">
							<h6 class="mb-0">${vehicle.name}</h6>
							<div class="d-flex flex-row mt-1 text-black-50 text-nowrap small">
								<div style="min-width: 110px;" ><i class="fas fa-tag"></i><span class="small ml-2">${Utils.translate('vehicles_page_vehicle_plate')} ${JSON.parse(vehicle_data.properties).plate ?? Utils.translate('vehicles_page_unregistered')}</span></div>
								<div class="ml-3"><i class="fas fa-route"></i><span class="small ml-2">${Utils.translate('vehicles_page_distance').format(Utils.numberFormat(vehicle_data.traveled_distance/1000,2))}</span></div>
							</div>
						</div>
					</div>
					<div class="d-flex flex-row text-black-50 small">
						<div class="d-flex align-items-center">
							<img src="images/car-engine.png" width="35px">
							<div class="ml-1">
								<span>${Utils.translate('vehicles_page_vehicle_condition')}</span>
								<div id="vehicle-health" class="progress mt-0 mb-0" style="height: 10px; width: 200px;"><div class="progress-bar bg-${health_color}" role="progressbar" style="width: ${vehicle_data.health/10}%" aria-valuenow="0.0" aria-valuemin="0" aria-valuemax="100"></div></div>
							</div>
						</div>
						<div class="d-flex align-items-center ml-3">
							<img src="images/fuel.png" width="35px">
							<div class="ml-1">
								<span>${Utils.translate('vehicles_page_vehicle_fuel')}</span>
								<div id="vehicle-health" class="progress mt-0 mb-0" style="height: 10px; width: 200px;"><div class="progress-bar bg-${fuel_color}" role="progressbar" style="width: ${vehicle_data.fuel}%" aria-valuenow="0.0" aria-valuemin="0" aria-valuemax="100"></div></div>
							</div>
						</div>
					</div>
					<div class="d-flex flex-row align-items-center mr-2">
						<div class="dropdown">
							<svg data-toggle="dropdown" class="dropdown-options-svg" xmlns="http://www.w3.org/2000/svg" version="1.1" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:svgjs="http://svgjs.com/svgjs" width="512" height="512" x="0" y="0" viewBox="0 0 515.555 515.555" style="enable-background:new 0 0 512 512" xml:space="preserve"><g><path xmlns="http://www.w3.org/2000/svg" d="m496.679 212.208c25.167 25.167 25.167 65.971 0 91.138s-65.971 25.167-91.138 0-25.167-65.971 0-91.138 65.971-25.167 91.138 0" data-original="#000000" style="" class=""></path><path xmlns="http://www.w3.org/2000/svg" d="m303.347 212.208c25.167 25.167 25.167 65.971 0 91.138s-65.971 25.167-91.138 0-25.167-65.971 0-91.138 65.971-25.167 91.138 0" data-original="#000000" style="" class=""></path><path xmlns="http://www.w3.org/2000/svg" d="m110.014 212.208c25.167 25.167 25.167 65.971 0 91.138s-65.971 25.167-91.138 0-25.167-65.971 0-91.138 65.971-25.167 91.138 0" data-original="#000000" style="" class=""></path></g></svg>
							<div class="dropdown-menu">
								${vehicle_health_str}
								${vehicle_fuel_str}
								<a class="dropdown-item text-black-50" onclick="spawnVehicle('${vehicle_data.id}')">${Utils.translate('vehicles_page_spawn')}</a>
								<a class="dropdown-item" onclick="sellVehicle('${vehicle_data.id}')" style="color:#ff0000c2;">${Utils.translate('vehicles_page_sell')}</a>
							</div>
						</div>
					</div>
				</li>
			`);
		}
	}		

	for (const boat_data of owned_vehicles.boats) {
		const boat = vehicles.vehicle[boat_data.vehicle]
		if (boat) {
			let vehicle_health_str = ``;
			let vehicle_fuel_str = ``;
			let health_color = `success`;
			let fuel_color = `amber`;
			if (boat_data.health < 900) {
				let remaining_health = Math.floor((1000 - boat_data.health)/10)
				let total_repair_price = boat.repair_price*remaining_health
				vehicle_health_str = `<a class="dropdown-item text-black-50" onclick="repairVehicle('${boat_data.id}')">${Utils.translate('vehicles_page_repair').format(Utils.currencyFormat(total_repair_price,0))}</a>`;

				if (boat_data.health < 200) {
					health_color = "danger"
				}
			}
			if (boat_data.fuel < 90) {
				let remaining_fuel = Math.floor(100 - boat_data.fuel)
				let total_refuel_price = boat.refuel_price*remaining_fuel
				vehicle_fuel_str = `<a class="dropdown-item text-black-50" onclick="refuelVehicle('${boat_data.id}')">${Utils.translate('vehicles_page_refuel').format(Utils.currencyFormat(total_refuel_price,0))}</a>`;

				if (boat_data.fuel < 20) {
					fuel_color = "danger"
				}
			}
			$('#owned-boat-page-list').append(`
				<li class="d-flex card-theme justify-content-between">
					<div style="width: 300px;" class="d-flex flex-row align-items-center">
						<img src="${boat.image}" class="img-width">
						<div class="ml-2">
							<h6 class="mb-0">${boat.name}</h6>
							<div class="d-flex flex-row mt-1 text-black-50 text-nowrap small">
								<div style="min-width: 110px;" ><i class="fas fa-tag"></i><span class="small ml-2">${Utils.translate('vehicles_page_vehicle_plate')} ${JSON.parse(boat_data.properties).plate ?? Utils.translate('vehicles_page_unregistered')}</span></div>
								<div class="ml-3"><i class="fas fa-route"></i><span class="small ml-2">${Utils.translate('vehicles_page_distance').format(Utils.numberFormat(boat_data.traveled_distance/1000,2))}</span></div>
							</div>
						</div>
					</div>
					<div class="d-flex flex-row text-black-50 small">
						<div class="d-flex align-items-center">
							<img src="images/car-engine.png" width="35px">
							<div class="ml-1">
								<span>${Utils.translate('vehicles_page_vehicle_condition')}</span>
								<div id="vehicle-health" class="progress mt-0 mb-0" style="height: 10px; width: 200px;"><div class="progress-bar bg-${health_color}" role="progressbar" style="width: ${boat_data.health/10}%" aria-valuenow="0.0" aria-valuemin="0" aria-valuemax="100"></div></div>
							</div>
						</div>
						<div class="d-flex align-items-center ml-3">
							<img src="images/fuel.png" width="35px">
							<div class="ml-1">
								<span>${Utils.translate('vehicles_page_vehicle_fuel')}</span>
								<div id="vehicle-health" class="progress mt-0 mb-0" style="height: 10px; width: 200px;"><div class="progress-bar bg-${fuel_color}" role="progressbar" style="width: ${boat_data.fuel}%" aria-valuenow="0.0" aria-valuemin="0" aria-valuemax="100"></div></div>
							</div>
						</div>
					</div>
					<div class="d-flex flex-row align-items-center mr-2">
						<div class="dropdown">
							<svg data-toggle="dropdown" class="dropdown-options-svg" xmlns="http://www.w3.org/2000/svg" version="1.1" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:svgjs="http://svgjs.com/svgjs" width="512" height="512" x="0" y="0" viewBox="0 0 515.555 515.555" style="enable-background:new 0 0 512 512" xml:space="preserve"><g><path xmlns="http://www.w3.org/2000/svg" d="m496.679 212.208c25.167 25.167 25.167 65.971 0 91.138s-65.971 25.167-91.138 0-25.167-65.971 0-91.138 65.971-25.167 91.138 0" data-original="#000000" style="" class=""></path><path xmlns="http://www.w3.org/2000/svg" d="m303.347 212.208c25.167 25.167 25.167 65.971 0 91.138s-65.971 25.167-91.138 0-25.167-65.971 0-91.138 65.971-25.167 91.138 0" data-original="#000000" style="" class=""></path><path xmlns="http://www.w3.org/2000/svg" d="m110.014 212.208c25.167 25.167 25.167 65.971 0 91.138s-65.971 25.167-91.138 0-25.167-65.971 0-91.138 65.971-25.167 91.138 0" data-original="#000000" style="" class=""></path></g></svg>
							<div class="dropdown-menu">
								${vehicle_health_str}
								${vehicle_fuel_str}
								<a class="dropdown-item text-black-50" onclick="spawnVehicle('${boat_data.id}')">${Utils.translate('vehicles_page_spawn')}</a>
								<a class="dropdown-item" onclick="sellVehicle('${boat_data.id}')" style="color:#ff0000c2;">${Utils.translate('vehicles_page_sell')}</a>
							</div>
						</div>
					</div>
				</li>
			`);
		}
	}		
}

function renderOwnedPropertiesPage(owned_properties,properties) {
	$('#owned-property-page-list').empty();
	for (const property_data of owned_properties) {
		const property = properties.vehicle[property_data.property]
		if (property) {
			let vehicle_health_str = ``;
			let vehicle_fuel_str = ``;
			let health_color = `success`;
			let fuel_color = `amber`;
			if (property_data.health < 900) {
				let remaining_health = Math.floor((1000 - property_data.health)/10)
				let total_repair_price = property.repair_price*remaining_health
				vehicle_health_str = `<a class="dropdown-item text-black-50" onclick="repairVehicle('${property_data.id}')">${Utils.translate('vehicles_page_repair').format(Utils.currencyFormat(total_repair_price,0))}</a>`;

				if (property_data.health < 200) {
					health_color = "danger"
				}
			}
			if (property_data.fuel < 90) {
				let remaining_fuel = Math.floor(100 - property_data.fuel)
				let total_refuel_price = property.refuel_price*remaining_fuel
				vehicle_fuel_str = `<a class="dropdown-item text-black-50" onclick="refuelVehicle('${property_data.id}')">${Utils.translate('vehicles_page_refuel').format(Utils.currencyFormat(total_refuel_price,0))}</a>`;

				if (property_data.fuel < 20) {
					fuel_color = "danger"
				}
			}
			$('#owned-property-page-list').append(`
				<li class="d-flex card-theme justify-content-between">
					<div style="width: 300px;" class="d-flex flex-row align-items-center">
						<img src="${property.image}" class="img-width">
						<div class="ml-2">
							<h6 class="mb-0">${property.name}</h6>
							<div class="d-flex flex-row mt-1 text-black-50 text-nowrap small">
								<div style="min-width: 110px;" ><i class="fas fa-tag"></i><span class="small ml-2">${Utils.translate('vehicles_page_vehicle_plate')} ${JSON.parse(property_data.properties).plate ?? Utils.translate('vehicles_page_unregistered')}</span></div>
								<div class="ml-3"><i class="fas fa-route"></i><span class="small ml-2">${Utils.translate('vehicles_page_distance').format(Utils.numberFormat(property_data.traveled_distance/1000,2))}</span></div>
							</div>
						</div>
					</div>
					<div class="d-flex flex-row text-black-50 small">
						<div class="d-flex align-items-center">
							<img src="images/car-engine.png" width="35px">
							<div class="ml-1">
								<span>${Utils.translate('vehicles_page_vehicle_condition')}</span>
								<div id="vehicle-health" class="progress mt-0 mb-0" style="height: 10px; width: 200px;"><div class="progress-bar bg-${health_color}" role="progressbar" style="width: ${property_data.health/10}%" aria-valuenow="0.0" aria-valuemin="0" aria-valuemax="100"></div></div>
							</div>
						</div>
						<div class="d-flex align-items-center ml-3">
							<img src="images/fuel.png" width="35px">
							<div class="ml-1">
								<span>${Utils.translate('vehicles_page_vehicle_fuel')}</span>
								<div id="vehicle-health" class="progress mt-0 mb-0" style="height: 10px; width: 200px;"><div class="progress-bar bg-${fuel_color}" role="progressbar" style="width: ${property_data.fuel}%" aria-valuenow="0.0" aria-valuemin="0" aria-valuemax="100"></div></div>
							</div>
						</div>
					</div>
					<div class="d-flex flex-row align-items-center mr-2">
						<div class="dropdown">
							<svg data-toggle="dropdown" class="dropdown-options-svg" xmlns="http://www.w3.org/2000/svg" version="1.1" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:svgjs="http://svgjs.com/svgjs" width="512" height="512" x="0" y="0" viewBox="0 0 515.555 515.555" style="enable-background:new 0 0 512 512" xml:space="preserve"><g><path xmlns="http://www.w3.org/2000/svg" d="m496.679 212.208c25.167 25.167 25.167 65.971 0 91.138s-65.971 25.167-91.138 0-25.167-65.971 0-91.138 65.971-25.167 91.138 0" data-original="#000000" style="" class=""></path><path xmlns="http://www.w3.org/2000/svg" d="m303.347 212.208c25.167 25.167 25.167 65.971 0 91.138s-65.971 25.167-91.138 0-25.167-65.971 0-91.138 65.971-25.167 91.138 0" data-original="#000000" style="" class=""></path><path xmlns="http://www.w3.org/2000/svg" d="m110.014 212.208c25.167 25.167 25.167 65.971 0 91.138s-65.971 25.167-91.138 0-25.167-65.971 0-91.138 65.971-25.167 91.138 0" data-original="#000000" style="" class=""></path></g></svg>
							<div class="dropdown-menu">
								${vehicle_health_str}
								${vehicle_fuel_str}
								<a class="dropdown-item text-black-50" onclick="spawnVehicle('${property_data.id}')">${Utils.translate('vehicles_page_spawn')}</a>
								<a class="dropdown-item" onclick="sellVehicle('${property_data.id}')" style="color:#ff0000c2;">${Utils.translate('vehicles_page_sell')}</a>
							</div>
						</div>
					</div>
				</li>
			`);
		}
	}	
}

function renderStockPage(property){
	// stock property page modal
	var max_stock  = 100 //TODO UPGRADES 
	let stock_capacity_percent = numberFormat((property.stock_amount * 100)/max_stock,1);
	$('#owned-property-title-div').html(`
		<h4 class="text-uppercase">${Utils.translate('stock_title')}</h4>
		<p>${Utils.translate('stock_page_desc')}</p>
		<div class="d-flex">
			<div style="width: 100%;">
				<div class="d-flex justify-content-between">
					<h5 id="stock-title" class="font-weight-semi-bold"></h5>
					<span class="small text-muted" id="stock-values"></span>
				</div>
				<div id="stock-progress-bar" class="progress">
					
				</div>
			</div>
			<div class="d-flex align-items-center">
				<button style="height: fit-content;" data-toggle="modal" data-target="#exportStockModal" class="btn btn-primary ml-4 text-nowrap" id="stock-button-export"></button>
			</div>
		</div>
	`);

	$('#stock-values').text(`${property.stock_amount}/${max_stock} ${Utils.translate('weight_unit')}`);
	$('#stock-progress-bar').html(`<div class="progress-bar bg-primary" role="progressbar" style="width: ${stock_capacity_percent}%" aria-valuenow="${stock_capacity_percent}" aria-valuemin="0" aria-valuemax="100">${stock_capacity_percent}%</div>`);
	
	$('#export-stock-form-container').html(`
		<p id="modal-p-export-stock">${Utils.translate('stock_page_export_modal_desc')}</p>
		<label class="mb-0" for="input-export-stock-select-item">${Utils.translate('stock_pag>e_modal_label_item')}</label>
		<select id="input-export-stock-select-item" class="form-control mb-2" name="select" style="width:100%;" onchange="setMaxInputExportStock();" required="required"></select>
		<label class="mb-0" for="input-export-stock-select-vehicle">${Utils.translate('stock_page_modal_label_vehicle')}</label>
		<select id="input-export-stock-select-vehicle" class="form-control mb-2" name="select" style="width:100%;" onchange="setMaxInputExportStock();" required="required"></select>
		<div id="export-stock-form-input-container" class="d-flex flex-column align-items-start">

		</div>
	`);
	$('#input-export-stock-select-item').empty();
	$(`#stock-button-export`).click({factory_stock: property.stock, relationship_upgrade: property.relationship_upgrade}, openExportStockModal);

	$('#stock-table-body').empty();
	/*let upgrade = config.factory.upgrades.relationship[property.relationship_upgrade-1]
	if (Object.keys(arr_stock).length > 0) {
		arr_stock = Object.keys(arr_stock).sort().reduce(
			(obj, key) => { 
			obj[key] = arr_stock[key]; 
			return obj;
			}, 
			{}
		);
		
		for (const stock_item in arr_stock) {
			if (config.items[stock_item]) {
				$('#stock-table-body').append(`
					<tr data-toggle="modal" data-target="#withdraw-item-modal" data-item="${stock_item}" data-amount="${arr_stock[stock_item]}" class="border-right border-left border-bottom">
						<td class="d-flex align-items-center text-left"><img src="${config.items[stock_item].img}" class="mr-2" style="width: 40px;">${config.items[stock_item].name}</td>
						<td class="align-middle">${config.items[stock_item].weight} ${Utils.translate('weight_unit')}</td>
						<td class="align-middle">${Utils.currencyFormat(config.items[stock_item].price_to_export + (config.items[stock_item].price_to_export * (upgrade?.level_reward ?? 0)/100))}</td>
						<td class="align-middle">${arr_stock[stock_item]}</td>
					</tr>
				`);
			} else {
				console.log(`Item '${stock_item}' from your stock does not exist in config, contact the server owner to remove that item from your database`)
			}
		}
	} else {
		$('#stock-table-body').append(`
			<tr class="border-right border-left border-bottom">
				<td colspan="4">${Utils.translate('stock_page_table_empty')}</td>
			</tr>
		`);
	}

	let has_readable_inventory_item = false
	$('#stock-player-table-body').empty();
	for (const inventory_item of item.data.player_inventory) {
		if (inventory_item && config.items[inventory_item.name]) {
			has_readable_inventory_item = true
			$('#stock-player-table-body').append(`
				<tr data-toggle="modal" data-target="#deposit-item-modal" data-item="${inventory_item.name}" data-amount="${inventory_item.amount}" class="border-right border-left border-bottom">
					<td class="d-flex align-items-center text-left"><img src="${config.items[inventory_item.name].img}" class="mr-2" style="width: 40px;">${config.items[inventory_item.name].name}</td>
					<td class="align-middle">${config.items[inventory_item.name].weight} ${Utils.translate('weight_unit')}</td>
					<td class="align-middle">${inventory_item.amount}</td>
				</tr>
			`);
		}
	}
	if (!has_readable_inventory_item) {
		$('#stock-player-table-body').append(`
			<tr class="border-right border-left border-bottom">
				<td colspan="3">${Utils.translate('stock_page_table_empty')}</td>
			</tr>
		`);
	}
*/

}

function renderUpgradesPage(upgrades,user){ 
	$('.upgrade-list').empty();
	let level = 1
	for (const upgrade_type in upgrades) {
		level = 1
		for (const upgrade of upgrades[upgrade_type]) {
			let current_level = user[upgrade_type+'_upgrade']
			$('#'+upgrade_type+'-upgrades-list').append(getUpgradeItemHTML(upgrade,upgrade_type,level,current_level));
			level++;
		}
	}
}

function renderBankPage(fishing_life_users, item, fishing_life_loans) {
	$('#bank-money').text(Utils.currencyFormat(fishing_life_users.money, 0));

	$('#withdraw-modal-money-available').text(`${Utils.translate('bank_page_modal_money_available').format(Utils.currencyFormat(fishing_life_users.money))}`);
	$('#deposit-modal-money-available').text(`${Utils.translate('bank_page_modal_money_available').format(Utils.currencyFormat(item.data.available_money))}`);

	$('#loan-table-body').empty();
	$('#loan-table-container').css('display', 'none');
	for (const loan of fishing_life_loans) {
		$('#loan-table-body').append(`
				<tr>
					<td>${Utils.currencyFormat(loan.loan)}</td>
					<td>${Utils.currencyFormat(loan.day_cost)}</td>
					<td class="text-danger">${Utils.currencyFormat(loan.remaining_amount)}</td>
					<td><button class="btn btn-outline-primary" style="min-width: 200px;" onclick="payLoan(${loan.id})" >${Utils.translate('bank_page_loan_pay')}</button></td>
				</tr>
			`);
		$('#loan-table-container').css('display', '');
	}
}

/*=================
	FUNCTIONS
=================*/

function openPage(pageN,tab){
	$(".pages").css("display", "none");
	$(`.${pageN}-page`).css("display", "block");
	if (pageN == "bank") {
		$("#player-info-money-container").removeClass("d-flex")
		$("#player-info-money-container").addClass("d-none")
	} else {
		$("#player-info-money-container").removeClass("d-none")
		$("#player-info-money-container").addClass("d-flex")
	}
	if (tab) {
		$(".tabs").css("display", "none");
		$("."+tab+"-tab").css("display", "");
		$('.navigation-tab').removeClass('selected');
		$('.navigation-tab-available').addClass('selected');
	}

	var titleHeight = $(`#${pageN}-title-div`).outerHeight(true) ?? 0;
	var footerHeight = $(`#${pageN}-footer-div`).outerHeight(true) ?? 0;	
	if(tab){
		var tabHeight = $(`#${pageN}-navigation-tab`).outerHeight(true) ?? 0;
		$(':root').css(`--${pageN}-title-height`, (titleHeight+footerHeight + tabHeight) + 'px');
	}else{
		$(':root').css(`--${pageN}-title-height`, (titleHeight+footerHeight) + 'px');
	}
	
}

function getStoreTabHTML() {
	return getTabHTML('store','store-vehicle',Utils.translate('navigation_tab_store_vehicle'),true)
	+ getTabHTML('store','store-boat',Utils.translate('navigation_tab_store_boat'))
	+ getTabHTML('store','store-property',Utils.translate('navigation_tab_store_property'))
}


function getUpgradesTabHTML() {
	return getTabHTML('upgrades','upgrades-vehicles',Lang[lang]['navigation_tab_upgrades_vehicles'],true)
	+ getTabHTML('upgrades','upgrades-boats',Lang[lang]['navigation_tab_upgrades_boats'])
	+ getTabHTML('upgrades','upgrades-properties',Lang[lang]['navigation_tab_upgrades_properties'])
	+ getTabHTML('upgrades','upgrades-rods',Lang[lang]['navigation_tab_upgrades_rods'])
	+ getTabHTML('upgrades','upgrades-lake',Lang[lang]['navigation_tab_upgrades_lake'])
	+ getTabHTML('upgrades','upgrades-swan',Lang[lang]['navigation_tab_upgrades_swan'])
	+ getTabHTML('upgrades','upgrades-sea',Lang[lang]['navigation_tab_upgrades_sea'])
}

function getOwnedVehicleTabHTML() {
	return getTabHTML('owned-vehicle','owned-vehicle',Utils.translate('navigation_tab_owned_vehicle'),true)
	+ getTabHTML('owned-vehicle','owned-boat',Utils.translate('navigation_tab_owned_boat'))
}


function getTabHTML(page,tab,tab_title,selected) {
	let selectedHTML = ""
	if (selected) {
		selectedHTML = "navigation-tab-available selected"
	}
	return `<div class="navigation-tab ${selectedHTML}" onclick="openPage('${page}','${tab}')">
		<h5>${tab_title}</h5>
		<div class="d-flex">
			<div class="border-default"></div>
			<div class="border-selected"></div>
			<div class="border-default"></div>
		</div>
	</div>`
}

function getUpgradeItemHTML(upgrade,upgrade_type,level,current_level) {
	current_level++;
	let upgrade_button = `<button style="height:38px;" class="btn btn-primary btn-block" onclick="buyUpgrade('${upgrade_type}',${level})">${currencyFormat(upgrade.price,0)}</button>`
	if (level > current_level) {
		upgrade_button = `<button style="height:38px;" class="btn btn-secondary btn-block"><i class="fa-solid fa-lock" disabled></i></button>`
	} else if (level < current_level) {
		upgrade_button = `<button style="height:38px;" class="btn btn-outline-success btn-block"><i class="fa-solid fa-check"></i></button>`
	}
	let upgrade_description = Lang[lang]['upgrade_page_' + upgrade_type + '_level'].format(upgrade.level_reward)
	if (upgrade_type == 'stock') {
		upgrade_description = Lang[lang]['upgrade_page_' + upgrade_type + '_level'].format(upgrade.level_reward,upgrade.trademarket_reward)
	}
	return `
		<li class="d-flex card-theme align-items-center">
			<img style="width: 8%;" src="${upgrade.icon}">
			<div style="width: 20%;" class="ml-2">
				<small class="text-black-50">${Lang[lang]['upgrade_page_' + upgrade_type]}</small>
				<h4 class="font-weight-semi-bold">${Lang[lang]['level_abbreviate']}${level}</h4>
			</div>
			<div style="width: 55%;">
				<span class="text-success">${upgrade_description}</span>
			</div>
			<div style="width: 15%;">
				${upgrade_button}
			</div>
		</li>
	`
}

/*=================
	CALLBACKS
=================*/

function closeUI(){
	Utils.post("close","")
}

function startContract(contract_id){
	Utils.post("startContract",{contract_id:contract_id})
}

function cancelContract(){
	Utils.post("cancelContract",{})
}

function viewLocation(contract_id){
	Utils.post("viewLocation",{contract_id:contract_id})
}

function payLoan(loan_id){
	Utils.post("payLoan",{loan_id:loan_id})
}

function changeTheme(dark_theme){
	Utils.post("changeTheme",{dark_theme})
}

function buyVehicle(vehicle_id,type) {
	Utils.post("buyVehicle",{vehicle_id,type})
}

function repairVehicle(vehicle_id) {
	Utils.post("repairVehicle",{vehicle_id})
}
function refuelVehicle(vehicle_id) {
	Utils.post("refuelVehicle",{vehicle_id})
}
function spawnVehicle(vehicle_id) {
	Utils.post("spawnVehicle",{vehicle_id})
}
function sellVehicle(vehicle_id) {
	Utils.showDefaultDangerModal(() => Utils.post("sellVehicle",{vehicle_id}), Utils.translate('confirmation_modal_sell_vehicle')); // TODO: fazer modal de confirmaçao pras outras rotas q são criticas tipo essa de vender veiculo. Pra fazer o modal é só essa linha aqui, o resto é magica
}
function buyProperty(property_id,type) {
	Utils.post("buyProperty",{property_id,type})
}

$(document).ready( function() {
	$('#css-toggle').on('change', function(){
		if($(this).prop("checked") == false){
			// Light theme
			$('#css-bs-light').prop('disabled', false);
			$('#css-light').prop('disabled', false);
			$('#css-bs-dark').prop('disabled', true);
			$('#css-dark').prop('disabled', true);
			$('#dark-theme-icon').css("display", "");
			$('#light-theme-icon').css("display", "none");
			changeTheme(0)
		} else if($(this).prop("checked") == true){
			// Dark theme
			$('#css-bs-dark').prop('disabled', false);
			$('#css-dark').prop('disabled', false);
			$('#css-bs-light').prop('disabled', true);
			$('#css-light').prop('disabled', true);
			$('#dark-theme-icon').css("display", "none");
			$('#light-theme-icon').css("display", "");
			changeTheme(1)
		}
	});

	$("#form-deposit-money").on('submit', function(e){
		e.preventDefault();
		var form = $('#form-deposit-money').serializeArray();
		$('#deposit-modal-money-amount').val(null);
		$("#deposit-modal").modal('hide');
		Utils.post("depositMoney",{amount:form[0].value})
	});

	$("#form-withdraw-money").on('submit', function(e){
		e.preventDefault();
		var form = $('#form-withdraw-money').serializeArray();
		$('#withdraw-modal-money-amount').val(null);
		$("#withdraw-modal").modal('hide');
		Utils.post("withdrawMoney",{amount:form[0].value})
	});

	$("#form-loan").on('submit', function(e){
		e.preventDefault();
		var form = $('#form-loan').serializeArray();
		$("#loans-modal").modal('hide');
		Utils.post("loan",{loan_id:form[0].value})
	});
})