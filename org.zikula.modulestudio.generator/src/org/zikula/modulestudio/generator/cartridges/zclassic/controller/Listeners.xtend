package org.zikula.modulestudio.generator.cartridges.zclassic.controller

import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.Core
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.ErrorsLegacy
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.FrontControllerLegacy
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.Group
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.Kernel
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.Mailer
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.ModuleDispatch
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.ModuleInstaller
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.Page
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.Theme
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.ThirdParty
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.User
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.UserLogin
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.UserLogout
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.UserRegistration
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.Users
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.View
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions

class Listeners {
    extension ControllerExtensions = new ControllerExtensions
    extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils
    extension WorkflowExtensions = new WorkflowExtensions

    FileHelper fh = new FileHelper
    IFileSystemAccess fsa
    Application app
    Boolean isBase
    Boolean needsThirdPartyListener

    String listenerPath
    String listenerSuffix

    /**
     * Entry point for event subscribers.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        this.fsa = fsa
        this.app = it
        listenerSuffix = (if (targets('1.3.5')) '' else 'Listener') + '.php'

        val needsDetailContentType = generateDetailContentType && hasUserController && getMainUserController.hasActions('display')
        needsThirdPartyListener = (generatePendingContentSupport || generateListContentType || needsDetailContentType || (!targets('1.3.5') && generateScribitePlugins))

        println('Generating event listener base classes')
        listenerPath = getAppSourceLibPath + 'Listener/Base/'
        isBase = true
        generateListenerClasses

        if (generateOnlyBaseClasses) {
            return
        }

        println('Generating event listener implementation classes')
        listenerPath = getAppSourceLibPath + 'Listener/'
        isBase = false
        generateListenerClasses
    }

    def private generateListenerClasses(Application it) {
        listenerFile('Core', listenersCoreFile)
        if (targets('1.3.5')) {
            listenerFile('FrontController', listenersFrontControllerFile)
        } else {
            listenerFile('Kernel', listenersKernelFile)
        }
        listenerFile('Installer', listenersInstallerFile)
        listenerFile('ModuleDispatch', listenersModuleDispatchFile)
        listenerFile('Mailer', listenersMailerFile)
        listenerFile('Page', listenersPageFile)
        if (targets('1.3.5')) {
            listenerFile('Errors', listenersErrorsFile)
        }
        listenerFile('Theme', listenersThemeFile)
        listenerFile('View', listenersViewFile)
        listenerFile('UserLogin', listenersUserLoginFile)
        listenerFile('UserLogout', listenersUserLogoutFile)
        listenerFile('User', listenersUserFile)
        listenerFile('UserRegistration', listenersUserRegistrationFile)
        listenerFile('Users', listenersUsersFile)
        listenerFile('Group', listenersGroupFile)

        if (needsThirdPartyListener) {
            listenerFile('ThirdParty', listenersThirdPartyFile)
        }
    }

    def private listenerFile(String name, CharSequence content) {
        var filePath = listenerPath + name + listenerSuffix
        if (!app.shouldBeSkipped(filePath)) {
            if (app.shouldBeMarked(filePath)) {
                filePath = listenerPath + name + listenerSuffix.replace('.php', '.generated.php')
            }
            fsa.generateFile(filePath, fh.phpFileContent(app, content))
        }
    }

    def private listenersCoreFile(Application it) '''
        IF !targets('1.3.5')
            namespace appNamespace\ListenerIF isBase\BaseENDIF;

            IF !isBase
                use appNamespace\Listener\Base\CoreListener as BaseCoreListener;
            ELSE
                use Symfony\Component\EventDispatcher\EventSubscriberInterface;
                use Symfony\Component\HttpKernel\HttpKernelInterface;
            ENDIF
            use Zikula\Core\Event\GenericEvent;

        ENDIF
        /**
         * Event handler IF isBasebaseELSEimplementationENDIF class for core events.
         */
        IF targets('1.3.5')
        class IF !isBaseappName_Listener_Core extends ENDIFappName_Listener_Base_Core
        ELSE
        class CoreListenerIF !isBase extends BaseCoreListenerELSE implements EventSubscriberInterfaceENDIF
        ENDIF
        {
            new Core().generate(it, isBase)
        }
    '''

    // obsolete, used for 1.3.5 only
    def private listenersFrontControllerFile(Application it) '''
        /**
         * Event handler IF isBasebaseELSEimplementationENDIF class for frontend controller interaction events.
         */
        class IF !isBaseappName_Listener_FrontController extends ENDIFappName_Listener_Base_FrontController
        {
            new FrontControllerLegacy().generate(it, isBase)
        }
    '''

    def private listenersInstallerFile(Application it) '''
        IF !targets('1.3.5')
            namespace appNamespace\ListenerIF isBase\BaseENDIF;

