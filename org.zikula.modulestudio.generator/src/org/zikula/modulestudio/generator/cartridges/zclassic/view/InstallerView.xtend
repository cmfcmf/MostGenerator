package org.zikula.modulestudio.generator.cartridges.zclassic.view

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import de.guite.modulestudio.metamodel.modulestudio.Variable

class InstallerView {
    @Inject extension ControllerExtensions = new ControllerExtensions()
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension ModelExtensions = new ModelExtensions()
    @Inject extension ModelBehaviourExtensions = new ModelBehaviourExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension Utils = new Utils()

    def generate(Application it, IFileSystemAccess fsa) {
        val templatePath = appName.getAppSourcePath + 'templates/init/'
        fsa.generateFile(templatePath + 'interactive.tpl', tplInit)
        if (needsConfig)
            fsa.generateFile(templatePath + 'step2.tpl', tplInitStep2)
        fsa.generateFile(templatePath + 'step3.tpl', tplInitStep3)
        fsa.generateFile(templatePath + 'update.tpl', tplUpdate)
        fsa.generateFile(templatePath + 'delete.tpl', tplDelete)
    }

    def private tplInit(Application it) '''
        {* Purpose of this template: 1st step of init process: welcome and information *}

        <h2>{gt text='Installation of «appName»'}</h2>
        <p>{gt text='Welcome to the installation of «appName»'}</p>
        <p>{gt text='Generated by <a href="«msUrl»" title="«msUrl»">ModuleStudio «msVersion».'}</p>
        <p>{gt text='Many features are contained in «appName» as for example:'}</p>
        <dl id="«name.formatForDB»featurelist">
            <dt>{gt text='«getLeadingEntity.name.formatForDisplayCapital» management.'}</dt>
            <dd>{gt text='Easy management of «getLeadingEntity.nameMultiple.formatForDisplay»«IF getAllEntities.size > 1» and «IF models.map(e|e.relations).size > 1»related«ELSE»other«ENDIF» artifacts«ENDIF».'}</dd>
        «IF hasAttributableEntities || hasCategorisableEntities || !hasGeographical
         || hasLoggable || hasMetaDataEntities || hasSortable || hasStandardFieldEntities || hasTranslatable || hasTrees»
            <dt>{gt text='Behaviours and extensions'}</dt>
        «IF hasAttributableEntities»
            <dd>{gt text='Automatic handling of generic attributes.'}</dd>
        «ENDIF»
        «IF hasCategorisableEntities»
            <dd>{gt text='Automatic handling of related categories.'}</dd>
        «ENDIF»
        «IF hasGeographical»
            <dd>{gt text='Coordinates handling including html5 geolocation support.'}</dd>
        «ENDIF»
        «IF hasLoggable»
            <dd>{gt text='Entity changes can be logged automatically by creating corresponding version log entries.'}</dd>
        «ENDIF»
        «IF hasMetaDataEntities»
            <dd>{gt text='Automatic handling of attached meta data.'}</dd>
        «ENDIF»
        «IF hasStandardFieldEntities»
            <dd>{gt text='Automatic handling of standard fields, that are user id and date for creation and last update.'}</dd>
        «ENDIF»
        «IF hasTranslatable»
            <dd>{gt text='Translation management for data fields.'}</dd>
        «ENDIF»
        «IF hasTrees»
            <dd>{gt text='Tree structures can be managed in a hierarchy view with the help of ajax.'}</dd>
        «ENDIF»
        «ENDIF»
        «IF !getAllControllers.filter(e|e.hasActions('view') || e.hasActions('display')).isEmpty»
            <dt>{gt text='Output formats'}</dt>
            <dd>{gt text='Beside the normal templates «appName» includes also templates for various other output formats, like for example xml (which is only accessible for administrators per default)«IF !getAllControllers.filter(e|e.hasActions('view')).isEmpty», rss, atom«ENDIF»«IF !getAllControllers.filter(e|e.hasActions('display')).isEmpty», csv«ENDIF».'}</dd>
        «ENDIF»
            <dt>{gt text='Integration'}</dt>
            <dd>{gt text='«appName» offers a generic block allowing you to display arbitrary content elements in a block.'}</dd>
            <dd>{gt text='It is possible to integrate «appName» with Content. There is a corresponding content type available.'}</dd>
            <dd>{gt text='There is also a mailz plugin for getting «appName» content into mailings and newsletters.'}</dd>
            <dd>{gt text='All these artifacts reuse the same templates for easier customisation. They can be extended by overriding and the addition of other template sets.'}</dd>
            <dt>{gt text='State-of-the-art technology'}</dt>
            <dd>{gt text='All parts of «appName» are always up to the latest version of the Zikula core.'}</dd>
            <dd>{gt text='Entities, controllers, hooks, templates, plugins and more.'}</dd>
        </dl>
        <p>
            <a href="{modurl modname='«appName»' type='init' func='interactiveinitstep«IF needsConfig»2«ELSE»3«ENDIF»'}" title="{gt text='Continue'}">
                {gt text='Continue'}
            </a>
        </p>
    '''

