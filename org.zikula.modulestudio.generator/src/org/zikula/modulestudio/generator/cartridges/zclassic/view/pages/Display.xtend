package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages

import de.guite.modulestudio.metamodel.modulestudio.DerivedField
import de.guite.modulestudio.metamodel.modulestudio.Entity
import de.guite.modulestudio.metamodel.modulestudio.EntityTreeType
import de.guite.modulestudio.metamodel.modulestudio.JoinRelationship
import de.guite.modulestudio.metamodel.modulestudio.ManyToManyRelationship
import de.guite.modulestudio.metamodel.modulestudio.OneToManyRelationship
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents.ItemActionsView
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents.Relations
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents.SimpleFields
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.UrlExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.ViewExtensions
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions

class Display {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension NamingExtensions = new NamingExtensions
    extension UrlExtensions = new UrlExtensions
    extension Utils = new Utils
    extension ViewExtensions = new ViewExtensions
    extension WorkflowExtensions = new WorkflowExtensions

    def generate(Entity it, String appName, IFileSystemAccess fsa) {
        println('Generating display templates for entity "' + name.formatForDisplay + '"')
        var templateFilePath = templateFile('display')
        if (!container.application.shouldBeSkipped(templateFilePath)) {
            fsa.generateFile(templateFilePath, displayView(appName))
        }
        if (tree != EntityTreeType::NONE) {
            templateFilePath = templateFile('display_treeRelatives')
            if (!container.application.shouldBeSkipped(templateFilePath)) {
                fsa.generateFile(templateFilePath, treeRelatives(appName))
            }
        }
    }

    def private displayView(Entity it, String appName) '''
        {* purpose of this template: nameMultiple.formatForDisplay display view *}
        {assign var='lct' value='user'}
        {if isset($smarty.get.lct) && $smarty.get.lct eq 'admin'}
            {assign var='lct' value='admin'}
        {/if}
        IF isLegacyApp
            {include file="`$lct`/header.tpl"}
        ELSE
            {assign var='lctUc' value=$lct|ucfirst}
            {include file="`$lctUc`/header.tpl"}
        ENDIF
        val refedElems = getOutgoingJoinRelations.filter[e|e.target.container.application == it.container.application] + incoming.filter(ManyToManyRelationship).filter[e|e.source.container.application == it.container.application]
        <div class="appName.toLowerCase-name.formatForDB appName.toLowerCase-displayIF !refedElems.empty with-rightboxENDIF">
            val objName = name.formatForCode
            {gt text='name.formatForDisplayCapital' assign='templateTitle'}
            {assign var='templateTitle' value=$objName->getTitleFromDisplayPattern()|default:$templateTitle}
            {pagesetvar name='title' value=$templateTitle|@html_entity_decode}
            templateHeader(appName)
            IF !refedElems.empty

                {if !isset($smarty.get.theme) || $smarty.get.theme ne 'Printer'}
                    <div class="appName.toLowerCase-rightbox">
                        val relationHelper = new Relations
                        FOR elem : refedElemsrelationHelper.displayRelatedItems(elem, appName, it)ENDFOR
                    </div>
                {/if}
            ENDIF
            IF useGroupingPanels('display')

            {if !isset($smarty.get.theme) || $smarty.get.theme ne 'Printer'}
                IF isLegacyApp
                    <div id="appName.toFirstLowerPanel" class="z-panels">
                        <h3 id="z-panel-header-fields" class="z-panel-header z-panel-indicator IF isLegacyAppzELSEcursorENDIF-pointer z-panel-active">{gt text='Fields'}</h3>
                        <div class="z-panel-content z-panel-active" style="overflow: visible">
                ELSE
                    <div class="panel-group" id="accordion">
                        <div class="panel panel-default">
                            <div class="panel-heading">
                                <h3 class="panel-title"><a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#collapseFields">{gt text='Fields'}</a></h3>
                            </div>
                            <div id="collapseFields" class="panel-collapse collapse in">
                                <div class="panel-body">
                ENDIF
            {/if}
            ENDIF

            fieldDetails(appName)
            IF useGroupingPanels('display')
            {if !isset($smarty.get.theme) || $smarty.get.theme ne 'Printer'}
                IF isLegacyApp
                    </div>/* fields panel */
                ELSE
                            </div>
                        </div>
                    </div>
                ENDIF
            {/if}
            ENDIF
            displayExtensions(objName)

            {if !isset($smarty.get.theme) || $smarty.get.theme ne 'Printer'}
                callDisplayHooks(appName)
                new ItemActionsView().generate(it, 'display')
                IF useGroupingPanels('display')
                    </div>/* panels */
                ENDIF
                IF !refedElems.empty
                    <br style="clear: right" />
                ENDIF
            {/if}
        </div>
        IF isLegacyApp
            {include file="`$lct`/footer.tpl"}
        ELSE
            {include file="`$lctUc`/footer.tpl"}
        ENDIF
        IF hasBooleansWithAjaxToggleEntity || (useGroupingPanels('display') && isLegacyApp)

        {if !isset($smarty.get.theme) || $smarty.get.theme ne 'Printer'}
            <script type="text/javascript">
            /* <![CDATA[ */
                IF isLegacyApp
                    document.observe('dom:loaded', function() {
                        initAjaxToggle
                        IF useGroupingPanels('display')
                            var panel = new Zikula.UI.Panels('appName.toFirstLowerPanel', {
                                headerSelector: 'h3',
                                headerClassName: 'z-panel-header z-panel-indicator',
                                contentClassName: 'z-panel-content',
                                active: $('z-panel-header-fields')
                            });
                        ENDIF
                    });
                ELSE
                    ( function($) {
                        $(document).ready(function() {
                            initAjaxToggle
                        });
                    })(jQuery);
                ENDIF
            /* ]]> */
            </script>
        {/if}
        ENDIF
    '''

