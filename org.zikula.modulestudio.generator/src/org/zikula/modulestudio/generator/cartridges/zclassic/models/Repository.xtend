package org.zikula.modulestudio.generator.cartridges.zclassic.models

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.CalculatedField
import de.guite.modulestudio.metamodel.modulestudio.DerivedField
import de.guite.modulestudio.metamodel.modulestudio.Entity
import de.guite.modulestudio.metamodel.modulestudio.EntityField
import de.guite.modulestudio.metamodel.modulestudio.EntityTreeType
import de.guite.modulestudio.metamodel.modulestudio.JoinRelationship
import de.guite.modulestudio.metamodel.modulestudio.ManyToManyRelationship
import de.guite.modulestudio.metamodel.modulestudio.ManyToOneRelationship
import de.guite.modulestudio.metamodel.modulestudio.OneToManyRelationship
import de.guite.modulestudio.metamodel.modulestudio.StringField
import de.guite.modulestudio.metamodel.modulestudio.TextField
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.models.repository.Joins
import org.zikula.modulestudio.generator.cartridges.zclassic.models.repository.LinkTable
import org.zikula.modulestudio.generator.cartridges.zclassic.models.repository.Tree
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelInheritanceExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import de.guite.modulestudio.metamodel.modulestudio.BooleanField
import de.guite.modulestudio.metamodel.modulestudio.ArrayField
import de.guite.modulestudio.metamodel.modulestudio.ObjectField

class Repository {
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension ModelExtensions = new ModelExtensions()
    @Inject extension ModelBehaviourExtensions = new ModelBehaviourExtensions()
    @Inject extension ModelJoinExtensions = new ModelJoinExtensions()
    @Inject extension ModelInheritanceExtensions = new ModelInheritanceExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension Utils = new Utils()

    FileHelper fh = new FileHelper()

    /**
     * Entry point for Doctrine repository classes.
     */

    def generate(Application it, IFileSystemAccess fsa) {
        getAllEntities.filter(e|!e.mappedSuperClass).forEach(e|e.generate(it, fsa))

        val linkTable = new LinkTable()
        for (relation : getJoinRelations.filter(typeof(ManyToManyRelationship))) linkTable.generate(relation, it, fsa)
    }

    /**
     * Creates a repository class file for every Entity instance.
     */
    def private generate(Entity it, Application app, IFileSystemAccess fsa) {
        println('Generating repository classes for entity "' + name.formatForDisplay + '"')
        if (!isInheriting) {
            fsa.generateFile(getAppSourcePath(app.appName) + baseClassModel('repository', '').asFile, modelRepositoryBaseFile(app))
        }
        fsa.generateFile(getAppSourcePath(app.appName) + implClassModel('repository', '').asFile, modelRepositoryFile(app))
    }

    def private modelRepositoryBaseFile(Entity it, Application app) '''
    	«fh.phpFileHeader(app)»
    	«modelRepositoryBaseImpl(app)»
    '''

    def private modelRepositoryFile(Entity it, Application app) '''
    	«fh.phpFileHeader(app)»
    	«modelRepositoryImpl(app)»
    '''

