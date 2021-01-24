local seed = [[
    CREATE TABLE userdata (
        user_id bigint(20) UNSIGNED NOT NULL,
        CONSTRAINT userdata_pk PRIMARY KEY (user_id),
        CONSTRAINT userdata_userid_fk FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE NO ACTION ON UPDATE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
]]

local db = {}
db.init = function(co)
    log('[Database] ' .. _('database_connecting'))

    local result = dbConnect('mysql', string.format('dbname=%s;host=%s;port=%s;charset=%s', config.database.name, config.database.host, config.database.port, config.database.charset), config.database.username, config.database.password, 'suppress=1062,1169; share=0; log=0; multi_statements=1;')

    if not result then
        return false
    end

    connection = result

    dbQuery(
        function(qr)
            local data, nar, lid = dbPoll(qr, 0)
            if data == false then
                local error_code, error_message = nar, lid
                error('[Database] ' .. _('database_query_error', error_code, error_message))
                coroutine.resume(co, false)
            else
                coroutine.resume(co, #data == 1 and true)
            end
        end,
        {},
        connection,
        'SHOW TABLES LIKE ?',
        'userdata'
    )

    local res = coroutine.yield()

    if not res then
        warning('userdata table not found')

        dbQuery(
            function(qr)
                local data, nar, lid = dbPoll(qr, 0)
                if data == false then
                    local error_code, error_message = nar, lid
                    error('[Database] ' .. _('database_query_error', error_code, error_message))
                    coroutine.resume(co, false)
                else
                    coroutine.resume(co, data and true)
                end
            end,
            {},
            connection,
            seed
        )

        res = coroutine.yield()

        if not res then
            error("couldn't create userdata")
            return false
        end
    end

    return true
end

db.add = function(co, uid)
    dbQuery(
        function(qr)
            local data, nar, lid = dbPoll(qr, 0)
            if data == false then
                local error_code, error_message = nar, lid
                error('[Database] ' .. _('database_query_error', error_code, error_message))
                coroutine.resume(co, false)
            else
                coroutine.resume(co, data and true)
            end
        end,
        {},
        connection,
        'INSERT INTO userdata (user_id) VALUES (?)',
        uid
    )

    local res = coroutine.yield()

    return res
end

db.set = function(co, uid, key, value)
    dbQuery(
        function(qr)
            local data, nar, lid = dbPoll(qr, 0)
            if data == false then
                local error_code, error_message = nar, lid
                error('[Database] ' .. _('database_query_error', error_code, error_message))
                coroutine.resume(co, false)
            else
                coroutine.resume(co, data and true)
            end
        end,
        {},
        connection,
        'UPDATE userdata SET ?? = ? WHERE user_id = ?',
        key,
        value,
        uid
    )

    local res = coroutine.yield()

    return res
end

db.get = function(co, uid, key)
    if type(key) == 'table' then
        key = table.concat(key, ',')
    end
    dbQuery(
        function(qr)
            local data, nar, lid = dbPoll(qr, 0)
            if data == false then
                local error_code, error_message = nar, lid
                error('[Database] ' .. _('database_query_error', error_code, error_message))
                coroutine.resume(co, false)
            else
                if data[1] then
                    coroutine.resume(co, data[1])
                else
                    coroutine.resume(co, false)
                end
            end
        end,
        {},
        connection,
        'SELECT ? FROM userdata WHERE user_id = ?',
        key,
        uid
    )

    local res = coroutine.yield()

    return res
end

db.types = {string = 'varchar(255)', table = 'longtext', int = 'int', float = 'float', bool = 'tinyint'}

drivers.mysql = db
