# Berezaa-Method-Data-Migration-Tool
## General Info
This module provides functions you can use to migrate data stored using the “Berezaa Method” to a single key in a Standard Data Store. This module will only migrate live players' data as it changes.

## Guide
Migration using these tools requires a few steps:

1. Install the BerezaaMethodDataMigrationTool.
2. Determine to what key and what data store you want each Berezaa Data Store to be migrated to.
3. Replace all “Gets” via Berezaa Method with `BerezaaMethodDataMigrationTool:GetAndMigrateIfNeeded()`.
4. Replace all “Sets” via Berezaa Method with `[Migrated Data Store]:[Set / Update / Increment]Async()`.

Below is an example of how an experience may use the module.

```
-- BEFORE
ReplicatedStorage.BuyProduct.OnServerEvent:connect(function(player, productName)
    if not Products[productName] then return end
    local productPrice = Products[productName].price
    local migratedDsName = "coins"
    local migratedDs = DataStoreService:GetDataStore(migratedDsName)
    if GetBerezaa("coins/" .. player.UserId) >= productPrice then
        print("Buying product", productName)
        IncrementBerezaa("coins/ .. player.UserId, -productPrice)
    end
end)

-- AFTER
ReplicatedStorage.BuyProduct.OnServerEvent:connect(function(player, productName)
    if not Products[productName] then return end
    local productPrice = Products[productName].price
    local migratedDsName = "coins"
    local migratedDs = DataStoreService:GetDataStore(migratedDsName)
    if BerezaaMethodDataMigrationTool:GetAndMigrateIfNeeded(migratedDsName, player.UserId, "coins/" .. player.UserId) >= productPrice then
        print("Buying product", productName)
        migratedDs:IncrementAsync(player.UserId, -productPrice)
    end
end)
```

A second function, `MigrateIfNeeded()` is provided as well for migrating keys at an as-needs basis.

## API
### `BerezaaMethodDataMigrationTool:GetAndMigrateIfNeeded(dsName, key, sdsName, odsName)`

### Description
Reads data from the migrated data store. I fthe data has not yet been migrated, it performs the migration and then returns he data.

**Note**: do not use the same newDsName for different Berezaa-style Data Stores; otherwise, the migrated data will be overwritten

### Parameters 
`dsName`: The name the data store the user would like to read data from and/or migrate data to. 

`key`: The name of the key we should migrate or retrieve data from (if using in Berezaa's style, this will likely be the player id) 

`sdsName`: The name of the standard data store used to store data. This likely includes the player name/id inside it, e.g. [player id]_inventory. 

`odsName`: The name of the ordered data store used to store versions. It is possible this is the same as the sdsName, in which case omit this field or pass a duplicate string as the parameter. 

### Returns
`Variant`: The value stored in the migrated or Berezaa Data Stores.

`Nil`: If no data was found in the migrated or Berezaa Data Stores.

 

### `BerezaaMethodDataMigrationTool:MigrateIfNeeded(newDsName, newKey, sdsName, odsName, forceOverwrite)` 
#### Description
Migrates player data from one Berezaa Data Store to a standard data store with the given name. If the data has already been migrated, it will exit the function. 

**Note**: do not use the same newDsName for different Berezaa-style Data Stores; otherwise, the migrated data will be overwritten

### Parameters 
`newDsName`: The name the data store the user would like to migrate data to. 

`newKey`: The name of the key we should migrate the data to (if using in Berezaa's style, this will likely be the player id) 

`sdsName`: The name of the standard data store used to store data. This likely includes the player name/id inside it, e.g. [player id]_inventory. 

`odsName`: The name of the ordered data store used to store versions. It is possible this is the same as the sdsName, in which case omit this field or pass a duplicate string as the parameter. 

`forceOverwrite`: A bool that determines if you want to write the data even if the data has already been migrated

### Returns
`Nil`
