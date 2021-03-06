package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import de.guite.modulestudio.metamodel.modulestudio.Application
import org.zikula.modulestudio.generator.extensions.Utils

class ModuleInstaller {
    extension Utils = new Utils

    CommonExample commonExample = new CommonExample()

    def generate(Application it, Boolean isBase) '''
        IF !targets('1.3.5')
            /**
             * Makes our handlers known to the event system.
             */
            public static function getSubscribedEvents()
            {
                IF isBase
                    return array(
                        CoreEvents::MODULE_INSTALL             => array('moduleInstalled', 5),
                        CoreEvents::MODULE_UPGRADE             => array('moduleUpgraded', 5),
                        CoreEvents::MODULE_ENABLE              => array('moduleEnabled', 5),
                        CoreEvents::MODULE_DISABLE             => array('moduleDisabled', 5),
                        CoreEvents::MODULE_REMOVE              => array('moduleRemoved', 5),
                        'installer.subscriberarea.uninstalled' => array('subscriberAreaUninstalled', 5)
                    );
                ELSE
                    return parent::getSubscribedEvents();
                ENDIF
            }

        ENDIF
        /**
         * Listener for the `IF targets('1.3.5')installer.module.installedELSEmodule.installENDIF` event.
         *
         * Called after a module has been successfully installed.
         * Receives `$modinfo` as args.
         *
         * @param IF targets('1.3.5')Zikula_EventELSEModuleStateEventENDIF $event The event instance.
         */
        public IF targets('1.3.5')static ENDIFfunction moduleInstalled(IF targets('1.3.5')Zikula_EventELSEModuleStateEventENDIF $event)
        {
            IF !isBase
                parent::moduleInstalled($event);

                commonExample.generalEventProperties(it)
            ENDIF
        }

        /**
         * Listener for the `IF targets('1.3.5')installer.module.upgradedELSEmodule.upgradeENDIF` event.
         *
         * Called after a module has been successfully upgraded.
         * Receives `$modinfo` as args.
         *
         * @param IF targets('1.3.5')Zikula_EventELSEModuleStateEventENDIF $event The event instance.
         */
        public IF targets('1.3.5')static ENDIFfunction moduleUpgraded(IF targets('1.3.5')Zikula_EventELSEModuleStateEventENDIF $event)
        {
            IF !isBase
                parent::moduleUpgraded($event);

                commonExample.generalEventProperties(it)
            ENDIF
        }
        IF !targets('1.3.5')

            /**
             * Listener for the `module.enable` event.
             *
             * Called after a module has been successfully enabled.
             * Receives `$modinfo` as args.
             */
            public function moduleEnabled(IF targets('1.3.5')Zikula_EventELSEModuleStateEventENDIF $event)
            {
                IF !isBase
                    parent::moduleEnabled($event);

                    commonExample.generalEventProperties(it)
                ENDIF
            }

            /**
             * Listener for the `module.disable` event.
             *
             * Called after a module has been successfully disabled.
             * Receives `$modinfo` as args.
             */
            public function moduleDisabled(IF targets('1.3.5')Zikula_EventELSEModuleStateEventENDIF $event)
            {
                IF !isBase
                    parent::moduleDisabled($event);

                    commonExample.generalEventProperties(it)
                ENDIF
            }
        ENDIF

        /**
         * Listener for the `IF targets('1.3.5')installer.module.uninstalledELSEmodule.removeENDIF` event.
         *
         * Called after a module has been successfully IF targets('1.3.5')uninstalledELSEremovedENDIF.
         * Receives `$modinfo` as args.
         *
         * @param IF targets('1.3.5')Zikula_EventELSEGenericEventENDIF $event The event instance.
         */
        public IF targets('1.3.5')static ENDIFfunction moduleIF targets('1.3.5')UninstalledELSERemovedENDIF(IF targets('1.3.5')Zikula_EventELSEModuleStateEventENDIF $event)
        {
            IF !isBase
                parent::moduleIF targets('1.3.5')UninstalledELSERemovedENDIF($event);

                commonExample.generalEventProperties(it)
            ENDIF
        }

        /**
         * Listener for the `installer.subscriberarea.uninstalled` event.
         *
         * Called after a hook subscriber area has been unregistered.
         * Receives args['areaid'] as the areaId. Use this to remove orphan data associated with this area.
         *
         * @param IF targets('1.3.5')Zikula_EventELSEGenericEventENDIF $event The event instance.
         */
        public IF targets('1.3.5')static ENDIFfunction subscriberAreaUninstalled(IF targets('1.3.5')Zikula_EventELSEGenericEventENDIF $event)
        {
            IF !isBase
                parent::subscriberAreaUninstalled($event);

                commonExample.generalEventProperties(it)
            ENDIF
        }
    '''
}
