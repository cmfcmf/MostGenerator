package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.form

import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Frame {
    extension FormattingExtensions = new FormattingExtensions()
    extension NamingExtensions = new NamingExtensions()
    extension Utils = new Utils()

    FileHelper fh = new FileHelper()

    def generate(Application it, IFileSystemAccess fsa) {
        var fileName = 'Form/Plugin/FormFrame.php'
        if (!shouldBeSkipped(getAppSourceLibPath + fileName)) {
            if (shouldBeMarked(getAppSourceLibPath + fileName)) {
                fileName = 'Form/Plugin/FormFrame.generated.php'
            }
            fsa.generateFile(getAppSourceLibPath + fileName, fh.phpFileContent(it, formFrameImpl))
        }
        if (!shouldBeSkipped(viewPluginFilePath('block', 'FormFrame'))) {
            fsa.generateFile(viewPluginFilePath('block', 'FormFrame'), fh.phpFileContent(it, formFramePluginImpl))
        }
    }

    def private formFrameImpl(Application it) '''
        IF !targets('1.3.5')
            namespace appNamespace\Form\Plugin;

            use Zikula_Form_AbstractPlugin;
            use Zikula_Form_View;

        ENDIF
        /**
         * Wrapper class for styling <div> elements and a validation summary.
         */
        class IF targets('1.3.5')appName_Form_Plugin_ENDIFFormFrame extends Zikula_Form_AbstractPlugin
        {
            /**
             * Whether a tabbed panel should be used or not.
             *
             * @var boolean
             */
            public $useTabs;

            /**
             * Name of css class to be used for the frame element.
             *
             * @var string
             */
            public $cssClass = 'tabs';

            /**
             * Get filename of this file.
             * The information is used to re-establish the plugins on postback.
             *
             * @return string
             */
            public function getFilename()
            {
                return __FILE__;
            }

            /**
             * Create event handler.
             *
             * This fires once, immediately <i>after</i> member variables have been populated from Smarty parameters
             * (in {@link readParameters()}). Default action is to do nothing.
             *
             * @see Zikula_Form_View::registerPlugin()
             *
             * @param Zikula_Form_View $view    Reference to Zikula_Form_View object.
             * @param array            &$params Parameters passed from the Smarty plugin function.
             *
             * @see    Zikula_Form_AbstractPlugin
             * @return void
             */
            public function create(Zikula_Form_View $view, &$params)
            {
                $this->useTabs = array_key_exists('useTabs', $params) ? $params['useTabs'] : false;
            }

            /**
             * RenderBegin event handler.
             *
             * Default action is to return an empty string.
             *
             * @param Zikula_Form_View $view Reference to Zikula_Form_View object.
             *
             * @return string The rendered output.
             */
            public function renderBegin(Zikula_Form_View $view)
            {
                $tabClass = $this->useTabs ? ' ' . $this->cssClass : '';

                return '<div class="appName.toLowerCase-form' . $tabClass . '">' . "\n";
            }

            /**
             * RenderEnd event handler.
             *
             * Default action is to return an empty string.
             *
             * @param Zikula_Form_View $view Reference to Zikula_Form_View object.
             *
             * @return string The rendered output.
             */
            public function renderEnd(Zikula_Form_View $view)
            {
                return '</div>' . "\n";
            }
        }
    '''

    def private formFramePluginImpl(Application it) '''
        /**
         * The appName.formatForDBFormFrame plugin adds styling <div> elements and a validation summary.
         *
         * Available parameters:
         *   - assign:   If set, the results are assigned to the corresponding variable instead of printed out.
         *
         * @param array            $params  All attributes passed to this function from the template.
         * @param string           $content The content of the block.
         * @param Zikula_Form_View $view    Reference to the view object.
         *
         * @return string The output of the plugin.
         */
        function smarty_block_appName.formatForDBFormFrame($params, $content, $view)
        {
            // As with all Forms plugins, we must remember to register our plugin.
            // In this case we also register a validation summary so we don't have to
            // do that explicitively in the templates.

            // We need to concatenate the output of boths plugins.
            $result = $view->registerPlugin('\\Zikula_Form_Plugin_ValidationSummary', $params);
            $result .= $view->registerBlock('IF targets('1.3.5')appName_Form_Plugin_FormFrameELSE\\vendor.formatForCodeCapital\\name.formatForCodeCapitalModule\\Form\\Plugin\\FormFrameENDIF', $params, $content);

            return $result;
        }
    '''
}
