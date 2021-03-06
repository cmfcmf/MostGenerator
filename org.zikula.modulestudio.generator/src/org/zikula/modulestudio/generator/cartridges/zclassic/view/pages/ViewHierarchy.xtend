package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages

import de.guite.modulestudio.metamodel.modulestudio.Entity
import de.guite.modulestudio.metamodel.modulestudio.EntityWorkflowType
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ViewHierarchy {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate(Entity it, String appName, IFileSystemAccess fsa) {
        println('Generating tree view templates for entity "' + name.formatForDisplay + '"')
        var templateFilePath = templateFile('view_tree')
        if (!container.application.shouldBeSkipped(templateFilePath)) {
            fsa.generateFile(templateFilePath, hierarchyView(appName))
        }
        templateFilePath = templateFile('view_tree_items')
        if (!container.application.shouldBeSkipped(templateFilePath)) {
            fsa.generateFile(templateFilePath, hierarchyItemsView(appName))
        }
    }

    def private hierarchyView(Entity it, String appName) '''
        val objName = name.formatForCode
        val appPrefix = container.application.prefix()
        {* purpose of this template: nameMultiple.formatForDisplay tree view *}
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
        <div class="appName.toLowerCase-name.formatForDB appName.toLowerCase-viewhierarchy">
            {gt text='name.formatForDisplayCapital hierarchy' assign='templateTitle'}
            {pagesetvar name='title' value=$templateTitle}
            templateHeader

            IF documentation !== null && documentation != ''
                <p class="IF isLegacyAppz-informationmsgELSEalert alert-infoENDIF">documentation</p>
            ENDIF

            <p>
            IF hasActions('edit')
                {checkpermissionblock component='appName:name.formatForCodeCapital:' instance='::' level='ACCESS_IF workflow == EntityWorkflowType::NONEEDITELSECOMMENTENDIF'}
                    {gt text='Add root node' assign='addRootTitle'}
                    <a id="treeAddRoot" href="javascript:void(0)" title="{$addRootTitle}" class="IF isLegacyAppz-icon-es-add z-hideELSEfa fa-plus hiddenENDIF">{$addRootTitle}</a>

                    <script type="text/javascript">
                    /* <![CDATA[ */
                    IF isLegacyApp
                        document.observe('dom:loaded', function() {
                            $('treeAddRoot').observe('click', function(event) {
                                appPrefixPerformTreeOperation('objName', 1, 'addRootNode');
                                Event.stop(event);
                            }).removeClassName('z-hide');
                        });
                    ELSE
                        ( function($) {
                            $(document).ready(function() {
                                $('#treeAddRoot').click( function(event) {
                                    appPrefixPerformTreeOperation('objName', 1, 'addRootNode');
                                    event.stopPropagation();
                                }).removeClass('hidden');
                            });
                        })(jQuery);
                    ENDIF
                    /* ]]> */
                    </script>
                    <noscript><p>{gt text='This function requires JavaScript activated!'}</p></noscript>
                {/checkpermissionblock}
            ENDIF
                {gt text='Switch to table view' assign='switchTitle'}
                IF isLegacyApp
                    <a href="{modurl modname='appName' type=$lct func='view' ot='objName'}" title="{$switchTitle}" class="z-icon-es-view">{$switchTitle}</a>
                ELSE
                    <a href="{route name='appName.formatForDB_objName_view' lct=$lct}" title="{$switchTitle}" class="fa fa-table">{$switchTitle}</a>
                ENDIF
            </p>

            {foreach key='rootId' item='treeNodes' from=$trees}
                {include file='IF isLegacyAppobjNameELSEname.formatForCodeCapitalENDIF/view_tree_items.tpl' lct=$lct rootId=$rootId items=$treeNodes}
            {foreachelse}
                {include file='IF isLegacyAppobjNameELSEname.formatForCodeCapitalENDIF/view_tree_items.tpl' lct=$lct rootId=1 items=null}
            {/foreach}

            <br style="clear: left" />
        </div>
        IF isLegacyApp
            {include file="`$lct`/footer.tpl"}
        ELSE
            {include file="`$lctUc`/footer.tpl"}
        ENDIF
    '''

    def private templateHeader(Entity it) '''
        {if $lct eq 'admin'}
            IF isLegacyApp
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

    def private hierarchyItemsView(Entity it, String appName) '''
        val appPrefix = container.application.prefix()
        {* purpose of this template: nameMultiple.formatForDisplay tree items *}
        {assign var='hasNodes' value=false}
        {if isset($items) && (is_object($items) && $items->count() gt 0) || (is_array($items) && count($items) gt 0)}
            {assign var='hasNodes' value=true}
        {/if}
        {assign var='idPrefix' value="name.formatForCode.toFirstLowerTree`$rootId`"}

        IF !isLegacyApp
            <p>
                <label for="{$idPrefix}SearchTerm">{gt text='Quick search'}:</label>
                <input type="search" id="{$idPrefix}SearchTerm" value="" />
            </p>
        ENDIF
        <div id="{$idPrefix}" class="IF isLegacyAppz-ENDIFtree-container">
            IF isLegacyApp
                <div id="name.formatForCode.toFirstLowerTreeItems{$rootId}" class="IF isLegacyAppz-ENDIFtree-items">
                {if $hasNodes}
                    {appName.formatForDBTreeData objectType='name.formatForCode' tree=$items controller=$lct root=$rootId sortable=true}
                {/if}
                </div>
            ELSE
                {if $hasNodes}
                    <ul id="itemTree{$rootId}">
                        {appName.formatForDBTreeData objectType='name.formatForCode' tree=$items controller=$lct root=$rootId}
                    </ul>
                {/if}
            ENDIF
        </div>

        {if $hasNodes}
            {pageaddvar name='javascript' value='container.application.rootFolder/IF isLegacyAppappName/javascript/ELSEcontainer.application.getAppJsPathENDIFappNameIF isLegacyApp_tELSE.TENDIFree.js'}
            IF !isLegacyApp
                {pageaddvar name='javascript' value='web/jstree/dist/jstree.min.js'}
                {pageaddvar name='stylesheet' value='web/jstree/dist/themes/default/style.min.css'}
            ENDIF
            <script type="text/javascript">
            /* <![CDATA[ */
                IF isLegacyApp
                    document.observe('dom:loaded', function() {
                        appPrefixInitTreeNodes('name.formatForCode', '{{$rootId}}', hasActions('display').displayBool, (hasActions('edit') && !readOnly).displayBool);
                        Zikula.TreeSortable.trees.itemTree{{$rootId}}.config.onSave = appPrefixTreeSave;
                    });
                ELSE
                    ( function($) {
                        $(document).ready(function() {
                            appPrefixInitTreeNodes('name.formatForCode', '{{$rootId}}', hasActions('display').displayBool, (hasActions('edit') && !readOnly).displayBool);

                            var tree = $('#{{$idPrefix}}').jstree({
                                'core': {
                                    'multiple': false,
                                    'check_callback': true
                                },
                                'dnd': {
                                    'copy': false,
                                    'is_draggable': function(node) {
                                        // disable drag and drop for root category
                                        var inst = node.inst;
                                        var level = inst.get_path().length;

                                        return (level > 1) ? true : false;
                                    }
                                },
                                'state': {
                                    'key': '{{$idPrefix}}'
                                },
                                'plugins': [ 'dnd', 'search', 'state', 'wholerow' ]
                            });

                            tree.on('move_node.jstree', function (e, data) {
                                var node = data.node;
                                var parentId = data.parent;
                                var parentNode = $tree.jstree('get_node', parentId, false);

                                appPrefixTreeSave(node, parentNode, 'bottom');
                            });

                            var searchStartDelay = false;
                            $('#{{$idPrefix}}SearchTerm').keyup(function () {
                                if (searchStartDelay) {
                                    clearTimeout(to);
                                }
                                searchStartDelay = setTimeout(function () {
                                    var v = $('#{{$idPrefix}}SearchTerm').val();
                                    $('#{{$idPrefix}}').jstree(true).search(v);
                                }, 250);
                            });

                            $('.dropdown-toggle').dropdown();
                        });
                    })(jQuery);
                ENDIF
            /* ]]> */
            </script>
            <noscript><p>{gt text='This function requires JavaScript activated!'}</p></noscript>
        {/if}
    '''

    def private isLegacyApp(Entity it) {
        container.application.targets('1.3.5')
    }
}
