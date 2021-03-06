package org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents

import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.Entity
import de.guite.modulestudio.metamodel.modulestudio.EntityWorkflowType
import de.guite.modulestudio.metamodel.modulestudio.JoinRelationship
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.UrlExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Relations {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension NamingExtensions = new NamingExtensions
    extension UrlExtensions = new UrlExtensions
    extension Utils = new Utils

    def displayItemList(Entity it, Application app, Boolean many, IFileSystemAccess fsa) {
        val templatePath = templateFile('include_displayItemList' + (if (many) 'Many' else 'One'))
        if (!app.shouldBeSkipped(templatePath)) {
            fsa.generateFile(templatePath, '''
                {* purpose of this template: inclusion template for display of related nameMultiple.formatForDisplay *}
                {assign var='lct' value='user'}
                {if isset($smarty.get.lct) && $smarty.get.lct eq 'admin'}
                    {assign var='lct' value='admin'}
                {/if}
                {if $lct ne 'admin'}
                    {checkpermission component='app.appName:name.formatForCodeCapital:' instance='::' level='ACCESS_IF workflow == EntityWorkflowType::NONEEDITELSECOMMENTENDIF' assign='hasAdminPermission'}
                    {checkpermission component='app.appName:name.formatForCodeCapital:' instance='::' level='ACCESS_IF workflow == EntityWorkflowType::NONEEDITELSECOMMENTENDIF' assign='hasEditPermission'}
                {/if}
                IF hasActions('display')
                    {if !isset($nolink)}
                        {assign var='nolink' value=false}
                    {/if}
                ENDIF
                IF !many
                    <h4>
                ELSE
                    {if isset($items) && $items ne null && count($items) gt 0}
                    <ul class="app.appName.toLowerCase-related-item-list name.formatForCode">
                    {foreach name='relLoop' item='item' from=$items}
                        {if $hasAdminPermission || $item.workflowState eq 'approved'IF ownerPermission || ($item.workflowState eq 'defered' && $hasEditPermission && isset($uid) && $item.createdUserId eq $uid)ENDIF}
                        <li>
                ENDIF
                IF hasActions('display')
                    {strip}
                    {if !$nolink}
                        IF app.targets('1.3.5')
                            <a href="{modurl modname='app.appName' type=$lct func='display' ot='name.formatForCode' routeParamsLegacy('item', true, true)}" title="{$item->getTitleFromDisplayPattern()|replace:"\"":""}">
                        ELSE
                            <a href="{route name='app.appName.formatForDB_name.formatForCode_display' routeParams('item', true) lct=$lct}" title="{$item->getTitleFromDisplayPattern()|replace:"\"":""}">
                        ENDIF
                    {/if}
                ENDIF
                    {$item->getTitleFromDisplayPattern()}
                IF hasActions('display')
                    {if !$nolink}
                        </a>
                        IF app.targets('1.3.5')
                            <a id="name.formatForCodeItemFOR pkField : getPrimaryKeyFields SEPARATOR '_'{$item.pkField.name.formatForCode}ENDFORDisplay" href="{modurl modname='app.appName' type=$lct func='display' ot='name.formatForCode' routeParamsLegacy('item', true, true) theme='Printer' forcelongurl=true}" title="{gt text='Open quick view window'}" class="z-hide">{icon type='view' size='extrasmall' __alt='Quick view'}</a>
                        ELSE
                            <a id="name.formatForCodeItemFOR pkField : getPrimaryKeyFields SEPARATOR '_'{$item.pkField.name.formatForCode}ENDFORDisplay" href="{route name='app.appName.formatForDB_name.formatForCode_display' routeParams('item', true) lct=$lct theme='Printer'}" title="{gt text='Open quick view window'}" class="fa fa-search-plus hidden"></a>
                        ENDIF
                    {/if}
                    {/strip}
                ENDIF
                IF !many</h4>
                ENDIF
                IF hasActions('display')
                    {if !$nolink}
                    <script type="text/javascript">
                    /* <![CDATA[ */
                        IF app.targets('1.3.5')
                            document.observe('dom:loaded', function() {
                                app.prefix()InitInlineWindow($('name.formatForCodeItemFOR pkField : getPrimaryKeyFields SEPARATOR '_'{{$item.pkField.name.formatForCode}}ENDFORDisplay'), '{{$item->getTitleFromDisplayPattern()|replace:"'":""}}');
                            });
                        ELSE
                            ( function($) {
                                $(document).ready(function() {
                                    app.prefix()InitInlineWindow($('#name.formatForCodeItemFOR pkField : getPrimaryKeyFields SEPARATOR '_'{{$item.pkField.name.formatForCode}}ENDFORDisplay'), '{{$item->getTitleFromDisplayPattern()|replace:"'":""}}');
                                });
                            })(jQuery);
                        ENDIF
                    /* ]]> */
                    </script>
                    {/if}
                ENDIF
                IF hasImageFieldsEntity
                    <br />
                    val imageFieldName = getImageFieldsEntity.head.name.formatForCode
                    {if $item.imageFieldName ne '' && isset($item.imageFieldNameFullPath) && $item.imageFieldNameMeta.isImage}
                        {thumb image=$item.imageFieldNameFullPath objectid="name.formatForCodeIF hasCompositeKeysFOR pkField : getPrimaryKeyFields-`$item.pkField.name.formatForCode`ENDFORELSE-`$item.primaryKeyFields.head.name.formatForCode`ENDIF" preset=$relationThumbPreset tag=true img_alt=$item->getTitleFromDisplayPattern()IF !container.application.targets('1.3.5') img_class='img-rounded'ENDIF}
                    {/if}
                ENDIF
                IF many
                        </li>
                        {/if}
                    {/foreach}
                    </ul>
                    {/if}
                ENDIF
            ''')
        }
    }

    def displayRelatedItems(JoinRelationship it, String appName, Entity relatedEntity) '''
        val incoming = (if (target == relatedEntity && source != relatedEntity) true else false)/* use outgoing mode for self relations #547 */
        val useTarget = !incoming
        val relationAliasName = getRelationAliasName(useTarget).formatForCode.toFirstLower
        val relationAliasNameParam = getRelationAliasName(!useTarget).formatForCode
        val otherEntity = (if (!useTarget) source else target)
        val many = isManySideDisplay(useTarget)
        {if $lct eq 'admin'}
            <h4>{gt text='otherEntity.getEntityNameSingularPlural(many).formatForDisplayCapital'}</h4>
        {else}
            <h3>{gt text='otherEntity.getEntityNameSingularPlural(many).formatForDisplayCapital'}</h3>
        {/if}

        {if isset($relatedEntity.name.formatForCode.relationAliasName) && $relatedEntity.name.formatForCode.relationAliasName ne null}
            {include file='IF container.application.targets('1.3.5')otherEntity.name.formatForCodeELSEotherEntity.name.formatForCodeCapitalENDIF/include_displayItemListIF manyManyELSEOneENDIF.tpl' itemIF manysENDIF=$relatedEntity.name.formatForCode.relationAliasName}
        {/if}

        IF otherEntity.hasActions('edit')
            IF !many
                {if !isset($relatedEntity.name.formatForCode.relationAliasName) || $relatedEntity.name.formatForCode.relationAliasName eq null}
            ENDIF
            {assign var='permLevel' value='ACCESS_IF relatedEntity.workflow == EntityWorkflowType::NONEEDITELSECOMMENTENDIF'}
            {if $lct eq 'admin'}
                {assign var='permLevel' value='ACCESS_ADMIN'}
            {/if}
            {checkpermission component='appName:relatedEntity.name.formatForCodeCapital:' instance="relatedEntity.idFieldsAsParameterTemplate::" level=$permLevel assign='mayManage'}
            {if $mayManage || (isset($uid) && isset($relatedEntity.name.formatForCode.createdUserId) && $relatedEntity.name.formatForCode.createdUserId eq $uid)}
            <p class="managelink">
                {gt text='Create otherEntity.name.formatForDisplay' assign='createTitle'}
                IF container.application.targets('1.3.5')
                    <a href="{modurl modname='appName' type=$lct func='edit' ot='otherEntity.name.formatForCode' relationAliasNameParam="relatedEntity.idFieldsAsParameterTemplate" returnTo="`$lct`DisplayrelatedEntity.name.formatForCodeCapital"'}" title="{$createTitle}" class="z-icon-es-add">{$createTitle}</a>
                ELSE
                    <a href="{route name='appName.formatForDB_otherEntity.name.formatForCode_edit' lct=$lct relationAliasNameParam="relatedEntity.idFieldsAsParameterTemplate" returnTo="`$lct`DisplayrelatedEntity.name.formatForCodeCapital"'}" title="{$createTitle}" class="fa fa-plus">{$createTitle}</a>
                ENDIF
            </p>
            {/if}
            IF !many
                {/if}
            ENDIF
        ENDIF
    '''
}