            IF !isBase
                use appNamespace\Listener\Base\InstallerListener as BaseInstallerListener;
            ELSE
                use Symfony\Component\EventDispatcher\EventSubscriberInterface;
                use Symfony\Component\HttpKernel\HttpKernelInterface;
                use Zikula\Core\CoreEvents;
            ENDIF
            use Zikula\Core\Event\GenericEvent;
            use Zikula\Core\Event\ModuleStateEvent;

        ENDIF
        /**
         * Event handler IF isBasebaseELSEimplementationENDIF class for module installer events.
         */
        IF targets('1.3.5')
        class IF !isBaseappName_Listener_Installer extends ENDIFappName_Listener_Base_Installer
        ELSE
        class InstallerListenerIF !isBase extends BaseInstallerListenerELSE implements EventSubscriberInterfaceENDIF
        ENDIF
        {
            new ModuleInstaller().generate(it, isBase)
        }
    '''

    // used for 1.4.x only
    def private listenersKernelFile(Application it) '''
        namespace appNamespace\ListenerIF isBase\BaseENDIF;

        IF !isBase
            use appNamespace\Listener\Base\KernelListener as BaseKernelListener;
        ELSE
            use Symfony\Component\EventDispatcher\EventSubscriberInterface;
            use Symfony\Component\HttpKernel\KernelEvents;
        ENDIF
        use Symfony\Component\HttpKernel\Event\GetResponseEvent;
        use Symfony\Component\HttpKernel\Event\FilterControllerEvent;
        use Symfony\Component\HttpKernel\Event\GetResponseForControllerResultEvent;
        use Symfony\Component\HttpKernel\Event\FilterResponseEvent;
        use Symfony\Component\HttpKernel\Event\FinishRequestEvent;
        use Symfony\Component\HttpKernel\Event\PostResponseEvent;
        use Symfony\Component\HttpKernel\Event\GetResponseForExceptionEvent;
        use Symfony\Component\HttpKernel\Exception\HttpExceptionInterface;
        use Symfony\Component\HttpFoundation\Response;

        /**
         * Event handler IF isBasebaseELSEimplementationENDIF class for Symfony kernel events.
         */
        class KernelListenerIF !isBase extends BaseKernelListenerELSE implements EventSubscriberInterfaceENDIF
        {
            new Kernel().generate(it, isBase)
        }
    '''

    def private listenersModuleDispatchFile(Application it) '''
        IF !targets('1.3.5')
            namespace appNamespace\ListenerIF isBase\BaseENDIF;

            IF !isBase
                use appNamespace\Listener\Base\ModuleDispatchListener as BaseModuleDispatchListener;
            ELSE
                use ModUtil;
                use Symfony\Component\EventDispatcher\EventSubscriberInterface;
                use Symfony\Component\HttpKernel\HttpKernelInterface;
            ENDIF
            use Zikula\Core\Event\GenericEvent;

