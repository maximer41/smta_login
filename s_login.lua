--[[
			AUTOR: xMaximerr <xmaximerr.programmer@vp.pl>
			GAMEMODE: SouthMTA <southmta.pl>
			Nie masz prawa używać tego kodu bez mojej zgody!
--]]

function generatorHashMybb(salt, password, passwordMybb, player, email)
	callRemote("www.southmta.pl/auth.php", callHashPassword, salt, password, passwordMybb, player, email)
end

function callHashPassword(hash, passwordMybb, player, email) 
	if tostring(hash):lower() == "error" then 
		exports.smta_notifications:showBox(player,"Wystąpił błąd podczas logowania!")
		triggerClientEvent("l_setEnabled",player,true)
		return
	end

	if hash then 
    	if hash==passwordMybb then
    		local w=exports.smta_mybb:pobierzTabeleWynikow("SELECT * FROM `mybb_users` WHERE email=?",email)
    	    --{account uid, southPoints, southCoins, premium account, admin rank, -, aj, pm status, pm partner}
    	    setElementData(player, "k:data", {w[1].uid, w[1].southPoints, w[1].southCoins, w[1].premium, w[1].gamerank, 0, w[1].aj, true, nil})
            setElementData(player, "k:icons",{
                [1]=false, --afk
                [2]=false, --typing
                [3]=false, --pm
                [4]=false, --phone
                [5]=false, --drone
            })
    	    setPlayerName(player, w[1].username)
			exports.smta_mybb:zapytanie("UPDATE mybb_users SET serial=? WHERE uid=?", getPlayerSerial(player), w[1].uid)
    	    triggerClientEvent("l_hide",player)
    	    exports.smta_characters:onOpenCharactersMenu(player)
    	    return
    	else
    	    return exports.smta_notifications:showBox(player,"Hasło jest niepoprawne!"),triggerClientEvent("l_setEnabled",player,true)
    	end
    end

end


local function onSubmitLogin(email, password)
    if email and password then
        if string.len(email)<2 or not string.find(email, "@.") then
            return exports.smta_notifications:showBox(source,"Podałeś niepoprawny e-mail."),triggerClientEvent("l_setEnabled",source,true)
        elseif string.len(password)<2 then
            return exports.smta_notifications:showBox(source,"Podałeś nieporawne hasło."),triggerClientEvent("l_setEnabled",source,true)
        end

        local w=exports.smta_mybb:pobierzTabeleWynikow("SELECT * FROM `mybb_users` WHERE email=?",email)
        if #w==0 then
            return exports.smta_notifications:showBox(source,"Konto o takim e-mailu nie istnieje."),triggerClientEvent("l_setEnabled",source,true)
        end
        
        local x=exports.smta_mybb:pobierzTabeleWynikow("SELECT * FROM `mybb_banned` WHERE uid=?",w[1].uid)
        if #x>0 then
            return exports.smta_notifications:showBox(source,"To konto jest zablokowane do "..x[1].bantime.."."),triggerClientEvent("l_setEnabled",source,true)
        end

        generatorHashMybb(w[1].salt, password, w[1].password, source, email)
        return
    end
end
addEvent("l_tryLogin", true)
addEventHandler("l_tryLogin", root, onSubmitLogin)