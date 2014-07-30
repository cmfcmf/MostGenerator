package org.zikula.modulestudio.generator.cartridges.zclassic.controller.installer

import de.guite.modulestudio.metamodel.modulestudio.Variable
import de.guite.modulestudio.metamodel.modulestudio.BoolVar
import de.guite.modulestudio.metamodel.modulestudio.IntVar
import de.guite.modulestudio.metamodel.modulestudio.ListVar
import de.guite.modulestudio.metamodel.modulestudio.ListVarItem
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions

/**
 * Utility methods for the installer.
 */
class ModVars {
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions

    def valFromSession(Variable it) {
        switch it {
            ListVar: '''IF it.multipleserialize(ENDIF$sessionValueIF it.multiple)ENDIF'''
            default: '''$sessionValue'''
        }
    }

    def dispatch CharSequence valSession2Mod(Variable it) {
        switch it {
            BoolVar: '''IF value !== null && value == 'true'trueELSEfalseENDIF'''
            IntVar: '''IF value !== null && value != ''valueELSE0ENDIF'''
            ListVar: '''IF it.multiplearray(ENDIFFOR item : it.getDefaultItems SEPARATOR ', 'item.valSession2ModENDFORIF it.multiple)ENDIF'''
            default: '\'' + value + '\''
        }
    }

    def dispatch CharSequence valSession2Mod(ListVarItem it) '''IF it.^default == true'name.formatForCode'ENDIF'''

    def dispatch CharSequence valDirect2Mod(Variable it) {
        switch it {
            BoolVar: '''IF value !== null && value == 'true'trueELSEfalseENDIF'''
            IntVar: '''IF value !== null && value != ''valueELSE0ENDIF'''
            ListVar: '''IF it.multiplearray(ENDIFFOR item : it.getDefaultItems SEPARATOR ', 'item.valDirect2ModENDFORIF it.multiple)ENDIF'''
            default: '\'' + (if (value !== null) value else '') + '\''
        }
    }

    def dispatch CharSequence valDirect2Mod(ListVarItem it) ''' 'name.formatForCode' '''

    // for interactive installer
    def dispatch CharSequence valForm2SessionDefault(Variable it) {
        switch it {
            ListVar: '''IF it.multipleserialize(array(ENDIFFOR item : it.getDefaultItems SEPARATOR ', 'item.valForm2SessionDefaultENDFORIF it.multiple))ENDIF'''
            default: '\'' + value.formatForCode + '\''
        }
    }

    def dispatch CharSequence valForm2SessionDefault(ListVarItem it) ''' 'name.formatForCode' '''
}
