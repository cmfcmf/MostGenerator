package org.zikula.modulestudio.generator.cartridges.zclassic.models

import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.Entity
import de.guite.modulestudio.metamodel.modulestudio.EntityChangeTrackingPolicy
import de.guite.modulestudio.metamodel.modulestudio.EntityIndex
import de.guite.modulestudio.metamodel.modulestudio.EntityIndexItem
import de.guite.modulestudio.metamodel.modulestudio.InheritanceRelationship
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.models.business.ValidationConstraints
import org.zikula.modulestudio.generator.cartridges.zclassic.models.business.ValidatorLegacy
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.Association
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.EntityConstructor
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.EntityMethods
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.ExtensionManager
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.Property
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelInheritanceExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Entities {

    extension FormattingExtensions = new FormattingExtensions
    extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension ModelInheritanceExtensions = new ModelInheritanceExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    FileHelper fh = new FileHelper
    Association thAssoc = new Association
    ExtensionManager extMan
    EventListener thEvLi = new EventListener
    Property thProp

    /**
     * Entry point for Doctrine entity classes.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        getAllEntities.forEach(e|e.generate(it, fsa))

        if (targets('1.3.5')) {
            val validator = new ValidatorLegacy()
            validator.generateCommon(it, fsa)
            for (entity : getAllEntities) {
                validator.generateWrapper(entity, fsa)
            }
        }

        for (entity : getAllEntities) {
            extMan = new ExtensionManager(entity)
            extMan.extensionClasses(fsa)
        }
    }

    /**
     * Creates an entity class file for every Entity instance.
     */
    def private generate(Entity it, Application app, IFileSystemAccess fsa) {
        println('Generating entity classes for entity "' + name.formatForDisplay + '"')
        extMan = new ExtensionManager(it)
        thProp = new Property(extMan)
        val entityPath = app.getAppSourceLibPath + 'Entity/'
        val entityClassSuffix = if (!app.targets('1.3.5')) 'Entity' else ''
        val entityFileName = name.formatForCodeCapital + entityClassSuffix
        var fileName = ''
        if (!isInheriting) {
            fileName = entityFileName + '.php'
            if (app.targets('1.3.5') && !app.shouldBeSkipped(entityPath + 'Base/' + fileName)) {
                if (app.shouldBeMarked(entityPath + 'Base/' + fileName)) {
                    fileName = entityFileName + '.generated.php'
                }
                fsa.generateFile(entityPath + 'Base/' + fileName, fh.phpFileContent(app, modelEntityBaseImpl(app)))
            } else if (!app.shouldBeSkipped(entityPath + 'Base/Abstract' + fileName)) {
                if (app.shouldBeMarked(entityPath + 'Base/Abstract' + fileName)) {
                    fileName = entityFileName + '.generated.php'
                }
                fsa.generateFile(entityPath + 'Base/Abstract' + fileName, fh.phpFileContent(app, modelEntityBaseImpl(app)))
            }
        }
        fileName = entityFileName + '.php'
        if (!app.generateOnlyBaseClasses && !app.shouldBeSkipped(entityPath + fileName)) {
            if (app.shouldBeMarked(entityPath + fileName)) {
                fileName = entityFileName + '.generated.php'
            }
            fsa.generateFile(entityPath + fileName, fh.phpFileContent(app, modelEntityImpl(app)))
        }
    }

    def private imports(Entity it) '''
        use Doctrine\ORM\Mapping as ORM;
        IF hasCollections || attributable || categorisable
            use Doctrine\Common\Collections\ArrayCollection;
        ENDIF
        use Gedmo\Mapping\Annotation as Gedmo;
        IF hasNotifyPolicy
            use Doctrine\Common\NotifyPropertyChanged;
            use Doctrine\Common\PropertyChangedListener;
        ENDIF
        IF standardFields
            use DoctrineExtensions\StandardFields\Mapping\Annotation as ZK;
        ENDIF
        IF !container.application.targets('1.3.5')
            use Symfony\Component\Validator\Constraints as Assert;
            IF !getUniqueDerivedFields.filter[!primaryKey].empty || (hasSluggableFields && slugUnique) || !getIncomingJoinRelations.filter[unique].empty || !getOutgoingJoinRelations.filter[unique].empty || !getUniqueIndexes.empty
                use Symfony\Bridge\Doctrine\Validator\Constraints\UniqueEntity;
            ENDIF
        ENDIF
    '''

    def private modelEntityBaseImpl(Entity it, Application app) '''
        IF !app.targets('1.3.5')
            namespace app.appNamespace\Entity\Base;

            use app.appNamespace\app.name.formatForCodeCapitalEvents;
            use app.appNamespace\Event\Filtername.formatForCodeCapitalEvent;
        ENDIF
        imports
        IF !app.targets('1.3.5')

            use DataUtil;
            use FormUtil;
            use ModUtil;
            use SecurityUtil;
            use ServiceUtil;
            use System;
            use UserUtil;
            use Zikula_EntityAccess;
            use Zikula_Exception;
            use Zikula_Workflow_Util;
            use ZLanguage;
        ENDIF

        /**
         * Entity class that defines the entity structure and behaviours.
         *
         * This is the base entity class for name.formatForDisplay entities.
         * The following annotation marks it as a mapped superclass so subclasses
         * inherit orm properties.
         *
         * @ORM\MappedSuperclass
         *
         * @abstract
         */
        IF app.targets('1.3.5')
        abstract class app.appName_Entity_Base_name.formatForCodeCapital extends Zikula_EntityAccessIF hasNotifyPolicy implements NotifyPropertyChangedENDIF
        ELSE
        abstract class Abstractname.formatForCodeCapitalEntity extends Zikula_EntityAccessIF hasNotifyPolicy implements
            NotifyPropertyChangedENDIF
        ENDIF
        {
            val validatorClassLegacy = if (app.targets('1.3.5')) app.appName + '_Entity_Validator_' + name.formatForCodeCapital else '\\' + app.vendor.formatForCodeCapital + '\\' + app.name.formatForCodeCapital + 'Module\\Entity\\Validator\\' + name.formatForCodeCapital + 'Validator'
            memberVars(validatorClassLegacy)
    
            new EntityConstructor().constructor(it, false)
    
            accessors(validatorClassLegacy)
    
            thEvLi.generateBase(it)
    
            new EntityMethods().generate(it, app, thProp)
        }
    '''

    def private memberVars(Entity it, String validatorClassLegacy) '''
        /**
         * @var string The tablename this object maps to.
         */
        protected $_objectType = 'name.formatForCode';
        IF container.application.targets('1.3.5')

            /**
             * @var validatorClassLegacy The validator for this entity.
             */
            protected $_validator = null;
        ENDIF

        /**
         IF !container.application.targets('1.3.5')
         * @Assert\Type(type="bool")
         ENDIF
         * @var boolean Option to bypass validation if needed.
         */
        protected $_bypassValidation = false;
        IF hasNotifyPolicy

            /**
             IF !container.application.targets('1.3.5')
             * @Assert\Type(type="array")
             ENDIF
             * @var array List of change notification listeners.
             */
            protected $_propertyChangedListeners = array();
        ENDIF

        /**
         IF !container.application.targets('1.3.5')
         * @Assert\Type(type="array")
         ENDIF
         * @var array List of available item actions.
         */
        protected $_actions = array();

        /**
         * @var array The current workflow data of this object.
         */
        protected $__WORKFLOW__ = array();

        FOR field : getDerivedFieldsthProp.persistentProperty(field)ENDFOR
        extMan.additionalProperties

        FOR relation : getBidirectionalIncomingJoinRelationsthAssoc.generate(relation, false)ENDFOR
        FOR relation : getOutgoingJoinRelationsthAssoc.generate(relation, true)ENDFOR
    '''

    def private accessors(Entity it, String validatorClassLegacy) '''
        fh.getterAndSetterMethods(it, '_objectType', 'string', false, false, '', '')
        IF container.application.targets('1.3.5')
            fh.getterAndSetterMethods(it, '_validator', validatorClassLegacy, false, true, 'null', '')
        ENDIF
        fh.getterAndSetterMethods(it, '_bypassValidation', 'boolean', false, false, '', '')
        fh.getterAndSetterMethods(it, '_actions', 'array', false, true, 'Array()', '')
        fh.getterAndSetterMethods(it, '__WORKFLOW__', 'array', false, true, 'Array()', '')

        FOR field : getDerivedFieldsthProp.fieldAccessor(field)ENDFOR
        extMan.additionalAccessors

        FOR relation : getBidirectionalIncomingJoinRelationsthAssoc.relationAccessor(relation, false)ENDFOR
        FOR relation : getOutgoingJoinRelationsthAssoc.relationAccessor(relation, true)ENDFOR
    '''

    def private modelEntityImpl(Entity it, Application app) '''
        IF !app.targets('1.3.5')
            namespace app.appNamespace\Entity;

            use app.appNamespace\Entity\IF isInheritingparentType.name.formatForCodeCapitalELSEBase\Abstractname.formatForCodeCapitalEntityENDIF as BaseIF isInheritingparentType.name.formatForCodeCapitalELSEAbstractname.formatForCodeCapitalEntityENDIF;

        ENDIF
        imports

        entityImplClassDocblock(app)
        IF app.targets('1.3.5')
        class entityClassName('', false) extends IF isInheritingparentType.entityClassName('', false)ELSEentityClassName('', true)ENDIF
        ELSE
        class name.formatForCodeCapitalEntity extends BaseIF isInheritingparentType.name.formatForCodeCapitalELSEAbstractname.formatForCodeCapitalEntityENDIF
        ENDIF
        {
            // feel free to add your own methods here
            IF isInheriting
                FOR field : getDerivedFieldsthProp.persistentProperty(field)ENDFOR
                extMan.additionalProperties

                FOR relation : getBidirectionalIncomingJoinRelationsthAssoc.generate(relation, false)ENDFOR
                FOR relation : getOutgoingJoinRelationsthAssoc.generate(relation, true)ENDFOR
                new EntityConstructor().constructor(it, true)

                FOR field : getDerivedFieldsthProp.fieldAccessor(field)ENDFOR
                extMan.additionalAccessors

                FOR relation : getBidirectionalIncomingJoinRelationsthAssoc.relationAccessor(relation, false)ENDFOR
                FOR relation : getOutgoingJoinRelationsthAssoc.relationAccessor(relation, true)ENDFOR
            ENDIF

            thEvLi.generateImpl(it)
        }
    '''

    def private entityImplClassDocblock(Entity it, Application app) '''
        /**
         * Entity class that defines the entity structure and behaviours.
         *
         * This is the concrete entity class for name.formatForDisplay entities.
         extMan.classAnnotations
         IF mappedSuperClass
          * @ORM\MappedSuperclass
         ELSE
          * @ORM\Entity(repositoryClass="IF app.targets('1.3.5')app.appName_Entity_Repository_name.formatForCodeCapitalELSE\app.appNamespace\Entity\Repository\name.formatForCodeCapitalENDIF"IF readOnly, readOnly=trueENDIF)
         ENDIF
        entityImplClassDocblockAdditions(app)
         */
    '''

    def private entityImplClassDocblockAdditions(Entity it, Application app) '''
         IF indexes.empty
          * @ORM\Table(name="fullEntityTableName")
         ELSE
          * @ORM\Table(name="fullEntityTableName",
         IF hasNormalIndexes
          *     indexes={
         FOR index : getNormalIndexes SEPARATOR ','index.index('Index')ENDFOR
          *     }IF hasUniqueIndexes,ENDIF
         ENDIF
         IF hasUniqueIndexes
          *     uniqueConstraints={
         FOR index : getUniqueIndexes SEPARATOR ','index.index('UniqueConstraint')ENDFOR
          *     }
         ENDIF
          * )
         ENDIF
         IF isTopSuperClass
          * @ORM\InheritanceType("getChildRelations.head.strategy.literal")
          * @ORM\DiscriminatorColumn(name="getChildRelations.head.discriminatorColumn.formatForCode"/*, type="string"*/)
          * @ORM\Discriminatormap[{"name.formatForCode" = "entityClassName('', false)"FOR relation : getChildRelationsrelation.discriminatorInfoENDFOR})
         ENDIF
         IF changeTrackingPolicy != EntityChangeTrackingPolicy::DEFERRED_IMPLICIT
          * @ORM\ChangeTrackingPolicy("changeTrackingPolicy.literal")
         ENDIF
         * @ORM\HasLifecycleCallbacks
        IF !app.targets('1.3.5')
            new ValidationConstraints().classAnnotations(it)
        ENDIF
    '''

    def private index(EntityIndex it, String indexType) '''
         *         @ORM\indexType.toFirstUpper(name="name.formatForDB", columns={FOR item : items SEPARATOR ','item.indexFieldENDFOR})
    '''
    def private indexField(EntityIndexItem it) '''"name.formatForCode"'''

    def private discriminatorInfo(InheritanceRelationship it) '''
        , "source.name.formatForCode" = "source.entityClassName('', false)"
    '''
}
