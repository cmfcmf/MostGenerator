package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages

import de.guite.modulestudio.metamodel.modulestudio.BooleanField
import de.guite.modulestudio.metamodel.modulestudio.DecimalField
import de.guite.modulestudio.metamodel.modulestudio.DerivedField
import de.guite.modulestudio.metamodel.modulestudio.Entity
import de.guite.modulestudio.metamodel.modulestudio.EntityTreeType
import de.guite.modulestudio.metamodel.modulestudio.EntityWorkflowType
import de.guite.modulestudio.metamodel.modulestudio.FloatField
import de.guite.modulestudio.metamodel.modulestudio.IntegerField
import de.guite.modulestudio.metamodel.modulestudio.JoinRelationship
import de.guite.modulestudio.metamodel.modulestudio.ListField
import de.guite.modulestudio.metamodel.modulestudio.NamedObject
import de.guite.modulestudio.metamodel.modulestudio.OneToManyRelationship
import de.guite.modulestudio.metamodel.modulestudio.OneToOneRelationship
import java.util.List
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents.ItemActionsView
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents.SimpleFields
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents.ViewQuickNavForm
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.UrlExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions

class View {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension NamingExtensions = new NamingExtensions
    extension UrlExtensions = new UrlExtensions
    extension Utils = new Utils
    extension WorkflowExtensions = new WorkflowExtensions

    SimpleFields fieldHelper = new SimpleFields

    Integer listType

    /*
      listType:
        0 = div and ul
        1 = div and ol
        2 = div and dl
        3 = div and table
     */
    def generate(Entity it, String appName, Integer listType, IFileSystemAccess fsa) {
        println('Generating view templates for entity "' + name.formatForDisplay + '"')
        this.listType = listType
        val templateFilePath = templateFile('view')
        if (!container.application.shouldBeSkipped(templateFilePath)) {
            fsa.generateFile(templateFilePath, viewView(appName))
        }
        new ViewQuickNavForm().generate(it, appName, fsa)
    }

    def private viewView(Entity it, String appName) '''
        {* purpose of this template: nameMultiple.formatForDisplay list view *}
        {assign var='lct' value='user'}
        {if isset($smarty.get.lct) && $smarty.get.lct eq 'admin'}
            {assign var='lct' value='admin'}
        {/if}
        IF container.application.targets('1.3.5')
            {include file="`$lct`/header.tpl"}
        ELSE
            {assign var='lctUc' value=$lct|ucfirst}
            {include file="`$lctUc`/header.tpl"}
        ENDIF
        <div class="appName.toLowerCase-name.formatForDB appName.toLowerCase-view">
            {gt text='name.formatForDisplayCapital list' assign='templateTitle'}
            {pagesetvar name='title' value=$templateTitle}
            templateHeader
            IF documentation !== null && documentation != ''

                <p class="IF container.application.targets('1.3.5')z-informationmsgELSEalert alert-infoENDIF">{gt text='documentation.replace('\'', '\\\'')'}</p>
            ENDIF

            pageNavLinks(appName)

            {include file='IF container.application.targets('1.3.5')name.formatForCodeELSEname.formatForCodeCapitalENDIF/view_quickNav.tpl' all=$all own=$ownIF !hasVisibleWorkflow workflowStateFilter=falseENDIF}{* see template file for available options *}

            viewForm(appName)

            callDisplayHooks(appName)
        </div>
        IF container.application.targets('1.3.5')
            {include file="`$lct`/footer.tpl"}
        ELSE
            {include file="`$lctUc`/footer.tpl"}
        ENDIF
        ajaxToggle
    '''

