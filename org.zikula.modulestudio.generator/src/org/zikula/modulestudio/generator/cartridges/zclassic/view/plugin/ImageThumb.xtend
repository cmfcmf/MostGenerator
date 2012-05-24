package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ImageThumb {
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension ModelExtensions = new ModelExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension Utils = new Utils()

    def generate(Application it, IFileSystemAccess fsa) {
    	if (hasUploads)
            fsa.generateFile(viewPluginFilePath('modifier', 'ImageThumb'), imageThumbFile)
    }

    def private imageThumbFile(Application it) '''
    	«new FileHelper().phpFileHeader(it)»
    	«imageThumbImpl»
    '''

    def private imageThumbImpl(Application it) '''
        /**
         * The «appName.formatForDB»ImageThumb modifier displays a thumbnail image.
         *
         * @param  string $fileName  The input file name.
         * @param  string $filePath  The input file path (including file name).
         * @param  int    $width     Desired width.
         * @param  int    $height    Desired height.
         * @param  array  $thumbArgs Additional arguments.
         *
         * @return string The thumbnail file path.
         */
        function smarty_modifier_«appName.formatForDB»ImageThumb($fileName = '', $filePath = '', $width = 100, $height = 80, $thumbArgs = array())
        {
            /**
             * By overriding this plugin or the util method called below you may add further thumbnail arguments
             * based on custom conditions.
             */
            return «appName»_Util_Image::getThumb($filePath, $width, $height, $thumbArgs);
        }
    '''
}