    def private initAjaxToggle(Entity it) '''
        IF hasBooleansWithAjaxToggleEntity
            {{assign var='itemid' value=$name.formatForCode.getFirstPrimaryKey.name.formatForCode}}
            FOR field : getBooleansWithAjaxToggleEntity
                container.application.prefix()InitToggle('name.formatForCode', 'field.name.formatForCode', '{{$itemid}}');
            ENDFOR
        ENDIF
    '''

    def private fieldDetails(Entity it, String appName) '''
        <dl>
            FOR field : getDisplayFieldsfield.displayEntryENDFOR
            IF geographical
                FOR geoFieldName : newArrayList('latitude', 'longitude')
                    <dt>{gt text='geoFieldName.toFirstUpper'}</dt>
                    <dd>{$name.formatForCode.geoFieldName|appName.formatForDBFormatGeoData}</dd>
                ENDFOR
            ENDIF
            IF softDeleteable
                <dt>{gt text='Deleted at'}</dt>
                <dd>{$name.formatForCode.deletedAt|dateformat:'datebrief'}</dd>
            ENDIF
            FOR relation : incoming.filter(OneToManyRelationship).filter[bidirectional]relation.displayEntry(false)ENDFOR
            /*FOR relation : outgoing.filter[OneToOneRelationship)relation.displayEntry(true)ENDFOR*/
        </dl>
    '''

    def private templateHeader(Entity it, String appName) '''
        {if $lct eq 'admin'}
            IF isLegacyApp
                <div class="z-admin-content-pagetitle">
                    {icon type='display' size='small' __alt='Details'}
                    <h3>templateHeading(appName)</h3>
                </div>
            ELSE
                <h3>
                    <span class="fa fa-eye"></span>
                    templateHeading(appName)
                </h3>
            ENDIF
        {else}
            <h2>templateHeading(appName)</h2>
        {/if}
    '''

    def private templateHeading(Entity it, String appName) '''{$templateTitle|notifyfilters:'appName.formatForDB.filter_hooks.nameMultiple.formatForDB.filter'}IF hasVisibleWorkflow <small>({$name.formatForCode.workflowState|appName.formatForDBObjectState:false|lower})</small>ENDIFnew ItemActionsView().trigger(it, 'display')'''

    def private displayEntry(DerivedField it) '''
        val fieldLabel = if (name == 'workflowState') 'state' else name
        <dt>{gt text='fieldLabel.formatForDisplayCapital'}</dt>
        <dd>displayEntryImpl</dd>
    '''

    def private displayEntryImpl(DerivedField it) {
        new SimpleFields().displayField(it, entity.name.formatForCode, 'display')
    }

