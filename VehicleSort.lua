-- VehicleSort.lua for FS22
-- Author: sperrgebiet
-- Please see https://github.com/sperrgebiet/FS22_VehicleExplorer for additional information, credits, issues and everything else

VehicleSort = {};
VehicleSort.eventName = {};

-- It's great that Giants gets rid of functions as part of an update. Now we can do things more complicated than before
--VehicleSort.ModName = g_currentModName
--VehicleSort.ModDirectory = g_currentModDirectory
VehicleSort.ModName = "FS22_VehicleExplorer"
VehicleSort.ModDirectory = g_modManager.nameToMod.FS22_VehicleExplorer.modDir
VehicleSort.Version = "0.2.0.5";


VehicleSort.debug = fileExists(VehicleSort.ModDirectory ..'debug');

VehicleSort.firstRun = true;

print(string.format('VehicleSort v%s - DebugMode %s)', VehicleSort.Version, tostring(VehicleSort.debug)));

VehicleSort.bgTransDef = 0.8;
VehicleSort.txtSizeDef = 2;
VehicleSort.infoYStart = 0.8;
VehicleSort.listAlignment = 2;						-- 1 = Left, 2 = Center, 3 = Right)
VehicleSort.showImgMaxImp = 9;
VehicleSort.showInfoMaxImpl = 9;
VehicleSort.showImplementsMax = 3;
VehicleSort.easyTabTable = {};

-- Integration environment for Tardis
envTardis = nil;

-- Trains get apparently handled differently for isTabbable and motorStatus, so we'll set that state on postMapload again
VehicleSort.loadTrainStatus = {};
VehicleSort.loadTrainStatus.entries = 0;
VehicleSort.loadItemsEnterable = {};

VehicleSort.config = {											--Id		-Order in configMenu
  {'showTrain', true, 1},										-- 1		1
  {'showCrane', false, 2},                             			-- 2		2
  {'showBrand', false, 3},                             			-- 3		3
  {'showHorsepower', true, 4},                         			-- 4		4
  {'showNames', true, 8},                              			-- 5		8
  {'showFillLevels', true, 5},                         			-- 6		5
  {'showPercentages', true, 6},                        			-- 7		6
  {'showEmpty', false, 7},                             			-- 8		7
  {'txtSize', VehicleSort.txtSizeDef, 16},             			-- 9		16
  {'bgTrans', VehicleSort.bgTransDef, 17},              		-- 10		17
  {'showSteerableImplements', true, 11},                		-- 11		11
  {'showImplements', true, 9},	                         		-- 12		9
  {'showHelp', true, 28},                               		-- 13		28
  {'saveStatus', true, 25},                             		-- 14		25
  {'showImg', true, 12},                                		-- 15		12
  {'showInfo', true, 14},                               		-- 16		14
  {'infoStart', VehicleSort.infoYStart, 21},            		-- 17		21
  {'infoBg', true, 18},                                 		-- 18		18
  {'imageBg', true, 20},                                		-- 19		20
  {'listAlignment', VehicleSort.listAlignment, 22},     		-- 20		22
  {'cleanOnRepair', true, 23},                          		-- 21		23
  {'integrateTardis', true, 26},                        		-- 22		26
  {'enterVehonTeleport', true, 27},                     		-- 23		27
  {'showImgMaxImp', VehicleSort.showImgMaxImp, 13},     		-- 24		13
  {'showInfoMaxImpl', VehicleSort.showInfoMaxImpl, 15},			-- 25		15
  {'showImplementsMax', VehicleSort.showImplementsMax, 10},		-- 26		10
  {'useTwoColoredList', true, 19},								-- 27		19
  {'useVeExTabOrder', true, 29},								-- 28		29
  {'paintonRepair', true, 24},									-- 29		24
};

VehicleSort.tColor = {}; -- text colours
VehicleSort.tColor.isParked 	= {0.5, 0.5, 0.5, 0.7};   -- grey
VehicleSort.tColor.locked 		= {1.0, 0.0, 0.0, 1.0};   -- red
VehicleSort.tColor.selected 	= {0.8879, 0.1878, 0.0037, 1.0}; -- orange
VehicleSort.tColor.standard 	= {1.0, 1.0, 1.0, 1.0}; -- white
VehicleSort.tColor.standard2 	= {0.8228, 0.8388, 0.7304, 1.0}; -- eggcolor
VehicleSort.tColor.hired 		= {0.0, 0.5, 1.0, 1.0}; 	-- blue
VehicleSort.tColor.courseplay 	= {0.270, 0.55, 0.88, 1.0}; 	-- baby blue
VehicleSort.tColor.followme 	= {0.92, 0.31, 0.69, 1.0}; 	-- light pink
VehicleSort.tColor.autodrive 	= {0.03, 0.78, 0.85, 1.0}; 	-- aqua/turquoise
VehicleSort.tColor.aive 		= {1.0, 0.5, 0.2, 1.0}; 	-- orange
VehicleSort.tColor.self  		= {0.0, 1.0, 0.0, 1.0}; -- green
VehicleSort.tColor.motorOn		= {0.9301, 0.7605, 0.0232, 1.0}; -- yellow

VehicleSort.keyCon = 'VeExConfig';
VehicleSort.selectedConfigIndex = 1;
VehicleSort.selectedRealConfigIndex = 1;
VehicleSort.selectedIndex = 1;
VehicleSort.selectedLock = false;
VehicleSort.showConfig = false;
VehicleSort.showVehicles = false;
VehicleSort.xmlAttrId = '#vsid';
VehicleSort.xmlAttrOrder = '#vsorder';
VehicleSort.xmlAttrParked = '#vsparked';
VehicleSort.Sorted = {};
VehicleSort.HiddenCount = 0;
--VehicleSort.dirtyState = false;						-- Used to check if we have to sync the order with g_currentMission.vehicles
VehicleSort.orderedConfig = {};							-- It's just nicer to have the config list ordered

addModEventListener(VehicleSort);

function VehicleSort:dp(val, fun, msg) -- debug mode, write to log
	if not VehicleSort.debug then
		return;
	end

	if msg == nil then
		msg = ' ';
	else
		msg = string.format(' msg = [%s] ', tostring(msg));
	end

	local pre = 'VehicleSort DEBUG:';

	if type(val) == 'table' then
		--if #val > 0 then
			print(string.format('%s BEGIN Printing table data: (%s)%s(function = [%s()])', pre, tostring(val), msg, tostring(fun)));
			DebugUtil.printTableRecursively(val, '.', 0, 3);
			print(string.format('%s END Printing table data: (%s)%s(function = [%s()])', pre, tostring(val), msg, tostring(fun)));
		--else
		--	print(string.format('%s Table is empty: (%s)%s(function = [%s()])', pre, tostring(val), msg, tostring(fun)));
		--end
	else
		print(string.format('%s [%s]%s(function = [%s()])', pre, tostring(val), msg, tostring(fun)));
	end
end


function VehicleSort:prerequisitesPresent(specializations)
	return true;
end

function VehicleSort:loadMap(name)
	print("--- loading VehicleSort V".. VehicleSort.Version .. " | ModName " .. VehicleSort.ModName .. " ---");
	
	FSBaseMission.registerActionEvents = Utils.appendedFunction(FSBaseMission.registerActionEvents, VehicleSort.RegisterActionEvents);
	
	VehicleSort:initVS();
	VehicleSort:loadConfig();
	
	-- We'd get an error when we want to access the config menu and the data is not populated yet. Same as there is some functionality in corner cases where we
	-- already need a populated Sorted list, hence we're going to pouplate it once here
	for i = 1, #VehicleSort.config do
		local val = {i, VehicleSort.config[i]};
		table.insert(VehicleSort.orderedConfig, val);
	end
	table.sort(VehicleSort.orderedConfig, function(a, b) return a[2][3] < b[2][3] end)	
end

function VehicleSort:prepareVeEx()
	-- Primarily necessary so that the train status get set
	-- But it also doesn't harm to have the list ready for tabbing and opening it for the first time
	VehicleSort.Sorted = VehicleSort:getOrderedVehicles();
	VehicleSort.firstRun = false;
end

---Called before loading
-- @param table savegame savegame
function VehicleSort:onPreLoad(savegame)
	--FS22 No idea if that's the proper way, but it seems it works
	VehicleSort.initSpecialization()
end

---Called on loading
-- @param table savegame savegame
function VehicleSort:onLoad(savegame)
end

function VehicleSort:onPostLoad(savegame)

	if savegame ~= nil then

		local orderId = savegame.xmlFile:getValue(savegame.key..".vehicleSort#UserOrder")
		if orderId ~= nil then
			VehicleSort:dp(string.format('Loaded orderId {%d} for vehicleId {%d}', orderId, self.id), 'onPostLoad');
		end
		
		if self.spec_vehicleSort ~= nil then
			self.spec_vehicleSort.id = self.id;
			if orderId ~= nil then
				self.spec_vehicleSort.orderId = orderId;
			end
		end
		
		local isParked = Utils.getNoNil(savegame.xmlFile:getValue(savegame.key..".vehicleSort#isParked"), false)
		if isParked then
			VehicleSort:dp(string.format('Set isParked {%s} for orderId {%d} / vehicleId {%d}', tostring(isParked), orderId, self.id), 'onPostLoad');
			self:setIsTabbable(false);
		end
		
		-- For any reason trains get handled differently, and simply ignore what we set at this stage. So lets store the status to hande it later on.
		if self.typeName == 'locomotive' then
			if VehicleSort.loadTrainStatus[self.id] == nil then
				VehicleSort.loadTrainStatus[self.id] = {};
				VehicleSort.loadTrainStatus.entries = VehicleSort.loadTrainStatus.entries + 1;
			end
			VehicleSort.loadTrainStatus[self.id]['isParked'] = isParked;
			--VehicleSort:dp(string.format('Added train isParked to loadTrainStatus. orderId {%d}, id {%d}', orderId, Utils.getNoNil(self.id, 0)));
		end
	end
end

function VehicleSort:onDelete()
	VehicleSort:dp(string.format('Going to remove vehicle realId {%d}, userOrder {%d}', Utils.getNoNil(self.spec_vehicleSort.realId, 0), Utils.getNoNil(self.spec_vehicleSort.orderId, 0)));
	--VehicleSort:dp(self);

	if self.spec_vehicleSort ~= nil then
		table.remove(VehicleSort.Sorted, self.spec_vehicleSort.orderId);
		--We've to build the list again, as we've new realId's after a vehicle got removed
		VehicleSort.dirtyState = true;
		VehicleSort.Sorted = VehicleSort:getOrderedVehicles();
		--VehicleSort:SyncSorted();
	end
end

function VehicleSort:RegisterActionEvents(isSelected, isOnActiveVehicle)

	local actions = {
					"vsToggleList",
					"vsLockListItem",
					"vsMoveCursorUp",
					"vsMoveCursorDown",
					"vsMoveCursorUpFast",
					"vsMoveCursorDownFast",
					"vsChangeVehicle",
					"vsShowConfig",
					"vsTogglePark",
					"vsRepair",
					"vsTab",
					"vsTabBack",
					"vsEasyTab"
				};

	for _, action in pairs(actions) do
		local actionMethod = string.format("action_%s", action);
		local result, eventName = InputBinding.registerActionEvent(g_inputBinding, action, self, VehicleSort[actionMethod], false, true, false, true)
		if result then
			table.insert(VehicleSort.eventName, eventName);
			g_inputBinding.events[eventName].displayIsVisible = VehicleSort.config[13][2];
		end
	end
	
end

function VehicleSort.registerEventListeners(vehicleType)
	local functionNames = {	"onPreLoad", "onLoad", "onPostLoad", "saveToXMLFile", "onDelete" };
	
	for _, functionName in ipairs(functionNames) do
		SpecializationUtil.registerEventListener(vehicleType, functionName, VehicleSort);
	end
end

function VehicleSort:keyEvent(unicode, sym, modifier, isDown)
end

function VehicleSort:mouseEvent(posX, posY, isDown, isUp, button)
	if VehicleSort:isActionAllowed() and ( isDown and button == Input.MOUSE_BUTTON_LEFT) then
		VehicleSort.action_vsChangeVehicle();
	end

	if VehicleSort:isActionAllowed() and ( isDown and button == Input.MOUSE_BUTTON_RIGHT) then
		VehicleSort.action_vsLockListItem();
	end

	if VehicleSort:isActionAllowed() and ( isDown and Input.isMouseButtonPressed(Input.MOUSE_BUTTON_WHEEL_UP)) then
		VehicleSort.action_vsMoveCursorUp();
	end
	
	if VehicleSort:isActionAllowed() and ( isDown and Input.isMouseButtonPressed(Input.MOUSE_BUTTON_WHEEL_DOWN)) then
		VehicleSort.action_vsMoveCursorDown();
	end	
