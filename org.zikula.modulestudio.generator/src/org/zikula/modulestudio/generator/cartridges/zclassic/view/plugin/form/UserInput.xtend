package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.form

import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class UserInput {
    extension FormattingExtensions = new FormattingExtensions()
    extension NamingExtensions = new NamingExtensions()
    extension Utils = new Utils()

    FileHelper fh = new FileHelper()

    def generate(Application it, IFileSystemAccess fsa) {
        generateClassPair(fsa, getAppSourceLibPath + 'Form/Plugin/UserInput.php',
            fh.phpFileContent(it, formUserInputBaseImpl), fh.phpFileContent(it, formUserInputImpl)
        )
        if (!shouldBeSkipped(viewPluginFilePath('function', 'UserInput'))) {
            fsa.generateFile(viewPluginFilePath('function', 'UserInput'), fh.phpFileContent(it, formUserInputPluginImpl))
        }
    }

    def private formUserInputBaseImpl(Application it) '''
        IF !targets('1.3.5')
            namespace appNamespace\Form\Plugin\Base;

            use DataUtil;
            use System;
            use UserUtil;
            use Zikula_Form_Plugin_TextInput;
            use Zikula_Form_View;
            use ZLanguage;

        ENDIF
        /**
         * User field plugin providing an autocomplete for user names.
         *
         * You can also use all of the features from the Zikula_Form_Plugin_TextInput plugin since
         * the user input inherits from it.
         */
        class IF targets('1.3.5')appName_Form_Plugin_Base_ENDIFUserInput extends Zikula_Form_Plugin_TextInput
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
                $params['maxLength'] = 25;

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

                return str_replace('z-form-text', 'z-form-userIF !targets('1.3.5') typeaheadENDIF', $class);
            }

            /**
             * Render event handler.
             *
             * @param Zikula_Form_View $view Reference to Zikula_Form_View object.
             *
             * @return string The rendered output
             */
            public function render(Zikula_Form_View $view)
            {
                $dom = ZLanguage::getModuleDomain('appName');

                //$result = parent::render($view);
                $result = '';

                // start code from TextInput base class
                $titleHtml = ($this->toolTip != null ? ' title="' . $view->translateForDisplay($this->toolTip) . '"' : '');
                $readOnlyHtml = ($this->readOnly ? ' readonly="readonly" tabindex="-1"' : '');
                $sizeHtml = ($this->size > 0 ? " size=\"{$this->size}\"" : '');
                $maxLengthHtml = ($this->maxLength > 0 ? " maxlength=\"{$this->maxLength}\"" : '');
                $class = $this->getStyleClass();

                $attributes = $this->renderAttributes($view);
                // end code from TextInput base class

                /*if ($this->readOnly) {
                    return $result;
                }*/

                $selectorDefaultValue = '';
                if (intval($this->text) > 0) {
                    $selectorDefaultValue = UserUtil::getVar('uname', intval($this->text));
                }

                $searchTitle = __('Search user', $dom);
                $selectorAttributes = $titleHtml . $sizeHtml . $maxLengthHtml . $readOnlyHtml . ' value="' . $selectorDefaultValue . '" class="' . $class . '"' . $attributes;
                IF targets('1.3.5')
                    $result = '<div id="' . $this->getId() . 'LiveSearch" class="appName.toLowerCase-livesearch-user appName.toLowerCase-autocomplete-user z-hide">
                            <img src="' . System::getBaseUrl() . 'images/icons/extrasmall/search.png" width="16" height="16" alt="' . $searchTitle . '" title="' . $searchTitle . '" />
                            <input type="text" id="' . $this->getId() . 'Selector" name="' . $this->getId() . 'Selector"' . $selectorAttributes . ' />
                            <img src="' . System::getBaseUrl() . 'images/ajax/indicator_circle.gif" width="16" height="16" alt="" id="' . $this->getId() . 'Indicator" style="display: none" />
                            <span id="' . $this->getId() . 'NoResultsHint" class="z-hide">' . __('No results found!', $dom) . '</span>
                            <div id="' . $this->getId() . 'SelectorChoices"></div>';
                ELSE
                    $result = '<div id="' . $this->getId() . 'LiveSearch" class="appName.toLowerCase-livesearch-user appName.toLowerCase-autocomplete-user hidden">
                            <i class="fa fa-search" title="' . $searchTitle . '"><i>';
                ENDIF

                if ($this->mandatory && $this->mandatorysym) {
                    $result .= '<span class="IF targets('1.3.5')z-form-mandatory-flagELSErequiresENDIF">*</span>';
                }

                $result .= '<noscript><p>' . __('This function requires JavaScript activated!', $dom) . '</p></noscript>' . "\n";
                IF targets('1.3.5')
                    $result .= '<input type="hidden" id="' . $this->getId() . '" name="' . $this->getId() . '" value="' . DataUtil::formatForDisplay($this->text) . '" />' . "\n";
                ELSE
                    $result .= '<input type="hidden" id="' . $this->getId() . '" name="' . $this->getId() . '" value="' . DataUtil::formatForDisplay($this->text) . '" />
                            <input type="text" id="' . $this->getId() . 'Selector" name="' . $this->getId() . 'Selector" autocomplete="off"' . $selectorAttributes . ' . ' />
                            <i class="fa fa-refresh fa-spin hidden" id="' . $this->getId() . 'Indicator"></i>
                            <span id="' . $this->getId() . 'NoResultsHint" class="hidden">' . __('No results found!', $dom) . '</span>';
                ENDIF
                $result .= '</div>' . "\n";

                return $result;
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
                if (empty($text)) {
                    return 0;//null;
                }

                return $text;
            }

            /**
             * Validates the input string.
             *
             * @param Zikula_Form_View $view Reference to Zikula_Form_View object.
             *
             * @return boolean
             */
            public function validate(Zikula_Form_View $view)
            {
                parent::validate($view);

                if (!$this->isValid) {
                    return;
                }

                if (strlen($this->text) > 0) {
                    $uid = intval($this->text);
                    if (UserUtil::getVar('uname', $uid) == null) {
                        $this->setError(__('Error! Invalid user.'));

                        return false;
                    }
                }
            }
        }
    '''

    def private formUserInputImpl(Application it) '''
        IF !targets('1.3.5')
            namespace appNamespace\Form\Plugin;

            use appNamespace\Form\Plugin\Base\UserInput as BaseUserInput;

        ENDIF
        /**
         * User field plugin providing an autocomplete for user names.
         *
         * You can also use all of the features from the Zikula_Form_Plugin_TextInput plugin since
         * the user input inherits from it.
         */
        IF targets('1.3.5')
        class appName_Form_Plugin_UserInput extends appName_Form_Plugin_Base_UserInput
        ELSE
        class UserInput extends BaseUserInput
        ENDIF
        {
            // feel free to add your customisation here
        }
    '''

    def private formUserInputPluginImpl(Application it) '''
        /**
         * The appName.formatForDBUserInput plugin handles fields carrying user ids.
         * It provides an autocomplete for user names.
         *
         * @param array            $params  All attributes passed to this function from the template.
         * @param Zikula_Form_View $view    Reference to the view object.
         *
         * @return string The output of the plugin.
         */
        function smarty_function_appName.formatForDBUserInput($params, $view)
        {
            return $view->registerPlugin('IF targets('1.3.5')appName_Form_Plugin_UserInputELSE\\vendor.formatForCodeCapital\\name.formatForCodeCapitalModule\\Form\\Plugin\\UserInputENDIF', $params);
        }
    '''
}
