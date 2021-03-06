package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.form

import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class GeoInput {
    extension FormattingExtensions = new FormattingExtensions()
    extension NamingExtensions = new NamingExtensions()
    extension Utils = new Utils()

    FileHelper fh = new FileHelper()

    def generate(Application it, IFileSystemAccess fsa) {
        generateClassPair(fsa, getAppSourceLibPath + 'Form/Plugin/GeoInput.php',
            fh.phpFileContent(it, formGeoInputBaseImpl), fh.phpFileContent(it, formGeoInputImpl)
        )
        if (!shouldBeSkipped(viewPluginFilePath('function', 'GeoInput'))) {
            fsa.generateFile(viewPluginFilePath('function', 'GeoInput'), fh.phpFileContent(it, formGeoInputPluginImpl))
        }
    }

    def private formGeoInputBaseImpl(Application it) '''
        IF !targets('1.3.5')
            namespace appNamespace\Form\Plugin\Base;

            use Zikula_Form_Plugin_TextInput;
            use Zikula_Form_View;

        ENDIF
        /**
         * Geo value input.
         *
         * You can also use all of the features from the Zikula_Form_Plugin_TextInput plugin since
         * the geo input inherits from it.
         */
        class IF targets('1.3.5')appName_Form_Plugin_Base_ENDIFGeoInput extends Zikula_Form_Plugin_TextInput
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
             * Create event handler.
             *
             * @param Zikula_Form_View $view    Reference to Zikula_Form_View object.
             * @param array            &$params Parameters passed from the Smarty plugin function.
             *
             * @see    Zikula_Form_AbstractPlugin
             * @return void
             */
            public function create(Zikula_Form_View $view, &$params)
            {
                $params['maxLength'] = 11;
                $params['width'] = '6em';

                // let parent plugin do the work in detail
                parent::create($view, $params);
            }

            /**
             * Helper method to determine css class.
             *
             * @see Zikula_Form_Plugin_TextInput
             *
             * @return string the list of css classes to apply
             */
            protected function getStyleClass()
            {
                $class = parent::getStyleClass();
                return str_replace('z-form-text', 'z-form-geo', $class);
            }

            /**
             * Validates the input.
             *
             * @param Zikula_Form_View $view Reference to Zikula_Form_View object.
             *
             * @return void
             */
            public function validate(Zikula_Form_View $view)
            {
                parent::validate($view);

                if (!$this->isValid) {
                    return;
                }

                if ($this->text !== '') {
                    $this->text = number_format($this->text, 7, '.', '');
                    if (!is_numeric($this->text)) {
                        $this->setError(__('Error! Invalid number.'));
                    }
                }
            }

            /**
             * Parses a value.
             *
             * @param Zikula_Form_View $view Reference to Zikula_Form_View object.
             * @param string           $text Text.
             *
             * @return string Parsed Text.
             */
            public function parseValue(Zikula_Form_View $view, $text)
            {
                if ($text === '') {
                    return null;
                }

                // process float value
                $text = floatval($text);

                return $text;
            }

            /**
             * Format the value to specific format.
             *
             * @param Zikula_Form_View $view  Reference to Zikula_Form_View object.
             * @param string           $value The value to format.
             *
             * @return string Formatted value.
             */
            public function formatValue(Zikula_Form_View $view, $value)
            {
                return number_format($value, 7, '.', '');
            }
        }
    '''

    def private formGeoInputImpl(Application it) '''
        IF !targets('1.3.5')
            namespace appNamespace\Form\Plugin;

            use appNamespace\Form\Plugin\Base\GeoInput as BaseGeoInput;

        ENDIF
        /**
         * Geo value input.
         *
         * You can also use all of the features from the Zikula_Form_Plugin_TextInput plugin since
         * the geo input inherits from it.
         */
        IF targets('1.3.5')
        class appName_Form_Plugin_GeoInput extends appName_Form_Plugin_Base_GeoInput
        ELSE
        class GeoInput extends BaseGeoInput
        ENDIF
        {
            // feel free to add your customisation here
        }
    '''

    def private formGeoInputPluginImpl(Application it) '''
        /**
         * The appName.formatForDBGeoInput plugin handles fields carrying geo data.
         *
         * @param  array            $params All attributes passed to this function from the template.
         * @param  Zikula_Form_View $view   Reference to the view object.
         *
         * @return string The output of the plugin.
         */
        function smarty_function_appName.formatForDBGeoInput($params, $view)
        {
            return $view->registerPlugin('IF targets('1.3.5')appName_Form_Plugin_GeoInputELSE\\vendor.formatForCodeCapital\\name.formatForCodeCapitalModule\\Form\\Plugin\\GeoInputENDIF', $params);
        }
    '''
}