end

function VehicleSort:saveToXMLFile(xmlFile, key)
	VehicleSort:dp(string.format('key {%s}', key), 'saveToXMLFile');
	if self.spec_vehicleSort ~= nil then
		if self.spec_vehicleSort.orderId ~= nil then
			xmlFile:setValue(key.."#UserOrder", self.spec_vehicleSort.orderId)
		end
		
		if VehicleSort:isParked(self.spec_vehicleSort.realId) then
			xmlFile:setValue(key.."#isParked", true)
		end
	end
end

function VehicleSort:update()
	-- Don't really like to add VeEx to update as it's not really necessary, but haven't found another solution to set the train motor&parked stated after load
	if VehicleSort.firstRun then
		VehicleSort:prepareVeEx();
	end
	
	--This should allow to have the default keybindings for Tab & Shift+Tab, while still using the ordered tabbing from VeEx, at least if it's activated
	if VehicleSort.config[28][2] then
		VehicleSort:overwriteDefaultTabBinding();
	end
	
end

function VehicleSort:draw()
	
	--VehicleSort:dp(string.format('showConfig [%s] & showVehicles [%s]', tostring(VehicleSort.showConfig), tostring(VehicleSort.showVehicles)));
  
	if VehicleSort.showConfig or VehicleSort.showVehicles then
		local dbgY = VehicleSort.dbgY;
		VehicleSort.bgY = nil;
		VehicleSort.bgW = nil;
		VehicleSort.bgH = nil;
		if VehicleSort.showConfig then
		  VehicleSort:drawConfig();
		else
		  VehicleSort:drawList();
		end
	end
	
end

function VehicleSort:delete()
end

function VehicleSort:deleteMap()
end

-- Functions for actionEvents/inputBindings

function VehicleSort:action_vsToggleList(actionName, keyStatus, arg3, arg4, arg5)
	VehicleSort:dp("vsToggleList fires", "vsToggleList");

	if envTardis == nil and VehicleSort.config[22][2] then
		-- Integration with Tardis
		local TardisName = "FS19_Tardis";

		if g_modIsLoaded[TardisName] then
			envTardis = getfenv(0)[TardisName];
			print("VehicleExplorer: Tardis integration available");
		end
	end
		
	if VehicleSort.showVehicles and not VehicleSort.showConfig then
		VehicleSort.showVehicles = false;
		VehicleSort.selectedLock = false;
	else
		VehicleSort.showVehicles = true;
		if VehicleSort.showConfig then
			VehicleSort.saveConfig();
		end
		VehicleSort.showConfig = false;
    end
end

function VehicleSort:action_vsLockListItem(actionName, keyStatus, arg3, arg4, arg5)
	VehicleSort:dp("vsLockListItem fires", "vsLockListItem");
	if VehicleSort.showVehicles then
		if not VehicleSort.selectedLock and VehicleSort.selectedIndex > 0 then
			VehicleSort.selectedLock = true;
		elseif VehicleSort.selectedLock then
			VehicleSort.selectedLock = false;
		end
	elseif VehicleSort.showConfig then
		if VehicleSort:contains({9, 20}, VehicleSort.selectedRealConfigIndex) then
			VehicleSort.config[VehicleSort.selectedRealConfigIndex][2] = VehicleSort.config[VehicleSort.selectedRealConfigIndex][2] + 1;
			if VehicleSort.config[VehicleSort.selectedRealConfigIndex][2] > 3 then
				VehicleSort.config[VehicleSort.selectedRealConfigIndex][2] = 1;
			end
		elseif VehicleSort:contains({24, 25, 26}, VehicleSort.selectedRealConfigIndex) then
			VehicleSort.config[VehicleSort.selectedRealConfigIndex][2] = VehicleSort.config[VehicleSort.selectedRealConfigIndex][2] + 1;
			if VehicleSort.config[VehicleSort.selectedRealConfigIndex][2] > 9 then
				VehicleSort.config[VehicleSort.selectedRealConfigIndex][2] = 1;
			end			
		elseif VehicleSort:contains({10, 17}, VehicleSort.selectedRealConfigIndex) then
			VehicleSort.config[VehicleSort.selectedRealConfigIndex][2] = VehicleSort.config[VehicleSort.selectedRealConfigIndex][2] + 0.1;
			if VehicleSort.config[VehicleSort.selectedRealConfigIndex][2] > 1 then
				VehicleSort.config[VehicleSort.selectedRealConfigIndex][2] = 0.0;
			end
		else
			VehicleSort.config[VehicleSort.selectedRealConfigIndex][2] = not VehicleSort.config[VehicleSort.selectedRealConfigIndex][2];
		end
	end
end

function VehicleSort:action_vsMoveCursorUp(actionName, keyStatus, arg3, arg4, arg5)
	VehicleSort:dp("action_vsMoveCursorUp fires", "action_vsMoveCursorUp");
	if VehicleSort.showVehicles then
		if Input.isKeyPressed(KEY_lalt) then
			VehicleSort:moveUp(3);
		else
			VehicleSort:moveUp(1);
		end
	elseif VehicleSort.showConfig then
		VehicleSort:moveConfigUp();
	end
end

function VehicleSort:action_vsMoveCursorDown(actionName, keyStatus, arg3, arg4, arg5)
	VehicleSort:dp("action_vsMoveCursorDown fires", "action_vsMoveCursorDown");
	if VehicleSort.showVehicles then
		VehicleSort:moveDown(1);
	elseif VehicleSort.showConfig then
		VehicleSort:moveConfigDown();
	end	
end

function VehicleSort:action_vsMoveCursorUpFast(actionName, keyStatus, arg3, arg4, arg5)
	VehicleSort:dp("action_vsMoveCursorUpFast fires", "action_vsMoveCursorUpFast");
	if VehicleSort.showVehicles then 
		VehicleSort:moveUp(3);
	end	
end

function VehicleSort:action_vsMoveCursorDownFast(actionName, keyStatus, arg3, arg4, arg5)
	VehicleSort:dp("action_vsMoveCursorDownFast fires", "action_vsMoveCursorDownFast");
	if VehicleSort.showVehicles then 
		VehicleSort:moveDown(3);
	end	
end

function VehicleSort:action_vsChangeVehicle(actionName, keyStatus, arg3, arg4, arg5)
	VehicleSort:dp("action_vsChangeVehicle fires", "action_vsChangeVehicle");
	if VehicleSort.showVehicles then
		local realVeh = g_currentMission.vehicles[VehicleSort.Sorted[VehicleSort.selectedIndex]];
		if realVeh.getIsControlled and not realVeh:getIsControlled() then

			VehicleSort:dp(string.format('VehicleSort.wasTeleportAction {%s}', tostring(VehicleSort.wasTeleportAction)));
			
			if envTardis == nil or 
						(envTardis ~= nil and not VehicleSort.wasTeleportAction) or 
						(envTardis ~= nil and VehicleSort.wasTeleportAction and VehicleSort.config[23][2]) then
				g_currentMission:requestToEnterVehicle(realVeh);
				VehicleSort:easyTab(realVeh);
				VehicleSort.wasTeleportAction = false;
			elseif envTardis ~= nil then
				VehicleSort.wasTeleportAction = false;
			end
		end
	end
end

function VehicleSort:action_vsShowConfig(actionName, keyStatus, arg3, arg4, arg5)
	VehicleSort:dp("action_vsShowConfig fires", "action_vsShowConfig");
	if VehicleSort.showVehicles and not VehicleSort.showConfig then
      VehicleSort.showVehicles = false;
	end
    
	VehicleSort.showConfig = not VehicleSort.showConfig;
	VehicleSort:saveConfig();
	
	--Directly set the displayIsVisible for the F1 help menu
	if VehicleSort.config[13][2] then
		VehicleSort:setHelpVisibility(VehicleSort.eventName, true)
		--If Tardis integration is available we'll also do the same for it
		if envTardis ~= nil and #Tardis.eventName > 0 then
			VehicleSort:setHelpVisibility(Tardis.eventName, true)
		end	
	else
		VehicleSort:setHelpVisibility(VehicleSort.eventName, false)
		if envTardis ~= nil and #Tardis.eventName > 0 then
			VehicleSort:setHelpVisibility(Tardis.eventName, false)
		end
	end
	
	InputBinding:notifyEventChanges();
end

function VehicleSort:action_vsTogglePark(actionName, keyStatus, arg3, arg4, arg5)
	VehicleSort:dp("action_vsTogglePark fires", "action_vsTogglePark");
	if VehicleSort.showVehicles then
		VehicleSort:toggleParkState(VehicleSort.selectedIndex);
	end
end

function VehicleSort:action_vsRepair(actionName, keyStatus, arg3, arg4, arg5)
	VehicleSort:dp(string.format('action_vsRepair fires - VehicleSort.showVehicles {%s}', tostring(VehicleSort.showVehicles)), "action_vsRepair");
	if VehicleSort.showVehicles then
	
		local infoText = {};
		local blinkTime = 2000;
		VehicleStatus:RepairVehicleWithImplements(VehicleSort.Sorted[VehicleSort.selectedIndex]);
		table.insert(infoText, g_i18n.modEnvironments[VehicleSort.ModName].texts.RepairDone);
		
		if VehicleSort.config[21][2] then
			VehicleStatus:CleanVehicleWithImplements(VehicleSort.Sorted[VehicleSort.selectedIndex]);
			--We want the blinking text to be centered
			
			table.insert(infoText, g_i18n.modEnvironments[VehicleSort.ModName].texts.CleaningDone);
			blinkTime = 3000;
		end
		
		--If 'repaint' is enabled the config we also have to take care of this
		if VehicleSort.config[29][2] then
			VehicleStatus:RepaintVehicleWithImplements(VehicleSort.Sorted[VehicleSort.selectedIndex]);
			table.insert(infoText, g_i18n.modEnvironments[VehicleSort.ModName].texts.RepaintDone);
			blinkTime = 4000;
		end
		
		VehicleSort:showCenteredBlinkingWarning(infoText, blinkTime);
		
	end
end

function VehicleSort:action_vsTab(actionName, keyStatus, arg3, arg4, arg5)
	VehicleSort:dp(string.format('action_vsTab fires - VehicleSort.showVehicles {%s}', tostring(VehicleSort.showVehicles)), "action_vsTab");
	VehicleSort:tabVehicle();
end

function VehicleSort:action_vsTabBack(actionName, keyStatus, arg3, arg4, arg5)
	VehicleSort:dp(string.format('action_vsTabBack fires - VehicleSort.showVehicles {%s}', tostring(VehicleSort.showVehicles)), "action_vsTabBack");
	VehicleSort:tabVehicle(true);
end

function VehicleSort:action_vsEasyTab(actionName, keyStatus, arg3, arg4, arg5)
	VehicleSort:dp(string.format('action_vsEasyTab fires - VehicleSort.showVehicles {%s}', tostring(VehicleSort.showVehicles)), "action_vsEasyTab");
	VehicleSort:easyTab();
end

--
-- VehicleSort specific functions
--
function VehicleSort:calcPercentage(curVal, maxVal)
	local per = curVal / maxVal * 100;
	return (math.floor(per * 10)/10);
end

