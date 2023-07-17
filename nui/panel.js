let lang = 'en';
let config = {};
let resource_name = ''

window.addEventListener('message', function (event) {
	var item = event.data;
	if (item.resourceName) {
		resource_name = item.resourceName
	}
	if (item.notification) {
		if (item.notification_type == "success") {
			vt.successo(item.notification,{
				position: "top-right",
				duration: 8000
			});
		} else if (item.notification_type == "info") {
			vt.importante(item.notification,{
				position: "top-right",
				duration: 8000
			});
		} else if (item.notification_type == "warning") {
			vt.aviso(item.notification,{
				position: "top-right",
				duration: 8000
			});
		} else if (item.notification_type == "error") {
			vt.erro(item.notification,{
				position: "top-right",
				duration: 8000
			});
		}
	} else if (item.openOwnerUI) {
		config = item.data.config;
		lang = item.data.config.lang;
		let fishing_life_users = item.data.fishing_life_users;
		let fishing_life_loans = item.data.fishing_life_loans;
		let fishing_available_contracts = item.data.fishing_available_contracts;
		let owned_vehicles = item.data.owned_vehicles
		let owned_properties = item.data.owned_properties
		let available_items_store = config.available_items_store;

		if (item.isUpdate != true) {
			// Open on first time
			renderStaticTexts();

			$('#css-toggle').prop('checked', fishing_life_users.dark_theme).change();
			openPage('profile');
		}

		/*
		* PLAYER INFO HEADER
		*/
		$("#player-info-level").text(numberFormat(config.player_level,0))
		$("#player-info-skill").text(numberFormat(fishing_life_users.skill_points,0))
		$("#player-info-money").text(currencyFormat(fishing_life_users.money,0))

		renderStatisticsPage();
		renderDeliveriesPage(fishing_available_contracts, fishing_life_users);
		renderStorePage(available_items_store);
		renderOwnedVehiclesPage(owned_vehicles,available_items_store);
		renderOwnedPropertiesPage(owned_properties,available_items_store);
		renderBankPage(fishing_life_users, item, fishing_life_loans);

		createListeners();
	} else if(item.openPropertyUI){
		//$(".main").css("display", "none");
		console.log(item)
		renderStockPage()
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
	$('#main-page-title').text(Lang[lang]['statistics_page_title']);
	$('#main-page-desc').text(Lang[lang]['statistics_page_desc']);

	// Deliveries page
	$('#deliveries-title-div').html(`
		<h4 class="text-uppercase">${Lang[lang]['deliveries_page_title']}</h4>
		<p>${Lang[lang]['deliveries_page_desc']}</p>
	`);
	$('#new-contracts-text').text(Lang[lang]['deliveries_contracts_time'].format(config.contracts.time_to_new_contracts));

	
	// Store page
	$('#store-title-div').html(`
		<h4 class="text-uppercase">${Lang[lang]['store_page_title']}</h4>
		<p>${Lang[lang]['store_page_desc']}</p>
	`);	
	
	// owned vehicle page
	$('#owned-vehicle-title-div').html(`
		<h4 class="text-uppercase">${Lang[lang]['owned_vehicle_page_title']}</h4>
		<p>${Lang[lang]['owned_vehicle_page_desc']}</p>
	`);

	// owned property page
	$('#owned-property-title-div').html(`
		<h4 class="text-uppercase">${Lang[lang]['owned_property_page_title']}</h4>
		<p>${Lang[lang]['owned_property_page_desc']}</p>
	`);

	// Bank page
	$('#bank-title-div').html(`
				<h4 class="text-uppercase">${Lang[lang]['bank_page_title']}</h4>
				<p>${Lang[lang]['bank_page_desc']}</p>
			`);
	$('#withdraw-money-btn').text(Lang[lang]['bank_page_withdraw']);
	$('#deposit-money-btn').text(Lang[lang]['bank_page_deposit']);
	$('#active-loans-title').text(`${Lang[lang]['bank_page_active_loans']}`);
	$('#bank-balance-text').text(`${Lang[lang]['bank_page_balance']}`);
	$('#bank-loans-title').text(`${Lang[lang]['bank_page_loan_title']}`);
	$('#bank-loans-desc').html(`${Lang[lang]['bank_page_loan_desc'].format(currencyFormat(config.max_loan))}`);
	$('#bank-loans-btn').text(`${Lang[lang]['bank_page_loan_button']}`);
	$('#loan-value-title').text(`${Lang[lang]['bank_page_loan_value_title']}`);
	$('#loan-daily-title').text(`${Lang[lang]['bank_page_loan_daily_title']}`);
	$('#loan-remaining-title').text(`${Lang[lang]['bank_page_loan_remaining_title']}`);

	$('#loan-modal-title').text(`${Lang[lang]['bank_page_loan_title']}`);
	$('#loan-modal-desc').text(`${Lang[lang]['bank_page_loan_modal_desc']}`);
	$('#loan-modal-label-4').html(`<span style="font-weight: 600;">${currencyFormat(config.loans[0][0])}</span> ${Lang[lang]['bank_page_loan_modal_item'].format(currencyFormat(config.loans[0][1]))}`);
	$('#loan-modal-label-3').html(`<span style="font-weight: 600;">${currencyFormat(config.loans[1][0])}</span> ${Lang[lang]['bank_page_loan_modal_item'].format(currencyFormat(config.loans[1][1]))}`);
	$('#loan-modal-label-2').html(`<span style="font-weight: 600;">${currencyFormat(config.loans[2][0])}</span> ${Lang[lang]['bank_page_loan_modal_item'].format(currencyFormat(config.loans[2][1]))}`);
	$('#loan-modal-label-1').html(`<span style="font-weight: 600;">${currencyFormat(config.loans[3][0])}</span> ${Lang[lang]['bank_page_loan_modal_item'].format(currencyFormat(config.loans[3][1]))}`);
	$('#loan-modal-cancel').text(`${Lang[lang]['bank_page_modal_cancel']}`);
	$('#loan-modal-submit').text(`${Lang[lang]['bank_page_loan_modal_submit']}`);

	$('#deposit-modal-title').text(`${Lang[lang]['bank_page_deposit_modal_title']}`);
	$('#deposit-modal-desc').text(`${Lang[lang]['bank_page_deposit_modal_desc']}`);
	$('#deposit-modal-money-amount').attr('placeholder', Lang[lang]['bank_page_modal_placeholder']);
	$('#deposit-modal-cancel').text(`${Lang[lang]['bank_page_modal_cancel']}`);
	$('#deposit-modal-submit').text(`${Lang[lang]['bank_page_deposit_modal_submit']}`);

	$('#withdraw-modal-title').text(`${Lang[lang]['bank_page_withdraw_modal_title']}`);
	$('#withdraw-modal-desc').text(`${Lang[lang]['bank_page_withdraw_modal_desc']}`);
	$('#withdraw-modal-money-amount').attr('placeholder', Lang[lang]['bank_page_modal_placeholder']);
	$('#withdraw-modal-cancel').text(`${Lang[lang]['bank_page_modal_cancel']}`);
	$('#withdraw-modal-submit').text(`${Lang[lang]['bank_page_withdraw_modal_submit']}`);

	$('#nav-bar').html(`
		<li id="sidebar-profile" onclick="openPage('profile')" class="active">
			<i class="fas fa-user-circle"></i>
			<span class="tooltip">${Lang[lang]['sidebar_profile']}</span>
		</li>
		<li onclick="openPage('deliveries')">
			<i class="fas fa-fish"></i>
			<span class="tooltip">${Lang[lang]['sidebar_deliveries']}</span>
		</li>
		<li onclick="openPage('dive')">
			<i class="fas fa-swimmer"></i>
			<span class="tooltip">${Lang[lang]['sidebar_dives']}</span>
		</li>
		<li onclick="openPage(3)">
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
			<span class="tooltip">${Lang[lang]['sidebar_bank']}</span>
		</li>
		<li onclick="closeUI()">
			<i class="fas fa-times"></i>
			<span class="tooltip">${Lang[lang]['sidebar_close']}</span>
		</li>
	`);

	$('.navigation-tabs-container').empty();
	// $('#navigation-tab-farms').append(getTabHTML('farms'));
	$('#store-navigation-tab').append(getStoreTabHTML());
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
			reward_html = currencyFormat(contract.money_reward, 0);
		} else {
			let items = JSON.parse(contract.item_reward);
			reward_icon = 'box';
			reward_html = `${items.amount}x ${items.display_name}`;
		}
		let start_button = `<button onclick="startContract(${contract.id})" type="button" class="btn btn-primary btn-block"><small>${Lang[lang]['deliveries_start_button']}</small></button>`;
		if (fishing_life_users.user_id == contract.progress) {
			start_button = `<button onclick="cancelContract()" type="button" class="btn btn-outline-danger btn-block"><small>${Lang[lang]['deliveries_cancel_button']}</small></button>`;
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
								<a class="text-primary" style="font-weight: 600;"><i class="fa-solid fa-map-pin mr-2"></i>${Lang[lang]['deliveries_see_location']}</a>
							</div>
							<div class="my-2 card-line"></div>
							<div class="mx-3 d-flex align-items-center">
								<i class="fa-solid fa-fish text-primary"></i>
								<div class="d-flex flex-column ml-2">
									<span class="small text-muted">${Lang[lang]['deliveries_required_items']}</span>
									<span style="font-weight: 600;">${required_items.map(item => `${item.amount}x ${item.display_name}`).join(', ')}</span>
								</div>
							</div>
							<div class="my-2 card-line"></div>
							<div class="mx-3 d-flex align-items-center">
								<i class="fa-solid fa-${reward_icon} text-primary"></i>
								<div class="d-flex flex-column ml-2">
									<span class="small text-muted">${Lang[lang]['deliveries_reward']}</span>
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
			let button_html = `<button onclick="buyVehicle('${vehicleIdx}','vehicle')" type="button" class="btn btn-primary btn-block mt-4"><small>${Lang[lang]['store_page_vehicle_buy']}</small></button>`
			let store_vehicle_locked_background = ``
			//if (garage_upgrade_level < vehicle.level) {
			//	button_html = `<div class="d-flex align-items-center"><i class="fa-solid fa-lock text-muted"></i><span class=" ml-2 small">${Lang[lang]['store_page_vehicle_unlock_text'].format(vehicle.level)}</span></div>`
			//	store_locked_background = `store-locked-background`
			//}
			$('#store-vehicle-page-list').append(`
			<div class="col-3 mb-3">
			<div class="card h-100">
				<div class="card ${store_vehicle_locked_background}">
					<img src="${vehicle.image}" class="card-img-top w-100">
					<div class="card-body pt-0 px-0 pb-2">
						<div class="d-flex flex-row justify-content-between mt-3 px-3"> <span class="text-muted">${Lang[lang]['store_page_vehicle_name']}</span>
							<h6>${vehicle.name}</h6>
						</div>
						<hr class="mt-2 mx-3">
						<div class="d-flex flex-row justify-content-between px-3">
							<div class="d-flex flex-column"><span class="text-muted">${Lang[lang]['store_page_vehicle_price']}</span></div>
							<div class="d-flex flex-column">
								<h5 class="mb-0">${new Intl.NumberFormat(config.format.location, { style: 'currency', currency: config.format.currency }).format(vehicle.price)}</h5>
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
			let button_html = `<button onclick="buyVehicle('${boatIdx}','boat')" type="button" class="btn btn-primary btn-block mt-4"><small>${Lang[lang]['store_buy_boat']}</small></button>`
			let store_boat_locked_background = ``
			//if (garage_upgrade_level < vehicle.level) {
			//	button_html = `<div class="d-flex align-items-center"><i class="fa-solid fa-lock text-muted"></i><span class=" ml-2 small">${Lang[lang]['store_page_vehicle_unlock_text'].format(vehicle.level)}</span></div>`
			//	store_locked_background = `store-locked-background`
			//}
			$('#store-boat-page-list').append(`
			<div class="col-3 mb-3">
			<div class="card h-100">
				<div class="card ${store_boat_locked_background}">
					<img src="${boat.image}" class="card-img-top w-100">
					<div class="card-body pt-0 px-0 pb-2">
						<div class="d-flex flex-row justify-content-between mt-3 px-3"> <span class="text-muted">${Lang[lang]['store_page_boat_name']}</span>
							<h6>${boat.name}</h6>
						</div>
						<hr class="mt-2 mx-3">
						<div class="d-flex flex-row justify-content-between px-3">
							<div class="d-flex flex-column"><span class="text-muted">${Lang[lang]['store_page_vehicle_price']}</span></div>
							<div class="d-flex flex-column">
								<h5 class="mb-0">${new Intl.NumberFormat(config.format.location, { style: 'currency', currency: config.format.currency }).format(boat.price)}</h5>
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
			let button_html = `<button onclick="buyProperty('${propertyIdx}','property')" type="button" class="btn btn-primary btn-block mt-4"><small>${Lang[lang]['store_buy_property']}</small></button>`
			let store_property_locked_background = ``
			//if (garage_upgrade_level < vehicle.level) {
			//	button_html = `<div class="d-flex align-items-center"><i class="fa-solid fa-lock text-muted"></i><span class=" ml-2 small">${Lang[lang]['store_page_vehicle_unlock_text'].format(vehicle.level)}</span></div>`
			//	store_locked_background = `store-locked-background`
			//}
			$('#store-property-page-list').append(`
			<div class="col-3 mb-3">
			<div class="card h-100">
				<div class="card ${store_property_locked_background}">
					<img src="${property.image}" class="card-img-top w-100">
					<div class="card-body pt-0 px-0 pb-2">
						<div class="d-flex flex-row justify-content-between mt-3 px-3"> <span class="text-muted">${Lang[lang]['store_page_boat_name']}</span>
							<h6>${property.name}</h6>
						</div>
						<hr class="mt-2 mx-3">
						<div class="d-flex flex-row justify-content-between px-3">
							<div class="d-flex flex-column"><span class="text-muted">${Lang[lang]['store_page_vehicle_price']}</span></div>
							<div class="d-flex flex-column">
								<h5 class="mb-0">${new Intl.NumberFormat(config.format.location, { style: 'currency', currency: config.format.currency }).format(property.price)}</h5>
							</div>
						</div>
						<hr class="mt-2 mx-3">
						<div class="d-flex flex-row justify-content-between px-3">
							<div class="d-flex flex-column"><span class="text-muted">${Lang[lang]['store_page_property_capacity']}</span></div>
							<div class="d-flex flex-column">
								<h5 class="mb-0">${property.warehouse_capacity}</h5>
							</div>
						</div>
						<hr class="mt-2 mx-3">
						<div class="d-flex flex-row justify-content-between m-auto">
							<div onclick="viewLocation(${propertyIdx})" class="view-location-container mx-3">
							<a class="text-primary" style="font-weight: 600;"><i class="fa-solid fa-map-pin"></i>${Lang[lang]['deliveries_see_location']}</a>
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
				vehicle_health_str = `<a class="dropdown-item text-black-50" onclick="repairVehicle('${vehicle_data.id}')">${Lang[lang]['vehicles_page_repair'].format(new Intl.NumberFormat(config.format.location, { maximumFractionDigits: 0, minimumFractionDigits: 0, style: 'currency', currency: config.format.currency }).format(total_repair_price))}</a>`;

				if (vehicle_data.health < 200) {
					health_color = "danger"
				}
			}
			if (vehicle_data.fuel < 90) {
				let remaining_fuel = Math.floor(100 - vehicle_data.fuel)
				let total_refuel_price = vehicle.refuel_price*remaining_fuel
				vehicle_fuel_str = `<a class="dropdown-item text-black-50" onclick="refuelVehicle('${vehicle_data.id}')">${Lang[lang]['vehicles_page_refuel'].format(new Intl.NumberFormat(config.format.location, { maximumFractionDigits: 0, minimumFractionDigits: 0, style: 'currency', currency: config.format.currency }).format(total_refuel_price))}</a>`;

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
								<div style="min-width: 110px;" ><i class="fas fa-tag"></i><span class="small ml-2">${Lang[lang]['vehicles_page_vehicle_plate']} ${JSON.parse(vehicle_data.properties).plate ?? Lang[lang]['vehicles_page_unregistered']}</span></div>
								<div class="ml-3"><i class="fas fa-route"></i><span class="small ml-2">${Lang[lang]['vehicles_page_distance'].format(new Intl.NumberFormat(config.format.location, { maximumFractionDigits: 2, minimumFractionDigits: 2 }).format(vehicle_data.traveled_distance/1000))}</span></div>
							</div>
						</div>
					</div>
					<div class="d-flex flex-row text-black-50 small">
						<div class="d-flex align-items-center">
							<img src="images/car-engine.png" width="35px">
							<div class="ml-1">
								<span>${Lang[lang]['vehicles_page_vehicle_condition']}</span>
								<div id="vehicle-health" class="progress mt-0 mb-0" style="height: 10px; width: 200px;"><div class="progress-bar bg-${health_color}" role="progressbar" style="width: ${vehicle_data.health/10}%" aria-valuenow="0.0" aria-valuemin="0" aria-valuemax="100"></div></div>
							</div>
						</div>
						<div class="d-flex align-items-center ml-3">
							<img src="images/fuel.png" width="35px">
							<div class="ml-1">
								<span>${Lang[lang]['vehicles_page_vehicle_fuel']}</span>
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
								<a class="dropdown-item text-black-50" onclick="spawnVehicle('${vehicle_data.id}')">${Lang[lang]['vehicles_page_spawn']}</a>
								<a class="dropdown-item" onclick="sellVehicle('${vehicle_data.id}')" style="color:#ff0000c2;">${Lang[lang]['vehicles_page_sell']}</a>
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
				vehicle_health_str = `<a class="dropdown-item text-black-50" onclick="repairVehicle('${boat_data.id}')">${Lang[lang]['vehicles_page_repair'].format(new Intl.NumberFormat(config.format.location, { maximumFractionDigits: 0, minimumFractionDigits: 0, style: 'currency', currency: config.format.currency }).format(total_repair_price))}</a>`;

				if (boat_data.health < 200) {
					health_color = "danger"
				}
			}
			if (boat_data.fuel < 90) {
				let remaining_fuel = Math.floor(100 - boat_data.fuel)
				let total_refuel_price = boat.refuel_price*remaining_fuel
				vehicle_fuel_str = `<a class="dropdown-item text-black-50" onclick="refuelVehicle('${boat_data.id}')">${Lang[lang]['vehicles_page_refuel'].format(new Intl.NumberFormat(config.format.location, { maximumFractionDigits: 0, minimumFractionDigits: 0, style: 'currency', currency: config.format.currency }).format(total_refuel_price))}</a>`;

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
								<div style="min-width: 110px;" ><i class="fas fa-tag"></i><span class="small ml-2">${Lang[lang]['vehicles_page_vehicle_plate']} ${JSON.parse(boat_data.properties).plate ?? Lang[lang]['vehicles_page_unregistered']}</span></div>
								<div class="ml-3"><i class="fas fa-route"></i><span class="small ml-2">${Lang[lang]['vehicles_page_distance'].format(new Intl.NumberFormat(config.format.location, { maximumFractionDigits: 2, minimumFractionDigits: 2 }).format(boat_data.traveled_distance/1000))}</span></div>
							</div>
						</div>
					</div>
					<div class="d-flex flex-row text-black-50 small">
						<div class="d-flex align-items-center">
							<img src="images/car-engine.png" width="35px">
							<div class="ml-1">
								<span>${Lang[lang]['vehicles_page_vehicle_condition']}</span>
								<div id="vehicle-health" class="progress mt-0 mb-0" style="height: 10px; width: 200px;"><div class="progress-bar bg-${health_color}" role="progressbar" style="width: ${boat_data.health/10}%" aria-valuenow="0.0" aria-valuemin="0" aria-valuemax="100"></div></div>
							</div>
						</div>
						<div class="d-flex align-items-center ml-3">
							<img src="images/fuel.png" width="35px">
							<div class="ml-1">
								<span>${Lang[lang]['vehicles_page_vehicle_fuel']}</span>
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
								<a class="dropdown-item text-black-50" onclick="spawnVehicle('${boat_data.id}')">${Lang[lang]['vehicles_page_spawn']}</a>
								<a class="dropdown-item" onclick="sellVehicle('${boat_data.id}')" style="color:#ff0000c2;">${Lang[lang]['vehicles_page_sell']}</a>
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
				vehicle_health_str = `<a class="dropdown-item text-black-50" onclick="repairVehicle('${property_data.id}')">${Lang[lang]['vehicles_page_repair'].format(new Intl.NumberFormat(config.format.location, { maximumFractionDigits: 0, minimumFractionDigits: 0, style: 'currency', currency: config.format.currency }).format(total_repair_price))}</a>`;

				if (property_data.health < 200) {
					health_color = "danger"
				}
			}
			if (property_data.fuel < 90) {
				let remaining_fuel = Math.floor(100 - property_data.fuel)
				let total_refuel_price = property.refuel_price*remaining_fuel
				vehicle_fuel_str = `<a class="dropdown-item text-black-50" onclick="refuelVehicle('${property_data.id}')">${Lang[lang]['vehicles_page_refuel'].format(new Intl.NumberFormat(config.format.location, { maximumFractionDigits: 0, minimumFractionDigits: 0, style: 'currency', currency: config.format.currency }).format(total_refuel_price))}</a>`;

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
								<div style="min-width: 110px;" ><i class="fas fa-tag"></i><span class="small ml-2">${Lang[lang]['vehicles_page_vehicle_plate']} ${JSON.parse(property_data.properties).plate ?? Lang[lang]['vehicles_page_unregistered']}</span></div>
								<div class="ml-3"><i class="fas fa-route"></i><span class="small ml-2">${Lang[lang]['vehicles_page_distance'].format(new Intl.NumberFormat(config.format.location, { maximumFractionDigits: 2, minimumFractionDigits: 2 }).format(property_data.traveled_distance/1000))}</span></div>
							</div>
						</div>
					</div>
					<div class="d-flex flex-row text-black-50 small">
						<div class="d-flex align-items-center">
							<img src="images/car-engine.png" width="35px">
							<div class="ml-1">
								<span>${Lang[lang]['vehicles_page_vehicle_condition']}</span>
								<div id="vehicle-health" class="progress mt-0 mb-0" style="height: 10px; width: 200px;"><div class="progress-bar bg-${health_color}" role="progressbar" style="width: ${property_data.health/10}%" aria-valuenow="0.0" aria-valuemin="0" aria-valuemax="100"></div></div>
							</div>
						</div>
						<div class="d-flex align-items-center ml-3">
							<img src="images/fuel.png" width="35px">
							<div class="ml-1">
								<span>${Lang[lang]['vehicles_page_vehicle_fuel']}</span>
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
								<a class="dropdown-item text-black-50" onclick="spawnVehicle('${property_data.id}')">${Lang[lang]['vehicles_page_spawn']}</a>
								<a class="dropdown-item" onclick="sellVehicle('${property_data.id}')" style="color:#ff0000c2;">${Lang[lang]['vehicles_page_sell']}</a>
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
	$('#owned-property-title-div').html(`
		<h4 class="text-uppercase">${Lang[lang]['stock_title']}</h4>
		<p>${Lang[lang]['stock_page_desc']}</p>
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

	$('#stock-values').text(`${property.stock_amount}/${max_stock} ${Lang[lang]['weight_unit']}`);
	$('#stock-progress-bar').html(`<div class="progress-bar bg-primary" role="progressbar" style="width: ${stock_capacity_percent}%" aria-valuenow="${stock_capacity_percent}" aria-valuemin="0" aria-valuemax="100">${stock_capacity_percent}%</div>`);
	
	$('#export-stock-form-container').html(`
		<p id="modal-p-export-stock">${Lang[lang]['stock_page_export_modal_desc']}</p>
		<label class="mb-0" for="input-export-stock-select-item">${Lang[lang]['stock_page_modal_label_item']}</label>
		<select id="input-export-stock-select-item" class="form-control mb-2" name="select" style="width:100%;" onchange="setMaxInputExportStock();" required="required"></select>
		<label class="mb-0" for="input-export-stock-select-vehicle">${Lang[lang]['stock_page_modal_label_vehicle']}</label>
		<select id="input-export-stock-select-vehicle" class="form-control mb-2" name="select" style="width:100%;" onchange="setMaxInputExportStock();" required="required"></select>
		<div id="export-stock-form-input-container" class="d-flex flex-column align-items-start">

		</div>
	`);
	$('#input-export-stock-select-vehicle').empty();
	$('#input-export-stock-select-vehicle').append(`<option value="" selected disabled>${Lang[lang]['stock_page_modal_placeholder_vehicle']}</option>`);
	for (const vehicle of factory_vehicles) {
		$('#input-export-stock-select-vehicle').append(`<option vehicle_id="${vehicle.id}" trunk="${config.vehicles[vehicle.vehicle].trunk}">${config.vehicles[vehicle.vehicle].name} (${config.vehicles[vehicle.vehicle].trunk} ${Lang[lang]['weight_unit']})</option>`);
	}
	if (item.data.last_vehicle && item.data.last_vehicle.network_id) {
		$('#input-export-stock-select-vehicle').append(`<option vehicle_id="spawned_from_world" trunk="${item.data.last_vehicle.vehicle_data.trunk}">${item.data.last_vehicle.vehicle_data.name} (${item.data.last_vehicle.vehicle_data.trunk} ${Lang[lang]['weight_unit']})</option>`);
	}
	$('#input-export-stock-select-item').empty();
	$(`#stock-button-export`).click({factory_stock: property.stock, relationship_upgrade: property.relationship_upgrade}, openExportStockModal);

	$('#stock-table-body').empty();
	let upgrade = config.factory.upgrades.relationship[property.relationship_upgrade-1]
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
						<td class="align-middle">${config.items[stock_item].weight} ${Lang[lang]['weight_unit']}</td>
						<td class="align-middle">${currencyFormat(config.items[stock_item].price_to_export + (config.items[stock_item].price_to_export * (upgrade?.level_reward ?? 0)/100))}</td>
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
				<td colspan="4">${Lang[lang]['stock_page_table_empty']}</td>
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
					<td class="align-middle">${config.items[inventory_item.name].weight} ${Lang[lang]['weight_unit']}</td>
					<td class="align-middle">${inventory_item.amount}</td>
				</tr>
			`);
		}
	}
	if (!has_readable_inventory_item) {
		$('#stock-player-table-body').append(`
			<tr class="border-right border-left border-bottom">
				<td colspan="3">${Lang[lang]['stock_page_table_empty']}</td>
			</tr>
		`);
	}


}

function renderBankPage(fishing_life_users, item, fishing_life_loans) {
	$('#bank-money').text(currencyFormat(fishing_life_users.money, 0));

	$('#withdraw-modal-money-available').text(`${Lang[lang]['bank_page_modal_money_available'].format(currencyFormat(fishing_life_users.money))}`);
	$('#deposit-modal-money-available').text(`${Lang[lang]['bank_page_modal_money_available'].format(currencyFormat(item.data.available_money))}`);

	$('#loan-table-body').empty();
	$('#loan-table-container').css('display', 'none');
	for (const loan of fishing_life_loans) {
		$('#loan-table-body').append(`
				<tr>
					<td>${currencyFormat(loan.loan)}</td>
					<td>${currencyFormat(loan.day_cost)}</td>
					<td class="text-danger">${currencyFormat(loan.remaining_amount)}</td>
					<td><button class="btn btn-outline-primary" style="min-width: 200px;" onclick="payLoan(${loan.id})" >${Lang[lang]['bank_page_loan_pay']}</button></td>
				</tr>
			`);
		$('#loan-table-container').css('display', '');
	}
}

/*=================
	FUNCTIONS
=================*/
  
document.onkeyup = function(data){
	if (data.which == 27){
		// $("#buyModal").modal('hide');
		
		$("#stock-modal").modal('hide');
		closeUI();
	}
};

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
	return getTabHTML('store','store-vehicle',Lang[lang]['navigation_tab_store_vehicle'],true)
	+ getTabHTML('store','store-boat',Lang[lang]['navigation_tab_store_boat'])
	+ getTabHTML('store','store-property',Lang[lang]['navigation_tab_store_property'])
}

function getOwnedVehicleTabHTML() {
	return getTabHTML('owned-vehicle','owned-vehicle',Lang[lang]['navigation_tab_owned_vehicle'],true)
	+ getTabHTML('owned-vehicle','owned-boat',Lang[lang]['navigation_tab_owned_boat'])
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
/*=================
	CALLBACKS
=================*/

function closeUI(){
	post("close","")
}

function startContract(contract_id){
	post("startContract",{contract_id:contract_id})
}

function cancelContract(){
	post("cancelContract",{})
}

function viewLocation(contract_id){
	post("viewLocation",{contract_id:contract_id})
}

function payLoan(loan_id){
	post("payLoan",{loan_id:loan_id})
}

function changeTheme(dark_theme){
	post("changeTheme",{dark_theme})
}

function buyVehicle(vehicle_id,type) {
	post("buyVehicle",{vehicle_id,type})
}

function repairVehicle(vehicle_id) {
	post("repairVehicle",{vehicle_id})
}
function refuelVehicle(vehicle_id) {
	post("refuelVehicle",{vehicle_id})
}
function spawnVehicle(vehicle_id) {
	post("spawnVehicle",{vehicle_id})
}
function sellVehicle(vehicle_id) {
	post("sellVehicle",{vehicle_id})
}

function buyProperty(property_id,type) {
	post("buyProperty",{property_id,type})
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
		post("depositMoney",{amount:form[0].value})
	});

	$("#form-withdraw-money").on('submit', function(e){
		e.preventDefault();
		var form = $('#form-withdraw-money').serializeArray();
		$('#withdraw-modal-money-amount').val(null);
		$("#withdraw-modal").modal('hide');
		post("withdrawMoney",{amount:form[0].value})
	});

	$("#form-loan").on('submit', function(e){
		e.preventDefault();
		var form = $('#form-loan').serializeArray();
		$("#loans-modal").modal('hide');
		post("loan",{loan_id:form[0].value})
	});
})

/*=================
	FUNCTIONS
=================*/

function InvalidMsg(textbox,min,max) {
	if (textbox.value == '') {
		textbox.setCustomValidity(Lang[config.lang]['str_fill_field']);
	}
	else if(textbox.validity.typeMismatch){
		textbox.setCustomValidity(Lang[config.lang]['str_invalid_value']);
	}
	else if(textbox.validity.rangeUnderflow){
		textbox.setCustomValidity(Lang[config.lang]['str_more_than'].format(min));
	}
	else if(textbox.validity.rangeOverflow){
		textbox.setCustomValidity(Lang[config.lang]['str_less_than'].format(max));
	}
	else if(textbox.validity.stepMismatch){
		textbox.setCustomValidity(Lang[config.lang]['str_invalid_value']);
	} else {
		textbox.setCustomValidity('');
	}
	return true;
}

if (!String.prototype.format) {
    String.prototype.format = function() {
        var args = arguments;
        return this.replace(/{(\d+)}/g, function(match, number) { 
        return typeof args[number] != 'undefined'
            ? args[number]
            : match
        ;
        });
    };
}

function post(event,data){
	$.post(getRoute("post"), JSON.stringify({event,data}),
	function (datab) {
		if (datab) {
			console.log(datab)
		}
	});
}

function getRoute(name) {
	return `http://${resource_name}/${name}`;
}

function timeConverter(UNIX_timestamp,locale){
	var a = new Date(UNIX_timestamp * 1000);
	var time = a.toLocaleString(locale);
	return time;
}

function currencyFormat(number,zeros) {
	if (zeros != null) {
		return new Intl.NumberFormat(config.format.location, { style: 'currency', currency: config.format.currency, maximumFractionDigits: zeros, minimumFractionDigits: zeros }).format(number)
	} else {
		return new Intl.NumberFormat(config.format.location, { style: 'currency', currency: config.format.currency }).format(number)
	}
}

function numberFormat(number,zeros) {
	if (zeros != null) {
		return new Intl.NumberFormat(config.format.location, { maximumFractionDigits: zeros, minimumFractionDigits: zeros }).format(number)
	} else {
		return new Intl.NumberFormat(config.format.location, {  }).format(number)
	}
}

// Notification
(() => {
	const toastPosition = {
		TopLeft: "top-left",
		TopCenter: "top-center",
		TopRight: "top-right",
		BottomLeft: "bottom-left",
		BottomCenter: "bottom-center",
		BottomRight: "bottom-right"
	}

	const toastPositionIndex = [
		[toastPosition.TopLeft, toastPosition.TopCenter, toastPosition.TopRight],
		[toastPosition.BottomLeft, toastPosition.BottomCenter, toastPosition.BottomRight]
	]

	const svgs = {
		successo: '<svg viewBox="0 0 426.667 426.667" width="18" height="18"><path d="M213.333 0C95.518 0 0 95.514 0 213.333s95.518 213.333 213.333 213.333c117.828 0 213.333-95.514 213.333-213.333S331.157 0 213.333 0zm-39.134 322.918l-93.935-93.931 31.309-31.309 62.626 62.622 140.894-140.898 31.309 31.309-172.203 172.207z" fill="#6ac259"></path></svg>',
		aviso: '<svg viewBox="0 0 310.285 310.285" width=18 height=18> <path d="M264.845 45.441C235.542 16.139 196.583 0 155.142 0 113.702 0 74.743 16.139 45.44 45.441 16.138 74.743 0 113.703 0 155.144c0 41.439 16.138 80.399 45.44 109.701 29.303 29.303 68.262 45.44 109.702 45.44s80.399-16.138 109.702-45.44c29.303-29.302 45.44-68.262 45.44-109.701.001-41.441-16.137-80.401-45.439-109.703zm-132.673 3.895a12.587 12.587 0 0 1 9.119-3.873h28.04c3.482 0 6.72 1.403 9.114 3.888 2.395 2.485 3.643 5.804 3.514 9.284l-4.634 104.895c-.263 7.102-6.26 12.933-13.368 12.933H146.33c-7.112 0-13.099-5.839-13.345-12.945L128.64 58.594c-.121-3.48 1.133-6.773 3.532-9.258zm23.306 219.444c-16.266 0-28.532-12.844-28.532-29.876 0-17.223 12.122-30.211 28.196-30.211 16.602 0 28.196 12.423 28.196 30.211.001 17.591-11.456 29.876-27.86 29.876z" fill="#FFDA44" /> </svg>',
		importante: '<svg viewBox="0 0 23.625 23.625" width=18 height=18> <path d="M11.812 0C5.289 0 0 5.289 0 11.812s5.289 11.813 11.812 11.813 11.813-5.29 11.813-11.813S18.335 0 11.812 0zm2.459 18.307c-.608.24-1.092.422-1.455.548a3.838 3.838 0 0 1-1.262.189c-.736 0-1.309-.18-1.717-.539s-.611-.814-.611-1.367c0-.215.015-.435.045-.659a8.23 8.23 0 0 1 .147-.759l.761-2.688c.067-.258.125-.503.171-.731.046-.23.068-.441.068-.633 0-.342-.071-.582-.212-.717-.143-.135-.412-.201-.813-.201-.196 0-.398.029-.605.09-.205.063-.383.12-.529.176l.201-.828c.498-.203.975-.377 1.43-.521a4.225 4.225 0 0 1 1.29-.218c.731 0 1.295.178 1.692.53.395.353.594.812.594 1.376 0 .117-.014.323-.041.617a4.129 4.129 0 0 1-.152.811l-.757 2.68a7.582 7.582 0 0 0-.167.736 3.892 3.892 0 0 0-.073.626c0 .356.079.599.239.728.158.129.435.194.827.194.185 0 .392-.033.626-.097.232-.064.4-.121.506-.17l-.203.827zm-.134-10.878a1.807 1.807 0 0 1-1.275.492c-.496 0-.924-.164-1.28-.492a1.57 1.57 0 0 1-.533-1.193c0-.465.18-.865.533-1.196a1.812 1.812 0 0 1 1.28-.497c.497 0 .923.165 1.275.497.353.331.53.731.53 1.196 0 .467-.177.865-.53 1.193z" fill="#006DF0" /> </svg>',
		erro: '<svg viewBox="0 0 51.976 51.976" width=18 height=18> <path d="M44.373 7.603c-10.137-10.137-26.632-10.138-36.77 0-10.138 10.138-10.137 26.632 0 36.77s26.632 10.138 36.77 0c10.137-10.138 10.137-26.633 0-36.77zm-8.132 28.638a2 2 0 0 1-2.828 0l-7.425-7.425-7.778 7.778a2 2 0 1 1-2.828-2.828l7.778-7.778-7.425-7.425a2 2 0 1 1 2.828-2.828l7.425 7.425 7.071-7.071a2 2 0 1 1 2.828 2.828l-7.071 7.071 7.425 7.425a2 2 0 0 1 0 2.828z" fill="#D80027" /> </svg>'
	}

	const styles = `
		.vt-container {
			position: fixed;
			width: 100%;
			height: 100vh;
			top: 0;
			left: 0;
			z-index: 9999;
			display: flex;
			flex-direction: column;
			justify-content: space-between;
			pointer-events: none;
		}

		.vt-row {
			display: flex;
			justify-content: space-between;
		}

		.vt-col {
			flex: 1;
			margin: 10px 20px;
			display: flex;
			flex-direction: column;
			align-items: center;
		}

		.vt-col.top-left,
		.vt-col.bottom-left {
			align-items: flex-start;
		}

		.vt-col.top-right,
		.vt-col.bottom-right {
			align-items: flex-end;
		}

		.vt-card {
			display: flex;
			justify-content: center;
			align-items: center;
			padding: 12px 20px;
			box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
			border-radius: 4px;
			margin: 0px;
			transition: 0.3s all ease-in-out;
			pointer-events: all;
			border-left: 3px solid #8b8b8b;
			cursor: pointer;
		}

		.vt-card.successo {
			border-left: 3px solid #6ec05f;
		}

		.vt-card.aviso {
			border-left: 3px solid #fed953;
		}

		.vt-card.importante {
			border-left: 3px solid #1271ec;
		}

		.vt-card.erro {
			border-left: 3px solid #d60a2e;
		}

		.vt-card .text-group {
			margin-left: 15px;
		}

		.vt-card h4 {
			margin: 0;
			margin-bottom: 10px;
			font-size: 16px;
			font-weight: 500;
		}

		.vt-card p {
			margin: 0;
			font-size: 14px;
		}
	`

	const styleSheet = document.createElement("style")
	styleSheet.innerText = styles.replace((/  |\r\n|\n|\r/gm), "")
	document.head.appendChild(styleSheet)

	const vtContainer = document.createElement("div")
	vtContainer.className = "vt-container"

	for (const ri of [0, 1]) {
		const row = document.createElement("div")
		row.className = "vt-row"

		for (const ci of [0, 1, 2]) {
			const col = document.createElement("div")
			col.className = `vt-col ${toastPositionIndex[ri][ci]}`

			row.appendChild(col)
		}

		vtContainer.appendChild(row)
	}

	document.body.appendChild(vtContainer)

	window.vt = {
		options: {
			title: undefined,
			position: toastPosition.TopCenter,
			duration: 10000,
			closable: true,
			focusable: true,
			callback: undefined
		},
		successo(message, options) {
			show(message, options, "successo")
		},
		importante(message, options) {
			show(message, options, "importante")
		},
		aviso(message, options) {
			show(message, options, "aviso")
		},
		erro(message, options) {
			show(message, options, "erro")
		}
	}

	function show(message = "", options, type) {
		options = { ...window.vt.options, ...options }

		const col = document.getElementsByClassName(options.position)[0]

		const vtCard = document.createElement("div")
		vtCard.className = `vt-card ${type}`
		vtCard.innerHTML += svgs[type]
		vtCard.options = {
			...options, ...{
				message,
				type: type,
				yPos: options.position.indexOf("top") > -1 ? "top" : "bottom",
				isFocus: false
			}
		}

		setVTCardContent(vtCard)
		setVTCardIntroAnim(vtCard)
		setVTCardBindEvents(vtCard)
		autoDestroy(vtCard)

		

		col.appendChild(vtCard)
	}

	function setVTCardContent(vtCard) {
		const textGroupDiv = document.createElement("div")

		textGroupDiv.className = "text-group"

		if (vtCard.options.title) {
			textGroupDiv.innerHTML = `<h4>${vtCard.options.title}</h4>`
		}

		textGroupDiv.innerHTML += `<p>${vtCard.options.message}</p>`

		vtCard.appendChild(textGroupDiv)
	}

	function setVTCardIntroAnim(vtCard) {
		vtCard.style.setProperty(`margin-${vtCard.options.yPos}`, "-15px")
		vtCard.style.setProperty("opacity", "0")

		setTimeout(() => {
			vtCard.style.setProperty(`margin-${vtCard.options.yPos}`, "15px")
			vtCard.style.setProperty("opacity", "1")
		}, 50)
	}

	function setVTCardBindEvents(vtCard) {
		vtCard.addEventListener("click", () => {
			if (vtCard.options.closable) {
				destroy(vtCard)
			}
		})

		vtCard.addEventListener("mouseover", () => {
			vtCard.options.isFocus = vtCard.options.focusable
		})

		vtCard.addEventListener("mouseout", () => {
			vtCard.options.isFocus = false
			autoDestroy(vtCard, vtCard.options.duration)
		})
	}

	function destroy(vtCard) {
		vtCard.style.setProperty(`margin-${vtCard.options.yPos}`, `-${vtCard.offsetHeight}px`)
		vtCard.style.setProperty("opacity", "0")

		setTimeout(() => {
			if(typeof x !== "undefined"){
				vtCard.parentNode.removeChild(v)

				if (typeof vtCard.options.callback === "function") {
					vtCard.options.callback()
				}
			}
		}, 500)
	}

	function autoDestroy(vtCard) {
		if (vtCard.options.duration !== 0) {
			setTimeout(() => {
				if (!vtCard.options.isFocus) {
					destroy(vtCard)
				}
			}, vtCard.options.duration)
		}
	}
})()