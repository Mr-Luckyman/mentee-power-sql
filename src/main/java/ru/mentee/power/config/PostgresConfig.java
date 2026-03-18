/* @MENTEE_POWER (C)2026 */
package ru.mentee.power.config;

import java.util.Properties;
import lombok.extern.slf4j.Slf4j;

@Slf4j
public class PostgresConfig implements DatabaseConfig {

    private final Properties properties;

    public PostgresConfig(Properties properties) {
        this.properties = properties;
        log.info("Создан экземпляр PostgresConfig");
    }

    @Override
    public String getUrl() {
        String url = properties.getProperty(DB_URL);
        if (url == null || url.isBlank()) {
            log.error("URL базы данных не найден в конфигурации!");
            throw new IllegalStateException("URL базы данных не найден в конфигурации");
        }
        log.debug("URL базы данных: {}", maskUrl(url));
        return url;
    }

    @Override
    public String getUsername() {
        String username = properties.getProperty(DB_USERNAME);
        if (username == null || username.isBlank()) {
            log.error("Имя пользователя не найдено в конфигурации!");
            throw new IllegalStateException("Имя пользователя не найдено в конфигурации");
        }
        log.debug("Имя пользователя: {}", username);
        return username;
    }

    @Override
    public String getPassword() {
        String password = properties.getProperty(DB_PASSWORD);
        if (password == null || password.isBlank()) {
            log.error(
                    "Пароль не найден в конфигурации! Пароль должен быть в secret.properties или"
                            + " ENV");
            throw new IllegalStateException("Пароль не найден в конфигурации");
        }
        log.debug("Пароль получен (замаскирован)");
        return password;
    }

    @Override
    public String getDriver() {
        String driver = properties.getProperty(DB_DRIVER, "org.postgresql.Driver");
        log.debug("Драйвер: {}", driver);
        return driver;
    }

    @Override
    public boolean getShowSql() {
        String showSql = properties.getProperty(DB_SHOW_SQL, "false");
        boolean result = Boolean.parseBoolean(showSql);
        log.debug("Показывать SQL: {}", result);
        return result;
    }

    /**
     * Маскирует URL для логирования (скрывает пароль, если он есть в URL)
     */
    private String maskUrl(String url) {
        if (url == null) return null;
        // Простая маскировка — если в URL есть @, предполагаем что там могут быть credentials
        if (url.contains("@")) {
            return url.replaceAll("://[^:]+:[^@]+@", "://***:***@");
        }
        return url;
    }
}