    def private pageNavLinks(Entity it, String appName) '''
        val objName = name.formatForCode
        IF hasActions('edit')
            {if $canBeCreated}
                {checkpermissionblock component='appName:name.formatForCodeCapital:' instance='::' level='ACCESS_IF workflow == EntityWorkflowType::NONEEDITELSECOMMENTENDIF'}
                    {gt text='Create name.formatForDisplay' assign='createTitle'}
                    IF container.application.targets('1.3.5')
                        <a href="{modurl modname='appName' type=$lct func='edit' ot='objName'}" title="{$createTitle}" class="z-icon-es-add">{$createTitle}</a>
                    ELSE
                        <a href="{route name='appName.formatForDB_objName_edit' lct=$lct}" title="{$createTitle}" class="fa fa-plus">{$createTitle}</a>
                    ENDIF
                {/checkpermissionblock}
            {/if}
        ENDIF
        {assign var='own' value=0}
        {if isset($showOwnEntries) && $showOwnEntries eq 1}
            {assign var='own' value=1}
        {/if}
        {assign var='all' value=0}
        {if isset($showAllEntries) && $showAllEntries eq 1}
            {gt text='Back to paginated view' assign='linkTitle'}
            IF container.application.targets('1.3.5')
                <a href="{modurl modname='appName' type=$lct func='view' ot='objName'}" title="{$linkTitle}" class="z-icon-es-view">{$linkTitle}</a>
            ELSE
                <a href="{route name='appName.formatForDB_objName_view' lct=$lct}" title="{$linkTitle}" class="fa fa-table">{$linkTitle}</a>
            ENDIF
            {assign var='all' value=1}
        {else}
            {gt text='Show all entries' assign='linkTitle'}
            IF container.application.targets('1.3.5')
                <a href="{modurl modname='appName' type=$lct func='view' ot='objName' all=1}" title="{$linkTitle}" class="z-icon-es-view">{$linkTitle}</a>
            ELSE
                <a href="{route name='appName.formatForDB_objName_view' lct=$lct all=1}" title="{$linkTitle}" class="fa fa-table">{$linkTitle}</a>
            ENDIF
        {/if}
        IF tree != EntityTreeType::NONE
            {gt text='Switch to hierarchy view' assign='linkTitle'}
            IF container.application.targets('1.3.5')
                <a href="{modurl modname='appName' type=$lct func='view' ot='objName' tpl='tree'}" title="{$linkTitle}" class="z-icon-es-view">{$linkTitle}</a>
            ELSE
                <a href="{route name='appName.formatForDB_objName_view' lct=$lct tpl='tree'}" title="{$linkTitle}" class="fa fa-code-fork">{$linkTitle}</a>
            ENDIF
        ENDIF
    '''

    def private viewForm(Entity it, String appName) '''
        IF listType == 3
            {if $lct eq 'admin'}
            <form action="IF container.application.targets('1.3.5'){modurl modname='appName' type='name.formatForCode' func='handleSelectedEntries' lct=$lct}ELSE{route name='appName.formatForDB_name.formatForCode_handleSelectedEntries' lct=$lct}ENDIF" method="post" id="nameMultiple.formatForCodeViewForm" class="IF container.application.targets('1.3.5')z-formELSEform-horizontalENDIF"IF !container.application.targets('1.3.5') role="form"ENDIF>
                <div>
                    <input type="hidden" name="csrftoken" value="{insert name='csrftoken'}" />
            {/if}
        ENDIF
            viewItemList(appName)
            pagerCall(appName)
        IF listType == 3
            {if $lct eq 'admin'}
                    massActionFields(appName)
                </div>
            </form>
            {/if}
        ENDIF
    '''

    def private viewItemList(Entity it, String appName) '''
            val listItemsFields = getDisplayFieldsForView
            val listItemsIn = incoming.filter(OneToManyRelationship).filter[bidirectional]
            val listItemsOut = outgoing.filter(OneToOneRelationship)
            viewItemListHeader(appName, listItemsFields, listItemsIn, listItemsOut)

            viewItemListBody(appName, listItemsFields, listItemsIn, listItemsOut)

            viewItemListFooter
    '''

