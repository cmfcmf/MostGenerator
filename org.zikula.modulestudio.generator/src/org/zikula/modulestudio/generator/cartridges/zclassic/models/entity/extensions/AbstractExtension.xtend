package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions

import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.Entity
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.ModelInheritanceExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

abstract class AbstractExtension implements EntityExtensionInterface {

    extension FormattingExtensions = new FormattingExtensions
    extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    extension ModelInheritanceExtensions = new ModelInheritanceExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    Application app
    String classType = ''
    FileHelper fh = new FileHelper
    protected IFileSystemAccess fsa

    /**
     * Generates separate extension classes.
     */
    override extensionClasses(Entity it, IFileSystemAccess fsa) {
        this.fsa = fsa
        if (extensionClassType != '') {
            extensionClasses(it, extensionClassType)
        }
    }

    /**
     * Single extension class.
     */
    def protected extensionClasses(Entity it, String classType) {
        this.app = container.application
        this.classType = classType

        val entityPath = app.getAppSourceLibPath + 'Entity/'
        val entitySuffix = if (app.targets('1.3.5')) '' else 'Entity'
        var classPrefix = name.formatForCodeCapital + classType.formatForCodeCapital
        val repositoryPath = entityPath + 'Repository/'
        var fileName = ''
        if (!isInheriting) {
            val entityPrefix = if (app.targets('1.3.5')) '' else 'Abstract'
            fileName = 'Base/' + entityPrefix + classPrefix + entitySuffix + '.php'
            if (!app.shouldBeSkipped(entityPath + fileName)) {
                if (app.shouldBeMarked(entityPath + fileName)) {
                    fileName = 'Base/' + entityPrefix + classPrefix + entitySuffix + '.generated.php'
                }
                fsa.generateFile(entityPath + fileName, fh.phpFileContent(app, extensionClassBaseImpl))
            }

            fileName = 'Base/' + classPrefix + '.php'
            if (classType != 'closure' && !app.shouldBeSkipped(repositoryPath + fileName)) {
                if (app.shouldBeMarked(repositoryPath + fileName)) {
                    fileName = 'Base/' + classPrefix + '.generated.php'
                }
                fsa.generateFile(repositoryPath + fileName, fh.phpFileContent(app, extensionClassRepositoryBaseImpl))
            }
        }
        if (!app.generateOnlyBaseClasses) {
            fileName = classPrefix + entitySuffix + '.php'
            if (!app.shouldBeSkipped(entityPath + fileName)) {
                if (app.shouldBeMarked(entityPath + fileName)) {
                    fileName = classPrefix + entitySuffix + '.generated.php'
                }
                fsa.generateFile(entityPath + fileName, fh.phpFileContent(app, extensionClassImpl))
            }

            fileName = classPrefix + '.php'
            if (classType != 'closure' && !app.shouldBeSkipped(repositoryPath + fileName)) {
                if (app.shouldBeMarked(repositoryPath + fileName)) {
                    fileName = classPrefix + '.generated.php'
                }
                fsa.generateFile(repositoryPath + fileName, fh.phpFileContent(app, extensionClassRepositoryImpl))
            }
        }
    }

    def protected extensionClassBaseImpl(Entity it) '''
        IF !app.targets('1.3.5')
            namespace app.appNamespace\Entity\Base;

        ENDIF
        extensionClassImports

        /**
         * extensionClassDescription
         *
         * This is the base classType.formatForDisplay class for it.name.formatForDisplay entities.
         */
        IF !app.targets('1.3.5')abstract ENDIFclass IF !app.targets('1.3.5')Abstractname.formatForCodeCapitalclassType.formatForCodeCapitalEntityELSEentityClassName(classType, true)ENDIF extends extensionBaseClass
        {
            extensionClassBaseAnnotations
        }
    '''

    /**
     * Returns the extension class type.
     */
    override extensionClassType(Entity it) {
        ''
    }

    /**
     * Returns the extension class import statements.
     */
    override extensionClassImports(Entity it) {
        ''
    }

    /**
     * Returns the extension base class.
     */
    override extensionBaseClass(Entity it) {
        ''
    }

    /**
     * Returns the extension class description.
     */
    override extensionClassDescription(Entity it) {
        ''
    }

    /**
     * Returns the extension base class ORM annotations.
     */
    override extensionClassBaseAnnotations(Entity it) {
        ''
    }

    def protected extensionClassEntityAccessors(Entity it) '''
        val app = container.application
        /**
         * Get reference to owning entity.
         *
         * @return IF !app.targets('1.3.5')\ENDIFentityClassName('', false)
         */
        public function getEntity()
        {
            return $this->entity;
        }

        /**
         * Set reference to owning entity.
         *
         * @param IF !app.targets('1.3.5')\ENDIFentityClassName('', false) $entity
         */
        public function setEntity(/*IF !app.targets('1.3.5')\ENDIFentityClassName('', false) */$entity)
        {
            $this->entity = $entity;
        }
    '''

