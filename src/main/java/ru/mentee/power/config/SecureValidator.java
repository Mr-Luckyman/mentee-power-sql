/* @MENTEE_POWER (C)2026 */
package ru.mentee.power.config;

import java.util.ArrayList;
import java.util.List;
import java.util.Properties;
import lombok.extern.slf4j.Slf4j;
import ru.mentee.power.exception.SASTException;

@Slf4j
public class SecureValidator {

    private static final String DB_PASSWORD_KEY = "db.password";
    private static final List<String> WEAK_PASSWORDS =
            List.of("password", "123456", "qwerty", "admin", "password123", "12345678");

    private final Properties properties;

    public SecureValidator(Properties properties) {
        this.properties = properties;
    }

    /**
     * Валидирует конфигурацию на наличие проблем безопасности
     * @throws SASTException если найдены проблемы
     */
    public void validate() {
        log.info("Запуск SAST валидации конфигурации...");
        List<String> violations = new ArrayList<>();

        checkPasswordInPublicProps(violations);
        checkWeakPassword(violations);

        if (!violations.isEmpty()) {
            String message =
                    String.format(
                            "Обнаружены проблемы безопасности (%d нарушений)", violations.size());
            log.error(message);
            violations.forEach(log::error);
            throw new SASTException(message, violations.toArray(new String[0]));
        }

        log.info("SAST валидация пройдена успешно. Нарушений не обнаружено.");
    }

    /**
     * Проверяет, нет ли пароля в публичных свойствах (до загрузки secret.properties)
     */
    private void checkPasswordInPublicProps(List<String> violations) {
        String password = properties.getProperty(DB_PASSWORD_KEY);
        if (password != null && !password.isBlank()) {
            String violation =
                    String.format(
                            "Переменная %s не должна быть записана в публичной конфигурации! Пароль"
                                + " должен быть в secret.properties или ENV. Найдено значение: %s",
                            DB_PASSWORD_KEY, maskPassword(password));
            violations.add(violation);
            log.warn(violation);
        }
    }

    /**
     * Проверяет пароль на слабость
     */
    private void checkWeakPassword(List<String> violations) {
        String password = properties.getProperty(DB_PASSWORD_KEY);
        if (password == null || password.isBlank()) {
            return;
        }

        if (WEAK_PASSWORDS.contains(password.toLowerCase())) {
            String violation =
                    String.format(
                            "Использован слабый пароль: '%s'. Пароль должен быть сложным (минимум 8"
                                    + " символов, содержать буквы разного регистра, цифры и"
                                    + " спецсимволы)",
                            maskPassword(password));
            violations.add(violation);
            log.warn(violation);
        } else if (password.length() < 8) {
            String violation =
                    String.format(
                            "Пароль слишком короткий (%d символов). Минимальная длина 8 символов",
                            password.length());
            violations.add(violation);
            log.warn(violation);
        }
    }

    /**
     * Маскирует пароль для логирования
     */
    private String maskPassword(String password) {
        if (password == null) return null;
        if (password.length() <= 4) return "****";
        return password.substring(0, 2) + "****" + password.substring(password.length() - 2);
    }
}
