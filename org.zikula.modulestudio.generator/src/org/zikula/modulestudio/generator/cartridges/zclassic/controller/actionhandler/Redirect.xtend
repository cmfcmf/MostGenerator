package org.zikula.modulestudio.generator.cartridges.zclassic.controller.actionhandler

import de.guite.modulestudio.metamodel.modulestudio.AjaxController
import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.Entity
import de.guite.modulestudio.metamodel.modulestudio.EntityTreeType
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.UrlExtensions
import org.zikula.modulestudio.generator.extensions.Utils

/**
 * Redirect processing functions for edit form handlers.
 */
class Redirect {
    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension NamingExtensions = new NamingExtensions
    extension UrlExtensions = new UrlExtensions
    extension Utils = new Utils

    def getRedirectCodes(Application it, String actionName) '''
        /**
         * Get list of allowed redirect codes.
         *
         * @return array list of possible redirect codes
         */
        protected function getRedirectCodes()
        {
            $codes = array();
            FOR someController : getAllControllers
                val controllerName = someController.formattedName
                IF someController.hasActions('index')
                    // IF targets('1.3.5')mainELSEindexENDIF page of controllerName area
                    $codes[] = 'controllerName';
                ENDIF
                IF someController.hasActions('view')
                    // controllerName list of entities
                    $codes[] = 'controllerNameView';
                ENDIF
                IF someController.hasActions('display')
                    // controllerName display page of treated entity
                    $codes[] = 'controllerNameDisplay';
                ENDIF
            ENDFOR

            return $codes;
        }
    '''

    def getRedirectCodes(Entity it, Application app, String actionName) '''
        /**
         * Get list of allowed redirect codes.
         *
         * @return array list of possible redirect codes
         */
        protected function getRedirectCodes()
        {
            $codes = parent::getRedirectCodes();
            FOR incomingRelation : getIncomingJoinRelationsWithOneSource.filter[source.container.application == app]
                val sourceEntity = incomingRelation.source
                IF sourceEntity.name != it.name
                    FOR someController : app.getAllControllers
                        val controllerName = someController.formattedName
                        IF someController.hasActions('view')
                            // controllerName list of sourceEntity.nameMultiple.formatForDisplay
                            $codes[] = 'controllerNameViewsourceEntity.name.formatForCodeCapital';
                        ENDIF
                        IF someController.hasActions('display')
                            // controllerName display page of treated sourceEntity.name.formatForDisplay
                            $codes[] = 'controllerNameDisplaysourceEntity.name.formatForCodeCapital';
                        ENDIF
                    ENDFOR
                ENDIF
            ENDFOR

            return $codes;
        }
    '''

    def getDefaultReturnUrl(Entity it, Application app, String actionName) '''
        /**
         * Get the default redirect url. Required if no returnTo parameter has been supplied.
         * This method is called in handleCommand so we know which command has been performed.
         *
         * @param array  $args List of arguments.
         *
         * @return string The default redirect url.
         */
        protected function getDefaultReturnUrl($args)
        {
            IF !app.targets('1.3.5')
                $serviceManager = $this->view->getServiceManager();

            ENDIF
            IF hasActions('view') || hasActions('index') || hasActions('display') && tree != EntityTreeType::NONE
                $legacyControllerType = $this->request->query->filter('lct', 'user', FILTER_SANITIZE_STRING);

            ENDIF
            IF hasActions('view')
                // redirect to the list of nameMultiple.formatForCode
                $viewArgs = array(IF app.targets('1.3.5')'ot' => $this->objectType, ENDIF'lct' => $legacyControllerType);
                IF tree != EntityTreeType::NONE
                    $viewArgs['tpl'] = 'tree';
                ENDIF
                IF app.targets('1.3.5')
                    $url = ModUtil::url($this->name, FormUtil::getPassedValue('type', 'user', 'GETPOST'), 'view', $viewArgs);
                ELSE
                    $url = $serviceManager->get('router')->generate('app.appName.formatForDB_' . $this->objectType . '_view', $viewArgs);
                ENDIF
            ELSEIF hasActions('index')
                // redirect to the IF app.targets('1.3.5')mainELSEindexENDIF page
                $indexArgs = array('lct' => $legacyControllerType);
                IF app.targets('1.3.5')
                    $url = ModUtil::url($this->name, FormUtil::getPassedValue('type', 'user', 'GETPOST'), 'main', $indexArgs);
                ELSE
                    $url = $serviceManager->get('router')->generate('app.appName.formatForDB_' . $this->objectType . '_index', $indexArgs);
                ENDIF
            ELSE
                $url = System::getHomepageUrl();
            ENDIF
            IF hasActions('display') && tree != EntityTreeType::NONE

                if ($args['commandName'] != 'delete' && !($this->mode == 'create' && $args['commandName'] == 'cancel')) {
                    // redirect to the detail page of treated name.formatForCode
                    IF app.targets('1.3.5')
                        $currentType = FormUtil::getPassedValue('type', 'user', 'GETPOST');
                        $displayArgs = array('ot' => $this->objectType, routeParamsLegacy('this->idValues', false, true));
                        $url = ModUtil::url($this->name, $currentType, 'display', $displayArgs);
                    ELSE
                        $displayArgs = array(routeParams('this->idValues', false));
                        $displayArgs['lct'] = $legacyControllerType;
                        $url = $serviceManager->get('router')->generate('app.appName.formatForDB_' . $this->objectType . '_display', $displayArgs);
                    ENDIF
                }
            ENDIF

            return $url;
        }
    '''

