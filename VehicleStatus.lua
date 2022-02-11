-- VehicleStatus.lua for FS22
-- Author: sperrgebiet
-- Please see https://github.com/sperrgebiet/FS22_VehicleExplorer for additional information, credits, issues and everything else

VehicleStatus = {};

VehicleStatus.ModName = g_currentModName;
VehicleStatus.ModDirectory = g_currentModDirectory;
VehicleStatus.Version = "0.1.0.0";


VehicleStatus.debug = fileExists(VehicleStatus.ModDirectory ..'debug');

print(string.format('VehicleStatus v%s - DebugMode %s)', VehicleStatus.Version, tostring(VehicleStatus.debug)));

function VehicleStatus.prerequisitesPresent(specializations)
	return true;
end

function VehicleStatus.registerEventListeners(vehicleType)
	local functionNames = {	"onPreLoad", "onLoad", "onPostLoad", "saveToXMLFile" };
	
	for _, functionName in ipairs(functionNames) do
		SpecializationUtil.registerEventListener(vehicleType, functionName, VehicleStatus);
	end
end

---Called before loading
-- @param table savegame savegame
function VehicleStatus:onPreLoad(savegame)
	--FS22 No idea if that's the proper way, but it seems it works
	VehicleStatus.initSpecialization()
end

---Called on loading
-- @param table savegame savegame

function VehicleStatus:onLoad(savegame)
end

function VehicleStatus.initSpecialization()
	local schema = Vehicle.xmlSchemaSavegame
	schema:setXMLSpecializationType("vehicleStatus")

	schema:register(XMLValueType.BOOL, "vehicles.vehicle(?).vehicleStatus#isMotorStarted", "")
	schema:register(XMLValueType.BOOL, "vehicles.vehicle(?).vehicleStatus#isTurnedOn", "")
	schema:register(XMLValueType.INT, "vehicles.vehicle(?).vehicleStatus#lightsMask", "")
	schema:register(XMLValueType.BOOL, "vehicles.vehicle(?).vehicleStatus#beaconsOn", "")
	schema:register(XMLValueType.INT, "vehicles.vehicle(?).vehicleStatus#turnLightsState", "")
	schema:register(XMLValueType.BOOL, "vehicles.vehicle(?).vehicleStatus#brakeLightsOn", "")
	--schema:setXMLSpecializationType()
end

