package org.zikula.modulestudio.generator.cartridges.zclassic.view.additions

import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.Entity
import de.guite.modulestudio.metamodel.modulestudio.StringField
import de.guite.modulestudio.metamodel.modulestudio.TextField
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.UrlExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ContentTypeListView {
    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension UrlExtensions = new UrlExtensions
    extension Utils = new Utils

    def generate(Application it, IFileSystemAccess fsa) {
        val templatePath = getViewPath + (if (targets('1.3.5')) 'contenttype' else 'ContentType') + '/'
        var fileName = ''
        for (entity : getAllEntities) {
            fileName = 'itemlist_' + entity.name.formatForCode + '_display_description.tpl'
            if (!shouldBeSkipped(templatePath + fileName)) {
                if (shouldBeMarked(templatePath + fileName)) {
                    fileName = 'itemlist_' + entity.name.formatForCode + '_display_description.generated.tpl'
                }
                fsa.generateFile(templatePath + fileName, entity.displayDescTemplate(it))
            }
            fileName = 'itemlist_' + entity.name.formatForCode + '_display.tpl'
            if (!shouldBeSkipped(templatePath + fileName)) {
                if (shouldBeMarked(templatePath + fileName)) {
                    fileName = 'itemlist_' + entity.name.formatForCode + '_display.generated.tpl'
                }
                fsa.generateFile(templatePath + fileName, entity.displayTemplate(it))
            }
        }
        fileName = 'itemlist_display.tpl'
        if (!shouldBeSkipped(templatePath + fileName)) {
            if (shouldBeMarked(templatePath + fileName)) {
                fileName = 'itemlist_display.generated.tpl'
            }
            fsa.generateFile(templatePath + fileName, fallbackDisplayTemplate)
        }
        fileName = 'itemlist_edit.tpl'
        if (!shouldBeSkipped(templatePath + fileName)) {
            if (shouldBeMarked(templatePath + fileName)) {
                fileName = 'itemlist_edit.generated.tpl'
            }
            fsa.generateFile(templatePath + fileName, editTemplate)
        }
    }

    def private displayDescTemplate(Entity it, Application app) '''
        {* Purpose of this template: Display nameMultiple.formatForDisplay within an external context *}
        <dl>
            {foreach item='name.formatForCode' from=$items}
                <dt>{$name.formatForCode->getTitleFromDisplayPattern()}</dt>
                val textFields = fields.filter(TextField)
                IF !textFields.empty
                    {if $name.formatForCode.textFields.head.name.formatForCode}
                        <dd>{$name.formatForCode.textFields.head.name.formatForCode|strip_tags|truncate:200:'&hellip;'}</dd>
                    {/if}
                ELSE
                    val stringFields = fields.filter(StringField).filter[!password]
                    IF !stringFields.empty
                        {if $name.formatForCode.stringFields.head.name.formatForCode}
                            <dd>{$name.formatForCode.stringFields.head.name.formatForCode|strip_tags|truncate:200:'&hellip;'}</dd>
                        {/if}
                    ENDIF
                ENDIF
                <dd>detailLink(app.appName)</dd>
            {foreachelse}
                <dt>{gt text='No entries found.'}</dt>
            {/foreach}
        </dl>
    '''

    def private displayTemplate(Entity it, Application app) '''
        {* Purpose of this template: Display nameMultiple.formatForDisplay within an external context *}
        {foreach item='name.formatForCode' from=$items}
            <h3>{$name.formatForCode->getTitleFromDisplayPattern()}</h3>
            IF app.hasUserController && app.getMainUserController.hasActions('display')
                <p>detailLink(app.appName)</p>
            ENDIF
        {/foreach}
    '''

    def private fallbackDisplayTemplate(Application it) '''
        {* Purpose of this template: Display objects within an external context *}
    '''

    def private editTemplate(Application it) '''
        {* Purpose of this template: edit view of generic item list content type *}
        editTemplateObjectType

        editTemplateCategories

        editTemplateSorting

        editTemplateAmount

        editTemplateTemplate

        editTemplateFilter

        editTemplateJs
    '''

    def private editTemplateObjectType(Application it) '''
        <div class="IF targets('1.3.5')z-formrowELSEform-groupENDIF">
            {gt text='Object type' domain='module_appName.formatForDB' assign='objectTypeSelectorLabel'}
            {formlabel for='appName.toFirstLowerObjectType' text=$objectTypeSelectorLabelIF !targets('1.3.5') cssClass='col-lg-3 control-label'ENDIF}
            IF !targets('1.3.5')
                <div class="col-lg-9">
            ENDIF
                {appName.formatForDBObjectTypeSelector assign='allObjectTypes'}
                {formdropdownlist id='appName.toFirstLowerOjectType' dataField='objectType' group='data' mandatory=true items=$allObjectTypesIF !targets('1.3.5') cssClass='form-control'ENDIF}
                <span class="IF targets('1.3.5')z-sub z-formnoteELSEhelp-blockENDIF">{gt text='If you change this please save the element once to reload the parameters below.' domain='module_appName.formatForDB'}</span>
            IF !targets('1.3.5')
                </div>
            ENDIF
        </div>
    '''

    def private editTemplateCategories(Application it) '''
        {formvolatile}
        {if $properties ne null && is_array($properties)}
            {nocache}
            {foreach key='registryId' item='registryCid' from=$registries}
                {assign var='propName' value=''}
                {foreach key='propertyName' item='propertyId' from=$properties}
                    {if $propertyId eq $registryId}
                        {assign var='propName' value=$propertyName}
                    {/if}
                {/foreach}
                <div class="IF targets('1.3.5')z-formrowELSEform-groupENDIF">
                    {modapifunc modname='appName' type='category' func='hasMultipleSelection' ot=$objectType registry=$propertyName assign='hasMultiSelection'}
                    {gt text='Category' domain='module_appName.formatForDB' assign='categorySelectorLabel'}
                    {assign var='selectionMode' value='single'}
                    {if $hasMultiSelection eq true}
                        {gt text='Categories' domain='module_appName.formatForDB' assign='categorySelectorLabel'}
                        {assign var='selectionMode' value='multiple'}
                    {/if}
                    {formlabel for="appName.toFirstLowerCatIds`$propertyName`" text=$categorySelectorLabelIF !targets('1.3.5') cssClass='col-lg-3 control-label'ENDIF}
                    IF !targets('1.3.5')
                        <div class="col-lg-9">
                    ENDIF
                        {formdropdownlist id="appName.toFirstLowerCatIds`$propName`" items=$categories.$propName dataField="catids`$propName`" group='data' selectionMode=$selectionModeIF !targets('1.3.5') cssClass='form-control'ENDIF}
                        <span class="IF targets('1.3.5')z-sub z-formnoteELSEhelp-blockENDIF">{gt text='This is an optional filter.' domain='module_appName.formatForDB'}</span>
                    IF !targets('1.3.5')
                        </div>
                    ENDIF
                </div>
            {/foreach}
            {/nocache}
        {/if}
        {/formvolatile}
    '''

    def private editTemplateSorting(Application it) '''
        <div class="IF targets('1.3.5')z-formrowELSEform-groupENDIF">
            {gt text='Sorting' domain='module_appName.formatForDB' assign='sortingLabel'}
            {formlabel text=$sortingLabelIF !targets('1.3.5') cssClass='col-lg-3 control-label'ENDIF}
            <divIF !targets('1.3.5') class="col-lg-9"ENDIF>
                {formradiobutton id='appName.toFirstLowerSortRandom' value='random' dataField='sorting' group='data' mandatory=true}
                {gt text='Random' domain='module_appName.formatForDB' assign='sortingRandomLabel'}
                {formlabel for='appName.toFirstLowerSortRandom' text=$sortingRandomLabel}
                {formradiobutton id='appName.toFirstLowerSortNewest' value='newest' dataField='sorting' group='data' mandatory=true}
                {gt text='Newest' domain='module_appName.formatForDB' assign='sortingNewestLabel'}
                {formlabel for='appName.toFirstLowerSortNewest' text=$sortingNewestLabel}
                {formradiobutton id='appName.toFirstLowerSortDefault' value='default' dataField='sorting' group='data' mandatory=true}
                {gt text='Default' domain='module_appName.formatForDB' assign='sortingDefaultLabel'}
                {formlabel for='appName.toFirstLowerSortDefault' text=$sortingDefaultLabel}
            </div>
        </div>
    '''

    def private editTemplateAmount(Application it) '''
        <div class="IF targets('1.3.5')z-formrowELSEform-groupENDIF">
            {gt text='Amount' domain='module_appName.formatForDB' assign='amountLabel'}
            {formlabel for='appName.toFirstLowerAmount' text=$amountLabelIF !targets('1.3.5') cssClass='col-lg-3 control-label'ENDIF}
            IF !targets('1.3.5')
                <div class="col-lg-9">
            ENDIF
                {formintinput id='appName.toFirstLowerAmount' dataField='amount' group='data' mandatory=true maxLength=2}
            IF !targets('1.3.5')
                </div>
            ENDIF
        </div>
    '''

    def private editTemplateTemplate(Application it) '''
        <div class="IF targets('1.3.5')z-formrowELSEform-groupENDIF">
            {gt text='Template' domain='module_appName.formatForDB' assign='templateLabel'}
            {formlabel for='appName.toFirstLowerTemplate' text=$templateLabelIF !targets('1.3.5') cssClass='col-lg-3 control-label'ENDIF}
            IF !targets('1.3.5')
                <div class="col-lg-9">
            ENDIF
                {appName.formatForDBTemplateSelector assign='allTemplates'}
                {formdropdownlist id='appName.toFirstLowerTemplate' dataField='template' group='data' mandatory=true items=$allTemplatesIF !targets('1.3.5') cssClass='form-control'ENDIF}
            IF !targets('1.3.5')
                </div>
            ENDIF
        </div>

        <div id="customTemplateArea" class="IF targets('1.3.5')z-formrow z-hideELSEform-group hiddenENDIF"IF !targets('1.3.5') data-switch="appName.toFirstLowerTemplate" data-switch-value="custom"ENDIF>
            {gt text='Custom template' domain='module_appName.formatForDB' assign='customTemplateLabel'}
            {formlabel for='appName.toFirstLowerCustomTemplate' text=$customTemplateLabelIF !targets('1.3.5') cssClass='col-lg-3 control-label'ENDIF}
            IF !targets('1.3.5')
                <div class="col-lg-9">
            ENDIF
                {formtextinput id='appName.toFirstLowerCustomTemplate' dataField='customTemplate' group='data' mandatory=false maxLength=80IF !targets('1.3.5') cssClass='form-control'ENDIF}
                <span class="IF targets('1.3.5')z-sub z-formnoteELSEhelp-blockENDIF">{gt text='Example' domain='module_appName.formatForDB'}: <em>itemlist_[objectType]_display.tpl</em></span>
            IF !targets('1.3.5')
                </div>
            ENDIF
        </div>
    '''

    def private editTemplateFilter(Application it) '''
        <div class="IF targets('1.3.5')z-formrow z-hideELSEform-groupENDIF">
            {gt text='Filter (expert option)' domain='module_appName.formatForDB' assign='filterLabel'}
            {formlabel for='appName.toFirstLowerFilter' text=$filterLabelIF !targets('1.3.5') cssClass='col-lg-3 control-label'ENDIF}
            IF !targets('1.3.5')
                <div class="col-lg-9">
            ENDIF
                {formtextinput id='appName.toFirstLowerFilter' dataField='filter' group='data' mandatory=false maxLength=255IF !targets('1.3.5') cssClass='form-control'ENDIF}
                IF targets('1.3.5')
                    <span class="z-sub z-formnote">
                        ({gt text='Syntax examples'}: <kbd>name:like:foobar</kbd> {gt text='or'} <kbd>status:ne:3</kbd>)
                    </span>
                ELSE
                    <span class="help-block">
                        <a class="fa fa-filter" data-toggle="modal" data-target="#filterSyntaxModal">{gt text='Show syntax examples'}</a>
                    </span>
                ENDIF
            IF !targets('1.3.5')
                </div>
            ENDIF
        </div>
        IF !targets('1.3.5')

            {include file='include_filterSyntaxDialog.tpl'}
        ENDIF
    '''

    def private editTemplateJs(Application it) '''
        IF targets('1.3.5')
            {pageaddvar name='javascript' value='prototype'}
        ELSE
            {pageaddvar name='stylesheet' value='web/bootstrap/css/bootstrap.min.css'}
            {pageaddvar name='stylesheet' value='web/bootstrap/css/bootstrap-theme.min.css'}
            {pageaddvar name='javascript' value='jquery'}
            {pageaddvar name='javascript' value='web/bootstrap/js/bootstrap.min.js'}
        ENDIF
        IF targets('1.3.5')
            <script type="text/javascript">
            /* <![CDATA[ */
                function prefix()ToggleCustomTemplate() {
                    if ($F('appName.toFirstLowerTemplate') == 'custom') {
                        $('customTemplateArea').removeClassName('IF targets('1.3.5')z-hideELSEhiddenENDIF');
                    } else {
                        $('customTemplateArea').addClassName('IF targets('1.3.5')z-hideELSEhiddenENDIF');
                    }
                }

                document.observe('dom:loaded', function() {
                    prefix()ToggleCustomTemplate();
                    $('appName.toFirstLowerTemplate').observe('change', function(e) {
                        prefix()ToggleCustomTemplate();
                    });
                });
            /* ]]> */
            </script>
        ENDIF
    '''

    def private detailLink(Entity it, String appName) '''
        IF container.application.targets('1.3.5')
            <a href="{modurl modname='appName' type='user' ot='name.formatForCode' func='display' routeParamsLegacy('$objectType', true, true)}">{gt text='Read more'}</a>
        ELSE
            <a href="{route name='appName.formatForDB_name.formatForCode_display' routeParams('$objectType', true)}">{gt text='Read more'}</a>
        ENDIF
    '''
}
