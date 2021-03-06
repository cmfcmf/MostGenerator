package org.zikula.modulestudio.generator.extensions

/**
 * Various helper functions for formatting names and qualifiers.
 */
class FormattingExtensions {

    /**
     * Replaces special chars, like German umlauts, by international version.
     *
     * @param s given input string
     * @return String without special characters.
     */
    def replaceSpecialChars(String s) {
        s.replace('', 'Ae').replace('', 'ae').replace('', 'Oe')
         .replace('', 'oe').replace('', 'Ue').replace('', 'ue')
         .replace('', 'ss').replaceAll('[\\W]', '')
    }

    /**
     * Formats a string for usage in generated source code starting not with capital.
     *
     * @param s given input string
     * @return String formatted for source code usage.
     */
    def formatForCode(String s) {
        s.replaceSpecialChars.toFirstLower
    }

    /**
     * Formats a string for usage in generated source code starting with capital.
     *
     * @param s given input string
     * @return String formatted for source code usage.
     */
    def formatForCodeCapital(String s) {
        s.formatForCode.toFirstUpper
    }

    /**
     * Formats a string for usage in generated source code in lower case.
     *
     * @param s given input string
     * @return String formatted for database usage.
     */
    def formatForDB(String s) {
        s.replaceSpecialChars.toLowerCase
    }

    /**
     * Formats a string for improved output readability starting not with capital.
     * For example FederalStateName becomes federal state name.
     *
     * @param s given input string
     * @return String formatted for display.
     */
    def formatForDisplay(String s) {
        var result = ""
        val helpString = replaceSpecialChars(s)

        val helpChars = helpString.toCharArray

        for (c : helpChars) {
            val sc = c.toString
            if (sc.matches("[A-Z]")) {
                result = result + ' '
            }
            result = result + sc.toLowerCase
        }

        result.trim.toFirstLower
    }

    /**
     * Formats a string for improved output readability starting with capital.
     * For example federalStateName becomes Federal state name.
     *
     * @param s given input string
     * @return String formatted for display.
     */
    def formatForDisplayCapital(String s) {
        s.formatForDisplay.toFirstUpper
    }

    /**
     * Displays a boolean value as string ("true" or "false").
     *
     * @param b given input boolean
     * @return String value of given boolean.
     */
    def displayBool(Boolean b) {
        if (b) 'true'
        else 'false'
    }
}