    def private modelRepositoryBaseImpl(Entity it, Application app) '''
        «IF tree != EntityTreeType::NONE»
            use Gedmo\Tree\Entity\Repository\«tree.asConstant.toFirstUpper»TreeRepository;
        «ELSE»
            use Doctrine\ORM\EntityRepository;
        «ENDIF»
        use Doctrine\ORM\Query;
        use Doctrine\ORM\QueryBuilder;
        «IF hasOptimisticLock || hasPessimisticReadLock || hasPessimisticWriteLock»
            use Doctrine\DBAL\LockMode;
        «ENDIF»

        use DoctrineExtensions\Paginate\Paginate;

        /**
         * Repository class used to implement own convenience methods for performing certain DQL queries.
         *
         * This is the base repository class for «name.formatForDisplay» entities.
         */
        class «baseClassModel('repository', '')» extends «IF tree != EntityTreeType::NONE»«tree.asConstant.toFirstUpper»TreeRepository«ELSE»EntityRepository«ENDIF»
        {
            /**
             * @var string The default sorting field/expression.
             */
            protected $defaultSortingField = '«(if (hasSortableFields) getSortableFields.head else getLeadingField).name.formatForCode»';

            /**«/* @TODO to be refactored */»
             * Retrieves an array with all fields which can be used for sorting instances.
             *
             * @return array
             */
            public function getAllowedSortingFields()
            {
                return array(
                    «FOR field : fields»«field.singleSortingField»«ENDFOR»
                    «extensionSortingFields»
                );
            }

            «fh.getterAndSetterMethods(it, 'defaultSortingField', 'string', false, false, '')»

            /**
             * Returns name of the field used as title / name for entities of this repository.
             *
             * @return string name of field to be used as title. 
             */
            public function getTitleFieldName()
            {
                «val leadingField = getLeadingField»
                $fieldName = '«IF leadingField != null»«leadingField.name.formatForCode»«ENDIF»';
                return $fieldName;
            }

            /**
             * Returns name of the field used for describing entities of this repository.
             *
             * @return string name of field to be used as description. 
             */
            public function getDescriptionFieldName()
           {
                $fieldName = '';
                «val textFields = fields.filter(typeof(TextField)).filter(e|!e.leading)»
                «IF !textFields.isEmpty»
                    $fieldName = '«textFields.head.name.formatForCode»';
                «ELSE»
                    «val stringFields = fields.filter(typeof(StringField)).filter(e|!e.leading && !e.password)»
                    «IF !stringFields.isEmpty»
                        $fieldName = '«stringFields.head.name.formatForCode»';
                    «ENDIF»
                «ENDIF»
                return $fieldName;
            }

            /**
             * Returns name of the first upload field which is capable for handling images.
             *
             * @return string name of field to be used for preview images 
             */
            public function getPreviewFieldName()
            {
                $fieldName = '«IF hasImageFieldsEntity»«getImageFieldsEntity.head.name.formatForCode»«ENDIF»';
                return $fieldName;
            }

            «getAdditionalTemplateParameters»

            «truncateTable»
            «IF standardFields || hasUserFieldsEntity»

                «userDeleteFunctions»
            «ENDIF»

            «selectById»
            «IF hasSluggableFields && slugUnique»

                «selectBySlug»
            «ENDIF»

            «selectWhere»

            «selectWherePaginated»

            «selectSearch»
            «IF !getUniqueDerivedFields.isEmpty»

                «selectCount»
            «ENDIF»

            «new Tree().generate(it, app)»

            «detectUniqueState»

            «intBaseQuery»

            «new Joins().generate(it, app)»
        }
    '''

