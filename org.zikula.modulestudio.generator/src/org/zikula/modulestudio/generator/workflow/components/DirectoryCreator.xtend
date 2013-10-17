package org.zikula.modulestudio.generator.workflow.components

import java.io.File
import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowComponent
import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowContext

/**
 * Workflow component class for cleaning a certain directory.
 */
class DirectoryCreator implements IWorkflowComponent {

    /**
     * The treated directory.
     */
    @Property
    String directory = '' //$NON-NLS-1$

    /**
     * Invokes the workflow component.
     * 
     * @param ctx
     *            The given {@link org.eclipse.emf.mwe2.runtime.workflow.IWorkflowContext} instance.
     */
    override invoke(IWorkflowContext ctx) {
        if (!directory.empty) {
            val dirHandle = new File(directory)
            if (!dirHandle.mkdirs) {
                System.err.println('Error during directory creation.')
                throw new IllegalStateException('Abort the workflow')
            }
        }
    }

    /**
     * Performs actions before the invocation.
     */
    override preInvoke() {
        // Nothing to do here yet
    }

    /**
     * Performs actions after the invocation.
     */
    override postInvoke() {
        // Nothing to do here yet
    }
}