    def private viewItemListHeader(Entity it, String appName, List<DerivedField> listItemsFields, Iterable<OneToManyRelationship> listItemsIn, Iterable<OneToOneRelationship> listItemsOut) '''
        IF listType != 3
            <listType.asListTag>
        ELSE
            IF !container.application.targets('1.3.5')
                <div class="table-responsive">
            ENDIF
            <table class="IF container.application.targets('1.3.5')z-datatableELSEtable table-striped table-bordered table-hoverIF (listItemsFields.size + listItemsIn.size + listItemsOut.size + 1) > 7 table-condensedELSE{if $lct eq 'admin'} table-condensed{/if}ENDIFENDIF">
                <colgroup>
                    {if $lct eq 'admin'}
                        <col id="cSelect" />
                    {/if}
                    FOR field : listItemsFieldsfield.columnDefENDFOR
                    FOR relation : listItemsInrelation.columnDef(false)ENDFOR
                    FOR relation : listItemsOutrelation.columnDef(true)ENDFOR
                    <col id="cItemActions" />
                </colgroup>
                <thead>
                <tr>
                    IF categorisable
                        {assign var='catIdListMainString' value=','|implode:$catIdList.Main}
                    ENDIF
                    {if $lct eq 'admin'}
                        <th id="hSelect" scope="col" align="center" valign="middle">
                            <input type="checkbox" id="togglenameMultiple.formatForCodeCapital" />
                        </th>
                    {/if}
                    FOR field : listItemsFieldsfield.headerLineENDFOR
                    FOR relation : listItemsInrelation.headerLine(false)ENDFOR
                    FOR relation : listItemsOutrelation.headerLine(true)ENDFOR
                    <th id="hItemActions" scope="col" class="IF container.application.targets('1.3.5')z-right ENDIFz-order-unsorted">{gt text='Actions'}</th>
                </tr>
                </thead>
                <tbody>
        ENDIF
    '''

    def private viewItemListBody(Entity it, String appName, List<DerivedField> listItemsFields, Iterable<OneToManyRelationship> listItemsIn, Iterable<OneToOneRelationship> listItemsOut) '''
        {foreach item='name.formatForCode' from=$items}
            IF listType < 2
                <li><ul>
            ELSEIF listType == 2
                <dt>
            ELSEIF listType == 3
                <trIF container.application.targets('1.3.5') class="{cycle values='z-odd, z-even'}"ENDIF>
                    {if $lct eq 'admin'}
                        <td headers="hselect" align="center" valign="top">
                            <input type="checkbox" name="items[]" value="{$name.formatForCode.getPrimaryKeyFields.head.name.formatForCode}" class="nameMultiple.formatForCode.toLowerCase-checkbox" />
                        </td>
                    {/if}
            ENDIF
                FOR field : listItemsFieldsfield.displayEntry(false)ENDFOR
                FOR relation : listItemsInrelation.displayEntry(false)ENDFOR
                FOR relation : listItemsOutrelation.displayEntry(true)ENDFOR
                itemActions(appName)
            IF listType < 2
                </ul></li>
            ELSEIF listType == 2
                </dt>
            ELSEIF listType == 3
                </tr>
            ENDIF
        {foreachelse}
            IF listType < 2
                <li>
            ELSEIF listType == 2
                <dt>
            ELSEIF listType == 3
                <tr class="z-{if $lct eq 'admin'}admin{else}data{/if}tableempty">
                  <td class="IF container.application.targets('1.3.5')zELSEtextENDIF-left" colspan="{if $lct eq 'admin'}(listItemsFields.size + listItemsIn.size + listItemsOut.size + 1 + 1){else}(listItemsFields.size + listItemsIn.size + listItemsOut.size + 1 + 0){/if}">
            ENDIF
            {gt text='No nameMultiple.formatForDisplay found.'}
            IF listType < 2
                </li>
            ELSEIF listType == 2
                </dt>
            ELSEIF listType == 3
                  </td>
                </tr>
            ENDIF
        {/foreach}
    '''

    def private viewItemListFooter(Entity it) '''
        IF listType != 3
            <listType.asListTag>
        ELSE
                </tbody>
            </table>
            IF !container.application.targets('1.3.5')
                </div>
            ENDIF
        ENDIF
    '''

    def private pagerCall(Entity it, String appName) '''

        {if !isset($showAllEntries) || $showAllEntries ne 1}
            {pager rowcount=$pager.numitems limit=$pager.itemsperpage display='page' modname='appName' type='name.formatForCode' func='view' lct=$lct}
        {/if}
    '''

