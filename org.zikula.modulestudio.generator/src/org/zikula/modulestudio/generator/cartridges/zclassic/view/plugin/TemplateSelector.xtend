package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class TemplateSelector {
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension Utils = new Utils()

    def generate(Application it, IFileSystemAccess fsa) {
        fsa.generateFile(viewPluginFilePath('function', 'TemplateSelector'), selectorTemplatesFile)
    }

    def private selectorTemplatesFile(Application it) '''
    	«new FileHelper().phpFileHeader(it)»
    	«selectorTemplatesImpl»
    '''

    def private selectorTemplatesImpl(Application it) '''
        /**
         * The «appName.formatForDB»TemplateSelector plugin provides items for a dropdown selector.
         *
         * Available parameters:
         *   - assign: If set, the results are assigned to the corresponding variable instead of printed out.
         *
         * @param  array            $params All attributes passed to this function from the template.
         * @param  Zikula_Form_View $view   Reference to the view object.
         *
         * @return string The output of the plugin.
         */
        function smarty_function_«appName.formatForDB»TemplateSelector($params, $view)
        {
            $result = array();

            $result[] = array('text' => $view->__('Only item titles'), 'value' => 'itemlist_display.tpl');
            $result[] = array('text' => $view->__('With description'), 'value' => 'itemlist_display_description.tpl');
            $result[] = array('text' => $view->__('Custom template'), 'value' => 'custom');

            if (array_key_exists('assign', $params)) {
                $view->assign($params['assign'], $result);

                return;
            }

            return $result;
        }
    '''
}