    def private tplInitStep2(Application it) '''
        {* Purpose of this template: 2nd step of init process: initial settings *}

        <h2>{gt text='Installation of «appName»'}</h2>
        <form action="{modurl modname='«appName»' type='init' func='interactiveinitstep2'}" method="post" enctype="application/x-www-form-urlencoded">
            <fieldset>
                <legend>{gt text='Settings'}</legend>
                <input type="hidden" name="csrftoken" value="{insert name='csrftoken'}" />

                «FOR modvar : getAllVariables»«modvar.tplInitStep2Var(it)»«ENDFOR»
            </fieldset>
            <fieldset>
                <legend>{gt text='Action'}</legend>

                <label for="«appName»_activate">{gt text='Activate «appName» after installation?'}</label>
                <input id="«appName»_activate" name="activate" type="checkbox" value="1" checked="checked" />
                <br /><br />

                <input name="submit" type="submit" value="{gt text='Submit'}" style="margin-left: 17em" />
            </fieldset>
        </form>
    '''

    def private tplInitStep2Var(Variable it, Application app) '''
        <label for="«formatForCode(app.name + '_' + name)»" style="float: left; width: 20em">{gt text='«name»'}</label>
        <input id="«formatForCode(app.name + '_' + name)»" type="text" name="«name.formatForCode»" value="«value»" size="40" />
        <br style="clear: left" /><br />
    '''

    def private tplInitStep3(Application it) '''
        {* Purpose of this template: 3rd step of init process: thanks *}

        <h2>{gt text='Installation of «appName»'}</h2>
        <p>{gt text='Last installation step'}</p>
        <p>{gt text='Thank you for installing «appName».<br />Click on the bottom link to finish the installation.' html='1'}</p>
        <p>
            {insert name='csrftoken' assign='csrftoken'}
            <a href="{modurl modname='Extensions' type='admin' func='initialise' csrftoken=$csrftoken activate=$activate}" title="{gt text='Continue'}">
                {gt text='Continue'}
            </a>
        </p>
    '''

    def private tplUpdate(Application it) '''

    '''

    def private tplDelete(Application it) '''
        {* Purpose of this template: delete process *}

        <h2>{gt text='Uninstall of «appName»'}</h2>
        <p>{gt text='Thank you for using «appName».<br />This application is going to be removed now!' html='1'}</p>
        <p>
            {insert name='csrftoken' assign='csrftoken'}
            <a href="{modurl modname='Extensions' type='admin' func='remove' csrftoken=$csrftoken}" title="{gt text='Uninstall «appName»'}">
                {gt text='Uninstall «appName»'}
            </a>
        </p>
        <p>
            <a href="{modurl modname='Extensions' type='admin' func='view'}" title="{gt text='Cancel uninstallation'}">
                {gt text='Cancel'}
            </a>
        </p>
    '''
}