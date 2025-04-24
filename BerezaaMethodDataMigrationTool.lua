--[[
	BerezaaMethodDataMigrationTool.lua
	This module will migrate data from the Berezaa Method (One Standard Data Store and one 
	Ordered Data Store per key) to the standard method of storing data in Data Stores.
	----------
	
	GetAndMigrateIfNeeded(migratedDataStoreName, key, berezaaMethodStandardDataStoreName, berezaaMethodOrderedDataStoreName)
	    Reads data from the migrated data store, or migrates data.
	MigrateIfNeeded(migratedDataStoreName, key, berezaaMethodStandardDataStoreName, berezaaMethodOrderedDataStoreName, forceOverwrite)
		Migrates a data store.
--]]

local DataStoreService = game:GetService("DataStoreService")
local BerezaaMethodDataMigrationTool = {} -- table to represent the BerezaaMethodDataMigrationTool class

--[[
	Reads data from the migrated data store. If the data has not yet been migrated, 
	it migrates the data from the Berezaa Method Data Store and then returns the data.
	
	Note: do not use the same migratedDataStoreName and key for different Berezaa Method Data Stores; 
		otherwise, the migrated data will be overwritten
	-------------------------------------------------------------------------------

	migratedDataStoreName: The name of the data store that contains migrated data. 
			The key will be read from this data store. If it does not exist, it will be read from the 
			Berezaa Method Data Store and then migrated to this data store.
	key: The name of the key to retrieve (if using in Berezaa's style, this will likely be the player id).
	berezaaMethodStandardDataStoreName: The name of the Berezaa Method standard data store used to store data. 
			This likely includes the player name/id inside it, e.g. [player id]_inventory.
	berezaaMethodOrderedDataStoreName: The name of the Berezaa Method ordered data store used to store versions. 
			It is possible this is the same as the berezaaMethodStandardDataStoreName, in which case omit this 
			field or pass a duplicate string as the parameter.
--]]
function BerezaaMethodDataMigrationTool:GetAndMigrateIfNeeded(migratedDataStoreName, key, berezaaMethodStandardDataStoreName, berezaaMethodOrderedDataStoreName)
	-- check if the data has already been migrated. If it has, return the value.
	local migratedDS = DataStoreService:GetDataStore(migratedDataStoreName)
	local data = migratedDS:GetAsync(key)
	if data ~= nil then
		return data
	end

	berezaaMethodOrderedDataStoreName = berezaaMethodOrderedDataStoreName or berezaaMethodStandardDataStoreName
	local berezaaSDS = DataStoreService:GetDataStore(berezaaMethodStandardDataStoreName)
	local berezaaODS = DataStoreService:GetOrderedDataStore(berezaaMethodOrderedDataStoreName)

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

--[[
	Migrates player data from one Berezaa Data Store to a standard data store with the given name. 
	If the data has already been migrated, it will exit the function.
	
	Note: do not use the same migratedDataStoreName and key for different Berezaa Method Data Stores; 
		otherwise, the migrated data will be overwritten
	---------------------------------------------------------------------------------------
	
	migratedDataStoreName: The name of the data store that contains migrated data. 
			If the key does not exist, it will be read from the Berezaa Method Data 
			Store and then migrated to this data store
	key: The name of the key we should migrate (if using in Berezaa's style, this will likely be the player id).
	berezaaMethodStandardDataStoreName: The name of the Berezaa Method standard data store used to store data. 
			This likely includes the player name/id inside it, e.g. [player id]_inventory.
	berezaaMethodOrderedDataStoreName: The name of the Berezaa Method ordered data store used to store versions. 
			It is possible this is the same as the berezaaMethodStandardDataStoreName, in which case omit this 
			field or pass a duplicate string as the parameter.
	forceOverwrite: A bool that determines if you want to write the data from the Berezaa Method Data Store to 
			the migrated data store, even if data already exists in the migrated data store.
--]]
function BerezaaMethodDataMigrationTool:MigrateIfNeeded(migratedDataStoreName, key, berezaaMethodStandardDataStoreName, berezaaMethodOrderedDataStoreName, forceOverwrite)
	-- check if the data has already been migrated. If it has, return.
	local migratedDS = DataStoreService:GetDataStore(migratedDataStoreName)
	if not forceOverwrite then
		local migratedData = migratedDS:GetAsync(key)
		if migratedData ~= nil then
			return
		end
	end

	berezaaMethodOrderedDataStoreName = berezaaMethodOrderedDataStoreName or berezaaMethodStandardDataStoreName
	local berezaaSDS = DataStoreService:GetDataStore(berezaaMethodStandardDataStoreName)
	local berezaaODS = DataStoreService:GetOrderedDataStore(berezaaMethodOrderedDataStoreName)

	-- retrieve the latest version from the ODS
	local latestVersion = berezaaODS:GetSortedAsync(false, 1):GetCurrentPage()[1]
	if latestVersion then

		-- get the data value from the SDS
		local version = latestVersion.value
		local data = berezaaSDS:GetAsync(version)

		-- move this data into the new SDS
		migratedDS:SetAsync(key, data)
	end
end

return BerezaaMethodDataMigrationTool
