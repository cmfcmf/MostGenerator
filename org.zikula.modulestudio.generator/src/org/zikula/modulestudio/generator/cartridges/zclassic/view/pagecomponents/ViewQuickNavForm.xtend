package org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents

import de.guite.modulestudio.metamodel.modulestudio.BooleanField
import de.guite.modulestudio.metamodel.modulestudio.DerivedField
import de.guite.modulestudio.metamodel.modulestudio.Entity
import de.guite.modulestudio.metamodel.modulestudio.JoinRelationship
import de.guite.modulestudio.metamodel.modulestudio.ListField
import de.guite.modulestudio.metamodel.modulestudio.StringField
import de.guite.modulestudio.metamodel.modulestudio.UserField
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ViewQuickNavForm {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate(Entity it, String appName, IFileSystemAccess fsa) {
        val templatePath = templateFile('view_quickNav')
        if (!container.application.shouldBeSkipped(templatePath)) {
            println('Generating view filter form templates for entity "' + name.formatForDisplay + '"')
            fsa.generateFile(templatePath, quickNavForm)
        }
    }

    def private quickNavForm(Entity it) '''
        val app = container.application
        val objName = name.formatForCode
        {* purpose of this template: nameMultiple.formatForDisplay view filter form *}
        {checkpermissionblock component='app.appName:name.formatForCodeCapital:' instance='::' level='ACCESS_EDIT'}
        {assign var='objectType' value='name.formatForCode'}
        <form action="{$modvars.ZConfig.entrypoint|default:'index.php'}" method="get" id="app.appName.toFirstLowername.formatForCodeCapitalQuickNavForm" class="app.appName.toLowerCase-quicknavIF container.application.targets('1.3.5')"ELSE {*form-inline*}navbar-form" role="navigation"ENDIF>
            <fieldset>
                <h3>{gt text='Quick navigation'}</h3>
                <input type="hidden" name="module" value="{modgetinfo modname='app.appName' info='url'}" />
                <input type="hidden" name="type" value="IF app.targets('1.3.5'){$lct}ELSEobjNameENDIF" />
                IF app.targets('1.3.5')
                    <input type="hidden" name="ot" value="objName" />
                ENDIF
                <input type="hidden" name="func" value="view" />
                <input type="hidden" name="all" value="{$all|default:0}" />
                <input type="hidden" name="own" value="{$own|default:0}" />
                {gt text='All' assign='lblDefault'}
                formFields
                <input type="submit" name="updateview" id="quicknavSubmit" value="{gt text='OK'}"IF !app.targets('1.3.5') class="btn btn-default"ENDIF />
            </fieldset>
        </form>

        <script type="text/javascript">
        /* <![CDATA[ */
            IF app.targets('1.3.5')
                document.observe('dom:loaded', function() {
                    app.prefix()InitQuickNavigation('name.formatForCode');
                    {{if isset($searchFilter) && $searchFilter eq false}}
                        {{* we can hide the submit button if we have no quick search field *}}
                        $('quicknavSubmit').addClassName('z-hide');
                    {{/if}}
                });
            ELSE
                ( function($) {
                    $(document).ready(function() {
                        app.prefix()InitQuickNavigation('name.formatForCode');
                        {{if isset($searchFilter) && $searchFilter eq false}}
                            {{* we can hide the submit button if we have no quick search field *}}
                            $('#quicknavSubmit').addClass('hidden');
                        {{/if}}
                    });
                })(jQuery);
            ENDIF
        /* ]]> */
        </script>
        {/checkpermissionblock}
    '''

    def private formFields(Entity it) '''
        categoriesFields
        val incomingRelations = getBidirectionalIncomingJoinRelationsWithOneSource
        IF !incomingRelations.empty
            FOR relation : incomingRelations
                relation.formField
            ENDFOR
        ENDIF
        IF hasListFieldsEntity
            FOR field : getListFieldsEntity
                field.formField
            ENDFOR
        ENDIF
        IF hasUserFieldsEntity
            FOR field : getUserFieldsEntity
                field.formField
            ENDFOR
        ENDIF
        IF hasCountryFieldsEntity
            FOR field : getCountryFieldsEntity
                field.formField
            ENDFOR
        ENDIF
        IF hasLanguageFieldsEntity
            FOR field : getLanguageFieldsEntity
                field.formField
            ENDFOR
        ENDIF
        IF hasLocaleFieldsEntity
            FOR field : getLocaleFieldsEntity
                field.formField
            ENDFOR
        ENDIF
        IF hasAbstractStringFieldsEntity
            {if !isset($searchFilter) || $searchFilter eq true}
                IF !container.application.targets('1.3.5')
                    <div class="form-group">
                ENDIF
                    <label for="searchTerm">{gt text='Search'}</label>
                    <input type="text" id="searchTerm" name="searchterm" value="{$searchterm}"IF !container.application.targets('1.3.5') class="form-control input-sm"ENDIF />
                IF !container.application.targets('1.3.5')
                    </div>
                ENDIF
            {/if}
        ENDIF
        sortingAndPageSize
        IF hasBooleanFieldsEntity
            FOR field : getBooleanFieldsEntity
                field.formField
            ENDFOR
        ENDIF
    '''

    def private categoriesFields(Entity it) '''
        IF categorisable
            {if !isset($categoryFilter) || $categoryFilter eq true}
                {nocache}
                {modapifunc modname='container.application.appName' type='category' func='getAllProperties' ot=$objectType assign='properties'}
                {if $properties ne null && is_array($properties)}
                    {gt text='All' assign='lblDefault'}
                    {foreach key='propertyName' item='propertyId' from=$properties}
                        {modapifunc modname='container.application.appName' type='category' func='hasMultipleSelection' ot=$objectType registry=$propertyName assign='hasMultiSelection'}
                        {gt text='Category' assign='categoryLabel'}
                        {assign var='categorySelectorId' value='catid'}
                        {assign var='categorySelectorName' value='catid'}
                        {assign var='categorySelectorSize' value='1'}
                        {if $hasMultiSelection eq true}
                            {gt text='Categories' assign='categoryLabel'}
                            {assign var='categorySelectorName' value='catids'}
                            {assign var='categorySelectorId' value='catids__'}
                            {assign var='categorySelectorSize' value='5'}
                        {/if}
                        IF !container.application.targets('1.3.5')
                            <div class="form-group">
                        ENDIF
                            <label for="{$categorySelectorId}{$propertyName}">{$categoryLabel}</label>
                            &nbsp;
                            {selector_category name="`$categorySelectorName``$propertyName`" field='id' selectedValue=$catIdList.$propertyName categoryRegistryModule='container.application.appName' categoryRegistryTable=$objectType categoryRegistryProperty=$propertyName defaultText=$lblDefault editLink=false multipleSize=$categorySelectorSizeIF !container.application.targets('1.3.5') cssClass='form-control input-sm'ENDIF}
                        IF !container.application.targets('1.3.5')
                            </div>
                        ENDIF
                    {/foreach}
                {/if}
                {/nocache}
            {/if}
        ENDIF
    '''

    def private dispatch formField(DerivedField it) '''
        val fieldName = name.formatForCode
        {if !isset($fieldNameFilter) || $fieldNameFilter eq true}
            IF !entity.container.application.targets('1.3.5')
                <div class="form-group">
            ENDIF
                formFieldImpl
            IF !entity.container.application.targets('1.3.5')
                </div>
            ENDIF
        {/if}
    '''

    def private dispatch formFieldImpl(BooleanField it) '''
        val fieldName = name.formatForCode
        val fieldLabel = if (name == 'workflowState') 'state' else name
        <label for="fieldName">{gt text='fieldLabel.formatForDisplayCapital'}</label>
        <select id="fieldName" name="fieldName"IF !entity.container.application.targets('1.3.5') class="form-control input-sm"ENDIF>
            <option value="">{$lblDefault}</option>
        {foreach item='option' from=$fieldNameItems}
            <option value="{$option.value}"{if $option.value eq $fieldName} selected="selected"{/if}>{$option.text|safetext}</option>
        {/foreach}
        </select>
    '''

    def private dispatch formFieldImpl(StringField it) '''
        val fieldName = name.formatForCode
        <label for="fieldName">{gt text='name.formatForDisplayCapital'}</label>
        IF country
            {selector_countries name='fieldName' selectedValue=$fieldName defaultText=$lblDefault defaultValue=''}
        ELSEIF language || locale
            {html_select_locales name='fieldName' selected=$fieldName}
        ENDIF
    '''

    def private dispatch formFieldImpl(UserField it) '''
        val fieldName = name.formatForCode
        <label for="fieldName">{gt text='name.formatForDisplayCapital'}</label>
        {selector_user name='fieldName' selectedValue=$fieldName defaultText=$lblDefault}
    '''

    def private dispatch formFieldImpl(ListField it) '''
        val fieldName = name.formatForCode
        <label for="fieldName">{gt text='name.formatForDisplayCapital'}</label>
        <select id="fieldName" name="fieldName"IF !entity.container.application.targets('1.3.5') class="form-control input-sm"ENDIF>
            <option value="">{$lblDefault}</option>
        {foreach item='option' from=$fieldNameItems}
        IF multiple
            <option value="%{$option.value}"{if $option.title ne ''} title="{$option.title|safetext}"{/if}{if "%`$option.value`" eq $formats} selected="selected"{/if}>{$option.text|safetext}</option>
        ELSE
            <option value="{$option.value}"{if $option.title ne ''} title="{$option.title|safetext}"{/if}{if $option.value eq $fieldName} selected="selected"{/if}>{$option.text|safetext}</option>
        ENDIF
        {/foreach}
        </select>
    '''

    def private dispatch formField(JoinRelationship it) '''
        val sourceName = source.name.formatForCode
        val sourceAliasName = getRelationAliasName(false)
        {if !isset($sourceNameFilter) || $sourceNameFilter eq true}
            IF !container.application.targets('1.3.5')
                <div class="form-group">
            ENDIF
                <label for="sourceAliasName">{gt text='source.nameMultiple.formatForDisplayCapital'}</label>
                {modapifunc modname='source.container.application.appName' type='selection' func='getEntities' ot='source.name.formatForCode' useJoins=false assign='listEntries'}
                <select id="sourceAliasName" name="sourceAliasName"IF !container.application.targets('1.3.5') class="form-control input-sm"ENDIF>
                    <option value="">{$lblDefault}</option>
                {foreach item='option' from=$listEntries}
                    IF source.hasCompositeKeys
                        {assign var='entryId' value="FOR pkField : source.getPrimaryKeyFields SEPARATOR '_'`$option.pkField.name.formatForCode`ENDFOR"}
                    ELSE
                        {assign var='entryId' value=$option.source.getFirstPrimaryKey.name.formatForCode}
                    ENDIF
                    <option value="{$entryId}"{if $entryId eq $sourceAliasName} selected="selected"{/if}>{$option->getTitleFromDisplayPattern()}</option>
                {/foreach}
                </select>
            IF !container.application.targets('1.3.5')
                </div>
            ENDIF
        {/if}
    '''

    def private sortingAndPageSize(Entity it) '''
        {if !isset($sorting) || $sorting eq true}
            IF !container.application.targets('1.3.5')
                <div class="form-group">
            ENDIF
                <label for="sortBy">{gt text='Sort by'}</label>
                &nbsp;
                <select id="sortBy" name="sort"IF !container.application.targets('1.3.5') class="form-control input-sm"ENDIF>
                    FOR field : getDerivedFields
                        <option value="field.name.formatForCode"{if $sort eq 'field.name.formatForCode'} selected="selected"{/if}>{gt text='field.name.formatForDisplayCapital'}</option>
                    ENDFOR
                    IF standardFields
                    <option value="createdDate"{if $sort eq 'createdDate'} selected="selected"{/if}>{gt text='Creation date'}</option>
                    <option value="createdUserId"{if $sort eq 'createdUserId'} selected="selected"{/if}>{gt text='Creator'}</option>
                    <option value="updatedDate"{if $sort eq 'updatedDate'} selected="selected"{/if}>{gt text='Update date'}</option>
                    ENDIF
                </select>
            IF !container.application.targets('1.3.5')
                </div>
                <div class="form-group">
            ENDIF
                <select id="sortDir" name="sortdir"IF !container.application.targets('1.3.5') class="form-control input-sm"ENDIF>
                    <option value="asc"{if $sdir eq 'asc'} selected="selected"{/if}>{gt text='ascending'}</option>
                    <option value="desc"{if $sdir eq 'desc'} selected="selected"{/if}>{gt text='descending'}</option>
                </select>
            IF !container.application.targets('1.3.5')
                </div>
            ENDIF
        {else}
            <input type="hidden" name="sort" value="{$sort}" />
            <input type="hidden" name="sdir" value="{if $sdir eq 'desc'}asc{else}desc{/if}" />
        {/if}
        {if !isset($pageSizeSelector) || $pageSizeSelector eq true}
            IF !container.application.targets('1.3.5')
                <div class="form-group">
            ENDIF
                <label for="num">{gt text='Page size'}</label>
                <select id="num" name="num"IF !container.application.targets('1.3.5') class="form-control input-sm" style="min-width: 70px"ENDIF>
                    <option value="5"{if $pageSize eq 5} selected="selected"{/if}>5</option>
                    <option value="10"{if $pageSize eq 10} selected="selected"{/if}>10</option>
                    <option value="15"{if $pageSize eq 15} selected="selected"{/if}>15</option>
                    <option value="20"{if $pageSize eq 20} selected="selected"{/if}>20</option>
                    <option value="30"{if $pageSize eq 30} selected="selected"{/if}>30</option>
                    <option value="50"{if $pageSize eq 50} selected="selected"{/if}>50</option>
                    <option value="100"{if $pageSize eq 100} selected="selected"{/if}>100</option>
                </select>
            IF !container.application.targets('1.3.5')
                </div>
            ENDIF
        {/if}
    '''
}