function VehicleStatus:onPostLoad(savegame)
	if VehicleSort.config[14][2] and savegame ~= nil then
		if self.spec_motorized ~= nil then
			local motorTurnedOn = Utils.getNoNil(savegame.xmlFile:getValue(savegame.key..".vehicleStatus#isMotorStarted"), false);
			VehicleSort:dp(string.format('motorTurnedOn: {%s} for {%s} | savegame.key: {%s}', tostring(motorTurnedOn), self.configFileName, savegame.key .. ".vehicleStatus#isMotorStarted"), 'VehicleStatus:onPostLoad');
			if motorTurnedOn then
				self:startMotor();
			end
		end
		
		if self.spec_turnOnVehicle ~= nil then
			local isTurnedOn = Utils.getNoNil(savegame.xmlFile:getValue(savegame.key..".vehicleStatus#isTurnedOn"), false);
			VehicleSort:dp(string.format('isTurnedOn: {%s} for {%s} | savegame.key: {%s}', tostring(isTurnedOn), self.configFileName, savegame.key .. ".vehicleStatus#isTurnedOn"), 'VehicleStatus:onPostLoad');
			if isTurnedOn then
				self:setIsTurnedOn(isTurnedOn);
			end
		end
		
		if self.spec_lights ~= nil and self.spec_enterable ~= nil then
			local lightsMask = Utils.getNoNil(savegame.xmlFile:getValue(savegame.key..".vehicleStatus#lightsMask"), 0);
			VehicleSort:dp(string.format('lightsMask: {%s} for {%s} | savegame.key: {%s}', tostring(lightsMask), self.configFileName, savegame.key .. ".vehicleStatus#lightsMask"), 'VehicleStatus:onPostLoad');
			if lightsMask > 0 then
				self:setLightsTypesMask(lightsMask, true);
			end

			local beaconsOn = Utils.getNoNil(savegame.xmlFile:getValue(savegame.key..".vehicleStatus#beaconsOn"), false);
			VehicleSort:dp(string.format('beaconsOn: {%s} for {%s} | savegame.key: {%s}', tostring(beaconsOn), self.configFileName, savegame.key .. ".vehicleStatus#beaconsOn"), 'VehicleStatus:onPostLoad');
			if beaconsOn then
				self:setBeaconLightsVisibility(beaconsOn, true);
			end

			local turnLightsState = Utils.getNoNil(savegame.xmlFile:getValue(savegame.key..".vehicleStatus#turnLightsState"), 0);
			VehicleSort:dp(string.format('turnLightsState: {%s} for {%s} | savegame.key: {%s}', tostring(turnLightsState), self.configFileName, savegame.key .. ".vehicleStatus#turnLightsState"), 'VehicleStatus:onPostLoad');
			if turnLightsState > 0 then
				self:setTurnLightState(turnLightsState, true);
			end
			
			local brakeLightsOn = Utils.getNoNil(savegame.xmlFile:getValue(savegame.key..".vehicleStatus#brakeLightsOn"), false);
			VehicleSort:dp(string.format('brakeLightsOn: {%s} for {%s} | savegame.key: {%s}', tostring(brakeLightsOn), self.configFileName, savegame.key .. ".vehicleStatus#brakeLightsOn"), 'VehicleStatus:onPostLoad');
			if brakeLightsOn then
				self:setBrakeLightsVisibility(brakeLightsOn, true);
			end
		end

		-- Handling trains differently
		if self.typeName == 'locomotive' then			
			if VehicleSort.loadTrainStatus[self.id] == nil then
				VehicleSort.loadTrainStatus[self.id] = {};
				VehicleSort.loadTrainStatus.entries = VehicleSort.loadTrainStatus.entries + 1;
			end
			VehicleSort.loadTrainStatus[self.id]['motorTurnedOn'] = Utils.getNoNil(savegame.xmlFile:getValue(savegame.key..".vehicleStatus#isMotorStarted"), false);
			VehicleSort:dp(string.format('Added train motor to loadTrainStatus. id {%d}', self.id));
		end
	end
end

function VehicleStatus:saveToXMLFile(xmlFile, key)
	if VehicleSort.config[14][2] then
		if VehicleStatus:getIsMotorStarted(self) then
			xmlFile:setValue(key.."#isMotorStarted", VehicleStatus:getIsMotorStarted(self))
			--setXMLBool(xmlFile, key .. '#isMotorStarted', VehicleStatus:getIsMotorStarted(self));
		end
		
		if VehicleStatus:getIsTurnedOn(self) then
			xmlFile:setValue(key.."#isTurnedOn", VehicleStatus:getIsTurnedOn(self))
			--setXMLBool(xmlFile, key .. '#isTurnedOn', VehicleStatus:getIsTurnedOn(self));
		end
		
		if VehicleStatus:getIsLightTurnedOn(self) then
			xmlFile:setValue(key.."#lightsMask", self:getLightsTypesMask())
			--setXMLInt(xmlFile, key .. '#lightsMask', self:getLightsTypesMask());
		end

		if VehicleStatus:getBeaconLightsVisibility(self) then
			xmlFile:setValue(key.."#beaconsOn", VehicleStatus:getBeaconLightsVisibility(self))
			--setXMLBool(xmlFile, key .. '#beaconsOn', VehicleStatus:getBeaconLightsVisibility(self));
		end

		if VehicleStatus:getTurnLightState(self) > 0 then
			xmlFile:setValue(key.."#turnLightsState", VehicleStatus:getTurnLightState(self))
			--setXMLInt(xmlFile, key .. '#turnLightsState', VehicleStatus:getTurnLightState(self));
		end

		if VehicleStatus:getIsBrakeLightsOn(self) then
			xmlFile:setValue(key.."#brakeLightsOn", VehicleStatus:getIsBrakeLightsOn(self))
			--setXMLBool(xmlFile, key .. '#brakeLightsOn', VehicleStatus:getIsBrakeLightsOn(self));
		end	
		
	end
end

function VehicleStatus:getIsMotorStarted(vehObj)
	if vehObj.spec_motorized ~= nil and vehObj.getIsMotorStarted ~= nil then
		return vehObj:getIsMotorStarted();
	end