    def private displayEntry(JoinRelationship it, Boolean useTarget) '''
        val relationAliasName = getRelationAliasName(useTarget).formatForCodeCapital
        val mainEntity = (if (useTarget) source else target)
        val linkEntity = (if (useTarget) target else source)
        val relObjName = mainEntity.name.formatForCode + '.' + relationAliasName
        <dt>{gt text='relationAliasName.formatForDisplayCapital'}</dt>
        <dd>
        {if isset($relObjName) && $relObjName ne null}
          {if !isset($smarty.get.theme) || $smarty.get.theme ne 'Printer'}
          IF linkEntity.hasActions('display')
              IF linkEntity.isLegacyApp
                  <a href="{modurl modname='linkEntity.container.application.appName' type=$lct func='display' ot='linkEntity.name.formatForCode' linkEntity.routeParamsLegacy(relObjName, true, true)}">{strip}
              ELSE
                  <a href="{route name='linkEntity.container.application.appName.formatForDB_linkEntity.name.formatForCode_display' linkEntity.routeParams(relObjName, true) lct=$lct}">{strip}
              ENDIF
          ENDIF
            {$relObjName->getTitleFromDisplayPattern()|default:""}
          IF linkEntity.hasActions('display')
            {/strip}</a>
            IF linkEntity.isLegacyApp
                <a id="linkEntity.name.formatForCodeItemFOR pkField : linkEntity.getPrimaryKeyFields{$relObjName.pkField.name.formatForCode}ENDFORDisplay" href="{modurl modname='linkEntity.container.application.appName' type=$lct func='display' ot='linkEntity.name.formatForCode' linkEntity.routeParamsLegacy(relObjName, true, true)' theme='Printer' forcelongurl=true}" title="{gt text='Open quick view window'}" class="z-hide">{icon type='view' size='extrasmall' __alt='Quick view'}</a>
            ELSE
                <a id="linkEntity.name.formatForCodeItemFOR pkField : linkEntity.getPrimaryKeyFields{$relObjName.pkField.name.formatForCode}ENDFORDisplay" href="{route name='linkEntity.container.application.appName.formatForDB_linkEntity.name.formatForCode_display' linkEntity.routeParams(relObjName, true) lct=$lct theme='Printer'}" title="{gt text='Open quick view window'}" class="fa fa-search-plus hidden"></a>
            ENDIF
            <script type="text/javascript">
            /* <![CDATA[ */
                IF linkEntity.isLegacyApp
                    document.observe('dom:loaded', function() {
                        container.application.prefix()InitInlineWindow($('linkEntity.name.formatForCodeItemFOR pkField : linkEntity.getPrimaryKeyFields SEPARATOR '_'{{$relObjName.pkField.name.formatForCode}}ENDFORDisplay'), '{{$relObjName->getTitleFromDisplayPattern()|replace:"'":""}}');
                    });
                ELSE
                    ( function($) {
                        $(document).ready(function() {
                            container.application.prefix()InitInlineWindow($('#linkEntity.name.formatForCodeItemFOR pkField : linkEntity.getPrimaryKeyFields SEPARATOR '_'{{$relObjName.pkField.name.formatForCode}}ENDFORDisplay'), '{{$relObjName->getTitleFromDisplayPattern()|replace:"'":""}}');
                        });
                    })(jQuery);
                ENDIF
            /* ]]> */
            </script>
          ENDIF
          {else}
            {$relObjName->getTitleFromDisplayPattern()|default:""}
          {/if}
        {else}
            {gt text='Not set.'}
        {/if}
        </dd>
    '''