    def private getAdditionalTemplateParameters(Entity it) '''
        /**
         * Returns an array of additional template variables which are specific to the object type treated by this repository.
         *
         * @param string $context Usage context (allowed values: controllerAction, api, actionHandler, block, contentType).
         * @param array  $args    Additional arguments.
         *
         * @return array List of template variables to be assigned.
         */
        public function getAdditionalTemplateParameters($context = '', $args = array())
        {
            if (!in_array($context, array('controllerAction', 'api', 'actionHandler', 'block', 'contentType'))) {
                $context = 'controllerAction';
            }

            $templateParameters = array();

            $currentFunc = FormUtil::getPassedValue('func', 'main', 'GETPOST');
            if ($currentFunc == 'view') {
                $templateParameters = $this->getViewQuickNavParameters($context, $args);
                «IF hasListFieldsEntity»
                    $serviceManager = ServiceUtil::getManager();
                    $listHelper = new «container.application.appName»_Util_ListEntries($serviceManager);
                    «FOR field : getListFieldsEntity»
                        «var fieldName = field.name.formatForCode»
                        $templateParameters['«fieldName»Items'] = $listHelper->getEntries('«name.formatForCode»', '«fieldName»');
                    «ENDFOR»
                «ENDIF»
            }

            // in the concrete child class you could do something like
            // $parameters = parent::getAdditionalTemplateParameters($context, $args);
            // $parameters['myvar'] = 'myvalue';
            // return $parameters;

            return $templateParameters;
        }

        /**
         * Returns an array of additional template variables for view quick navigation forms.
         *
         * @param string $context Usage context (allowed values: controllerAction, api, actionHandler, block, contentType).
         * @param array  $args    Additional arguments.
         *
         * @return array List of template variables to be assigned.
         */
        protected function getViewQuickNavParameters($context = '', $args = array())
        {
            if (!in_array($context, array('controllerAction', 'api', 'actionHandler', 'block', 'contentType'))) {
                $context = 'controllerAction';
            }

            $parameters = array();
            «IF categorisable»
                $parameters['catId'] = (int) FormUtil::getPassedValue('catid', 0, 'GET');
            «ENDIF»
            «IF !getBidirectionalIncomingJoinRelationsWithOneSource.isEmpty»
                «FOR relation: getBidirectionalIncomingJoinRelationsWithOneSource»
                    «val sourceAliasName = relation.getRelationAliasName(false).formatForCodeCapital»
                    $parameters['«sourceAliasName»'] = FormUtil::getPassedValue('«sourceAliasName»', 0, 'GET');
                «ENDFOR»
            «ENDIF»
            «IF hasListFieldsEntity»
                «FOR field : getListFieldsEntity»
                    «val fieldName = field.name.formatForCode»
                    $parameters['«fieldName»'] = FormUtil::getPassedValue('«fieldName»', '', 'GET');
                «ENDFOR»
            «ENDIF»
            «IF hasUserFieldsEntity»
                «FOR field : getUserFieldsEntity»
                    «val fieldName = field.name.formatForCode»
                    $parameters['«fieldName»'] = (int) FormUtil::getPassedValue('«fieldName»', 0, 'GET');
                «ENDFOR»
            «ENDIF»
            «IF hasCountryFieldsEntity»
                «FOR field : getCountryFieldsEntity»
                    «val fieldName = field.name.formatForCode»
                    $parameters['«fieldName»'] = FormUtil::getPassedValue('«fieldName»', '', 'GET');
                «ENDFOR»
            «ENDIF»
            «IF hasLanguageFieldsEntity»
                «FOR field : getLanguageFieldsEntity»
                    «val fieldName = field.name.formatForCode»
                    $parameters['«fieldName»'] = FormUtil::getPassedValue('«fieldName»', '', 'GET');
                «ENDFOR»
            «ENDIF»
            «IF hasAbstractStringFieldsEntity»
                $parameters['searchterm'] = FormUtil::getPassedValue('searchterm', '', 'GET');
            «ENDIF»
            «/* not needed as already handled in the controller $pageSize = ModUtil::getVar('«container.application.appName»', 'pageSize', 10);
            $parameters['pageSize'] = (int) FormUtil::getPassedValue('pageSize', $pageSize, 'GET');*/»
            «IF hasBooleanFieldsEntity»
                «FOR field : getBooleanFieldsEntity»
                    «val fieldName = field.name.formatForCode»
                    $parameters['«fieldName»'] = (int) FormUtil::getPassedValue('«fieldName»', 0, 'GET');
                «ENDFOR»
            «ENDIF»

            // in the concrete child class you could do something like
            // $parameters = parent::getViewQuickNavParameters($context, $args);
            // $parameters['myvar'] = 'myvalue';
            // return $parameters;

            return $parameters;
        }
    '''

    def private truncateTable(Entity it) '''
        /**
         * Helper method for truncating the table.
         * Used during installation when inserting default data.
         */
        public function truncateTable()
        {
            $qb = $this->getEntityManager()->createQueryBuilder();
            $qb->delete('«implClassModelEntity»', 'tbl');
            $query = $qb->getQuery();
            «IF hasPessimisticWriteLock»
                $query->setLockMode(LockMode::«lockType.asConstant»);
            «ENDIF»
            $query->execute();
        }
    '''

