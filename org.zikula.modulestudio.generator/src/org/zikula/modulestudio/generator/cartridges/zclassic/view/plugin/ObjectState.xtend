package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin

import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ObjectState {
    extension FormattingExtensions = new FormattingExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate(Application it, IFileSystemAccess fsa) {
        val pluginFilePath = viewPluginFilePath('modifier', 'ObjectState')
        if (!shouldBeSkipped(pluginFilePath)) {
            fsa.generateFile(pluginFilePath, new FileHelper().phpFileContent(it, objectStateImpl))
        }
    }

    def private objectStateImpl(Application it) '''
        /**
         * The appName.formatForDBObjectState modifier displays the name of a given object's workflow state.
         * Examples:
         *    {$item.workflowState|appName.formatForDBObjectState}       {* with visual feedback *}
         *    {$item.workflowState|appName.formatForDBObjectState:false} {* no ui feedback *}
         *
         * @param string  $state      Name of given workflow state.
         * @param boolean $uiFeedback Whether the output should include some visual feedback about the state.
         *
         * @return string Enriched and translated workflow state ready for display.
         */
        function smarty_modifier_appName.formatForDBObjectState($state = 'initial', $uiFeedback = true)
        {
            $serviceManager = ServiceUtil::getManager();
            IF targets('1.3.5')
                $workflowHelper = new appName_Util_Workflow($serviceManager);
            ELSE
                $workflowHelper = $serviceManager->get('appName.formatForDB.workflow_helper');
            ENDIF

            $stateInfo = $workflowHelper->getStateInfo($state);

            $result = $stateInfo['text'];
            if ($uiFeedback === true) {
                IF targets('1.3.5')/* led images (legacy) */
                    $result = '<img src="' . System::getBaseUrl() . 'images/icons/extrasmall/' . $stateInfo['ui'] . 'led.png" width="16" height="16" alt="' . $result . '" />&nbsp;&nbsp;' . $result;
                ELSE/* use Bootstrap labels instead of images */
                    $result = '<span class="label label-' . $stateInfo['ui'] . '">' . $result . '</span>';
                ENDIF
            }

            return $result;
        }
    '''
}
