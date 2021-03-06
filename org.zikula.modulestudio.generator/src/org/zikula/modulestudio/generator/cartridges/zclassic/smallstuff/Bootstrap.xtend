package org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff

import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Bootstrap {
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    FileHelper fh = new FileHelper

    def generate(Application it, IFileSystemAccess fsa) {
        generateClassPair(fsa, getAppSourcePath + 'bootstrap.php',
            fh.phpFileContent(it, bootstrapBaseImpl), fh.phpFileContent(it, bootstrapImpl)
        )
    }

    def private bootstrapDocs() '''
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
    '''

    def private bootstrapBaseImpl(Application it) '''
        bootstrapDocs
        initExtensions
        IF !referredApplications.empty

            FOR referredApp : referredApplications
                if (ModUtil::available('referredApp.name.formatForCodeCapital')) {
                    // load Doctrine 2 data of referredApp.name.formatForCodeCapital
                    ModUtil::initOOModule('referredApp.name.formatForCodeCapital');
                }
            ENDFOR
        ENDIF
        archiveObjectsCall

    '''

    def private initExtensions(Application it) '''
        IF needsExtensionListener
            // initialise doctrine extension listeners
            $helper = ServiceUtil::getIF targets('1.3.5')ServiceENDIF('doctrine_extensions');
            initTree
            initLoggable
            initSluggable
            initSoftDeleteable
            initSortable
            initTimestampable
            initStandardFields
            initTranslatable
        ENDIF
    '''

    def private needsExtensionListener(Application it) {
        (hasTrees || hasLoggable || hasSluggable || hasSortable || hasTimestampable || hasTranslatable || hasStandardFieldEntities)
    }

    def private initTree(Application it) '''
        IF hasTrees
            $helper->getListener('tree');
        ENDIF
    '''

    def private initLoggable(Application it) '''
        IF hasLoggable
            $loggableListener = $helper->getListener('loggable');
            // set current user name to loggable listener
            $userName = UserUtil::isLoggedIn() ? UserUtil::getVar('uname') : __('Guest');
            $loggableListener->setUsername($userName);
        ENDIF
    '''

    def private initSluggable(Application it) '''
        IF hasSluggable
            $helper->getListener('sluggable');
        ENDIF
    '''

    def private initSoftDeleteable(Application it) '''
        IF hasSoftDeleteable && !targets('1.3.5')
            $helper->getListener('softdeleteable');
        ENDIF
    '''

    def private initSortable(Application it) '''
        IF hasSortable
            $helper->getListener('sortable');
        ENDIF
    '''

    def private initTimestampable(Application it) '''
        IF hasTimestampable || hasStandardFieldEntities
            $helper->getListener('timestampable');
        ENDIF
    '''

    def private initStandardFields(Application it) '''
        IF hasStandardFieldEntities
            $helper->getListener('standardfields');
        ENDIF
    '''

    def private initTranslatable(Application it) '''
        IF hasTranslatable
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
        ENDIF
    '''

    def private archiveObjectsCall(Application it) '''
        val entitiesWithArchive = getAllEntities.filter[hasArchive && getEndDateField !== null]
        IF !entitiesWithArchive.empty
            prefix()PerformRegularAmendments();
            
            function prefix()PerformRegularAmendments()
            {
                $currentFunc = FormUtil::getPassedValue('func', 'IF targets('1.3.5')mainELSEindexENDIF', 'GETPOST', FILTER_SANITIZE_STRING);
                if ($currentFunc == 'edit' || $currentFunc == 'initialize') {
                    return;
                }
            
                $randProbability = mt_rand(1, 1000);
            
                if ($randProbability < 750) {
                    return;
                }

                PageUtil::registerVar('appNameAutomaticArchiving', false, true);
                $serviceManager = ServiceUtil::getManager();
                IF targets('1.3.5')
                    $entityManager = $serviceManager->getIF targets('1.3.5')ServiceENDIF('doctrine.entitymanager');
                ELSE
                    $logger = $serviceManager->get('logger');
                ENDIF
                FOR entity : entitiesWithArchive

                    // perform update for entity.nameMultiple.formatForDisplay becoming archived
                    IF !targets('1.3.5')
                        $logger->notice('{app}: Automatic archiving for the {entity} entity started.', array('app' => 'appName', 'entity' => 'entity.name.formatForCode'));
                    ENDIF
                    IF targets('1.3.5')
                        $entityClass = 'appName_Entity_entity.name.formatForCodeCapital';
                        $repository = $entityManager->getRepository($entityClass);
                    ELSE
                        $repository = $serviceManager->get('appName.formatForDB.entity.name.formatForCode_factory')->getRepository();
                    ENDIF
                    $repository->archiveObjects();
                    IF !targets('1.3.5')
                        $logger->notice('{app}: Automatic archiving for the {entity} entity completed.', array('app' => 'appName', 'entity' => 'entity.name.formatForCode'));
                    ENDIF
                ENDFOR
                PageUtil::setVar('appNameAutomaticArchiving', false);
            }
        ENDIF
    '''

    def private bootstrapImpl(Application it) '''
        bootstrapDocs

        include_once 'Base/bootstrap.php';
    '''
}