    def private massActionFields(Entity it, String appName) '''
        <fieldset>
            <label for="appName.toFirstLowerAction"IF !container.application.targets('1.3.5') class="col-lg-3 control-label"ENDIF>{gt text='With selected nameMultiple.formatForDisplay'}</label>
            IF !container.application.targets('1.3.5')
                <div class="col-lg-9">
            ENDIF
            <select id="appName.toFirstLowerAction" name="action"IF !container.application.targets('1.3.5') class="form-control"ENDIF>
                <option value="">{gt text='Choose action'}</option>
            IF workflow != EntityWorkflowType::NONE
                IF workflow == EntityWorkflowType::ENTERPRISE
                    <option value="accept" title="{gt text='getWorkflowActionDescription(workflow, 'Accept')'}">{gt text='Accept'}</option>
                    IF ownerPermission
                        <option value="reject" title="{gt text='getWorkflowActionDescription(workflow, 'Reject')'}">{gt text='Reject'}</option>
                    ENDIF
                    <option value="demote" title="{gt text='getWorkflowActionDescription(workflow, 'Demote')'}">{gt text='Demote'}</option>
                ENDIF
                <option value="approve" title="{gt text='getWorkflowActionDescription(workflow, 'Approve')'}">{gt text='Approve'}</option>
            ENDIF
            IF hasTray
                <option value="unpublish" title="{gt text='getWorkflowActionDescription(workflow, 'Unpublish')'}">{gt text='Unpublish'}</option>
                <option value="publish" title="{gt text='getWorkflowActionDescription(workflow, 'Publish')'}">{gt text='Publish'}</option>
            ENDIF
            IF hasArchive
                <option value="archive" title="{gt text='getWorkflowActionDescription(workflow, 'Archive')' comment='this is the verb, not the noun'}">{gt text='Archive'}</option>
            ENDIF
            IF softDeleteable
                <option value="trash" title="{gt text='getWorkflowActionDescription(workflow, 'Trash')' comment='this is the verb, not the noun'}">{gt text='Trash'}</option>
                <option value="recover" title="{gt text='getWorkflowActionDescription(workflow, 'Recover')'}">{gt text='Recover'}</option>
            ENDIF
                <option value="delete" title="{gt text='getWorkflowActionDescription(workflow, 'Delete')'}">{gt text='Delete'}</option>
            </select>
            IF !container.application.targets('1.3.5')
                </div>
            ENDIF
            <input type="submit" value="{gt text='Submit'}" />
        </fieldset>
    '''

    def private callDisplayHooks(Entity it, String appName) '''

        {if $lct ne 'admin'}
            {notifydisplayhooks eventname='appName.formatForDB.ui_hooks.nameMultiple.formatForDB.display_view' urlobject=$currentUrlObject assign='hooks'}
            {foreach key='providerArea' item='hook' from=$hooks}
                {$hook}
            {/foreach}
        {/if}
    '''

    def private ajaxToggle(Entity it) '''
        IF hasBooleansWithAjaxToggleEntity || listType == 3

            <script type="text/javascript">
            /* <![CDATA[ */
                IF container.application.targets('1.3.5')
                    document.observe('dom:loaded', function() {
                        initAjaxSingleToggle
                        IF listType == 3
                            initMassToggle
                        ENDIF
                    });
                ELSE
                    ( function($) {
                        $(document).ready(function() {
                            initAjaxSingleToggle
                            IF listType == 3
                                initMassToggle
                            ENDIF
                        });
                    })(jQuery);
                ENDIF
            /* ]]> */
            </script>
        ENDIF
    '''

    def private initAjaxSingleToggle(Entity it) '''
        IF hasBooleansWithAjaxToggleEntity
            val objName = name.formatForCode
            {{foreach item='objName' from=$items}}
                {{assign var='itemid' value=$objName.getFirstPrimaryKey.name.formatForCode}}
                FOR field : getBooleansWithAjaxToggleEntity
                    container.application.prefix()InitToggle('objName', 'field.name.formatForCode', '{{$itemid}}');
                ENDFOR
            {{/foreach}}
        ENDIF
    '''

