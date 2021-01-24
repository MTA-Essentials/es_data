keys = getElementData(root, 'es-data-keys') or {} -- key, type, default, sync (broadcast, local, subscribe/client)
loading = {}

driver = config.database.driver
drivers = {}

addEventHandler(
    'onResourceStart',
    resourceRoot,
    function()
        if not drivers[driver] then
            error('[Data] ' .. _('database_invalid_driver'))
            return cancelEvent()
        end

        db = drivers[driver]

        local co
        co =
            coroutine.create(
            function()
                -- init database
                log('[Data] ' .. _('database_init', driver))
                if not db.init(co) then
                    return error('[Data] ' .. _('database_init_failure'))
                end
                log('[Data] ' .. _('database_init_success'))

                -- print("result", db.add(co, 1))
                -- print('result', db.get(co, 1, 'user_id'))
                -- print('result', db.set(co, 1, 'money', 12))
                -- triggerEvent('onElementDataRegister', resourceRoot, 'money', 'float', 0, 'client')

                -- triggerEvent('onPlayerLoading', resourceRoot, getRandomPlayer())
            end
        )
        coroutine.resume(co)
    end
)

addEventHandler(
    'onResourceStop',
    resourceRoot,
    function()
        setElementData(root, 'es-data-keys', keys, false)
    end
)

addEvent('onElementDataRegister')
addEventHandler(
    'onElementDataRegister',
    root,
    function(key, _type, def, sync)
        local co
        co =
            coroutine.create(
            function()
                dbQuery(
                    function(qr)
                        local data, nar, lid = dbPoll(qr, 0)
                        if data == false then
                            local error_code, error_message = nar, lid
                            error('[Database] ' .. _('database_query_error', error_code, error_message))
                            coroutine.resume(co, false)
                        else
                            coroutine.resume(co, data[1])
                        end
                    end,
                    {},
                    connection,
                    'SHOW COLUMNS FROM userdata LIKE ?',
                    key
                )

                local res = coroutine.yield()

                if not res then
                    dbQuery(
                        function(qr)
                            local data, nar, lid = dbPoll(qr, 0)
                            if data == false then
                                local error_code, error_message = nar, lid
                                error('[Database] ' .. _('database_query_error', error_code, error_message))
                                coroutine.resume(co, false)
                            else
                                coroutine.resume(co, data)
                            end
                        end,
                        {},
                        connection,
                        'ALTER TABLE userdata ADD ?? ?? NULL',
                        key,
                        db.types[_type]
                    )
                    local res = coroutine.yield()

                    if not res then
                        error('failed to add column')
                        return
                    end
                end

                keys[key] = {_type, def, sync}
            end
        )
        coroutine.resume(co)
    end
)

addEventHandler(
    'onElementDataChange',
    root,
    function(key, old, new)
        if not keys[key] then
            return
        end

        if old == new then
            return
        end

        if client then
            return
        end

        if getElementType(source) ~= 'player' then
            return
        end

        local player = source

        if loading[player] then
            return
        end

        local uid = getElementData(player, 'uid')

        if not uid then
            return
        end

        local co
        co =
            coroutine.create(
            function()
                db.set(co, uid, key, new)
            end
        )
        coroutine.resume(co)
    end
)

addEventHandler(
    'onPlayerLoading',
    root,
    function(player)
        local uid = getElementData(player, 'uid')

        if not uid then
            return
        end

        local co
        co =
            coroutine.create(
            function()
                if not db.get(co, uid, 'user_id') then
                    if not db.add(co, uid) then
                        error('add userdata failed')
                    end
                end

                local res = {}

                for i, v in pairs(keys) do
                    res[#res + 1] = i
                end

                local data = db.get(co, uid, res)

                -- compare data against keys to check default
                -- or
                -- remove default from keys and get it from mysql
                -- so the difference is basically dynamic and static
                -- if it's defined on mysql it'll be static
                -- my conclusion is it's a waste using mysql default

                loading[player] = true

                for i, v in pairs(keys) do
                    -- iprint(player, i, data[i] or v[3], v[4] or false)
                    local sync = v[4]
                    if v[4] == "client" then
                        sync = "subscribe"
                    end
                    setElementData(player, i, data[i] or v[3], sync or false)
                    if v[4] == "client" then
                        addElementDataSubscriber(player, i, player)
                    end
                end

                loading[player] = nil
            end
        )
        coroutine.resume(co)
        -- check if has row on table
    end
)