function VehicleSort:drawConfig()
	local xPos = VehicleSort.tPos.x;
	local yPos = VehicleSort.tPos.y;
	local size = VehicleSort:getTextSize();
	local y = VehicleSort.tPos.y;
	local txtOn = g_i18n.texts.ui_on;
	local txtOff = g_i18n.texts.ui_off;
	local texts = {};
	VehicleSort.bgW = (VehicleSort.tPos.columnWidth * 2 )+ VehicleSort.tPos.padSides + getTextWidth(size, txtOff);		--For config we can use wider columns


		-- We render the heading seperately to have it centered, despite the user config for the list
	local headingY = VehicleSort.tPos.y + size + (VehicleSort.tPos.padHeight * 6);
	local txt = g_i18n.modEnvironments[VehicleSort.ModName].texts.configHeadline;
	setTextAlignment(VehicleSort.tPos.alignmentC);
	setTextColor(unpack(VehicleSort.tColor.standard));
	renderText(VehicleSort.tPos.x, headingY, size + VehicleSort.tPos.sizeIncr, tostring(txt)); -- x, y, size, txt

	setTextAlignment(VehicleSort.tPos.alignmentL);
	
	--VehicleSort:dp(orderedConfig, 'drawConfig');
	-- And now the rest of our config
	for k, v in ipairs(VehicleSort.orderedConfig) do
		local clr = VehicleSort.tColor.standard;
		if k == VehicleSort.selectedConfigIndex then
		  clr = VehicleSort.tColor.selected;
		end
		local rText = g_i18n.modEnvironments[VehicleSort.ModName].texts[VehicleSort.config[v[1]][1]];
		local state = VehicleSort.config[v[1]][2];
		if VehicleSort:contains({9, 24, 25, 26}, v[1]) then							--txtSize, showImgMaxImp, showInfoMaxImpl, showImplementsMax as int
			state = string.format('%d', state);
		elseif VehicleSort:contains({10, 17}, v[1]) then						--bgTransparency, VehicleSort.infoYStart as float
			state = string.format('%.1f', state);
		elseif v[1] == 20 then 			-- List text alignment
			if state == 1 then
				state = g_i18n.modEnvironments[VehicleSort.ModName].texts.left;
			elseif state == 2 then
				state = g_i18n.modEnvironments[VehicleSort.ModName].texts.center;
			elseif state == 3 then
				state = g_i18n.modEnvironments[VehicleSort.ModName].texts.right;
			end
		elseif state then
		  state = txtOn;
		else
		  state = txtOff;
		end
		table.insert(texts, {xPos - (VehicleSort.bgW / 2) + VehicleSort.tPos.padSides, yPos, size, clr, rText}); --config definition line
		table.insert(texts, {xPos - (VehicleSort.bgW / 2) + (VehicleSort.tPos.columnWidth * 2), yPos, size, clr, state}); --config value
		yPos = yPos - size - VehicleSort.tPos.spacing;
	end
  
	VehicleSort.bgY = yPos;
	VehicleSort.bgH = (y - yPos) + size + VehicleSort.tPos.yOffset + VehicleSort.tPos.padHeight;
	if VehicleSort.bgY ~= nil and VehicleSort.bgW ~=nil and VehicleSort.bgH ~= nil then
		VehicleSort:renderBg(VehicleSort.bgX, VehicleSort.bgY, VehicleSort.bgW, VehicleSort.bgH);
	end;  

	setTextBold(false);
	for k, v in ipairs(texts) do
		setTextColor(unpack(v[4]))
		renderText(v[1], v[2], v[3], tostring(v[5]));
	end
	setTextColor(unpack(VehicleSort.tColor.standard));
  
	--Show the last selected vehicle for info/image position & BG option
	if VehicleSort:contains({17, 18, 19, 24, 25}, VehicleSort.selectedRealConfigIndex) then
		if g_currentMission.vehicles[VehicleSort.Sorted[VehicleSort.selectedIndex]] ~= nil then
			VehicleSort:drawInfobox(VehicleSort.Sorted[VehicleSort.selectedIndex]);
			VehicleSort:drawStoreImage(VehicleSort.Sorted[VehicleSort.selectedIndex]);
		end
	end
  
end

function VehicleSort:drawList()
  VehicleSort.Sorted = VehicleSort:getOrderedVehicles();
   
   if VehicleSort.HiddenCount == #VehicleSort.Sorted then
		VehicleSort:showNoVehicles();
		VehicleSort.showVehicles = false;
		return false;
   end
   
  --VehicleSort:dp(vehList, 'drawList', 'vehList');
  
	local cnt = #VehicleSort.Sorted;
	if cnt == 0 then
		return;
	end
	setTextBold(true); -- for width checks, to compensate for increased width when the line is bold
 
	local yPos = VehicleSort.tPos.y;
	local bgPosY = yPos; 
	local size = VehicleSort.getTextSize();
	local y = VehicleSort.tPos.y;
	local txt = g_i18n.modEnvironments[VehicleSort.ModName].texts.vs_title;
	local texts = {};
	local bold = false;
	local minBgW = 0;
	VehicleSort.bgY = y - VehicleSort.tPos.spacing;
	VehicleSort.bgW = getTextWidth(size, txt) + VehicleSort.tPos.padSides;		--Background width will be dynamically adjusted later on. Just a value to get started with
  
	-- We render the heading seperately to have it centered, despite the user config for the list
	local headingY = VehicleSort.tPos.y + size + (VehicleSort.tPos.padHeight * 6);
  
	setTextAlignment(VehicleSort.tPos.alignmentC);
	setTextColor(unpack(VehicleSort.tColor.standard));
	renderText(VehicleSort.tPos.x, headingY, size + VehicleSort.tPos.sizeIncr, tostring(txt)); -- x, y, size, txt

	-- Now set the list alignment based on the config
	if VehicleSort.config[20][2] == 1 then
		setTextAlignment(VehicleSort.tPos.alignmentL);
	elseif VehicleSort.config[20][2] == 3 then
		setTextAlignment(VehicleSort.tPos.alignmentR);
	else
		setTextAlignment(VehicleSort.tPos.alignmentC);
	end
 
	--Just used to figure out if we'll have multiple columns, hence we've to loop through the amount of vehicles to get the total height of the table
	--This assumes that there is just one line/vehicle. But it's a rough guess though
	local chk = yPos + size + VehicleSort.tPos.spacing;
	local chkColNum = 1;
	
	--Min distance to the bottom of the screen
	local minY = ((4 * (size + VehicleSort.tPos.spacing)) + VehicleSort.tPos.padHeight);
	
	for i = 1, cnt do --loop through lines to see if there will be multiple columns needed
		if not VehicleSort:isHidden(VehicleSort.Sorted[i]) then
			chk = chk - size - VehicleSort.tPos.spacing;
			if chk < minY then
				chkColNum = chkColNum + 1;
				chk = yPos + size + VehicleSort.tPos.spacing;	--For a new colum we've to reset this
			end
		end
	end

	local colNum = 1;			--For multiple columns this counter gets increased
	--VehicleSort:dp(string.format('chk {%f} | check for chk {%f} | minY {%f}', chk, size + VehicleSort.tPos.spacing + VehicleSort.tPos.padHeight, minY));
	--VehicleSort:dp(string.format('minY {%s} - chk {%s} - chkColNum {%s}', minY, chk, chkColNum));
	
	-- Calc our maxTxtW based on the expected number of columns.
	--As we support just three columns we do the calc based on 3. In case we don't show a infobox we can add the space of one additional column
	local maxTxtW = 0;
	if VehicleSort.config[16][2] then
		maxTxtW = (VehicleSort.tPos.columnWidth - VehicleSort.tPos.padSides) * (3 / chkColNum);
	else
		maxTxtW = (VehicleSort.tPos.columnWidth - VehicleSort.tPos.padSides) * (3 / chkColNum) + VehicleSort.tPos.columnWidth;
	end
	
	--VehicleSort:dp(string.format('columnWidth {%s} - maxTxtW {%s} - chkColNum {%s}', VehicleSort.tPos.columnWidth, maxTxtW, chkColNum));
	
	for i = 1, cnt do
		local realId = VehicleSort.Sorted[i];
		if not VehicleSort:isHidden(realId) then

			local clr = VehicleSort:getTextColor(i, realId);
			local fullNameTable = VehicleSort:getFullVehicleName(realId);
			txt = table.concat(fullNameTable);

			-- Check if the line is not longer as our max txtLength, otherwise split it up to multiple lines
			-- We don't have to care about the MaxNumImplements anymore, as we already consider that in getFullVehicleName
			local multiLine = {};
			if getTextWidth(size, txt) > maxTxtW then
				while #fullNameTable > 0 do
					local line = ''
					while (fullNameTable[1] ~= nil) and (getTextWidth(size, line) < maxTxtW) do
						line = line .. fullNameTable[1];
						table.remove(fullNameTable, 1);
					end
					table.insert(multiLine, line);
				end
				-- Otherwise we add the lines twice
				txt = '';
			end
			
			bold = VehicleSort:isControlled(realId) and (not g_currentMission.missionDynamicInfo.isMultiplayer or VehicleSort:getControllerName(realId) == g_gameSettings.nickname);
			
			if string.len(txt) > 0 then
				table.insert(texts, {colNum, yPos, size, bold, clr, txt});
				yPos = yPos - size - VehicleSort.tPos.spacing;
				
				-- To find our proper background width and the position of the columns we've to keep track of the longest text
				VehicleSort.bgW = math.max(VehicleSort.bgW, getTextWidth(size, txt) + VehicleSort.tPos.padSides);
			end
			
			-- And for multiline entries we've to add multiple entries to our texts table
			if #multiLine > 0 then
				for k, v in ipairs(multiLine) do
					if string.len(v) > 0 then
						table.insert(texts, {colNum, yPos, size, bold, clr, v});
						yPos = yPos - size - VehicleSort.tPos.spacing;
						VehicleSort.bgW = math.max(VehicleSort.bgW, getTextWidth(size, v) + VehicleSort.tPos.padSides);
					end
				end
			end
		
			
			-- We don't want our background go further than necessary
			bgPosY = math.min(bgPosY, yPos);
		end
		
		if yPos < minY then -- getting near bottom of screen, start a new column
			yPos = VehicleSort.tPos.y;
			colNum = colNum + 1;
		end
	end

	setTextBold(false);

	--Drawing our background
	bgPosY = bgPosY - VehicleSort.tPos.spacing; -- bottom padding

	VehicleSort.bgY = bgPosY;
	VehicleSort.bgH = (y - bgPosY) + size + VehicleSort.tPos.sizeIncr + VehicleSort.tPos.yOffset + VehicleSort.tPos.spacing;
	VehicleSort.bgW = VehicleSort.bgW * colNum;
	if VehicleSort.bgY ~= nil and VehicleSort.bgW ~=nil and VehicleSort.bgH ~= nil then
		VehicleSort:renderBg(VehicleSort.bgX, VehicleSort.bgY, VehicleSort.bgW, VehicleSort.bgH);
	end

	--We've to calculate our X based on each column.
	local tblColWidth = VehicleSort.bgW / colNum;
	
	local tPosXAligned = VehicleSort.tPos.x;
	if VehicleSort.config[20][2] == 1 then
		tPosXAligned = VehicleSort.tPos.x - (tblColWidth / 2) + VehicleSort.tPos.padSides;
	elseif VehicleSort.config[20][2] == 3 then
		tPosXAligned = VehicleSort.tPos.x + (tblColWidth / 2) - VehicleSort.tPos.padSides;
	end
	
	local colX = {};
	colX[0] = tPosXAligned;
	if colNum == 2 then
		colX[1] = tPosXAligned - (tblColWidth / 2);
		colX[2] = tPosXAligned + (tblColWidth / 2);
	elseif colNum == 3 then
		colX[1] = tPosXAligned - tblColWidth;
		colX[2] = tPosXAligned;
		colX[3] = tPosXAligned + tblColWidth;
	else
		--We just support 3 columsn. So this case is primarily for one column and as a 'catch all' which won't work but I don't care for now
		colX[1] = tPosXAligned;
	end	
	
	--VehicleSort:dp(colX, 'drawList');
	
	for k, v in ipairs(texts) do
		if type(v[4]) == 'boolean' then
			setTextBold(v[4]);
		end
		setTextColor(unpack(v[5]));
		local storColNum = v[1];
		--VehicleSort:dp(storColNum, 'drawList', 'storcolNum');
		renderText(colX[storColNum], v[2], v[3], tostring(v[6])); -- x, y, size, txt
	end

	setTextBold(false);
	setTextColor(unpack(VehicleSort.tColor.standard));
  
	if VehicleSort.config[15][2] then
		VehicleSort:drawStoreImage(VehicleSort.Sorted[VehicleSort.selectedIndex]);
	end

	if VehicleSort.config[16][2] then
		VehicleSort:drawInfobox(VehicleSort.Sorted[VehicleSort.selectedIndex])
	end
  
end

function VehicleSort:getVehicles()
	local allveh = g_currentMission.vehicles
	local veh = {}
	
	for k, v in ipairs(allveh) do
		if not v.isDeleted then
			if v.spec_vehicleSort ~= nil then
				v.spec_vehicleSort.realId = k;
				table.insert(veh, v);
				
				-- Handle trains at this stage for first load, as we loop through all vehicles anyways
				if VehicleSort:isTrain(k) and VehicleSort.loadTrainStatus.entries > 0 then
					VehicleSort:handlePostloadTrains(k);
				end
			end
		end
	end
	return veh;
end

function VehicleSort:getVehImplements(realId)
	if g_currentMission.vehicles[realId].getAttachedImplements ~= nil then
		if #g_currentMission.vehicles[realId]:getAttachedImplements() > 0 then
			local allImp = {}
			-- Credits to Tardis from FS17
			local function addAllAttached(obj)
				if obj.getAttachedImplements ~= nil then
					for _, imp in pairs(obj:getAttachedImplements()) do
						addAllAttached(imp.object);
						table.insert(allImp, imp);
					end
				end
			end
                
            addAllAttached(g_currentMission.vehicles[realId]);
			return allImp;
		else
			return nil;
		end
	else
		return nil;
	end
