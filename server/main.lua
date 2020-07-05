RDX = nil

TriggerEvent('rdx:getSharedObject', function(obj) RDX = obj end)

RegisterNetEvent('rdx_lojaseller:buy')
AddEventHandler('rdx_lojaseller:buy', function(item, amount, money)
   local xPlayer = RDX.GetPlayerFromId(source)
   local moneys = xPlayer.getMoney()
   if moneys >= money then
   xPlayer.removeMoney(money)
   xPlayer.addInventoryItem(item, amount)
   TriggerClientEvent('rdx_lojaseller:alert', source, 'Comprou!')
   else 
   TriggerClientEvent('rdx_lojaseller:alert', source, 'Não tens dinheiro suficiente')
   end
end)