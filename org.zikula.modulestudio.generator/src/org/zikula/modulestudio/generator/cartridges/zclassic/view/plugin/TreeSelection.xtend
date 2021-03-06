package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin

import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class TreeSelection {
    extension FormattingExtensions = new FormattingExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate(Application it, IFileSystemAccess fsa) {
        val pluginFilePath = viewPluginFilePath('function', 'TreeSelection')
        if (!shouldBeSkipped(pluginFilePath)) {
            fsa.generateFile(pluginFilePath, new FileHelper().phpFileContent(it, treeSelectionImpl))
        }
    }

    def private treeSelectionImpl(Application it) '''
        /**
         * The appName.formatForDBTreeSelection plugin retrieves tree entities based on a given one.
         *
         * Available parameters:
         *   - objectType:   Name of treated object type.
         *   - node:         Given entity as tree entry point.
         *   - target:       One of 'allParents', 'directParent', 'allChildren', 'directChildren', 'predecessors', 'successors', 'preandsuccessors'
         *   - skipRootNode: Whether root nodes are skipped or not (defaults to true). Useful for when working with many trees at once.
         *   - assign:       Variable where the results are assigned to.
         *
         * @param  array       $params All attributes passed to this function from the template.
         * @param  Zikula_View $view   Reference to the view object.
         */
        function smarty_function_appName.formatForDBTreeSelection($params, $view)
        {
            if (!isset($params['objectType']) || empty($params['objectType'])) {
                $view->trigger_error(__f('Error! in %1$s: the %2$s parameter must be specified.', array('appName.formatForDBTreeSelection', 'objectType')));

                return false;
            }

            if (!isset($params['node']) || !is_object($params['node'])) {
                $view->trigger_error(__f('Error! in %1$s: the %2$s parameter must be specified.', array('appName.formatForDBTreeSelection', 'node')));

                return false;
            }

            $allowedTargets = array('allParents', 'directParent', 'allChildren', 'directChildren', 'predecessors', 'successors', 'preandsuccessors');
            if (!isset($params['target']) || empty($params['target']) || !in_array($params['target'], $allowedTargets)) {
                $view->trigger_error(__f('Error! in %1$s: the %2$s parameter must be specified.', array('appName.formatForDBTreeSelection', 'target')));

                return false;
            }

            $skipRootNode = (isset($params['skipRootNode']) ? (bool) $params['skipRootNode'] : true);

            if (!isset($params['assign']) || empty($params['assign'])) {
                $view->trigger_error(__f('Error! in %1$s: the %2$s parameter must be specified.', array('appName.formatForDBTreeSelection', 'assign')));

                return false;
            }

            IF targets('1.3.5')
                $entityClass = 'appName_Entity_' . ucfirst($params['objectType']);
            ENDIF
            $serviceManager = ServiceUtil::getManager();
            IF targets('1.3.5')
                $entityManager = $serviceManager->getIF targets('1.3.5')ServiceENDIF('doctrine.entitymanager');
                $repository = $entityManager->getRepository($entityClass);
            ELSE
                $repository = $serviceManager->get('appName.formatForDB.' . $params['objectType'] . '_factory')->getRepository();
            ENDIF
            $titleFieldName = $repository->getTitleFieldName();

            $node = $params['node'];
            $result = null;

            switch ($params['target']) {
                case 'allParents':
                case 'directParent':
                    $path = $repository->getPath($node);
                    if (count($path) > 0) {
                        // remove $node
                        unset($path[count($path)-1]);
                    }
                    if ($skipRootNode && count($path) > 0) {
                        // remove root level
                        array_shift($path);
                    }
                    if ($params['target'] == 'allParents') {
                        $result = $path;
                    } elseif ($params['target'] == 'directParent' && count($path) > 0) {
                        $result = $path[count($path)-1];
                    }
                    break;
                case 'allChildren':
                case 'directChildren':
                    $direct = ($params['target'] == 'directChildren');
                    $sortByField = ($titleFieldName != '') ? $titleFieldName : null;
                    $sortDirection = 'ASC';
                    $result = $repository->children($node, $direct, $sortByField, $sortDirection);
                    break;
                case 'predecessors':
                    $includeSelf = false;
                    $result = $repository->getPrevSiblings($node, $includeSelf);
                    break;
                case 'successors':
                    $includeSelf = false;
                    $result = $repository->getNextSiblings($node, $includeSelf);
                    break;
                case 'preandsuccessors':
                    $includeSelf = false;
                    $result = array_merge($repository->getPrevSiblings($node, $includeSelf), $repository->getNextSiblings($node, $includeSelf));
                    break;
            }

            $view->assign($params['assign'], $result);
        }
    '''
}
