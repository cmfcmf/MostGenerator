package org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.Entity
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import de.guite.modulestudio.metamodel.modulestudio.DerivedField
import de.guite.modulestudio.metamodel.modulestudio.BooleanField
import de.guite.modulestudio.metamodel.modulestudio.JoinRelationship

class DisplayFunctions {
    @Inject extension ControllerExtensions = new ControllerExtensions()
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension ModelExtensions = new ModelExtensions()
    @Inject extension ModelJoinExtensions = new ModelJoinExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension Utils = new Utils()

    /**
     * Entry point for the javascript file with display functionality.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        println('Generating javascript for display functions')
        fsa.generateFile(getAppSourcePath(appName) + 'javascript/' + appName + '.js', generate)
    }

    def private generate(Application it) '''

        «initItemActions»

        «IF !getAllControllers.map(e|e.hasActions('view')).isEmpty»
            «initQuickNavigation»
        «ENDIF»
        «IF !getJoinRelations.isEmpty»
            «initRelationWindow»
        «ENDIF»
        «IF hasBooleansWithAjaxToggle»
            «initToggle»
            «toggleFlag»
        «ENDIF»
    '''

    def private initItemActions(Application it) '''
        /**
         * Initialises the context menu for item actions.
         */
        function «prefix»InitItemActions(objectType, func, containerId)
        {
            var triggerId = containerId + 'trigger';
            // attach context menu
            var contextMenu = new Control.ContextMenu(triggerId, { leftClick: true, animation: false });

            // process normal links
            $$('#' + containerId + ' a').each(function(elem) {
                // hide it
                elem.hide();
                // determine the link text
                var linkText = '';
                if (func == 'display') {
                    linkText = elem.innerHTML;
                } else if (func == 'view') {
                    elem.select('img').each(function(imgElem) {
                        linkText = imgElem.readAttribute('alt');
                    });
                }

                // determine the icon
                var iconFile = '';
                if (func == 'display') {
                    if (elem.hasClassName('z-icon-es-preview')) {
                        iconFile = 'xeyes.png';
                    } else if (elem.hasClassName('z-icon-es-display')) {
                        iconFile = 'kview.png';
                    } else if (elem.hasClassName('z-icon-es-edit')) {
                        iconFile = 'edit';
                    } else if (elem.hasClassName('z-icon-es-saveas')) {
                        iconFile = 'filesaveas';
                    } else if (elem.hasClassName('z-icon-es-delete')) {
                        iconFile = '14_layer_deletelayer';
                    } else if (elem.hasClassName('z-icon-es-back')) {
                        iconFile = 'agt_back';
                    }
                    if (iconFile != '') {
                        iconFile = '/images/icons/extrasmall/' + iconFile + '.png';
                    }
                } else if (func == 'view') {
                    elem.select('img').each(function(imgElem) {
                        iconFile = imgElem.readAttribute('src');
                    });
                }
                if (iconFile != '') {
                    iconFile = '<img src="' + iconFile + '" width="16" height="16" alt="' + linkText + '" /> ';
                }

                contextMenu.addItem({
                    label: iconFile + linkText,
                    callback: function() {
                        window.location = elem.readAttribute('href');
                    }
                });
            });
            $(triggerId).show();
        }
    '''

    def private initQuickNavigation(Application it) '''
        function «prefix»CapitaliseFirstLetter(string)
        {
            return string.charAt(0).toUpperCase() + string.slice(1);
        }

        /**
         * Initialise the quick navigation panel in list views.
         */
        function «prefix»InitQuickNavigation(objectType, controller)
        {
            if ($('«prefix»' + «prefix»CapitaliseFirstLetter(objectType) + 'QuickNavForm') == undefined) {
                return;
            }

            if ($('catid') != undefined) {
                $('catid').observe('change', «initQuickNavigationSubmitCall(prefix)»);
            }
            if ($('sortby') != undefined) {
                $('sortby').observe('change', «initQuickNavigationSubmitCall(prefix)»);
            }
            if ($('sortdir') != undefined) {
                $('sortdir').observe('change', «initQuickNavigationSubmitCall(prefix)»);
            }
            if ($('num') != undefined) {
                $('num').observe('change', «initQuickNavigationSubmitCall(prefix)»);
            }

            switch (objectType) {
            «FOR entity : getAllEntities»
                «entity.initQuickNavigationEntity»
            «ENDFOR»
            }
        }

