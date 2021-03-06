package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin

import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class FormatGeoData {
    extension FormattingExtensions = new FormattingExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate(Application it, IFileSystemAccess fsa) {
        val pluginFilePath = viewPluginFilePath('modifier', 'FormatGeoData')
        if (!shouldBeSkipped(pluginFilePath)) {
            fsa.generateFile(pluginFilePath, new FileHelper().phpFileContent(it, formatGeoDataImpl))
        }
    }

    def private formatGeoDataImpl(Application it) '''
        /**
         * The appName.formatForDBFormatGeoData modifier formats geo data.
         *
         * @param string $string The data to be formatted.
         *
         * @return string The formatted output.
         */
        function smarty_modifier_appName.formatForDBFormatGeoData($string)
        {
            return number_format($string, 7, '.', '');
        }
    '''
}