    def private userDeleteFunctions(Entity it) '''
        «IF standardFields»
        /**
         * Deletes all objects created by a certain user.
         *
         * @param integer $userId The userid of the creator to be removed.
         */
        public function deleteCreator($userId)
        {
            // check id parameter
            if ($userId == 0 || !is_numeric($userId)) {
                return LogUtil::registerArgsError();
            }

            $qb = $this->getEntityManager()->createQueryBuilder();
            $qb->delete('«implClassModelEntity»', 'tbl')
               ->where('tbl.createdUserId = :creator')
               ->setParameter('creator', $userId);
            $query = $qb->getQuery();
            «IF hasPessimisticWriteLock»
                $query->setLockMode(LockMode::«lockType.asConstant»);
            «ENDIF»
            $query->execute();
        }

        /**
         * Deletes all objects updated by a certain user.
         *
         * @param integer $userId The userid of the last editor to be removed.
         */
        public function deleteLastEditor($userId)
        {
            // check id parameter
            if ($userId == 0 || !is_numeric($userId)) {
                return LogUtil::registerArgsError();
            }

            $qb = $this->getEntityManager()->createQueryBuilder();
            $qb->delete('«implClassModelEntity»', 'tbl')
               ->where('tbl.updatedUserId = :editor')
               ->setParameter('editor', $userId);
            $query = $qb->getQuery();
            «IF hasPessimisticWriteLock»
                $query->setLockMode(LockMode::«lockType.asConstant»);
            «ENDIF»
            $query->execute();
        }

        /**
         * Updates the creator of all objects created by a certain user.
         *
         * @param integer $userId    The userid of the creator to be replaced.
         * @param integer $newUserId The new userid of the creator as replacement.
         */
        public function updateCreator($userId, $newUserId)
        {
            // check id parameter
            if ($userId == 0 || !is_numeric($userId)
             || $newUserId == 0 || !is_numeric($newUserId)) {
                return LogUtil::registerArgsError();
            }

            $qb = $this->getEntityManager()->createQueryBuilder();
            $qb->update('«implClassModelEntity»', 'tbl')
               ->set('tbl.createdUserId', $newUserId)
               ->where('tbl.createdUserId = :creator')
               ->setParameter('creator', $userId);
            $query = $qb->getQuery();
            «IF hasPessimisticWriteLock»
                $query->setLockMode(LockMode::«lockType.asConstant»);
            «ENDIF»
            $query->execute();
        }

        /**
         * Updates the last editor of all objects updated by a certain user.
         *
         * @param integer $userId    The userid of the last editor to be replaced.
         * @param integer $newUserId The new userid of the last editor as replacement.
         */
        public function updateLastEditor($userId, $newUserId)
        {
            // check id parameter
            if ($userId == 0 || !is_numeric($userId)
             || $newUserId == 0 || !is_numeric($newUserId)) {
                return LogUtil::registerArgsError();
            }

            $qb = $this->getEntityManager()->createQueryBuilder();
            $qb->update('«implClassModelEntity»', 'tbl')
               ->set('tbl.updatedUserId', $newUserId)
               ->where('tbl.updatedUserId = :editor')
               ->setParameter('editor', $userId);
            $query = $qb->getQuery();
            «IF hasPessimisticWriteLock»
                $query->setLockMode(LockMode::«lockType.asConstant»);
            «ENDIF»
            $query->execute();
        }
        «ENDIF»
        «IF hasUserFieldsEntity»
        «IF standardFields»

        «ENDIF»
        /**
         * Updates a user field value of all objects affected by a certain user.
         *
         * @param string  $fieldName The name of the user field.
         * @param integer $userId    The userid to be replaced.
         * @param integer $newUserId The new userid as replacement.
         */
        public function updateUserField($userFieldName, $userId, $newUserId)
        {
            // check field parameter
            if (empty($userFieldName) || !in_array($userFieldName, array(«FOR field : getUserFieldsEntity SEPARATOR ', '»'«field.name.formatForCode»'«ENDFOR»))) {
                return LogUtil::registerArgsError();
            }
            // check id parameter
            if ($userId == 0 || !is_numeric($userId)
             || $newUserId == 0 || !is_numeric($newUserId)) {
                return LogUtil::registerArgsError();
            }

            $qb = $this->getEntityManager()->createQueryBuilder();
            $qb->update('«implClassModelEntity»', 'tbl')
               ->set('tbl.' . $userFieldName, $newUserId)
               ->where('tbl.' . $userFieldName . ' = :user')
               ->setParameter('user', $userId);
            $query = $qb->getQuery();
            «IF hasPessimisticWriteLock»
                $query->setLockMode(LockMode::«lockType.asConstant»);
            «ENDIF»
            $query->execute();
        }
        «ENDIF»
    '''

    def private selectById(Entity it) '''
        /**
         * Adds id filters to given query instance.
         *
         * @param mixed          $id The id (or array of ids) to use to retrieve the object.
         * @param Doctrine_Query $q  Query to be enhanced.
         *
         * @return Doctrine_Query Enriched query instance.
         */
        protected function addIdFilter($id, $q)
        {
            if (is_array($id)) {
                foreach ($id as $fieldName => $fieldValue) {
                    $fieldName = DataUtil::formatForStore($fieldName);
                    $q->andWhere('tbl.' . $fieldName . ' = :' . $fieldName)
                      ->setParameter($fieldName, $fieldValue);
                }
            } else {
                $q->andWhere('tbl.id = :id')«/* TODO fix composite keys */»
                  ->setParameter('id', $id);
            }
            return $q;
        }

        /**
         * Selects an object from the database.
         *
         * @param mixed   $id       The id (or array of ids) to use to retrieve the object (optional) (default=0).
         * @param boolean $useJoins Whether to include joining related objects (optional) (default=true).
         *
         * @return array|«implClassModelEntity» retrieved data array or «implClassModelEntity» instance
         */
        public function selectById($id = 0, $useJoins = true)
        {
            // check id parameter
            if ($id == 0) {
                return LogUtil::registerArgsError();
            }

            $query = $this->_intBaseQuery('', '', $useJoins);

            $query = $this->addIdFilter($id, $query);

            return $query->getOneOrNullResult();
        }

        /**
         * Selects an object from the database.
         * This version uses no joins at all and selects only a minimal set of fields.
         *
         * @TODO merge both queries into one more flexible version.
         *
         * @param mixed   $id       The id (or array of ids) to use to retrieve the object (optional) (default=null).
         *
         * @return array|«implClassModelEntity» retrieved data array or «implClassModelEntity» instance
         */
        public function selectByIdSimple($id = 0)
        {
            // check id parameter
            if ($id == 0) {
                return LogUtil::registerArgsError();
            }

            $query = $this->_intBaseQuerySimple('', '');

            $query = $this->addIdFilter($id, $query);

            return $query->getOneOrNullResult();
        }
    '''

