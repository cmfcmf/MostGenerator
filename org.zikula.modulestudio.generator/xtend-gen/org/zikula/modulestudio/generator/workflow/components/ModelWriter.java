package org.zikula.modulestudio.generator.workflow.components;

import java.io.IOException;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.common.util.WrappedException;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.emf.ecore.resource.URIConverter;
import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowContext;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.zikula.modulestudio.generator.workflow.components.WorkflowComponentWithSlot;

/**
 * Workflow component class for writing the enriched model for debugging
 * purposes after m2m transformation has been applied.
 */
@SuppressWarnings("all")
public class ModelWriter extends WorkflowComponentWithSlot {
  /**
   * The treated uri.
   */
  private String _uri = "";
  
  /**
   * The treated uri.
   */
  public String getUri() {
    return this._uri;
  }
  
  /**
   * The treated uri.
   */
  public void setUri(final String uri) {
    this._uri = uri;
  }
  
  /**
   * Invokes the workflow component.
   * 
   * @param ctx
   *            The given {@link IWorkflowContext} instance.
   */
  public void invoke(final IWorkflowContext ctx) {
    String _slot = this.getSlot();
    Object _get = ctx.get(_slot);
    final Resource resource = ((Resource) _get);
    String _uri = this.getUri();
    URI fileUri = URI.createFileURI(_uri);
    ResourceSet _resourceSet = resource.getResourceSet();
    URIConverter _uRIConverter = _resourceSet.getURIConverter();
    URI _normalize = _uRIConverter.normalize(fileUri);
    fileUri = _normalize;
    resource.setURI(fileUri);
    try {
      resource.save(null);
    } catch (final Throwable _t) {
      if (_t instanceof IOException) {
        final IOException e = (IOException)_t;
        WrappedException _wrappedException = new WrappedException(e);
        throw _wrappedException;
      } else {
        throw Exceptions.sneakyThrow(_t);
      }
    }
  }
}