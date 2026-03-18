/* @MENTEE_POWER (C)2026 */
package ru.mentee.power.config;

public record ConfigFilePath(String appMainConfigPath, String appSecretPath) {
    private static final String DEFAULT_APP_PATH = "/application.properties";
    private static final String DEFAULT_SECRET_PATH = "/secret.properties";

    public ConfigFilePath() {
        this(DEFAULT_APP_PATH, DEFAULT_SECRET_PATH);
    }
}