    def private selectBySlug(Entity it) '''
        /**
         * Selects an object by slug field.
         *
         * @param string  $slugTitle The slug value
         * @param boolean $useJoins  Whether to include joining related objects (optional) (default=true).
         * @param integer $excludeId Optional id to be excluded (used for unique validation).
         *
         * @return «implClassModelEntity» retrieved instance of «implClassModelEntity»
         */
        public function selectBySlug($slugTitle = '', $useJoins = true, $excludeId = 0)
        {
            // check input parameter
            if ($slugTitle == '') {
                return LogUtil::registerArgsError();
            }

            $query = $this->_intBaseQuery('', '', $useJoins);

            $query->andWhere('tbl.slug = :slug')
                  ->setParameter('slug', $slugTitle);

            if ($excludeId > 0) {
                $query->andWhere('tbl.id != :excludeId')«/* TODO fix composite keys */»
                      ->setParameter('excludeId', $excludeId);
            }

            return $query->getOneOrNullResult();
        }

        /**
         * Selects an object by slug field.
         * This version uses no joins at all and selects only a minimal set of fields.
         *
         * @TODO merge both queries into one more flexible version.
         *
         * @param string  $slugTitle The slug value
         * @param integer $excludeId Optional id to be excluded (used for unique validation).
         *
         * @return «implClassModelEntity» retrieved instance of «implClassModelEntity»
         */
        public function selectBySlugSimple($slugTitle = '', $excludeId = 0)
        {
            // check input parameter
            if ($slugTitle == '') {
                return LogUtil::registerArgsError();
            }

            $query = $this->_intBaseQuerySimple('', '');

            $query->andWhere('tbl.slug = :slug')
                  ->setParameter('slug', $slugTitle);

            if ($excludeId > 0) {
                $query->andWhere('tbl.id != :excludeId')«/* TODO fix composite keys */»
                      ->setParameter('excludeId', $excludeId);
            }

            return $query->getOneOrNullResult();
        }
    '''

    def private selectWhere(Entity it) '''
        /**
         * Selects a list of objects with a given where clause.
         *
         * @param string  $where    The where clause to use when retrieving the collection (optional) (default='').
         * @param string  $orderBy  The order-by clause to use when retrieving the collection (optional) (default='').
         * @param boolean $useJoins Whether to include joining related objects (optional) (default=true).
         *
         * @return ArrayCollection collection containing retrieved «implClassModelEntity» instances
         */
        public function selectWhere($where = '', $orderBy = '', $useJoins = true)
        {
            $query = $this->_intBaseQuery($where, $orderBy, $useJoins);

            return $query->getResult();
        }

        /**
         * Selects a list of objects with a given where clause.
         * This version uses no joins at all and selects only a minimal set of fields.
         *
         * @TODO merge both queries into one more flexible version.
         *
         * @param string  $where   The where clause to use when retrieving the collection (optional) (default='').
         * @param string  $orderBy The order-by clause to use when retrieving the collection (optional) (default='').
         *
         * @return ArrayCollection collection containing retrieved «implClassModelEntity» instances
         */
        public function selectWhereSimple($where = '', $orderBy = '')
        {
            $query = $this->_intBaseQuerySimple($where, $orderBy);

            return $query->getResult();
        }
    '''

