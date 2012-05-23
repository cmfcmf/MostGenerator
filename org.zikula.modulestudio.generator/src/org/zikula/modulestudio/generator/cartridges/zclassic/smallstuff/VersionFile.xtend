package org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.Entity
import de.guite.modulestudio.metamodel.modulestudio.JoinRelationship
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class VersionFile {
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension ModelExtensions = new ModelExtensions()
    @Inject extension ModelJoinExtensions = new ModelJoinExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension Utils = new Utils()

    FileHelper fh = new FileHelper()

    def generate(Application it, IFileSystemAccess fsa) {
        val destPath = appName.getAppSourceLibPath
        fsa.generateFile(destPath + 'Base/Version.php', versionBaseFile)
        fsa.generateFile(destPath + 'Version.php', versionFile)
    }

    def private versionBaseFile(Application it) '''
    	«fh.phpFileHeader(it)»
    	«appInfoBaseImpl»
    '''

    def private versionFile(Application it) '''
    	«fh.phpFileHeader(it)»
    	«appInfoImpl»
    '''

    def private appInfoBaseImpl(Application it) '''
        /**
         * Version information base class.
         */
        class «appName»_Base_Version extends Zikula_AbstractVersion
        {
            public function getMetaData()
            {
                $meta = array();
                // the current module version
                $meta['version']              = '«version»';
                // the displayed name of the module
                $meta['displayname']          = $this->__('«appName»');
                // the module description
                $meta['description']          = $this->__('«IF documentation != null && documentation != ''»«documentation.replaceAll("'", "\\'")»«ELSE»«appName» module generated by ModuleStudio «msVersion».«ENDIF»');
                //! url version of name, should be in lowercase without space
                $meta['url']                  = $this->__('«appName.formatForDB»');
                // core requirement
                $meta['core_min']             = '1.3.2'; // requires minimum 1.3.2 or later
                $meta['core_max']             = '1.3.99'; // not ready for 1.4.0 yet

                // define special capabilities of this module
                $meta['capabilities'] = array(
                                  HookUtil::SUBSCRIBER_CAPABLE => array('enabled' => true)
        /*,
                                  HookUtil::PROVIDER_CAPABLE => array('enabled' => true), // TODO: see #15
                                  'authentication' => array('version' => '1.0'),
                                  'profile'        => array('version' => '1.0', 'anotherkey' => 'anothervalue'),
                                  'message'        => array('version' => '1.0', 'anotherkey' => 'anothervalue')
        */
                );

                // permission schema
                «permissionSchema»

                «IF !referredApplications.isEmpty»
                    // module dependencies
                    $meta['dependencies'] = array(
                        «FOR referredApp : referredApplications SEPARATOR ','»«appDependency»«ENDFOR»
                    );
                «ENDIF»

                return $meta;
            }

            /**
             * Define hook subscriber«/* and provider (TODO see #15) */» bundles.
             */
            protected function setupHookBundles()
            {
        «val appName = name.formatForDB»
                «FOR entity : getAllEntities»
                    «/* we register one hook subscriber bundle foreach entity type */»
                    «val areaName = entity.nameMultiple.formatForDB»
                    $bundle = new Zikula_HookManager_SubscriberBundle($this->name, 'subscriber.«appName».ui_hooks.«areaName»', 'ui_hooks', __('«appName» «entity.nameMultiple.formatForDisplayCapital» Display Hooks'));
                    «/* $bundle->addEvent('hook type', 'event name triggered by *this* module');*/»
                    // Display hook for view/display templates.
                    $bundle->addEvent('display_view', '«appName».ui_hooks.«areaName».display_view');
                    // Display hook for create/edit forms.
                    $bundle->addEvent('form_edit', '«appName».ui_hooks.«areaName».form_edit');
                    // Display hook for delete dialogues.
                    $bundle->addEvent('form_delete', '«appName».ui_hooks.«areaName».form_delete');
                    // Validate input from an ui create/edit form.
                    $bundle->addEvent('validate_edit', '«appName».ui_hooks.«areaName».validate_edit');
                    // Validate input from an ui create/edit form (generally not used).
                    $bundle->addEvent('validate_delete', '«appName».ui_hooks.«areaName».validate_delete');
                    // Perform the final update actions for a ui create/edit form.
                    $bundle->addEvent('process_edit', '«appName».ui_hooks.«areaName».process_edit');
                    // Perform the final delete actions for a ui form.
                    $bundle->addEvent('process_delete', '«appName».ui_hooks.«areaName».process_delete');
                    $this->registerHookSubscriberBundle($bundle);

                    $bundle = new Zikula_HookManager_SubscriberBundle($this->name, 'subscriber.«appName».filter_hooks.«areaName»', 'filter_hooks', __('«appName» «entity.nameMultiple.formatForDisplayCapital» Filter Hooks'));
                    // A filter applied to the given area.
                    $bundle->addEvent('filter', '«appName».filter_hooks.«areaName».filter');
                    $this->registerHookSubscriberBundle($bundle);
                «ENDFOR»

                «/* TODO see #15
                    Example for name of provider area: provider_area.comments.general

                    $bundle = new Zikula_Version_HookProviderBundle($this->name, 'provider.ratings.ui_hooks.rating', 'ui_hooks', $this->__('Ratings Hook Poviders'));
                    $bundle->addServiceHandler('display_view', 'Ratings_Hooks', 'uiView', 'ratings.service');
                    // add other hooks as needed
                    $this->registerHookProviderBundle($bundle);

                    //... repeat as many times as necessary
                */»
            }
        }
    '''

    def private appInfoImpl(Application it) '''
        /**
         * Version information implementation class.
         */
        class «appName»_Version extends «appName»_Base_Version
        {
            // custom enhancements can go here
        }
    '''

    /**
     * Definition of permission schema arrays.
     */
    def private permissionSchema(Application it) '''
        $meta['securityschema'] = array(
            '«appName»::' => '::',
            '«appName»::Ajax' => '::',
            '«appName»:ItemListBlock:' => 'Block title::',
            «FOR entity : getAllEntities»«entity.permissionSchema(appName)»«ENDFOR»
        );
        // DEBUG: permission schema aspect ends
    '''


    def private appDependency(Application it) '''
        array('modname'    => '«appName»',
              'minversion' => '«version»',
              'maxversion' => '',
              'status'     => ModUtil::DEPENDENCY_REQUIRED«/* TODO: ModUtil::RECOMMENDED, ModUtil::CONFLICTS */»)
    '''

    def private permissionSchema(Entity it, String appName) '''
        '«appName»:«name.formatForCodeCapital»:' => '«name.formatForCodeCapital» ID::',
        «IF !getIncomingJoinRelations.isEmpty»
            «FOR relation : getIncomingJoinRelations»«relation.permissionSchema(appName)»«ENDFOR»
        «ENDIF»
    '''

    def private permissionSchema(JoinRelationship it, String modName) '''
        '«modName»:«source.name.formatForCodeCapital»:«target.name.formatForCodeCapital»' => '«source.name.formatForCodeCapital» ID:«target.name.formatForCodeCapital» ID:',
    '''
}