        ENDIF
        /**
         * Event handler IF isBasebaseELSEimplementationENDIF class for dispatching modules.
         */
        IF targets('1.3.5')
        class IF !isBaseappName_Listener_ModuleDispatch extends ENDIFappName_Listener_Base_ModuleDispatch
        ELSE
        class ModuleDispatchListenerIF !isBase extends BaseModuleDispatchListenerELSE implements EventSubscriberInterfaceENDIF
        ENDIF
        {
            new ModuleDispatch().generate(it, isBase)
        }
    '''

    def private listenersMailerFile(Application it) '''
        IF !targets('1.3.5')
            namespace appNamespace\ListenerIF isBase\BaseENDIF;

            IF !isBase
                use appNamespace\Listener\Base\MailerListener as BaseMailerListener;
            ELSE
                use Symfony\Component\EventDispatcher\EventSubscriberInterface;
                use Symfony\Component\HttpKernel\HttpKernelInterface;
            ENDIF
            use Zikula\Core\Event\GenericEvent;

        ENDIF
        /**
         * Event handler IF isBasebaseELSEimplementationENDIF class for mailing events.
         */
        IF targets('1.3.5')
        class IF !isBaseappName_Listener_Mailer extends ENDIFappName_Listener_Base_Mailer
        ELSE
        class MailerListenerIF !isBase extends BaseMailerListenerELSE implements EventSubscriberInterfaceENDIF
        ENDIF
        {
            new Mailer().generate(it, isBase)
        }
    '''

    def private listenersPageFile(Application it) '''
        IF !targets('1.3.5')
            namespace appNamespace\ListenerIF isBase\BaseENDIF;

            IF !isBase
                use appNamespace\Listener\Base\PageListener as BasePageListener;
            ELSE
                use Symfony\Component\EventDispatcher\EventSubscriberInterface;
                use Symfony\Component\HttpKernel\HttpKernelInterface;
            ENDIF
            use Zikula\Core\Event\GenericEvent;

        ENDIF
        /**
         * Event handler IF isBasebaseELSEimplementationENDIF class for page-related events.
         */
        IF targets('1.3.5')
        class IF !isBaseappName_Listener_Page extends ENDIFappName_Listener_Base_Page
        ELSE
        class PageListenerIF !isBase extends BasePageListenerELSE implements EventSubscriberInterfaceENDIF
        ENDIF
        {
            new Page().generate(it, isBase)
        }
    '''

    // obsolete, used for 1.3.5 only
    def private listenersErrorsFile(Application it) '''
        /**
         * Event handler IF isBasebaseELSEimplementationENDIF class for error-related events.
         */
        class IF !isBaseappName_Listener_Errors extends ENDIFappName_Listener_Base_Errors
        {
            new ErrorsLegacy().generate(it, isBase)
        }
    '''

    def private listenersThemeFile(Application it) '''
        IF !targets('1.3.5')
            namespace appNamespace\ListenerIF isBase\BaseENDIF;

            IF !isBase
                use appNamespace\Listener\Base\ThemeListener as BaseThemeListener;
            ELSE
                use Symfony\Component\EventDispatcher\EventSubscriberInterface;
                use Symfony\Component\HttpKernel\HttpKernelInterface;
            ENDIF
            use Zikula\Core\Event\GenericEvent;

        ENDIF
        /**
         * Event handler IF isBasebaseELSEimplementationENDIF class for theme-related events.
         */
        IF targets('1.3.5')
        class IF !isBaseappName_Listener_Theme extends ENDIFappName_Listener_Base_Theme
        ELSE
        class ThemeListenerIF !isBase extends BaseThemeListenerELSE implements EventSubscriberInterfaceENDIF
        ENDIF
        {
            new Theme().generate(it, isBase)
        }
    '''

    def private listenersViewFile(Application it) '''
        IF !targets('1.3.5')
            namespace appNamespace\ListenerIF isBase\BaseENDIF;