end

function VehicleStatus:getIsTurnedOn(vehObj)
	if vehObj.spec_turnOnVehicle ~= nil and vehObj.getIsTurnedOn ~= nil then
		return vehObj:getIsTurnedOn()
	end
end

function VehicleStatus:getIsLightTurnedOn(vehObj)
	if vehObj.spec_lights ~= nil and vehObj.getLightsTypesMask ~= nil then
		if vehObj:getLightsTypesMask() > 0 then
			return true;
		else
			return false;
		end
	end
end

function VehicleStatus:getBeaconLightsVisibility(vehObj)
	if vehObj.spec_lights ~= nil and vehObj.getBeaconLightsVisibility ~= nil then
		return vehObj:getBeaconLightsVisibility()
	end
end

function VehicleStatus:getTurnLightState(vehObj)
	if vehObj.spec_lights ~= nil and vehObj.getTurnLightState ~= nil then
		return vehObj:getTurnLightState()
	else
		return 0;
	end
end

function VehicleStatus:getIsBrakeLightsOn(vehObj)
	if vehObj.spec_lights ~= nil and vehObj.spec_lights.brakeLightsVisibility ~= nil then
		return vehObj.spec_lights.brakeLightsVisibility;
	end
end

function VehicleStatus:getSpeedStr(vehObj)
	if vehObj.getLastSpeed ~= nil then
		local unit = nil
		local speed = nil
		if g_i18n.useMiles then
			speed = math.floor(vehObj:getLastSpeed() * 0.621371)
			unit = g_i18n.texts.unit_mph
		else
			speed = math.floor(vehObj:getLastSpeed())
			unit = g_i18n.texts.unit_kmh
		end
		
		return tostring(speed) .. " " .. unit;
	end
end

function VehicleStatus:RepairVehicleWithImplements(realId)
	veh = g_currentMission.vehicles[realId];
	VehicleSort:dp(string.format('realId {%s} for configFileName {%s}', realId, veh.configFileName), 'VehicleStatus:RepairVehicleWithImplements');
	if veh ~= nil then
		if veh.repairVehicle ~= nil then
			veh:repairVehicle(true);
			VehicleSort:dp(string.format('Repaired vehicle realId {%s} - configFileName {%s}', tostring(realId), veh.configFileName), 'VehicleStatus:RepairVehicleWithImplements');
			local implements = VehicleSort:getVehImplements(realId);
			if implements ~= nil then
				for i = 1, #implements do
					local imp = implements[i];
					if imp ~= nil and imp.object ~= nil and imp.object.repairVehicle ~= nil then
						imp.object:repairVehicle(true);
						VehicleSort:dp(string.format('Repaired implement configFileName {%s}', tostring(imp.object.configFileName)), 'VehicleStatus:RepairVehicleWithImplements');
					end
				end
			end
		end
	end
end


function VehicleStatus:CleanVehicleWithImplements(realId)
	veh = g_currentMission.vehicles[realId];
	VehicleSort:dp(string.format('realId {%s} for configFileName {%s}', realId, veh.configFileName), 'VehicleStatus:CleanVehicleWithImplements');
	if veh ~= nil then
		if veh.spec_washable ~= nil then
			VehicleStatus:setDirtOnObject(veh, 0)
			VehicleSort:dp(string.format('Cleaned vehicle realId {%s} - configFileName {%s}', tostring(realId), veh.configFileName), 'VehicleStatus:CleanVehicleWithImplements');
			local implements = VehicleSort:getVehImplements(realId);
			if implements ~= nil then
				for i = 1, #implements do
					local imp = implements[i];
					if imp ~= nil and imp.object ~= nil and imp.object.spec_washable ~= nil then
						VehicleStatus:setDirtOnObject(imp.object, 0)
						VehicleSort:dp(string.format('Cleaned implement configFileName {%s}', tostring(imp.object.configFileName)), 'VehicleStatus:CleanVehicleWithImplements');
					end
				end
			end
		end
	end
end

