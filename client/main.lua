RDX              = nil
local PlayerData = {}

Citizen.CreateThread(function()
	while RDX == nil do
		TriggerEvent('rdx:getSharedObject', function(obj) RDX = obj end)
		Citizen.Wait(0)
	end
end)

RegisterNetEvent('rdx:playerLoaded')
AddEventHandler('rdx:playerLoaded', function(xPlayer)
  PlayerData = xPlayer   
end)

local shop = {
    { x=-322.25, y=803.97, z=116.95},
    { x=3017.29, y=1352.52, z=42.78}, 
    { x=-3701.45, y=-2596.06, z=-13.32}, 
}

local active = false
local ShopPrompt
local hasAlreadyEnteredMarker, lastZone
local currentZone = nil

function SetupShopPrompt()
    Citizen.CreateThread(function()
        local str = 'Loja'
        ShopPrompt = PromptRegisterBegin()
        PromptSetControlAction(ShopPrompt, 0xE8342FF2)
        str = CreateVarString(10, 'LITERAL_STRING', str)
        PromptSetText(ShopPrompt, str)
        PromptSetEnabled(ShopPrompt, false)
        PromptSetVisible(ShopPrompt, false)
        PromptSetHoldMode(ShopPrompt, true)
        PromptRegisterEnd(ShopPrompt)
    end)
end

Citizen.CreateThread(function()
	for _, info in pairs(shop) do
        local blip = N_0x554d9d53f696d002(1664425300, info.x, info.y, info.z)
        SetBlipSprite(blip, 1475879922, 1)
		SetBlipScale(blip, 0.2)
		Citizen.InvokeNative(0x9CB1A1623062F402, blip, "Loja")
    end  
end)

AddEventHandler('rdx:estalojas', function(zone)
	currentZone     = zone
end)

AddEventHandler('rdx:saiulojas', function(zone)
    if active == true then
        PromptSetEnabled(ShopPrompt, false)
        PromptSetVisible(ShopPrompt, false)
        active = false
    end
	currentZone = nil
end)

Citizen.CreateThread(function()
    SetupShopPrompt()
    while true do
        Citizen.Wait(0)
        local player = PlayerPedId()
        local coords = GetEntityCoords(player)
        local isInMarker, currentZone = false

        for k,v in ipairs(shop) do
            local distance = Vdist(coords.x, coords.y, coords.z, v.x, v.y, v.z)
            if distance < 1.0 then
                isInMarker  = true
                currentZone = 'shop'
                lastZone    = 'shop'
            end
        end

		if isInMarker and not hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = true
			TriggerEvent('rdx:estalojas', currentZone)
		end

		if not isInMarker and hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = false
			TriggerEvent('rdx:saiulojas', lastZone)
		end

    end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
        if currentZone then
            if active == false then
                PromptSetEnabled(ShopPrompt, true)
                PromptSetVisible(ShopPrompt, true)
                active = true
            end
            if PromptHasHoldModeCompleted(ShopPrompt) then
                openlojamenu()
                PromptSetEnabled(ShopPrompt, false)
                PromptSetVisible(ShopPrompt, false)
                active = false

				currentZone = nil
			end
        else
			Citizen.Wait(500)
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local coords = GetEntityCoords(PlayerPedId())
        Citizen.InvokeNative(0x2A32FAA57B937173, -1795314153, Config.Zonas['loja'].x, Config.Zonas['loja'].y, Config.Zonas['loja'].z - 1.0, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 0.9, 255, 255, 0, 155, 0, 0, 2, 0, 0, 0, 0)
		Citizen.InvokeNative(0x2A32FAA57B937173, -1795314153, Config.Zonas['loja1'].x, Config.Zonas['loja1'].y, Config.Zonas['loja1'].z - 1.0, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 0.9, 255, 255, 0, 155, 0, 0, 2, 0, 0, 0, 0)
		Citizen.InvokeNative(0x2A32FAA57B937173, -1795314153, Config.Zonas['loja2'].x, Config.Zonas['loja2'].y, Config.Zonas['loja2'].z - 1.0, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 0.9, 255, 255, 0, 155, 0, 0, 2, 0, 0, 0, 0)
	end
end)

openlojamenu = function()
	RDX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'lojas',
		{
            title  = 'loja' ,
            align = 'center',
			elements = {
				{label = "Pão $3", type = "slider", value = 1, min = 1, max = 1, price = 3, item = "bread"},
				{label = "Água $3", type = "slider", value = 1, min = 1, max = 1, price = 3, item = "water"},
            }
		},
		function(data, menu)
			local name = data.current.item
			local amount = data.current.value
			local money = data.current.value * data.current.price

			TriggerServerEvent('rdx_lojaseller:buy', name, amount, money)
        end,
        function(data, menu)
			menu.close()
        end
	)
end

RegisterNetEvent('rdx_lojaseller:alert')	
AddEventHandler('rdx_lojaseller:alert', function(txt)
    SetTextScale(0.5, 0.5)
    local str = Citizen.InvokeNative(0xFA925AC00EB830B9, 10, "LITERAL_STRING", txt, Citizen.ResultAsLong())
    Citizen.InvokeNative(0xFA233F8FE190514C, str)
    Citizen.InvokeNative(0xE9990552DEC71600)
end)
