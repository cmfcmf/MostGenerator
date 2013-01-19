package org.zikula.modulestudio.generator.cartridges.zclassic.controller.apis

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Category {
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension ModelBehaviourExtensions = new ModelBehaviourExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension Utils = new Utils()

    FileHelper fh = new FileHelper()

    def generate(Application it, IFileSystemAccess fsa) {
        println('Generating category api')
        val apiPath = getAppSourceLibPath + 'Api/'
        val apiClassSuffix = if (!targets('1.3.5')) 'Api' else ''
        val apiFileName = 'Category' + apiClassSuffix + '.php'
        fsa.generateFile(apiPath + 'Base/' + apiFileName, categoryBaseFile)
        fsa.generateFile(apiPath + apiFileName, categoryFile)
    }

    def private categoryBaseFile(Application it) '''
        «fh.phpFileHeader(it)»
        «categoryBaseClass»
    '''

    def private categoryFile(Application it) '''
        «fh.phpFileHeader(it)»
        «categoryImpl»
    '''

    def private categoryBaseClass(Application it) '''
        «IF !targets('1.3.5')»
            namespace «appName»\Api\Base;

        «ENDIF»
        /**
         * Category api base class.
         */
        «IF targets('1.3.5')»
        class «appName»_Api_Base_Category extends Zikula_AbstractApi
        «ELSE»
        class CategoryApi extends \Zikula_AbstractApi
        «ENDIF»
        {
            «categoryBaseImpl»
        }
    '''

    def private categoryBaseImpl(Application it) '''
        /**
         * Retrieves the main/default category of «appName».
         *
         * @param string $args['ot']       The object type to be treated (optional)
         * @param string $args['registry'] Name of category registry to be used (optional)
         * @deprecated Use the methods getAllProperties, getAllPropertiesWithMainCat, getMainCatForProperty and getPrimaryProperty instead.
         *
         * @return mixed Category array on success, false on failure
         */
        public function getMainCat(array $args = array())
        {
            if (isset($args['registry'])) {
                $args['registry'] = $this->getPrimaryProperty($args);
            }

            $objectType = $this->determineObjectType($args, 'getMainCat');

            return \CategoryRegistryUtil::getRegisteredModuleCategory($this->name, ucwords($objectType), $args['registry'], 32); // 32 == /__System/Modules/Global
        }

        /**
         * Defines whether multiple selection is enabled for a given object type
         * or not. Subclass can override this method to apply a custom behaviour
         * to certain category registries for example.
         *
         * @param string $args['ot']       The object type to be treated (optional)
         * @param string $args['registry'] Name of category registry to be used (optional)
         *
         * @return boolean true if multiple selection is allowed, else false
         */
        public function hasMultipleSelection(array $args = array())
        {
            if (isset($args['registry'])) {
                // default to the primary registry
                $args['registry'] = $this->getPrimaryProperty($args);
            }

            $objectType = $this->determineObjectType($args, 'hasMultipleSelection');

            // we make no difference between different category registries here
            // if you need a custom behaviour you should override this method

            $result = false;
            switch ($objectType) {
                «FOR entity : getCategorisableEntities»
                    case '«entity.name.formatForCode»':
                        $result = «entity.categorisableMultiSelection.displayBool»;
                        break;
                «ENDFOR»
            }

            return $result;
        }

        /**
         * Retrieves input data from POST for all registries.
         *
         * @param string $args['ot']     The object type to be treated (optional)
         * @param string $args['source'] Where to retrieve the data from (defaults to POST)
         *
         * @return array The fetched data indexed by the registry id.
         */
        public function retrieveCategoriesFromRequest(array $args = array())
        {
            $dataSource = $this->request->request;
            if (isset($args['source']) && $args['source'] == 'GET') {
                $dataSource = $this->request->query;
            }

            $catIdsPerRegistry = array();

            $objectType = $this->determineObjectType($args, 'retrieveCategoriesFromRequest');
            $properties = $this->getAllProperties($args);
            foreach ($properties as $propertyName => $propertyId) {
                $hasMultiSelection = $this->hasMultipleSelection(array('ot' => $objectType, 'registry' => $propertyName));
                if ($hasMultiSelection === true) {
                    $inputValue = $dataSource->get('catids' . $propertyName, array());
                    if (!is_array($inputValue)) {
                        $inputValue = explode(', ', $inputValue);
                    }
                } else {
                    $inputVal = (int) $dataSource->filter('catid' . $propertyName, 0, FILTER_VALIDATE_INT);
                    $inputValue = array();
                    if ($inputVal > 0) {
                        $inputValue[] = $inputVal;
                    }
                }
                $catIdsPerRegistry[$propertyName] = $inputValue;
            }

            return $catIdsPerRegistry;
        }

        /**
         * Builds a list of where clauses for a given list of categories.
         *
         * @param string $args['ot']     The object type to be treated (optional)
         * @param string $args['catids'] Category ids grouped by property name
         *
         * @return array List of where clauses per registry / property.
         */
        public function buildFilterClauses(array $args = array())
        {
            $properties = $this->getAllProperties($args);
            $catIds = $args['catids'];
            $result = array();

            foreach ($properties as $propertyName => $propertyId) {
                if (!isset($catIds[$propertyName]) || !is_array($catIds[$propertyName]) || !count($catIds[$propertyName])) {
                    continue;
                }

                $result[] = '(tblCategories.category IN (' . DataUtil::formatForStore(implode(', ', $catIds[$propertyName])) . ') AND tblCategories.categoryRegistryId = ' . $propertyId . ')';
            }

            return $result;
        }

        /**
         * Returns a list of all registries / properties for a given object type.
         *
         * @param string $args['ot'] The object type to retrieve (optional)
         *
         * @return array list of the registries (property name as key, id as value).
         */
        public function getAllProperties(array $args = array())
        {
            $objectType = $this->determineObjectType($args, 'getAllProperties');

            $propertyIdsPerName = \CategoryRegistryUtil::getRegisteredModuleCategoriesIds($this->name, ucwords($objectType));

            return $propertyIdsPerName;
        }

        /**
         * Returns a list of all registries with main category for a given object type.
         *
         * @param string $args['ot']       The object type to retrieve (optional)
         * @param string $args['arraykey'] Key for the result array (optional)
         *
         * @return array list of the registries (registry id as key, main category id as value).
         */
        public function getAllPropertiesWithMainCat(array $args = array())
        {
            $objectType = $this->determineObjectType($args, 'getAllPropertiesWithMainCat');

            if (!isset($args['arraykey'])) {
                $args['arraykey'] = '';
            }

            $registryInfo = \CategoryRegistryUtil::getRegisteredModuleCategories($this->name, ucwords($objectType), $args['arraykey']);

            return $registryInfo;
        }

        /**
         * Returns the main category id for a given object type and a certain property name.
         *
         * @param string $args['ot']       The object type to retrieve (optional)
         * @param string $args['property'] The property name (optional)
         *
         * @return integer The main category id of desired tree.
         */
        public function getMainCatForProperty(array $args = array())
        {
            $objectType = $this->determineObjectType($args, 'getMainCatForProperty');

            $catId = \CategoryRegistryUtil::getRegisteredModuleCategory($this->name, ucwords($objectType), $args['property']);

            return $catId;
        }

        /**
         * Returns the name of the primary registry.
         *
         * @param string $args['ot'] The object type to retrieve (optional)
         *
         * @return string name of the main registry.
         */
        public function getPrimaryProperty(array $args = array())
        {
            $objectType = $this->determineObjectType($args, 'getPrimaryProperty');

            $registry = 'Main';

            return $registry;
        }

        /**
         * Determine object type using controller util methods.
         *
         * @param string $args['ot'] The object type to retrieve (optional)
         * @param string $methodName Name of calling method
         *
         * @return string name of the determined object type
         */
        protected function determineObjectType(array $args = array(), $methodName = '')
        {
            $objectType = isset($args['ot']) ? $args['ot'] : '';
            $controllerHelper = new «appName»«IF targets('1.3.5')»_Util_«ELSE»\Util\«ENDIF»Controller($this->serviceManager);
            $utilArgs = array('api' => 'category', 'action' => $methodName);
            if (!in_array($objectType, $controllerHelper->getObjectTypes('api', $utilArgs))) {
                $objectType = $controllerHelper->getDefaultObjectType('api', $utilArgs);
            }

            return $objectType;
        }
    '''

    def private categoryImpl(Application it) '''
        «IF !targets('1.3.5')»
            namespace «appName»\Api;

        «ENDIF»
        /**
         * Category api implementation class.
         */
        «IF targets('1.3.5')»
        class «appName»_Api_Category extends «appName»_Api_Base_Category
        «ELSE»
        class CategoryApi extends Base\CategoryApi
        «ENDIF»
        {
            // feel free to extend the category api at this place
        }
    '''
}