function VehicleStatus:RepaintVehicleWithImplements(realId)
	veh = g_currentMission.vehicles[realId];
	VehicleSort:dp(string.format('realId {%s} for configFileName {%s}', realId, veh.configFileName), 'VehicleStatus:RepaintVehicleWithImplements');
	if veh ~= nil then
		if veh.repaintVehicle then
			veh:repaintVehicle();
			VehicleSort:dp(string.format('Repainted vehicle realId {%s} - configFileName {%s}', tostring(realId), veh.configFileName), 'VehicleStatus:RepaintVehicleWithImplements');
			local implements = VehicleSort:getVehImplements(realId);
			if implements ~= nil then
				for i = 1, #implements do
					local imp = implements[i];
					if imp ~= nil and imp.object ~= nil and imp.object.repaintVehicle then
						imp.object:repaintVehicle();
						VehicleSort:dp(string.format('Repainted implement configFileName {%s}', tostring(imp.object.configFileName)), 'VehicleStatus:RepaintVehicleWithImplements');
					end
				end
			end
		end
	end
end

function VehicleStatus:getVehImplementsWear(realId)
	local texts = {};
	local line = "";

	local implements = VehicleSort:getVehImplements(realId);
	if implements ~= nil then
	
		for i = 1, #implements do
			local imp = implements[i];
			
			if (imp ~= nil and imp.object ~= nil and imp.object.getWearTotalAmount ~= nil) then
				line = string.gsub(VehicleSort:getAttachmentName(imp.object), "%s$", "") .. " | " .. g_i18n.modEnvironments[VehicleSort.ModName].texts.wear .. ": " .. VehicleSort:calcPercentage(imp.object:getWearTotalAmount(), 1) .. " %";
				table.insert(texts, line);
			end
		end
		
		return texts;
	else
		return nil;
	end
end

function VehicleStatus:getVehImplementsDamage(realId)
	local texts = {};
	local line = "";

	local implements = VehicleSort:getVehImplements(realId);
	if implements ~= nil then
	
		for i = 1, #implements do
			local imp = implements[i];
			
			if (imp ~= nil and imp.object ~= nil and imp.object.getDamageAmount ~= nil) then
				line = string.gsub(VehicleSort:getAttachmentName(imp.object), "%s$", "") .. " | " .. g_i18n.modEnvironments[VehicleSort.ModName].texts.damage .. ": " .. VehicleSort:calcPercentage(imp.object:getDamageAmount(), 1) .. " %";
				table.insert(texts, line);
			end
		end
		
		return texts;
	else
		return nil;
	end
end

function VehicleStatus:getDirtPercForObject(obj)
	if obj ~= nil then
		if obj.spec_washable ~= nil then
			local nodeCount = 0;
			local dirtAmount = 0;
			for _, node in pairs(obj.spec_washable.washableNodes) do
				dirtAmount = dirtAmount + node.dirtAmount;
				nodeCount = nodeCount + 1;
			end
			-- Total dirt should be combined dirt / nodecount
			return VehicleSort:calcPercentage(dirtAmount / nodeCount, 1);
		else
			return nil;
		end
	else
		return nil;
	end
end

function VehicleStatus:getVehImplementsDirt(realId)
	local texts = {};
	local line = "";

	local implements = VehicleSort:getVehImplements(realId);
	if implements ~= nil then
	
		for i = 1, #implements do
			local imp = implements[i];
			
			if (imp ~= nil and imp.object ~= nil and VehicleStatus:getDirtPercForObject(imp.object) ~= nil) then
				line = string.gsub(VehicleSort:getAttachmentName(imp.object), "%s$", "") .. " | " .. g_i18n.texts.setting_dirt .. ": " .. VehicleStatus:getDirtPercForObject(imp.object) .. " %";
				table.insert(texts, line);
			end
		end
		
		return texts;
	else
		return nil;
	end
end

function VehicleStatus:setDirtOnObject(obj, dirt)
	if obj.spec_washable ~= nil then
		for _, node in pairs(obj.spec_washable.washableNodes) do
			Washable:setNodeDirtAmount(node, dirt, force);
		end
		return true;
	else
		return nil;
	end
end

