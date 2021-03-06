package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import de.guite.modulestudio.metamodel.modulestudio.Application
import org.zikula.modulestudio.generator.extensions.Utils

class UserLogout {
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
                        'module.users.ui.logout.succeeded' => array('succeeded', 5)
                    );
                ELSE
                    return parent::getSubscribedEvents();
                ENDIF
            }

        ENDIF
        /**
         * Listener for the `module.users.ui.logout.succeeded` event.
         *
         * Occurs right after a successful logout.
         * All handlers are notified.
         * The event's subject contains the user's user record.
         * Args contain array of `array('authentication_method' => $authenticationMethod,
         *                              'uid'                   => $uid));`
         *
         * @param IF targets('1.3.5')Zikula_EventELSEGenericEventENDIF $event The event instance.
         */
        public IF targets('1.3.5')static ENDIFfunction succeeded(IF targets('1.3.5')Zikula_EventELSEGenericEventENDIF $event)
        {
            IF !isBase
                parent::succeeded($event);

                commonExample.generalEventProperties(it)
            ENDIF
        }
    '''
}
