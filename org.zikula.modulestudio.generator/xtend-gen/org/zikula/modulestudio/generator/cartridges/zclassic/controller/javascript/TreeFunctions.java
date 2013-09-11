package org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript;

import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class TreeFunctions {
  @Inject
  @Extension
  private FormattingExtensions _formattingExtensions = new Function0<FormattingExtensions>() {
    public FormattingExtensions apply() {
      FormattingExtensions _formattingExtensions = new FormattingExtensions();
      return _formattingExtensions;
    }
  }.apply();
  
  @Inject
  @Extension
  private NamingExtensions _namingExtensions = new Function0<NamingExtensions>() {
    public NamingExtensions apply() {
      NamingExtensions _namingExtensions = new NamingExtensions();
      return _namingExtensions;
    }
  }.apply();
  
  @Inject
  @Extension
  private Utils _utils = new Function0<Utils>() {
    public Utils apply() {
      Utils _utils = new Utils();
      return _utils;
    }
  }.apply();
  
  /**
   * Entry point for tree-related javascript functions.
   */
  public void generate(final Application it, final IFileSystemAccess fsa) {
    InputOutput.<String>println("Generating javascript for tree functions");
    String _appJsPath = this._namingExtensions.getAppJsPath(it);
    String _appName = this._utils.appName(it);
    String _plus = (_appJsPath + _appName);
    String _plus_1 = (_plus + "_tree.js");
    CharSequence _generate = this.generate(it);
    fsa.generateFile(_plus_1, _generate);
  }
  
  private CharSequence generate(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("\'use strict\';");
    _builder.newLine();
    _builder.newLine();
    _builder.append("var currentNodeId = 0;");
    _builder.newLine();
    _builder.newLine();
    CharSequence _performTreeOperation = this.performTreeOperation(it);
    _builder.append(_performTreeOperation, "");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _initTreeNodes = this.initTreeNodes(it);
    _builder.append(_initTreeNodes, "");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _treeSave = this.treeSave(it);
    _builder.append(_treeSave, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence initTreeNodes(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("var ");
    String _prefix = this._utils.prefix(it);
    _builder.append(_prefix, "");
    _builder.append("TreeContextMenu;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    String _prefix_1 = this._utils.prefix(it);
    _builder.append(_prefix_1, "");
    _builder.append("TreeContextMenu = Class.create(Zikula.UI.ContextMenu, {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("selectMenuItem: function ($super, event, item, item_container) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// open in new tab / window when right-clicked");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (event.isRightClick()) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("item.callback(this.clicked, true);");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("event.stop(); // close the menu");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("return;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// open in current window when left-clicked");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return $super(event, item, item_container);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("});");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Initialise event handlers for all nodes of a given tree root.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("function ");
    String _prefix_2 = it.getPrefix();
    _builder.append(_prefix_2, "");
    _builder.append("InitTreeNodes(objectType, controller, rootId, hasDisplay, hasEdit)");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$$(\'#itemtree\' + rootId + \' a\').each(function (elem) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("var liRef, isRoot, contextMenu;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// get reference to list item");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("liRef = elem.up();");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("isRoot = (liRef.id === \'tree\' + rootId + \'node_\' + rootId);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// define a link id");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("elem.id = liRef.id + \'link\';");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// and use it to attach a context menu");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("contextMenu = new ");
    String _prefix_3 = this._utils.prefix(it);
    _builder.append(_prefix_3, "        ");
    _builder.append("TreeContextMenu(elem.id, { leftClick: true, animation: false });");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("if (hasDisplay === true) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("contextMenu.addItem({");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("label: \'<img src=\"\' + Zikula.Config.baseURL + \'images/icons/extrasmall/kview.png\" width=\"16\" height=\"16\" alt=\"\' + Zikula.__(\'Display\', \'module_");
    String _appName = this._utils.appName(it);
    String _formatForDB = this._formattingExtensions.formatForDB(_appName);
    _builder.append(_formatForDB, "                ");
    _builder.append("_js\') + \'\" /> \'");
    _builder.newLineIfNotEmpty();
    _builder.append("                     ");
    _builder.append("+ Zikula.__(\'Display\', \'module_");
    String _appName_1 = this._utils.appName(it);
    String _formatForDB_1 = this._formattingExtensions.formatForDB(_appName_1);
    _builder.append(_formatForDB_1, "                     ");
    _builder.append("_js\'),");
    _builder.newLineIfNotEmpty();
    _builder.append("                ");
    _builder.append("callback: function () {");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("currentNodeId = liRef.id.replace(\'tree\' + rootId + \'node_\', \'\');");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("window.location = Zikula.Config.baseURL + \'index.php?module=");
    String _appName_2 = this._utils.appName(it);
    _builder.append(_appName_2, "                    ");
    _builder.append("&type=\' + controller + \'&func=display&ot=\' + objectType + \'&id=\' + currentNodeId;");
    _builder.newLineIfNotEmpty();
    _builder.append("                ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("});");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (hasEdit === true) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("contextMenu.addItem({");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("label: \'<img src=\"\' + Zikula.Config.baseURL + \'images/icons/extrasmall/edit.png\" width=\"16\" height=\"16\" alt=\"\' + Zikula.__(\'Edit\', \'module_");
    String _appName_3 = this._utils.appName(it);
    String _formatForDB_2 = this._formattingExtensions.formatForDB(_appName_3);
    _builder.append(_formatForDB_2, "                ");
    _builder.append("_js\') + \'\" /> \'");
    _builder.newLineIfNotEmpty();
    _builder.append("                     ");
    _builder.append("+ Zikula.__(\'Edit\', \'module_");
    String _appName_4 = this._utils.appName(it);
    String _formatForDB_3 = this._formattingExtensions.formatForDB(_appName_4);
    _builder.append(_formatForDB_3, "                     ");
    _builder.append("_js\'),");
    _builder.newLineIfNotEmpty();
    _builder.append("                ");
    _builder.append("callback: function () {");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("currentNodeId = liRef.id.replace(\'tree\' + rootId + \'node_\', \'\');");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("window.location = Zikula.Config.baseURL + \'index.php?module=");
    String _appName_5 = this._utils.appName(it);
    _builder.append(_appName_5, "                    ");
    _builder.append("&type=\' + controller + \'&func=edit&ot=\' + objectType + \'&id=\' + currentNodeId;");
    _builder.newLineIfNotEmpty();
    _builder.append("                ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("});");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("contextMenu.addItem({");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("label: \'<img src=\"\' + Zikula.Config.baseURL + \'images/icons/extrasmall/insert_table_row.png\" width=\"16\" height=\"16\" alt=\"\' + Zikula.__(\'Add child node\', \'module_");
    String _appName_6 = this._utils.appName(it);
    String _formatForDB_4 = this._formattingExtensions.formatForDB(_appName_6);
    _builder.append(_formatForDB_4, "            ");
    _builder.append("_js\') + \'\" /> \'");
    _builder.newLineIfNotEmpty();
    _builder.append("                 ");
    _builder.append("+ Zikula.__(\'Add child node\', \'module_");
    String _appName_7 = this._utils.appName(it);
    String _formatForDB_5 = this._formattingExtensions.formatForDB(_appName_7);
    _builder.append(_formatForDB_5, "                 ");
    _builder.append("_js\'),");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("callback: function () {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("currentNodeId = liRef.id.replace(\'tree\' + rootId + \'node_\', \'\');");
    _builder.newLine();
    _builder.append("                ");
    String _prefix_4 = it.getPrefix();
    _builder.append(_prefix_4, "                ");
    _builder.append("PerformTreeOperation(objectType, rootId, \'addChildNode\');");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("});");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("contextMenu.addItem({");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("label: \'<img src=\"\' + Zikula.Config.baseURL + \'images/icons/extrasmall/14_layer_deletelayer.png\" width=\"16\" height=\"16\" alt=\"\' + Zikula.__(\'Delete node\', \'module_");
    String _appName_8 = this._utils.appName(it);
    String _formatForDB_6 = this._formattingExtensions.formatForDB(_appName_8);
    _builder.append(_formatForDB_6, "            ");
    _builder.append("_js\') + \'\" /> \'");
    _builder.newLineIfNotEmpty();
    _builder.append("                 ");
    _builder.append("+ Zikula.__(\'Delete node\', \'module_");
    String _appName_9 = this._utils.appName(it);
    String _formatForDB_7 = this._formattingExtensions.formatForDB(_appName_9);
    _builder.append(_formatForDB_7, "                 ");
    _builder.append("_js\'),");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("callback: function () {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("var confirmQuestion;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("                ");
    _builder.append("confirmQuestion = Zikula.__(\'Do you really want to remove this node?\', \'module_");
    String _appName_10 = this._utils.appName(it);
    String _formatForDB_8 = this._formattingExtensions.formatForDB(_appName_10);
    _builder.append(_formatForDB_8, "                ");
    _builder.append("_js\');");
    _builder.newLineIfNotEmpty();
    _builder.append("                ");
    _builder.append("if (!liRef.hasClassName(\'z-tree-leaf\')) {");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("confirmQuestion = Zikula.__(\'Do you really want to remove this node including all child nodes?\', \'module_");
    String _appName_11 = this._utils.appName(it);
    String _formatForDB_9 = this._formattingExtensions.formatForDB(_appName_11);
    _builder.append(_formatForDB_9, "                    ");
    _builder.append("_js\');");
    _builder.newLineIfNotEmpty();
    _builder.append("                ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("if (window.confirm(confirmQuestion) !== false) {");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("currentNodeId = liRef.id.replace(\'tree\' + rootId + \'node_\', \'\');");
    _builder.newLine();
    _builder.append("                    ");
    String _prefix_5 = it.getPrefix();
    _builder.append(_prefix_5, "                    ");
    _builder.append("PerformTreeOperation(objectType, rootId, \'deleteNode\');");
    _builder.newLineIfNotEmpty();
    _builder.append("                ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("});");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("contextMenu.addItem({");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("label: \'<img src=\"\' + Zikula.Config.baseURL + \'images/icons/extrasmall/14_layer_raiselayer.png\" width=\"16\" height=\"16\" alt=\"\' + Zikula.__(\'Move up\', \'module_");
    String _appName_12 = this._utils.appName(it);
    String _formatForDB_10 = this._formattingExtensions.formatForDB(_appName_12);
    _builder.append(_formatForDB_10, "            ");
    _builder.append("_js\') + \'\" /> \'");
    _builder.newLineIfNotEmpty();
    _builder.append("                 ");
    _builder.append("+ Zikula.__(\'Move up\', \'module_");
    String _appName_13 = this._utils.appName(it);
    String _formatForDB_11 = this._formattingExtensions.formatForDB(_appName_13);
    _builder.append(_formatForDB_11, "                 ");
    _builder.append("_js\'),");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("condition: function () {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("return !isRoot && !liRef.hasClassName(\'z-tree-first\'); // has previous sibling");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("},");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("callback: function () {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("currentNodeId = liRef.id.replace(\'tree\' + rootId + \'node_\', \'\');");
    _builder.newLine();
    _builder.append("                ");
    String _prefix_6 = it.getPrefix();
    _builder.append(_prefix_6, "                ");
    _builder.append("PerformTreeOperation(objectType, rootId, \'moveNodeUp\');");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("});");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("contextMenu.addItem({");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("label: \'<img src=\"\' + Zikula.Config.baseURL + \'images/icons/extrasmall/14_layer_lowerlayer.png\" width=\"16\" height=\"16\" alt=\"\' + Zikula.__(\'Move down\', \'module_");
    String _appName_14 = this._utils.appName(it);
    String _formatForDB_12 = this._formattingExtensions.formatForDB(_appName_14);
    _builder.append(_formatForDB_12, "            ");
    _builder.append("_js\') + \'\" /> \'");
    _builder.newLineIfNotEmpty();
    _builder.append("                 ");
    _builder.append("+ Zikula.__(\'Move down\', \'module_");
    String _appName_15 = this._utils.appName(it);
    String _formatForDB_13 = this._formattingExtensions.formatForDB(_appName_15);
    _builder.append(_formatForDB_13, "                 ");
    _builder.append("_js\'),");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("condition: function () {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("return !isRoot && !liRef.hasClassName(\'z-tree-last\'); // has next sibling");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("},");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("callback: function () {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("currentNodeId = liRef.id.replace(\'tree\' + rootId + \'node_\', \'\');");
    _builder.newLine();
    _builder.append("                ");
    String _prefix_7 = it.getPrefix();
    _builder.append(_prefix_7, "                ");
    _builder.append("PerformTreeOperation(objectType, rootId, \'moveNodeDown\');");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("});");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("});");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence performTreeOperation(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Helper function to start several different ajax actions");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* performing tree related amendments and operations.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("function ");
    String _prefix = it.getPrefix();
    _builder.append(_prefix, "");
    _builder.append("PerformTreeOperation(objectType, rootId, op)");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("var opParam, pars, request;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("opParam = ((op === \'moveNodeUp\' || op === \'moveNodeDown\') ? \'moveNode\' : op);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("pars = \'ot=\' + objectType + \'&op=\' + opParam;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (op !== \'addRootNode\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("pars += \'&root=\' + rootId;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (!currentNodeId) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("Zikula.UI.Alert(\'Invalid node id\', Zikula.__(\'Error\', \'module_");
    String _appName = this._utils.appName(it);
    String _formatForDB = this._formattingExtensions.formatForDB(_appName);
    _builder.append(_formatForDB, "            ");
    _builder.append("_js\'));");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("pars += \'&\' + ((op === \'addChildNode\') ? \'pid\' : \'id\') + \'=\' + currentNodeId;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (op === \'moveNodeUp\') {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("pars += \'&direction=up\';");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("} else if (op === \'moveNodeDown\') {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("pars += \'&direction=down\';");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("request = new Zikula.Ajax.Request(");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("Zikula.Config.baseURL + \'");
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      if (_targets) {
        _builder.append("ajax");
      } else {
        _builder.append("index");
      }
    }
    _builder.append(".php?module=");
    String _appName_1 = this._utils.appName(it);
    _builder.append(_appName_1, "        ");
    {
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets_1);
      if (_not) {
        _builder.append("&type=ajax");
      }
    }
    _builder.append("&func=handleTreeOperation\',");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("method: \'post\',");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("parameters: pars,");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("onComplete: function (req) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("if (!req.isSuccess()) {");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("Zikula.UI.Alert(req.getMessage(), Zikula.__(\'Error\', \'module_");
    String _appName_2 = this._utils.appName(it);
    String _formatForDB_1 = this._formattingExtensions.formatForDB(_appName_2);
    _builder.append(_formatForDB_1, "                    ");
    _builder.append("_js\'));");
    _builder.newLineIfNotEmpty();
    _builder.append("                    ");
    _builder.append("return;");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("var data = req.getData();");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("/*if (data.message) {");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("Zikula.UI.Alert(data.message, Zikula.__(\'Success\', \'module_");
    String _appName_3 = this._utils.appName(it);
    String _formatForDB_2 = this._formattingExtensions.formatForDB(_appName_3);
    _builder.append(_formatForDB_2, "                    ");
    _builder.append("_js\'));");
    _builder.newLineIfNotEmpty();
    _builder.append("                ");
    _builder.append("}*/");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("window.location.reload();");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append(");");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence treeSave(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Callback function for config.onSave. This function is called after each tree change.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param node - the node which is currently being moved");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param params - array with insertion params, which are [relativenode, dir];");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*     - \"dir\" is a string with value \"after\', \"before\" or \"bottom\" and defines");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*       whether the affected node is inserted after, before or as last child of \"relativenode\"");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param tree data - serialized to JSON tree data");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return true on success, otherwise the change will be reverted");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("function ");
    String _prefix = it.getPrefix();
    _builder.append(_prefix, "");
    _builder.append("TreeSave(node, params, data)");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("var nodeParts, rootId, nodeId, destId, pars, request;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// do not allow inserts on root level");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (node.up(\'li\') === undefined) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return false;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("nodeParts = node.id.split(\'node_\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("rootId = nodeParts[0].replace(\'tree\', \'\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("nodeId = nodeParts[1];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("destId = params[1].id.replace(\'tree\' + rootId + \'node_\', \'\');");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("pars = {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'op\': \'moveNodeTo\',");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'direction\': params[0],");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'root\': rootId,");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'id\': nodeId,");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'destid\': destId");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("};");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("request = new Zikula.Ajax.Request(");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("Zikula.Config.baseURL + \'");
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      if (_targets) {
        _builder.append("ajax");
      } else {
        _builder.append("index");
      }
    }
    _builder.append(".php?module=");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "        ");
    {
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets_1);
      if (_not) {
        _builder.append("&type=ajax");
      }
    }
    _builder.append("&func=handleTreeOperation\',");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("method: \'post\',");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("parameters: pars,");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("onComplete: function (req) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("if (!req.isSuccess()) {");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("Zikula.UI.Alert(req.getMessage(), Zikula.__(\'Error\', \'module_");
    String _appName_1 = this._utils.appName(it);
    String _formatForDB = this._formattingExtensions.formatForDB(_appName_1);
    _builder.append(_formatForDB, "                    ");
    _builder.append("_js\'));");
    _builder.newLineIfNotEmpty();
    _builder.append("                    ");
    _builder.append("return Zikula.TreeSortable.categoriesTree.revertInsertion();");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("return true;");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append(");");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return request.success();");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