end

-- We can't use getFullName for Attachments as that's causing lua callstacks once CP or a helper is used
-- Hence we build our own full name with the help of the store & brand manager
function VehicleSort:getAttachmentName(obj)
	local val = '';
	if VehicleSort.config[3][2] then
		local brand = VehicleSort:getAttachmentBrand(obj);
		if brand ~= nil then
			val = val .. string.format('%s %s', brand, obj:getName());
		else
			val = val .. string.format('%s ', obj:getName());
		end
	else
		val = val .. string.format('%s', obj:getName());
	end
	--VehicleSort:dp(string.format('val = {%s}', val), getAttachmentName);
	return val;
end

-- Not using :getFullName, as it will throw lua call stacks for not getting the helper name when using CP
function VehicleSort:getAttachmentBrand(obj)
    local storeItem = g_storeManager:getItemByXMLFilename(obj.configFileName);
    if storeItem ~= nil then
        local brand = g_brandManager:getBrandByIndex(storeItem.brandIndex);
        if brand ~= nil then
            return brand.title;
		else
			return 'Lizard';
        end
    end
end

function VehicleSort:getFillLevel(obj)

	local fillLevel = 0;
	local cap = 0;
	local fillType = "";
	
	if obj.getFillUnits ~= nil then
		for _, fillUnit in ipairs(obj:getFillUnits()) do
			-- We don't want to take care of Diesel, Def or Air right now
			if (fillUnit.fillType ~= 37) and (fillUnit.fillType ~= 38) and (fillUnit.fillType ~= 39) then
				fillLevel = fillUnit.fillLevel
				cap = fillUnit.capacity
				fillType = g_fillTypeManager.fillTypes[fillUnit.fillType]['title']
			end
			
			--DummyMod:dp(string.format('FillLevel - fillUnitID {%f} - fillLevel {%f} - capacity {%f} - fillType {%s}', fillUnit.fillUnitIndex, fillLevel, cap, fillType), 'getFillLevel');
		end
	end

	--VehicleSort:dp(string.format('FillLevel fillLevel {%f} - capacity {%f}', fillLevel, cap), 'getFillLevel');
	--VehicleSort:dp(string.format('fillType {%s} - fillTypeIndex {%s} - filltypeTitle {%s}', fillLevelVehicle.fillType, fillTypeIndex, fillType));	
	
	return fillLevel, cap, fillType
end

function VehicleSort:getFillDisplay(obj, infoBox)
	local ret = '';
	if VehicleSort.config[6][2] or infoBox then -- Fill-Level-Display active?
		local f, c, t = VehicleSort:getFillLevel(obj);
		
		if not infoBox then t = ""; end;	-- we use the same method for the list and the infobox. But the fillType should just be visible in the infobox
		
		if VehicleSort.config[8][2] or f > 0 then -- Empty should be shown or is not empty
			if c > 0 then -- Capacity more than zero
				if infoBox then  -- show more details in the infobox
					ret = string.format('%d/%d (%d %%) %s', math.floor(f), c, VehicleSort:calcPercentage(f, c), t);
				elseif VehicleSort.config[7][2] then -- Display as percentage
					ret = string.format(' (%d %%) %s', VehicleSort:calcPercentage(f, c), t);
				else -- Display as amount of total capacity
					ret = string.format(' (%d/%d) %s', math.floor(f), c, t);
				end
			end
		end
	end
	
	return ret;
end

function VehicleSort:getFullVehicleName(realId)
	local nam = '';
	local ret = {};
	local tmpString = '(%s) ';
  
	if VehicleSort:isParked(realId) then
		nam = '[P] '; -- Prefix for parked (not part of tab list) vehicles
	end
	if g_currentMission.vehicles[realId] ~= nil and VehicleSort:getIsCourseplay(g_currentMission.vehicles[realId]) then -- CoursePlay
		nam = nam .. string.format(tmpString, g_i18n.modEnvironments[VehicleSort.ModName].texts.courseplay);
	elseif (g_currentMission.vehicles[realId].getIsFollowMeActive and g_currentMission.vehicles[realId]:getIsFollowMeActive()) then	--FollowMe
		nam = nam .. string.format(tmpString, g_i18n.modEnvironments[VehicleSort.ModName].texts.followme);
	elseif (g_currentMission.vehicles[realId].ad ~= nil and g_currentMission.vehicles[realId].ad.stateModule ~= nil and g_currentMission.vehicles[realId].ad.stateModule.active) then	--AutoDrive
		nam = nam .. string.format(tmpString, g_i18n.modEnvironments[VehicleSort.ModName].texts.autodrive);
	elseif g_currentMission.vehicles[realId].aiveIsStarted then
		nam = nam .. string.format(tmpString, g_i18n.modEnvironments[VehicleSort.ModName].texts.aive);
	elseif VehicleSort:isHired(realId) then
		nam = nam .. string.format(tmpString, g_i18n.modEnvironments[VehicleSort.ModName].texts.hired);
	elseif VehicleSort:isControlled(realId) then
		local con = VehicleSort:getControllerName(realId);
		if VehicleSort.config[5][2] and con ~= nil and con ~= 'Unknown' and con ~= '' then
			nam = nam .. string.format(tmpString, con);
		end
	end

	if VehicleSort:isTrain(realId) then
		nam = nam .. VehicleSort:getName(realId, string.format('%s', g_i18n.modEnvironments[VehicleSort.ModName].texts.vs_train));
	elseif VehicleSort:isCrane(realId) then
		nam = nam .. VehicleSort:getName(realId, string.format('%s', g_i18n.modEnvironments[VehicleSort.ModName].texts.vs_crane));
	elseif VehicleSort.config[3][2] then -- Show brand
		nam = nam .. string.format('%s %s', VehicleSort:getBrandName(realId), VehicleSort:getName(realId));
	else
	  --VehicleSort:dp(veh.spec_vehicleSort, 'getFullVehicleName', 'Table spec_vehicleSort');
	  nam = nam .. string.format('%s', VehicleSort:getName(realId));
	end
	
	-- Show horse power
	if VehicleSort.config[4][2] then
		local horsePower = VehicleSort:getHorsePower(realId);
		if horsePower ~= nil then
			nam = nam .. " (" .. horsePower .. string.format(' %s)', g_i18n.modEnvironments[VehicleSort.ModName].texts.horsePower);
		end
	end

	table.insert(ret, nam .. VehicleSort:getFillDisplay(g_currentMission.vehicles[realId]));

	if VehicleSort:getVehImplements(realId) ~= nil and VehicleSort.config[12][2] then
		local implements = VehicleSort:getVehImplements(realId);
		
		local maxCount = VehicleSort.config[26][2];
		if #implements < maxCount then
			maxCount = #implements;
		end
		
		local linkWord = string.format(' %s', g_i18n.modEnvironments[VehicleSort.ModName].texts.with);
		for i=1, maxCount do
			local imp = implements[i];
			if (imp ~= nil and imp.object ~= nil) then
				if i > 1 then
					linkWord = "&";
				end
				table.insert(ret, string.format('%s %s%s ', linkWord, VehicleSort:getAttachmentName(imp.object), VehicleSort:getFillDisplay(imp.object)));		
			end
		end
	end

	return ret;
end

function VehicleSort:getName(realId, sFallback)
	nam = g_currentMission.vehicles[realId]:getName();
	if nam == nil then
		nam = obj.typeName;
	end	
	if nam == nil or nam == '' then
		return sFallback;
	else
		return nam;
	end
end

function VehicleSort:getBrandName(realId)
	--return g_currentMission.vehicles[realId]:getFullName();		--Problem is that getFullName also returns the helper name.
	local storeItem = g_storeManager:getItemByXMLFilename(g_currentMission.vehicles[realId].configFileName);
    if storeItem ~= nil then
		local brand = g_brandManager:getBrandByIndex(storeItem.brandIndex);
		if brand ~= nil then
            return brand.title;
		else
			return 'Lizard';
        end
    end
end