        /**
         * Submits a quick navigation form.
         */
        function «prefix»SubmitQuickNavForm(objectType)
        {
            $('«prefix»' + «prefix»CapitaliseFirstLetter(objectType) + 'QuickNavForm').submit();
        }
    '''

    def private initQuickNavigationSubmitCall(String prefix) '''function() { «prefix»SubmitQuickNavForm(objectType); }'''

    def private initQuickNavigationEntity(Entity it) '''
        case '«name.formatForCode»':
                    «IF !getBidirectionalIncomingJoinRelationsWithOneSource.isEmpty»
                        «FOR relation: getBidirectionalIncomingJoinRelationsWithOneSource»
                            «relation.jsInit»
                        «ENDFOR»
                    «ENDIF»
                    «IF hasListFieldsEntity»
                        «FOR field : getListFieldsEntity»
                            «field.jsInit»
                        «ENDFOR»
                    «ENDIF»
                    «IF hasUserFieldsEntity»
                        «FOR field : getUserFieldsEntity»
                            «field.jsInit»
                        «ENDFOR»
                    «ENDIF»
                    «IF hasCountryFieldsEntity»
                        «FOR field : getCountryFieldsEntity»
                            «field.jsInit»
                        «ENDFOR»
                    «ENDIF»
                    «IF hasLanguageFieldsEntity»
                        «FOR field : getLanguageFieldsEntity»
                            «field.jsInit»
                        «ENDFOR»
                    «ENDIF»
                    «IF hasBooleanFieldsEntity»
                        «FOR field : getBooleanFieldsEntity»
                            «field.jsInit»
                        «ENDFOR»
                    «ENDIF»
                    break;
    '''

    def private dispatch jsInit(DerivedField it) '''
        if ($('«name.formatForCode»') != undefined) {
            $('«name.formatForCode»').observe('change', «initQuickNavigationSubmitCall(entity.container.application.prefix)»);
        }
    '''

    def private dispatch jsInit(BooleanField it) '''
        if ($('«name.formatForCode»') != undefined) {
            $('«name.formatForCode»').observe('click', «initQuickNavigationSubmitCall(entity.container.application.prefix)»)
                                     .observe('keypress', «initQuickNavigationSubmitCall(entity.container.application.prefix)»);
        }
    '''

    def private dispatch jsInit(JoinRelationship it) '''
        «val sourceAliasName = getRelationAliasName(false).formatForCodeCapital»
        if ($('«sourceAliasName»') != undefined) {
            $('«sourceAliasName»').observe('change', «initQuickNavigationSubmitCall(container.application.prefix)»);
        }
    '''

    def private initRelationWindow(Application it) '''
        /**
         * Helper function to create new Zikula.UI.Window instances.
         * For edit forms we use "iframe: true" to ensure file uploads work without problems.
         * For all other windows we use "iframe: false" because we want the escape key working.
         */
        function «prefix»InitInlineWindow(containerElem, title)
        {
            // show the container (hidden for users without JavaScript)
            containerElem.show();

            // define the new window instance
            var newWindow = new Zikula.UI.Window(
                containerElem,
                {
                    minmax: true,
                    resizable: true,
                    title: title,
                    width: 600,
                    initMaxHeight: 400,
                    modal: false,
                    iframe: false
                }
            );

            // return the instance
            return newWindow;
        }

    '''

    def private initToggle(Application it) '''
        /**
         * Initialise ajax-based toggle for boolean fields.
         */
        function «prefix»InitToggle(objectType, fieldName, itemId)
        {
            var idSuffix = fieldName.toLowerCase() + itemId;
            if ($('toggle' + idSuffix) == undefined) {
                return;
            }
            $('toggle' + idSuffix).observe('click', function() {
                «prefix»ToggleFlag(objectType, fieldName, itemId);
            }).show();
        }

    '''

    def private toggleFlag(Application it) '''
        /**
         * Toggle a certain flag for a given item.
         */
        function «prefix»ToggleFlag(objectType, fieldName, itemId)
        {
            var pars = 'ot=' + objectType + '&field=' + fieldName + '&id=' + itemId;

            new Zikula.Ajax.Request(
                Zikula.Config.baseURL + 'ajax.php?module=«appName»&func=toggleFlag',
                {
                    method: 'post',
                    parameters: pars,
                    onComplete: function(req) {
                        if (!req.isSuccess()) {
                            Zikula.UI.Alert(req.getMessage(), Zikula.__('Error', 'module_«appName»'));
                            return;
                        }
                        var data = req.getData();
                        /*if (data.message) {
                            Zikula.UI.Alert(data.message, Zikula.__('Success', 'module_«appName»'));
                        }*/

                        var idSuffix = fieldName.toLowerCase() + '_' + itemId;
                        var state = data.state;
                        if (state === true) {
                            $('no' + idSuffix).hide();
                            $('yes' + idSuffix).show();
                        } else {
                            $('yes' + idSuffix).hide();
                            $('no' + idSuffix).show();
                        }
                    }
                }
            );
        }
    '''
}