    def private selectWherePaginated(Entity it) '''
        /**
         * Returns query instance for retrieving a list of objects with a given where clause and pagination parameters.
         *
         * @param string  $where          The where clause to use when retrieving the collection (optional) (default='').
         * @param string  $orderBy        The order-by clause to use when retrieving the collection (optional) (default='').
         * @param integer $currentPage    Where to start selection
         * @param integer $resultsPerPage Amount of items to select
         * @param boolean $useJoins       Whether to include joining related objects (optional) (default=true).
         *
         * @return Doctrine_Query created query instance.
         */
        protected function getSelectWherePaginatedQuery($where = '', $orderBy = '', $currentPage = 1, $resultsPerPage = 25, $useJoins = true)
        {
            $query = $this->_intBaseQuery($where, $orderBy, $useJoins);
            $query = $this->addCommonViewFilters($query);
            $offset = ($currentPage-1) * $resultsPerPage;

            // count the total number of affected items
            $count = Paginate::getTotalQueryResults($query);

            «IF !(outgoing.filter(typeof(OneToManyRelationship)).isEmpty
               && outgoing.filter(typeof(ManyToManyRelationship)).isEmpty
               && incoming.filter(typeof(ManyToOneRelationship)).isEmpty)»
                // prefetch unique relationship ids for given pagination frame
                $query = Paginate::getPaginateQuery($query, $offset, $resultsPerPage);
            «ELSE»
                $query->setFirstResult($offset)
                      ->setMaxResults($resultsPerPage);
            «ENDIF»
            return array($query, $count);
        }

        /**
         * Selects a list of objects with a given where clause and pagination parameters.
         *
         * @param string  $where          The where clause to use when retrieving the collection (optional) (default='').
         * @param string  $orderBy        The order-by clause to use when retrieving the collection (optional) (default='').
         * @param integer $currentPage    Where to start selection
         * @param integer $resultsPerPage Amount of items to select
         * @param boolean $useJoins       Whether to include joining related objects (optional) (default=true).
         *
         * @return Array with retrieved collection and amount of total records affected by this query.
         */
        public function selectWherePaginated($where = '', $orderBy = '', $currentPage = 1, $resultsPerPage = 25, $useJoins = true)
        {
            list($query, $count) = $this->getSelectWherePaginatedQuery($where, $orderBy, $currentPage, $resultsPerPage, $useJoins);

            $result = $query->getResult();

            return array($result, $count);
        }

        /**
         * Adds quick navigation related filter options as where clauses.
         *
         * @param Doctrine_Query $query The query to be enhanced.
         *
         * @return Doctrine_Query Enriched query instance.
         */
        protected function addCommonViewFilters($query = '')
        {
            $currentFunc = FormUtil::getPassedValue('func', 'main', 'GETPOST');
            if ($currentFunc != 'view') {
                return $query;
            }

            $parameters = $this->getViewQuickNavParameters($context, $args);
            foreach ($parameters as $k => $v) {
                if ($k == 'catId') {
                    // category filter
                    if ($v > 0) {
                        $query->andWhere('tblCategories.category = :category')
                              ->setParameter('category', $v);
                    }
                } elseif ($k == 'searchterm') {
                    // quick search
                    if (!empty($v)) {
                        $query = $this->addSearchFilter($query, $v);
                    }
                } else {
                    // field filter
                    if ($v != '' || (is_numeric($v) && $v > 0)) {
                        $query->andWhere('tbl.' . $k . ' = :' . $k)
                              ->setParameter($k, $v);
                    }
                }
            }
            return $query;
        }
    '''

    def private selectSearch(Entity it) '''
        /**
         * Selects entities by a given search fragment.
         *
         * @param string  $fragment       The fragment to search for.
         * @param string  $exclude        Comma separated list with ids to be excluded from search.
         * @param string  $orderBy        The order-by clause to use when retrieving the collection (optional) (default='').
         * @param integer $currentPage    Where to start selection
         * @param integer $resultsPerPage Amount of items to select
         * @param boolean $useJoins       Whether to include joining related objects (optional) (default=true).
         *
         * @return Array with retrieved collection and amount of total records affected by this query.
         */
        public function selectSearch($fragment = '', $exclude = array(), $orderBy = '', $currentPage = 1, $resultsPerPage = 25, $useJoins = true)
        {
            list($query, $count) = $this->getSelectWherePaginatedQuery('', $orderBy, $currentPage, $resultsPerPage, $useJoins);
            if (count($exclude) > 0) {
                $exclude = implode(', ', $exclude);
                $query->andWhere('tbl.id NOT IN (:excludeList)')«/* TODO fix composite keys */»
                      ->setParameter('excludeList', $exclude);
            }

            $query = $this->addSearchFilter($query, $fragment);

            $result = $query->getResult();

            return array($result, $count);
        }

        /**
         * Adds where clause for search query.
         *
         * @param Doctrine_Query $query    The query instance to be enhanced.
         * @param string         $fragment The fragment to search for.
         *
         * @return Doctrine_Query The enrichted query instance.
         */
        protected function addSearchFilter($query, $fragment = '')
        {
            if ($fragment == '') {
                return $query;
            }

            $where = '';
            «FOR field : getDerivedFields.filter(e|!e.primaryKey && e.isContainedInSearch)»
                $where .= ((!empty($where)) ? ' OR ' : '');
                $where .= 'tbl.«field.name.formatForCode» «IF field.isTextSearch»LIKE %:fragment%«ELSE»= :fragment«ENDIF»';
            «ENDFOR»
            $where = '(' . $where . ')';

            $query->andWhere($where)
                  ->setParameter('fragment', $fragment);

            return $query;
        }
    '''

