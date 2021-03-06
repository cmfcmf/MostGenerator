package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import de.guite.modulestudio.metamodel.modulestudio.Application
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions

class ThirdParty {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils
    extension WorkflowExtensions = new WorkflowExtensions

    CommonExample commonExample = new CommonExample()

    def generate(Application it, Boolean isBase) '''
        val needsDetailContentType = generateDetailContentType && hasUserController && getMainUserController.hasActions('display')
        IF !targets('1.3.5')
            /**
             * Makes our handlers known to the event system.
             */
            public static function getSubscribedEvents()
            {
                IF isBase
                    return array(IF generatePendingContentSupport
                        'get.pending_content'                   => array('pendingContentListener', 5),ENDIFIF generateListContentType || needsDetailContentType
                        'module.content.gettypes'               => array('contentGetTypes', 5),ENDIFIF generateScribitePlugins
                        'module.scribite.editorhelpers'         => array('getEditorHelpers', 5),
                        'moduleplugin.tinymce.externalplugins'  => array('getTinyMcePlugins', 5),
                        'moduleplugin.ckeditor.externalplugins' => array('getCKEditorPlugins', 5)ENDIF
                    );
                ELSE
                    return parent::getSubscribedEvents();
                ENDIF
            }

        ENDIF
        IF generatePendingContentSupport
            pendingContentListener(isBase)
        ENDIF
        IF generateListContentType || needsDetailContentType

            contentGetTypes(isBase)
        ENDIF
        IF !targets('1.3.5')
            IF generateScribitePlugins

                getEditorHelpers(isBase)

                getTinyMcePlugins(isBase)

                getCKEditorPlugins(isBase)
            ENDIF
        ENDIF
    '''

    def private pendingContentListener(Application it, Boolean isBase) '''
        /**
         * Listener for the 'get.pending_content' event with registration requests and
         * other submitted data pending approval.
         *
         * When a 'get.pending_content' event is fired, the Users module will respond with the
         * number of registration requests that are pending administrator approval. The number
         * pending may not equal the total number of outstanding registration requests, depending
         * on how the 'moderation_order' module configuration variable is set, and whether e-mail
         * address verification is required.
         * If the 'moderation_order' variable is set to require approval after e-mail verification
         * (and e-mail verification is also required) then the number of pending registration
         * requests will equal the number of registration requested that have completed the
         * verification process but have not yet been approved. For other values of
         * 'moderation_order', the number should equal the number of registration requests that
         * have not yet been approved, without regard to their current e-mail verification state.
         * If moderation of registrations is not enabled, then the value will always be 0.
         * In accordance with the 'get_pending_content' conventions, the count of pending
         * registrations, along with information necessary to access the detailed list, is
         * assemped as a {@link Zikula_Provider_AggregateItem} and added to the event
         * subject's collection.
         *
         * @param IF targets('1.3.5')Zikula_EventELSEGenericEventENDIF $event The event instance.
         */
        public IF targets('1.3.5')static ENDIFfunction pendingContentListener(IF targets('1.3.5')Zikula_EventELSEGenericEventENDIF $event)
        {
            IF !isBase
                parent::pendingContentListener($event);

                commonExample.generalEventProperties(it)
            ELSE
                pendingContentListenerImpl
            ENDIF
        }
    '''

    def private pendingContentListenerImpl(Application it) '''
        IF !needsApproval
            // nothing required here as no entities use enhanced workflows including approval actions
        ELSEIF !generatePendingContentSupport
            // pending content support is disabled in generator settings
            // however, we keep this empty stub to prevent errors if the event handler
            // was already registered before
        ELSE
            $serviceManager = ServiceUtil::getManager();
            IF targets('1.3.5')
                $workflowHelper = new appName_Util_Workflow($this->serviceManager);
            ELSE
                $workflowHelper = $serviceManager->get('appName.formatForDB.workflow_helper');
            ENDIF

            $modname = 'appName';
            $useJoins = false;

            $collection = new IF targets('1.3.5')Zikula_Collection_ENDIFContainer($modname);
            $amounts = $workflowHelper->collectAmountOfModerationItems();
            if (count($amounts) > 0) {
                foreach ($amounts as $amountInfo) {
                    $aggregateType = $amountInfo['aggregateType'];
                    $description = $amountInfo['description'];
                    $amount = $amountInfo['amount'];
                    $viewArgs = array('ot' => $amountInfo['objectType'],
                                      'workflowState' => $amountInfo['state']);
                    $aggregateItem = new IF targets('1.3.5')Zikula_Provider_ENDIFAggregateItem($aggregateType, $description, $amount, 'admin', 'view', $viewArgs);
                    $collection->add($aggregateItem);
                }

                // add collected items for pending content
                if ($collection->count() > 0) {
                    $event->getSubject()->add($collection);
                }
            }
        ENDIF
    '''