    def private initMassToggle(Entity it) '''
        {{if $lct eq 'admin'}}
            {{* init the "toggle all" functionality *}}
            if ($('togglenameMultiple.formatForCodeCapital') != undefined) {
                $('togglenameMultiple.formatForCodeCapital').observe('click', function (e) {
                    Zikula.toggleInput('nameMultiple.formatForCodeViewForm');
                    e.stop()
                });
            }
        {{/if}}
    '''

    def private templateHeader(Entity it) '''
        {if $lct eq 'admin'}
            IF container.application.targets('1.3.5')
                <div class="z-admin-content-pagetitle">
                    {icon type='view' size='small' alt=$templateTitle}
                    <h3>{$templateTitle}</h3>
                </div>
            ELSE
                <h3>
                    <span class="fa fa-list"></span>
                    {$templateTitle}
                </h3>
            ENDIF
        {else}
            <h2>{$templateTitle}</h2>
        {/if}
    '''

    def private columnDef(DerivedField it) '''
        <col id="cmarkupIdCode(false)" />
    '''

    def private columnDef(JoinRelationship it, Boolean useTarget) '''
        <col id="cmarkupIdCode(useTarget)" />
    '''

    def private headerLine(DerivedField it) '''
        <th id="hmarkupIdCode(false)" scope="col" class="IF entity.container.application.targets('1.3.5')zELSEtextENDIF-alignment">
            val fieldLabel = if (name == 'workflowState') 'state' else name
            headerSortingLink(entity, name.formatForCode, fieldLabel)
        </th>
    '''

    def private headerLine(JoinRelationship it, Boolean useTarget) '''
        <th id="hmarkupIdCode(useTarget)" scope="col" class="IF container.application.targets('1.3.5')zELSEtextENDIF-left">
            val mainEntity = (if (useTarget) source else target)
            headerSortingLink(mainEntity, getRelationAliasName(useTarget).formatForCode, getRelationAliasName(useTarget).formatForCodeCapital)
        </th>
    '''

    def private headerSortingLink(Object it, Entity entity, String fieldName, String label) '''
        {sortlink __linktext='label.formatForDisplayCapital' currentsort=$sort modname='entity.container.application.appName' type=IF entity.container.application.targets('1.3.5')$lctELSE'entity.name.formatForCode'ENDIF func='view' sort='fieldName'headerSortingLinkParameters(entity)IF entity.container.application.targets('1.3.5') ot='entity.name.formatForCode'ELSE lct=$lctENDIF}
    '''

    def private headerSortingLinkParameters(Entity it) ''' sortdir=$sdir all=$all own=$ownIF categorisable catidMain=$catIdListMainStringENDIFsortParamsForIncomingRelationssortParamsForListFieldssortParamsForUserFieldssortParamsForCountryFieldssortParamsForLanguageFieldssortParamsForLocaleFieldsIF hasAbstractStringFieldsEntity searchterm=$searchtermENDIF pageSize=$pageSizesortParamsForBooleanFields'''

    def private sortParamsForIncomingRelations(Entity it) '''IF !getBidirectionalIncomingJoinRelationsWithOneSource.emptyFOR relation: getBidirectionalIncomingJoinRelationsWithOneSourceval sourceAliasName = relation.getRelationAliasName(false).formatForCode sourceAliasName=$sourceAliasNameENDFORENDIF'''
    def private sortParamsForListFields(Entity it) '''IF hasListFieldsEntityFOR field : getListFieldsEntityval fieldName = field.name.formatForCode fieldName=$fieldNameENDFORENDIF'''
    def private sortParamsForUserFields(Entity it) '''IF hasUserFieldsEntityFOR field : getUserFieldsEntityval fieldName = field.name.formatForCode fieldName=$fieldNameENDFORENDIF'''
    def private sortParamsForCountryFields(Entity it) '''IF hasCountryFieldsEntityFOR field : getCountryFieldsEntityval fieldName = field.name.formatForCode fieldName=$fieldNameENDFORENDIF'''
    def private sortParamsForLanguageFields(Entity it) '''IF hasLanguageFieldsEntityFOR field : getLanguageFieldsEntityval fieldName = field.name.formatForCode fieldName=$fieldNameENDFORENDIF'''
    def private sortParamsForLocaleFields(Entity it) '''IF hasLocaleFieldsEntityFOR field : getLocaleFieldsEntityval fieldName = field.name.formatForCode fieldName=$fieldNameENDFORENDIF'''
    def private sortParamsForBooleanFields(Entity it) '''IF hasBooleanFieldsEntityFOR field : getBooleanFieldsEntityval fieldName = field.name.formatForCode fieldName=$fieldNameENDFORENDIF'''

