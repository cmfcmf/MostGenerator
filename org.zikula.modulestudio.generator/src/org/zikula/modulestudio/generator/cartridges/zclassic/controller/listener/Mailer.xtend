package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import de.guite.modulestudio.metamodel.modulestudio.Application
import org.zikula.modulestudio.generator.extensions.Utils

class Mailer {
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
                        'module.mailer.api.sendmessage' => array('sendMessage', 5)
                    );
                ELSE
                    return parent::getSubscribedEvents();
                ENDIF
            }

        ENDIF
        /**
         * Listener for the `module.mailer.api.sendmessage` event.
         *
         * Invoked from `Mailer_Api_User#sendmessage`.
         * Subject is `Mailer_Api_User` with `$args`.
         * This is a notifyUntil event so the event must `$event->stopIF !targets('1.3.5')PropagationENDIF()` and set any
         * return data into `$event->data`, or `$event->setData()`.
         *
         * @param IF targets('1.3.5')Zikula_EventELSEGenericEventENDIF $event The event instance.
         */
        public IF targets('1.3.5')static ENDIFfunction sendMessage(IF targets('1.3.5')Zikula_EventELSEGenericEventENDIF $event)
        {
            IF !isBase
                parent::sendMessage($event);

                commonExample.generalEventProperties(it)
            ENDIF
        }
    '''
}