function VehicleSort:getOrderedVehicles()
	local ordered = {};
	local unordered = {};
	local orderedToOrder = {};
	VehicleSort.HiddenCount = 0;
	local vehList = VehicleSort:getVehicles();
  
	-- We don't want to do everything all the time, unless we know that something has changed, like after a vehicle got deleted
	-- TEST: Always return a Sorted list. Lets see if that helps us avoid the mixup with implements
	--[[
	if #VehicleSort.Sorted == #vehList and not VehicleSort.dirtyState then
		--VehicleSort:dp("Sorted list seems to be up to date. No need to redo everything", "getOrderedVehicles");
		return VehicleSort.Sorted;
	end
	]]
	--VehicleSort:dp("Sorted list seems outdated. So doing the ordering again.", "getOrderedVehicles");
  
	for _, veh in pairs(vehList) do
		if veh.spec_vehicleSort.orderId ~= nil then
			table.insert(orderedToOrder, {orderId=veh.spec_vehicleSort.orderId, realId=veh.spec_vehicleSort.realId} );
		else
			table.insert(unordered, veh.spec_vehicleSort.realId);
		end
		
		-- Keep track of hidden items, so that we're not showing an empty list
		if VehicleSort:isHidden(veh.spec_vehicleSort.realId) then
			VehicleSort.HiddenCount = VehicleSort.HiddenCount + 1;
		end
	end
	
	-- Now order our temp table based on the actual orderId
	table.sort(orderedToOrder, function(a,b) return a['orderId'] < b['orderId'] end)
	-- And to avoid any holes in the order or dups we'll just add them to a new ordered table
	for _, v in ipairs(orderedToOrder) do
		table.insert(ordered, v['realId']);
	end
	
	local cntOrdered = #ordered;
	
	if unordered ~= nil then
		for _, v in pairs(unordered) do
			table.insert(ordered, v);
		end
	end
	
	-- We might have to reorder the list in case we've missing entries or completely new vehicles
	if #vehList ~= cntOrdered or #unordered ~= 0 then
		VehicleSort:dp(string.format('Reshuffle of vehicles required. #vehList {%d} - cntOrdered {%d} - #unordered {%d}', #vehList, cntOrdered, #unordered));
		ordered = VehicleSort:reshuffleVehicles(ordered);
	end
	
	--VehicleSort:SyncSorted();
	return ordered;

end

function VehicleSort:reshuffleVehicles(list)
	local newList = {};
	local i = 1;
	for _, v in ipairs(list) do
		VehicleSort:dp(string.format('Reshuffle vehile: orderId {%d}, realId {%d}', i, v), 'reshuffleVehicles');
		-- Actually that shouldn't be necessary. But just had an corner case where an Hauer Weight suddenly showed up in the VehicleList
		-- So just to be sure and avoid any callstacks lets check if our spec is available
		if g_currentMission.vehicles[v]['spec_vehicleSort'] ~= nil then
			table.insert(newList, v);
			g_currentMission.vehicles[v]['spec_vehicleSort']['orderId'] = i;
			g_currentMission.vehicles[v]['spec_vehicleSort']['realId'] = v;
			i = i + 1;
		end
	end

	-- After a reshuffle our list should be in a proper state
	VehicleSort.dirtyState = false;
	return newList;
end

function VehicleSort:getTextColor(index, realId)
	--VehicleSort:dp(veh, 'getTextColor');
	if index == VehicleSort.selectedIndex then
		if VehicleSort.selectedLock then
			return VehicleSort.tColor.locked;
		else
			return VehicleSort.tColor.selected;
		end
	elseif VehicleSort:isParked(realId) then
		return VehicleSort.tColor.isParked;
	elseif VehicleSort:isControlled(realId) then
		return VehicleSort.tColor.self;
	-- Not sure yet if it make sense to have multiple different colors for CP, AD, FM. I imagine it's getting to busy then. But lets give it a try
	-- Has to be before 'isHired', otherwise will end up with the same hired color
	elseif g_currentMission.vehicles[realId] ~= nil and self:getIsCourseplay(g_currentMission.vehicles[realId]) then
		return VehicleSort.tColor.courseplay;
	elseif (g_currentMission.vehicles[realId].getIsFollowMeActive and g_currentMission.vehicles[realId]:getIsFollowMeActive()) then
		return VehicleSort.tColor.followme;
	elseif (g_currentMission.vehicles[realId].ad ~= nil and g_currentMission.vehicles[realId].ad.stateModule ~= nil and g_currentMission.vehicles[realId].ad.stateModule.active) then
		return VehicleSort.tColor.autodrive;
	elseif g_currentMission.vehicles[realId].aiveIsStarted then
		return VehicleSort.tColor.aive;
	elseif VehicleSort:isHired(realId) then
		return VehicleSort.tColor.hired;
	elseif VehicleStatus:getIsMotorStarted(g_currentMission.vehicles[realId]) then
		return VehicleSort.tColor.motorOn;
	else
		if VehicleSort.config[27][2] then						--Alterate the list colors if enabled
			if index % 2 == 0 then
				return VehicleSort.tColor.standard;
			else
				return VehicleSort.tColor.standard2;
			end
		else
			return VehicleSort.tColor.standard;
		end
	end
end

function VehicleSort:getTextSize()
  local val = tonumber(VehicleSort.config[9][2]);
  if val == nil or val < 1 or val > 3 then
    val = 2;
  end
  if val == 1 then
    return VehicleSort.tPos.sizeSmall;
  elseif val == 3 then
    return VehicleSort.tPos.sizeBig;
  else
    VehicleSort.config[9][2] = 2;
    return VehicleSort.tPos.size;
  end
end

function VehicleSort:getHorsePower(realId)
	if g_currentMission.vehicles[realId] ~= nil then
		if VehicleSort:isTrain(realId) then
			--VehicleSort:dp(string.format('isTrain -> realId {%s}', tostring(realId)), 'getHorsePower');
			return VehicleSort:getHorsePowerFromStore(realId)
		else
			local veh = g_currentMission.vehicles[realId]
			if veh.spec_motorized ~= nil then
				local maxMotorTorque = veh.spec_motorized.motor.peakMotorTorque
				local maxRpm = veh.spec_motorized.motor.maxRpm
				if maxRpm == 2200 then
					return math.ceil(maxMotorTorque / 0.0044)
				else
					--Maybe I'm just too stupid. But somehow I don't get the results with the more complex formula I want. Hence getting max power from store
					--HP = (torqueScale * torquecurvevalue * Pi * RPM / 30) * 1.35962161
					-- motor.lastMotorRpm
					--local torqueCurveVal = veh.spec_motorized.motor.torqueCurve.keyframes[6][1]
					--local torqueCurveRPM = veh.spec_motorized.motor.torqueCurve.keyframes[6]['time']
					--local hp = (maxMotorTorque * torqueCurveVal * math.pi * torqueCurveRPM / 30) * 1.35962161
					--VehicleSort:dp(string.format('maxRPM ~= 2200. HP for {%s} is: {%s}', veh.configFileName, hp))
					--VehicleSort:dp(string.format('torqueCurveVal {%s}, torqueCurveRPM {%s}, maxMotorTorque {%s}', tostring(torqueCurveVal), tostring(torqueCurveRPM), tostring(maxMotorTorque)))
					--return math.ceil(hp);
					local powerFromStore = VehicleSort:getHorsePowerFromStore(realId)
					if powerFromStore ~= nil then
						return math.ceil(powerFromStore)
					end
				end
			end
		end
	end
end

function VehicleSort:getHorsePowerFromStore(realId)
	--VehicleSort:dp(string.format('realId {%s}', tostring(realId)));
	local motorConfig = g_currentMission.vehicles[realId]['configurations']['motor']
	local confFile = string.lower(g_currentMission.vehicles[realId]['configFileName']);
	storeItem = g_storeManager.xmlFilenameToItem[confFile:lower()];
	--VehicleSort:dp(storeItem);
	if storeItem ~= nil then
		if storeItem.configurations ~= nil then
			--VehicleSort:dp(storeItem.configurations);
			if storeItem.configurations.motor ~= nil then
				if storeItem.configurations.motor[motorConfig].power ~= nil then
					return storeItem.configurations.motor[motorConfig].power;
				end
			end
		end
	end
end

function VehicleSort:getControllerName(realId)
	if not VehicleSort:isHired(realId) then
		if g_currentMission.vehicles[realId].getControllerName ~= nil then
			return g_currentMission.vehicles[realId]:getControllerName();
		else
			return "Unknown Controller";
		end
	end
end

function VehicleSort.initSpecialization()
    local schema = Vehicle.xmlSchemaSavegame
    schema:setXMLSpecializationType("vehicleSort")

	schema:register(XMLValueType.INT, "vehicles.vehicle(?).vehicleSort#UserOrder", "")
	schema:register(XMLValueType.BOOL, "vehicles.vehicle(?).vehicleSort#isParked", "")
    --schema:setXMLSpecializationType()
end

function VehicleSort:initVS()

	VehicleSort:dp('Start Init', 'VehicleSort:init');
	if g_dedicatedServerInfo ~= nil then -- Dedicated server does not need the initialization process
		VehicleSort:dp('Skipping undesired initialization on dedicated server.', 'VehicleSort:init');
		return;
	end
	VehicleSort.dbgX = 0.01;
	VehicleSort.dbgY = 0.5;
	VehicleSort.tPos = {};
	VehicleSort.tPos.x = 0.5;
	VehicleSort.tPos.center = 0.5;
	VehicleSort.tPos.y = g_currentMission.inGameMenu.hud.topNotification.origY + g_currentMission.inGameMenu.hud.topNotification.infoOffsetY;  -- y Position of Textfield, originally hardcoded 0.9
	VehicleSort.tPos.yOffset = g_currentMission.inGameMenu.hud.topNotification.infoOffsetY;  --* 1.5; -- y Position offset for headings, originally hardcoded 0.007
	VehicleSort.tPos.size = g_currentMission.inGameMenu.hud.gameInfoDisplay.timeTextSize;  -- TextSize, originally hardcoded 0.018
	VehicleSort.tPos.sizeBig = VehicleSort.tPos.size * 1.2;
	VehicleSort.tPos.sizeSmall = VehicleSort.tPos.size * 0.6;
	VehicleSort.tPos.sizeIncr = g_currentMission.inGameMenu.hud.speedMeter.cruiseControlTextOffsetY; -- Text size increase for headings
	VehicleSort.tPos.spacing = g_currentMission.inGameMenu.hud.speedMeter.cruiseControlTextOffsetY;  -- Spacing between lines, originally hardcoded 0.005
	VehicleSort.tPos.padHeight = VehicleSort.tPos.spacing;
	VehicleSort.tPos.padSides = VehicleSort.tPos.padHeight;
	--VehicleSort.tPos.columnWidth = (((1 - VehicleSort.tPos.x) / 2) );
	VehicleSort.tPos.columnWidth = 1 / 5;				--Max 3 columns for vehicles, and one left/right for spacing
	VehicleSort.tPos.alignmentL = RenderText.ALIGN_LEFT;  -- Text Alignment
	VehicleSort.tPos.alignmentC = RenderText.ALIGN_CENTER;  -- Text Alignment
	VehicleSort.tPos.alignmentR = RenderText.ALIGN_RIGHT;  -- Text Alignment

	VehicleSort:dp(VehicleSort.tPos, 'VehicleSort:init', 'tPos');
	VehicleSort.userPath = getUserProfileAppPath();
	VehicleSort.saveBasePath = VehicleSort.userPath .. 'modSettings/VehicleExplorer/';
-- ToDo MP
	if g_currentMission.missionDynamicInfo.serverAddress ~= nil then --multi-player game and player is not the host (dedi already handled above)
		VehicleSort.savePath = VehicleSort.saveBasePath .. g_currentMission.missionDynamicInfo.serverAddress .. '/';
	else
		VehicleSort.savePath = VehicleSort.saveBasePath .. 'savegame' .. g_careerScreen.savegameList.selectedIndex .. '/';
	end
	
	createFolder(VehicleSort.userPath .. 'modSettings/');
	createFolder(VehicleSort.saveBasePath);
	createFolder(VehicleSort.savePath);
	VehicleSort.xmlFilename = VehicleSort.savePath .. 'VeExConfig.xml';
	VehicleSort.bg = createImageOverlay('dataS/menu/blank.png'); --credit: Decker_MMIV, VehicleGroupsSwitcher mod
	VehicleSort.bgX = 0.5;
  
	VehicleSort:dp(string.format('Initialized userPath [%s] saveBasePath [%s] savePath [%s]',
	tostring(VehicleSort.userPath),
	tostring(VehicleSort.saveBasePath),
	tostring(VehicleSort.savePath)), 'VehicleSort:init');
end

function VehicleSort:isCrane(realId)
	if g_currentMission.vehicles[realId] ~= nil then
		return g_currentMission.vehicles[realId]['typeName'] == 'crane';
	end
end

function VehicleSort:isHidden(realId)
	return (VehicleSort:isTrain(realId) and not VehicleSort.config[1][2]) or (VehicleSort:isCrane(realId) and not VehicleSort.config[2][2]) or (VehicleSort:isSteerableImplement(realId) and not VehicleSort.config[11][2]);
end

function VehicleSort:isTrain(realId)
	--VehicleSort:dp(string.format('realId {%d}', realId), 'isTrain');
	if g_currentMission.vehicles[realId] ~= nil then
		return g_currentMission.vehicles[realId]['typeName'] == 'locomotive';
	end
end

function VehicleSort:isSteerableImplement(realId)
	if g_currentMission.vehicles[realId] ~= nil then
		return g_currentMission.vehicles[realId]['spec_attachable'] ~= nil;
	end
end

function VehicleSort:isControlled(realId)
	if not VehicleSort:isHired(realId) and g_currentMission.vehicles[realId].getIsControlled ~= nil then
		return g_currentMission.vehicles[realId]:getIsControlled(); 
	end
end

function VehicleSort:isParked(realId)
	if g_currentMission.vehicles[realId] ~= nil and g_currentMission.vehicles[realId].getIsTabbable ~= nil then
		return not g_currentMission.vehicles[realId]:getIsTabbable();
	end
end

function VehicleSort:isHired(realId)
	if g_currentMission.vehicles[realId] ~= nil and g_currentMission.vehicles[realId].spec_aiJobVehicle ~= nil then
		if g_currentMission.vehicles[realId].spec_aiJobVehicle.job ~= nil then
			return true
		end
	end
end

function VehicleSort:loadConfig()
	if fileExists(VehicleSort.xmlFilename) then
		VehicleSort.saveFile = loadXMLFile('VehicleSort.loadFile', VehicleSort.xmlFilename);

		if hasXMLProperty(VehicleSort.saveFile, VehicleSort.keyCon) then

			VehicleSort:dp('Config file found.', 'VehicleSort:loadConfig');
			for i = 1, #VehicleSort.config do
				if VehicleSort:contains({9},i) then				--txtsize as int with max value 3
					local int = getXMLString(VehicleSort.saveFile, VehicleSort.keyCon .. '.' .. VehicleSort.config[i][1]);
					if tonumber(int) == nil or tonumber(int) <= 0 or tonumber(int) > 3 then
						int = VehicleSort.txtSizeDef;
						print("VeEx Config: Invalid saved value for txtSizeDef. Set default value: " .. VehicleSort.txtSizeDef);
					else
						int = math.floor(tonumber(int));
					end
					VehicleSort.config[i][2] = int;
					VehicleSort:dp(string.format('txtSize value set to [%d]', int), 'VehicleSort:loadConfig');
				elseif VehicleSort:contains({24, 25, 26}, i) then	--max implements info & image, showImplementsMax as int with max value 9
					local int = getXMLString(VehicleSort.saveFile, VehicleSort.keyCon .. '.' .. VehicleSort.config[i][1]);
					if tonumber(int) == nil or tonumber(int) <= 0 or tonumber(int) > 9 then
						int = VehicleSort.config[i][2];
						print("VeEx Config: Invalid saved value for " .. VehicleSort.config[i][1] .. ". Set default value: " .. tostring(VehicleSort.config[i][2]));
					else
						int = math.floor(tonumber(int));
					end
					VehicleSort.config[i][2] = int;
					VehicleSort:dp(string.format('txtSize value set to [%d]', int), 'VehicleSort:loadConfig');
				elseif VehicleSort:contains({10, 17},i) then
					local flt = getXMLString(VehicleSort.saveFile, VehicleSort.keyCon .. '.' .. VehicleSort.config[i][1]);
					if tonumber(flt) == nil or tonumber(flt) <= 0 or tonumber(flt) > 1 then
						flt = VehicleSort.config[i][2];
						print("VeEx Config: Invalid saved value for " .. VehicleSort.config[i][1] .. ". Set default value: " .. tostring(VehicleSort.config[i][2]));
					else
						flt = tonumber(string.format('%.1f', tonumber(flt)));
					end
					VehicleSort.config[i][2] = flt;
					VehicleSort:dp(string.format('%s value set to [%f]',tostring(VehicleSort.config[i][1]), flt), 'VehicleSort:loadConfig');
				elseif i == 20 then
					local int = getXMLString(VehicleSort.saveFile, VehicleSort.keyCon .. '.' .. VehicleSort.config[i][1]);
					if tonumber(int) == nil or tonumber(int) <= 0 or tonumber(int) > 3 then
						int = VehicleSort.listAlignment;
						print("VeEx Config: Invalid saved value for " .. VehicleSort.config[i][1] .. ". Set default value: " .. tostring(VehicleSort.config[i][2]));
					else
						int = math.floor(tonumber(int));
					end
					VehicleSort.config[i][2] = int;
					VehicleSort:dp(string.format('listAlignment value set to [%d]', int), 'VehicleSort:loadConfig');
				else
					local b = getXMLBool(VehicleSort.saveFile, VehicleSort.keyCon .. '.' .. VehicleSort.config[i][1]);
					if b ~= nil then
						VehicleSort.config[i][2] = b;
					end
				end
			end
			print("VeExConfig loaded");
		end
	end
end

function VehicleSort:moveDown(moveSpeed)
	if moveSpeed == nil then
		moveSpeed = 1;
	end
	local oldIndex = VehicleSort.selectedIndex;
	VehicleSort.selectedIndex = VehicleSort.selectedIndex + moveSpeed;
	if VehicleSort.selectedIndex > #VehicleSort.Sorted then
		VehicleSort.selectedIndex = 1;
	end
	if VehicleSort:isHidden(VehicleSort.Sorted[VehicleSort.selectedIndex]) then
		VehicleSort:moveDown();
	end
	if VehicleSort.selectedLock then
		VehicleSort:reSort(oldIndex, VehicleSort.selectedIndex);
	end
end

function VehicleSort:moveUp(moveSpeed)
	if moveSpeed == nil then
		moveSpeed = 1;
	end
	local oldIndex = VehicleSort.selectedIndex;
	VehicleSort.selectedIndex = VehicleSort.selectedIndex - moveSpeed;
	if VehicleSort.selectedIndex < 1 then
		VehicleSort.selectedIndex = #VehicleSort.Sorted;
	end
	if VehicleSort:isHidden(VehicleSort.Sorted[VehicleSort.selectedIndex]) then
		VehicleSort:moveUp();
	end
	if VehicleSort.selectedLock then
		VehicleSort:reSort(oldIndex, VehicleSort.selectedIndex);
	end
end

function VehicleSort:moveConfigDown()
	VehicleSort.selectedConfigIndex = VehicleSort.selectedConfigIndex + 1;
	if VehicleSort.selectedConfigIndex > #VehicleSort.config then
		VehicleSort.selectedConfigIndex = 1;
	end
	VehicleSort.selectedRealConfigIndex = VehicleSort.orderedConfig[VehicleSort.selectedConfigIndex][1];
end

function VehicleSort:moveConfigUp()
	VehicleSort.selectedConfigIndex = VehicleSort.selectedConfigIndex - 1;
	if VehicleSort.selectedConfigIndex <= 0 then
		VehicleSort.selectedConfigIndex = #VehicleSort.config;
	end
	VehicleSort.selectedRealConfigIndex = VehicleSort.orderedConfig[VehicleSort.selectedConfigIndex][1];
end

function VehicleSort:renderBg(x, y, w, h)
  setOverlayColor(VehicleSort.bg, 0, 0, 0, VehicleSort.config[10][2]);
  renderOverlay(VehicleSort.bg, x - w / 2, y, w, h);
end

function VehicleSort:reSort(old, new)
	VehicleSort:dp(string.format('reSort old {%d} - new {%d}', old, new), 'reSort()');
	local u = VehicleSort.Sorted[old];
	table.remove(VehicleSort.Sorted, old);
	table.insert(VehicleSort.Sorted, new, u);
	VehicleSort.Sorted = VehicleSort:reshuffleVehicles(VehicleSort.Sorted);
end

--function VehicleSort:SyncSorted()
--	for k, v in ipairs(VehicleSort.Sorted) do
--		if g_currentMission.vehicles[v] ~= nil then
--			if g_currentMission.vehicles[v]['spec_vehicleSort'] ~= nil then
--				g_currentMission.vehicles[v]['spec_vehicleSort']['id'] = g_currentMission.vehicles[v]['id'];
--				g_currentMission.vehicles[v]['spec_vehicleSort']['orderId'] = k;
--				g_currentMission.vehicles[v]['spec_vehicleSort']['realId'] = v;
--			end
--		else
--			-- When there is o vehicle, we can actually drop that entry
--			-- ToDo: that would screw up our list ordering. And it shouldn't happen anyways
--			--table.remove(VehicleSort.Sorted, k);
--		end
--	end
--	
--	-- After selling or resetting vehicles our selectedIndex could point to an non existing vehicle, so better to reset it then
--	if g_currentMission.vehicles[VehicleSort.selectedIndex] == nil then
--		VehicleSort.selectedIndex = 1;
--	end
--end
--
--function VehicleSort:SyncSortedWithGame()
--	local allVeh = {}	
--	local newOrder = {};
--	local newSorted = {};
--
--	for _, v in ipairs(g_currentMission.vehicles) do
--		table.insert(allVeh, v);
--	end
--	
--	for k, v in ipairs(VehicleSort.Sorted) do
--		VehicleSort:dp(string.format('Sorted Index {%d}, realId {%d}, Vehicle {%s}', k, v, g_currentMission.vehicles[v]['configFileName']), 'SyncSortedWithGame');
--		
--		local newVeh = g_currentMission.vehicles[v];
--		newVeh.spec_vehicleSort.orderId = k;
--		newVeh.spec_vehicleSort.realId = k;
--		table.insert(newOrder, newVeh);
--		table.insert(newSorted, k);
--	end
--	-- Add the unsorted vehicles like trailers, implements etc.
--	for k, _ in pairs(allVeh) do
--		if allVeh[k]['spec_vehicleSort'] == nil then
--			table.insert(newOrder, allVeh[k]);
--		end
--	end
--
--	VehicleSort:dp(string.format('#newOrder {%d} - #g_currentMission.vehicles {%d}', #newOrder, #g_currentMission.vehicles), 'SyncSortedWithGame');
--	if #newOrder == #g_currentMission.vehicles then
--		VehicleSort.Sorted = newSorted;
--		g_currentMission.vehicles = newOrder;
--		-- Update tab order
--		--g_inputBinding.events['SWITCH_VEHICLE'].targetObject.loadVehiclesById = newOrder;
--		--g_inputBinding.events['SWITCH_VEHICLE_BACK'].targetObject.loadVehiclesById = newOrder;
--		
--		VehicleSort:dp('Write back of orderd vehicles to g_currentMission.vehicles');
--	end
--end

function VehicleSort:toggleParkState(selectedIndex)
	local realId = VehicleSort.Sorted[selectedIndex];
	local parked = not g_currentMission.vehicles[realId]:getIsTabbable();
	if parked then
		g_currentMission.vehicles[realId]:setIsTabbable(true);
	else
		g_currentMission.vehicles[realId]:setIsTabbable(false);
	end
	VehicleSort:dp(string.format('realId {%d} - parked {%s}', realId, tostring(parked)), 'VehicleSort:toggleParkState');
end

function VehicleSort:saveConfig()
	VehicleSort.saveFile = createXMLFile('VehicleSort.saveFile', VehicleSort.xmlFilename, VehicleSort.keyCon);
	for i = 1, #VehicleSort.config do
		if VehicleSort:contains({9, 20, 24, 25, 26}, i) then		-- int values
			setXMLString(VehicleSort.saveFile, VehicleSort.keyCon .. '.' .. tostring(VehicleSort.config[i][1]), tostring(VehicleSort.config[i][2]));
		elseif VehicleSort:contains({10, 17}, i) then				-- floats
			setXMLString(VehicleSort.saveFile, VehicleSort.keyCon .. '.' .. tostring(VehicleSort.config[i][1]), string.format('%.1f', VehicleSort.config[i][2]));
		else
			setXMLBool(VehicleSort.saveFile, VehicleSort.keyCon .. '.' .. tostring(VehicleSort.config[i][1]), VehicleSort.config[i][2]);
		end
	end
	saveXMLFile(VehicleSort.saveFile);

  print("VehicleSort config saved");
end

function VehicleSort:drawStoreImage(realId)
	if g_currentMission.vehicles[realId] ~= nil and not VehicleSort:isTrain(realId) then
		local imgFileName = VehicleSort:getStoreImageByConf(g_currentMission.vehicles[realId]['configFileName']);
		--VehicleSort:dp(string.format('configFileName {%s}', configFileName));
		--VehicleSort:dp(storeItem, 'drawStoreImage');
		if string.len(imgFileName) > 0 then
			local storeImage = createImageOverlay(imgFileName);
			if storeImage > 0 then
				local storeImgX, storeImgY = getNormalizedScreenValues(128, 128)
				local imgX = 0.5 - VehicleSort.bgW / 2 - storeImgX;
				local imgY = VehicleSort.config[17][2] - storeImgY;
				
				-- Background rendering for the images, based on the saved configvalue
				if VehicleSort.config[19][2] then
					local bgW = storeImgX;
					local bgH = storeImgY;
					local bgX = imgX + (bgW / 2);
					local bgY = imgY;
					VehicleSort:renderBg(bgX, bgY, bgW, bgH);
				end
				-- Must be rendered after the background, otherwise it's covered by it
				renderOverlay(storeImage, imgX, imgY, storeImgX, storeImgY)
				
				if (VehicleSort:getVehImplements(realId) ~= nil) and (imgFileName ~= "data/store/store_empty.png") then
					local impList = VehicleSort:getVehImplements(realId);
					for i = 1, VehicleSort.config[24][2] do			-- Limit to the configured amount of implements to show
						local imp = impList[i];
						if imp ~= nil and imp.object ~= nil then
							local imgFileName = VehicleSort:getStoreImageByConf(imp.object.configFileName);
							local storeImage = createImageOverlay(imgFileName);
							if storeImage > 0 then
								local imgY = VehicleSort.config[17][2] - (storeImgY * (i + 1) );
										
								-- Background rendering for the images, based on the saved configvalue
								if VehicleSort.config[19][2] then
									local bgW = storeImgX;
									local bgH = storeImgY;
									local bgX = imgX + (bgW / 2);
									local bgY = imgY;
									VehicleSort:renderBg(bgX, bgY, bgW, bgH);
								end
								-- Must be rendered after the background, otherwise it's covered by it
								renderOverlay(storeImage, imgX, imgY, storeImgX, storeImgY)
							end
						end
					end
				end
			end
		end
	end
end

function VehicleSort:getStoreImageByConf(confFile)
	local storeItem = g_storeManager.xmlFilenameToItem[string.lower(confFile)];
	if storeItem ~= nil then
		local imgFileName = storeItem.imageFilename;
		--if imgFileName == 'data/vehicles/train/locomotive01/store_locomotive01.png' or imgFileName == 'data/vehicles/train/locomotive04/store_locomotive04.png' then
		if string.find(imgFileName, 'locomotive') then
			--imgFileName = Utils.getFilename('img/train.png', VehicleSort.ModDirectory);
			imgFileName = "data/store/store_empty.png";
		end
		return imgFileName;
	end
end

function VehicleSort:drawInfobox(realId)
	if realId ~= nil then
	
		local textTable = VehicleSort:getInfoTexts(realId);
	
		setTextAlignment(VehicleSort.tPos.alignmentR);
		setTextColor(unpack(VehicleSort.tColor.standard));
		local txtSize = VehicleSort.tPos.sizeSmall;
		local imgWidth, _ = getNormalizedScreenValues(128,128);
		if not VehicleSort.config[15][2] then				-- If there is no picture we can move more right
			imgWidth = 0.01;
		end

		local infoX = 0.5 - VehicleSort.bgW / 2 - imgWidth - VehicleSort.tPos.padSides;
		local infoY = VehicleSort.config[17][2];
		local txtY = infoY - VehicleSort.tPos.padHeight - txtSize - VehicleSort.tPos.spacing;
		local txtWidth = getTextWidth(txtSize, "Info");
		
		local texts = {};
		for _, t in ipairs(textTable) do
			local tWidth = getTextWidth(txtSize, t);
			renderText(infoX, txtY, txtSize, tostring(t));
			txtY = txtY - txtSize - VehicleSort.tPos.spacing;
			txtWidth = math.max(txtWidth, tWidth);
		end
		
		setTextAlignment(VehicleSort.tPos.alignmentL);		
		
		-- Background rendering for the infobox, based on the saved configvalue
		if VehicleSort.config[18][2] then
			local bgW = txtWidth + (VehicleSort.tPos.padSides * 2);
			-- We have to compensate for the last txtY change in the loop
			local bgH = (txtSize * (#textTable + 1)) + (VehicleSort.tPos.spacing * (#textTable + 1)) + (VehicleSort.tPos.padHeight * 1);
			local bgX = infoX - (bgW / 2) + VehicleSort.tPos.padSides;
			local bgY = txtY;
			VehicleSort:renderBg(bgX, bgY, bgW, bgH);
		end
	end
end

function VehicleSort:getInfoTexts(realId)
	local veh = g_currentMission.vehicles[realId];
	
	if veh ~= nil then
		local texts = {};
		local line = "";
		
		local doSpacing = false;
		
		-- This part doesn't work at the moment, but also doesn't make sense as long as we've no tasks
		
		-- spec_cpCourseManager.courses.1.name
		--cpAIFieldWorker
		if VehicleSort:getIsCourseplay(veh) then
			local courseName = "";
			if veh:getCurrentCpCourseName() ~= nil then
				courseName = veh:getCurrentCpCourseName()
			elseif veh.cp.mapHotspot ~= nil and veh.cp.mapHotspot.fullViewName ~= nil then
				local str = tostring(veh.cp.mapHotspot.fullViewName);
				local t = {}
				for s in str:gmatch("[^\r\n]+") do
					table.insert(t, s)
				end
				if string.len(tostring(t[3])) > 1 then
					courseName = tostring(t[3]);
				end
			else
				courseName = g_i18n.modEnvironments[VehicleSort.ModName].texts.cp_courseunknown
			end
			line = g_i18n.modEnvironments[VehicleSort.ModName].texts.cp_course .. ": " .. courseName;
			table.insert(texts, line);
			doSpacing = true;
		end
		
		if (veh.ad ~= nil and veh.ad.stateModule ~= nil and veh.ad.stateModule.active) then
			if veh.ad.stateModule.firstMarker ~= nil and veh.ad.stateModule.mode ~= 1 then
				local target1 = "";
				local target2 = "";
				if veh.ad.stateModule.currentDestination ~= ni and (veh.ad.stateModule.currentDestination.id == veh.ad.stateModule.firstMarker.id) then
					target1 = " <<";
				else
					target2 = " <<";
				end
				
				line = g_i18n.modEnvironments[VehicleSort.ModName].texts.ad_load .. ": " .. veh.ad.stateModule.firstMarker.name .. target1;
				table.insert(texts, line);
				line = g_i18n.modEnvironments[VehicleSort.ModName].texts.ad_unload .. ": " .. veh.ad.stateModule.secondMarker.name .. target2;
				table.insert(texts, line);
			elseif veh.ad.stateModule.currentDestination ~= nil then
				line = g_i18n.modEnvironments[VehicleSort.ModName].texts.ad_destination .. ": " .. veh.ad.stateModule.currentDestination.name
				table.insert(texts, line);			
			end
			doSpacing = true;
		end
		
		if veh.getIsOnField and veh:getIsOnField() then
			local fieldId = VehicleStatus:getFieldNumber(realId)
			if fieldId ~= nil and fieldId ~= false then
				line = g_i18n.modEnvironments[VehicleSort.ModName].texts.field .. ": " .. tostring(fieldId);
				table.insert(texts, line);
				doSpacing = true;
			end
		end
		
		if VehicleSort:isHired(realId) then
			if veh.getCurrentHelper ~= nil and veh:getCurrentHelper() ~= nil then
				--TODO: g_i18n:getText("ui_helper")
				line = g_i18n.modEnvironments[VehicleSort.ModName].texts.helper .. ": " .. veh:getCurrentHelper().name;
			else
				line = g_i18n.modEnvironments[VehicleSort.ModName].texts.helper .. ": Unknown Helper";
			end
			table.insert(texts, line);
			if not doSpacing then
				doSpacing = true;
			end
		end		

		-- Some spacing, but just if we actually had some data so far
		if doSpacing then
			table.insert(texts, " ");
			doSpacing = false;
		end
		
		-- Operating time; Kudos to Watsi for the idea
		if veh.getOperatingTime then
			line = g_i18n.modEnvironments[VehicleSort.ModName].texts.operationHours .. ": " .. VehicleStatus:getOperatingHours(veh);
			table.insert(texts, line);
			
			if VehicleSort:getVehImplements(realId) ~= nil then
				local impHours = VehicleStatus:getVehImplementsOperatingHours(realId);
				if #impHours > 0 then
					for i=1, VehicleSort.config[25][2] do
						table.insert(texts, impHours[i]);
					end
				end
				doSpacing = true;
			end
			doSpacing = true;
		end

		-- Some spacing, but just if we actually had some data so far
		if doSpacing then
			table.insert(texts, " ");
			doSpacing = false;
		end
		
		-- Get vehicle wear and damage
		if veh.getWearTotalAmount ~= nil then
			line = g_i18n.modEnvironments[VehicleSort.ModName].texts.wear .. ": " .. VehicleSort:calcPercentage(veh:getWearTotalAmount(), 1) .. " %";
			table.insert(texts, line);

			if VehicleSort:getVehImplements(realId) ~= nil then
				local impWear = VehicleStatus:getVehImplementsWear(realId);
				if #impWear > 0 then
					for i=1, VehicleSort.config[25][2] do
						table.insert(texts, impWear[i]);
					end
				end
				doSpacing = true;
			end
			doSpacing = true;
		end
		
		-- Get vehicle damage
		if veh.getDamageAmount then
			line = g_i18n.modEnvironments[VehicleSort.ModName].texts.damage .. ": " .. VehicleSort:calcPercentage(veh:getDamageAmount(), 1) .. " %";
			table.insert(texts, line);

			if VehicleSort:getVehImplements(realId) ~= nil then
				local impDamage = VehicleStatus:getVehImplementsDamage(realId);
				if #impDamage > 0 then
					for i=1, VehicleSort.config[25][2] do
						table.insert(texts, impDamage[i]);
					end
				end
				doSpacing = true;
			end
			doSpacing = true;
		end
		
		-- Some spacing, but just if we actually had some data so far
		if doSpacing then
			table.insert(texts, " ");
			doSpacing = false;
		end
		
		-- Get vehicle Dirt
		local dirtPerc = VehicleStatus:getDirtPercForObject(g_currentMission.vehicles[realId]);
		if dirtPerc ~= nil then
			line = g_i18n.texts.setting_dirt .. ": " .. dirtPerc .. " %";
			table.insert(texts, line);		
			doSpacing = true;			
		end
		
		if VehicleSort:getVehImplements(realId) ~= nil then		
			local impDirt = VehicleStatus:getVehImplementsDirt(realId);
			if #impDirt > 0 then
				for i=1, VehicleSort.config[25][2] do
					table.insert(texts, impDirt[i]);
				end
			end
			doSpacing = true;
		end		
		
		-- Some spacing, but just if we actually had some data so far
		if doSpacing then
			table.insert(texts, " ");
			doSpacing = false;
		end

		-- Get vehicle filllevel
		if string.len(VehicleSort:getFillDisplay(veh, true)) > 1 then
			line = g_i18n.modEnvironments[VehicleSort.ModName].texts.fillLevel .. ": " .. VehicleSort:getFillDisplay(veh, true);
			table.insert(texts, line);
			doSpacing = true;
		end
		
		if VehicleSort:getVehImplements(realId) ~= nil then
			local impFill = VehicleSort:getVehImplementsFillInfobox(realId);
			if #impFill > 0 then
				for i=1, VehicleSort.config[25][2] do
					table.insert(texts, impFill[i]);
				end
				if not doSpacing then
					doSpacing = true;
				end
			end
		end

		-- Some spacing, but just if we actually had some data so far
		if doSpacing then
			table.insert(texts, " ");
			doSpacing = false;
		end
		
		if (not VehicleSort:isTrain(realId)) or (not VehicleSort:isCrane(realId)) then
			-- Diesel & DEF FillLevel
			-- FS22 local level, capacity = VehicleStatus:getDieselLevel(realId)
			if level ~= nil and capacity ~= nil then
				line = g_i18n.texts.fillType_diesel .. ": " .. level .. "/" .. capacity .. " " .. g_i18n.texts.unit_liter;
				table.insert(texts, line);
			end
			
			--FS22 local level, capacity = VehicleStatus:getDefLevel(realId)
			if level ~= nil and capacity ~= nil then
				line = g_i18n.texts.fillType_def_short .. ": " .. level .. "/" .. capacity .. " " .. g_i18n.texts.unit_liter;
				table.insert(texts, line);
			end
		end
		
		-- Speed
		line = g_i18n.modEnvironments[VehicleSort.ModName].texts.speed .. ": " .. VehicleStatus:getSpeedStr(veh);
		table.insert(texts, line);
		
		-- Some spacing
		table.insert(texts, " ");
		
		-- Motor on/TurnedOn, Lights
		if VehicleStatus:getIsMotorStarted(veh) then
			line = g_i18n.modEnvironments[VehicleSort.ModName].texts.motor .. ": " .. g_i18n.texts.ui_on;
		else
			line = g_i18n.modEnvironments[VehicleSort.ModName].texts.motor .. ": " .. g_i18n.texts.ui_off;
		end
		if not doSpacing then
			doSpacing = true;
		end		
		table.insert(texts, line);
		
		if VehicleStatus:getIsTurnedOn(veh) then
			line = g_i18n.modEnvironments[VehicleSort.ModName].texts.turnedOn .. ": " .. g_i18n.texts.ui_on;
		else
			line = g_i18n.modEnvironments[VehicleSort.ModName].texts.turnedOn .. ": " .. g_i18n.texts.ui_off;
		end
		if not doSpacing then
			doSpacing = true;
		end				
		table.insert(texts, line);		
		
		if VehicleStatus:getIsLightTurnedOn(veh) then
			line = g_i18n.modEnvironments[VehicleSort.ModName].texts.lights .. ": " .. g_i18n.texts.ui_on;
		else
			line = g_i18n.modEnvironments[VehicleSort.ModName].texts.lights .. ": " .. g_i18n.texts.ui_off;
		end
		if not doSpacing then
			doSpacing = true;
		end				
		table.insert(texts, line);
		
		-- Implement status, lowered and turnedOn
		if VehicleSort:getVehImplements(realId) ~= nil then
			local impStatus = VehicleStatus:getImplementStatus(realId);
			
			if impStatus ~= nil and #impStatus > 0 then		-- We've to check for nil again, as we filter out frontloaders
				-- Some spacing, but just if we actually had some data so far
				-- This spacing is actually meant after the light state. But we just want it if there are implements, otherwise we've too much spacing at the end of the infobox
				if doSpacing then
					table.insert(texts, " ");
					doSpacing = false;
				end
			
				for _, v in ipairs(impStatus) do
					if v.isLowered ~= nil or v.isTurnedOn ~= nil then
						local yesno = '';
						if v.isLowered ~= nil then
							if v.isLowered then yesno = g_i18n.texts.ui_yes; else yesno = g_i18n.texts.ui_no; end
							table.insert(texts, string.format('%s | %s: %s', v.name, g_i18n.modEnvironments[VehicleSort.ModName].texts.isLowered, yesno));
						end
						if v.isTurnedOn ~= nil then
							if v.isTurnedOn then yesno = g_i18n.texts.ui_yes; else yesno = g_i18n.texts.ui_no; end
							table.insert(texts, string.format('%s | %s: %s', v.name, g_i18n.modEnvironments[VehicleSort.ModName].texts.turnedOnImplement, yesno));
						end
					end
				end
			end
		end

		return texts;
	end
end

function VehicleSort:getVehImplementsFillInfobox(realId)
	local texts = {};
	local line = "";

	local implements = VehicleSort:getVehImplements(realId);
	if implements ~= nil then
		for i = 1, #implements do
			local imp = implements[i];
			
			if imp ~= nil and imp.object ~= nil and (string.len(VehicleSort:getFillDisplay(imp.object)) > 1) then
				line = string.gsub(VehicleSort:getAttachmentName(imp.object), "%s$", "") .. " | " .. g_i18n.modEnvironments[VehicleSort.ModName].texts.fillLevel .. ": " .. VehicleSort:getFillDisplay(imp.object, true);
				table.insert(texts, line);
			end
		end
	end

	return texts;
end

function VehicleSort:isActionAllowed()
	-- We don't want to accidently switch vehicle when the vehicle list is opened and we change to a menu
	if string.len(g_gui.currentGuiName) > 0 or #g_gui.dialogs > 0 then
		return false;
	elseif VehicleSort.showConfig or VehicleSort.showVehicles then
		return true;
	end
end

function VehicleSort:showNoVehicles()
	g_currentMission:showBlinkingWarning(g_i18n.modEnvironments[VehicleSort.ModName].texts.warningNoVehicles, 8000);
end

function VehicleSort:contains(haystack, needle)
	for _, value in pairs(haystack) do
		if value == needle then
			return true;
		end
	end
	return false;
end

function VehicleSort:tabVehicle(backwards)
	-- TBD Not sure yet if it's a good idea to get a ordered List for every tab. Will see if this has any negative
	-- performance impact. If so, I'll just drop it again and define it as 'by design'. Opening/closing the vehList shouldn't be a big deal
	-- especially as it's just an issue when new vehicles get bought/sold
	--if #VehicleSort.Sorted == 0 then
	if #VehicleSort.Sorted == 0 or #VehicleSort.Sorted ~= #VehicleSort:getOrderedVehicles() then
		VehicleSort.Sorted = VehicleSort:getOrderedVehicles();
	end
	
	-- Show the warning in case we've still no vehicles
	if #VehicleSort.Sorted == 0 then
		VehicleSort:showNoVehicles();
	end
	
	if g_currentMission.controlledVehicle == nil then
		conId = nil;
		nextId = 1;
	else
		conId = g_currentMission.controlledVehicle.spec_vehicleSort.orderId

		VehicleSort:getNextInTabList(conId, backwards);
	end
	
	VehicleSort:dp(string.format('conId {%s} - nextId {%d}', tostring(conId), nextId), 'tabVehicle');

	-- We need the loop to check which vehicle we can actually enter
	local run = 1;
	if g_currentMission.vehicles[(VehicleSort.Sorted[nextId])] ~= nil and g_currentMission.vehicles[(VehicleSort.Sorted[nextId])].getIsControlled then
		while g_currentMission.vehicles[(VehicleSort.Sorted[nextId])]:getIsControlled() or VehicleSort:isParked(VehicleSort.Sorted[nextId]) do

			VehicleSort:getNextInTabList(nextId, backwards)

			if run == #VehicleSort.Sorted then
				VehicleSort.showNoVehicles();
				return false;
			end
			run = run + 1;
		end
	end
	realVeh = g_currentMission.vehicles[VehicleSort.Sorted[nextId]];
	g_currentMission:requestToEnterVehicle(realVeh);
	
end

function VehicleSort:getNextInTabList(orderId, backwards)
	if backwards then
		if orderId == 1 then
			nextId = #VehicleSort.Sorted;
		else
			nextId = orderId - 1;
		end			
	else
		if orderId == #VehicleSort.Sorted then
			nextId = 1;
		else
			nextId = orderId + 1;
		end
	end
	return nextId;
end

function VehicleSort:easyTab(realVeh)
	-- We use this method for the action as well as set the table. So if a parameter gets passed, we've to do the logic to set the easyTab table
	if realVeh ~= nil then
		VehicleSort:dp('realVeh is not null, so altering our easyTabTable', 'easyTab');
		table.insert(VehicleSort.easyTabTable, 1, realVeh);
		table.remove(VehicleSort.easyTabTable, 3);
	else
		VehicleSort:dp('realVeh is not present, so we are going to tab', 'easyTab');
		if #VehicleSort.easyTabTable == 1 then
			g_currentMission:requestToEnterVehicle(VehicleSort.easyTabTable[1]);
		elseif #VehicleSort.easyTabTable > 1 then
			g_currentMission:requestToEnterVehicle(VehicleSort.easyTabTable[2]);
			--Shift table again to have the proper order the next time
			table.insert(VehicleSort.easyTabTable, 1, VehicleSort.easyTabTable[2]);
			table.remove(VehicleSort.easyTabTable, 3);
		end
	end
end

function VehicleSort:handlePostloadTrains(realId)
	local id = g_currentMission.vehicles[realId]['id'];
	
	if VehicleSort.loadTrainStatus[id] ~= nil then
		if VehicleSort.loadTrainStatus[id]['motorTurnedOn'] then
			g_currentMission.vehicles[realId]:startMotor();
		else
			g_currentMission.vehicles[realId]:setLocomotiveState(Locomotive.STATE_MANUAL_TRAVEL_ACTIVE);
			g_currentMission.vehicles[realId]:stopMotor();
		end

		g_currentMission.vehicles[realId]:setIsTabbable(not VehicleSort.loadTrainStatus[id]['isParked']);
		
		VehicleSort:dp(string.format('Train realId {%d} should be fine now. isParked {%s}, motorTurnedOn {%s}', realId, 
							tostring(VehicleSort.loadTrainStatus[id]['isParked']), tostring(VehicleSort.loadTrainStatus[id]['motorTurnedOn'])));		

							VehicleSort.loadTrainStatus[id] = nil;
		VehicleSort.loadTrainStatus.entries = VehicleSort.loadTrainStatus.entries - 1;
	end

end

function VehicleSort:placeableSaveToXMLFile(xmlFile, key, usedModNames)
	VehicleSort:dp(string.format('key {%s}', key), 'placeableSaveToXMLFile');
	
	if xmlFile ~= nil and key ~= nil and self.vehicle.spec_vehicleSort ~= nil then
		local key = key..".vehicleSort";
		if self.vehicle.spec_vehicleSort.orderId ~= nil then
			setXMLInt(xmlFile, key.."#UserOrder", self.vehicle.spec_vehicleSort.orderId);
		end
		
		if VehicleSort:isParked(self.vehicle.spec_vehicleSort.realId) then
			setXMLBool(xmlFile, key.."#isParked", true);
		end
	end
end

function VehicleSort:placeableLoadFromXMLFile(superFunc, xmlFile, key, resetVehicles)

	if xmlFile == nil and key == nil then
		return false;		
	end

	local mainLoad = superFunc(self, xmlFile, key, resetVehicles);
	
	if mainLoad then
		VehicleSort:dp(string.format('key {%s}', key), 'placeableLoadFromXMLFile');		
		
		local key = key..".vehicleSort";
		
		if hasXMLProperty(xmlFile, key) then
			local orderId = getXMLInt(xmlFile, key.."#UserOrder");
			if orderId ~= nil then
				VehicleSort:dp(string.format('Loaded orderId {%d} for placeableId {%d}', orderId, self.id), 'placeableLoadFromXMLFile');
			end
			
			if self.vehicle.spec_vehicleSort ~= nil then
				self.vehicle.spec_vehicleSort.id = self.id;
				if orderId ~= nil then
					self.vehicle.spec_vehicleSort.orderId = orderId;
				end
			end
			
			local isParked = Utils.getNoNil(getXMLBool(xmlFile, key.."#isParked"), false);
			if isParked then
				VehicleSort:dp(string.format('Set isParked {%s} for orderId {%d} / vehicleId {%d}', tostring(isParked), orderId, self.id), 'onPostLoad');
				self.vehicle:setIsTabbable(false);
			else
				self.vehicle:setIsTabbable(true);
			end
		end
	end

	return mainLoad;
end

function VehicleSort:isActionAllowed()
	-- We don't want to accidently switch vehicle when the vehicle list is opened and we change to a menu
	if string.len(g_gui.currentGuiName) > 0 or #g_gui.dialogs > 0 then
		return false;
	elseif VehicleSort.showConfig or VehicleSort.showVehicles then
		return true;
	end
end

function VehicleSort:overwriteDefaultTabBinding()
	local state = false;
	if not (string.len(g_gui.currentGuiName) > 0) then
		if g_inputBinding.nameActions.SWITCH_VEHICLE.bindings[1] ~= nil and g_inputBinding.nameActions.SWITCH_VEHICLE.bindings[1].isActive ~= state then
			--VehicleSort:dp(string.format("SWITCH_VEHICLE does not equal state. state = {%s} Going to change it.", tostring(state)), "setTabBinding")
			local eventsTab = InputBinding.getEventsForActionName(g_inputBinding, "SWITCH_VEHICLE")
			if eventsTab[1] ~= nil then
				g_inputBinding:setActionEventActive(eventsTab[1].id, state)
			end
		end
		
		if g_inputBinding.nameActions.SWITCH_VEHICLE_BACK.bindings[1] ~= nil and g_inputBinding.nameActions.SWITCH_VEHICLE_BACK.bindings[1].isActive ~= state then
			--VehicleSort:dp(string.format("SWITCH_VEHICLE_BACK does not equal state. state = {%s} Going to change it.", tostring(state)), "setTabBinding")
			local eventsShiftTab = InputBinding.getEventsForActionName(g_inputBinding, "SWITCH_VEHICLE_BACK")
			if eventsShiftTab[1] ~= nil then
				g_inputBinding:setActionEventActive(eventsShiftTab[1].id, state)
			end
		end
	end
end

function VehicleSort:setHelpVisibility(eventTable, state)
	if #eventTable > 0 then
		for _, eventName in pairs(eventTable) do
			if g_inputBinding.events[eventName] ~= nil and g_inputBinding.events[eventName].id ~= nil then
				g_inputBinding:setActionEventTextVisibility(g_inputBinding.events[eventName].id, state)
			end
		end
	end
end

function VehicleSort:showCenteredBlinkingWarning(text, blinkDuration)
	local centeredText = "";

	if type(text) == 'table' then
		VehicleSort:dp(string.format('We got a table to handle'), 'showCenteredBlinkingWarning');
		local textWidth = 0;
		
		--First we get the longest text as baseline
		for i=1, #text do
			local length = string.len(text[i])
			if length > textWidth then
				textWidth = length
			end
		end
		
		VehicleSort:dp(string.format('Max textWidth: {%d}', textWidth), 'showCenteredBlinkingWarning');
		
		for i=1, #text do
			VehicleSort:dp(string.format('Line: {%s}', text[i]), 'showCenteredBlinkingWarning');
			if string.len(text[i]) < textWidth then
				local spaceCount = 0;
				local spaces = "";
				spaceCount = math.floor((textWidth - string.len(text[i])) / 2)
				VehicleSort:dp(string.format('Line: {%s}; SpaceCount: {%d}', text[i], spaceCount), 'showCenteredBlinkingWarning');

				for j=0, spaceCount do
					spaces = string.format('%s%s', spaces, " ");
				end

				centeredText = string.format('%s%s%s\n', centeredText, spaces, text[i]);
				VehicleSort:dp(string.format('CenteredText: {%s} after adding line {%s}',centeredText, text[i]));
			elseif string.len(text[i]) == textWidth then
				centeredText = string.format('%s%s\n', centeredText, text[i]);
				VehicleSort:dp(string.format('Line length: {%s} equals textWidth {%d}', text[i], textWidth), 'showCenteredBlinkingWarning');
			end
		end
	else
		centeredText = text;
	end

	VehicleSort:dp(string.format('CenteredText: {%s}', centeredText), 'showCenteredBlinkingWarning');
	g_currentMission:showBlinkingWarning(centeredText, blinkDuration);
end

function VehicleSort:getIsCourseplay(veh)
	if veh.getCpStatus ~= nil then
		local cpStatus = veh:getCpStatus()
		return cpStatus:getIsActive()
	else
		return false
	end
end

--
-- Extends default game functions
-- This is required to block the camera zoom & handtool selection while drawlist or drawconfig is open
--
function VehicleSort.onInputCycleHandTool(self, superFunc, _, _, direction)
	if not VehicleSort.showVehicles and not VehicleSort.showConfig then
		superFunc(self, _, _, direction);
	end
end

function VehicleSort.zoomSmoothly(self, superFunc, offset)
	if not VehicleSort.showConfig and not VehicleSort.showVehicles then -- don't zoom camera when mouse wheel is used to scroll displayed list
		superFunc(self, offset);
	end
end

-- I think it's convinient to have the moveup/down fast keys on KEY_1 and KEY_2, but that conflicts with the cruisecontrol
function VehicleSort.setCruiseControlMaxSpeed(self, superFunc, speed)
	if not VehicleSort.showConfig and not VehicleSort.showVehicles then
		superFunc(self, speed);
	end
end

if g_dedicatedServerInfo == nil then
  VehicleCamera.zoomSmoothly = Utils.overwrittenFunction(VehicleCamera.zoomSmoothly, VehicleSort.zoomSmoothly);
  Player.onInputCycleHandTool = Utils.overwrittenFunction(Player.onInputCycleHandTool, VehicleSort.onInputCycleHandTool);
  Drivable.setCruiseControlMaxSpeed = Utils.overwrittenFunction(Drivable.setCruiseControlMaxSpeed, VehicleSort.setCruiseControlMaxSpeed);
end

-- As there are also placeables which get treated as vehicles (e.g. cranes) we've to add ourself to those elements too
-- Load must be overwritten. With a simpel appendedFunction we get errors in the log, as the main load method already returns true, before our
-- additional load is finished
--VehiclePlaceable.saveToXMLFile = Utils.appendedFunction(VehiclePlaceable.saveToXMLFile, VehicleSort.placeableSaveToXMLFile);
--VehiclePlaceable.loadFromXMLFile = Utils.overwrittenFunction(VehiclePlaceable.loadFromXMLFile, VehicleSort.placeableLoadFromXMLFile);