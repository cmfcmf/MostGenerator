package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin

import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class GetFileSize {
    extension FormattingExtensions = new FormattingExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate(Application it, IFileSystemAccess fsa) {
        val pluginFilePath = viewPluginFilePath('modifier', 'GetFileSize')
        if (!shouldBeSkipped(pluginFilePath)) {
            fsa.generateFile(pluginFilePath, new FileHelper().phpFileContent(it, getFileSizeImpl))
        }
    }

    def private getFileSizeImpl(Application it) '''
        /**
         * The appName.formatForDBGetFileSize modifier displays the size of a given file in a readable way.
         *
         * @param integer $size     File size in bytes.
         * @param string  $filepath The input file path including file name (if file size is not known).
         * @param boolean $nodesc   If set to true the description will not be appended.
         * @param boolean $onlydesc If set to true only the description will be returned.
         *
         * @return string File size in a readable form.
         */
        function smarty_modifier_appName.formatForDBGetFileSize($size = 0, $filepath = '', $nodesc = false, $onlydesc = false)
        {
            if (!is_numeric($size)) {
                $size = (int) $size;
            }
            if (!$size) {
                if (empty($filepath) || !file_exists($filepath)) {
                    return '';
                }
                $size = filesize($filepath);
            }
            if (!$size) {
                return '';
            }

            $serviceManager = ServiceUtil::getManager();
            IF targets('1.3.5')
                $viewHelper = new appName_Util_View($serviceManager);
            ELSE
                $viewHelper = $serviceManager->get('appName.formatForDB.view_helper');
            ENDIF

            $result = $viewHelper->getReadableFileSize($size, $nodesc, $onlydesc);

            return $result;
        }
    '''
}
