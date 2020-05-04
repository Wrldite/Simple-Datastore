local Players = game:GetService("Players");
local DataStoreService = game:GetService("DataStoreService");
local RunService = game:GetService("RunService");

local Internal = require(script.DataStore2);

local DATANAME = "379810371819";
local Cache = {};

local Data = {};
Data.__index = Data;

--[[
	DOCUMENTATION:
	
	Constructor | Data.new(<instance>player)
	Method | Data:Get(<string>Index)
			 Returns the Index Value
	Method | Data:Set(<string>Index, <any>Value)
	Method | Data:Save()
]]--

function Data.new(player)
	
	local self = {
		Player = player;
		DataStore = DataStoreService:GetDataStore(DATANAME);
	}
	
	return setmetatable(self, Data);
end

function Data:Get(Index)
	if self.Player:FindFirstChild("Data") then
		return Cache[self.Player.Name][Index];
	else
		if not RunService:IsStudio() then
			local Data;
			local Success, Err;
			local Iteration = 0;
			
			repeat
				Success, Err = pcall(function()
					Data = self.DataStore:GetAsync(
						self.Player.UserId
					);
				end)
				Iteration = 1;
				if Iteration > 5 then
					self.Player:Kick("ERROR:", Err);
				end
			until Success
			
			local boolValue = Instance.new("BoolValue", self.Player);
			boolValue.Name = "Data";
			
			return Data or Default
		else
			local boolValue = Instance.new("BoolValue", self.Player);
			boolValue.Name = "Data";
			
			return Default;
		end
	end
end

function Data:Set(Index, Value)
	if self.Player:FindFirstChild("Data") then
		Cache[self.Player.Name][Index] = Value;
	end
end

function Data:Save()
	if self.Player:FindFirstChild("Data") then
		if RunService:IsStudio() then
			local Data;
			local Success, Err;
			local Iteration = 0;
			
			repeat
				Success, Err = pcall(function()
					self.DataStore:SetAsync(
						self.Player.UserId, 
						Cache[self.Player.Name]
					);
				end)
				Iteration = 1;
				if Iteration > 5 then
					warn("[ERROR]:", Err);
				end
			until Success
		end
	end
end

function Data:Remove()
	if self.Player:FindFirstChild("Data") then
		if RunService:IsStudio() then
			local Data;
			local Success, Err;
			local Iteration = 0;
			
			repeat
				Success, Err = pcall(function()
					self.DataStore:SetAsync(
						self.Player.UserId, 
						{}
					);
				end)
				Iteration = 1;
				if Iteration > 5 then
					warn("[ERROR]:", Err);
				end
			until Success
		end
	end
end

Data.Initialize = function()
	Players.PlayerAdded:Connect(function(Player)
		Cache[Player.Name] = {};
	end)
	Players.PlayerRemoving:Connect(function(Player)
		Cache[Player.Name] = nil;
	end)
end

return Data
