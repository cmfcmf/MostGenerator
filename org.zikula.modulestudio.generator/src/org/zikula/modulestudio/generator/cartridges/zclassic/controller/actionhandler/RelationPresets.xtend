package org.zikula.modulestudio.generator.cartridges.zclassic.controller.actionhandler

import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.Entity
import de.guite.modulestudio.metamodel.modulestudio.JoinRelationship
import de.guite.modulestudio.metamodel.modulestudio.ManyToManyRelationship
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions

class RelationPresets {
    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension NamingExtensions = new NamingExtensions

    def memberFields(Application it) '''

        /**
         * List of identifiers for predefined relationships.
         *
         * @var mixed
         */
        protected $relationPresets = array();
    '''

    def initPresets(Entity it) '''
        val owningAssociations = getOwningAssociations(it.container.application)
        IF !owningAssociations.empty

            // assign identifiers of predefined incoming relationships
            FOR relation : owningAssociations
                IF !relation.isEditable(false)
                    // non-editable relation, we store the id and assign it in handleCommand
                ELSE
                    // editable relation, we store the id and assign it now to show it in UI
                ENDIF
                relation.initSinglePreset(false)
                IF relation.isEditable(false)
                    relation.saveSinglePreset(false)
                ENDIF
            ENDFOR
        ENDIF
        val ownedMMAssociations = getOwnedMMAssociations(it.container.application)
        IF !ownedMMAssociations.empty

            // assign identifiers of predefined outgoing many to many relationships
            FOR relation : ownedMMAssociations
                IF !relation.isEditable(true)
                    // non-editable relation, we store the id and assign it in handleCommand
                ELSE
                    // editable relation, we store the id and assign it now to show it in UI
                ENDIF
                relation.initSinglePreset(true)
                IF relation.isEditable(true)
                    relation.saveSinglePreset(true)
                ENDIF
            ENDFOR
        ENDIF
    '''

    def private initSinglePreset(JoinRelationship it, Boolean useTarget) '''
        val alias = getRelationAliasName(useTarget)
        $this->relationPresets['alias'] = FormUtil::getPassedValue('alias', '', 'GET');
    '''

    def private getOwningAssociations(Entity it, Application refApp) {
        getBidirectionalIncomingJoinRelations
            .filter[source.container.application == refApp]
    }

    def private getOwnedMMAssociations(Entity it, Application refApp) {
        getOutgoingJoinRelations
            .filter(ManyToManyRelationship)
            .filter[source.container.application == refApp]
    }

    def private isEditable(JoinRelationship it, Boolean useTarget) {
        getEditStageCode(!useTarget) > 0
    }

    def saveNonEditablePresets(Entity it, Application app) '''
        val owningAssociationsNonEditable = getOwningAssociations(app).filter[!isEditable(false)]
        val ownedMMAssociationsNonEditable = getOwnedMMAssociations(app).filter[!isEditable(true)]
        IF !owningAssociationsNonEditable.empty || !ownedMMAssociationsNonEditable.empty

            if ($args['commandName'] == 'create') {
                IF !owningAssociationsNonEditable.empty
                // save predefined incoming relationship from parent entity
                FOR relation : owningAssociationsNonEditable
                    relation.saveSinglePreset(false)
                ENDFOR
                ENDIF
                IF !ownedMMAssociationsNonEditable.empty
                // save predefined outgoing relationship to child entity
                FOR relation : ownedMMAssociationsNonEditable
                    relation.saveSinglePreset(true)
                ENDFOR
                ENDIF
                $this->entityManager->flush();
            }
        ENDIF
    '''

    def private saveSinglePreset(JoinRelationship it, Boolean useTarget) '''
        val alias = getRelationAliasName(useTarget)
        val aliasInverse = getRelationAliasName(!useTarget)
        val otherObjectType = (if (useTarget) target else source).name.formatForCode
        if (!empty($this->relationPresets['alias'])) {
            $relObj = ModUtil::apiFunc($this->name, 'selection', 'getEntity', array('ot' => 'otherObjectType', 'id' => $this->relationPresets['alias']));
            if ($relObj != null) {
                IF !useTarget && it instanceof ManyToManyRelationship
                    $entity->IF isManySide(useTarget)addELSEsetENDIFalias.toFirstUpper($relObj);
                ELSE
                    $relObj->IF isManySide(!useTarget)addELSEsetENDIFaliasInverse.toFirstUpper($entity);
                ENDIF
            }
        }
    '''
}