    def private displayEntry(Object it, Boolean useTarget) '''
        val cssClass = entryContainerCssClass
        IF listType != 3
            <listType.asItemTagIF cssClass != '' class="cssClass"ENDIF>
        ELSE
            <td headers="hmarkupIdCode(useTarget)" class="z-alignmentIF cssClass != '' cssClassENDIF">
        ENDIF
            displayEntryInner(useTarget)
        </listType.asItemTag>
    '''

    def private dispatch entryContainerCssClass(Object it) {
        return ''
    }
    def private dispatch entryContainerCssClass(ListField it) {
        if (name == 'workflowState') {
            if (entity.container.application.targets('1.3.5')) {
                'z-nowrap'
            } else {
                'nowrap'
            }
        } else ''
    }

    def private dispatch displayEntryInner(Object it, Boolean useTarget) {
    }

    def private dispatch displayEntryInner(DerivedField it, Boolean useTarget) '''
        IF newArrayList('name', 'title').contains(name)
            IF entity.hasActions('display')
                IF entity.container.application.targets('1.3.5')
                    <a href="{modurl modname='entity.container.application.appName' type=$lct func='display' ot='entity.name.formatForCode' entity.routeParamsLegacy(entity.name.formatForCode, true, true)}" title="{gt text='View detail page'}">displayLeadingEntry</a>
                ELSE
                    <a href="{route name='entity.container.application.appName.formatForDB_entity.name.formatForCode_display' entity.routeParams(entity.name.formatForCode, true) lct=$lct}" title="{gt text='View detail page'}">displayLeadingEntry</a>
                ENDIF
            ELSE
                displayLeadingEntry
            ENDIF
        ELSEIF name == 'workflowState'
            {$entity.name.formatForCode.workflowState|entity.container.application.appName.formatForDBObjectState}
        ELSE
            fieldHelper.displayField(it, entity.name.formatForCode, 'view')
        ENDIF
    '''

    def private displayLeadingEntry(DerivedField it) '''{$entity.name.formatForCode.name.formatForCode|notifyfilters:'entity.container.application.appName.formatForDB.filterhook.entity.nameMultiple.formatForDB'}'''

