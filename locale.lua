locales = {}

function _(str, ...) -- Translate string
	if locales[config.locale] ~= nil then
		if locales[config.locale][str] ~= nil then
			return string.format(locales[config.locale][str], ...)
		else
			return 'Translation [' .. config.locale .. '][' .. str .. '] does not exist'
		end
	else
		return 'locale [' .. config.locale .. '] does not exist'
	end
end

function _U(str, ...) -- Translate string first char uppercase
	return tostring(_(str, ...):gsub('^%l', string.upper))
end
