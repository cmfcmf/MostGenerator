package org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions

import de.guite.modulestudio.metamodel.modulestudio.AjaxController
import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.Controller
import de.guite.modulestudio.metamodel.modulestudio.StringField
import de.guite.modulestudio.metamodel.modulestudio.TextField
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.ControllerHelper
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Ajax {
    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension Utils = new Utils

    def dispatch additionalAjaxFunctionsBase(Controller it, Application app) {
    }

    def dispatch additionalAjaxFunctionsBase(AjaxController it, Application app) '''
        userSelectorsBase(app)
        IF app.generateExternalControllerAndFinder

            getItemListFinderBase(app)
        ENDIF
        val joinRelations = app.getJoinRelations
        IF !joinRelations.empty

            getItemListAutoCompletionBase(app)
        ENDIF
        IF app.getAllEntities.exists[getUniqueDerivedFields.filter[!primaryKey].size > 0]
        || (app.hasSluggable && !app.getAllEntities.filter[hasSluggableFields && slugUnique].empty)

            checkForDuplicateBase(app)
        ENDIF
        IF app.hasBooleansWithAjaxToggle

            toggleFlagBase(app)
        ENDIF
        IF app.hasTrees
        
            handleTreeOperationBase(app)
        ENDIF
    '''

    def private userSelectorsBase(AjaxController it, Application app) '''
        val userFields = app.getAllUserFields
        IF !userFields.empty
            FOR userField : userFields

                public function getuserField.entity.name.formatForCodeCapitaluserField.name.formatForCodeCapitalUsers()IF !app.targets('1.3.5')Action(Request $request)ENDIF
                {
                    return $this->getCommonUsersListIF container.application.targets('1.3.5')()ELSEAction($request)ENDIF;
                }
            ENDFOR

            getCommonUsersListBase(app)
        ENDIF
    '''

    def private getCommonUsersListBase(AjaxController it, Application app) '''
        getCommonUsersListDocBlock(true)
        getCommonUsersListSignature
        {
            getCommonUsersListBaseImpl(app)
        }
    '''

    def private getCommonUsersListDocBlock(AjaxController it, Boolean isBase) '''
        /**
         * Retrieve a general purpose list of users.
        IF !container.application.targets('1.3.5') && !isBase
        ' '*
        ' '* @Route("/getCommonUsersList", options={"expose"=true})
        /*' '* @Method("POST")*/
        ENDIF
         *
         * @param string $fragment The search fragment.
         *
         * @return IF container.application.targets('1.3.5')Zikula_Response_Ajax_PlainELSEPlainResponseENDIF
         */ 
    '''

    def private getCommonUsersListSignature(AjaxController it) '''
        public function getCommonUsersListIF container.application.targets('1.3.5')()ELSEAction(Request $request)ENDIF
    '''

    def private getCommonUsersListBaseImpl(AjaxController it, Application app) '''
        if (!SecurityUtil::checkPermission($this->name . '::Ajax', '::', ACCESS_EDIT)) {
            return true;
        }

        $fragment = '';
        if ($IF app.targets('1.3.5')this->ENDIFrequest->IF app.targets('1.3.5')isPost()ELSEisMethod('POST')ENDIF && $IF app.targets('1.3.5')this->ENDIFrequest->request->has('fragment')) {
            $fragment = $IF app.targets('1.3.5')this->ENDIFrequest->request->get('fragment', '');
        } elseif ($this->request->IF app.targets('1.3.5')isGet()ELSEisMethod('GET')ENDIF && $this->request->query->has('fragment')) {
            $fragment = $IF app.targets('1.3.5')this->ENDIFrequest->query->get('fragment', '');
        }

        IF app.targets('1.3.5')
            ModUtil::dbInfoLoad('Users');
            $tables = DBUtil::getTables();

            $usersColumn = $tables['users_column'];

            $where = 'WHERE ' . $usersColumn['uname'] . ' REGEXP \'(' . DataUtil::formatForStore($fragment) . ')\'';
            $results = DBUtil::selectObjectArray('users', $where);
        ELSE
            ModUtil::initOOModule('ZikulaUsersModule');

            $dql = 'SELECT u FROM Zikula\Module\UsersModule\Entity\UserEntity u WHERE u.uname LIKE :fragment';
            $query = $this->entityManager->createQuery($dql);
            $query->setParameter('fragment', '%' . $fragment . '%');
            $results = $query->getArrayResult();
        ENDIF

        // load avatar plugin
        IF app.targets('1.3.5')
            include_once 'lib/viewplugins/function.useravatar.php';
        ELSE
            include_once 'lib/legacy/viewplugins/function.useravatar.php';
        ENDIF
        $view = Zikula_View::getInstance('app.appName', false);

        IF app.targets('1.3.5')
            $out = '<ul>';
            if (is_array($results) && count($results) > 0) {
                foreach ($results as $result) {
                    $itemId = 'user' . $result['uid'];
                    $itemTitle = DataUtil::formatForDisplay($result['uname']);
                    $itemTitleStripped = str_replace('"', '', $itemTitle);
                    $out .= '<li id="' . $itemId . '" title="' . $itemTitleStripped . '">';
                    $out .= '<div class="itemtitle">' . $itemTitle . '</div>';
                    $out .= '<input type="hidden" id="' . $itemTitleStripped . '" value="' . $result['uid'] . '" />';
                    $out .= '<div id="itemPreview' . $itemId . '" class="itempreview informal">' . smarty_function_useravatar(array('uid' => $result['uid'], 'rating' => 'g'), $view) . '</div>';
                    $out .= '</li>';
                }
            }
            $out .= '</ul>';

            IF app.targets('1.3.5')
                return new Zikula_Response_Ajax_Plain($out);
            ELSE
                return new PlainResponse($out);
            ENDIF
        ELSE
            $resultItems = array();
            if (is_array($results) && count($results) > 0) {
                foreach ($results as $result) {
                    $resultItems[] = array(
                        'uid' => $result['uid'],
                        'uname' => DataUtil::formatForDisplay($result['uname']),
                        'avatar' => smarty_function_useravatar(array('uid' => $result['uid'], 'rating' => 'g'), $view)
                    );
                }
            }

            return new JsonResponse($resultItems);
        ENDIF
    '''

    def private getItemListFinderBase(AjaxController it, Application app) '''
        getItemListFinderDocBlock(true)
        getItemListFinderSignature
        {
            getItemListFinderBaseImpl(app)
        }

        getItemListFinderPrepareSlimItem(app)
    '''

    def private getItemListFinderDocBlock(AjaxController it, Boolean isBase) '''
        /**
         * Retrieve item list for finder selections in Forms, Content type plugin and Scribite.
        IF !container.application.targets('1.3.5') && !isBase
        ' '*
        ' '* @Route("/getItemListFinder", options={"expose"=true})
        /*' '* @Method("POST")*/
        ENDIF
         *
         * @param string $ot      Name of currently used object type.
         * @param string $sort    Sorting field.
         * @param string $sortdir Sorting direction.
         *
         * @return IF container.application.targets('1.3.5')Zikula_Response_AjaxELSEAjaxResponseENDIF
         */
    '''

    def private getItemListFinderSignature(AjaxController it) '''
        public function getItemListFinderIF container.application.targets('1.3.5')()ELSEAction(Request $request)ENDIF
    '''

    def private getItemListFinderBaseImpl(AjaxController it, Application app) '''
        if (!SecurityUtil::checkPermission($this->name . '::Ajax', '::', ACCESS_EDIT)) {
            return true;
        }

        $objectType = 'app.getLeadingEntity.name.formatForCode';
        if ($IF app.targets('1.3.5')this->ENDIFrequest->IF app.targets('1.3.5')isPost()ELSEisMethod('POST')ENDIF && $IF app.targets('1.3.5')this->ENDIFrequest->request->has('ot')) {
            $objectType = $IF app.targets('1.3.5')this->ENDIFrequest->request->filter('ot', 'app.getLeadingEntity.name.formatForCode', IF !app.targets('1.3.5')false, ENDIFFILTER_SANITIZE_STRING);
        } elseif ($IF app.targets('1.3.5')this->ENDIFrequest->IF app.targets('1.3.5')isGet()ELSEisMethod('GET')ENDIF && $IF app.targets('1.3.5')this->ENDIFrequest->query->has('ot')) {
            $objectType = $IF app.targets('1.3.5')this->ENDIFrequest->query->filter('ot', 'app.getLeadingEntity.name.formatForCode', IF !app.targets('1.3.5')false, ENDIFFILTER_SANITIZE_STRING);
        }
        IF app.targets('1.3.5')
            $controllerHelper = new app.appName_Util_Controller($this->serviceManager);
        ELSE
            $controllerHelper = $this->serviceManager->get('app.appName.formatForDB.controller_helper');
        ENDIF
        $utilArgs = array('controller' => 'formattedName', 'action' => 'getItemListFinder');
        if (!in_array($objectType, $controllerHelper->getObjectTypes('controllerAction', $utilArgs))) {
            $objectType = $controllerHelper->getDefaultObjectType('controllerAction', $utilArgs);
        }

        IF app.targets('1.3.5')
            $entityClass = 'app.appName_Entity_' . ucfirst($objectType);
            $repository = $this->entityManager->getRepository($entityClass);
            $repository->setControllerArguments(array());
        ELSE
            $repository = $this->serviceManager->get('app.appName.formatForDB.' . $objectType . '_factory')->getRepository();
            $repository->setRequest($request);
        ENDIF
        $idFields = ModUtil::apiFunc($this->name, 'selection', 'getIdFields', array('ot' => $objectType));

        $descriptionField = $repository->getDescriptionFieldName();

        $sort = $IF app.targets('1.3.5')this->ENDIFrequest->request->filter('sort', '', IF !app.targets('1.3.5')false, ENDIFFILTER_SANITIZE_STRING);
        if (empty($sort) || !in_array($sort, $repository->getAllowedSortingFields())) {
            $sort = $repository->getDefaultSortingField();
        }

        $sdir = $IF app.targets('1.3.5')this->ENDIFrequest->request->filter('sortdir', '', IF !app.targets('1.3.5')false, ENDIFFILTER_SANITIZE_STRING);
        $sdir = strtolower($sdir);
        if ($sdir != 'asc' && $sdir != 'desc') {
            $sdir = 'asc';
        }

        $where = ''; // filters are processed inside the repository class
        $sortParam = $sort . ' ' . $sdir;

        $entities = $repository->selectWhere($where, $sortParam);

        $slimItems = array();
        $component = $this->name . ':' . ucfirst($objectType) . ':';
        foreach ($entities as $item) {
            $itemId = '';
            foreach ($idFields as $idField) {
                $itemId .= ((!empty($itemId)) ? '_' : '') . $item[$idField];
            }
            if (!SecurityUtil::checkPermission($component, $itemId . '::', ACCESS_READ)) {
                continue;
            }
            $slimItems[] = $this->prepareSlimItem($objectType, $item, $itemId, $descriptionField);
        }

        return new IF app.targets('1.3.5')Zikula_Response_AjaxELSEAjaxResponseENDIF($slimItems);
    '''

    def private getItemListFinderPrepareSlimItem(AjaxController it, Application app) '''
        /**
         * Builds and returns a slim data array from a given entity.
         *
         * @param string $objectType       The currently treated object type.
         * @param object $item             The currently treated entity.
         * @param string $itemid           Data item identifier(s).
         * @param string $descriptionField Name of item description field.
         *
         * @return array The slim data representation.
         */
        protected function prepareSlimItem($objectType, $item, $itemId, $descriptionField)
        {
            $view = Zikula_View::getInstance('app.appName', false);
            $view->assign($objectType, $item);
            $previewInfo = base64_encode($view->fetch(IF app.targets('1.3.5')'external/' . $objectTypeELSE'External/' . ucfirst($objectType)ENDIF . '/info.tpl'));

            $title = $item->getTitleFromDisplayPattern();
            $description = ($descriptionField != '') ? $item[$descriptionField] : '';

            return array('id'          => $itemId,
                         'title'       => str_replace('&amp;', '&', $title),
                         'description' => $description,
                         'previewInfo' => $previewInfo);
        }
    '''

    def private getItemListAutoCompletionBase(AjaxController it, Application app) '''
        getItemListAutoCompletionDocBlock(true)
        getItemListAutoCompletionSignature
        {
            getItemListAutoCompletionBaseImpl(app)
        }
    '''

    def private getItemListAutoCompletionDocBlock(AjaxController it, Boolean isBase) '''
        /**
         * Searches for entities for auto completion usage.
        IF !container.application.targets('1.3.5') && !isBase
        ' '*
        ' '* @Route("/getItemListAutoCompletion", options={"expose"=true})
        /*' '* @Method("POST")*/
        ENDIF
         *
         * @param string $ot       Treated object type.
         * @param string $fragment The fragment of the entered item name.
         * @param string $exclude  Comma separated list with ids of other items (to be excluded from search).
         *
         * @return IF container.application.targets('1.3.5')Zikula_Response_Ajax_PlainELSEPlainResponseENDIF
         */
    '''

    def private getItemListAutoCompletionSignature(AjaxController it) '''
        public function getItemListAutoCompletionIF container.application.targets('1.3.5')()ELSEAction(Request $request)ENDIF
    '''

    def private getItemListAutoCompletionBaseImpl(AjaxController it, Application app) '''
        if (!SecurityUtil::checkPermission($this->name . '::Ajax', '::', ACCESS_EDIT)) {
            return true;
        }

        $objectType = 'app.getLeadingEntity.name.formatForCode';
        if ($IF app.targets('1.3.5')this->ENDIFrequest->IF app.targets('1.3.5')isPost()ELSEisMethod('POST')ENDIF && $IF app.targets('1.3.5')this->ENDIFrequest->request->has('ot')) {
            $objectType = $IF app.targets('1.3.5')this->ENDIFrequest->request->filter('ot', 'app.getLeadingEntity.name.formatForCode', IF !app.targets('1.3.5')false, ENDIFFILTER_SANITIZE_STRING);
        } elseif ($IF app.targets('1.3.5')this->ENDIFrequest->IF app.targets('1.3.5')isGet()ELSEisMethod('GET')ENDIF && $IF app.targets('1.3.5')this->ENDIFrequest->query->has('ot')) {
            $objectType = $IF app.targets('1.3.5')this->ENDIFrequest->query->filter('ot', 'app.getLeadingEntity.name.formatForCode', IF !app.targets('1.3.5')false, ENDIFFILTER_SANITIZE_STRING);
        }
        IF app.targets('1.3.5')
            $controllerHelper = new app.appName_Util_Controller($this->serviceManager);
        ELSE
            $controllerHelper = $this->serviceManager->get('app.appName.formatForDB.controller_helper');
        ENDIF
        $utilArgs = array('controller' => 'formattedName', 'action' => 'getItemListAutoCompletion');
        if (!in_array($objectType, $controllerHelper->getObjectTypes('controllerAction', $utilArgs))) {
            $objectType = $controllerHelper->getDefaultObjectType('controllerAction', $utilArgs);
        }

        IF app.targets('1.3.5')
            $entityClass = 'app.appName_Entity_' . ucfirst($objectType);
            $repository = $this->entityManager->getRepository($entityClass);
        ELSE
            $repository = $this->serviceManager->get('app.appName.formatForDB.' . $objectType . '_factory')->getRepository();
        ENDIF
        $idFields = ModUtil::apiFunc($this->name, 'selection', 'getIdFields', array('ot' => $objectType));

        $fragment = '';
        $exclude = '';
        if ($IF app.targets('1.3.5')this->ENDIFrequest->IF app.targets('1.3.5')isPost()ELSEisMethod('POST')ENDIF && $IF app.targets('1.3.5')this->ENDIFrequest->request->has('fragment')) {
            $fragment = $IF app.targets('1.3.5')this->ENDIFrequest->request->get('fragment', '');
            $exclude = $IF app.targets('1.3.5')this->ENDIFrequest->request->get('exclude', '');
        } elseif ($IF app.targets('1.3.5')this->ENDIFrequest->IF app.targets('1.3.5')isGet()ELSEisMethod('GET')ENDIF && $IF app.targets('1.3.5')this->ENDIFrequest->query->has('fragment')) {
            $fragment = $IF app.targets('1.3.5')this->ENDIFrequest->query->get('fragment', '');
            $exclude = $IF app.targets('1.3.5')this->ENDIFrequest->query->get('exclude', '');
        }
        $exclude = ((!empty($exclude)) ? array($exclude) : array());

        // parameter for used sorting field
        $sort = $this->request->query->get('sort', '');
        new ControllerHelper().defaultSorting(it)
        $sortParam = $sort . ' asc';

        $currentPage = 1;
        $resultsPerPage = 20;

        // get objects from database
        list($entities, $objectCount) = $repository->selectSearch($fragment, $exclude, $sortParam, $currentPage, $resultsPerPage);

        IF app.targets('1.3.5')
            $out = '<ul>';
            if ((is_array($entities) || is_object($entities)) && count($entities) > 0) {
                prepareForAutoCompletionProcessing(app)
                foreach ($entities as $item) {
                    // class="informal" --> show in dropdown, but do nots copy in the input field after selection
                    $itemTitle = $item->getTitleFromDisplayPattern();
                    $itemTitleStripped = str_replace('"', '', $itemTitle);
                    $itemDescription = isset($item[$descriptionFieldName]) && !empty($item[$descriptionFieldName]) ? $item[$descriptionFieldName] : '';//$this->__('No description yet.');
                    $itemId = $item->createCompositeIdentifier();

                    $out .= '<li id="' . $itemId . '" title="' . $itemTitleStripped . '">';
                    $out .= '<div class="itemtitle">' . $itemTitle . '</div>';
                    if (!empty($itemDescription)) {
                        $out .= '<div class="itemdesc informal">' . substr($itemDescription, 0, 50) . '&hellip;</div>';
                    }
                    IF app.hasImageFields

                        // check for preview image
                        if (!empty($previewFieldName) && !empty($item[$previewFieldName]) && isset($item[$previewFieldName . 'FullPath'])) {
                            $fullObjectId = $objectType . '-' . $itemId;
                            $thumbImagePath = $imagineManager->getThumb($item[$previewFieldName], $fullObjectId);
                            $preview = '<img src="' . $thumbImagePath . '" width="50" height="50" alt="' . $itemTitleStripped . '" />';
                            $out .= '<div id="itemPreview' . $itemId . '" class="itempreview informal">' . $preview . '</div>';
                        }
                    ENDIF

                    $out .= '</li>';
                }
            }
            $out .= '</ul>';

            // return response
            return new IF app.targets('1.3.5')Zikula_Response_Ajax_PlainELSEPlainResponseENDIF($out);
        ELSE
            $resultItems = array();

            if ((is_array($entities) || is_object($entities)) && count($entities) > 0) {
                prepareForAutoCompletionProcessing(app)
                foreach ($entities as $item) {
                    $itemTitle = $item->getTitleFromDisplayPattern();
                    $itemTitleStripped = str_replace('"', '', $itemTitle);
                    $itemDescription = isset($item[$descriptionFieldName]) && !empty($item[$descriptionFieldName]) ? $item[$descriptionFieldName] : '';//$this->__('No description yet.')
                    if (!empty($itemDescription)) {
                        $itemDescription = substr($itemDescription, 0, 50) . '&hellip;';
                    }

                    $resultItem = array(
                        'id' => $item->createCompositeIdentifier(),
                        'title' => $item->getTitleFromDisplayPattern(),
                        'description' => $itemDescription,
                        'image' => ''
                    );
                    IF app.hasImageFields

                        // check for preview image
                        if (!empty($previewFieldName) && !empty($item[$previewFieldName]) && isset($item[$previewFieldName . 'FullPath'])) {
                            $fullObjectId = $objectType . '-' . $itemId;
                            $thumbImagePath = $imagineManager->getThumb($item[$previewFieldName], $fullObjectId);
                            $preview = '<img src="' . $thumbImagePath . '" width="50" height="50" alt="' . $itemTitleStripped . '" />';
                            $resultItem['image'] = $preview;
                        }
                    ENDIF

                    $resultItems[] = $resultItem;
                }
            }

            return new JsonResponse($resultItems);
        ENDIF
    '''

    def private prepareForAutoCompletionProcessing(AjaxController it, Application app) '''
        $descriptionFieldName = $repository->getDescriptionFieldName();
        $previewFieldName = $repository->getPreviewFieldName();
        IF app.hasImageFields
            if (!empty($previewFieldName)) {
                IF app.targets('1.3.5')
                    $imageHelper = new app.appName_Util_Image($this->serviceManager);
                ELSE
                    $imageHelper = $this->serviceManager->get('app.appName.formatForDB.image_helper');
                ENDIF
                $imagineManager = $imageHelper->getManager($objectType, $previewFieldName, 'controllerAction', $utilArgs);
            }
        ENDIF
    '''

    def private checkForDuplicateBase(AjaxController it, Application app) '''
        checkForDuplicateDocBlock(true)
        checkForDuplicateSignature
        {
            checkForDuplicateBaseImpl(app)
        }
    '''

    def private checkForDuplicateDocBlock(AjaxController it, Boolean isBase) '''
        /**
         * Checks whether a field value is a duplicate or not.
        IF !container.application.targets('1.3.5') && !isBase
        ' '*
        ' '* @Route("/checkForDuplicate", options={"expose"=true})
        ' '* @Method("POST")
        ENDIF
         *
         * @param string $ot Treated object type.
         * @param string $fn Name of field to be checked.
         * @param string $v  The value to be checked for uniqueness.
         * @param string $ex Optional identifier to be excluded from search.
         *
         * @return IF container.application.targets('1.3.5')Zikula_Response_AjaxELSEAjaxResponseENDIF
         IF !container.application.targets('1.3.5')
         *
         * @throws AccessDeniedException Thrown if the user doesn't have required permissions
         ENDIF
         */
    '''

    def private checkForDuplicateSignature(AjaxController it) '''
        public function checkForDuplicateIF container.application.targets('1.3.5')()ELSEAction(Request $request)ENDIF
    '''

    def private checkForDuplicateBaseImpl(AjaxController it, Application app) '''
        $this->checkAjaxToken();
        IF app.targets('1.3.5')
            $this->throwForbiddenUnless(SecurityUtil::checkPermission($this->name . '::Ajax', '::', ACCESS_EDIT));
        ELSE
            if (!SecurityUtil::checkPermission($this->name . '::Ajax', '::', ACCESS_EDIT)) {
                throw new AccessDeniedException();
            }
        ENDIF

        prepareDuplicateCheckParameters(app)
        IF app.targets('1.3.5')
            $entityClass = 'app.appName_Entity_' . ucfirst($objectType);
            /* can probably be removed
             * $object = new $entityClass();
             */ 
        ELSE
            /* can probably be removed
             * $createMethod = 'create' . ucfirst($objectType);
             * $object = $this->serviceManager->get('app.name.formatForDB.' . $objectType . '_factory')->$createMethod();
             */
        ENDIF

        $result = false;
        switch ($objectType) {
        FOR entity : app.getAllEntities
            val uniqueFields = entity.getUniqueDerivedFields.filter[!primaryKey]
            IF !uniqueFields.empty || (entity.hasSluggableFields && entity.slugUnique)
                case 'entity.name.formatForCode':
                    IF app.targets('1.3.5')
                        $repository = $this->entityManager->getRepository($entityClass);
                    ELSE
                        $repository = $this->serviceManager->get('app.appName.formatForDB.' . $objectType . '_factory')->getRepository();
                    ENDIF
                    switch ($fieldName) {
                    FOR uniqueField : uniqueFields
                        case 'uniqueField.name.formatForCode':
                                $result = $repository->detectUniqueState('uniqueField.name.formatForCode', $value, $excludeIF !container.application.getAllEntities.filter[hasCompositeKeys].empty[0]ENDIF);
                                break;
                    ENDFOR
                    IF entity.hasSluggableFields && entity.slugUnique
                        case 'slug':
                                $entity = $repository->selectBySlug($value, false, $exclude);
                                $result = ($entity != null && isset($entity['slug']));
                                break;
                    ENDIF
                    }
                    break;
            ENDIF
        ENDFOR
        }

        // return response
        $result = array('isDuplicate' => $result);

        return new IF app.targets('1.3.5')Zikula_Response_AjaxELSEAjaxResponseENDIF($result);
    '''

    def private prepareDuplicateCheckParameters(AjaxController it, Application app) '''
        $postData = $IF app.targets('1.3.5')this->ENDIFrequest->request;

        $objectType = $postData->filter('ot', 'app.getLeadingEntity.name.formatForCode', IF !app.targets('1.3.5')false, ENDIFFILTER_SANITIZE_STRING);
        IF app.targets('1.3.5')
            $controllerHelper = new app.appName_Util_Controller($this->serviceManager);
        ELSE
            $controllerHelper = $this->serviceManager->get('app.appName.formatForDB.controller_helper');
        ENDIF
        $utilArgs = array('controller' => 'formattedName', 'action' => 'checkForDuplicate');
        if (!in_array($objectType, $controllerHelper->getObjectTypes('controllerAction', $utilArgs))) {
            $objectType = $controllerHelper->getDefaultObjectType('controllerAction', $utilArgs);
        }

        $fieldName = $postData->filter('fn', '', IF !app.targets('1.3.5')false, ENDIFFILTER_SANITIZE_STRING);
        $value = $postData->get('v', '');

        if (empty($fieldName) || empty($value)) {
            return new IF app.targets('1.3.5')Zikula_Response_Ajax_BadDataELSEBadDataResponseENDIF($this->__('Error: invalid input.'));
        }

        // check if the given field is existing and unique
        $uniqueFields = array();
        switch ($objectType) {
            FOR entity : app.getAllEntities
                val uniqueFields = entity.getUniqueDerivedFields.filter[!primaryKey]
                IF !uniqueFields.empty || (entity.hasSluggableFields && entity.slugUnique)
                    case 'entity.name.formatForCode':
                            $uniqueFields = array(FOR uniqueField : uniqueFields SEPARATOR ', ''uniqueField.name.formatForCode'ENDFORIF entity.hasSluggableFields && entity.slugUniqueIF !uniqueFields.empty, ENDIF'slug'ENDIF);
                            break;
                ENDIF
            ENDFOR
        }
        if (!count($uniqueFields) || !in_array($fieldName, $uniqueFields)) {
            return new IF app.targets('1.3.5')Zikula_Response_Ajax_BadDataELSEBadDataResponseENDIF($this->__('Error: invalid input.'));
        }

        $exclude = $postData->get('ex', '');
        IF !container.application.getAllEntities.filter[hasCompositeKeys].empty
            if (strpos($exclude, '_') !== false) {
                $exclude = explode('_', $exclude);
            }
        ENDIF 
    '''

    def private toggleFlagBase(AjaxController it, Application app) '''
        toggleFlagDocBlock(true)
        toggleFlagSignature
        {
            toggleFlagBaseImpl(app)
        }
    '''

    def private toggleFlagDocBlock(AjaxController it, Boolean isBase) '''
        /**
         * Changes a given flag (boolean field) by switching between true and false.
        IF !container.application.targets('1.3.5') && !isBase
        ' '*
        ' '* @Route("/toggleFlag", options={"expose"=true})
        ' '* @Method("POST")
        ENDIF
         *
         * @param string $ot    Treated object type.
         * @param string $field The field to be toggled.
         * @param int    $id    Identifier of treated entity.
         *
         * @return IF container.application.targets('1.3.5')Zikula_Response_AjaxELSEAjaxResponseENDIF
         IF !container.application.targets('1.3.5')
         *
         * @throws AccessDeniedException Thrown if the user doesn't have required permissions
         ENDIF
         */
    '''

    def private toggleFlagSignature(AjaxController it) '''
        public function toggleFlagIF container.application.targets('1.3.5')()ELSEAction(Request $request)ENDIF
    '''

    def private toggleFlagBaseImpl(AjaxController it, Application app) '''
        IF app.targets('1.3.5')
            $this->throwForbiddenUnless(SecurityUtil::checkPermission($this->name . '::Ajax', '::', ACCESS_EDIT));
        ELSE
            if (!SecurityUtil::checkPermission($this->name . '::Ajax', '::', ACCESS_EDIT)) {
                throw new AccessDeniedException();
            }
        ENDIF

        $postData = $IF app.targets('1.3.5')this->ENDIFrequest->request;

        $objectType = $postData->filter('ot', '', IF !app.targets('1.3.5')false, ENDIFFILTER_SANITIZE_STRING);
        $field = $postData->filter('field', '', IF !app.targets('1.3.5')false, ENDIFFILTER_SANITIZE_STRING);
        $id = (int) $postData->filter('id', 0, IF !app.targets('1.3.5')false, ENDIFFILTER_VALIDATE_INT);

        val entities = app.getEntitiesWithAjaxToggle
        if ($id == 0
            || (FOR entity : entities SEPARATOR ' && '$objectType != 'entity.name.formatForCode'ENDFOR)
        FOR entity : entities
            || ($objectType == 'entity.name.formatForCode' && !in_array($field, array(FOR field : entity.getBooleansWithAjaxToggleEntity SEPARATOR ', ''field.name.formatForCode'ENDFOR)))
        ENDFOR
        ) {
            return new IF app.targets('1.3.5')Zikula_Response_Ajax_BadDataELSEBadDataResponseENDIF($this->__('Error: invalid input.'));
        }

        // select data from data source
        $entity = ModUtil::apiFunc($this->name, 'selection', 'getEntity', array('ot' => $objectType, 'id' => $id));
        if ($entity == null) {
            return new IF app.targets('1.3.5')Zikula_Response_Ajax_NotFoundELSENotFoundResponseENDIF($this->__('No such item.'));
        }

        // toggle the flag
        $entity[$field] = !$entity[$field];

        // save entity back to database
        $this->entityManager->flush();

        // return response
        $result = array('id' => $id,
                        'state' => $entity[$field]);
        IF !app.targets('1.3.5')

            $logger = $this->serviceManager->get('logger');
            $logger->notice('{app}: User {user} toggled the {field} flag the {entity} with id {id}.', array('app' => 'app.appName', 'user' => UserUtil::getVar('uname'), 'field' => $field, 'entity' => $objectType, 'id' => $id));
        ENDIF

        return new IF app.targets('1.3.5')Zikula_Response_AjaxELSEAjaxResponseENDIF($result);
    '''

    def private handleTreeOperationBase(AjaxController it, Application app) '''
        handleTreeOperationDocBlock(true)
        handleTreeOperationSignature
        {
            handleTreeOperationBaseImpl(app)
        }
    '''

    def private handleTreeOperationDocBlock(AjaxController it, Boolean isBase) '''
        /**
         * Performs different operations on tree hierarchies.
        IF !container.application.targets('1.3.5') && !isBase
        ' '*
        ' '* @Route("/handleTreeOperation", options={"expose"=true})
        ' '* @Method("POST")
        ENDIF
         *
         * @param string $ot        Treated object type.
         * @param string $op        The operation which should be performed (addRootNode, addChildNode, deleteNode, moveNode, moveNodeTo).
         * @param int    $id        Identifier of treated node (not for addRootNode and addChildNode).
         * @param int    $pid       Identifier of parent node (only for addChildNode).
         * @param string $direction The target direction for a move action (only for moveNode [up, down] and moveNodeTo [after, before, bottom]).
         * @param int    $destid    Identifier of destination node for (only for moveNodeTo).
         *
         * @return IF container.application.targets('1.3.5')Zikula_Response_AjaxELSEAjaxResponseENDIF
         *
         IF !container.application.targets('1.3.5')
         * @throws AccessDeniedException Thrown if the user doesn't have required permissions
         ENDIF
         * @throws IF container.application.targets('1.3.5')Zikula_Exception_Ajax_FatalELSEFatalResponseENDIF
         IF !container.application.targets('1.3.5')
         * @throws RuntimeException Thrown if tree verification or executing the workflow action fails
         ENDIF
         */
    '''

    def private handleTreeOperationSignature(AjaxController it) '''
        public function handleTreeOperationIF container.application.targets('1.3.5')()ELSEAction(Request $request)ENDIF
    '''

    def private handleTreeOperationBaseImpl(AjaxController it, Application app) '''
        IF app.targets('1.3.5')
            $this->throwForbiddenUnless(SecurityUtil::checkPermission($this->name . '::Ajax', '::', ACCESS_EDIT));
        ELSE
            if (!SecurityUtil::checkPermission($this->name . '::Ajax', '::', ACCESS_EDIT)) {
                throw new AccessDeniedException();
            }
        ENDIF

        $postData = $IF app.targets('1.3.5')this->ENDIFrequest->request;

        val treeEntities = app.getTreeEntities
        // parameter specifying which type of objects we are treating
        $objectType = DataUtil::convertFromUTF8($postData->filter('ot', 'treeEntities.head.name.formatForCode', IF !app.targets('1.3.5')false, ENDIFFILTER_SANITIZE_STRING));
        // ensure that we use only object types with tree extension enabled
        if (!in_array($objectType, array(FOR treeEntity : treeEntities SEPARATOR ", "'treeEntity.name.formatForCode'ENDFOR))) {
            $objectType = 'treeEntities.head.name.formatForCode';
        }

        prepareTreeOperationParameters(app)

        $returnValue = array(
            'data'    => array(),
            'message' => ''
        );

        IF app.targets('1.3.5')
            $entityClass = 'app.appName_Entity_' . ucfirst($objectType);
            $repository = $this->entityManager->getRepository($entityClass);
        ELSE
            $createMethod = 'create' . ucfirst($objectType);
            $repository = $this->serviceManager->get('app.appName.formatForDB.' . $objectType . '_factory')->getRepository();
        ENDIF

        $rootId = 1;
        if (!in_array($op, array('addRootNode'))) {
            $rootId = (int) $postData->filter('root', 0, IF !app.targets('1.3.5')false, ENDIFFILTER_VALIDATE_INT);
            if (!$rootId) {
                throw new IF app.targets('1.3.5')Zikula_Exception_Ajax_FatalELSEFatalResponseENDIF($this->__('Error: invalid root node.'));
            }
        }

        // Select tree
        $tree = null;
        if (!in_array($op, array('addRootNode'))) {
            $tree = ModUtil::apiFunc($this->name, 'selection', 'getTree', array('ot' => $objectType, 'rootId' => $rootId));
        }

        // verification and recovery of tree
        $verificationResult = $repository->verify();
        if (is_array($verificationResult)) {
            foreach ($verificationResult as $errorMsg) {
                IF app.targets('1.3.5')LogUtil::registerErrorELSEthrow new \RuntimeExceptionENDIF($errorMsg);
            }
        }
        $repository->recover();
        $this->entityManager->clear(); // clear cached nodes

        treeOperationDetermineEntityFields(app)

        treeOperationSwitch(app)

        $returnValue['message'] = $this->__('The operation was successful.');

        // Renew tree
        /** postponed, for now we do a page reload
        $returnValue['data'] = ModUtil::apiFunc($this->name, 'selection', 'getTree', array('ot' => $objectType, 'rootId' => $rootId));
        */

        return new IF app.targets('1.3.5')Zikula_Response_AjaxELSEAjaxResponseENDIF($returnValue);
    '''

    def private prepareTreeOperationParameters(AjaxController it, Application app) '''
        $op = DataUtil::convertFromUTF8($postData->filter('op', '', IF !app.targets('1.3.5')false, ENDIFFILTER_SANITIZE_STRING));
        if (!in_array($op, array('addRootNode', 'addChildNode', 'deleteNode', 'moveNode', 'moveNodeTo'))) {
            throw new IF app.targets('1.3.5')Zikula_Exception_Ajax_FatalELSEFatalResponseENDIF($this->__('Error: invalid operation.'));
        }

        // Get id of treated node
        $id = 0;
        if (!in_array($op, array('addRootNode', 'addChildNode'))) {
            $id = (int) $postData->filter('id', 0, IF !app.targets('1.3.5')false, ENDIFFILTER_VALIDATE_INT);
            if (!$id) {
                throw new IF app.targets('1.3.5')Zikula_Exception_Ajax_FatalELSEFatalResponseENDIF($this->__('Error: invalid node.'));
            }
        }
    '''

    def private treeOperationDetermineEntityFields(AjaxController it, Application app) '''
        $titleFieldName = $descriptionFieldName = '';

        switch ($objectType) {
            FOR entity : app.getTreeEntities
                case 'entity.name.formatForCode':
                    val stringFields = entity.fields.filter(StringField).filter[length >= 20 && !nospace && !country && !htmlcolour && !language && !locale]
                        $titleFieldName = 'IF !stringFields.emptystringFields.head.name.formatForCodeENDIF';
                        val textFields = entity.fields.filter(TextField).filter[mandatory && length >= 50]
                        IF !textFields.empty
                            $descriptionFieldName = 'textFields.head.name.formatForCode';
                        ELSE
                            val textStringFields = entity.fields.filter(StringField).filter[mandatory && length >= 50 && !nospace && !country && !htmlcolour && !language && !locale]
                            IF !textStringFields.empty
                                $descriptionFieldName = 'textStringFields.head.name.formatForCode';
                            ENDIF
                        ENDIF
                        break;
            ENDFOR
        }
    '''

    def private treeOperationSwitch(AjaxController it, Application app) '''
        IF !app.targets('1.3.5')
            $logger = $this->serviceManager->get('logger');

        ENDIF
        switch ($op) {
            case 'addRootNode':
                            treeOperationAddRootNode(app)
                            IF !app.targets('1.3.5')

                                $logger->notice('{app}: User {user} added a new root node in the {entity} tree.', array('app' => 'app.appName', 'user' => UserUtil::getVar('uname'), 'entity' => $objectType));
                            ENDIF

                            break;
            case 'addChildNode':
                            treeOperationAddChildNode(app)
                            IF !app.targets('1.3.5')

                                $logger->notice('{app}: User {user} added a new child node in the {entity} tree.', array('app' => 'app.appName', 'user' => UserUtil::getVar('uname'), 'entity' => $objectType));
                            ENDIF
                            break;
            case 'deleteNode':
                            treeOperationDeleteNode(app)
                            IF !app.targets('1.3.5')

                                $logger->notice('{app}: User {user} deleted a node from the {entity} tree.', array('app' => 'app.appName', 'user' => UserUtil::getVar('uname'), 'entity' => $objectType));
                            ENDIF

                            break;
            case 'moveNode':
                            treeOperationMoveNode(app)
                            IF !app.targets('1.3.5')

                                $logger->notice('{app}: User {user} moved a node in the {entity} tree.', array('app' => 'app.appName', 'user' => UserUtil::getVar('uname'), 'entity' => $objectType));
                            ENDIF

                            break;
            case 'moveNodeTo':
                            treeOperationMoveNodeTo(app)
                            IF !app.targets('1.3.5')

                                $logger->notice('{app}: User {user} moved a node in the {entity} tree.', array('app' => 'app.appName', 'user' => UserUtil::getVar('uname'), 'entity' => $objectType));
                            ENDIF

                            break;
        }
    '''

    def private treeOperationAddRootNode(AjaxController it, Application app) '''
        //$this->entityManager->transactional(function($entityManager) {
            IF app.targets('1.3.5')
                $entity = new $entityClass();
            ELSE
                $entity = $this->serviceManager->get('app.name.formatForDB.' . $objectType . '_factory')->$createMethod();
            ENDIF
            $entityData = array();
            if (!empty($titleFieldName)) {
                $entityData[$titleFieldName] = $this->__('New root node');
            }
            if (!empty($descriptionFieldName)) {
                $entityData[$descriptionFieldName] = $this->__('This is a new root node');
            }
            $entity->merge($entityData);
            /*IF hasTranslatableFields
                $entity->setLocale(ZLanguage::getLanguageCode());
            ENDIF*/

            // save new object to set the root id
            $action = 'submit';
            try {
                // execute the workflow action
                IF app.targets('1.3.5')
                    $workflowHelper = new app.appName_Util_Workflow($this->serviceManager);
                ELSE
                    $workflowHelper = $this->serviceManager->get('app.appName.formatForDB.workflow_helper');
                ENDIF
                $success = $workflowHelper->executeAction($entity, $action);
            } catch(\Exception $e) {
                IF app.targets('1.3.5')LogUtil::registerErrorELSEthrow new \RuntimeExceptionENDIF($this->__f('Sorry, but an unknown error occured during the %s action. Please apply the changes again!', array($action)));
            }
        //});
    '''

    def private treeOperationAddChildNode(AjaxController it, Application app) '''
        $parentId = (int) $postData->filter('pid', 0, IF !app.targets('1.3.5')false, ENDIFFILTER_VALIDATE_INT);
        if (!$parentId) {
            throw new IF app.targets('1.3.5')Zikula_Exception_Ajax_FatalELSEFatalResponseENDIF($this->__('Error: invalid parent node.'));
        }

        //$this->entityManager->transactional(function($entityManager) {
            IF app.targets('1.3.5')
                $childEntity = new $entityClass();
            ELSE
                $childEntity = $this->serviceManager->get('app.name.formatForDB.' . $objectType . '_factory')->$createMethod();
            ENDIF
            $entityData = array();
            $entityData[$titleFieldName] = $this->__('New child node');
            if (!empty($descriptionFieldName)) {
                $entityData[$descriptionFieldName] = $this->__('This is a new child node');
            }
            $childEntity->merge($entityData);

            // save new object
            $action = 'submit';
            try {
                // execute the workflow action
                IF app.targets('1.3.5')
                    $workflowHelper = new app.appName_Util_Workflow($this->serviceManager);
                ELSE
                    $workflowHelper = $this->serviceManager->get('app.appName.formatForDB.workflow_helper');
                ENDIF
                $success = $workflowHelper->executeAction($childEntity, $action);
            } catch(\Exception $e) {
                IF app.targets('1.3.5')LogUtil::registerErrorELSEthrow new \RuntimeExceptionENDIF($this->__f('Sorry, but an unknown error occured during the %s action. Please apply the changes again!', array($action)));
            }

            //$childEntity->setParent($parentEntity);
            $parentEntity = ModUtil::apiFunc($this->name, 'selection', 'getEntity', array('ot' => $objectType, 'id' => $parentId, 'useJoins' => false));
            if ($parentEntity == null) {
                return new IF app.targets('1.3.5')Zikula_Response_Ajax_NotFoundELSENotFoundResponseENDIF($this->__('No such item.'));
            }
            $repository->persistAsLastChildOf($childEntity, $parentEntity);
        //});
        $this->entityManager->flush();
    '''

    def private treeOperationDeleteNode(AjaxController it, Application app) '''
        // remove node from tree and reparent all children
        $entity = ModUtil::apiFunc($this->name, 'selection', 'getEntity', array('ot' => $objectType, 'id' => $id, 'useJoins' => false));
        if ($entity == null) {
            return new IF app.targets('1.3.5')Zikula_Response_Ajax_NotFoundELSENotFoundResponseENDIF($this->__('No such item.'));
        }

        $entity->initWorkflow();

        // delete the object
        $action = 'delete';
        try {
            // execute the workflow action
                IF app.targets('1.3.5')
                    $workflowHelper = new app.appName_Util_Workflow($this->serviceManager);
                ELSE
                    $workflowHelper = $this->serviceManager->get('app.appName.formatForDB.workflow_helper');
                ENDIF
            $success = $workflowHelper->executeAction($entity, $action);
        } catch(\Exception $e) {
            IF app.targets('1.3.5')LogUtil::registerErrorELSEthrow new \RuntimeExceptionENDIF($this->__f('Sorry, but an unknown error occured during the %s action. Please apply the changes again!', array($action)));
        }

        $repository->removeFromTree($entity);
        $this->entityManager->clear(); // clear cached nodes
    '''

    def private treeOperationMoveNode(AjaxController it, Application app) '''
        $moveDirection = $postData->filter('direction', '', IF !app.targets('1.3.5')false, ENDIFFILTER_SANITIZE_STRING);
        if (!in_array($moveDirection, array('up', 'down'))) {
            throw new IF app.targets('1.3.5')Zikula_Exception_Ajax_FatalELSEFatalResponseENDIF($this->__('Error: invalid direction.'));
        }

        $entity = ModUtil::apiFunc($this->name, 'selection', 'getEntity', array('ot' => $objectType, 'id' => $id, 'useJoins' => false));
        if ($entity == null) {
            return new IF app.targets('1.3.5')Zikula_Response_Ajax_NotFoundELSENotFoundResponseENDIF($this->__('No such item.'));
        }

        if ($moveDirection == 'up') {
            $repository->moveUp($entity, 1);
        } else if ($moveDirection == 'down') {
            $repository->moveDown($entity, 1);
        }
        $this->entityManager->flush();
    '''

    def private treeOperationMoveNodeTo(AjaxController it, Application app) '''
        $moveDirection = $postData->filter('direction', '', IF !app.targets('1.3.5')false, ENDIFFILTER_SANITIZE_STRING);
        if (!in_array($moveDirection, array('after', 'before', 'bottom'))) {
            throw new IF app.targets('1.3.5')Zikula_Exception_Ajax_FatalELSEFatalResponseENDIF($this->__('Error: invalid direction.'));
        }

        $destId = (int) $postData->filter('destid', 0, IF !app.targets('1.3.5')false, ENDIFFILTER_VALIDATE_INT);
        if (!$destId) {
            throw new IF app.targets('1.3.5')Zikula_Exception_Ajax_FatalELSEFatalResponseENDIF($this->__('Error: invalid destination node.'));
        }

        //$this->entityManager->transactional(function($entityManager) {
            $entity = ModUtil::apiFunc($this->name, 'selection', 'getEntity', array('ot' => $objectType, 'id' => $id, 'useJoins' => false));
            $destEntity = ModUtil::apiFunc($this->name, 'selection', 'getEntity', array('ot' => $objectType, 'id' => $destId, 'useJoins' => false));
            if ($entity == null || $destEntity == null) {
                return new IF app.targets('1.3.5')Zikula_Response_Ajax_NotFoundELSENotFoundResponseENDIF($this->__('No such item.'));
            }

            if ($moveDirection == 'after') {
                $repository->persistAsNextSiblingOf($entity, $destEntity);
            } elseif ($moveDirection == 'before') {
                $repository->persistAsPrevSiblingOf($entity, $destEntity);
            } elseif ($moveDirection == 'bottom') {
                $repository->persistAsLastChildOf($entity, $destEntity);
            }
            $this->entityManager->flush();
        //});
    '''




    def dispatch additionalAjaxFunctions(Controller it, Application app) {
    }

    def dispatch additionalAjaxFunctions(AjaxController it, Application app) '''
        userSelectorsImpl(app)
        IF app.generateExternalControllerAndFinder

            getItemListFinderImpl(app)
        ENDIF
        val joinRelations = app.getJoinRelations
        IF !joinRelations.empty

            getItemListAutoCompletionImpl(app)
        ENDIF
        IF app.getAllEntities.exists[getUniqueDerivedFields.filter[!primaryKey].size > 0]
        || (app.hasSluggable && !app.getAllEntities.filter[hasSluggableFields && slugUnique].empty)

            checkForDuplicateImpl(app)
        ENDIF
        IF app.hasBooleansWithAjaxToggle

            toggleFlagImpl(app)
        ENDIF
        IF app.hasTrees
        
            handleTreeOperationImpl(app)
        ENDIF
    '''

    def private userSelectorsImpl(AjaxController it, Application app) '''
        val userFields = app.getAllUserFields
        IF !userFields.empty
            FOR userField : userFields

                /**
                 *
                 * @Route("/getuserField.entity.name.formatForCodeCapitaluserField.name.formatForCodeCapitalUsers", options={"expose"=true})
                 * @Method("POST")
                 */
                public function getuserField.entity.name.formatForCodeCapitaluserField.name.formatForCodeCapitalUsersAction(Request $request)
                {
                    return parent::getuserField.entity.name.formatForCodeCapitaluserField.name.formatForCodeCapitalUsersAction($request);
                }
            ENDFOR

            getCommonUsersListImpl(app)
        ENDIF
    '''

    def private getCommonUsersListImpl(AjaxController it, Application app) '''
        getCommonUsersListDocBlock(false)
        getCommonUsersListSignature
        {
            return parent::return $this->getCommonUsersListAction($request);
        }
    '''

    def private getItemListFinderImpl(AjaxController it, Application app) '''
        getItemListFinderDocBlock(false)
        getItemListFinderSignature
        {
            return parent::getItemListFinderAction($request);
        }
    '''

    def private getItemListAutoCompletionImpl(AjaxController it, Application app) '''
        getItemListAutoCompletionDocBlock(false)
        getItemListAutoCompletionSignature
        {
            return parent::getItemListAutoCompletionAction($request);
        }
    '''

    def private checkForDuplicateImpl(AjaxController it, Application app) '''
        checkForDuplicateDocBlock(false)
        checkForDuplicateSignature
        {
            return parent::checkForDuplicateAction($request);
        }
    '''

    def private toggleFlagImpl(AjaxController it, Application app) '''
        toggleFlagDocBlock(false)
        toggleFlagSignature
        {
            return parent::toggleFlagAction($request);
        }
    '''

    def private handleTreeOperationImpl(AjaxController it, Application app) '''
        handleTreeOperationDocBlock(false)
        handleTreeOperationSignature
        {
            return parent::handleTreeOperationAction($request);
        }
    '''
}
