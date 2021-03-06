package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity

import de.guite.modulestudio.metamodel.modulestudio.AdminController
import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.Controller
import de.guite.modulestudio.metamodel.modulestudio.Entity
import de.guite.modulestudio.metamodel.modulestudio.EntityTreeType
import de.guite.modulestudio.metamodel.modulestudio.ManyToManyRelationship
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.UrlExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ItemActions {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension NamingExtensions = new NamingExtensions
    extension UrlExtensions = new UrlExtensions
    extension Utils = new Utils

    def prepareItemActions(Entity it, Application app) '''
        /**
         * Collect available actions for this entity.
         */
        protected function prepareItemActions()
        {
            if (!empty($this->_actions)) {
                return;
            }

            $currentLegacyControllerType = FormUtil::getPassedValue('lct', 'user', 'GETPOST', FILTER_SANITIZE_STRING);
            $currentFunc = FormUtil::getPassedValue('func', 'IF app.targets('1.3.5')mainELSEindexENDIF', 'GETPOST', FILTER_SANITIZE_STRING);
            val appName = app.appName
            $dom = ZLanguage::getModuleDomain('appName');
            FOR controller : app.getAdminAndUserControllers
                if ($currentLegacyControllerType == 'controller.formattedName') {
                    itemActionsTargetingDisplay(app, controller)
                    itemActionsTargetingEdit(app, controller)
                    itemActionsTargetingView(app, controller)
                    itemActionsForAddingRelatedItems(app, controller)
                }
            ENDFOR
        }
    '''

    def private itemActionsTargetingDisplay(Entity it, Application app, Controller controller) '''
        IF controller.hasActions('view')
            if (in_array($currentFunc, array('IF app.targets('1.3.5')mainELSEindexENDIF', 'view'))) {
                IF controller.tempIsAdminController && container.application.hasUserController && container.application.getMainUserController.hasActions('display')
                    $this->_actions[] = array(
                        IF app.targets('1.3.5')
                            'url' => array('type' => 'user', 'func' => 'display', 'arguments' => array('ot' => 'name.formatForCode', routeParamsLegacy('this', false, true))),
                        ELSE
                            'url' => array('type' => 'name.formatForCode', 'func' => 'display', 'arguments' => array('lct' => 'user', routeParams('this', false))),
                        ENDIF
                        'icon' => 'IF app.targets('1.3.5')previewELSEsearch-plusENDIF',
                        'linkTitle' => __('Open preview page', $dom),
                        'linkText' => __('Preview', $dom)
                    );
                ENDIF
                IF controller.hasActions('display')
                    $this->_actions[] = array(
                        IF app.targets('1.3.5')
                            'url' => array('type' => 'controller.formattedName', 'func' => 'display', 'arguments' => array('ot' => 'name.formatForCode', routeParamsLegacy('this', false, true))),
                        ELSE
                            'url' => array('type' => 'name.formatForCode', 'func' => 'display', 'arguments' => array('lct' => 'controller.formattedName', routeParams('this', false))),
                        ENDIF
                        'icon' => 'IF app.targets('1.3.5')displayELSEeyeENDIF',
                        'linkTitle' => str_replace('"', '', $this->getTitleFromDisplayPattern())/*__('Open detail page', $dom)*/,
                        'linkText' => __('Details', $dom)
                    );
                ENDIF
            }
        ENDIF
    '''

    def private itemActionsTargetingEdit(Entity it, Application app, Controller controller) '''
        IF controller.hasActions('view') || controller.hasActions('display')
            if (in_array($currentFunc, array('IF app.targets('1.3.5')mainELSEindexENDIF', 'view', 'display'))) {
                IF controller.hasActions('edit') || controller.hasActions('delete')
                     $component = 'app.appName:name.formatForCodeCapital:';
                     $instance = idFieldsAsParameterCode('this') . '::';
                ENDIF
                IF controller.hasActions('edit')
                    if (SecurityUtil::checkPermission($component, $instance, ACCESS_EDIT)) {
                        IF ownerPermission && standardFields
                            // only allow editing for the owner or people with higher permissions
                            if ($this['createdUserId'] == UserUtil::getVar('uid') || SecurityUtil::checkPermission($component, $instance, ACCESS_ADD)) {
                                itemActionsForEditAction(controller)
                            }
                        ELSE
                            itemActionsForEditAction(controller)
                        ENDIF
                    }
                ENDIF
                IF controller.hasActions('delete')
                    if (SecurityUtil::checkPermission($component, $instance, ACCESS_DELETE)) {
                        $this->_actions[] = array(
                            IF app.targets('1.3.5')
                                'url' => array('type' => 'controller.formattedName', 'func' => 'delete', 'arguments' => array('ot' => 'name.formatForCode', routeParamsLegacy('this', false, false))),
                            ELSE
                                'url' => array('type' => 'name.formatForCode', 'func' => 'delete', 'arguments' => array('lct' => 'controller.formattedName', routeParams('this', false))),
                            ENDIF
                            'icon' => 'IF app.targets('1.3.5')deleteELSEtrash-oENDIF',
                            'linkTitle' => __('Delete', $dom),
                            'linkText' => __('Delete', $dom)
                        );
                    }
                ENDIF
            }
        ENDIF
    '''

    def private itemActionsTargetingView(Entity it, Application app, Controller controller) '''
        IF controller.hasActions('display')
            if ($currentFunc == 'display') {
                IF controller.hasActions('view')
                    $this->_actions[] = array(
                        IF app.targets('1.3.5')
                            'url' => array('type' => 'controller.formattedName', 'func' => 'view', 'arguments' => array('ot' => 'name.formatForCode')),
                        ELSE
                            'url' => array('type' => 'name.formatForCode', 'func' => 'view', 'arguments' => array('lct' => 'controller.formattedName')),
                        ENDIF
                        'icon' => 'IF app.targets('1.3.5')backELSEreplyENDIF',
                        'linkTitle' => __('Back to overview', $dom),
                        'linkText' => __('Back to overview', $dom)
                    );
                ENDIF
            }
        ENDIF
    '''

    def private itemActionsForAddingRelatedItems(Entity it, Application app, Controller controller) '''
        val refedElems = getOutgoingJoinRelations.filter[e|e.target.container.application == it.container.application] + incoming.filter(ManyToManyRelationship).filter[e|e.source.container.application == it.container.application]
        IF !refedElems.empty && controller.hasActions('edit')

            // more actions for adding new related items
            $authAdmin = SecurityUtil::checkPermission($component, $instance, ACCESS_ADMIN);
            /* TODO review the permission levels and maybe define them for each related entity
              * ACCESS_ADMIN for admin controllers else: IF relatedEntity.workflow == EntityWorkflowType::NONEEDITELSECOMMENTENDIF
              */
            $uid = UserUtil::getVar('uid');
            if ($authAdmin || (isset($uid) && isset($this->createdUserId) && $this->createdUserId == $uid)) {
                FOR elem : refedElems

                    val useTarget = (elem.source == it)
                    val relationAliasName = elem.getRelationAliasName(useTarget).formatForCode.toFirstLower
                    val relationAliasNameParam = elem.getRelationAliasName(!useTarget).formatForCodeCapital
                    val otherEntity = (if (!useTarget) elem.source else elem.target)
                    val many = elem.isManySideDisplay(useTarget)
                    IF !many
                        if (!isset($this->relationAliasName) || $this->relationAliasName == null) {
                            IF app.targets('1.3.5')
                                $urlArgs = array('ot' => 'otherEntity.name.formatForCode',
                                                 'relationAliasNameParam.formatForDB' => idFieldsAsParameterCode('this'));
                            ELSE
                                $urlArgs = array('lct' => 'controller.formattedName',
                                                 'relationAliasNameParam.formatForDB' => idFieldsAsParameterCode('this'));
                            ENDIF
                            if ($currentFunc == 'view') {
                                $urlArgs['returnTo'] = 'controller.formattedNameViewname.formatForCodeCapital';
                            } elseif ($currentFunc == 'display') {
                                $urlArgs['returnTo'] = 'controller.formattedNameDisplayname.formatForCodeCapital';
                            }
                            $this->_actions[] = array(
                                IF app.targets('1.3.5')
                                    'url' => array('type' => 'controller.formattedName', 'func' => 'edit', 'arguments' => $urlArgs),
                                ELSE
                                    'url' => array('type' => 'otherEntity.name.formatForCode', 'func' => 'edit', 'arguments' => $urlArgs),
                                ENDIF
                                'icon' => 'IF app.targets('1.3.5')addELSEplusENDIF',
                                'linkTitle' => __('Create otherEntity.name.formatForDisplay', $dom),
                                'linkText' => __('Create otherEntity.name.formatForDisplay', $dom)
                            );
                        }
                    ELSE
                        IF app.targets('1.3.5')
                            $urlArgs = array('ot' => 'otherEntity.name.formatForCode',
                                             'relationAliasNameParam.formatForDB' => idFieldsAsParameterCode('this'));
                        ELSE
                            $urlArgs = array('lct' => 'controller.formattedName',
                                             'relationAliasNameParam.formatForDB' => idFieldsAsParameterCode('this'));
                        ENDIF
                        if ($currentFunc == 'view') {
                            $urlArgs['returnTo'] = 'controller.formattedNameViewname.formatForCodeCapital';
                        } elseif ($currentFunc == 'display') {
                            $urlArgs['returnTo'] = 'controller.formattedNameDisplayname.formatForCodeCapital';
                        }
                        $this->_actions[] = array(
                            IF app.targets('1.3.5')
                                'url' => array('type' => 'controller.formattedName', 'func' => 'edit', 'arguments' => $urlArgs),
                            ELSE
                                'url' => array('type' => 'otherEntity.name.formatForCode', 'func' => 'edit', 'arguments' => $urlArgs),
                            ENDIF
                            'icon' => 'IF app.targets('1.3.5')addELSEplusENDIF',
                            'linkTitle' => __('Create otherEntity.name.formatForDisplay', $dom),
                            'linkText' => __('Create otherEntity.name.formatForDisplay', $dom)
                        );
                    ENDIF
                ENDFOR
            }
        ENDIF
    '''

    def private tempIsAdminController(Controller it) {
        switch it {
            AdminController: true
            default: false
        }
    }

    def private itemActionsForEditAction(Entity it, Controller controller) '''
        IF !readOnly/*create is allowed, but editing not*/
            $this->_actions[] = array(
                IF container.application.targets('1.3.5')
                    'url' => array('type' => 'controller.formattedName', 'func' => 'edit', 'arguments' => array('ot' => 'name.formatForCode', routeParamsLegacy('this', false, false))),
                ELSE
                    'url' => array('type' => 'name.formatForCode', 'func' => 'edit', 'arguments' => array('lct' => 'controller.formattedName', routeParams('this', false))),
                ENDIF
                'icon' => 'IF container.application.targets('1.3.5')editELSEpencil-square-oENDIF',
                'linkTitle' => __('Edit', $dom),
                'linkText' => __('Edit', $dom)
            );
        ENDIF
        IF tree == EntityTreeType::NONE
                $this->_actions[] = array(
                    IF container.application.targets('1.3.5')
                        'url' => array('type' => 'controller.formattedName', 'func' => 'edit', 'arguments' => array('ot' => 'name.formatForCode', routeParamsLegacy('this', false, false, 'astemplate'))),
                    ELSE
                        'url' => array('type' => 'name.formatForCode', 'func' => 'edit', 'arguments' => array('lct' => 'controller.formattedName', routeParams('this', false, 'astemplate'))),
                    ENDIF
                    'icon' => 'IF container.application.targets('1.3.5')saveasELSEfiles-oENDIF',
                    'linkTitle' => __('Reuse for new item', $dom),
                    'linkText' => __('Reuse', $dom)
                );
        ENDIF
    '''
}