package org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions;

import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

/**
 * This class creates additional artifacts which can be helpful for Scribite integration.
 */
@SuppressWarnings("all")
public class Scribite {
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
  private ModelExtensions _modelExtensions = new Function0<ModelExtensions>() {
    public ModelExtensions apply() {
      ModelExtensions _modelExtensions = new ModelExtensions();
      return _modelExtensions;
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
  
  public void generate(final Application it, final IFileSystemAccess fsa) {
    InputOutput.<String>println("Generating Scribite support");
    String _appDocPath = this._namingExtensions.getAppDocPath(it);
    String docPath = (_appDocPath + "scribite/");
    String _plus = (docPath + "integration.txt");
    CharSequence _integration = this.integration(it);
    fsa.generateFile(_plus, _integration);
    String _plus_1 = (docPath + "plugins/");
    docPath = _plus_1;
    String _plus_2 = (docPath + "CKEditor/vendor/ckeditor/plugins/");
    String _name = it.getName();
    String _formatForDB = this._formattingExtensions.formatForDB(_name);
    String _plus_3 = (_plus_2 + _formatForDB);
    String pluginPath = (_plus_3 + "/");
    String _plus_4 = (pluginPath + "plugin.js");
    CharSequence _ckPlugin = this.ckPlugin(it);
    fsa.generateFile(_plus_4, _ckPlugin);
    String _plus_5 = (pluginPath + "lang/de.js");
    CharSequence _ckLangDe = this.ckLangDe(it);
    fsa.generateFile(_plus_5, _ckLangDe);
    String _plus_6 = (pluginPath + "lang/en.js");
    CharSequence _ckLangEn = this.ckLangEn(it);
    fsa.generateFile(_plus_6, _ckLangEn);
    String _plus_7 = (pluginPath + "lang/nl.js");
    CharSequence _ckLangNl = this.ckLangNl(it);
    fsa.generateFile(_plus_7, _ckLangNl);
    String _xifexpression = null;
    boolean _targets = this._utils.targets(it, "1.3.5");
    if (_targets) {
      _xifexpression = "TineMCE";
    } else {
      _xifexpression = "TinyMce";
    }
    String _plus_8 = (docPath + _xifexpression);
    String _plus_9 = (_plus_8 + "/vendor/tiny_mce/plugins/");
    String _name_1 = it.getName();
    String _formatForDB_1 = this._formattingExtensions.formatForDB(_name_1);
    String _plus_10 = (_plus_9 + _formatForDB_1);
    String _plus_11 = (_plus_10 + "/");
    pluginPath = _plus_11;
    String _plus_12 = (pluginPath + "editor_plugin.js");
    CharSequence _tinyPlugin = this.tinyPlugin(it);
    fsa.generateFile(_plus_12, _tinyPlugin);
    String _plus_13 = (pluginPath + "langs/de.js");
    CharSequence _tinyLangDe = this.tinyLangDe(it);
    fsa.generateFile(_plus_13, _tinyLangDe);
    String _plus_14 = (pluginPath + "langs/en.js");
    CharSequence _tinyLangEn = this.tinyLangEn(it);
    fsa.generateFile(_plus_14, _tinyLangEn);
    String _plus_15 = (pluginPath + "langs/nl.js");
    CharSequence _tinyLangNl = this.tinyLangNl(it);
    fsa.generateFile(_plus_15, _tinyLangNl);
    String _plus_16 = (docPath + "WYMeditor/vendor/wymeditor/plugins/");
    String _name_2 = it.getName();
    String _formatForDB_2 = this._formattingExtensions.formatForDB(_name_2);
    String _plus_17 = (_plus_16 + _formatForDB_2);
    String _plus_18 = (_plus_17 + "/");
    pluginPath = _plus_18;
    String _plus_19 = (docPath + "Xinha/");
    String _xifexpression_1 = null;
    boolean _targets_1 = this._utils.targets(it, "1.3.5");
    if (_targets_1) {
      _xifexpression_1 = "plugins";
    } else {
      _xifexpression_1 = "vendor";
    }
    String _plus_20 = (_plus_19 + _xifexpression_1);
    String _plus_21 = (_plus_20 + "/xinha/plugins/");
    String _appName = this._utils.appName(it);
    String _plus_22 = (_plus_21 + _appName);
    String _plus_23 = (_plus_22 + "/");
    pluginPath = _plus_23;
    String _appName_1 = this._utils.appName(it);
    String _plus_24 = (pluginPath + _appName_1);
    String _plus_25 = (_plus_24 + ".js");
    CharSequence _xinhaPlugin = this.xinhaPlugin(it);
    fsa.generateFile(_plus_25, _xinhaPlugin);
  }
  
  private CharSequence integration(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("SCRIBITE INTEGRATION");
    _builder.newLine();
    _builder.append("--------------------");
    _builder.newLine();
    _builder.newLine();
    _builder.append("It is easy to include ");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "");
    _builder.append(" in your Scribite editors.");
    _builder.newLineIfNotEmpty();
    _builder.append("While ");
    String _appName_1 = this._utils.appName(it);
    _builder.append(_appName_1, "");
    _builder.append(" contains already the a popup for selecting ");
    Entity _leadingEntity = this._modelExtensions.getLeadingEntity(it);
    String _nameMultiple = _leadingEntity.getNameMultiple();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_nameMultiple);
    _builder.append(_formatForDisplay, "");
    _builder.append(" and other items,");
    _builder.newLineIfNotEmpty();
    _builder.append("the actual Scribite enhancements must be done manually for Scribite <= 4.3.");
    _builder.newLine();
    _builder.append("From Scribite 5.0 onwards the integration is automatic. The necessary javascript is loaded via event system and the");
    _builder.newLine();
    _builder.append("plugins are already in the Scribite package.");
    _builder.newLine();
    _builder.newLine();
    _builder.append("Just follow these few steps to complete the integration for Scribite <= 4.3:");
    _builder.newLine();
    _builder.append("  ");
    _builder.append("1. Open modules/Scribite/lib/Scribite/Api/User.php in your favourite text editor.");
    _builder.newLine();
    _builder.append("  ");
    _builder.append("2. Search for");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (ModUtil::available(\'SimpleMedia\')) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("PageUtil::AddVar(\'javascript\', \'modules/SimpleMedia/");
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      if (_targets) {
        _builder.append("javascript");
      } else {
        _builder.append("Resources/public/js");
      }
    }
    _builder.append("/findItem.js\');");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("  ");
    _builder.append("3. Below this add");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (ModUtil::available(\'");
    String _appName_2 = this._utils.appName(it);
    _builder.append(_appName_2, "        ");
    _builder.append("\')) {");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("PageUtil::AddVar(\'javascript\', \'modules/");
    String _appName_3 = this._utils.appName(it);
    _builder.append(_appName_3, "            ");
    _builder.append("/");
    {
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      if (_targets_1) {
        _builder.append("javascript");
      } else {
        _builder.append("Resources/public/js");
      }
    }
    _builder.append("/");
    String _appName_4 = this._utils.appName(it);
    _builder.append(_appName_4, "            ");
    _builder.append("_finder.js\');");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("  ");
    _builder.append("4. Copy or move all files from ");
    {
      boolean _targets_2 = this._utils.targets(it, "1.3.5");
      if (_targets_2) {
        _builder.append("modules/");
        String _appName_5 = this._utils.appName(it);
        _builder.append(_appName_5, "  ");
      } else {
        _builder.append("Resources");
      }
    }
    _builder.append("/docs/scribite/plugins/ into modules/Scribite/plugins/.");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("Just follow these few steps to complete the integration for Scribite >= 5.0:");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("1. Check if the plugins for ");
    String _appName_6 = this._utils.appName(it);
    _builder.append(_appName_6, " ");
    _builder.append(" are in Scribite/plugins/EDITOR/vendor/plugins. If not then copy from");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("modules/");
    String _appName_7 = this._utils.appName(it);
    _builder.append(_appName_7, "    ");
    _builder.append("/");
    {
      boolean _targets_3 = this._utils.targets(it, "1.3.5");
      if (_targets_3) {
        _builder.append("docs");
      } else {
        String _appDocPath = this._namingExtensions.getAppDocPath(it);
        _builder.append(_appDocPath, "    ");
      }
    }
    _builder.append("/scribite/plugins into modules/Scribite/plugins.");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence ckPlugin(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("CKEDITOR.plugins.add(\'");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "");
    _builder.append("\', {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("requires: \'popup\',");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("lang: \'en,nl,de\',");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("init: function (editor) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("editor.addCommand(\'insert");
    String _appName_1 = this._utils.appName(it);
    _builder.append(_appName_1, "        ");
    _builder.append("\', {");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("exec: function (editor) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("var url = Zikula.Config.baseURL + Zikula.Config.entrypoint + \'?module=");
    String _appName_2 = this._utils.appName(it);
    _builder.append(_appName_2, "                ");
    _builder.append("&type=external&func=finder&editor=ckeditor\';");
    _builder.newLineIfNotEmpty();
    _builder.append("                ");
    _builder.append("// call method in ");
    String _appName_3 = this._utils.appName(it);
    _builder.append(_appName_3, "                ");
    _builder.append("_Finder.js and also give current editor");
    _builder.newLineIfNotEmpty();
    _builder.append("                ");
    String _appName_4 = this._utils.appName(it);
    _builder.append(_appName_4, "                ");
    _builder.append("FinderCKEditor(editor, url);");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("});");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("editor.ui.addButton(\'");
    String _appName_5 = this._utils.appName(it);
    String _formatForDB = this._formattingExtensions.formatForDB(_appName_5);
    _builder.append(_formatForDB, "        ");
    _builder.append("\', {");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("label: \'Insert ");
    String _appName_6 = this._utils.appName(it);
    _builder.append(_appName_6, "            ");
    _builder.append(" object\',");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("command: \'insert");
    String _appName_7 = this._utils.appName(it);
    _builder.append(_appName_7, "            ");
    _builder.append("\',");
    _builder.newLineIfNotEmpty();
    _builder.append("         ");
    _builder.append("// icon: this.path + \'images/ed_");
    String _appName_8 = this._utils.appName(it);
    String _formatForDB_1 = this._formattingExtensions.formatForDB(_appName_8);
    _builder.append(_formatForDB_1, "         ");
    _builder.append(".png\'");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("icon: \'/images/icons/extrasmall/favorites.png\'");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("});");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("});");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence ckLangDe(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("tinyMCE.addI18n(\'de.");
    String _name = it.getName();
    String _formatForDB = this._formattingExtensions.formatForDB(_name);
    _builder.append(_formatForDB, "");
    _builder.append("\', {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("title : \'");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "    ");
    _builder.append("-Objekt einf\u00FCgen\',");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("alt: \'");
    String _appName_1 = this._utils.appName(it);
    _builder.append(_appName_1, "    ");
    _builder.append("-Objekt einf\u00FCgen\'");
    _builder.newLineIfNotEmpty();
    _builder.append("});");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence ckLangEn(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("CKEDITOR.plugins.setLang(\'");
    String _name = it.getName();
    String _formatForDB = this._formattingExtensions.formatForDB(_name);
    _builder.append(_formatForDB, "");
    _builder.append("\', \'en\', {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("title: \'Insert ");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "    ");
    _builder.append(" object\',");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("alt: \'Insert ");
    String _appName_1 = this._utils.appName(it);
    _builder.append(_appName_1, "    ");
    _builder.append(" object\'");
    _builder.newLineIfNotEmpty();
    _builder.append("});");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence ckLangNl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("tinyMCE.addI18n(\'nl.");
    String _name = it.getName();
    String _formatForDB = this._formattingExtensions.formatForDB(_name);
    _builder.append(_formatForDB, "");
    _builder.append("\', {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("title : \'");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "    ");
    _builder.append(" Object invoegen\',");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("alt: \'");
    String _appName_1 = this._utils.appName(it);
    _builder.append(_appName_1, "    ");
    _builder.append(" Object invoegen\'");
    _builder.newLineIfNotEmpty();
    _builder.append("});");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence tinyPlugin(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* editor_plugin_src.js");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Copyright 2009, Moxiecode Systems AB");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Released under LGPL License.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* License: http://tinymce.moxiecode.com/license");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Contributing: http://tinymce.moxiecode.com/contributing");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.newLine();
    _builder.append("(function () {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// Load plugin specific language pack");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("tinymce.PluginManager.requireLangPack(\'");
    String _name = it.getName();
    String _formatForDB = this._formattingExtensions.formatForDB(_name);
    _builder.append(_formatForDB, "    ");
    _builder.append("\');");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("tinymce.create(\'tinymce.plugins.");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "    ");
    _builder.append("Plugin\', {");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("         ");
    _builder.append("* Initializes the plugin, this will be executed after the plugin has been created.");
    _builder.newLine();
    _builder.append("         ");
    _builder.append("* This call is done before the editor instance has finished it\'s initialization so use the onInit event");
    _builder.newLine();
    _builder.append("         ");
    _builder.append("* of the editor instance to intercept that event.");
    _builder.newLine();
    _builder.append("         ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("         ");
    _builder.append("* @param {tinymce.Editor} ed Editor instance that the plugin is initialized in.");
    _builder.newLine();
    _builder.append("         ");
    _builder.append("* @param {string} url Absolute URL to where the plugin is located.");
    _builder.newLine();
    _builder.append("         ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("init : function (ed, url) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("// Register the command so that it can be invoked by using tinyMCE.activeEditor.execCommand(\'mce");
    String _appName_1 = this._utils.appName(it);
    _builder.append(_appName_1, "            ");
    _builder.append("\');");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("ed.addCommand(\'mce");
    String _appName_2 = this._utils.appName(it);
    _builder.append(_appName_2, "            ");
    _builder.append("\', function () {");
    _builder.newLineIfNotEmpty();
    _builder.append("                ");
    _builder.append("ed.windowManager.open({");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("file : Zikula.Config.baseURL + Zikula.Config.entrypoint + \'?module=");
    String _appName_3 = this._utils.appName(it);
    _builder.append(_appName_3, "                    ");
    _builder.append("&type=external&func=finder&editor=tinymce\',");
    _builder.newLineIfNotEmpty();
    _builder.append("                    ");
    _builder.append("width : (screen.width * 0.75),");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("height : (screen.height * 0.66),");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("inline : 1,");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("scrollbars : true,");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("resizable : true");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("}, {");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("plugin_url : url, // Plugin absolute URL");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("some_custom_arg : \'custom arg\' // Custom argument");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("});");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("});");
    _builder.newLine();
    _builder.newLine();
    _builder.append("            ");
    _builder.append("// Register ");
    String _name_1 = it.getName();
    String _formatForDB_1 = this._formattingExtensions.formatForDB(_name_1);
    _builder.append(_formatForDB_1, "            ");
    _builder.append(" button");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("ed.addButton(\'");
    String _name_2 = it.getName();
    String _formatForDB_2 = this._formattingExtensions.formatForDB(_name_2);
    _builder.append(_formatForDB_2, "            ");
    _builder.append("\', {");
    _builder.newLineIfNotEmpty();
    _builder.append("                ");
    _builder.append("title : \'");
    String _name_3 = it.getName();
    String _formatForDB_3 = this._formattingExtensions.formatForDB(_name_3);
    _builder.append(_formatForDB_3, "                ");
    _builder.append(".desc\',");
    _builder.newLineIfNotEmpty();
    _builder.append("                ");
    _builder.append("cmd : \'mce");
    String _appName_4 = this._utils.appName(it);
    _builder.append(_appName_4, "                ");
    _builder.append("\',");
    _builder.newLineIfNotEmpty();
    _builder.append("             ");
    _builder.append("// image : url + \'/img/");
    String _appName_5 = this._utils.appName(it);
    _builder.append(_appName_5, "             ");
    _builder.append(".gif\'");
    _builder.newLineIfNotEmpty();
    _builder.append("                ");
    _builder.append("image : \'/images/icons/extrasmall/favorites.png\'");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("});");
    _builder.newLine();
    _builder.newLine();
    _builder.append("            ");
    _builder.append("// Add a node change handler, selects the button in the UI when a image is selected");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("ed.onNodeChange.add(function (ed, cm, n) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("cm.setActive(\'");
    String _name_4 = it.getName();
    String _formatForDB_4 = this._formattingExtensions.formatForDB(_name_4);
    _builder.append(_formatForDB_4, "                ");
    _builder.append("\', n.nodeName === \'IMG\');");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("});");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("},");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("         ");
    _builder.append("* Creates control instances based in the incomming name. This method is normally not");
    _builder.newLine();
    _builder.append("         ");
    _builder.append("* needed since the addButton method of the tinymce.Editor class is a more easy way of adding buttons");
    _builder.newLine();
    _builder.append("         ");
    _builder.append("* but you sometimes need to create more complex controls like listboxes, split buttons etc then this");
    _builder.newLine();
    _builder.append("         ");
    _builder.append("* method can be used to create those.");
    _builder.newLine();
    _builder.append("         ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("         ");
    _builder.append("* @param {String} n Name of the control to create.");
    _builder.newLine();
    _builder.append("         ");
    _builder.append("* @param {tinymce.ControlManager} cm Control manager to use inorder to create new control.");
    _builder.newLine();
    _builder.append("         ");
    _builder.append("* @return {tinymce.ui.Control} New control instance or null if no control was created.");
    _builder.newLine();
    _builder.append("         ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("createControl : function (n, cm) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("return null;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("},");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("         ");
    _builder.append("* Returns information about the plugin as a name/value array.");
    _builder.newLine();
    _builder.append("         ");
    _builder.append("* The current keys are longname, author, authorurl, infourl and version.");
    _builder.newLine();
    _builder.append("         ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("         ");
    _builder.append("* @return {Object} Name/value array containing information about the plugin.");
    _builder.newLine();
    _builder.append("         ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("getInfo : function () {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("return {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("longname : \'");
    String _appName_6 = this._utils.appName(it);
    _builder.append(_appName_6, "                ");
    _builder.append(" for tinymce\',");
    _builder.newLineIfNotEmpty();
    _builder.append("                ");
    _builder.append("author : \'");
    String _author = it.getAuthor();
    _builder.append(_author, "                ");
    _builder.append("\',");
    _builder.newLineIfNotEmpty();
    _builder.append("                ");
    _builder.append("authorurl : \'");
    String _url = it.getUrl();
    _builder.append(_url, "                ");
    _builder.append("\',");
    _builder.newLineIfNotEmpty();
    _builder.append("                ");
    _builder.append("infourl : \'");
    String _url_1 = it.getUrl();
    _builder.append(_url_1, "                ");
    _builder.append("\',");
    _builder.newLineIfNotEmpty();
    _builder.append("                ");
    _builder.append("version : \'");
    String _version = it.getVersion();
    _builder.append(_version, "                ");
    _builder.append("\'");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("};");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("});");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// Register plugin");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("tinymce.PluginManager.add(\'");
    String _name_5 = it.getName();
    String _formatForDB_5 = this._formattingExtensions.formatForDB(_name_5);
    _builder.append(_formatForDB_5, "    ");
    _builder.append("\', tinymce.plugins.");
    String _appName_7 = this._utils.appName(it);
    _builder.append(_appName_7, "    ");
    _builder.append("Plugin);");
    _builder.newLineIfNotEmpty();
    _builder.append("}());");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence tinyLangDe(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("tinyMCE.addI18n(\'de.");
    String _name = it.getName();
    String _formatForDB = this._formattingExtensions.formatForDB(_name);
    _builder.append(_formatForDB, "");
    _builder.append("\', {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("desc : \'");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "    ");
    _builder.append("-Objekt einf\u00FCgen\'");
    _builder.newLineIfNotEmpty();
    _builder.append("});");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence tinyLangEn(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("tinyMCE.addI18n(\'en.");
    String _name = it.getName();
    String _formatForDB = this._formattingExtensions.formatForDB(_name);
    _builder.append(_formatForDB, "");
    _builder.append("\', {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("desc : \'Insert ");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "    ");
    _builder.append(" object\'");
    _builder.newLineIfNotEmpty();
    _builder.append("});");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence tinyLangNl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("tinyMCE.addI18n(\'nl.");
    String _name = it.getName();
    String _formatForDB = this._formattingExtensions.formatForDB(_name);
    _builder.append(_formatForDB, "");
    _builder.append("\', {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("desc : \'");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "    ");
    _builder.append(" Object invoegen\'");
    _builder.newLineIfNotEmpty();
    _builder.append("});");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence xinhaPlugin(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("// ");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "");
    _builder.append(" plugin for Xinha");
    _builder.newLineIfNotEmpty();
    _builder.append("// developed by ");
    String _author = it.getAuthor();
    _builder.append(_author, "");
    _builder.newLineIfNotEmpty();
    _builder.append("//");
    _builder.newLine();
    _builder.append("// requires ");
    String _appName_1 = this._utils.appName(it);
    _builder.append(_appName_1, "");
    _builder.append(" module (");
    String _url = it.getUrl();
    _builder.append(_url, "");
    _builder.append(")");
    _builder.newLineIfNotEmpty();
    _builder.append("//");
    _builder.newLine();
    _builder.append("// Distributed under the same terms as xinha itself.");
    _builder.newLine();
    _builder.append("// This notice MUST stay intact for use (see license.txt).");
    _builder.newLine();
    _builder.newLine();
    _builder.append("\'use strict\';");
    _builder.newLine();
    _builder.newLine();
    _builder.append("function ");
    String _appName_2 = this._utils.appName(it);
    _builder.append(_appName_2, "");
    _builder.append("(editor) {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("var cfg, self;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("this.editor = editor;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("cfg = editor.config;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("self = this;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("cfg.registerButton({");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("id       : \'");
    String _appName_3 = this._utils.appName(it);
    _builder.append(_appName_3, "        ");
    _builder.append("\',");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("tooltip  : \'Insert ");
    String _appName_4 = this._utils.appName(it);
    _builder.append(_appName_4, "        ");
    _builder.append(" object\',");
    _builder.newLineIfNotEmpty();
    _builder.append("     ");
    _builder.append("// image    : _editor_url + \'plugins/");
    String _appName_5 = this._utils.appName(it);
    _builder.append(_appName_5, "     ");
    _builder.append("/img/ed_");
    String _appName_6 = this._utils.appName(it);
    _builder.append(_appName_6, "     ");
    _builder.append(".gif\',");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("image    : \'/images/icons/extrasmall/favorites.png\',");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("textMode : false,");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("action   : function (editor) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("var url = Zikula.Config.baseURL + \'index.php\'/*Zikula.Config.entrypoint*/ + \'?module=");
    String _appName_7 = this._utils.appName(it);
    _builder.append(_appName_7, "            ");
    _builder.append("&type=external&func=finder&editor=xinha\';");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    String _appName_8 = this._utils.appName(it);
    _builder.append(_appName_8, "            ");
    _builder.append("FinderXinha(editor, url);");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("});");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("cfg.addToolbarElement(\'");
    String _appName_9 = this._utils.appName(it);
    _builder.append(_appName_9, "    ");
    _builder.append("\', \'insertimage\', 1);");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    String _appName_10 = this._utils.appName(it);
    _builder.append(_appName_10, "");
    _builder.append("._pluginInfo = {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("name          : \'");
    String _appName_11 = this._utils.appName(it);
    _builder.append(_appName_11, "    ");
    _builder.append(" for xinha\',");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("version       : \'");
    String _version = it.getVersion();
    _builder.append(_version, "    ");
    _builder.append("\',");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("developer     : \'");
    String _author_1 = it.getAuthor();
    _builder.append(_author_1, "    ");
    _builder.append("\',");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("developer_url : \'");
    String _url_1 = it.getUrl();
    _builder.append(_url_1, "    ");
    _builder.append("\',");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("sponsor       : \'ModuleStudio ");
    String _msVersion = this._utils.msVersion();
    _builder.append(_msVersion, "    ");
    _builder.append("\',");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("sponsor_url   : \'");
    String _msUrl = this._utils.msUrl();
    _builder.append(_msUrl, "    ");
    _builder.append("\',");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("license       : \'htmlArea\'");
    _builder.newLine();
    _builder.append("};");
    _builder.newLine();
    return _builder;
  }
}