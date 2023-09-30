let config = {};
let lang = 'en';
var progress = 0;
var animCancel = false;
var bobbing = false;
var nibble = false;
var bite = false;
var reeling = false;
var fishBite = false;
var tensionIncrease = null; //speed of tension increase. lower = faster/harder
var tensionDecrease = null; //speed of tension decrease. lower = faster/easier
var progressIncrease = null; //speed of percent increase. lower = faster/easier
var progressDecrease = null; //speed of percent decrease. lower = faster/harder
var uiOpen = false;
var _success;
var _fail;
var _gotAway;
var _tooSoon;
var _fishBite ;
var playerFishing = {};
const currentKeysPressed = {};
const fishingreel = document.getElementById("circle-container");
function display(bool) {
	uiOpen = bool;
	if (bool) {
		$("#fishingUI").css("display", "");
	} else {
		$("#fishingUI").css("display", "none");
	}
  }
  display(false)

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
		let fishing_available_dives = item.data.fishing_available_dives;
		let owned_vehicles = item.data.owned_vehicles
		let owned_properties = item.data.owned_properties
		let available_vehicles = item.data.available_vehicles;
		let available_boats = item.data.available_boats;
		let available_properties = item.data.available_properties;
		let available_items_store = config.available_items_store;
		let upgrades = config.upgrades
		let equipments_upgrades = config.equipments_upgrades
		let fishs_available = config.fishs_available
		let swan = config.swan
		let lake = config.lake
		let sea = config.sea

		$(document).off('click',handleClickOnFishingGame)
		if (item.isUpdate != true) {
			// Open on first time
			renderStaticTexts(fishing_life_users,equipments_upgrades);

			$('#css-toggle').prop('checked', fishing_life_users.dark_theme).change();
			openPage('profile');
		}

		/*
		* PLAYER INFO HEADER
		*/
		$("#player-info-level").text(Utils.numberFormat(config.player_level,0))
		$("#player-info-skill").text(Utils.numberFormat(fishing_life_users.skill_points,0))
		$("#player-info-money").text(Utils.currencyFormat(fishing_life_users.money,0))

		renderStatisticsPage(fishing_life_users);
		renderDeliveriesPage(fishing_available_contracts, fishing_life_users);
		renderDivesPage(fishing_available_dives, fishing_life_users);
		renderStorePage(available_items_store,available_vehicles,available_boats,available_properties,owned_properties);
		renderOwnedVehiclesPage(owned_vehicles,available_items_store);
		renderOwnedPropertiesPage(owned_properties,available_items_store, fishs_available);
		renderBankPage(fishing_life_users, item, fishing_life_loans);
		renderUpgradesPage(upgrades,fishing_life_users);
		renderEquipmentsPage(equipments_upgrades,fishing_life_users);
		renderGuidePage(fishs_available,sea,lake,swan);

		createListeners();
	} else if(item.openPropertyUI){
		$(document).off('click',handleClickOnFishingGame)
		config = item.data.config;
		renderStaticTextsProperty()
		/*
		* PLAYER INFO HEADER
		*/
		let available_items_store = config.available_items_store;
		let fishing_life_users = item.data.fishing_life_users;
		let players_items_fishing = item.data.players_items_fishing
		let fishs_available = config.fishs_available
		$("#player-info-level-stock").text(Utils.numberFormat(config.player_level,0))
		$("#player-info-skill-stock").text(Utils.numberFormat(fishing_life_users.skill_points,0))
		$("#player-info-money-stock").text(Utils.currencyFormat(fishing_life_users.money,0))
		renderStockPage(item.property,available_items_store,players_items_fishing,fishs_available)
	}
	if (item.hidemenu){
		$(".main").css("display", "none");
		$(".main-stock").css("display", "none");
	}
	//FISHING AREA
	if (item.type === "start") {
		progress = 0;
		$(document).on('click',handleClickOnFishingGame)
		SetProgress(progress);
		playerFishing = item.player
        let x = item.x * 100 + "%";
        let y = item.y * 100 + "%";
        fishingreel.style.left = x;
        fishingreel.style.top = y;
        fishBite = false;
        animCancel = false;
        bobbing = false;
        nibble = false;
        bite = false;
        reeling = false;
        display(true);  
		$("#text-progress").html(Utils.translate("wait_fish"));
		$("#controls-text-mouse").text(Utils.translate("hook_command"))
		$("#controls-text-esc").text(Utils.translate("exit_fishing"))
		bob()
      } else if (item.type === "updatePos") {
        let x = item.x * 100 + "%";
        let y = item.y * 100 + "%";
        fishingreel.style.left = x;
        fishingreel.style.top = y;
      }
	  else if (item.type === "updateDifficulty") {
		tensionIncrease = item.tensionIncrease;
		tensionDecrease = item.tensionDecrease;
		progressIncrease = item.progressIncrease;
		progressDecrease = item.progressDecrease;
	  }
	   else if (item.type === "close") {
        display(false);
        cancelReset("", true);
		$(document).off('click',handleClickOnFishingGame)
      } else if (item.type === "hide") {
        display(false);
		$(document).off('click',handleClickOnFishingGame)
      } else if (item.type === "show") {
        display(true);
      } else if (item.type === "setLocale") {
		playerFishing = item.player
        _success = item.success;
        _fail = item.fail;
        _gotAway = item.gotaway;
        _tooSoon = item.toosoon;
		_fishBite = item.fishBite
		$("#controls-text-mouse").text(Utils.translate("hook_command"))
		$("#controls-text-esc").text(Utils.translate("exit_fishing"))
      }
	async function bob() {
		SwapScenes("bobber");
		bobbing = true;
		for (let y = 0; y < getDelayOnStartFishing(); y++) {
		  if (animCancel === true) {
			bobbing = false;
			return;
		  }
		  await delay(100);
		}
		$("#text-progress").html("");
		let x = getRandomInt(3, 6);
		for (let counter = 0; counter < x; counter++) {
		  if (animCancel === true) {
			bobbing = false;
			return;
		  }
		  $("#circle-outer").animate(
			{
			  top: "-=20%",
			},
			500
		  );
		  $("#circle-outer").animate(
			{
			  top: "+=20%",
			},
			500
		  );
		  await delay(1000);
		}
		bobbing = false;
		hook();
	  }

	  function getRandomInt(min, max) {
		min = Math.ceil(min);
		max = Math.floor(max);
		return Math.floor(Math.random() * (max - min) + min);
	  }
	
	  function SwapScenes(scene) {    
		if (scene == "bobber") {
			$("#reeling").hide();
			$("#hook").hide();
			$("#circle-inner").hide();
			$("#wrapper").hide();
			$(".progressfish").css("width", "190px");
			$(".progressfish").css("stroke", "white");
			$("#text-progress").html("");
			$("#bobber").show();
		}
		else if (scene == "hook") {
		  $("#reeling").hide();
		  $("#circle-inner").hide();
		  $("#bobber").hide();
		  $(".progressfish").css("width", "140px");
		  $(".progressfish").css("stroke", "rgba(0, 157, 134,1.0)");
		  $("#text-progress").html(Utils.translate("hook"));
		  $("#wrapper").show();
		  $("#hook").show();
		}else if (scene == "reel") {
			$("#bobber").hide();
			$("#hook").hide();
			$(".progressfish").css("width", "190px");
			$(".progressfish").css("stroke", "white");
			SetProgress(0);
			$("#reeling").show();
			$("#circle-inner").show();
			$("#wrapper").show();
		}
	  }
  
	  function SetProgress(val) {
		var max = -219.99078369140625;
		$(".progressfish")
		  .children($(".fill"))
		  .attr("style", "stroke-dashoffset: " + ((100 - val) / 100) * max);
	  }
	  function delay(time) {
		return new Promise((resolve) => setTimeout(resolve, time));
	  }
	
	  async function hook() {
		nibble = true;
		SwapScenes("hook");
		var id = setInterval(countdown, 3);
		var x = 100;
		for (let count2 = 0; count2 < 5; count2++) {
		  $("#circle-outer").animate(
			{
			  left: "-=2%",
			},
			100
		  );
		  $("#circle-outer").animate(
			{
			  left: "+=2%",
			},
			100
		  );
		  if (animCancel === true) {
			nibble = false;
			return;
		  }
		}
	
		function countdown() {
		  if (x <= 0) {
			nibble = false;
			clearInterval(id);
			cancelReset(_fail, false);
		  }
		  if (bite == true) {
			nibble = false;
			clearInterval(id);	
			cancelReset(_fishBite, true);
		  }
		  x = x - getDiffTimerToHook();
		  SetProgress(x);
		}
		await delay(500 * 5);
	  }
	
	  async function cancelReset(message, pass) {
		animCancel = true;
		SetProgress(0);    
		if (message == _success) {
			fishBite = false;
		}	  
		$("#circle-outer").stop(true);
		if (pass == false) {  
			fishBite = false;
		  $("#text-progress").show();
		  $("#text-progress").html(message);
		  $("#text-progress").css("color", "red");
		  $("#circle-inner").css("height", "1%");
		  $("#circle-inner").css("width", "1%");
		  $("#circle-inner").css("background-color", "rgba(255,0,0,0.6)");
		} else {
		  $("#text-progress").html(message);
		  $("#text-progress").css("color", "rgba(0, 157, 134,1.0)");
		  $("#circle-inner").css("height", "1%");
		  $("#circle-inner").css("width", "1%");
		  $("#circle-inner").css("background-color", "rgba(0, 157, 134,0.6)");
		}
		setTimeout(function () {
			$("#text-progress").css("color", "white");
			$("#text-progress").html("0%");
			$("#circle-inner").css("background-color", "rgba(0, 157, 134,0.6)");
			$("#circle-outer").css("left", "50%");
			$("#circle-outer").css("top", "50%");
		  if (pass == false) {
			closeFishingUi(pass)
			progress = 0;
			animCancel = false;
			bobbing = false;
			nibble = false;
			fishBite = false;
			bite = false;
			reeling = false;
		  }
		  if (message == _fishBite) {
			fishBite = true;
			SwapScenes("reel");
		  }else if (message == _success) {
			fishBite = false;
			progress = 0;
			animCancel = false;
			bobbing = false;
			nibble = false;
			bite = false;
			reeling = false;
		  }
		}, 2000);
	  }

		  

	  function getDiffTimerToHook(){
		switch (playerFishing.windlass_upgrade){
			case 1:
				return 1
			case 2:
				return 0.8
			case 3:
				return 0.6
			case 4:
				return 0.4
			case 5:
				return 0.2
		}
	  }
	  
	  function getDelayOnStartFishing(){
		switch (playerFishing.bait_upgrade){
			case 1:
				return 200
			case 2:
				return 160
			case 3:
				return 120
			case 4:
				return 80
			case 5:
				return 40
		}

	  }
	  

