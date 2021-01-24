config = {}
config.locale = getServerConfigSetting('es_locale') or 'en'
config.database = {
    driver = getServerConfigSetting('es_database_driver') or 'mysql', -- ("mysql", //Todo > "internal", "sqlite", "json")
    host = getServerConfigSetting('es_database_host') or '127.0.0.1',
    name = getServerConfigSetting('es_database_name') or 'essentialmode',
    port = getServerConfigSetting('es_database_port') or '3306',
    charset = getServerConfigSetting('es_database_charset') or 'utf8',
    username = getServerConfigSetting('es_database_username') or 'root',
    password = getServerConfigSetting('es_database_password') or ''
}
config.debug = getServerConfigSetting('es_debug') or 3 -- Log level: (0: disabled, 1: errors, 2: warnings, 3: info)
