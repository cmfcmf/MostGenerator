package org.zikula.modulestudio.generator.cartridges.zclassic.controller

import org.zikula.modulestudio.generator.extensions.FormattingExtensions

class ControllerHelper {
    extension FormattingExtensions = new FormattingExtensions

    def controllerPostInitialize(Object it, Boolean caching, String additionalCommands) '''
        /**
         * Post initialise.
         *
         * Run after construction.
         *
         * @return void
         */
        protected function postInitialize()
        {
            // Set caching to caching.displayBool by default.
            $this->view->setCaching(Zikula_View::CACHE_IF cachingENABLEDELSEDISABLEDENDIF);
            IF additionalCommands != ''
                additionalCommands
            ENDIF
        }
    '''

    def defaultSorting(Object it) '''
        if (empty($sort) || !in_array($sort, $repository->getAllowedSortingFields())) {
            $sort = $repository->getDefaultSortingField();
        }
    '''
}
