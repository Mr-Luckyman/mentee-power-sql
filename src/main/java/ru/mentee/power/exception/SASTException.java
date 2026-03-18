/* @MENTEE_POWER (C)2026 */
package ru.mentee.power.exception;

import java.util.Arrays;
import java.util.stream.Collectors;

/**
 * Исключение, выбрасываемое при обнаружении проблем безопасности в конфигурации.
 * SAST (Static Application Security Testing) - статический анализ безопасности.
 */
public class SASTException extends RuntimeException {

    public SASTException(String message) {
        super(message);
    }

    public SASTException(String message, Throwable cause) {
        super(message, cause);
    }

    public SASTException(String message, String... details) {
        super(formatMessage(message, details));
    }

    private static String formatMessage(String message, String... details) {
        if (details == null || details.length == 0) {
            return message;
        }
        return Arrays.stream(details).collect(Collectors.joining(", ", message + " Детали: ", ""));
    }
}