    def protected extensionClassImpl(Entity it) '''
        IF !app.targets('1.3.5')
            namespace app.appNamespace\Entity;

            use app.appNamespace\Entity\IF isInheritingparentType.name.formatForCodeCapitalclassType.formatForCodeCapitalEntityELSEBase\Abstractname.formatForCodeCapitalclassType.formatForCodeCapitalEntityENDIF as BaseIF isInheritingparentType.name.formatForCodeCapitalclassType.formatForCodeCapitalELSEAbstractname.formatForCodeCapitalclassType.formatForCodeCapitalENDIFEntity;

        ENDIF
        use Doctrine\ORM\Mapping as ORM;

        /**
         * extensionClassDescription
         *
         * This is the concrete classType.formatForDisplay class for it.name.formatForDisplay entities.
        extensionClassImplAnnotations
         */
        IF app.targets('1.3.5')
        class entityClassName(classType, false) extends IF isInheritingparentType.entityClassName(classType, false)ELSEentityClassName(classType, true)ENDIF
        ELSE
        class name.formatForCodeCapitalclassType.formatForCodeCapitalEntity extends BaseIF isInheritingparentType.name.formatForCodeCapitalclassType.formatForCodeCapitalELSEAbstractname.formatForCodeCapitalclassType.formatForCodeCapitalENDIFEntity
        ENDIF
        {
            // feel free to add your own methods here
        }
    '''

    /**
     * Returns the extension implementation class ORM annotations.
     */
    override extensionClassImplAnnotations(Entity it) {
        ''
    }

    def protected repositoryClass(Entity it, String classType) {
        if (app === null) {
            app = container.application
        }
        (if (app.targets('1.3.5')) app.appName + '_Entity_Repository_' else app.appNamespace + '\\Entity\\Repository\\') + name.formatForCodeCapital + classType.formatForCodeCapital
    }

    def protected extensionClassRepositoryBaseImpl(Entity it) '''
        IF !app.targets('1.3.5')
            namespace app.appNamespace\Entity\Repository\Base;

        ENDIF
        IF classType == 'translation'
            use Gedmo\Translatable\Entity\Repository\TranslationRepository;
        ELSEIF classType == 'logEntry'
            use Gedmo\Loggable\Entity\Repository\LogEntryRepository;
        ELSE
            use Doctrine\ORM\EntityRepository;
        ENDIF

        /**
         * Repository class used to implement own convenience methods for performing certain DQL queries.
         *
         * This is the base repository class for it.name.formatForDisplay classType.formatForDisplay entities.
         */
        IF app.targets('1.3.5')
        class app.appName_Entity_Repository_Base_name.formatForCodeCapitalclassType.formatForCodeCapital extends IF classType == 'translation'TranslationELSEIF classType == 'logEntry'LogEntryELSEEntityENDIFRepository
        ELSE
        class name.formatForCodeCapitalclassType.formatForCodeCapital extends IF classType == 'translation'TranslationELSEIF classType == 'logEntry'LogEntryELSEEntityENDIFRepository
        ENDIF
        {
        }
    '''

    def protected extensionClassRepositoryImpl(Entity it) '''
        IF !app.targets('1.3.5')
            namespace app.appNamespace\Entity\Repository;

            use app.appNamespace\Entity\Repository\IF isInheritingparentType.name.formatForCodeCapitalclassType.formatForCodeCapitalELSEBase\name.formatForCodeCapitalclassType.formatForCodeCapitalENDIF as BaseIF isInheritingparentType.name.formatForCodeCapitalELSEname.formatForCodeCapitalENDIFclassType.formatForCodeCapital;

        ENDIF
        /**
         * Repository class used to implement own convenience methods for performing certain DQL queries.
         *
         * This is the concrete repository class for it.name.formatForDisplay classType.formatForDisplay entities.
         */
        IF app.targets('1.3.5')
        class app.appName_Entity_Repository_name.formatForCodeCapitalclassType.formatForCodeCapital extends IF isInheritingapp.appName_Entity_Repository_parentType.name.formatForCodeCapitalclassType.formatForCodeCapitalELSEapp.appName_Entity_Repository_Base_name.formatForCodeCapitalclassType.formatForCodeCapitalENDIF
        ELSE
        class name.formatForCodeCapitalclassType.formatForCodeCapital extends BaseIF isInheritingparentType.name.formatForCodeCapitalELSEname.formatForCodeCapitalENDIFclassType.formatForCodeCapital
        ENDIF
        {
            // feel free to add your own methods here
        }
    '''
}