    def private selectCount(Entity it) '''
        /**
         * Returns query for a count query.
         *
         * @param string  $where    The where clause to use when retrieving the object count (optional) (default='').
         * @param boolean $useJoins Whether to include joining related objects (optional) (default=true).
         *
         * @return Doctrine_Query created query instance.
         * @TODO fix usage of joins; please remove the first line and test.
         */
        protected function getCountQuery($where = '', $useJoins = true)
        {
            $useJoins = false;

            $selection = 'COUNT(tbl.id) AS num«nameMultiple.formatForCodeCapital»';
            if ($useJoins === true) {
                $selection .= $this->addJoinsToSelection();
            }

            $qb = $this->getEntityManager()->createQueryBuilder();
            $qb->select($selection)
               ->from('«implClassModelEntity»', 'tbl');

            if ($useJoins === true) {
                $this->addJoinsToFrom($qb);
            }

            if (!empty($where)) {
                $qb->where($where);
            }

            $query = $qb->getQuery();
            return $query;
        }

        /**
         * Selects entity count with a given where clause.
         *
         * @param string  $where    The where clause to use when retrieving the object count (optional) (default='').
         * @param boolean $useJoins Whether to include joining related objects (optional) (default=true).
         *
         * @return integer amount of affected records
         */
        public function selectCount($where = '', $useJoins = true)
        {
            $query = $this->getCountQuery($where, $useJoins);
            «IF hasPessimisticReadLock»
                $query->setLockMode(LockMode::«lockType.asConstant»);
            «ENDIF»
            return $query->getSingleScalarResult();
        }
    '''

    def private detectUniqueState(Entity it) '''
        /**
         * Checks for unique values.
         *
         * @param string $fieldName  The name of the property to be checked
         * @param string $fieldValue The value of the property to be checked
         * @param int    $excludeid  Id of «nameMultiple.formatForDisplay» to exclude (optional).
         * @return boolean result of this check, true if the given «name.formatForDisplay» does not already exist
         */
        public function detectUniqueState($fieldName, $fieldValue, $excludeid = 0)
        {
            $query = $this->getCountQuery($where, $useJoins);
            $query->andWhere('tbl.' . $fieldName . ' = :' . $fieldName)
                  ->setParameter($fieldName, $fieldValue);

            if ($excludeid > 0) {
                $query->andWhere('tbl.id != :excludeId')
                      ->setParameter('excludeId', $excludeid);
            }

            «IF hasPessimisticReadLock»
                $query->setLockMode(LockMode::«lockType.asConstant»);
            «ENDIF»
            $count = $query->getSingleScalarResult();

            return ($count == 0);
        }
    '''

