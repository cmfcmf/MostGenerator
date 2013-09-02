package org.zikula.modulestudio.generator.cartridges.zclassic.controller.installer;

import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class EventListener {
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
  private Utils _utils = new Function0<Utils>() {
    public Utils apply() {
      Utils _utils = new Utils();
      return _utils;
    }
  }.apply();
  
  /**
   * Entry point for event listeners registered by the installer.
   */
  public CharSequence generate(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Register persistent event handlers.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* These are listeners for external events of the core and other modules.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function registerPersistentEventHandlers()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    String _xifexpression = null;
    boolean _targets = this._utils.targets(it, "1.3.5");
    if (_targets) {
      String _appName = this._utils.appName(it);
      String _plus = (_appName + "_Listener_");
      _xifexpression = _plus;
    } else {
      String _vendor = it.getVendor();
      String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_vendor);
      String _plus_1 = (_formatForCodeCapital + "\\");
      String _name = it.getName();
      String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(_name);
      String _plus_2 = (_plus_1 + _formatForCodeCapital_1);
      String _plus_3 = (_plus_2 + "Module\\Listener\\");
      _xifexpression = _plus_3;
    }
    final String listenerBase = _xifexpression;
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    String _xifexpression_1 = null;
    boolean _targets_1 = this._utils.targets(it, "1.3.5");
    if (_targets_1) {
      _xifexpression_1 = "";
    } else {
      _xifexpression_1 = "Listener";
    }
    final String listenerSuffix = _xifexpression_1;
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("// core -> ");
    String _plus_4 = (listenerBase + "Core");
    String callableClass = (_plus_4 + listenerSuffix);
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("EventUtil::registerPersistentModuleHandler(\'");
    String _appName_1 = this._utils.appName(it);
    _builder.append(_appName_1, "    ");
    _builder.append("\', \'api.method_not_found\', array(\'");
    _builder.append(callableClass, "    ");
    _builder.append("\', \'apiMethodNotFound\'));");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("EventUtil::registerPersistentModuleHandler(\'");
    String _appName_2 = this._utils.appName(it);
    _builder.append(_appName_2, "    ");
    _builder.append("\', \'core.preinit\', array(\'");
    _builder.append(callableClass, "    ");
    _builder.append("\', \'preInit\'));");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("EventUtil::registerPersistentModuleHandler(\'");
    String _appName_3 = this._utils.appName(it);
    _builder.append(_appName_3, "    ");
    _builder.append("\', \'core.init\', array(\'");
    _builder.append(callableClass, "    ");
    _builder.append("\', \'init\'));");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("EventUtil::registerPersistentModuleHandler(\'");
    String _appName_4 = this._utils.appName(it);
    _builder.append(_appName_4, "    ");
    _builder.append("\', \'core.postinit\', array(\'");
    _builder.append(callableClass, "    ");
    _builder.append("\', \'postInit\'));");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("EventUtil::registerPersistentModuleHandler(\'");
    String _appName_5 = this._utils.appName(it);
    _builder.append(_appName_5, "    ");
    _builder.append("\', \'controller.method_not_found\', array(\'");
    _builder.append(callableClass, "    ");
    _builder.append("\', \'controllerMethodNotFound\'));");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// front controller -> ");
    String _plus_5 = (listenerBase + "FrontController");
    String _plus_6 = (_plus_5 + listenerSuffix);
    String _callableClass = callableClass = _plus_6;
    _builder.append(_callableClass, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("EventUtil::registerPersistentModuleHandler(\'");
    String _appName_6 = this._utils.appName(it);
    _builder.append(_appName_6, "    ");
    _builder.append("\', \'frontcontroller.predispatch\', array(\'");
    _builder.append(callableClass, "    ");
    _builder.append("\', \'preDispatch\'));");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// installer -> ");
    String _plus_7 = (listenerBase + "Installer");
    String _plus_8 = (_plus_7 + listenerSuffix);
    String _callableClass_1 = callableClass = _plus_8;
    _builder.append(_callableClass_1, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("EventUtil::registerPersistentModuleHandler(\'");
    String _appName_7 = this._utils.appName(it);
    _builder.append(_appName_7, "    ");
    _builder.append("\', \'installer.module.installed\', array(\'");
    _builder.append(callableClass, "    ");
    _builder.append("\', \'moduleInstalled\'));");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("EventUtil::registerPersistentModuleHandler(\'");
    String _appName_8 = this._utils.appName(it);
    _builder.append(_appName_8, "    ");
    _builder.append("\', \'installer.module.upgraded\', array(\'");
    _builder.append(callableClass, "    ");
    _builder.append("\', \'moduleUpgraded\'));");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("EventUtil::registerPersistentModuleHandler(\'");
    String _appName_9 = this._utils.appName(it);
    _builder.append(_appName_9, "    ");
    _builder.append("\', \'installer.module.uninstalled\', array(\'");
    _builder.append(callableClass, "    ");
    _builder.append("\', \'moduleUninstalled\'));");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets_2 = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets_2);
      if (_not) {
        _builder.append("    ");
        _builder.append("EventUtil::registerPersistentModuleHandler(\'");
        String _appName_10 = this._utils.appName(it);
        _builder.append(_appName_10, "    ");
        _builder.append("\', \'installer.module.activated\', array(\'");
        _builder.append(callableClass, "    ");
        _builder.append("\', \'moduleActivated\'));");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("EventUtil::registerPersistentModuleHandler(\'");
        String _appName_11 = this._utils.appName(it);
        _builder.append(_appName_11, "    ");
        _builder.append("\', \'installer.module.deactivated\', array(\'");
        _builder.append(callableClass, "    ");
        _builder.append("\', \'moduleDeactivated\'));");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("    ");
    _builder.append("EventUtil::registerPersistentModuleHandler(\'");
    String _appName_12 = this._utils.appName(it);
    _builder.append(_appName_12, "    ");
    _builder.append("\', \'installer.subscriberarea.uninstalled\', array(\'");
    _builder.append(callableClass, "    ");
    _builder.append("\', \'subscriberAreaUninstalled\'));");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// modules -> ");
    String _plus_9 = (listenerBase + "ModuleDispatch");
    String _plus_10 = (_plus_9 + listenerSuffix);
    String _callableClass_2 = callableClass = _plus_10;
    _builder.append(_callableClass_2, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("EventUtil::registerPersistentModuleHandler(\'");
    String _appName_13 = this._utils.appName(it);
    _builder.append(_appName_13, "    ");
    _builder.append("\', \'module_dispatch.postloadgeneric\', array(\'");
    _builder.append(callableClass, "    ");
    _builder.append("\', \'postLoadGeneric\'));");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("EventUtil::registerPersistentModuleHandler(\'");
    String _appName_14 = this._utils.appName(it);
    _builder.append(_appName_14, "    ");
    _builder.append("\', \'module_dispatch.preexecute\', array(\'");
    _builder.append(callableClass, "    ");
    _builder.append("\', \'preExecute\'));");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("EventUtil::registerPersistentModuleHandler(\'");
    String _appName_15 = this._utils.appName(it);
    _builder.append(_appName_15, "    ");
    _builder.append("\', \'module_dispatch.postexecute\', array(\'");
    _builder.append(callableClass, "    ");
    _builder.append("\', \'postExecute\'));");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("EventUtil::registerPersistentModuleHandler(\'");
    String _appName_16 = this._utils.appName(it);
    _builder.append(_appName_16, "    ");
    _builder.append("\', \'module_dispatch.custom_classname\', array(\'");
    _builder.append(callableClass, "    ");
    _builder.append("\', \'customClassname\'));");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("EventUtil::registerPersistentModuleHandler(\'");
    String _appName_17 = this._utils.appName(it);
    _builder.append(_appName_17, "    ");
    _builder.append("\', \'module_dispatch.service_links\', array(\'");
    _builder.append(callableClass, "    ");
    _builder.append("\', \'serviceLinks\'));");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// mailer -> ");
    String _plus_11 = (listenerBase + "Mailer");
    String _plus_12 = (_plus_11 + listenerSuffix);
    String _callableClass_3 = callableClass = _plus_12;
    _builder.append(_callableClass_3, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("EventUtil::registerPersistentModuleHandler(\'");
    String _appName_18 = this._utils.appName(it);
    _builder.append(_appName_18, "    ");
    _builder.append("\', \'module.mailer.api.sendmessage\', array(\'");
    _builder.append(callableClass, "    ");
    _builder.append("\', \'sendMessage\'));");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// page -> ");
    String _plus_13 = (listenerBase + "Page");
    String _plus_14 = (_plus_13 + listenerSuffix);
    String _callableClass_4 = callableClass = _plus_14;
    _builder.append(_callableClass_4, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("EventUtil::registerPersistentModuleHandler(\'");
    String _appName_19 = this._utils.appName(it);
    _builder.append(_appName_19, "    ");
    _builder.append("\', \'pageutil.addvar_filter\', array(\'");
    _builder.append(callableClass, "    ");
    _builder.append("\', \'pageutilAddvarFilter\'));");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("EventUtil::registerPersistentModuleHandler(\'");
    String _appName_20 = this._utils.appName(it);
    _builder.append(_appName_20, "    ");
    _builder.append("\', \'system.outputfilter\', array(\'");
    _builder.append(callableClass, "    ");
    _builder.append("\', \'systemOutputfilter\'));");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// errors -> ");
    String _plus_15 = (listenerBase + "Errors");
    String _plus_16 = (_plus_15 + listenerSuffix);
    String _callableClass_5 = callableClass = _plus_16;
    _builder.append(_callableClass_5, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("EventUtil::registerPersistentModuleHandler(\'");
    String _appName_21 = this._utils.appName(it);
    _builder.append(_appName_21, "    ");
    _builder.append("\', \'setup.errorreporting\', array(\'");
    _builder.append(callableClass, "    ");
    _builder.append("\', \'setupErrorReporting\'));");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("EventUtil::registerPersistentModuleHandler(\'");
    String _appName_22 = this._utils.appName(it);
    _builder.append(_appName_22, "    ");
    _builder.append("\', \'systemerror\', array(\'");
    _builder.append(callableClass, "    ");
    _builder.append("\', \'systemError\'));");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// theme -> ");
    String _plus_17 = (listenerBase + "Theme");
    String _plus_18 = (_plus_17 + listenerSuffix);
    String _callableClass_6 = callableClass = _plus_18;
    _builder.append(_callableClass_6, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("EventUtil::registerPersistentModuleHandler(\'");
    String _appName_23 = this._utils.appName(it);
    _builder.append(_appName_23, "    ");
    _builder.append("\', \'theme.preinit\', array(\'");
    _builder.append(callableClass, "    ");
    _builder.append("\', \'preInit\'));");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("EventUtil::registerPersistentModuleHandler(\'");
    String _appName_24 = this._utils.appName(it);
    _builder.append(_appName_24, "    ");
    _builder.append("\', \'theme.init\', array(\'");
    _builder.append(callableClass, "    ");
    _builder.append("\', \'init\'));");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("EventUtil::registerPersistentModuleHandler(\'");
    String _appName_25 = this._utils.appName(it);
    _builder.append(_appName_25, "    ");
    _builder.append("\', \'theme.load_config\', array(\'");
    _builder.append(callableClass, "    ");
    _builder.append("\', \'loadConfig\'));");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("EventUtil::registerPersistentModuleHandler(\'");
    String _appName_26 = this._utils.appName(it);
    _builder.append(_appName_26, "    ");
    _builder.append("\', \'theme.prefetch\', array(\'");
    _builder.append(callableClass, "    ");
    _builder.append("\', \'preFetch\'));");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("EventUtil::registerPersistentModuleHandler(\'");
    String _appName_27 = this._utils.appName(it);
    _builder.append(_appName_27, "    ");
    _builder.append("\', \'theme.postfetch\', array(\'");
    _builder.append(callableClass, "    ");
    _builder.append("\', \'postFetch\'));");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// view -> ");
    String _plus_19 = (listenerBase + "View");
    String _plus_20 = (_plus_19 + listenerSuffix);
    String _callableClass_7 = callableClass = _plus_20;
    _builder.append(_callableClass_7, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("EventUtil::registerPersistentModuleHandler(\'");
    String _appName_28 = this._utils.appName(it);
    _builder.append(_appName_28, "    ");
    _builder.append("\', \'view.init\', array(\'");
    _builder.append(callableClass, "    ");
    _builder.append("\', \'init\'));");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("EventUtil::registerPersistentModuleHandler(\'");
    String _appName_29 = this._utils.appName(it);
    _builder.append(_appName_29, "    ");
    _builder.append("\', \'view.postfetch\', array(\'");
    _builder.append(callableClass, "    ");
    _builder.append("\', \'postFetch\'));");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// user login -> ");
    String _plus_21 = (listenerBase + "UserLogin");
    String _plus_22 = (_plus_21 + listenerSuffix);
    String _callableClass_8 = callableClass = _plus_22;
    _builder.append(_callableClass_8, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("EventUtil::registerPersistentModuleHandler(\'");
    String _appName_30 = this._utils.appName(it);
    _builder.append(_appName_30, "    ");
    _builder.append("\', \'module.users.ui.login.started\', array(\'");
    _builder.append(callableClass, "    ");
    _builder.append("\', \'started\'));");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("EventUtil::registerPersistentModuleHandler(\'");
    String _appName_31 = this._utils.appName(it);
    _builder.append(_appName_31, "    ");
    _builder.append("\', \'module.users.ui.login.veto\', array(\'");
    _builder.append(callableClass, "    ");
    _builder.append("\', \'veto\'));");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("EventUtil::registerPersistentModuleHandler(\'");
    String _appName_32 = this._utils.appName(it);
    _builder.append(_appName_32, "    ");
    _builder.append("\', \'module.users.ui.login.succeeded\', array(\'");
    _builder.append(callableClass, "    ");
    _builder.append("\', \'succeeded\'));");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("EventUtil::registerPersistentModuleHandler(\'");
    String _appName_33 = this._utils.appName(it);
    _builder.append(_appName_33, "    ");
    _builder.append("\', \'module.users.ui.login.failed\', array(\'");
    _builder.append(callableClass, "    ");
    _builder.append("\', \'failed\'));");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// user logout -> ");
    String _plus_23 = (listenerBase + "UserLogout");
    String _plus_24 = (_plus_23 + listenerSuffix);
    String _callableClass_9 = callableClass = _plus_24;
    _builder.append(_callableClass_9, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("EventUtil::registerPersistentModuleHandler(\'");
    String _appName_34 = this._utils.appName(it);
    _builder.append(_appName_34, "    ");
    _builder.append("\', \'module.users.ui.logout.succeeded\', array(\'");
    _builder.append(callableClass, "    ");
    _builder.append("\', \'succeeded\'));");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// user -> ");
    String _plus_25 = (listenerBase + "User");
    String _plus_26 = (_plus_25 + listenerSuffix);
    String _callableClass_10 = callableClass = _plus_26;
    _builder.append(_callableClass_10, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("EventUtil::registerPersistentModuleHandler(\'");
    String _appName_35 = this._utils.appName(it);
    _builder.append(_appName_35, "    ");
    _builder.append("\', \'user.gettheme\', array(\'");
    _builder.append(callableClass, "    ");
    _builder.append("\', \'getTheme\'));");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("EventUtil::registerPersistentModuleHandler(\'");
    String _appName_36 = this._utils.appName(it);
    _builder.append(_appName_36, "    ");
    _builder.append("\', \'user.account.create\', array(\'");
    _builder.append(callableClass, "    ");
    _builder.append("\', \'create\'));");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("EventUtil::registerPersistentModuleHandler(\'");
    String _appName_37 = this._utils.appName(it);
    _builder.append(_appName_37, "    ");
    _builder.append("\', \'user.account.update\', array(\'");
    _builder.append(callableClass, "    ");
    _builder.append("\', \'update\'));");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("EventUtil::registerPersistentModuleHandler(\'");
    String _appName_38 = this._utils.appName(it);
    _builder.append(_appName_38, "    ");
    _builder.append("\', \'user.account.delete\', array(\'");
    _builder.append(callableClass, "    ");
    _builder.append("\', \'delete\'));");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// registration -> ");
    String _plus_27 = (listenerBase + "UserRegistration");
    String _plus_28 = (_plus_27 + listenerSuffix);
    String _callableClass_11 = callableClass = _plus_28;
    _builder.append(_callableClass_11, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("EventUtil::registerPersistentModuleHandler(\'");
    String _appName_39 = this._utils.appName(it);
    _builder.append(_appName_39, "    ");
    _builder.append("\', \'module.users.ui.registration.started\', array(\'");
    _builder.append(callableClass, "    ");
    _builder.append("\', \'started\'));");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("EventUtil::registerPersistentModuleHandler(\'");
    String _appName_40 = this._utils.appName(it);
    _builder.append(_appName_40, "    ");
    _builder.append("\', \'module.users.ui.registration.succeeded\', array(\'");
    _builder.append(callableClass, "    ");
    _builder.append("\', \'succeeded\'));");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("EventUtil::registerPersistentModuleHandler(\'");
    String _appName_41 = this._utils.appName(it);
    _builder.append(_appName_41, "    ");
    _builder.append("\', \'module.users.ui.registration.failed\', array(\'");
    _builder.append(callableClass, "    ");
    _builder.append("\', \'failed\'));");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("EventUtil::registerPersistentModuleHandler(\'");
    String _appName_42 = this._utils.appName(it);
    _builder.append(_appName_42, "    ");
    _builder.append("\', \'user.registration.create\', array(\'");
    _builder.append(callableClass, "    ");
    _builder.append("\', \'create\'));");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("EventUtil::registerPersistentModuleHandler(\'");
    String _appName_43 = this._utils.appName(it);
    _builder.append(_appName_43, "    ");
    _builder.append("\', \'user.registration.update\', array(\'");
    _builder.append(callableClass, "    ");
    _builder.append("\', \'update\'));");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("EventUtil::registerPersistentModuleHandler(\'");
    String _appName_44 = this._utils.appName(it);
    _builder.append(_appName_44, "    ");
    _builder.append("\', \'user.registration.delete\', array(\'");
    _builder.append(callableClass, "    ");
    _builder.append("\', \'delete\'));");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// users module -> ");
    String _plus_29 = (listenerBase + "Users");
    String _plus_30 = (_plus_29 + listenerSuffix);
    String _callableClass_12 = callableClass = _plus_30;
    _builder.append(_callableClass_12, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("EventUtil::registerPersistentModuleHandler(\'");
    String _appName_45 = this._utils.appName(it);
    _builder.append(_appName_45, "    ");
    _builder.append("\', \'module.users.config.updated\', array(\'");
    _builder.append(callableClass, "    ");
    _builder.append("\', \'configUpdated\'));");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// group -> ");
    String _plus_31 = (listenerBase + "Group");
    String _plus_32 = (_plus_31 + listenerSuffix);
    String _callableClass_13 = callableClass = _plus_32;
    _builder.append(_callableClass_13, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("EventUtil::registerPersistentModuleHandler(\'");
    String _appName_46 = this._utils.appName(it);
    _builder.append(_appName_46, "    ");
    _builder.append("\', \'group.create\', array(\'");
    _builder.append(callableClass, "    ");
    _builder.append("\', \'create\'));");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("EventUtil::registerPersistentModuleHandler(\'");
    String _appName_47 = this._utils.appName(it);
    _builder.append(_appName_47, "    ");
    _builder.append("\', \'group.update\', array(\'");
    _builder.append(callableClass, "    ");
    _builder.append("\', \'update\'));");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("EventUtil::registerPersistentModuleHandler(\'");
    String _appName_48 = this._utils.appName(it);
    _builder.append(_appName_48, "    ");
    _builder.append("\', \'group.delete\', array(\'");
    _builder.append(callableClass, "    ");
    _builder.append("\', \'delete\'));");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("EventUtil::registerPersistentModuleHandler(\'");
    String _appName_49 = this._utils.appName(it);
    _builder.append(_appName_49, "    ");
    _builder.append("\', \'group.adduser\', array(\'");
    _builder.append(callableClass, "    ");
    _builder.append("\', \'addUser\'));");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("EventUtil::registerPersistentModuleHandler(\'");
    String _appName_50 = this._utils.appName(it);
    _builder.append(_appName_50, "    ");
    _builder.append("\', \'group.removeuser\', array(\'");
    _builder.append(callableClass, "    ");
    _builder.append("\', \'removeUser\'));");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// special purposes and 3rd party api support -> ");
    String _plus_33 = (listenerBase + "ThirdParty");
    String _plus_34 = (_plus_33 + listenerSuffix);
    String _callableClass_14 = callableClass = _plus_34;
    _builder.append(_callableClass_14, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("EventUtil::registerPersistentModuleHandler(\'");
    String _appName_51 = this._utils.appName(it);
    _builder.append(_appName_51, "    ");
    _builder.append("\', \'get.pending_content\', array(\'");
    _builder.append(callableClass, "    ");
    _builder.append("\', \'pendingContentListener\'));");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("EventUtil::registerPersistentModuleHandler(\'");
    String _appName_52 = this._utils.appName(it);
    _builder.append(_appName_52, "    ");
    _builder.append("\', \'module.content.gettypes\', array(\'");
    _builder.append(callableClass, "    ");
    _builder.append("\', \'contentGetTypes\'));");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets_3 = this._utils.targets(it, "1.3.5");
      boolean _not_1 = (!_targets_3);
      if (_not_1) {
        _builder.append("    ");
        _builder.append("EventUtil::registerPersistentModuleHandler(\'");
        String _appName_53 = this._utils.appName(it);
        _builder.append(_appName_53, "    ");
        _builder.append("\', \'module.scribite.editorhelpers\', array(\'");
        _builder.append(callableClass, "    ");
        _builder.append("\', \'getEditorHelpers\'));");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("EventUtil::registerPersistentModuleHandler(\'");
        String _appName_54 = this._utils.appName(it);
        _builder.append(_appName_54, "    ");
        _builder.append("\', \'moduleplugin.tinymce.externalplugins\', array(\'");
        _builder.append(callableClass, "    ");
        _builder.append("\', \'getTinyMcePlugins\'));");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("EventUtil::registerPersistentModuleHandler(\'");
        String _appName_55 = this._utils.appName(it);
        _builder.append(_appName_55, "    ");
        _builder.append("\', \'moduleplugin.ckeditor.externalplugins\', array(\'");
        _builder.append(callableClass, "    ");
        _builder.append("\', \'getCKEditorPlugins\'));");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
