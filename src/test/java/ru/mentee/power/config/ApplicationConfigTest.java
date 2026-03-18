/* @MENTEE_POWER (C)2026 */
package ru.mentee.power.config;

import static org.assertj.core.api.Assertions.*;

import java.io.IOException;
import java.util.Properties;
import org.junit.jupiter.api.Test;
import ru.mentee.power.exception.SASTException;

class ApplicationConfigTest {

    @Test
    void shouldThrowError() throws IOException {
        assertThatThrownBy(
                        () ->
                                new ApplicationConfig(
                                        new Properties(),
                                        new ConfigFilePath(
                                                "/application-with-secret.properties",
                                                "/secret.properties")))
                .isInstanceOf(SASTException.class)
                .hasMessageContaining("Обнаружены проблемы безопасности (2 нарушений)")
                .hasMessageContaining(
                        "Переменная db.password не должна быть записана в публичной конфигурации")
                .hasMessageContaining("Использован слабый пароль");
    }

    @Test
    void shouldHasProperties() throws IOException {
        ApplicationConfig databaseConfig =
                new ApplicationConfig(new Properties(), new ConfigFilePath());
        assertThat(databaseConfig.getPassword()).isNotNull();
        assertThat(databaseConfig.getUsername()).isNotNull();
        assertThat(databaseConfig.getUrl()).isNotNull();
        assertThat(databaseConfig.getShowSql()).isTrue();
    }

    @Test
    void shouldExistWithoutSecret() {
        assertThatCode(
                        () ->
                                new ApplicationConfig(
                                        new Properties(),
                                        new ConfigFilePath(
                                                "/application.properties",
                                                "/fake-secret.properties")))
                .doesNotThrowAnyException();
    }
}
