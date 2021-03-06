package org.zikula.modulestudio.generator.cartridges.zclassic.view.additions

import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class BlocksView {
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate(Application it, IFileSystemAccess fsa) {
        val templatePath = getViewPath + (if (targets('1.3.5')) 'block' else 'Block') + '/'
        var fileName = 'itemlist.tpl'
        if (!shouldBeSkipped(templatePath + fileName)) {
            if (shouldBeMarked(templatePath + fileName)) {
                fileName = 'itemlist.generated.tpl'
            }
            fsa.generateFile(templatePath + fileName, displayTemplate)
        }
        fileName = 'itemlist_modify.tpl'
        if (!shouldBeSkipped(templatePath + fileName)) {
            if (shouldBeMarked(templatePath + fileName)) {
                fileName = 'itemlist_modify.generated.tpl'
            }
            fsa.generateFile(templatePath + fileName, editTemplate)
        }
    }

    def private displayTemplate(Application it) '''
        {* Purpose of this template: Display items within a block (fallback template) *}
        Default block for generic item list.
    '''

    def private editTemplate(Application it) '''
        {* Purpose of this template: Edit block for generic item list *}
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
            <label for="appName.toFirstLowerObjectType"IF !targets('1.3.5') class="col-lg-3 control-label"ENDIF>{gt text='Object type'}:</label>
            IF !targets('1.3.5')
                <div class="col-lg-9">
            ENDIF
                <select id="appName.toFirstLowerObjectType" name="objecttype" size="1"IF !targets('1.3.5') class="form-control"ENDIF>
                    FOR entity : getAllEntities
                        <option value="entity.name.formatForCode"{if $objectType eq 'entity.name.formatForCode'} selected="selected"{/if}>{gt text='entity.nameMultiple.formatForDisplayCapital'}</option>
                    ENDFOR
                </select>
                <span class="IF targets('1.3.5')z-sub z-formnoteELSEhelp-blockENDIF">{gt text='If you change this please save the block once to reload the parameters below.'}</span>
            IF !targets('1.3.5')
                </div>
            ENDIF
        </div>
    '''

    def private editTemplateCategories(Application it) '''
        {if $catIds ne null && is_array($catIds)}
            {gt text='All' assign='lblDefault'}
            {nocache}
            {foreach key='propertyName' item='propertyId' from=$catIds}
                <div class="IF targets('1.3.5')z-formrowELSEform-groupENDIF">
                    {modapifunc modname='appName' type='category' func='hasMultipleSelection' ot=$objectType registry=$propertyName assign='hasMultiSelection'}
                    {gt text='Category' assign='categoryLabel'}
                    {assign var='categorySelectorId' value='catid'}
                    {assign var='categorySelectorName' value='catid'}
                    {assign var='categorySelectorSize' value='1'}
                    {if $hasMultiSelection eq true}
                        {gt text='Categories' assign='categoryLabel'}
                        {assign var='categorySelectorName' value='catids'}
                        {assign var='categorySelectorId' value='catids__'}
                        {assign var='categorySelectorSize' value='8'}
                    {/if}
                    <label for="{$categorySelectorId}{$propertyName}"IF !targets('1.3.5') class="col-lg-3 control-label"ENDIF>{$categoryLabel}</label>
                    IF !targets('1.3.5')
                        <div class="col-lg-9">
                    ELSE
                        &nbsp;
                    ENDIF
                        {selector_category name="`$categorySelectorName``$propertyName`" field='id' selectedValue=$catIds.$propertyName categoryRegistryModule='appName' categoryRegistryTable=$objectType categoryRegistryProperty=$propertyName defaultText=$lblDefault editLink=false multipleSize=$categorySelectorSizeIF !targets('1.3.5') cssClass='form-control'ENDIF}
                        <span class="IF targets('1.3.5')z-sub z-formnoteELSEhelp-blockENDIF">{gt text='This is an optional filter.'}</span>
                    IF !targets('1.3.5')
                        </div>
                    ENDIF
                </div>
            {/foreach}
            {/nocache}
        {/if}
    '''

    def private editTemplateSorting(Application it) '''
        <div class="IF targets('1.3.5')z-formrowELSEform-groupENDIF">
            <label for="appName.toFirstLowerSorting"IF !targets('1.3.5') class="col-lg-3 control-label"ENDIF>{gt text='Sorting'}:</label>
            IF !targets('1.3.5')
                <div class="col-lg-9">
            ENDIF
                <select id="appName.toFirstLowerSorting" name="sorting"IF !targets('1.3.5') class="form-control"ENDIF>
                    <option value="random"{if $sorting eq 'random'} selected="selected"{/if}>{gt text='Random'}</option>
                    <option value="newest"{if $sorting eq 'newest'} selected="selected"{/if}>{gt text='Newest'}</option>
                    <option value="alpha"{if $sorting eq 'default' || ($sorting != 'random' && $sorting != 'newest')} selected="selected"{/if}>{gt text='Default'}</option>
                </select>
            IF !targets('1.3.5')
                </div>
            ENDIF
        </div>
    '''

    def private editTemplateAmount(Application it) '''
        <div class="IF targets('1.3.5')z-formrowELSEform-groupENDIF">
            <label for="appName.toFirstLowerAmount"IF !targets('1.3.5') class="col-lg-3 control-label"ENDIF>{gt text='Amount'}:</label>
            IF !targets('1.3.5')
                <div class="col-lg-9">
            ENDIF
                <input type="text" id="appName.toFirstLowerAmount" name="amount" maxlength="2" size="10" value="{$amount|default:"5"}"IF !targets('1.3.5') class="form-control"ENDIF />
            IF !targets('1.3.5')
                </div>
            ENDIF
        </div>
    '''

    def private editTemplateTemplate(Application it) '''
        <div class="IF targets('1.3.5')z-formrowELSEform-groupENDIF">
            <label for="appName.toFirstLowerTemplate"IF !targets('1.3.5') class="col-lg-3 control-label"ENDIF>{gt text='Template'}:</label>
            IF !targets('1.3.5')
                <div class="col-lg-9">
            ENDIF
                <select id="appName.toFirstLowerTemplate" name="template"IF !targets('1.3.5') class="form-control"ENDIF>
                    <option value="itemlist_display.tpl"{if $template eq 'itemlist_display.tpl'} selected="selected"{/if}>{gt text='Only item titles'}</option>
                    <option value="itemlist_display_description.tpl"{if $template eq 'itemlist_display_description.tpl'} selected="selected"{/if}>{gt text='With description'}</option>
                    <option value="custom"{if $template eq 'custom'} selected="selected"{/if}>{gt text='Custom template'}</option>
                </select>
            IF !targets('1.3.5')
                </div>
            ENDIF
        </div>

        <div id="customTemplateArea" class="IF targets('1.3.5')z-formrow z-hideELSEform-group hiddenENDIF"IF !targets('1.3.5') data-switch="appName.toFirstLowerTemplate" data-switch-value="custom"ENDIF>
            <label for="appName.toFirstLowerCustomTemplate"IF !targets('1.3.5') class="col-lg-3 control-label"ENDIF>{gt text='Custom template'}:</label>
            IF !targets('1.3.5')
                <div class="col-lg-9">
            ENDIF
                <input type="text" id="appName.toFirstLowerCustomTemplate" name="customtemplate" size="40" maxlength="80" value="{$customTemplate|default:''}"IF !targets('1.3.5') class="form-control"ENDIF />
                <span class="IF targets('1.3.5')z-sub z-formnoteELSEhelp-blockENDIF">{gt text='Example'}: <em>itemlist_[objectType]_display.tpl</em></span>
            IF !targets('1.3.5')
                </div>
            ENDIF
        </div>
    '''

    def private editTemplateFilter(Application it) '''
        <div class="IF targets('1.3.5')z-formrow z-hideELSEform-groupENDIF">
            <label for="appName.toFirstLowerFilter"IF !targets('1.3.5') class="col-lg-3 control-label"ENDIF>{gt text='Filter (expert option)'}:</label>
            IF !targets('1.3.5')
                <div class="col-lg-9">
            ENDIF
                <input type="text" id="appName.toFirstLowerFilter" name="filter" size="40" value="{$filterValue|default:''}"IF !targets('1.3.5') class="form-control"ENDIF />
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
                        $('customTemplateArea').removeClassName('z-hide');
                    } else {
                        $('customTemplateArea').addClassName('z-hide');
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
}
