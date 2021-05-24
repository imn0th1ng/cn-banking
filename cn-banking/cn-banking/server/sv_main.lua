ESX = nil

TriggerEvent('esx:getSharedObject', function(obj)
    ESX = obj
end)

local firstname = ""
local lastname = ""
local webhook = exports["inv-base"]:getwebhooks()
RegisterServerEvent("banking:get-infos")
AddEventHandler("banking:get-infos", function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    bank = xPlayer.getAccount('bank').money
    cash = xPlayer.getMoney()
    local result = MySQL.Sync.fetchAll("SELECT firstname, lastname, job, accounts, bankid FROM users WHERE identifier = @identifier", {
        ['@identifier'] = xPlayer.getIdentifier()
    })
    firstname = result[1]['firstname']
    lastname = result[1]['lastname']
    job = result[1]['job']
    bankid= result[1]['bankid']
    TriggerClientEvent("banking:infos", src, firstname, lastname, job, bank, cash, bankid)
end)

RegisterServerEvent("banking:withdraw")
AddEventHandler("banking:withdraw", function(amount, comment, date)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local type = "neg"
    local iden = "WITHDRAW"
    local sender = firstname.. " " ..lastname
    local target = sender
    local ply = ESX.GetPlayerFromId(src).getIdentifier()

    xPlayer.removeAccountMoney('bank', amount)
    xPlayer.addMoney(amount)

    Save(ply, amount, comment, date, type, sender, target, iden)
    TriggerClientEvent("banking:refresh", src)
    local discord2 = exports["inv-base"]:getid(xPlayer.source)["discord"]
    exports["inv-base"]:dclog(webhook.banka, "Banka Log", xPlayer.getName().." ["..xPlayer.identifier.."] kişisi **çekme** işlemi yapmıştır. Çektiği miktar: **"..amount.."**\n**Discord ID**: "..discord2)
    if comment == nil then
        comment = ""
    end
end)

RegisterServerEvent("banking:deposit")
AddEventHandler("banking:deposit", function(amount, comment, date)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local type = "pos"
    local iden = "DEPOSIT"
    local sender = firstname.. " " ..lastname
    local target = sender
    local ply = ESX.GetPlayerFromId(src).getIdentifier()

    xPlayer.removeMoney(amount)
    xPlayer.addAccountMoney('bank', amount)

    Save(ply, amount, comment, date, type, sender, target, iden)
    TriggerClientEvent("banking:refresh", src)
    local discord2 = exports["inv-base"]:getid(xPlayer.source)["discord"]
    exports["inv-base"]:dclog(webhook.banka, "Banka Log", xPlayer.getName().." ["..xPlayer.identifier.."] kişisi **yatırma** işlemi yapmıştır. Yatırdığı miktar: **"..amount.."**\n**Discord ID**: "..discord2)
    if comment == nil then
        comment = ""
    end
end)

RegisterServerEvent("banking:transfer")
AddEventHandler("banking:transfer", function(amount, comment, id, date)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local zPlayer = ESX.GetPlayerFromId(id)
    local type = "neg"
    local iden = "TRANSFER"
    local sender = firstname.. " " ..lastname
    local ply = ESX.GetPlayerFromId(src).getIdentifier()
    local result = MySQL.Sync.fetchAll("SELECT firstname, lastname FROM users WHERE identifier = @identifier", {
        ['@identifier'] = zPlayer.getIdentifier()
    })
    local fn2 = result[1]['firstname']
    local ln2 = result[1]['lastname']
    local target = fn2.. " ".. ln2
   
   if id == source then
    --TriggerClientEvent('DoLongHudText', source, "You can't transfer money yourself!", 2)
    print('kendine para basamıyon mal herif')
   else
    
    TriggerClientEvent("banking:refresh", src)

    if comment == nil then
        comment = ""
    end
    xPlayer.removeAccountMoney('bank', amount)
    zPlayer.addAccountMoney('bank', amount)
    local discord2 = exports["inv-base"]:getid(xPlayer.source)["discord"]
    exports["inv-base"]:dclog(webhook.banka, "Banka Log", xPlayer.getName().." ["..xPlayer.identifier.."] kişisi "..zPlayer.getName().." ["..xPlayer.identifier.."] kişisine **"..amount.."** havale yapmıştır\n**Discord ID**: "..discord2)
    Save(ply, amount, comment, date, type, sender, target, iden)
    ply = ESX.GetPlayerFromId(id).getIdentifier()
    type = "pos"
   end 
end)

ESX.RegisterServerCallback('banking:getRecent', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.Async.fetchAll('SELECT id, sender, target, label, amount, iden, type, date FROM account_recent WHERE identifier = @identifier', {
		['@identifier'] = xPlayer.identifier
	}, function(result)
		cb(result)

	end)
end)

AddEventHandler('esx:playerLoaded',function(playerId, xPlayer)
    local sourcePlayer = playerId
    local identifier = xPlayer.getIdentifier()

    getOrGenerateBankId(identifier, function(bankid)
    end)
end)

function generateBankId()
    local numBase0 = math.random(100000, 999999)
    local num = string.format(numBase0)

	return num
end

function getBankId(identifier)
    local result = MySQL.Sync.fetchAll("SELECT users.bankid FROM users WHERE users.identifier = @identifier", {
        ['@identifier'] = identifier
    })
    if result[1] ~= nil then
        return result[1].bankid
    end
    return nil
end

function getOrGenerateBankId(identifier, cb)
    local identifier = identifier
    local myBankId = getBankId(identifier)

    if myBankId == '0' or myBankId == nil then
        repeat
            myBankId = generateBankId()
            local id = getPlayerFromBankId(myBankId)

        until id == nil

        MySQL.Async.insert("UPDATE users SET bankid = @myBankId WHERE identifier = @identifier", { 
            ['@myBankId'] = myBankId,
            ['@identifier'] = identifier

        }, function()
            cb(myBankId)
        end)
    else
        cb(myBankId)
    end
end

function getPlayerFromBankId(bankid)
    local result = MySQL.Sync.fetchAll('SELECT * FROM users WHERE bankid = @bankid', {
		['@bankid'] = bankid
    })
    
    if result[1] and result[1].identifier then
        return ESX.GetPlayerFromIdentifier(result[1].identifier)
    end

    return nil
end

--RegisterServerEvent('banking:updaterecent')
--AddEventHandler('banking:updaterecent', function(amount, comment, date, type, sender, target, iden)
Save = function(identifier, amount, comment, date, type, sender, target, iden)
        exports.ghmattimysql:execute("INSERT INTO account_recent (identifier, sender, target, label, amount, iden, type, date) VALUES (@identifier, @sender, @target, @label, @amount, @iden, @type, @date)", {
            ['@identifier'] = identifier,
            ['@sender'] = sender,
            ['@target'] = target,
            ['@label'] = comment,
            ['@amount'] = amount,
            ['@iden'] = iden,
            ['@type'] = type,
            ['@date'] = date
        })
end