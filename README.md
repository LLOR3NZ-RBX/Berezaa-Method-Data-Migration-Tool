# Berezaa-Method-Data-Migration-Tool
## General Info
This module provides functions you can use to migrate data stored using the “Berezaa Method” to a single key in a Standard Data Store. This module will only migrate live players' data as it changes.

**Note:** A “Berezaa Method Data Store” represents a pair of data stores: a Standard Data Store and an Ordered Data Store. In the Berezaa Method, they collectively represent a single data value for a single player.

![image](https://github.com/user-attachments/assets/4f01cc21-2dc2-4624-95ea-356913489a55)


## Guide
Migration using these tools requires a few steps:

1. Install the BerezaaMethodDataMigrationTool.
2. Determine to what key and what data store you want each Berezaa Method Data Store to be migrated to.
3. Replace all “Gets” via Berezaa Method with `BerezaaMethodDataMigrationTool:GetAndMigrateIfNeeded()`.
4. Replace all “Sets” via Berezaa Method with `[Migrated Data Store]:[Set / Update / Increment]Async()`.

Below is an example of how an experience may use the module. The example 

```
-- BEFORE
ReplicatedStorage.BuyProduct.OnServerEvent:connect(function(player, productName)
    if not Products[productName] then return end
    local productPrice = Products[productName].price
    local migratedDsName = "coins"
    local migratedDs = DataStoreService:GetDataStore(migratedDsName)
    local numCoins = GetBerezaa("coins/" .. player.UserId)
    if numCoins >= productPrice then
        print("Buying product", productName)
        <Insert Berezaa Method Function to Set>("coins/ .. player.UserId, numCoins - productPrice)
    end
end)

-- AFTER
ReplicatedStorage.BuyProduct.OnServerEvent:connect(function(player, productName)
    if not Products[productName] then return end
    local productPrice = Products[productName].price
    local migratedDsName = "coins"
    local migratedDs = DataStoreService:GetDataStore(migratedDsName)
    local numCoins = BerezaaMethodDataMigrationTool:GetAndMigrateIfNeeded(migratedDsName, player.UserId, "coins/" .. player.UserId) -- gets data and migrates it
    if  numCoins >= productPrice then
        print("Buying product", productName)
        migratedDs:SetAsync(player.UserId, numCoins - productPrice)
    end
end)
```

A second function, `MigrateIfNeeded()` is provided as well for migrating keys at an as-needs basis. This should only be used for migrating individual keys, or for reverting back to the version stored in the Berezaa Method Data Store.

## API
### `BerezaaMethodDataMigrationTool:GetAndMigrateIfNeeded(migratedDataStoreName, key, berezaaMethodStandardDataStoreName, berezaaMethodOrderedDataStoreName)`

#### Description
Reads data from the migrated data store. If the data has not yet been migrated, it migrates the data from the Berezaa Method Data Store and then returns the data.

**Note**: do not use the same `migratedDataStoreName` and `key` for different Berezaa Method Data Stores; otherwise, the migrated data will be overwritten

#### Parameters 
Parameter | Description
:--- | :---
`migratedDataStoreName`: _string_ | The name of the data store that contains migrated data. The key will be read from this data store. If it does not exist, it will be read from the Berezaa Method Data Store and then migrated to this data store.
`key`: _string_ | The name of the key to retrieve (if using in Berezaa's style, this will likely be the player id).
`berezaaMethodStandardDataStoreName`: _string_ | The name of the Berezaa Method standard data store used to store data. This likely includes the player name/id inside it, e.g. [player id]_inventory.
`berezaaMethodOrderedDataStoreName`: _string_ | The name of the Berezaa Method ordered data store used to store versions. It is possible this is the same as the berezaaMethodStandardDataStoreName, in which case omit this field or pass a duplicate string as the parameter.

#### Returns
`Variant`: The value stored in the migrated or Berezaa Method Data Stores.

`Nil`: If no data was found in the migrated or Berezaa Method Data Stores.

 

### `BerezaaMethodDataMigrationTool:MigrateIfNeeded(migratedDataStoreName, key, berezaaMethodStandardDataStoreName, berezaaMethodOrderedDataStoreName, forceOverwrite)` 
#### Description
Migrates player data from one Berezaa Data Store to a standard data store with the given name. If the data has already been migrated, it will exit the function. 

**Note**: do not use the same `migratedDataStoreName` and `key` for different Berezaa Method Data Stores; otherwise, the migrated data will be overwritten

#### Parameters 
Parameter | Description
:--- | :---
`migratedDataStoreName`: _string_ | The name of the data store that contains migrated data. If the key does not exist, it will be read from the Berezaa Method Data Store and then migrated to this data store
`key`: _string_ | The name of the key we should migrate (if using in Berezaa's style, this will likely be the player id).
`berezaaMethodStandardDataStoreName`: _string_ | The name of the Berezaa Method standard data store used to store data. This likely includes the player name/id inside it, e.g. [player id]_inventory.
`berezaaMethodOrderedDataStoreName`: _string_ | The name of the Berezaa Method ordered data store used to store versions. It is possible this is the same as the berezaaMethodStandardDataStoreName, in which case omit this field or pass a duplicate string as the parameter.
`forceOverwrite`: _bool_ | A bool that determines if you want to write the data from the Berezaa Method Data Store to the migrated data store, even if data already exists in the migrated data store.

#### Returns
`Nil`