    def private intBaseQuery(Entity it) '''
        /**
         * Builds a generic Doctrine query supporting WHERE and ORDER BY.
         *
         * @param string  $where    The where clause to use when retrieving the collection (optional) (default='').
         * @param string  $orderBy  The order-by clause to use when retrieving the collection (optional) (default='').
         * @param boolean $useJoins Whether to include joining related objects (optional) (default=true).
         *
         * @return Doctrine\ORM\Query query instance to be further processed
         */
        protected function _intBaseQuery($where = '', $orderBy = '', $useJoins = true)
        {
            $selection = 'tbl';
            if ($useJoins === true) {
                $selection .= $this->addJoinsToSelection();
            }

            $qb = $this->getEntityManager()->createQueryBuilder();
            $qb->select($selection)
               ->from('«implClassModelEntity»', 'tbl');

            if ($useJoins === true) {
                $this->addJoinsToFrom($qb);
            }

            if (!empty($where)) {
                $qb->where($where);
            }
            «IF standardFields»
                $onlyOwn = (int) FormUtil::getPassedValue('own', 0, 'GETPOST');
                if ($onlyOwn == 1) {
                    $qb->andWhere('tbl.createdUserId = :creator')
                       ->setParameter('creator', UserUtil::getVar('uid'));
                }
            «ENDIF»

            // add order by clause
            if (!empty($orderBy)) {
                if (strpos($orderBy, '.') === false) {
                    $orderBy = 'tbl.' . $orderBy;
                }
                $qb->add('orderBy', $orderBy);
            }

            «intBaseQueryCommonParts»
        }

        /**
         * Builds a generic Doctrine query supporting WHERE and ORDER BY.
         * This version uses no joins at all and selects only a minimal set of fields.
         *
         * @TODO merge both queries into one more flexible version.
         *
         * @param string  $where   The where clause to use when retrieving the collection (optional) (default='').
         * @param string  $orderBy The order-by clause to use when retrieving the collection (optional) (default='').
         *
         * @return Doctrine\ORM\Query query instance to be further processed
         */
        protected function _intBaseQuerySimple($where = '', $orderBy = '')
        {
            $titleField = $this->getTitleFieldName();
            $selection = '«FOR pkField : getPrimaryKeyFields SEPARATOR ', '»tbl.«pkField.name.formatForCode»«ENDFOR»';
            if ($titleField != '') {
                $selection .= ', tbl.' . $titleField;
            }
            «IF hasSluggableFields»
                $selection .= ', tbl.slug';
            «ENDIF»

            $qb = $this->getEntityManager()->createQueryBuilder();
            $qb->select($selection)
               ->from('«implClassModelEntity»', 'tbl');

            if (!empty($where)) {
                $qb->where($where);
            }

            // add order by clause
            if (!empty($orderBy)) {
                $qb->add('orderBy', 'tbl.' . $orderBy);
            }

            «intBaseQueryCommonParts»
        }
    '''

    def private intBaseQueryCommonParts(Entity it) '''
        $query = $qb->getQuery();

        // TODO - see https://github.com/zikula/core/issues/118
        // use FilterUtil to support generic filtering
        //$fu = new FilterUtil('«container.application.appName»', $this);

        // you could set explicit filters at this point, something like
        // $fu->setFilter('type:eq:' . $args['type'] . ',id:eq:' . $args['id']);
        // supported operators: eq, ne, like, lt, le, gt, ge, null, notnull

        // process request input filters and add them to the query.
        //$fu->enrichQuery($query);

        «IF hasTranslatableFields»
            // set the translation query hint
            $query->setHint(
                \Doctrine\ORM\Query::HINT_CUSTOM_OUTPUT_WALKER,
                'Gedmo\\Translatable\\Query\\TreeWalker\\TranslationWalker'
            );

        «ENDIF»
        «IF hasPessimisticReadLock»
            $query->setLockMode(LockMode::«lockType.asConstant»);
        «ENDIF»

        return $query;
    '''

    def private singleSortingField(EntityField it) {
        switch it {
            DerivedField : {
                val joins = entity.incoming.filter(typeof(JoinRelationship)).filter(e|formatForDB(e.getSourceFields.head) == name.formatForDB)
                if (!joins.isEmpty) '''
                     '«joins.head.source.name.formatForCode»',
                     '''
                else '''
                     '«name.formatForCode»',
                     '''
            }
            CalculatedField: '''
                     '«name.formatForCode»',
                     '''
        }
    }

    def private isContainedInSearch(DerivedField it) {
        switch it {
            BooleanField: false
            ArrayField: false
            ObjectField: false
            default: true
        }
    }

    def private isTextSearch(DerivedField it) {
        switch it {
            StringField: true
            TextField: true
            default: false
        }
    }

    def private extensionSortingFields(Entity it) '''
        «IF geographical»
             'latitude',
             'longitude',
        «ENDIF»
        «IF standardFields»
             'createdUserId',
             'updatedUserId',
             'createdDate',
             'updatedDate',
        «ENDIF»
    '''


    def private modelRepositoryImpl(Entity it, Application app) '''
        /**
         * Repository class used to implement own convenience methods for performing certain DQL queries.
         *
         * This is the concrete repository class for «name.formatForDisplay» entities.
         */
        class «implClassModel('repository', '')» extends «IF isInheriting»«parentType.implClassModel('repository', '')»«ELSE»«baseClassModel('repository', '')»«ENDIF»
        {
            // feel free to add your own methods here, like for example reusable DQL queries
        }
    '''
}
