package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import de.guite.modulestudio.metamodel.modulestudio.Application
import org.zikula.modulestudio.generator.extensions.Utils

class Group {
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
                        'group.create'     => array('create', 5),
                        'group.update'     => array('update', 5),
                        'group.delete'     => array('delete', 5),
                        'group.adduser'    => array('addUser', 5),
                        'group.removeuser' => array('removeUser', 5)
                    );
                ELSE
                    return parent::getSubscribedEvents();
                ENDIF
            }

        ENDIF

        /**
         * Listener for the `group.create` event.
         *
         * Occurs after a group is created. All handlers are notified.
         * The full group record created is available as the subject.
         *
         * @param IF targets('1.3.5')Zikula_EventELSEGenericEventENDIF $event The event instance.
         */
        public IF targets('1.3.5')static ENDIFfunction create(IF targets('1.3.5')Zikula_EventELSEGenericEventENDIF $event)
        {
            IF !isBase
                parent::create($event);

                commonExample.generalEventProperties(it)
            ENDIF
        }

        /**
         * Listener for the `group.update` event.
         *
         * Occurs after a group is updated. All handlers are notified.
         * The full updated group record is available as the subject.
         *
         * @param IF targets('1.3.5')Zikula_EventELSEGenericEventENDIF $event The event instance.
         */
        public IF targets('1.3.5')static ENDIFfunction update(IF targets('1.3.5')Zikula_EventELSEGenericEventENDIF $event)
        {
            IF !isBase
                parent::update($event);

                commonExample.generalEventProperties(it)
            ENDIF
        }

        /**
         * Listener for the `group.delete` event.
         *
         * Occurs after a group is deleted from the system.
         * All handlers are notified.
         * The full group record deleted is available as the subject.
         *
         * @param IF targets('1.3.5')Zikula_EventELSEGenericEventENDIF $event The event instance.
         */
        public IF targets('1.3.5')static ENDIFfunction delete(IF targets('1.3.5')Zikula_EventELSEGenericEventENDIF $event)
        {
            IF !isBase
                parent::delete($event);

                commonExample.generalEventProperties(it)
            ENDIF
        }

        /**
         * Listener for the `group.adduser` event.
         *
         * Occurs after a user is added to a group.
         * All handlers are notified.
         * It does not apply to pending membership requests.
         * The uid and gid are available as the subject.
         *
         * @param IF targets('1.3.5')Zikula_EventELSEGenericEventENDIF $event The event instance.
         */
        public IF targets('1.3.5')static ENDIFfunction addUser(IF targets('1.3.5')Zikula_EventELSEGenericEventENDIF $event)
        {
            IF !isBase
                parent::addUser($event);

                commonExample.generalEventProperties(it)
            ENDIF
        }

        /**
         * Listener for the `group.removeuser` event.
         *
         * Occurs after a user is removed from a group.
         * All handlers are notified.
         * The uid and gid are available as the subject.
         *
         * @param IF targets('1.3.5')Zikula_EventELSEGenericEventENDIF $event The event instance.
         */
        public IF targets('1.3.5')static ENDIFfunction removeUser(IF targets('1.3.5')Zikula_EventELSEGenericEventENDIF $event)
        {
            IF !isBase
                parent::removeUser($event);

                commonExample.generalEventProperties(it)
            ENDIF
        }
    '''
}