    def private contentGetTypes(Application it, Boolean isBase) '''
        /**
         * Listener for the `module.content.gettypes` event.
         *
         * This event occurs when the Content module is 'searching' for Content plugins.
         * The subject is an instance of Content_Types.
         * You can register custom content types as well as custom layout types.
         *
         * @param IF targets('1.3.5')Zikula_EventELSEGenericEventENDIF $event The event instance.
         */
        public IF targets('1.3.5')static ENDIFfunction contentGetTypes(IF targets('1.3.5')Zikula_EventELSEGenericEventENDIF $event)
        {
            IF !isBase
                parent::contentGetTypes($event);

                commonExample.generalEventProperties(it)
            ELSE
                contentGetTypesImpl
            ENDIF
        }
    '''

    def private contentGetTypesImpl(Application it) '''
        // intended is using the add() method to add a plugin like below
        $types = $event->getSubject();

        IF generateDetailContentType && hasUserController && getMainUserController.hasActions('display')

            // plugin for showing a single item
            $types->add('appName_ContentType_Item');
        ENDIF
        IF generateListContentType

            // plugin for showing a list of multiple items
            $types->add('appName_ContentType_ItemList');
        ENDIF
    '''

    def private getEditorHelpers(Application it, Boolean isBase) '''
        /**
         * Listener for the `module.scribite.editorhelpers` event.
         *
         * This occurs when Scribite adds pagevars to the editor page.
         * appName will use this to add a javascript helper to add custom items.
         *
         * @param IF targets('1.3.5')Zikula_EventELSEGenericEventENDIF $event The event instance.
         */
        public IF targets('1.3.5')static ENDIFfunction getEditorHelpers(IF targets('1.3.5')Zikula_EventELSEGenericEventENDIF $event)
        {
            IF !isBase
                parent::getEditorHelpers($event);

                commonExample.generalEventProperties(it)
            ELSE
                getEditorHelpersImpl
            ENDIF
        }
    '''

    def private getEditorHelpersImpl(Application it) '''
        // intended is using the add() method to add a helper like below
        $helpers = $event->getSubject();

        $helpers->add(
            array('module' => 'appName',
                  'type'   => 'javascript',
                  'path'   => 'rootFolder/IF targets('1.3.5')appName/javascript/ELSEappName/getAppJsPathENDIFappNameIF targets('1.3.5')_fELSE.FENDIFinder.js')
        );
    '''

    def private getTinyMcePlugins(Application it, Boolean isBase) '''
        /**
         * Listener for the `moduleplugin.tinymce.externalplugins` event.
         *
         * Adds external plugin to TinyMCE.
         *
         * @param IF targets('1.3.5')Zikula_EventELSEGenericEventENDIF $event The event instance.
         */
        public IF targets('1.3.5')static ENDIFfunction getTinyMcePlugins(IF targets('1.3.5')Zikula_EventELSEGenericEventENDIF $event)
        {
            IF !isBase
                parent::getTinyMcePlugins($event);

                commonExample.generalEventProperties(it)
            ELSE
                getTinyMcePluginsImpl
            ENDIF
        }
    '''

    def private getTinyMcePluginsImpl(Application it) '''
        // intended is using the add() method to add a plugin like below
        $plugins = $event->getSubject();

        $plugins->add(
            array('name' => 'appName.formatForDB',
                  'path' => 'rootFolder/IF targets('1.3.5')appName/docs/ELSEappName/getAppDocPathENDIFscribite/plugins/TinyMce/vendor/tinymce/plugins/appName.formatForDB/editor_plugin.js'
            )
        );
    '''

    def private getCKEditorPlugins(Application it, Boolean isBase) '''
        /**
         * Listener for the `moduleplugin.ckeditor.externalplugins` event.
         *
         * Adds external plugin to CKEditor.
         *
         * @param IF targets('1.3.5')Zikula_EventELSEGenericEventENDIF $event The event instance.
         */
        public IF targets('1.3.5')static ENDIFfunction getCKEditorPlugins(IF targets('1.3.5')Zikula_EventELSEGenericEventENDIF $event)
        {
            IF !isBase
                parent::getCKEditorPlugins($event);

                commonExample.generalEventProperties(it)
            ELSE
                getCKEditorPluginsImpl
            ENDIF
        }
    '''

    def private getCKEditorPluginsImpl(Application it) '''
        // intended is using the add() method to add a plugin like below
        $plugins = $event->getSubject();

        $plugins->add(
            array('name' => 'appName.formatForDB',
                  'path' => 'rootFolder/IF targets('1.3.5')appName/docs/ELSEappName/getAppDocPathENDIFscribite/plugins/CKEditor/vendor/ckeditor/plugins/appName.formatForDB/',
                  'file' => 'plugin.js',
                  'img'  => 'ed_appName.formatForDB.gif'
            )
        );
    '''
}