            IF !isBase
                use appNamespace\Listener\Base\ViewListener as BaseViewListener;
            ELSE
                use Symfony\Component\EventDispatcher\EventSubscriberInterface;
                use Symfony\Component\HttpKernel\HttpKernelInterface;
            ENDIF
            use Zikula\Core\Event\GenericEvent;

        ENDIF
        /**
         * Event handler IF isBasebaseELSEimplementationENDIF class for view-related events.
         */
        IF targets('1.3.5')
        class IF !isBaseappName_Listener_View extends ENDIFappName_Listener_Base_View
        ELSE
        class ViewListenerIF !isBase extends BaseViewListenerELSE implements EventSubscriberInterfaceENDIF
        ENDIF
        {
            new View().generate(it, isBase)
        }
    '''

    def private listenersUserLoginFile(Application it) '''
        IF !targets('1.3.5')
            namespace appNamespace\ListenerIF isBase\BaseENDIF;

            IF !isBase
                use appNamespace\Listener\Base\UserLoginListener as BaseUserLoginListener;
            ELSE
                use Symfony\Component\EventDispatcher\EventSubscriberInterface;
                use Symfony\Component\HttpKernel\HttpKernelInterface;
            ENDIF
            use Zikula\Core\Event\GenericEvent;

        ENDIF
        /**
         * Event handler IF isBasebaseELSEimplementationENDIF class for user login events.
         */
        IF targets('1.3.5')
        class IF !isBaseappName_Listener_UserLogin extends ENDIFappName_Listener_Base_UserLogin
        ELSE
        class UserLoginListenerIF !isBase extends BaseUserLoginListenerELSE implements EventSubscriberInterfaceENDIF
        ENDIF
        {
            new UserLogin().generate(it, isBase)
        }
    '''

    def private listenersUserLogoutFile(Application it) '''
        IF !targets('1.3.5')
            namespace appNamespace\ListenerIF isBase\BaseENDIF;

            IF !isBase
                use appNamespace\Listener\Base\UserLogoutListener as BaseUserLogoutListener;
            ELSE
                use Symfony\Component\EventDispatcher\EventSubscriberInterface;
                use Symfony\Component\HttpKernel\HttpKernelInterface;
            ENDIF
            use Zikula\Core\Event\GenericEvent;

        ENDIF
        /**
         * Event handler IF isBasebaseELSEimplementationENDIF class for user logout events.
         */
        IF targets('1.3.5')
        class IF !isBaseappName_Listener_UserLogout extends ENDIFappName_Listener_Base_UserLogout
        ELSE
        class UserLogoutListenerIF !isBase extends BaseUserLogoutListenerELSE implements EventSubscriberInterfaceENDIF
        ENDIF
        {
            new UserLogout().generate(it, isBase)
        }
    '''

    def private listenersUserFile(Application it) '''
        IF !targets('1.3.5')
            namespace appNamespace\ListenerIF isBase\BaseENDIF;

            IF !isBase
                use appNamespace\Listener\Base\UserListener as BaseUserListener;
            ELSE
                IF hasStandardFieldEntities || hasUserFields
                    use ModUtil;
                    use ServiceUtil;
                ENDIF
                use UserUtil;
                use Symfony\Component\EventDispatcher\EventSubscriberInterface;
                use Symfony\Component\HttpKernel\HttpKernelInterface;
            ENDIF
            use Zikula\Core\Event\GenericEvent;

        ENDIF
        /**
         * Event handler IF isBasebaseELSEimplementationENDIF class for user-related events.
         */
        IF targets('1.3.5')
        class IF !isBaseappName_Listener_User extends ENDIFappName_Listener_Base_User
        ELSE
        class UserListenerIF !isBase extends BaseUserListenerELSE implements EventSubscriberInterfaceENDIF
        ENDIF
        {
            new User().generate(it, isBase)
        }
    '''

    def private listenersUserRegistrationFile(Application it) '''
        IF !targets('1.3.5')
            namespace appNamespace\ListenerIF isBase\BaseENDIF;