    def private displayExtensions(Entity it, String objName) '''
        IF geographical
            IF useGroupingPanels('display')
                IF isLegacyApp
                    <h3 class="container.application.appName.toLowerCase-map z-panel-header z-panel-indicator IF isLegacyAppzELSEcursorENDIF-pointer">{gt text='Map'}</h3>
                    <div class="container.application.appName.toLowerCase-map z-panel-content" style="display: none">
                ELSE
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            <h3 class="panel-title"><a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#collapseMap">{gt text='Map'}</a></h3>
                        </div>
                        <div id="collapseMap" class="panel-collapse collapse in">
                            <div class="panel-body">
                ENDIF
            ELSE
                <h3 class="container.application.appName.toLowerCase-map">{gt text='Map'}</h3>
            ENDIF
            {pageaddvarblock name='header'}
                <script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor=false"></script>
                <script type="text/javascript" src="{$baseurl}plugins/Mapstraction/lib/vendor/mxn/mxn.js?(googlev3)"></script>
                <script type="text/javascript">
                /* <![CDATA[ */
                    var mapstraction;
                    IF isLegacyApp
                        Event.observe(window, 'load', function() {
                            initGeographical(objName)
                        });
                    ELSE
                        ( function($) {
                            $(document).ready(function() {
                                initGeographical(objName)
                            });
                        })(jQuery);
                    ENDIF
                /* ]]> */
                </script>
            {/pageaddvarblock}
            <div id="mapContainer" class="container.application.appName.toLowerCase-mapcontainer">
            </div>
            IF useGroupingPanels('display')
                IF isLegacyApp
                    </div>
                ELSE
                            </div>
                        </div>
                    </div>
                ENDIF
            ENDIF
        ENDIF
        IF attributable
            {include file='IF isLegacyApphelperELSEHelperENDIF/include_attributes_display.tpl' obj=$objNameIF useGroupingPanels('display') panel=trueENDIF}
        ENDIF
        IF categorisable
            {include file='IF isLegacyApphelperELSEHelperENDIF/include_categories_display.tpl' obj=$objNameIF useGroupingPanels('display') panel=trueENDIF}
        ENDIF
        IF tree != EntityTreeType::NONE
            IF useGroupingPanels('display')
                IF isLegacyApp
                    <h3 class="relatives z-panel-header z-panel-indicator IF isLegacyAppzELSEcursorENDIF-pointer">{gt text='Relatives'}</h3>
                    <div class="relatives z-panel-content" style="display: none">
                ELSE
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            <h3 class="panel-title"><a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#collapseRelatives">{gt text='Relatives'}</a></h3>
                        </div>
                        <div id="collapseRelatives" class="panel-collapse collapse in">
                            <div class="panel-body">
                ENDIF
            ELSE
                <h3 class="relatives">{gt text='Relatives'}</h3>
            ENDIF
                    {include file='IF isLegacyAppname.formatForCodeELSEname.formatForCodeCapitalENDIF/display_treeRelatives.tpl' allParents=true directParent=true allChildren=true directChildren=true predecessors=true successors=true preandsuccessors=true}
            IF useGroupingPanels('display')
                IF isLegacyApp
                    </div>
                ELSE
                            </div>
                        </div>
                    </div>
                ENDIF
            ENDIF
        ENDIF
        IF metaData
            {include file='IF isLegacyApphelperELSEHelperENDIF/include_metadata_display.tpl' obj=$objNameIF useGroupingPanels('display') panel=trueENDIF}
        ENDIF
        IF standardFields
            {include file='IF isLegacyApphelperELSEHelperENDIF/include_standardfields_display.tpl' obj=$objNameIF useGroupingPanels('display') panel=trueENDIF}
        ENDIF
    '''

    def private initGeographical(Entity it, String objName) '''
        mapstraction = new mxn.Mapstraction('mapContainer', 'googlev3');
        mapstraction.addControls({
            pan: true,
            zoom: 'small',
            map_type: true
        });

        var latlon = new mxn.LatLonPoint({{$objName.latitude|container.application.name.formatForDBFormatGeoData}}, {{$objName.longitude|container.application.name.formatForDBFormatGeoData}});

        mapstraction.setMapType(mxn.Mapstraction.SATELLITE);
        mapstraction.setCenterAndZoom(latlon, 18);
        mapstraction.mousePosition('position');

        // add a marker
        var marker = new mxn.Marker(latlon);
        mapstraction.addMarker(marker, true);
        IF !isLegacyApp

            $('#collapseMap').on('hidden.bs.collapse', function () {
                // redraw the map after it's panel has been opened (see also #340)
                mapstraction.resizeTo($('#mapContainer').width(), $('#mapContainer').height());
            })
        ENDIF
    '''

    def private callDisplayHooks(Entity it, String appName) '''
        {* include display hooks *}
        {notifydisplayhooks eventname='appName.formatForDB.ui_hooks.nameMultiple.formatForDB.display_view' id=displayHookId urlobject=$currentUrlObject assign='hooks'}
        {foreach name='hookLoop' key='providerArea' item='hook' from=$hooks}
            IF useGroupingPanels('display')
                IF isLegacyApp
                    <h3 class="z-panel-header z-panel-indicator IF isLegacyAppzELSEcursorENDIF-pointer">{$providerArea}</h3>
                    <div class="z-panel-content" style="display: none">
                        {$hook}
                    </div>
                ELSE
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            <h3 class="panel-title"><a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#collapseHook{$smarty.foreach.hookLoop.iteration}">{$providerArea}</a></h3>
                        </div>
                        <div id="collapseHook{$smarty.foreach.hookLoop.iteration}" class="panel-collapse collapse in">
                            <div class="panel-body">
                                {$hook}
                            </div>
                        </div>
                    </div>
                ENDIF
            ELSE
                {$hook}
            ENDIF
        {/foreach}
    '''

    def private displayHookId(Entity it) '''IF !hasCompositeKeys$name.formatForCode.getFirstPrimaryKey.name.formatForCodeELSE"FOR pkField : getPrimaryKeyFields SEPARATOR '_'`$name.formatForCode.pkField.name.formatForCode`ENDFOR"ENDIF'''