    def private dispatch displayEntryInner(JoinRelationship it, Boolean useTarget) '''
        val relationAliasName = getRelationAliasName(useTarget).formatForCodeCapital
        val mainEntity = (if (!useTarget) target else source)
        val linkEntity = (if (useTarget) target else source)
        var relObjName = mainEntity.name.formatForCode + '.' + relationAliasName
        {if isset($relObjName) && $relObjName ne null}
            IF linkEntity.hasActions('display')
                IF container.application.targets('1.3.5')
                    <a href="{modurl modname='linkEntity.container.application.appName' type=$lct func='display' ot='linkEntity.name.formatForCode' linkEntity.routeParamsLegacy(relObjName, true, true)}">{strip}
                ELSE
                    <a href="{route name='linkEntity.container.application.appName.formatForDB_linkEntity.name.formatForCode_display' linkEntity.routeParams(relObjName, true) lct=$lct}">{strip}
                ENDIF
            ENDIF
              {$relObjName->getTitleFromDisplayPattern()|default:""}
            IF linkEntity.hasActions('display')
                {/strip}</a>
                IF container.application.targets('1.3.5')
                    <a id="linkEntity.name.formatForCodeItemFOR pkField : mainEntity.getPrimaryKeyFields SEPARATOR '_'{$mainEntity.name.formatForCode.pkField.name.formatForCode}ENDFOR_rel_FOR pkField : linkEntity.getPrimaryKeyFields SEPARATOR '_'{$relObjName.pkField.name.formatForCode}ENDFORDisplay" href="{modurl modname='container.application.appName' type=$lct func='display' ot='linkEntity.name.formatForCode' linkEntity.routeParamsLegacy(relObjName, true, true) theme='Printer' forcelongurl=true}" title="{gt text='Open quick view window'}" class="z-hide">{icon type='view' size='extrasmall' __alt='Quick view'}</a>
                ELSE
                    <a id="linkEntity.name.formatForCodeItemFOR pkField : mainEntity.getPrimaryKeyFields SEPARATOR '_'{$mainEntity.name.formatForCode.pkField.name.formatForCode}ENDFOR_rel_FOR pkField : linkEntity.getPrimaryKeyFields SEPARATOR '_'{$relObjName.pkField.name.formatForCode}ENDFORDisplay" href="{route name='container.application.appName.formatForDB_linkEntity.name.formatForCode_display' linkEntity.routeParams(relObjName, true) lct=$lct theme='Printer'}" title="{gt text='Open quick view window'}" class="fa fa-search-plus hidden"></a>
                ENDIF
                <script type="text/javascript">
                /* <![CDATA[ */
                    IF container.application.targets('1.3.5')
                        document.observe('dom:loaded', function() {
                            container.application.prefix()InitInlineWindow($('linkEntity.name.formatForCodeItemFOR pkField : mainEntity.getPrimaryKeyFields SEPARATOR '_'{{$mainEntity.name.formatForCode.pkField.name.formatForCode}}ENDFOR_rel_FOR pkField : linkEntity.getPrimaryKeyFields SEPARATOR '_'{{$relObjName.pkField.name.formatForCode}}ENDFORDisplay'), '{{$relObjName->getTitleFromDisplayPattern()|replace:"'":""}}');
                        });
                    ELSE
                        ( function($) {
                            $(document).ready(function() {
                                container.application.prefix()InitInlineWindow($('#linkEntity.name.formatForCodeItemFOR pkField : mainEntity.getPrimaryKeyFields SEPARATOR '_'{{$mainEntity.name.formatForCode.pkField.name.formatForCode}}ENDFOR_rel_FOR pkField : linkEntity.getPrimaryKeyFields SEPARATOR '_'{{$relObjName.pkField.name.formatForCode}}ENDFORDisplay'), '{{$relObjName->getTitleFromDisplayPattern()|replace:"'":""}}');
                            });
                        })(jQuery);
                    ENDIF
                /* ]]> */
                </script>
            ENDIF
        {else}
            {gt text='Not set.'}
        {/if}
    '''

    def private dispatch markupIdCode(Object it, Boolean useTarget) {
    }
    def private dispatch markupIdCode(NamedObject it, Boolean useTarget) {
        name.formatForCodeCapital
    }
    def private dispatch markupIdCode(DerivedField it, Boolean useTarget) {
        name.formatForCodeCapital
    }
    def private dispatch markupIdCode(JoinRelationship it, Boolean useTarget) {
        getRelationAliasName(useTarget).toFirstUpper
    }

    def private alignment(Object it) {
        switch it {
            BooleanField: 'center'
            IntegerField: 'right'
            DecimalField: 'right'
            FloatField: 'right'
            default: 'left'
        }
    }

    def private itemActions(Entity it, String appName) '''
        IF listType != 3
            <listType.asItemTag>
        ELSE
            <td id="new ItemActionsView().itemActionContainerViewId(it)" headers="hItemActions" class="IF container.application.targets('1.3.5')z-right z-nowrapELSEactions nowrapENDIF z-w02">
        ENDIF
            new ItemActionsView().generate(it, 'view')
        </listType.asItemTag>
    '''

    def private asListTag (Integer listType) {
        switch listType {
            case 0: 'ul'
            case 1: 'ol'
            case 2: 'dl'
            case 3: 'table'
        }
    }

    def private asItemTag (Integer listType) {
        switch listType {
            case 0: 'li' // ul
            case 1: 'li' // ol
            case 2: 'dd' // dl
            case 3: 'td' // table
        }
    }
}