    def getRedirectUrl(Entity it, Application app, String actionName) '''
        /**
         * Get url to redirect to.
         *
         * @param array  $args List of arguments.
         *
         * @return string The redirect url.
         */
        protected function getRedirectUrl($args)
        {
            IF !app.targets('1.3.5')
                $serviceManager = $this->view->getContainer();

            ENDIF
            if ($this->inlineUsage == true) {
                $urlArgs = array('idPrefix'    => $this->idPrefix,
                                 'commandName' => $args['commandName']);
                foreach ($this->idFields as $idField) {
                    $urlArgs[$idField] = $this->idValues[$idField];
                }

                // inline usage, return to special function for closing the Zikula.UI.Window instance
                IF app.targets('1.3.5')
                    return ModUtil::url($this->name, FormUtil::getPassedValue('type', 'user', 'GETPOST'), 'handleInlineRedirect', $urlArgs);
                ELSE
                    return $serviceManager->get('router')->generate('app.appName.formatForDB_' . $this->objectType . '_handleInlineRedirect', $urlArgs);
                ENDIF
            }

            if ($this->repeatCreateAction) {
                return $this->repeatReturnUrl;
            }

            // normal usage, compute return url from given redirect code
            if (!in_array($this->returnTo, $this->getRedirectCodes())) {
                // invalid return code, so return the default url
                return $this->getDefaultReturnUrl($args);
            }

            // parse given redirect code and return corresponding url
            switch ($this->returnTo) {
                FOR someController : app.getAllControllers
                IF !(someController instanceof AjaxController)
                    val controllerName = someController.formattedName
                    IF someController.hasActions('index')
                        case 'controllerName':
                            IF app.targets('1.3.5')
                                return ModUtil::url($this->name, 'controllerName', 'main');
                            ELSE
                                return $serviceManager->get('router')->generate('app.appName.formatForDB_' . $this->objectType . '_index', array('lct' => 'controllerName'));
                            ENDIF
                    ENDIF
                    IF someController.hasActions('view')
                        case 'controllerNameView':
                            IF app.targets('1.3.5')
                                return ModUtil::url($this->name, 'controllerName', 'view', array('ot' => $this->objectType));
                            ELSE
                                return $serviceManager->get('router')->generate('app.appName.formatForDB_' . $this->objectType . '_view', array('lct' => 'controllerName'));
                            ENDIF
                    ENDIF
                    IF someController.hasActions('display')
                        case 'controllerNameDisplay':
                            if ($args['commandName'] != 'delete' && !($this->mode == 'create' && $args['commandName'] == 'cancel')) {
                                IF app.targets('1.3.5')
                                    $urlArgs['ot'] = $this->objectType;
                                ENDIF
                                foreach ($this->idFields as $idField) {
                                    $urlArgs[$idField] = $this->idValues[$idField];
                                }
                                IF app.targets('1.3.5')
                                    return ModUtil::url($this->name, 'controllerName', 'display', $urlArgs);
                                ELSE
                                    $urlArgs['lct'] = 'controllerName';
                                    return $serviceManager->get('router')->generate('app.appName.formatForDB_' . $this->objectType . '_display', $urlArgs);
                                ENDIF
                            }
                            return $this->getDefaultReturnUrl($args);
                    ENDIF
                ENDIF
                ENDFOR
                FOR incomingRelation : getIncomingJoinRelationsWithOneSource.filter[source.container.application == app]
                    val sourceEntity = incomingRelation.source
                    IF sourceEntity.name != it.name
                        FOR someController : app.getAllControllers
                        IF !(someController instanceof AjaxController)
                            val controllerName = someController.formattedName
                            IF someController.hasActions('view')
                                case 'controllerNameViewsourceEntity.name.formatForCodeCapital':
                                    IF app.targets('1.3.5')
                                        return ModUtil::url($this->name, 'controllerName', 'view', array('ot' => 'sourceEntity.name.formatForCode'));
                                    ELSE
                                        return $serviceManager->get('router')->generate('app.appName.formatForDB_sourceEntity.name.formatForCode_view', array('lct' => 'controllerName'));
                                    ENDIF
                            ENDIF
                            IF someController.hasActions('display')
                                case 'controllerNameDisplaysourceEntity.name.formatForCodeCapital':
                                    if (!empty($this->relationPresets['incomingRelation.getRelationAliasName(false)'])) {
                                        IF app.targets('1.3.5')
                                            return ModUtil::url($this->name, 'controllerName', 'display', array('ot' => 'sourceEntity.name.formatForCode', 'id' => $this->relationPresets['incomingRelation.getRelationAliasName(false)']IF sourceEntity.hasSluggableFields/*, 'slug' => 'TODO'*/ENDIF));
                                        ELSE
                                            return $serviceManager->get('router')->generate('app.appName.formatForDB_sourceEntity.name.formatForCode_display',  array('id' => $this->relationPresets['incomingRelation.getRelationAliasName(false)']IF sourceEntity.hasSluggableFields/*, 'slug' => 'TODO'*/ENDIF));
                                        ENDIF
                                    }
                                    return $this->getDefaultReturnUrl($args);
                            ENDIF
                        ENDIF
                        ENDFOR
                    ENDIF
                ENDFOR
                default:
                    return $this->getDefaultReturnUrl($args);
            }
        }
    '''
}
