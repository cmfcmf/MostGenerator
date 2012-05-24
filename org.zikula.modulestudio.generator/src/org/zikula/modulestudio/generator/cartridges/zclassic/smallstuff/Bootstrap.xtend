package org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Bootstrap {
    @Inject extension ModelBehaviourExtensions = new ModelBehaviourExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension Utils = new Utils()

    def generate(Application it, IFileSystemAccess fsa) {
        fsa.generateFile(getAppSourcePath(appName) + 'bootstrap.php', bootstrapFile)
    }

    def private bootstrapFile(Application it) '''
    	«new FileHelper().phpFileHeader(it)»
    	«bootstrapImpl»
    '''

    def private bootstrapImpl(Application it) '''
        /**
         * Bootstrap called when application is first initialised at runtime.
         *
         * This is only called once, and only if the core has reason to initialise this module,
         * usually to dispatch a controller request or API.
         *
         * For example you can register additional AutoLoaders with ZLoader::addAutoloader($namespace, $path)
         * whereby $namespace is the first part of the PEAR class name
         * and $path is the path to the containing folder.
         */
        «IF hasTrees || hasLoggable || hasSluggable || hasSortable || hasTimestampable || hasTranslatable || hasStandardFieldEntities»
            // initialise doctrine extension listeners
            $helper = ServiceUtil::getService('doctrine_extensions');
            «IF hasTrees»
                $helper->getListener('tree');
            «ENDIF»
            «IF hasLoggable»
                $loggableListener = $helper->getListener('loggable');
                // set current user name to loggable listener
                $userName = UserUtil::isLoggedIn() ? UserUtil::getVar('uname') : __('Guest');
                $loggableListener->setUsername($userName);
            «ENDIF»
            «IF hasSluggable»
                $helper->getListener('sluggable');
            «ENDIF»
            «IF hasSortable»
                $helper->getListener('sortable');
            «ENDIF»
            «IF hasTimestampable || hasStandardFieldEntities»
                $helper->getListener('timestampable');
            «ENDIF»
            «IF hasStandardFieldEntities»
                $helper->getListener('standardfields');
            «ENDIF»
            «IF hasTranslatable»
                $translatableListener = $helper->getListener('translatable');
                //$translatableListener->setTranslatableLocale(ZLanguage::getLanguageCode());
                $currentLanguage = preg_replace('#[^a-z-].#', '', FormUtil::getPassedValue('lang', System::getVar('language_i18n', 'en'), 'GET'));
                $translatableListener->setTranslatableLocale($currentLanguage);
                /**
                 * Sometimes it is desired to set a default translation as a fallback if record does not have a translation
                 * on used locale. In that case Translation Listener takes the current value of Entity.
                 * But there is a way to specify a default locale which would force Entity to not update it`s field
                 * if current locale is not a default.
                 */
                //$translatableListener->setDefaultLocale(System::getVar('language_i18n', 'en'));
            «ENDIF»
        «ENDIF»

    '''
}