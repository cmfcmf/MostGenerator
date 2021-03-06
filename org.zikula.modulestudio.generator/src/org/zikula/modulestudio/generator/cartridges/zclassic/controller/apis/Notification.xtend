package org.zikula.modulestudio.generator.cartridges.zclassic.controller.apis

import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Notification {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    FileHelper fh = new FileHelper

    def generate(Application it, IFileSystemAccess fsa) {
        generateClassPair(fsa, getAppSourceLibPath + 'Api/Notification' + (if (targets('1.3.5')) '' else 'Api') + '.php',
            fh.phpFileContent(it, notificationApiBaseClass), fh.phpFileContent(it, notificationApiImpl)
        )
    }

    def private notificationApiBaseClass(Application it) '''
        IF !targets('1.3.5')
            namespace appNamespace\Api\Base;

            use ModUtil;
            use ServiceUtil;
            use System;
            use UserUtil;

            use Zikula_AbstractApi;
            use Zikula_View;

        ENDIF
        /**
         * Notification api base class.
         */
        class IF targets('1.3.5')appName_Api_Base_NotificationELSENotificationApiENDIF extends Zikula_AbstractApi
        {
            notificationApiBaseImpl
        }
    '''

    def private notificationApiBaseImpl(Application it) '''

        /**
         * List of notification recipients.
         *
         * @var array $recipients.
         */
        private $recipients = array();

        /**
         * Which type of recipient is used ("creator", "moderator" or "superModerator").
         *
         * @var string recipientType.
         */
        private $recipientType = '';

        /**
         * The entity which has been changed before.
         *
         * @var Zikula_EntityAccess entity.
         */
        private $entity = '';

        /**
         * Name of workflow action which is being performed.
         *
         * @var string action.
         */
        private $action = '';

        /**
         * Sends a mail to either an item's creator or a group of moderators.
         */
        public function process($args)
        {
            if (!isset($args['recipientType']) || !$args['recipientType']) {
                return false;
            }

            if (!isset($args['action']) || !$args['action']) {
                return false;
            }

            if (!isset($args['entity']) || !$args['entity']) {
                return false;
            }

            $this->recipientType = $args['recipientType'];
            $this->action = $args['action'];
            $this->entity = $args['entity'];

            $uid = UserUtil::getVar('uid');

            $this->collectRecipients();

            if (!count($this->recipients)) {
                return true;
            }

            if (!ModUtil::available('IF targets('1.3.5')MailerELSEZikulaMailerModuleENDIF') || !ModUtil::loadApi('IF targets('1.3.5')MailerELSEZikulaMailerModuleENDIF', 'user')) {
                return LogUtil::registerError($this->__('Could not inform other persons about your amendments, because the Mailer module is not available - please contact an administrator about that!'));
            }

            $result = $this->sendMails();

            IF targets('1.3.5')
                SessionUtil::delVar($this->name . 'AdditionalNotificationRemarks');
            ELSE
                $this->request->getSession()->del($this->name . 'AdditionalNotificationRemarks');
            ENDIF

            return $result;
        }

        /**
         * Collects the recipients.
         */
        protected function collectRecipients()
        {
            $this->recipients = array();

            if ($this->recipientType == 'moderator' || $this->recipientType == 'superModerator') {
                $objectType = $this->entity['_objectType'];
                $moderatorGroupId = $this->getVar('moderationGroupFor' . $objectType, 2);
                if ($this->recipientType == 'superModerator') {
                    $moderatorGroupId = $this->getVar('superModerationGroupFor' . $objectType, 2);
                }

                $moderatorGroup = ModUtil::apiFunc('IF targets('1.3.5')GroupsELSEZikulaGroupsModuleENDIF', 'user', 'get', array('gid' => $moderatorGroupId));
                foreach (array_keys($moderatorGroup['members']) as $uid) {
                    $this->addRecipient($uid);
                }
            } elseif ($this->recipientType == 'creator' && isset($this->entity['createdUserId'])) {
                $creatorUid = $this->entity['createdUserId'];

                $this->addRecipient($creatorUid);
            }

            if (isset($args['debug']) && $args['debug']) {
                // add the admin, too
                $this->addRecipient(2);
            }
        }

        /**
         * Collects data for building the recipients array.
         *
         * @param $userId Id of treated user.
         */
        protected function addRecipient($userId)
        {
            $userVars = UserUtil::getVars($userId);

            $recipient = array(
                'name' => (isset($userVars['name']) && !empty($userVars['name']) ? $userVars['name'] : $userVars['uname']),
                'email' => $userVars['email']
            );
            $this->recipients[] = $recipient;
            return $recipient;
        }

        /**
         * Performs the actual mailing.
         */
        protected function sendMails()
        {
            $objectType = $this->entity['_objectType'];
            $siteName = System::getVar('sitename');

            $view = Zikula_View::getInstance('appName');
            $templateType = $this->recipientType == 'creator' ? 'Creator' : 'Moderator';
            $template = 'IF targets('1.3.5')emailELSEEmailENDIF/notify' . ucfirst($objectType) . $templateType .  '.tpl';

            $mailData = $this->prepareEmailData();

            // send one mail per recipient
            $totalResult = true;
            foreach ($this->recipients as $recipient) {
                if (!isset($recipient['username']) || !$recipient['username']) {
                    continue;
                }
                if (!isset($recipient['email']) || !$recipient['email']) {
                    continue;
                }

                $view->assign('recipient', $recipient)
                     ->assign('mailData', $mailData);

                $mailArgs = array(
                    'fromname' => $siteName),
                    'toname' => $recipient['name'],
                    'toaddress' => $recipient['email'],
                    'subject' => $this->getMailSubject(),
                    'body' => $view->fetch($template),
                    'html' => true
                );

                $totalResult &= ModUtil::apiFunc('IF targets('1.3.5')MailerELSEZikulaMailerModuleENDIF', 'user', 'sendmessage', $mailArgs);
            }

            return $totalResult;
        }

        protected function getMailSubject()
        {
            $mailSubject = '';
            if ($this->recipientType == 'moderator' || $this->recipientType == 'superModerator') {
                if ($this->action == 'submit') {
                    $mailSubject = $this->__('New content has been submitted');
                } else {
                    $mailSubject = $this->__('Content has been updated');
                }
            } elseif ($this->recipientType == 'creator') {
                $mailSubject = $this->__('Your submission has been updated');
            }

            return $mailSubject;
        }

        protected function prepareEmailData()
        {
            $serviceManager = ServiceUtil::getManager();
            IF targets('1.3.5')
                $workflowHelper = new appName_Util_Workflow($serviceManager);
            ELSE
                $workflowHelper = $serviceManager->get('appName.formatForDB.workflow_helper');
            ENDIF

            $objectType = $this->entity['_objectType'];
            $state = $this->entity['workflowState'];
            $stateInfo = $workflowHelper->getStateInfo($state);

            IF targets('1.3.5')
                $remarks = SessionUtil::getVar($this->name . 'AdditionalNotificationRemarks', '');
            ELSE
                $remarks = $this->request->getSession()->get($this->name . 'AdditionalNotificationRemarks', '');
            ENDIF

            $urlArgs = $this->entity->createUrlArgs();
            $displayUrl = '';
            $editUrl = '';

            if ($this->recipientType == 'moderator' || $this->recipientType == 'superModerator') {
                IF !targets('1.3.5') && (hasAdminController && getAllAdminControllers.head.hasActions('display')
                    || hasUserController && getMainUserController.hasActions('display')
                    || hasAdminController && getAllAdminControllers.head.hasActions('edit')
                    || hasUserController && getMainUserController.hasActions('edit'))
                    $urlArgs['lct'] = 'IF hasAdminController && getAllAdminControllers.head.hasActions('display')adminELSEuserENDIF';
                ENDIF
                IF hasAdminController && getAllAdminControllers.head.hasActions('display')
                    || hasUserController && getMainUserController.hasActions('display')
                    IF targets('1.3.5')
                        $displayUrl = ModUtil::url($this->name, 'IF hasAdminController && getAllAdminControllers.head.hasActions('display')adminELSEuserENDIF', 'display', $urlArgs, null, null, true); // absolute
                    ELSE
                        $displayUrl = $serviceManager->get('router')->generate('appName.formatForDB_' . $objectType . '_display', $urlArgs, true);
                    ENDIF
                ENDIF
                IF hasAdminController && getAllAdminControllers.head.hasActions('edit')
                    || hasUserController && getMainUserController.hasActions('edit')
                    IF targets('1.3.5')
                        $editUrl = ModUtil::url($this->name, 'IF hasAdminController && getAllAdminControllers.head.hasActions('display')adminELSEuserENDIF', 'edit', $urlArgs, null, null, true); // absolute
                    ELSE
                        $editUrl = $serviceManager->get('router')->generate('appName.formatForDB_' . $objectType . '_edit', $urlArgs, true);
                    ENDIF
                ENDIF
            } elseif ($this->recipientType == 'creator') {
                IF !targets('1.3.5') && (getMainUserController.hasActions('display') || getMainUserController.hasActions('edit'))
                    $urlArgs['lct'] = 'user';
                ENDIF
                IF getMainUserController.hasActions('display')
                    IF targets('1.3.5')
                        $displayUrl = ModUtil::url($this->name, 'user', 'display', $urlArgs, null, null, true); // absolute
                    ELSE
                        $displayUrl = $serviceManager->get('router')->generate('appName.formatForDB_' . $objectType . '_display', $urlArgs, true);
                    ENDIF
                ENDIF
                IF getMainUserController.hasActions('edit')
                    IF targets('1.3.5')
                        $editUrl = ModUtil::url($this->name, 'user', 'edit', $urlArgs, null, null, true); // absolute
                    ELSE
                        $editUrl = $serviceManager->get('router')->generate('appName.formatForDB_' . $objectType . '_edit', $urlArgs, true);
                    ENDIF
                ENDIF
            }

            $emailData = array(
                'name' => $this->entity->getTitleFromDisplayPattern(),
                'newState' => $stateInfo['text'],
                'remarks' => $remarks,
                'displayUrl' => $displayUrl,
                'editUrl' => $editUrl
            );

            return $emailData;
        }
    '''

    def private notificationApiImpl(Application it) '''
        IF !targets('1.3.5')
            namespace appNamespace\Api;

            use appNamespace\Api\Base\NotificationApi as BaseNotificationApi;

        ENDIF
        /**
         * Notification api implementation class.
         */
        IF targets('1.3.5')
        class appName_Api_Notification extends appName_Api_Base_Notification
        ELSE
        class NotificationApi extends BaseNotificationApi
        ENDIF
        {
            // feel free to extend the notification api here
        }
    '''
}
