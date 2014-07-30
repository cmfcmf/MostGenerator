package org.zikula.modulestudio.generator.cartridges.zclassic.view

import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Styles {
    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    String cssPrefix

    /**
     * Entry point for application styles.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        cssPrefix = appName.toLowerCase
        var fileName = 'style.css'
        if (!shouldBeSkipped(getAppCssPath + fileName)) {
            if (shouldBeMarked(getAppCssPath + fileName)) {
                fileName = 'style.generated.css'
            }
            fsa.generateFile(getAppCssPath + fileName, appStyles)
        }
        fileName = 'finder.css'
        if (generateExternalControllerAndFinder && !shouldBeSkipped(getAppCssPath + fileName)) {
            if (shouldBeMarked(getAppCssPath + fileName)) {
                fileName = 'finder.generated.css'
            }
            fsa.generateFile(getAppCssPath + fileName, finderStyles)
        }
    }

    def private appStyles(Application it) '''
        /* view pages */
        div#z-maincontent.z-module-name.formatForDB table tbody tr td {
            vertical-align: top;
        }

        /* display pages */
        .cssPrefix-display.with-rightbox div.IF targets('1.3.5')z-panel-contentELSEpanelENDIF {
            float: left;
            width: 79%;
        }
        .cssPrefix-display div.cssPrefix-rightbox {
            float: right;
            margin: 0 1em;
            padding: .5em;
            width: 20%;
            /*border: 1px solid #666;*/
        }

        .cssPrefix-display div.cssPrefix-rightbox h3 {
            color: #333;
            font-weight: 400;
            border-bottom: 1px solid #ccc;
            padding-bottom: 8px;
        }

        .cssPrefix-display div.cssPrefix-rightbox p.managelink {
            margin-left: 18px;
        }
        IF hasGeographical

            div.cssPrefix-mapcontainer {
                height: 400px;
            }
        ENDIF
        IF hasTrees

            .IF targets('1.3.5')z-ENDIFtree-container {
                border: 1px solid #ccc;
                width: 400px;
                float: left;
                margin-right: 16px;
            }
        ENDIF
        IF hasColourFields

            .cssPrefixColourPicker {
                cursor: pointer;
            }
        ENDIF
        validationStyles
        autoCompletion
        viewFilterForm
        IF interactiveInstallation

            dl#appName.toFirstLowerFeatureList {
                margin-left: 50px;
            }
            dl#appName.toFirstLowerFeatureList dt {
                font-weight: 700;
            }
        ENDIF
    '''

    def private validationStyles(Application it) '''
        /* validation */
        div.fieldGroupClass input.required, div.fieldGroupClass textarea.required {
            border: 1px solid #00a8e6;
        }
        IF targets('1.3.5')
            div.fieldGroupClass input.validation-failed, div.fieldGroupClass textarea.validation-failed {
                border: 1px solid #f30;
                color: #f30;
            }
            div.fieldGroupClass input.validation-passed, div.fieldGroupClass textarea.validation-passed {
                border: 1px solid #0c0;
                color: #000;
            }
        ENDIF

        .validation-advice {
            margin: 5px 0;
            padding: 5px;
            background-color: #f90;
            color: #fff;
            font-weight: 700;
        }
    '''

    def private fieldGroupClass(Application it) '''IF targets('1.3.5')z-formrowELSEform-groupENDIF'''

    def private autoCompletion(Application it) '''
        val hasUserFields = hasUserFields
        val hasImageFields = hasImageFields
        val joinRelations = getJoinRelations
        IF !joinRelations.empty || hasUserFields

            /* edit pages */
            IF targets('1.3.5')/* fix for #413 */
                form.z-form select.z-form-dropdownlist,
                form.z-form input.z-form-upload {
                    float: left;
                }
            ENDIF
            IF !joinRelations.empty
                div.cssPrefix-relation-leftside {
                    float: left;
                    width: 25%;
                }

                div.cssPrefix-relation-rightside {
                    float: right;
                    width: 65%;
                }

            ENDIF
            /* hide legends if z-panels are used as both contain the same labels */
            div.name.formatForDB-edit .IF targets('1.3.5')z-panel-contentELSEpanelENDIF legend {
                display: none;
            }

            IF targets('1.3.5')
                IF hasUserFields
                    div.cssPrefix-livesearch-user {
                        margin: 0;
                    }

                ENDIF

                div.cssPrefix-autocompleteIF hasUserFields,
                div.cssPrefix-autocomplete-userENDIFIF hasImageFields,
                div.cssPrefix-autocomplete-withimageENDIF {
                    position: relative !important;
                    top: 2px !important;
                    width: 191px !important;
                    background-color: #fff;
                    border: 1px solid #888;
                    margin: 0;
                    padding: 0;
                }

                div.cssPrefix-autocompleteIF hasImageFields,
                div.cssPrefix-autocomplete-with-imageENDIF {
                    left: 0 !important;
                }
                IF hasUserFields
                    div.cssPrefix-autocomplete-user {
                        left: 29% !important;
                    }

                ENDIF
                div.cssPrefix-autocomplete ulIF hasUserFields,
                div.cssPrefix-autocomplete-user ulENDIFIF hasImageFields,
                div.cssPrefix-autocomplete-with-image ulENDIF {
                    margin: 0;
                    padding: 0;
                }
            ENDIF

            div.cssPrefix-autocomplete ul liIF hasUserFields,
            div.cssPrefix-autocomplete-user ul liENDIFIF hasImageFields,
            div.cssPrefix-autocomplete-with-image ul liENDIF {
                margin: 0;
                padding: 0.2em 0 0.2em 20px;
                list-style-type: none;
                line-height: 1.4em;
                cursor: pointer;
                display: block;
                background-position: 2px 2px;
                background-repeat: no-repeat;
            }

            div.cssPrefix-autocomplete ul li {
                background-image: url("../../../images/icons/extrasmall/tab_right.png");
            }
            IF hasUserFields
                div.cssPrefix-autocomplete-user ul li {
                    background-image: url("../../../images/icons/extrasmall/user.png");
                }
            ENDIF
            IF hasImageFields
                div.cssPrefix-autocomplete-with-image ul li {
                    background-image: url("../../../images/icons/extrasmall/agt_Multimedia.png");
                }
            ENDIF

            div.cssPrefix-autocomplete ul li.selectedIF hasUserFields,
            div.cssPrefix-autocomplete-user ul li.selectedENDIFIF hasImageFields,
            div.cssPrefix-autocomplete-with-image ul li.selectedENDIF {
                background-color: #ffb;
            }

            IF hasImageFields || !joinRelations.empty
                div.cssPrefix-autocomplete ul li div.itemtitleIF hasImageFields,
                div.cssPrefix-autocomplete-with-image ul li div.itemtitleENDIF {
                    font-weight: 700;
                    font-size: 12px;
                    line-height: 1.2em;
                }
                div.cssPrefix-autocomplete ul li div.itemdescIF hasImageFields,
                div.cssPrefix-autocomplete-with-image ul li div.itemdescENDIF {
                    font-size: 10px;
                    color: #888;
                }
                IF !joinRelations.empty

                    button.cssPrefix-inline-button {
                        margin-top: 1em;
                    }
                ENDIF
            ENDIF

        ENDIF
    '''

    def private viewFilterForm(Application it) '''
        IF !getAllControllers.filter[hasActions('view')].empty
            div.cssPrefix-view form.cssPrefix-quicknav {
                margin: 10px 0;
                padding: 8px 12px;
                border: 1px solid #ccc;
            }

            div.cssPrefix-view form.cssPrefix-quicknav fieldset {
                padding: 3px 10px;
                margin-bottom: 0;
            }

            div.cssPrefix-view form.cssPrefix-quicknav fieldset h3 {
                margin-top: 0;
                display: none;
            }

            div.cssPrefix-view form.cssPrefix-quicknav fieldset #num {
                width: 50px;
                text-align: right;
            }
        ENDIF
    '''

    def private finderStyles(Application it) '''
        body {
            background-color: #ddd;
            margin: 10px;
            text-align: left;
        }

        .cssPrefix-finderform fieldset,
        .cssPrefix-finderform fieldset legend {
            background-color: #fff;
            border: none;
        }

        #cssPrefixItemContainer {
            background-color: #eee;
            height: 300px;
            overflow: auto;
            padding: 5px;
        }

        #cssPrefixItemContainer ul {
            list-style: none;
            margin: 0;
            padding: 0;
        }

        #cssPrefixItemContainer a {
            color: #000;
            margin: 0.1em 0.2em;
            text-decoration: underline;
        }
        #cssPrefixItemContainer a:hover,
        #cssPrefixItemContainer a:focus,
        #cssPrefixItemContainer a:active {
            color: #900;
            text-decoration: none;
        }

        #cssPrefixItemContainer a img {
            border: none;
        }

        #cssPrefixItemContainer a img {
            border: 1px solid #ccc;
            background-color: #f5f5f5;
            padding: 0.5em;
        }
        #cssPrefixItemContainer a:hover img,
        #cssPrefixItemContainer a:focus img,
        #cssPrefixItemContainer a:active img {
            background-color: #fff;
        }
    '''
}
