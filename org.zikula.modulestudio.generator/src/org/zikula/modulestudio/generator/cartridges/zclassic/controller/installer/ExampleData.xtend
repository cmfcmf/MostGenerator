package org.zikula.modulestudio.generator.cartridges.zclassic.controller.installer

import de.guite.modulestudio.metamodel.modulestudio.AbstractDateField
import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.ArrayField
import de.guite.modulestudio.metamodel.modulestudio.BooleanField
import de.guite.modulestudio.metamodel.modulestudio.DateField
import de.guite.modulestudio.metamodel.modulestudio.DatetimeField
import de.guite.modulestudio.metamodel.modulestudio.DecimalField
import de.guite.modulestudio.metamodel.modulestudio.DerivedField
import de.guite.modulestudio.metamodel.modulestudio.EmailField
import de.guite.modulestudio.metamodel.modulestudio.Entity
import de.guite.modulestudio.metamodel.modulestudio.EntityTreeType
import de.guite.modulestudio.metamodel.modulestudio.FloatField
import de.guite.modulestudio.metamodel.modulestudio.IntegerField
import de.guite.modulestudio.metamodel.modulestudio.JoinRelationship
import de.guite.modulestudio.metamodel.modulestudio.ListField
import de.guite.modulestudio.metamodel.modulestudio.ListFieldItem
import de.guite.modulestudio.metamodel.modulestudio.ManyToManyRelationship
import de.guite.modulestudio.metamodel.modulestudio.ManyToOneRelationship
import de.guite.modulestudio.metamodel.modulestudio.Models
import de.guite.modulestudio.metamodel.modulestudio.ObjectField
import de.guite.modulestudio.metamodel.modulestudio.OneToManyRelationship
import de.guite.modulestudio.metamodel.modulestudio.OneToOneRelationship
import de.guite.modulestudio.metamodel.modulestudio.StringField
import de.guite.modulestudio.metamodel.modulestudio.TextField
import de.guite.modulestudio.metamodel.modulestudio.TimeField
import de.guite.modulestudio.metamodel.modulestudio.UploadField
import de.guite.modulestudio.metamodel.modulestudio.UrlField
import de.guite.modulestudio.metamodel.modulestudio.UserField
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelInheritanceExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ExampleData {
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension ModelInheritanceExtensions = new ModelInheritanceExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    /**
     * Entry point for example data used by the installer.
     */
    def generate(Application it) '''
        /**
         * Create the default data for appName.
         *
         * @param array $categoryRegistryIdsPerEntity List of category registry ids.
         *
         * @return void
         */
        protected function createDefaultData($categoryRegistryIdsPerEntity)
        {
            getDefaultDataSource.exampleRowImpl
        }
    '''

    def private exampleRowImpl(Models it) '''
        FOR entity : entitiesentity.truncateTableENDFOR
        IF numExampleRows > 0
            IF !entities.filter[tree != EntityTreeType::NONE].empty
                $treeCounterRoot = 1;
            ENDIF
            createExampleRows
        ENDIF
    '''

    def private truncateTable(Entity it) '''
        val app = container.application
        IF app.targets('1.3.5')
            $entityClass = 'app.appName_Entity_name.formatForCodeCapital';
        ELSE
            $entityClass = 'app.vendor.formatForCodeCapitalapp.name.formatForCodeCapitalModule:name.formatForCodeCapitalEntity';
        ENDIF
        $this->entityManager->getRepository($entityClass)->truncateTable();
    '''

    def private createExampleRows(Models it) '''
        initDateValues
        FOR entity : entitiesentity.initExampleObjects(application)ENDFOR
        FOR entity : entitiesentity.createExampleRows(application)ENDFOR
        persistExampleObjects
    '''

    def private initDateValues(Models it) '''
        val fields = getModelEntityFields.filter(AbstractDateField)
        IF !fields.filter[past].empty
            $lastMonth = mktime(date('s'), date('H'), date('i'), date('m')-1, date('d'), date('Y'));
            $lastHour = mktime(date('s'), date('H')-1, date('i'), date('m'), date('d'), date('Y'));
        ENDIF
        IF !fields.filter[future].empty
            $nextMonth = mktime(date('s'), date('H'), date('i'), date('m')+1, date('d'), date('Y'));
            $nextHour = mktime(date('s'), date('H')+1, date('i'), date('m'), date('d'), date('Y'));
        ENDIF
        IF !fields.filter(DatetimeField).empty
            $dtNow = date('Y-m-d H:i:s');
            IF !fields.filter(DatetimeField).filter[past].empty
                $dtPast = date('Y-m-d H:i:s', $lastMonth);
            ENDIF
            IF !fields.filter(DatetimeField).filter[future].empty
                $dtFuture = date('Y-m-d H:i:s', $nextMonth);
            ENDIF
        ENDIF
        IF !fields.filter(DateField).empty
            $dNow = date('Y-m-d');
            IF !fields.filter(DateField).filter[past].empty
                $dPast = date('Y-m-d', $lastMonth);
            ENDIF
            IF !fields.filter(DateField).filter[future].empty
                $dFuture = date('Y-m-d', $nextMonth);
            ENDIF
        ENDIF
        IF !fields.filter(TimeField).empty
            $tNow = date('H:i:s');
            IF !fields.filter(TimeField).filter[past].empty
                $tPast = date('H:i:s', $lastHour);
            ENDIF
            IF !fields.filter(TimeField).filter[future].empty
                $tFuture = date('H:i:s', $nextHour);
            ENDIF
        ENDIF
    '''

    def private initExampleObjects(Entity it, Application app) '''
        FOR number : 1..container.numExampleRows
            $name.formatForCodenumber = new IF app.targets('1.3.5')\app.appName_Entity_name.formatForCodeCapitalELSE\app.vendor.formatForCodeCapital\app.name.formatForCodeCapitalModule\Entity\name.formatForCodeCapitalEntityENDIF(exampleRowsConstructorArguments(number));
        ENDFOR
        /* this last line is on purpose */
    '''

    def private createExampleRows(Entity it, Application app) '''
        val entityName = name.formatForCode
        IF categorisable
            $categoryId = 41; // Business and work
            $category = $this->entityManager->find('ZikulaIF app.targets('1.3.5')_Doctrine2_Entity_CategoryELSECategoriesModule:CategoryEntityENDIF', $categoryId);
        ENDIF
        FOR number : 1..container.numExampleRows
            IF isInheriting
                FOR field : parentType.getFieldsForExampleDataexampleRowAssignment(field, it, entityName, number)ENDFOR
            ENDIF
            FOR field : getFieldsForExampleDataexampleRowAssignment(field, it, entityName, number)ENDFOR
            /*IF hasTranslatableFields
                $entityNamenumber->setLocale(ZLanguage::getLanguageCode());
            ENDIF*/
            IF tree != EntityTreeType::NONE
                $entityNamenumber->setParent(IF number == 1nullELSE$entityName1ENDIF);
                $entityNamenumber->setLvl(IF number == 11ELSE2ENDIF);
                $entityNamenumber->setLft(IF number == 11ELSE((number-1)*2)ENDIF);
                $entityNamenumber->setRgt(IF number == 1container.numExampleRows*2ELSE((number-1)*2)+1ENDIF);
                $entityNamenumber->setRoot($treeCounterRoot);
            ENDIF
            FOR relation : outgoing.filter(OneToOneRelationship).filter[target.container.application == app]relation.exampleRowAssignmentOutgoing(entityName, number)ENDFOR 
            FOR relation : outgoing.filter(ManyToOneRelationship).filter[target.container.application == app]relation.exampleRowAssignmentOutgoing(entityName, number)ENDFOR
            FOR relation : outgoing.filter(ManyToManyRelationship).filter[target.container.application == app]relation.exampleRowAssignmentOutgoing(entityName, number)ENDFOR
            FOR relation : incoming.filter(OneToManyRelationship).filter[bidirectional].filter[source.container.application == app]relation.exampleRowAssignmentIncoming(entityName, number)ENDFOR
            IF categorisable
                // create category assignment
                $entityNamenumber->getCategories()->add(new IF app.targets('1.3.5')\app.appName_Entity_name.formatForCodeCapitalCategoryELSE\app.vendor.formatForCodeCapital\app.name.formatForCodeCapitalModule\Entity\name.formatForCodeCapitalCategoryEntityENDIF($categoryRegistryIdsPerEntity['name.formatForCode'], $category, $entityNamenumber));
            ENDIF
            IF attributable
                // create example attributes
                $entityNamenumber->setAttribute('field1', 'first value');
                $entityNamenumber->setAttribute('field2', 'second value');
                $entityNamenumber->setAttribute('field3', 'third value');
            ENDIF
            IF metaData
                // create meta data assignment
                IF app.targets('1.3.5')
                    $metaDataEntityClass = $this->name . '_Entity_name.formatForCodeCapitalMetaData';
                ELSE
                    $metaDataEntityClass = '\\app.vendor.formatForCodeCapital\\app.name.formatForCodeCapitalModule\\Entity\\name.formatForCodeCapitalMetaDataEntity';
                ENDIF
                $metaData = new $metaDataEntityClass($entity);

                $metaData->setTitle($this->__('Example title'));
                $metaData->setAuthor($this->__('Example author'));
                $metaData->setSubject($this->__('Example subject'));
                $metaData->setKeywords($this->__('Example keywords, one, two, three'));
                $metaData->setDescription($this->__('Example description'));
                $metaData->setPublisher($this->__('Example publisher'));
                $metaData->setContributor($this->__('Example contributor'));
                $metaData->setStartdate('');
                $metaData->setEnddate('');
                $metaData->setType($this->__('Example type'));
                $metaData->setFormat($this->__('Example format'));
                $metaData->setUri('http://example.org/');
                $metaData->setSource($this->__('Example source'));
                $metaData->setLanguage('en');
                $metaData->setRelation($this->__('Example relation'));
                $metaData->setCoverage($this->__('Example coverafge'));
                $metaData->setComment($this->__('Example comment'));
                $metaData->setExtra($this->__('Example extra information'));

                $entityNamenumber->setMetadata($metaData);
            ENDIF
        ENDFOR
        IF tree != EntityTreeType::NONE
            $treeCounterRoot++;
        ENDIF
        /* this last line is on purpose */
    '''

    def private persistExampleObjects(Models it) '''
        // execute the workflow action for each entity
        $action = 'submit';
        IF application.targets('1.3.5')
            $workflowHelper = new application.appName_Util_Workflow($this->serviceManager);
        ELSE
            $workflowHelper = $this->serviceManager->get('application.appName.formatForDB.workflow_helper');
        ENDIF
        try {
            FOR entity : entitiesentity.persistEntities(application)ENDFOR
        } catch(\Exception $e) {
            IF application.targets('1.3.5')
                LogUtil::registerError($this->__('Sorry, but an unknown error occured during example data creation. Possibly not all data could be created properly!'));
            ELSE
                $this->request->getSession()->getFlashBag()->add('warning', $this->__('Sorry, but an unknown error occured during example data creation. Possibly not all data could be created properly!'));
            ENDIF
        }
    '''

    def private persistEntities(Entity it, Application app) '''
        FOR number : 1..container.numExampleRows
            $success = $workflowHelper->executeAction($name.formatForCodenumber, $action);
        ENDFOR
    '''

    def private exampleRowsConstructorArgumentsDefault(Entity it, Boolean hasPreviousArgs, Integer number) '''
        IF hasCompositeKeys
            IF hasPreviousArgs, ENDIFFOR pkField : getPrimaryKeyFields SEPARATOR ', '$pkField.name.formatForCodeENDFOR
        ENDIF
    '''

    def private exampleRowsConstructorArguments(Entity it, Integer number) '''
        IF isIndexByTarget
            val indexRelation = incoming.filter(JoinRelationship).filter[isIndexed].head
            val sourceAlias = getRelationAliasName(indexRelation, false)
            val indexBy = indexRelation.getIndexByField
            val indexByField = getDerivedFields.findFirst[name == indexBy]
            indexByField.exampleRowsConstructorArgument(number), $sourceAlias.formatForCodenumberexampleRowsConstructorArgumentsDefault(true, number)
        ELSEIF isAggregated
            FOR aggregator : getAggregators SEPARATOR ', '
                FOR relation : aggregator.getAggregatingRelationships SEPARATOR ', 'relation.exampleRowsConstructorArgumentsAggregate(number)ENDFORexampleRowsConstructorArgumentsDefault(true, number)
            ENDFOR
        ELSE
            exampleRowsConstructorArgumentsDefault(false, number)
        ENDIF
    '''

    def private exampleRowsConstructorArgument(DerivedField it, Integer number) {
        switch it {
            IntegerField: if (it.defaultValue.length > 0) it.defaultValue else number
            default: '\'' + (if (it.defaultValue.length > 0) it.defaultValue else it.name.formatForDisplayCapital + ' ' + number) + '\''
        }
    }

    def private exampleRowsConstructorArgumentsAggregate(OneToManyRelationship it, Integer number) '''
        val targetField = source.getAggregateFields.head.getAggregateTargetField
        $getRelationAliasName(false)number, IF targetField.defaultValue != '' && targetField.defaultValue != '0'targetField.defaultValueELSEnumberENDIF
    '''

    def private exampleRowAssignment(DerivedField it, Entity dataEntity, String entityName, Integer number) {
        switch it {
            IntegerField: '''
                IF it.aggregateFor.length == 0
                    $entityNamenumber->setname.formatForCodeCapital(exampleRowValue(dataEntity, number));
                ENDIF
            '''
            UploadField: ''
            default: '''
                $entityNamenumber->setname.formatForCodeCapital(exampleRowValue(dataEntity, number));
            '''
        }
    }

    def private dispatch exampleRowAssignmentOutgoing(JoinRelationship it, String entityName, Integer number) '''
            $entityNamenumber->setgetRelationAliasName(true).formatForCodeCapital($target.name.formatForCodenumber);
    '''
    def private dispatch exampleRowAssignmentOutgoing(ManyToManyRelationship it, String entityName, Integer number) '''
            $entityNamenumber->addgetRelationAliasName(true).formatForCodeCapital($target.name.formatForCodenumber);
    '''
    def private exampleRowAssignmentIncoming(JoinRelationship it, String entityName, Integer number) '''
            $entityNamenumber->setgetRelationAliasName(false).formatForCodeCapital($source.name.formatForCodenumber);
    '''

    def private exampleRowValueNumber(DerivedField it, Entity dataEntity, Integer number) '''number'''

    def private exampleRowValueTextLength(DerivedField it, Entity dataEntity, Integer number, Integer maxLength) '''
        IF maxLength >= (entity.name.formatForDisplayCapital.length + 4 + name.formatForDisplay.length)
            'dataEntity.name.formatForDisplayCapital name.formatForDisplay number'ELSEIF !unique && maxLength >= (4 + name.formatForDisplay.length)
            'name.formatForDisplay number'ELSEIF maxLength < 4 && maxLength > 1
            '(number+dataEntity.name.length+dataEntity.fields.size)'ELSEIF maxLength == 1
            'if (number > 9) 1 else number'ELSE
            substr('dataEntity.name.formatForDisplayCapital name.formatForDisplay', 0, (maxLength-2)) . ' number'
        ENDIF'''

    def private exampleRowValueText(DerivedField it, Entity dataEntity, Integer number) {
        switch it {
            StringField: exampleRowValueTextLength(dataEntity, number, it.length)
            TextField: exampleRowValueTextLength(dataEntity, number, it.length)
            EmailField: exampleRowValueTextLength(dataEntity, number, it.length)
            UrlField: exampleRowValueTextLength(dataEntity, number, it.length)
            default: '\'' + entity.name.formatForDisplayCapital + ' ' + name.formatForDisplay + ' ' + number + '\''
        }
    }
    def private exampleRowValue(DerivedField it, Entity dataEntity, Integer number) {
        switch it {
            BooleanField: if (defaultValue == true || defaultValue == 'true') 'true' else 'false'
            IntegerField: exampleRowValueNumber(dataEntity, number)
            DecimalField: exampleRowValueNumber(dataEntity, number)
            StringField: if (it.country || it.language || it.locale) 'ZLanguage::getLanguageCode()' else if (it.currency) 'EUR' else if (it.htmlcolour) '\'#ff6600\'' else exampleRowValueText(dataEntity, number)
            TextField: exampleRowValueText(dataEntity, number)
            EmailField: '\'' + entity.container.application.email + '\''
            UrlField: '\'' + entity.container.application.url + '\''
            UploadField: exampleRowValueText(dataEntity, number)
            UserField: /* admin */2
            ArrayField: exampleRowValueNumber(dataEntity, number)
            ObjectField: exampleRowValueText(dataEntity, number)
            DatetimeField: '''IF it.past$dtPastELSEIF it.future$dtFutureELSE$dtNowENDIF'''
            DateField: '''IF it.past$dPastELSEIF it.future$dFutureELSE$dNowENDIF'''
            TimeField: '''IF it.past$tPastELSEIF it.future$tFutureELSE$tNowENDIF'''
            FloatField: exampleRowValueNumber(dataEntity, number)
            ListField: ''''IF it.multiple###FOR item : getDefaultItems SEPARATOR '###'item.exampleRowValueENDFOR###ELSEFOR item : getDefaultItemsitem.exampleRowValueENDFORENDIF'/**/'''
            default: ''
        }
    }

    def private exampleRowValue(ListFieldItem it) {
        if (^default) value else ''
    }
}
