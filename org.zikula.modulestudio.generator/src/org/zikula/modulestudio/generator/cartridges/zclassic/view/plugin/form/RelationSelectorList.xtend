package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.form

import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class RelationSelectorList {
    extension FormattingExtensions = new FormattingExtensions()
    extension NamingExtensions = new NamingExtensions()
    extension Utils = new Utils()

    FileHelper fh = new FileHelper()

    def generate(Application it, IFileSystemAccess fsa) {
        generateClassPair(fsa, getAppSourceLibPath + 'Form/Plugin/RelationSelectorList.php',
            fh.phpFileContent(it, relationSelectorBaseImpl), fh.phpFileContent(it, relationSelectorImpl)
        )
        if (!shouldBeSkipped(viewPluginFilePath('function', 'RelationSelectorList'))) {
            fsa.generateFile(viewPluginFilePath('function', 'RelationSelectorList'), fh.phpFileContent(it, relationSelectorPluginImpl))
        }
    }

    def private relationSelectorBaseImpl(Application it) '''
        IF !targets('1.3.5')
            namespace appNamespace\Form\Plugin\Base;

            use appNamespace\Form\Plugin\AbstractObjectSelector as BaseAbstractObjectSelector;

            use Zikula_Form_View;

        ENDIF
        /**
         * Relation selector plugin base class.
         */
        IF targets('1.3.5')
        class appName_Form_Plugin_Base_RelationSelectorList extends appName_Form_Plugin_AbstractObjectSelector
        ELSE
        class RelationSelectorList extends BaseAbstractObjectSelector
        ENDIF
        {
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
             * Load event handler.
             *
             * @param Zikula_Form_View $view    Reference to Zikula_Form_View object.
             * @param array            &$params Parameters passed from the Smarty plugin function.
             *
             * @return void
             */
            public function load(Zikula_Form_View $view, &$params)
            {
                $this->processRequestData($view, 'GET');

                // load list items
                parent::load($view, $params);

                // preprocess selection: collect id list for related items
                $this->preprocessIdentifiers($view, $params);
            }

            /**
             * Entry point for customised css class.
             */
            protected function getStyleClass()
            {
                return 'z-form-relationlist';
            }

            /**
             * Decode event handler.
             *
             * @param Zikula_Form_View $view Reference to Zikula_Form_View object.
             *
             * @return void
             */
            public function decode(Zikula_Form_View $view)
            {
                parent::decode($view);

                // postprocess selection: reinstantiate objects for identifiers
                $this->processRequestData($view, 'POST');
            }
        }
    '''

    def private relationSelectorImpl(Application it) '''
        IF !targets('1.3.5')
            namespace appNamespace\Form\Plugin;

            use appNamespace\Form\Plugin\Base\RelationSelectorList as BaseRelationSelectorList;

        ENDIF
        /**
         * Relation selector plugin implementation class.
         */
        IF targets('1.3.5')
        class appName_Form_Plugin_RelationSelectorList extends appName_Form_Plugin_Base_RelationSelectorList
        ELSE
        class RelationSelectorList extends BaseRelationSelectorList
        ENDIF
        {
            // feel free to add your customisation here
        }
    '''

    def private relationSelectorPluginImpl(Application it) '''
        /**
         * The appName.formatForDBRelationSelectorList plugin provides a dropdown selector for related items.
         *
         * @param  array            $params All attributes passed to this function from the template.
         * @param  Zikula_Form_View $view   Reference to the view object.
         *
         * @return string The output of the plugin.
         */
        function smarty_function_appName.formatForDBRelationSelectorList($params, $view)
        {
            return $view->registerPlugin('IF targets('1.3.5')appName_Form_Plugin_RelationSelectorListELSE\\vendor.formatForCodeCapital\\name.formatForCodeCapitalModule\\Form\\Plugin\\RelationSelectorListENDIF', $params);
        }
    '''
}
