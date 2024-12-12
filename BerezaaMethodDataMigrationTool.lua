--[[
	BerezaaMethodDataMigrationTool.lua
	This module will migrate data from the Berezaa Method (One Standard Data Store and one 
	Ordered Data Store per key) to the standard method of storing data in Data Stores.
	----------
	
	MigrateIfNeeded(newDsName, newKey, sdsName, odsName, forceOverwrite) - Migrates a data store.
	GetAndMigrateIfNeeded(dsName, key, sdsName, odsName) - Reads data from the migrated data 
		store, or migrates data.
--]]

local DataStoreService = game:GetService("DataStoreService")
local BerezaaMethodDataMigrationTool = {} -- table to represent the BerezaaMethodDataMigrationTool class

--[[
	Migrates key data from Berezaa Data Stores to a Standard Data Store with the given name.
	If the data has already been migrated, it will exit the function.
	
	Note: do not use the same `newKey` and `newDsName` for different Berezaa Data Stores; 
	otherwise, the migrated data will be overwritten
	---------------------------------------------------------------------------------------
	
	newDsName: The name the data store the user would like to migrate data to.
	newKey: The name of the key we should migrate the data to
			(if using in Berezaa's style, this will likely be the player id)
	sdsName: The name of the standard data store used to store data.
	         This likely includes the player name/id inside it, e.g. 
	         [player id]_inventory.
	odsName: The name of the ordered data store used to store versions.
	         It is possible this is the same as the sdsName, in which case
	         omit this field or pass a duplicate string as the parameter.
	forceOverwrite: a bool that determines if you want to write the data even if
			 the data has already been migrated
--]]
function BerezaaMethodDataMigrationTool:MigrateIfNeeded(newDsName, newKey, sdsName, odsName, forceOverwrite)
	-- check if the data has already been migrated. If it has, return.
	local migratedDS = DataStoreService:GetDataStore(newDsName)
	if not forceOverwrite then
		local migratedData = migratedDS:GetAsync(newKey)
		if migratedData ~= nil then
			return
		end
	end

	odsName = odsName or sdsName
	local berezaaSDS = DataStoreService:GetDataStore(sdsName)
	local berezaaODS = DataStoreService:GetOrderedDataStore(odsName)

	-- retrieve the latest version from the ODS
	local latestVersion = berezaaODS:GetSortedAsync(false, 1):GetCurrentPage()[1]
	if latestVersion then

		-- get the data value from the SDS
		local version = latestVersion.value
		local data = berezaaSDS:GetAsync(version)

		-- move this data into the new SDS
		migratedDS:SetAsync(newKey, data)
	end
end

--[[
	Reads data from the migrated data store. If the data has not yet been migrated,
	it performs the migration and then returns the data. If there is no data,
	it returns nil.
	-------------------------------------------------------------------------------

	dsName: The name the data store the user would like to migrate data to.
	key: The name of the key we should migrate or retrieve data from
	     (If using in Berezaa's style, this will likely be the player id)
	sdsName: The name of the standard data store used to store data.
	   		 This likely includes the player name/id inside it, e.g. 
	   		 [player id]_inventory.
	odsName: The name of the ordered data store used to store versions.
	    	 It is possible this is the same as the sdsName, in which case
	    	 omit this field or pass a duplicate string as the parameter.
--]]
function BerezaaMethodDataMigrationTool:GetAndMigrateIfNeeded(dsName, key, sdsName, odsName)
	-- check if the data has already been migrated. If it has, return the value.
	local migratedDS = DataStoreService:GetDataStore(dsName)
	local data = migratedDS:GetAsync(key)
	if data ~= nil then
		return data
	end

	odsName = odsName or sdsName
	local berezaaSDS = DataStoreService:GetDataStore(sdsName)
	local berezaaODS = DataStoreService:GetOrderedDataStore(odsName)

	-- retrieve the latest version from the ODS
	local latestVersion = berezaaODS:GetSortedAsync(false, 1):GetCurrentPage()[1]
	if latestVersion then

		-- get the data value from the SDS
		local version = latestVersion.value
		local data = berezaaSDS:GetAsync(version)

		-- move this data into the new SDS and return
		migratedDS:SetAsync(key, data)
		return data
	end

	-- no data found
	return nil
end

return BerezaaMethodDataMigrationTool
