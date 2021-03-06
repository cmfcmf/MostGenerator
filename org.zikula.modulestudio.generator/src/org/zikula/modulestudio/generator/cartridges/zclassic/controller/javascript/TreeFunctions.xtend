package org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript

import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class TreeFunctions {
    extension FormattingExtensions = new FormattingExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    /**
     * Entry point for tree-related JavaScript functions.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        var fileName = ''
        if (targets('1.3.5')) {
            fileName = appName + '_tree.js'
        } else {
            fileName = appName + '.Tree.js'
        }
        if (!shouldBeSkipped(getAppJsPath + fileName)) {
            println('Generating JavaScript for tree functions')
            if (shouldBeMarked(getAppJsPath + fileName)) {
                if (targets('1.3.5')) {
                    fileName = appName + '_tree.generated.js'
                } else {
                    fileName = appName + '.Tree.generated.js'
                }
            }
            fsa.generateFile(getAppJsPath + fileName, generate)
        }
    }

    def private generate(Application it) '''
        'use strict';

        var currentNodeId = 0;

        performTreeOperation

        initTreeNodes

        treeSave
    '''

    def private initTreeNodes(Application it) '''
        IF targets('1.3.5')
            var prefix()TreeContextMenu;

            prefix()TreeContextMenu = Class.create(Zikula.UI.ContextMenu, {
                selectMenuItem: function ($super, event, item, item_container) {
                    // open in new tab / window when right-clicked
                    if (event.isRightClick()) {
                        item.callback(this.clicked, true);
                        IF targets('1.3.5')
                            event.stop(); // close the menu
                        ELSE
                            event.stopPropagation(); // close the menu
                        ENDIF
                        return;
                    }
                    // open in current window when left-clicked
                    return $super(event, item, item_container);
                }
            });

        ENDIF
        /**
         * Initialise event handlers for all nodes of a given tree root.
         */
        function prefix()InitTreeNodes(objectType, rootId, hasDisplay, hasEdit)
        {
            IF targets('1.3.5')$ENDIF$('#itemTree' + rootId + ' a').each(function (elem) {
                IF targets('1.3.5')
                    initTreeNodesLegacy
                ELSE
                    initTreeNodesImpl
                ENDIF
            });
        }
    '''

    def private initTreeNodesImpl(Application it) '''
        var liRef, isRoot, contextMenu;

        // get reference to list item
        liRef = elem.parent();
        isRoot = (liRef.attr('id') === 'tree' + rootId + 'node_' + rootId);
        currentNodeId = liRef.attr('id').replace('tree' + rootId + 'node_', '');

        // fill the context menu
        contextMenu = liRef.attr('id') + 'DropDownMenu';

        contextMenu.append(
            listItem = $('<li>', { role: 'presentation', class: 'dropdown-header' }).append(Zikula.__('Basic actions', 'module_appName.formatForDB_js'))
        );

        if (hasDisplay === true) {
            contextMenu.append(
                $('<li>', { role: 'presentation' }).append(
                    $('<a>', { role: 'menuitem', tabindex: '-1', })
                        .attr('href', Zikula.Config.baseURL + 'index.php?module=appName&type=' + objectType + '&func=display&id=' + currentNodeId)
                        /* TODO use routing for creating the url (requires more detailed differentiation of parameters to be provided, e.g. slugs and composite keys) */
                        .append($('<i>', class: 'fa fa-eye' }))
                        .append(Zikula.__('Display', 'module_appName.formatForDB_js'))
                )
            );
        }
        if (hasEdit === true) {
            contextMenu.append(
                $('<li>', { role: 'presentation' }).append(
                    $('<a>', { role: 'menuitem', tabindex: '-1', })
                        .attr('href', Zikula.Config.baseURL + 'index.php?module=appName&type=' + objectType + '&func=edit&id=' + currentNodeId)
                        /* TODO use routing for creating the url (requires more detailed differentiation of parameters to be provided, e.g. slugs and composite keys) */
                        .append($('<i>', class: 'fa fa-pencil-square-o' }))
                        .append(Zikula.__('Edit', 'module_appName.formatForDB_js'))
                )
            );
        }
        contextMenu.append(
            $('<li>', { role: 'presentation' }).append(
                $('<a>', { role: 'menuitem', tabindex: '-1', })
                    .attr('href', '#')
                    .append($('<i>', class: 'fa fa-plus' }))
                    .append(Zikula.__('Add child node', 'module_appName.formatForDB_js'))
                    .click(function (evt) {
                        evt.preventDefault();
                        prefix()PerformTreeOperation(objectType, rootId, 'addChildNode');
                    })
            )
        );
        contextMenu.append({
            $('<li>', { role: 'presentation' }).append(
                $('<a>', { role: 'menuitem', tabindex: '-1', })
                    .attr('href', '#')
                    .append($('<i>', class: 'fa fa-trash-o' }))
                    .append(Zikula.__('Delete node', 'module_appName.formatForDB_js'))
                    .click(function (evt) {
                        var confirmQuestion;

                        evt.preventDefault();
                        confirmQuestion = Zikula.__('Do you really want to remove this node?', 'module_appName.formatForDB_js');
                        if (!liRef.hasClass('z-tree-leaf')) {
                            confirmQuestion = Zikula.__('Do you really want to remove this node including all child nodes?', 'module_appName.formatForDB_js');
                        }
                        if (window.confirm(confirmQuestion) !== false) {
                            prefix()PerformTreeOperation(objectType, rootId, 'deleteNode');
                        }
                    })
            )
        });

        contextMenu.append(
            listItem = $('<li>', { role: 'presentation', class: 'divider' })
        );
        contextMenu.append(
            listItem = $('<li>', { role: 'presentation', class: 'dropdown-header' }).append(Zikula.__('Sorting', 'module_appName.formatForDB_js'))
        );

        if (!isRoot && !liRef.is(':first-child')) { // has previous sibling
            contextMenu.append(
                $('<li>', { role: 'presentation' }).append(
                    $('<a>', { role: 'menuitem', tabindex: '-1', })
                        .attr('href', '#')
                        .append($('<i>', class: 'fa fa-angle-up' }))
                        .append(Zikula.__('Move up', 'module_appName.formatForDB_js'))
                        .click(function (evt) {
                            evt.preventDefault();
                            prefix()PerformTreeOperation(objectType, rootId, 'moveNodeUp');
                        })
                )
            );
        }

        if (!isRoot && !liRef.is(':last-child')) { // has next sibling
            contextMenu.append(
                $('<li>', { role: 'presentation' }).append(
                    $('<a>', { role: 'menuitem', tabindex: '-1', })
                        .attr('href', '#')
                        .append($('<i>', class: 'fa fa-angle-down' }))
                        .append(Zikula.__('Move down', 'module_appName.formatForDB_js'))
                        .click(function (evt) {
                            evt.preventDefault();
                            prefix()PerformTreeOperation(objectType, rootId, 'moveNodeDown');
                        })
                )
            );
        }
    '''

    def private initTreeNodesLegacy(Application it) '''
        var liRef, isRoot, contextMenu;

        // get reference to list item
        liRef = elem.up();
        isRoot = (liRef.id === 'tree' + rootId + 'node_' + rootId);

        // define a link id
        elem.id = liRef.id + 'link';

        // and use it to attach a context menu
        contextMenu = new prefix()TreeContextMenu(elem.id, { leftClick: true, animation: false });
        if (hasDisplay === true) {
            contextMenu.addItem({
                label: '<img src="' + Zikula.Config.baseURL + 'images/icons/extrasmall/kview.png" width="16" height="16" alt="' + Zikula.__('Display', 'module_appName.formatForDB_js') + '" /> '
                     + Zikula.__('Display', 'module_appName.formatForDB_js'),
                callback: function (selectedMenuItem, isRightClick) {
                    var url;

                    currentNodeId = liRef.id.replace('tree' + rootId + 'node_', '');
                    url = Zikula.Config.baseURL + 'index.php?module=appName&type=' + objectType + '&func=display&id=' + currentNodeId;
                    /* TODO use routing for creating the url (requires more detailed differentiation of parameters to be provided, e.g. slugs and composite keys) */

                    if (isRightClick) {
                        window.open(url);
                    } else {
                        window.location = url;
                    }
                }
            });
        }
        if (hasEdit === true) {
            contextMenu.addItem({
                label: '<img src="' + Zikula.Config.baseURL + 'images/icons/extrasmall/edit.png" width="16" height="16" alt="' + Zikula.__('Edit', 'module_appName.formatForDB_js') + '" /> '
                     + Zikula.__('Edit', 'module_appName.formatForDB_js'),
                callback: function (selectedMenuItem, isRightClick) {
                    var url;

                    currentNodeId = liRef.id.replace('tree' + rootId + 'node_', '');
                    url = Zikula.Config.baseURL + 'index.php?module=appName&type=' + objectType + '&func=edit&id=' + currentNodeId;
                    /* TODO use routing for creating the url (requires more detailed differentiation of parameters to be provided, e.g. slugs and composite keys) */

                    if (isRightClick) {
                        window.open(url);
                    } else {
                        window.location = url;
                    }
                }
            });
        }
        contextMenu.addItem({
            label: '<img src="' + Zikula.Config.baseURL + 'images/icons/extrasmall/insert_table_row.png" width="16" height="16" alt="' + Zikula.__('Add child node', 'module_appName.formatForDB_js') + '" /> '
                 + Zikula.__('Add child node', 'module_appName.formatForDB_js'),
            callback: function () {
                currentNodeId = liRef.id.replace('tree' + rootId + 'node_', '');
                prefix()PerformTreeOperation(objectType, rootId, 'addChildNode');
            }
        });
        contextMenu.addItem({
            label: '<img src="' + Zikula.Config.baseURL + 'images/icons/extrasmall/14_layer_deletelayer.png" width="16" height="16" alt="' + Zikula.__('Delete node', 'module_appName.formatForDB_js') + '" /> '
                 + Zikula.__('Delete node', 'module_appName.formatForDB_js'),
            callback: function () {
                var confirmQuestion;

                confirmQuestion = Zikula.__('Do you really want to remove this node?', 'module_appName.formatForDB_js');
                if (!liRef.hasClassName('z-tree-leaf')) {
                    confirmQuestion = Zikula.__('Do you really want to remove this node including all child nodes?', 'module_appName.formatForDB_js');
                }
                if (window.confirm(confirmQuestion) !== false) {
                    currentNodeId = liRef.id.replace('tree' + rootId + 'node_', '');
                    prefix()PerformTreeOperation(objectType, rootId, 'deleteNode');
                }
            }
        });
        contextMenu.addItem({
            label: '<img src="' + Zikula.Config.baseURL + 'images/icons/extrasmall/14_layer_raiselayer.png" width="16" height="16" alt="' + Zikula.__('Move up', 'module_appName.formatForDB_js') + '" /> '
                 + Zikula.__('Move up', 'module_appName.formatForDB_js'),
            condition: function () {
                return !isRoot && !liRef.hasClassName('z-tree-first'); // has previous sibling
            },
            callback: function () {
                currentNodeId = liRef.id.replace('tree' + rootId + 'node_', '');
                prefix()PerformTreeOperation(objectType, rootId, 'moveNodeUp');
            }
        });
        contextMenu.addItem({
            label: '<img src="' + Zikula.Config.baseURL + 'images/icons/extrasmall/14_layer_lowerlayer.png" width="16" height="16" alt="' + Zikula.__('Move down', 'module_appName.formatForDB_js') + '" /> '
                 + Zikula.__('Move down', 'module_appName.formatForDB_js'),
            condition: function () {
                return !isRoot && !liRef.hasClassName('z-tree-last'); // has next sibling
            },
            callback: function () {
                currentNodeId = liRef.attr('id').replace('tree' + rootId + 'node_', '');
                prefix()PerformTreeOperation(objectType, rootId, 'moveNodeDown');
            }
        });
    '''

    def private performTreeOperation(Application it) '''
        /**
         * Helper function to start several different ajax actions
         * performing tree related amendments and operations.
         */
        function prefix()PerformTreeOperation(objectType, rootId, op)
        {
            var opParam, paramsIF targets('1.3.5'), requestENDIF;

            opParam = ((op === 'moveNodeUp' || op === 'moveNodeDown') ? 'moveNode' : op);
            params = 'ot=' + objectType + '&op=' + opParam;

            if (op !== 'addRootNode') {
                params += '&root=' + rootId;

                if (!currentNodeId) {
                    IF targets('1.3.5')
                        Zikula.UI.Alert(Zikula.__('Invalid node id', 'module_appName.formatForDB_js'), Zikula.__('Error', 'module_appName.formatForDB_js'));
                    ELSE
                        prefix()SimpleAlert($('.tree-container'), Zikula.__('Error', 'module_appName.formatForDB_js'), Zikula.__('Invalid node id', 'module_appName.formatForDB_js'), 'treeInvalidNodeAlert', 'danger');
                    ENDIF
                }
                params += '&' + ((op === 'addChildNode') ? 'pid' : 'id') + '=' + currentNodeId;

                if (op === 'moveNodeUp') {
                    params += '&direction=up';
                } else if (op === 'moveNodeDown') {
                    params += '&direction=down';
                }
            }

            IF targets('1.3.5')
                request = new Zikula.Ajax.Request(
                    Zikula.Config.baseURL + 'ajax.php?module=appName&func=handleTreeOperation',
                    {
                        method: 'post',
                        parameters: params,
                        onComplete: function (req) {
                            if (!req.isSuccess()) {
                                Zikula.UI.Alert(req.getMessage(), Zikula.__('Error', 'module_appName.formatForDB_js'));
                                return;
                            }
                            var data = req.getData();
                            /*if (data.message) {
                                Zikula.UI.Alert(data.message, Zikula.__('Success', 'module_appName.formatForDB_js'));
                            }*/
                            window.location.reload();
                        }
                    }
                );
            ELSE
                $.ajax({
                    type: 'POST',
                    url: Routing.generate('appName.formatForDB_ajax_handleTreeOperation'),
                    data: params
                }).done(function(res) {
                    // get data returned by the ajax response
                    var data;

                    data = res.data;

                    /*if (data.message) {
                        prefix()SimpleAlert($('.tree-container'), Zikula.__('Success', 'module_appName.formatForDB_js'), data.message, 'treeAjaxDoneAlert', 'success');
                    }*/

                    window.location.reload();
                }).fail(function(jqXHR, textStatus) {
                    prefix()SimpleAlert($('.tree-container'), Zikula.__('Error', 'module_appName.formatForDB_js'), Zikula.__('Could not persist your change.', 'module_appName.formatForDB_js'), 'treeAjaxFailedAlert', 'danger');
                });
            ENDIF
        }
    '''

    def private treeSave(Application it) '''
        /**
         * Callback function for config.onSave. This function is called after each tree change.
         *
         * @param node - the node which is currently being moved
        IF targets('1.3.5')
            ' '* @param params - array with insertion params, which are [relativenode, dir];
            ' '*     - "dir" is a string with value "after", "before" or "bottom" and defines
            ' '*       whether the affected node is inserted after, before or as last child of "relativenode"
            ' '* @param tree data - serialized to JSON tree data
        ELSE
            ' '* @param parentNode - the new parent node
            ' '* @param position - can be "after", "before" or "bottom" and defines
            ' '*       whether the affected node is inserted after, before or as last child of "relativenode"
        ENDIF
         *
         * @return true on success, otherwise the change will be reverted
         */
        function prefix()TreeSave(node, IF targets('1.3.5')params, dataELSEparentNode, positionENDIF)
        {
            var nodeParts, rootId, nodeId, destId, requestParamsIF targets('1.3.5'), requestENDIF;

            // do not allow inserts on root level
            IF targets('1.3.5')
                if (node.up('li') === undefined) {
                    return false;
                }
            ELSE
                if (node.parents.find('li').size() < 1) {
                    return false;
                }
            ENDIF

            IF targets('1.3.5')
                nodeParts = node.id.split('node_');
                rootId = nodeParts[0].replace('tree', '');
                nodeId = nodeParts[1];
                destId = params[1].id.replace('tree' + rootId + 'node_', '');
            ELSE
                nodeParts = node.attr('id').split('node_');
                rootId = nodeParts[0].replace('tree', '');
                nodeId = nodeParts[1];
                destId = parentNode.attr('id').replace('tree' + rootId + 'node_', '');
            ENDIF

            requestParams = {
                'op': 'moveNodeTo',
                'direction': IF targets('1.3.5')params[0]ELSEpositionENDIF,
                'root': rootId,
                'id': nodeId,
                'destid': destId
            };

            IF targets('1.3.5')
                request = new Zikula.Ajax.Request(
                    Zikula.Config.baseURL + 'ajax.php?module=appName&func=handleTreeOperation',
                    {
                        method: 'post',
                        parameters: requestParams,
                        onComplete: function (req) {
                            if (!req.isSuccess()) {
                                var treeName = 'itemTree' + rootId;
                                Zikula.UI.Alert(req.getMessage(), Zikula.__('Error', 'module_appName.formatForDB_js'));

                                return Zikula.TreeSortable[treeName].revertInsertion();
                            }
                            return true;
                        }
                    }
                );

                return request.success();
            ELSE
                $.ajax({
                    type: 'POST',
                    url: Routing.generate('appName.formatForDB_ajax_handleTreeOperation'),
                    data: requestParams
                }).done(function(res) {
                    return true;
                }).fail(function(jqXHR, textStatus) {
                    var treeName = 'itemTree' + rootId;
                    prefix()SimpleAlert($('.tree-container'), Zikula.__('Error', 'module_appName.formatForDB_js'), Zikula.__('Could not persist your change.', 'module_appName.formatForDB_js'), 'treeAjaxFailedAlert', 'danger');

                    window.location.reload();
                    return false;
                });

                return true;
            ENDIF
        }
    '''
}