    def private treeRelatives(Entity it, String appName) '''
        val objName = name.formatForCode
        val pluginPrefix = container.application.appName.formatForDB
        {* purpose of this template: show different forms of relatives for a given tree node *}
        <h3>{gt text='Related nameMultiple.formatForDisplay'}</h3>
        {if $objName.lvl gt 0}
            {if !isset($allParents) || $allParents eq true}
                {pluginPrefixTreeSelection objectType='objName' node=$objName target='allParents' assign='allParents'}
                {if $allParents ne null && count($allParents) gt 0}
                    <h4>{gt text='All parents'}</h4>
                    nodeLoop(appName, 'allParents')
                    {foreach item='node' from=$allParents}
                {/if}
            {/if}
            {if !isset($directParent) || $directParent eq true}
                {pluginPrefixTreeSelection objectType='objName' node=$objName target='directParent' assign='directParent'}
                {if $directParent ne null}
                    <h4>{gt text='Direct parent'}</h4>
                    <ul>
                        IF isLegacyApp
                            <li><a href="{modurl modname='appName' type=$lct func='display' ot='objName' routeParamsLegacy('directParent', true, true)}" title="{$directParent->getTitleFromDisplayPattern()|replace:'"':''}">{$directParent->getTitleFromDisplayPattern()}</a></li>
                        ELSE
                            <li><a href="{route name='appName.formatForDB_objName_display' routeParams('directParent', true) lct=$lct}" title="{$directParent->getTitleFromDisplayPattern()|replace:'"':''}">{$directParent->getTitleFromDisplayPattern()}</a></li>
                        ENDIF
                    </ul>
                {/if}
            {/if}
        {/if}
        {if !isset($allChildren) || $allChildren eq true}
            {pluginPrefixTreeSelection objectType='objName' node=$objName target='allChildren' assign='allChildren'}
            {if $allChildren ne null && count($allChildren) gt 0}
                <h4>{gt text='All children'}</h4>
                nodeLoop(appName, 'allChildren')
            {/if}
        {/if}
        {if !isset($directChildren) || $directChildren eq true}
            {pluginPrefixTreeSelection objectType='objName' node=$objName target='directChildren' assign='directChildren'}
            {if $directChildren ne null && count($directChildren) gt 0}
                <h4>{gt text='Direct children'}</h4>
                nodeLoop(appName, 'directChildren')
            {/if}
        {/if}
        {if $objName.lvl gt 0}
            {if !isset($predecessors) || $predecessors eq true}
                {pluginPrefixTreeSelection objectType='objName' node=$objName target='predecessors' assign='predecessors'}
                {if $predecessors ne null && count($predecessors) gt 0}
                    <h4>{gt text='Predecessors'}</h4>
                    nodeLoop(appName, 'predecessors')
                {/if}
            {/if}
            {if !isset($successors) || $successors eq true}
                {pluginPrefixTreeSelection objectType='objName' node=$objName target='successors' assign='successors'}
                {if $successors ne null && count($successors) gt 0}
                    <h4>{gt text='Successors'}</h4>
                    nodeLoop(appName, 'successors')
                {/if}
            {/if}
            {if !isset($preandsuccessors) || $preandsuccessors eq true}
                {pluginPrefixTreeSelection objectType='objName' node=$objName target='preandsuccessors' assign='preandsuccessors'}
                {if $preandsuccessors ne null && count($preandsuccessors) gt 0}
                    <h4>{gt text='Siblings'}</h4>
                    nodeLoop(appName, 'preandsuccessors')
                {/if}
            {/if}
        {/if}
    '''

    def private nodeLoop(Entity it, String appName, String collectionName) '''
        val objName = name.formatForCode
        <ul>
        {foreach item='node' from=$collectionName}
            IF isLegacyApp
                <li><a href="{modurl modname='appName' type=$lct func='display' ot='objName' routeParamsLegacy('node', true, true)}" title="{$node->getTitleFromDisplayPattern()|replace:'"':''}">{$node->getTitleFromDisplayPattern()}</a></li>
            ELSE
                <li><a href="{route name='appName.formatForDB_objName_display' routeParams('node', true) lct=$lct}" title="{$node->getTitleFromDisplayPattern()|replace:'"':''}">{$node->getTitleFromDisplayPattern()}</a></li>
            ENDIF
        {/foreach}
        </ul>
    '''

    def private isLegacyApp(Entity it) {
        container.application.targets('1.3.5')
    }
}