function handleClickOnFishingGame(e){
	e.preventDefault()
	e.stopPropagation()
	if (e.button == 0) {
		if(uiOpen){
			if (bobbing == true) {
				cancelReset(_tooSoon, false);
			} else if (nibble == true) {
				bite = true;
			}else if (fishBite == true) {
				reeling = true;
				updateTension(100, reeling, tensionIncrease);
				updateProgress(reeling, progressIncrease);
			}
		}
	}
}

$(document).unbind('keyup');

$(document).bind('keyup', function(data){
	data.preventDefault()
	data.stopPropagation()
	if (data.key == "Escape"){
		if (uiOpen == true) {
			animCancel = true;
			SetProgress(0);
			$("#text-progress").css("color", "white");
			$("#text-progress").html(Utils.translate("wait_fish"));
			$("#circle-inner").css("background-color", "rgba(0, 157, 134,0.6)");
			$("#circle-outer").css("left", "50%");
			$("#circle-outer").css("top", "50%");
			progress = 0;
			animCancel = false;
			bobbing = false;
			nibble = false;
			bite = false;
			reeling = false;
			display(false);
			closeFishingUi(false)
		  }
	}
});

$(document).one('mousedown', function(e){
    if (fishBite == true || reeling == true) {
        reeling = false;
        updateTension(1, reeling, tensionDecrease);
        updateProgress(reeling, progressDecrease);
    }
});


	  function updateTension(tension, add, speed) {
		var elem = document.getElementById("circle-inner");
		var width = parseFloat(elem.style.height);
		var id = setInterval(frame, speed);
		function frame() {
		  if (add === true) {
			if (width >= tension || reeling == false || fishBite == false) {
			  clearInterval(id);
			  if (width >= tension) {
				cancelReset(_gotAway, false);
				updateTrackingFish(progress,true)
				return;
			  }
			} else {
			  width++;
			  $("#circle-inner").css("height", width + "%");
			  $("#circle-inner").css("width", width + "%");
			  if (progress >= 100) {
				cancelReset(_success, true);
				closeFishingUi(true)
			  }
			}
		  } else {
			if (width <= tension || reeling == true || fishBite == false) {
			  clearInterval(id);
			} else {
			  width--;
			  $("#circle-inner").css("height", width + "%");
			  $("#circle-inner").css("width", width + "%");
			}
		  }
		  if (width <= 50) {
			$("#circle-inner").css("background-color", "rgba(0, 157, 134,0.6)");
		  } else if (width > 50 && width < 80) {
			$("#circle-inner").css("background-color", "rgba(255,165,0, 0.6)");
		  } else if (width >= 80) {
			$("#circle-inner").css("background-color", "rgba(255,0,0,0.6)");
		  }
		}
	  }
	
	  function updateProgress(add, speed) {
		var id = setInterval(frame, speed);
		var canUpdate = true;
		function frame() {
		  if (add === true) {
			if (reeling === false || fishBite === false) {
			  clearInterval(id);
			} else {
			  if (progress < 100) {
				progress = progress + 0.1;
				$("#text-progress").html(Math.floor(progress) + "%");
				SetProgress(progress);
			  }
			}
		  } else {
			if (reeling === true || fishBite === false) {
			  clearInterval(id);
			} else {
			  if (progress > 0) {
				progress = progress - 0.001;
				if (progress < 0) {
				  progress = 0;
				}
			  }
			  $("#text-progress").html(Math.floor(progress) + "%");
			  SetProgress(progress);
			}
		  }
		  if (canUpdate == true) {
			canUpdate = false;
			setTimeout(function () {
			  canUpdate = true;
			}, 1000);
		  }
		}
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

function renderStaticTextsProperty(){
	$(".main-stock").css("display", "");
	$(".stock-page").css("display", "block");
	$('#nav-bar-stock').html(`
		<li class="active">
			<i class="fas fa-warehouse"></i>
			<span class="tooltip">Propriedade</span>
		</li>
		<li onclick="closeUI()">
			<i class="fas fa-times"></i>
			<span class="tooltip">${Utils.translate('sidebar_close')}</span>
		</li>
	`);


}

function renderStaticTexts(fishinguser,equipments_upgrades) {
	$(".pages").css("display", "none");
	$(".main").css("display", "");
	$(".main-page").css("display", "block");
	$('.sidebar-navigation ul li').removeClass('active');
	$('#sidebar-main').addClass('active');

	// Statistics page
	$('#main-page-title').text(Utils.translate('statistics_page_title'));
	$('#main-page-desc').text(Utils.translate('statistics_page_desc'));
	$('#profile-money-earned-text').text(Lang[lang]['statistics_page_money_earned']);
	$('#profile-money-spent-text').text(Lang[lang]['statistics_page_money_spent']);
	$('#profile-total-dives').text(Lang[lang]['statistics_page_total_dives']);
	$('#profile-total-deliveries').text(Lang[lang]['statistics_page_total_deliveries']);
	$('#profile-total-rare-fish').text(Lang[lang]['statistics_page_total_rare_fish']);
	$('#profile-total-common-fish').text(Lang[lang]['statistics_page_total_common_fish']);

	// Deliveries page
	$('#deliveries-title-div').html(`
		<h4 class="text-uppercase">${Utils.translate('deliveries_page_title')}</h4>
		<p>${Utils.translate('deliveries_page_desc')}</p>
	`);
	$('#new-contracts-text').text(Utils.translate('deliveries_contracts_time').format(config.contracts.time_to_new_contracts));

	// Dives page
	$('#dives-title-div').html(`
		<h4 class="text-uppercase">${Utils.translate('dives_page_title')}</h4>
		<p>${Utils.translate('dives_page_desc')}</p>
	`);
	$('#new-dives-text').text(Utils.translate('dives_time').format(config.dives.time_to_new_dives));

	
	// Upgrades page
	$('#upgrades-page-title').text(Lang[lang]['upgrades_page_title']);
	$('#upgrades-page-desc').text(Lang[lang]['upgrades_page_desc']);
	$('#stock-upgrade-desc').text(Lang[lang]['upgrade_page_stock_desc']);
	$('#vehicles-upgrade-desc').text(Lang[lang]['upgrade_page_vehicles_desc']);
	$('#boats-upgrade-desc').text(Lang[lang]['upgrade_page_boats_desc']);
	$('#properties-upgrade-desc').text(Lang[lang]['upgrade_page_properties_desc']);
	$('#lake-upgrade-desc').text(Lang[lang]['upgrade_page_lake_desc']);
	$('#swan-upgrade-desc').text(Lang[lang]['upgrade_page_swan_desc']);
	$('#sea-upgrade-desc').text(Lang[lang]['upgrade_page_sea_desc']);

	// Equipments page
	$('#equipments-page-title').text(Lang[lang]['equipments_page_title']);
	$('#equipments-page-desc').text(Lang[lang]['equipments_page_desc']);
	$('#windlass-equipments-desc').text(Lang[lang]['equipment_page_windlass_desc'].format(equipments_upgrades.windlass[fishinguser.windlass_upgrade - 1].level_reward));
	$('#gimp-equipments-desc').text(Lang[lang]['equipment_page_gimp_desc'].format(equipments_upgrades.gimp[fishinguser.gimp_upgrade - 1].level_reward));
	$('#rod-equipments-desc').text(Lang[lang]['equipment_page_rod_desc']);
	$('#bait-equipments-desc').text(Lang[lang]['equipment_page_bait_desc'].format(equipments_upgrades.bait[fishinguser.bait_upgrade - 1].level_reward));


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
	
	// Guide page
	$('#guide-title-div').html(`
		<h4 class="text-uppercase">${Utils.translate('guide_page_title')}</h4>
		<p>${Utils.translate('guide_page_desc')}</p>
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
		<li onclick="openPage('dives')">
			<i class="fas fa-swimmer"></i>
			<span class="tooltip">${Utils.translate('sidebar_dives')}</span>
		</li>
		<li onclick="openPage('upgrades','vehicles-upgrades')">
			<i class="fas fa-trophy"></i>
			<span class="tooltip">${Utils.translate('sidebar_upgrades')}</span>
		</li>
		<li onclick="openPage('equipments','windlass-equipments')">
			<i class="fas fa-cog"></i>
			<span class="tooltip">${Utils.translate('sidebar_equipments')}</span>
		</li>
		<li onclick="openPage('store','store-vehicle')">
			<i class="fas fa-shopping-cart"></i>
			<span class="tooltip">${Utils.translate('sidebar_store')}</span>
		</li>
		<li onclick="openPage('owned-vehicle','owned-vehicle')">
			<i class="fas fa-ship"></i>
			<span class="tooltip">${Utils.translate('sidebar_owned_vehicles')}</span>
		</li>
		<li onclick="openPage('owned-property')">
			<i class="fas fa-warehouse"></i>
			<span class="tooltip">${Utils.translate('sidebar_owned_property')}</span>
		</li>
		<li onclick="openPage('guide','guide-all')">
			<i class="far fa-map"></i>
			<span class="tooltip">${Utils.translate('sidebar_guide')}</span>
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
	$('#store-navigation-tab').append(getStoreTabHTML());
	$('#guide-navigation-tab').append(getGuideTabHTML());
	$('#navigation-tab-upgrades').append(getUpgradesTabHTML());
	$('#navigation-tab-equipments').append(getEquipmentsTabHTML());
	$('#owned-vehicle-navigation-tab').append(getOwnedVehicleTabHTML());
}

function renderStatisticsPage(user) {
	$('#profile-money-earned2').text( Utils.currencyFormat(user.total_money_earned));
	$('#profile-money-spent2').text( Utils.currencyFormat(user.total_money_spent));
	$('#profile-total-rare-fish-2').text(user.fishs_rare_caught);
	$('#profile-total-common-fish-2').text(user.fishs_common_caught);
	$('#profile-total-dives-2').text(user.total_dives);
	$('#profile-total-deliveries-2').text(user.total_deliveries);

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


function renderDivesPage(fishing_available_dives, fishing_life_users) {
	$('#list-available-dives').empty();
	for (const dive of fishing_available_dives) {
		let reward_html = ``;
		let reward_icon = ``;
		if (dive.money_reward) {
			reward_icon = 'coins';
			reward_html = Utils.currencyFormat(dive.money_reward, 0);
		} else {
			let items = JSON.parse(dive.item_reward);
			reward_icon = 'box';
			reward_html = `${items.amount}x ${items.display_name}`;
		}
		let start_button = `<button onclick="startDive(${dive.id})" type="button" class="btn btn-primary btn-block"><small>${Utils.translate('dives_start_button')}</small></button>`;
		if (fishing_life_users.user_id == dive.progress) {
			start_button = `<button onclick="cancelDive()" type="button" class="btn btn-outline-danger btn-block"><small>${Utils.translate('dives_cancel_button')}</small></button>`;
		}

		$('#list-available-dives').append(`
				<div class="col-3 mb-3">
					<div class="card h-100">
						<div>
							<img src="${dive.image}" class="card-img-top w-100">
						</div>
						<div class="card-body pt-2 px-0">
							<div class="mx-3">
								<h6 style="font-size: 17px; font-weight: 600;">${dive.name}</h6>
							</div>
							<div class="mx-3">
								<h6>${dive.description}</h6>
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

function renderStorePage(available_items_store,available_vehicles,available_boats,available_properties,owned_properties) {
	$('#store-vehicle-page-list').empty();
	$('#store-boat-page-list').empty();
	$('#store-property-page-list').empty();
	for (const vehicleIdx of available_vehicles) {
		const vehicle = available_items_store.vehicle[vehicleIdx]
		if (vehicle) {
			let button_html = `<button onclick="buyVehicle('${vehicleIdx}','vehicle')" type="button" class="btn btn-primary btn-block mt-4"><small>${Utils.translate('store_page_vehicle_buy')}</small></button>`
			$('#store-vehicle-page-list').append(`
			<div class="col-3 mb-3">
			<div class="card h-100">
				<div class="card">
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
	
	for (const boatIdx of available_boats) {
		const boat = available_items_store.boat[boatIdx]
		if (boat) {
			let button_html = `<button onclick="buyVehicle('${boatIdx}','boat')" type="button" class="btn btn-primary btn-block mt-4"><small>${Utils.translate('store_buy_boat')}</small></button>`
			$('#store-boat-page-list').append(`
			<div class="col-3 mb-3">
			<div class="card h-100">
				<div class="card">
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

	for (const propertyIdx of available_properties) {
		const property = available_items_store.property[propertyIdx]
		if (property) {
			let button_html = `<button onclick="buyProperty('${propertyIdx}','property')" type="button" class="btn btn-primary btn-block mt-4"><small>${Utils.translate('store_buy_property')}</small></button>`
			let store_property_locked_background = ``
			if (owned_properties.filter(p => p.property ==propertyIdx).length > 0) {
				button_html = `<div class="d-flex align-items-center"><i class="fa-solid fa-lock text-muted"></i><span class=" ml-2 small">${Utils.translate('store_page_property_owned')}</span></div>`
				store_locked_background = `store-locked-background`
			}
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

function renderGuidePage(fishs_available,sea,lake,swan){
	$('#guide-all-page-list').empty();
	$('#guide-sea-page-list').empty();
	$('#guide-lake-page-list').empty();
	$('#guide-swan-page-list').empty();
	let levelSea = 0 ;
	for (const difSea of sea) {
		levelSea++;
		for(const seaIdx of difSea){
		const fish = fishs_available[seaIdx]
		if (fish) {
			let fishHtml = `
				<div class="col-3 mb-3">
				<div class="card h-100">
					<div class="card">
						<h5 class="mb-2" style="text-align:center;">${Utils.translate('sea')}</h5>
						<img src="${fish.img}" class="card-img-top w-50" style= "align-self:center">
						<div class="card-body pt-0 px-0 pb-2">
							<div class="d-flex flex-row justify-content-between mt-3 px-3"> <span class="text-muted">${Utils.translate('level_abbreviate')} ${levelSea}</span>
								<h6>${fish.name}</h6>
							</div>
							<hr class="mt-2 mx-3">
							<div class="d-flex flex-row justify-content-between px-3">
								<div class="d-flex flex-column"><span class="text-muted">${Utils.translate('guide_page_fish_value')}</span></div>
								<div class="d-flex flex-column">
									<h5 class="mb-0">${Utils.currencyFormat(fish.sale_value)}</h5>
								</div>
							</div>
							<hr class="mt-2 mx-3">
							<div class="d-flex flex-row justify-content-between px-3">
								<div class="d-flex flex-column"><span class="text-muted">${Utils.translate('guide_page_fish_weight')}</span></div>
								<div class="d-flex flex-column">
									<h5 class="mb-0">${fish.weight}</h5>
								</div>
							</div>
						</div>
					</div>
					</div>
					</div>
				`
				$('#guide-all-page-list').append(fishHtml);
				$('#guide-sea-page-list').append(fishHtml);
			}
		}
	}	
	let levelLake = 0;
	for (const difLake of lake) {
		levelLake++;
		for(const lakeIdx of difLake){
			const fish = fishs_available[lakeIdx]
			if (fish) {
				let fishHtml = `
					<div class="col-3 mb-3">
					<div class="card h-100">
					<div class="card">
						<h5 class="mb-2" style="text-align:center;">${Utils.translate('lake')}</h5>
							<img src="${fish.img}" class="card-img-top w-50" style= "align-self:center">
							<div class="card-body pt-0 px-0 pb-2">
								<div class="d-flex flex-row justify-content-between mt-3 px-3"> <span class="text-muted">${Utils.translate('level_abbreviate')} ${levelLake}</span>
									<h6>${fish.name}</h6>
								</div>
								<hr class="mt-2 mx-3">
								<div class="d-flex flex-row justify-content-between px-3">
									<div class="d-flex flex-column"><span class="text-muted">${Utils.translate('guide_page_fish_value')}</span></div>
									<div class="d-flex flex-column">
										<h5 class="mb-0">${Utils.currencyFormat(fish.sale_value)}</h5>
									</div>
								</div>
								<hr class="mt-2 mx-3">
								<div class="d-flex flex-row justify-content-between px-3">
									<div class="d-flex flex-column"><span class="text-muted">${Utils.translate('guide_page_fish_weight')}</span></div>
									<div class="d-flex flex-column">
										<h5 class="mb-0">${fish.weight}</h5>
									</div>
								</div>
							</div>
						</div>
						</div>
						</div>
					`
					$('#guide-all-page-list').append(fishHtml);
					$('#guide-lake-page-list').append(fishHtml);
			}
		}
	}		
	let levelSwan = 0;
	for (const swanDif of swan) {
		levelSwan ++;
		for(const swanIdx of swanDif){
			const fish = fishs_available[swanIdx]
			if (fish) {
				let fishHtml = `
					<div class="col-3 mb-3">
					<div class="card h-100">
					<div class="card">
						<h5 class="mb-2" style="text-align:center;">${Utils.translate('swan')}</h5>
							<img src="${fish.img}" class="card-img-top w-50" style= "align-self:center">
							<div class="card-body pt-0 px-0 pb-2">
								<div class="d-flex flex-row justify-content-between mt-3 px-3"> <span class="text-muted">${Utils.translate('level_abbreviate')} ${levelSwan}</span>
									<h6>${fish.name}</h6>
								</div>
								<hr class="mt-2 mx-3">
								<div class="d-flex flex-row justify-content-between px-3">
									<div class="d-flex flex-column"><span class="text-muted">${Utils.translate('guide_page_fish_value')}</span></div>
									<div class="d-flex flex-column">
										<h5 class="mb-0">${Utils.currencyFormat(fish.sale_value)}</h5>
									</div>
								</div>
								<hr class="mt-2 mx-3">
								<div class="d-flex flex-row justify-content-between px-3">
									<div class="d-flex flex-column"><span class="text-muted">${Utils.translate('guide_page_fish_weight')}</span></div>
									<div class="d-flex flex-column">
										<h5 class="mb-0">${fish.weight}</h5>
									</div>
								</div>
							</div>
						</div>
						</div>
						</div>
					`
					$('#guide-all-page-list').append(fishHtml);
					$('#guide-swan-page-list').append(fishHtml);
			}
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

function renderOwnedPropertiesPage(owned_properties, properties, fishs_available) {
	$('#owned-property-page-list').empty();
	for (const property_data of owned_properties) {
		const property = properties.property[property_data.property]
		if (property) {
			let property_stock_str = ``;
			let health_color = `success`;
			if (property_data.property_condition < 10) {
				let remaining_health = 100 - property_data.property_condition
				let total_repair_price = property.repair_price*remaining_health
				property_stock_str = `<a class="dropdown-item text-black-50" onclick="repairProperty('${property_data.property}')">${Utils.translate('vehicles_page_repair').format(Utils.currencyFormat(total_repair_price,0))}</a>`;

				if (property_data.property_condition < 200) {
					health_color = "danger"
				}
			}
			var max_stock = property.warehouse_capacity
			let stock_capacity_percent = numberFormat((property_data.stock.length * 100)/max_stock,1);	
			$('#owned-property-page-list').append(`
				<li class="d-flex card-theme justify-content-between">
					<div style="width: 300px;" class="d-flex flex-row align-items-center">
						<img src="${property.image}" class="img-width">
						<div class="ml-2">
							<h6 class="mb-0">${property.name}</h6>
							<div class="d-flex flex-row mt-1 text-black-50 text-nowrap small">
								<div class="ml-3"><i class="fas fa-route"></i><span class="small ml-2">${Utils.translate('owned_property_location').format(property.location)}</span></div>
							</div>
						</div>
					</div>
					<div class="d-flex flex-row text-black-50 small"  style="flex: 2;">
						<div class="d-flex align-items-center">
							<img src="images/car-engine.png" width="35px">
							<div class="ml-1">
								<span>${Utils.translate('owned_properties_stock_percentage')}</span>
								<div class="progress mt-0 mb-0" style="height: 10px; width: 200px;"><div class="progress-bar bg-primary" role="progressbar" style="width: ${stock_capacity_percent}%" aria-valuenow="0.0" aria-valuemin="0" aria-valuemax="100"></div></div>								
								</div>
						</div>
					</div>
					<div class="d-flex flex-row text-black-50 small"  style="flex: 2;">
						<div class="d-flex align-items-center">
							<img src="images/car-engine.png" width="35px">
							<div class="ml-1">
								<span>${Utils.translate('owned_properties_stock_condition')}</span>
								<div class="progress mt-0 mb-0" style="height: 10px; width: 200px;"><div class="progress-bar bg-${health_color}" role="progressbar" style="width: ${property_data.property_condition}%" aria-valuenow="0.0" aria-valuemin="0" aria-valuemax="100"></div></div>								
								</div>
						</div>
					</div>
					<div class="d-flex flex-row align-items-center mr-2">
						<div class="dropdown">
							<svg data-toggle="dropdown" class="dropdown-options-svg" xmlns="http://www.w3.org/2000/svg" version="1.1" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:svgjs="http://svgjs.com/svgjs" width="512" height="512" x="0" y="0" viewBox="0 0 515.555 515.555" style="enable-background:new 0 0 512 512" xml:space="preserve"><g><path xmlns="http://www.w3.org/2000/svg" d="m496.679 212.208c25.167 25.167 25.167 65.971 0 91.138s-65.971 25.167-91.138 0-25.167-65.971 0-91.138 65.971-25.167 91.138 0" data-original="#000000" style="" class=""></path><path xmlns="http://www.w3.org/2000/svg" d="m303.347 212.208c25.167 25.167 25.167 65.971 0 91.138s-65.971 25.167-91.138 0-25.167-65.971 0-91.138 65.971-25.167 91.138 0" data-original="#000000" style="" class=""></path><path xmlns="http://www.w3.org/2000/svg" d="m110.014 212.208c25.167 25.167 25.167 65.971 0 91.138s-65.971 25.167-91.138 0-25.167-65.971 0-91.138 65.971-25.167 91.138 0" data-original="#000000" style="" class=""></path></g></svg>
							<div class="dropdown-menu">
								${property_stock_str}
								<a class="dropdown-item text-black-50" id="seePropertyButton">${Utils.translate('owned_properties_see')}</a>
								<a class="dropdown-item" onclick="sellProperty('${property_data}')" style="color:#ff0000c2;">${Utils.translate('vehicles_page_sell')}</a>
							</div>
						</div>
					</div>
				</li>
			`);
			$("#seePropertyButton").bind('click',{ param: property_data, param1:fishs_available} ,seePropertyStock)
		}
	}	
}

function  renderStockPage(property, properties,players_items_fishing,fishs_available){
	// stock property page modal
	var arr_stock = property.stock
	var max_stock = properties.property[property.property].warehouse_capacity
	let stock_capacity_percent = numberFormat((property.stock_amount * 100)/max_stock,1);
	$('#stock-title-div').html(`
		<h4 class="text-uppercase">${Utils.translate('stock_title')} ${property.name} </h4>
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
		</div>
	`);
	$('#stock-page-th-name').text(Lang[lang]['stock_page_header_name']);
	$('#stock-page-th-weight').text(Lang[lang]['stock_page_header_weight']);
	$('#stock-page-th-amount').text(Lang[lang]['stock_page_header_amount']);
	$('#stock-player-page-th-name').text(Lang[lang]['stock_page_header_name']);
	$('#stock-player-page-th-weight').text(Lang[lang]['stock_page_header_weight']);
	$('#stock-player-page-th-amount').text(Lang[lang]['stock_page_header_amount']);
	$('#withdraw-item-modal-cancel').text(`${Lang[lang]['stock_page_withdraw_modal_cancel']}`);
	$('#withdraw-item-modal-submit').text(`${Lang[lang]['confirm_button_modal']}`);
	$('#withdraw-item-modal-amount').text(`${Lang[lang]['stock_page_withdraw_modal_amount']}`);
	$('#deposit-item-modal-cancel').text(`${Lang[lang]['stock_page_withdraw_modal_cancel']}`);
	$('#deposit-item-modal-submit').text(`${Lang[lang]['confirm_button_modal']}`);
	$('#deposit-item-modal-amount').text(`${Lang[lang]['stock_page_withdraw_modal_amount']}`);
	$('#deposit-item-modal').attr('value',`${property.property}`);
	$('#withdraw-item-modal').attr('value',`${property.property}`);
	$('#stock-title').text(Lang[lang]['stock_page_bar_title']);
	$('#stock-values').text(`${property.stock_amount}/${max_stock} ${Utils.translate('weight_unit')}`);
	$('#stock-progress-bar').html(`<div class="progress-bar bg-primary" role="progressbar" style="width: ${stock_capacity_percent}%" aria-valuenow="${stock_capacity_percent}" aria-valuemin="0" aria-valuemax="100">${stock_capacity_percent}%</div>`);
	$('#stock-table-body').empty();
	if(arr_stock){
		if (Object.keys(arr_stock).length > 0) {
			arr_stock = Object.keys(arr_stock).sort().reduce(
				(obj, key) => { 
				obj[key] = arr_stock[key]; 
				return obj;
				}, 
				{}
			);
			
			for (const stock_item in arr_stock) {
				let item = null
				if(stock_item.toLowerCase().includes('fish')){
					item = fishs_available[stock_item]
				} 
				if (item) {
					$('#stock-table-body').append(`
						<tr data-toggle="modal" data-target="#withdraw-item-modal" data-item="${stock_item}" data-amount="${arr_stock[stock_item]}" class="border-right border-left border-bottom">
							<td class="d-flex align-items-center text-left"><img src="${item.img}" class="mr-2" style="width: 40px;">${item.name}</td>
							<td class="align-middle">${item.weight} ${Utils.translate('weight_unit')}</td>
							<td class="align-middle">${arr_stock[stock_item]}</td>
						</tr>
					`);
				} else {
					console.log(`Item '${stock_item}' from your stock does not exist in config, contact the server owner to remove that item from your database`)
				}
			}
		}else {
			$('#stock-table-body').append(`
				<tr class="border-right border-left border-bottom">
					<td colspan="4">${Utils.translate('stock_page_table_empty')}</td>
				</tr>
			`);
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
	for (const inventory_item of players_items_fishing) {
		if(inventory_item){
			let item = null
			if(inventory_item.name.toLowerCase().includes('fish')){
				item = fishs_available[inventory_item.name]
			}
			if (item) {
				has_readable_inventory_item = true
				$('#stock-player-table-body').append(`
					<tr data-toggle="modal" data-target="#deposit-item-modal" data-item="${inventory_item.name}" data-amount="${inventory_item.amount}" class="border-right border-left border-bottom">
						<td class="d-flex align-items-center text-left"><img src="${item.img}" class="mr-2" style="width: 40px;">${inventory_item.label}</td>
						<td class="align-middle">${item.weight} ${Utils.translate('weight_unit')}</td>
						<td class="align-middle">${inventory_item.amount}</td>
					</tr>
				`);
			}	
		}
	}
	if (!has_readable_inventory_item) {
		$('#stock-player-table-body').append(`
			<tr class="border-right border-left border-bottom">
				<td colspan="3">${Utils.translate('stock_page_table_empty')}</td>
			</tr>
		`);
	}
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

function renderEquipmentsPage(equipments,user){ 
	$('.equipment-list').empty();
	let level = 1
	for (const equipment_type in equipments) {
		level = 1
		for (const equipment of equipments[equipment_type]) {
			let current_level = user[equipment_type+'_upgrade']
			$('#'+equipment_type+'-equipments-list').append(getEquipmentItemHTML(equipment,equipment_type,level,current_level));
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

function getGuideTabHTML() {
	return getTabHTML('guide','guide-all',Utils.translate('navigation_tab_guide_all'),true)
	+ getTabHTML('guide','guide-sea',Utils.translate('sea'))
	+ getTabHTML('guide','guide-lake',Utils.translate('lake'))
	+ getTabHTML('guide','guide-swan',Utils.translate('swan'))
}


function getUpgradesTabHTML() {
	return getTabHTML('upgrades','vehicles-upgrades',Lang[lang]['navigation_tab_upgrades_vehicles'],true)
	+ getTabHTML('upgrades','boats-upgrades',Lang[lang]['navigation_tab_upgrades_boats'])
	+ getTabHTML('upgrades','lake-upgrades',Lang[lang]['navigation_tab_upgrades_lake'])
	+ getTabHTML('upgrades','swan-upgrades',Lang[lang]['navigation_tab_upgrades_swan'])
	+ getTabHTML('upgrades','sea-upgrades',Lang[lang]['navigation_tab_upgrades_sea'])
}

function getEquipmentsTabHTML() {
	return getTabHTML('equipments','windlass-equipments',Lang[lang]['navigation_tab_equipments_windlass'],true)
	+ getTabHTML('equipments','rod-equipments',Lang[lang]['navigation_tab_equipments_rod'])
	+ getTabHTML('equipments','bait-equipments',Lang[lang]['navigation_tab_equipments_bait'])
	+ getTabHTML('equipments','gimp-equipments',Lang[lang]['navigation_tab_equipments_gimp'])
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
	let upgrade_button = `<button style="height:38px;" class="btn btn-primary btn-block" onclick="buyUpgrade('${upgrade_type}',${level})">${upgrade.points_required} ${Lang[lang]['skill_point']}</button>`
	if (level > current_level) {
		upgrade_button = `<button style="height:38px;" class="btn btn-secondary btn-block"><i class="fa-solid fa-lock" disabled></i></button>`
	} else if (level < current_level) {
		upgrade_button = `<button style="height:38px;" class="btn btn-outline-success btn-block"><i class="fa-solid fa-check"></i></button>`
	}
	let upgrade_description = Lang[lang]['upgrade_page_' + upgrade_type + '_level'].format(upgrade.level_reward)
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

function getEquipmentItemHTML(equipment,equipment_type,level,current_level) {
	current_level++;
	let equipment_button = `<button style="height:38px;" class="btn btn-primary btn-block" onclick="buyEquipment('${equipment_type}',${level},${equipment.price})"> ${Lang[lang]['equipment_price'].format(Utils.currencyFormat(equipment.price))}</button>`
	if (level > current_level) {
		equipment_button = `<button style="height:38px;" class="btn btn-secondary btn-block"><i class="fa-solid fa-lock" disabled></i></button>`
	} else if (level < current_level) {
		equipment_button = `<button style="height:38px;" class="btn btn-outline-success btn-block"><i class="fa-solid fa-check"></i></button>`
	}
	let equipment_description = Lang[lang]['equipment_page_' + equipment_type + '_level'].format(equipment.level_reward)
	return `
		<li class="d-flex card-theme align-items-center">
			<img style="width: 8%;" src="${equipment.icon}">
			<div style="width: 20%;" class="ml-2">
				<small class="text-black-50">${Lang[lang]['equipment_page_' + equipment_type]}</small>
				<h4 class="font-weight-semi-bold">${Lang[lang]['level_abbreviate']}${level}</h4>
			</div>
			<div style="width: 55%;">
				<span class="text-success">${equipment_description}</span>
			</div>
			<div style="width: 15%;">
				${equipment_button}
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

function startDive(dive_id){
	Utils.post("startDive",{dive_id:dive_id})
}

function cancelDive(){
	Utils.post("cancelDive",{})
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

function buyUpgrade(upgrade_type,level){
	Utils.post("buyUpgrade",{upgrade_type,level})
}

function buyEquipment(equipment_type,level, price){
	Utils.post("buyEquipment",{equipment_type,level,price})
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
	Utils.showDefaultDangerModal(() => Utils.post("sellVehicle",{vehicle_id}), Utils.translate('confirmation_modal_sell_vehicle'));
}
function buyProperty(property_id,type) {
	Utils.post("buyProperty",{property_id,type})
}
function sellProperty(property_id,type) {
	Utils.post("sellProperty",{property_id})
}

function updateTrackingFish(progress, isItOver){
	Utils.post("updateTrackingFish",{progress,isItOver},"updateTrackingFish")
}

function closeFishingUi(success){
	Utils.post("closeFishingUi",{success})
}

function seePropertyStock(event) {
	// stock property page modal
	var property = event.data.param
	var fishs_available = event.data.param1
	var arr_stock = JSON.parse(property.stock)
	$('#stock-page-th-name-modal').text(Lang[lang]['stock_page_header_name']);
	$('#stock-page-th-weight-modal').text(Lang[lang]['stock_page_header_weight']);
	$('#stock-page-th-amount-modal').text(Lang[lang]['stock_page_header_amount']);
	$('#stock-table-body-modal').empty();
	if (Object.keys(arr_stock).length > 0) {
		arr_stock = Object.keys(arr_stock).sort().reduce(
			(obj, key) => { 
			obj[key] = arr_stock[key]; 
			return obj;
			}, 
			{}
		);
		
		for (const stock_item in arr_stock) {
			let item = null
			if(stock_item.toLowerCase().includes('fish')){
				item = fishs_available[stock_item]
			}
			if (item) {
				$('#stock-table-body-modal').append(`
					<tr class="border-right border-left border-bottom">
						<td class="d-flex align-items-center text-left"><img src="${item.img}" class="mr-2" style="width: 40px;">${item.name}</td>
						<td class="align-middle">${item.weight} ${Utils.translate('weight_unit')}</td>
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
	$("#stock-modal").modal()
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

	$("#form-withdraw-item").on('submit', function(e){
		e.preventDefault();
		var form = $('#form-withdraw-item').serializeArray();
		let item = $('#withdraw-modal-item-amount').data('item');
		let property = $('#withdraw-item-modal').attr('value');
		$('#withdraw-modal-item-amount').val(0);
		$('#add-button-withdraw').prop('disabled',false);
		$('#subtract-button-withdraw').prop('disabled',true);
		$("#withdraw-item-modal").modal('hide');
		Utils.post("withdrawItem",{amount:form[0].value,item,property})
	});

	$("#form-deposit-item").on('submit', function(e){
		e.preventDefault();
		var form = $('#form-deposit-item').serializeArray();
		let item = $('#deposit-modal-item-amount').data('item');
		let property = $('#deposit-item-modal').attr('value');
		$('#deposit-modal-item-amount').val(0);
		$('#add-button-deposit').prop('disabled',false);
		$('#subtract-button-deposit').prop('disabled',true);
		$("#deposit-item-modal").modal('hide');
		Utils.post("depositItem",{amount:form[0].value,item, property})
	});

	$("#form-loan").on('submit', function(e){
		e.preventDefault();
		var form = $('#form-loan').serializeArray();
		$("#loans-modal").modal('hide');
		Utils.post("loan",{loan_id:form[0].value})
	});

	

	$('#withdraw-item-modal').on('show.bs.modal', function (event) {
		var button = $(event.relatedTarget);
		var item = button.data('item');
		var amount = button.data('amount');
		let fishs_available = config.fishs_available
		let itemModal =  null
		if(item.toLowerCase().includes('fish')){
			itemModal = fishs_available[item]
		}
		$('#withdraw-item-modal-item-name').text(itemModal.name);
		$('#withdraw-item-modal-img').attr("src",itemModal.img);
		$('#withdraw-item-modal-item-available').text(`${Lang[lang]['stock_page_withdraw_modal_item_available'].format(amount)}`);
		$('#withdraw-modal-item-amount').val(0);
		$('#form-withdraw-item-input-container').css('display','flex');
		$('#withdraw-modal-item-amount').data('max',amount);
		$('#withdraw-item-modal-title').text(`${Lang[lang]['stock_page_withdraw_modal_title']}`);
		$('#withdraw-item-modal-img').css('width','80px');
		$("#withdraw-modal-item-amount").attr("max",amount);
		$("#withdraw-modal-item-amount").attr("oninput",`Utils.InvalidMsg(this,1,${amount});`);
		$('#add-button-withdraw').prop('disabled',false);
		$('#subtract-button-withdraw').prop('disabled',true);
		$('#withdraw-modal-item-amount').data('item',item);
	})

	$('#deposit-item-modal').on('show.bs.modal', function (event) {
		var button = $(event.relatedTarget);
		var item = button.data('item');
		var amount = button.data('amount');
		let fishs_available = config.fishs_available
		let itemModal =  null
		if(item.toLowerCase().includes('fish')){
			itemModal = fishs_available[item]
		}
		$('#deposit-item-modal-item-name').text(itemModal.name);
		$('#deposit-item-modal-img').attr("src",itemModal.img);
		$('#deposit-item-modal-item-available').text(`${Lang[lang]['stock_page_deposit_modal_item_available'].format(amount)}`);
		$('#deposit-modal-item-amount').val(0);
		$('#form-deposit-item-input-container').css('display','flex');
		$('#deposit-modal-item-amount').data('max',amount);
		$('#deposit-item-modal-title').text(`${Lang[lang]['stock_page_deposit_modal_title']}`);
		$('#deposit-item-modal-img').css('width','80px');
		$('#add-button-deposit').prop('disabled',false);
		$('#subtract-button-deposit').prop('disabled',true);
		$('#deposit-modal-item-amount').data('item',item);
		$("#deposit-modal-item-amount").attr("max",amount);
		$("#deposit-modal-item-amount").attr("oninput",`Utils.InvalidMsg(this,1,${amount});`);
	})
	
	$("#subtract-button-deposit").on('click', function(e){
		$('#add-button-deposit').prop('disabled',false);
		let max_amount = $('#deposit-modal-item-amount').data('max');
		let amount = $('#deposit-modal-item-amount').val();
		if (--amount <= 0) {
			amount = 0;
			$(this).prop('disabled',true);
		}
		if (amount >= max_amount) {
			amount = max_amount
			$('#add-button-deposit').prop('disabled',true);
		}
		$('#deposit-modal-item-amount').val(amount);
	});

	$("#add-button-deposit").on('click', function(e){
		$('#subtract-button-deposit').prop('disabled',false);
		let max_amount = $('#deposit-modal-item-amount').data('max');
		let amount = $('#deposit-modal-item-amount').val();
		if (++amount >= max_amount) {
			amount = max_amount
			$(this).prop('disabled',true);
		}
		if (amount <= 0) {
			amount = 0;
			$('#subtract-button-deposit').prop('disabled',true);
		}
		$('#deposit-modal-item-amount').val(amount);
	});

	$("#subtract-button-withdraw").on('click', function(e){
		$('#add-button-withdraw').prop('disabled',false);
		let max_amount = $('#withdraw-modal-item-amount').data('max');
		let amount = $('#withdraw-modal-item-amount').val();
		if (--amount <= 0) {
			amount = 0;
			$(this).prop('disabled',true);
		}
		if (amount >= max_amount) {
			amount = max_amount
			$('#add-button-withdraw').prop('disabled',true);
		}
		$('#withdraw-modal-item-amount').val(amount);
	});

	$("#add-button-withdraw").on('click', function(e){
		$('#subtract-button-withdraw').prop('disabled',false);
		let max_amount = $('#withdraw-modal-item-amount').data('max');
		let amount = $('#withdraw-modal-item-amount').val();
		if (++amount >= max_amount) {
			amount = max_amount
			$(this).prop('disabled',true);
		}
		if (amount <= 0) {
			amount = 0;
			$('#subtract-button-withdraw').prop('disabled',true);
		}
		$('#withdraw-modal-item-amount').val(amount);
	});

	document.onkeyup = function(data){
		if (data.which == 27){
			if ($(".main-stock").is(":visible") || $(".main").is(":visible") ){
				Utils.post("close","")
			}
			if(typeof $(".modal").modal == 'function'){
				
				$(".modal").modal('hide');
			}
		}
	};

})
function numberFormat(number,zeros) {
	if (zeros != null) {
		return new Intl.NumberFormat(config.format.location, { maximumFractionDigits: zeros, minimumFractionDigits: zeros }).format(number)
	} else {
		return new Intl.NumberFormat(config.format.location, {  }).format(number)
	}
}
