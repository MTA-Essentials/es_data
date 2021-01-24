function findPlayer(partial)
    if not partial or partial == '' then
        return false
    end
    local player = getPlayerFromName(tostring(partial))
    if player then
        return player
    end
    for _, player in pairs(getElementsByType('player')) do
        if tonumber(getElementData(player, 'id')) == tonumber(partial) then
            if getElementData(player, 'loggedIn') == true then
                return player
            end
        end
    end

    for _, player in pairs(getElementsByType('player')) do
        if string.find(string.gsub(getPlayerName(player):lower(), '#%x%x%x%x%x%x', ''), partial:lower(), 1, true) then
            if getElementData(player, 'loggedIn') == true then
                return player
            end
        end
    end
end

function log(str)
    if config.debug >= 3 then
        return outputDebugString(str, 3)
    end
end

function warning(str)
    if config.debug >= 2 then
        return outputDebugString(str, 2)
    end
end

function error(str)
    if config.debug >= 1 then
        return outputDebugString(str, 3)
    end
end