            IF !isBase
                use appNamespace\Listener\Base\UserRegistrationListener as BaseUserRegistrationListener;
            ELSE
                use Symfony\Component\EventDispatcher\EventSubscriberInterface;
                use Symfony\Component\HttpKernel\HttpKernelInterface;
            ENDIF
            use Zikula\Core\Event\GenericEvent;

        ENDIF
        /**
         * Event handler IF isBasebaseELSEimplementationENDIF class for user registration events.
         */
        IF targets('1.3.5')
        class IF !isBaseappName_Listener_UserRegistration extends ENDIFappName_Listener_Base_UserRegistration
        ELSE
        class UserRegistrationListenerIF !isBase extends BaseUserRegistrationListenerELSE implements EventSubscriberInterfaceENDIF
        ENDIF
        {
            new UserRegistration().generate(it, isBase)
        }
    '''

    def private listenersUsersFile(Application it) '''
        IF !targets('1.3.5')
            namespace appNamespace\ListenerIF isBase\BaseENDIF;

            IF !isBase
                use appNamespace\Listener\Base\UsersListener as BaseUsersListener;
            ELSE
                use Symfony\Component\EventDispatcher\EventSubscriberInterface;
                use Symfony\Component\HttpKernel\HttpKernelInterface;
            ENDIF
            use Zikula\Core\Event\GenericEvent;

        ENDIF
        /**
         * Event handler IF isBasebaseELSEimplementationENDIF class for events of the Users module.
         */
        IF targets('1.3.5')
        class IF !isBaseappName_Listener_Users extends ENDIFappName_Listener_Base_Users
        ELSE
        class UsersListenerIF !isBase extends BaseUsersListenerELSE implements EventSubscriberInterfaceENDIF
        ENDIF
        {
            new Users().generate(it, isBase)
        }
    '''

    def private listenersGroupFile(Application it) '''
        IF !targets('1.3.5')
            namespace appNamespace\ListenerIF isBase\BaseENDIF;

            IF !isBase
                use appNamespace\Listener\Base\GroupListener as BaseGroupListener;
            ELSE
                use Symfony\Component\EventDispatcher\EventSubscriberInterface;
                use Symfony\Component\HttpKernel\HttpKernelInterface;
            ENDIF
            use Zikula\Core\Event\GenericEvent;

        ENDIF
        /**
         * Event handler implementation class for group-related events.
         */
        IF targets('1.3.5')
        class IF !isBaseappName_Listener_Group extends ENDIFappName_Listener_Base_Group
        ELSE
        class GroupListenerIF !isBase extends BaseGroupListenerELSE implements EventSubscriberInterfaceENDIF
        ENDIF
        {
            new Group().generate(it, isBase)
        }
    '''

    def private listenersThirdPartyFile(Application it) '''
        IF !targets('1.3.5')
            namespace appNamespace\ListenerIF isBase\BaseENDIF;

            IF !isBase
                use appNamespace\Listener\Base\ThirdPartyListener as BaseThirdPartyListener;
            ELSE
                use Symfony\Component\EventDispatcher\EventSubscriberInterface;
                use Symfony\Component\HttpKernel\HttpKernelInterface;
                IF needsApproval
                    use ServiceUtil;
                    use Zikula\Collection\Container;
                ENDIF
            ENDIF
            use Zikula\Core\Event\GenericEvent;
            IF isBase
                IF needsApproval
                    use Zikula\Provider\AggregateItem;
                ENDIF
            ENDIF

        ENDIF
        /**
         * Event handler implementation class for special purposes and 3rd party api support.
         */
        IF targets('1.3.5')
        class IF !isBaseappName_Listener_ThirdParty extends ENDIFappName_Listener_Base_ThirdParty
        ELSE
        class ThirdPartyListenerIF !isBase extends BaseThirdPartyListenerELSE implements EventSubscriberInterfaceENDIF
        ENDIF
        {
            new ThirdParty().generate(it, isBase)
        }
    '''
}
