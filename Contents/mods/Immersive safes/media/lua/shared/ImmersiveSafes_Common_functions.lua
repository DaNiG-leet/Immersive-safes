local a = {}

a.VaultTileList = {
	{
		close = 'safes_01_0',
		open = 'safes_01_2'
	},
	{
		close = 'safes_01_1',
		open = 'safes_01_3'
	},
	{
		close = 'safes_01_4',
		open = 'safes_01_6'
	},
	{
		close = 'safes_01_5',
		open = 'safes_01_7'
	},
	{
		close = 'safes_01_8',
		open = 'safes_01_10'
	},
	{
		close = 'safes_01_9',
		open = 'safes_01_11'
	},
	{
		close = 'safes_01_12',
		open = 'safes_01_14'
	},
	{
		close = 'safes_01_13',
		open = 'safes_01_15'
	},
	{
		close = 'safes_01_16',
		open = 'safes_01_18',
        wallSafe = true,
	},
	{
		close = 'safes_01_17',
		open = 'safes_01_19',
        wallSafe = true,
	},
	{
		close = 'safes_01_20',
		open = 'safes_01_22',
        wallSafe = true,
	},
	{
		close = 'safes_01_21',
		open = 'safes_01_23',
        wallSafe = true,
	},
	{
		close = 'safes_01_24',
		open = 'safes_01_26',
        wallSafe = true,
	},
	{
		close = 'safes_01_25',
		open = 'safes_01_27',
        wallSafe = true,
	},
	{
		close = 'safes_01_28',
		open = 'safes_01_30',
        wallSafe = true,
	},
	{
		close = 'safes_01_29',
		open = 'safes_01_31',
        wallSafe = true,
	},
	{
		close = 'safes_01_32',
		open = 'safes_01_33'
	},
	{
		close = 'safes_01_34',
		open = 'safes_01_35'
	},
}

a.isVaultOpen = function(value)
    for _, val in pairs(a.VaultTileList) do
        if val['open'] == value then return true end
        if val['close'] == value then return false end
    end
    return nil
end

return a