function VehicleStatus:getDieselLevel(realId)
	local veh = g_currentMission.vehicles[realId];
	if veh.getConsumerFillUnitIndex ~= nil and veh.getFillUnitFillLevel ~= nil then
		local fuelFillType = veh:getConsumerFillUnitIndex(FillType.DIESEL);
		local level = veh:getFillUnitFillLevel(fuelFillType);
		local capacity = veh:getFillUnitCapacity(fuelFillType);
		--VehicleSort:dp(string.format('level {%s} - capacity {%s}', level, capacity), 'getDieselLevel');
		if level ~= nil and capacity ~= nil then
			return math.floor(level), math.floor(capacity);
		else
			return nil;
		end
	else
		return nil;
	end
end

function VehicleStatus:getDefLevel(realId)
	local veh = g_currentMission.vehicles[realId];
	if veh.getConsumerFillUnitIndex ~= nil and veh.getFillUnitFillLevel ~= nil then
		local fuelFillType = veh:getConsumerFillUnitIndex(FillType.DEF);
		local level = veh:getFillUnitFillLevel(fuelFillType);
		local capacity = veh:getFillUnitCapacity(fuelFillType);
		--VehicleSort:dp(string.format('level {%s} - capacity {%s}', level, capacity), 'getDefLevel');
		if level ~= nil and capacity ~= nil then
			return math.floor(level), math.floor(capacity);
		else
			return nil;
		end
	else
		return nil;
	end
end

function VehicleStatus:getImplementStatus(realId)
	local impStatus = {};
	local implements = VehicleSort:getVehImplements(realId);
	if implements ~= nil then
		for i = 1, #implements do
			local imp = implements[i];
			if imp ~= nil and imp.object ~= nil then
				if imp.object.typeName ~= 'attachableFrontloader' then
					local isTurnedOn = nil;
					local isLowered = nil;
					
					if imp.object.getIsTurnedOn then
						isTurnedOn = imp.object:getIsTurnedOn();
					end
					if imp.object.getIsLowered then
						isLowered = imp.object:getIsLowered();
					end
					
					local entry = {jointDescIndex = imp.object.jointDescIndex, isTurnedOn = isTurnedOn, isLowered = isLowered, name = VehicleSort:getAttachmentName(imp.object)};
					table.insert(impStatus, entry);
				end
			end
		end
	end
	
	if #impStatus > 0 then
		return impStatus;
	end
end

function VehicleStatus:getFieldNumber(realId)
	local veh = g_currentMission.vehicles[realId];
	
	if veh.getIsOnField and veh:getIsOnField() then
		--Took the majority of the getFieldNumber code from VehicleInspector by HappyLooser. Kudos to him/her
		local veh_pos_x, veh_pos_y, veh_pos_z = getWorldTranslation(veh.components[1].node)
		
		for fieldNum,fieldDef in ipairs(g_fieldManager.fields) do
			for a=1, #fieldDef.getFieldStatusPartitions do
				local b = fieldDef.getFieldStatusPartitions[a];
				local x, z, wX, wZ, hX, hZ = b.x0, b.z0, b.widthX, b.widthZ, b.heightX, b.heightZ;
				local distanceMax = math.max(wX, wZ, hX, hZ);
				local distance = MathUtil.vector2Length(veh_pos_x - x, veh_pos_z - z);
				if distance <= distanceMax then
					--print("distance...".. tostring(distance).. " - maxDistance...".. tostring(distanceMax))
					return fieldDef.fieldId;
				end;				
			end;			
		end;

	else
		return false;
	end
end

function VehicleStatus:getOperatingHours(obj)	
	if obj.getOperatingTime then
		local milliSeconds = obj:getOperatingTime()
		local hours = string.format("%.1f h", (milliSeconds / 3600000));
		return hours;
	end
end

function VehicleStatus:getVehImplementsOperatingHours(realId)
	local texts = {};
	local line = "";

	local implements = VehicleSort:getVehImplements(realId);
	if implements ~= nil then
	
		for i = 1, #implements do
			local imp = implements[i];
			
			if (imp ~= nil and imp.object ~= nil and imp.object.getOperatingTime ~= nil) then
				line = string.gsub(VehicleSort:getAttachmentName(imp.object), "%s$", "") .. " | " .. g_i18n.modEnvironments[VehicleSort.ModName].texts.operationHours .. ": " .. VehicleStatus:getOperatingHours(imp.object);
				table.insert(texts, line);
			end
		end
		
		return texts;
	else
		return nil;
	end
end