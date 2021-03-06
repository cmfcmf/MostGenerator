package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions

import de.guite.modulestudio.metamodel.modulestudio.DerivedField
import de.guite.modulestudio.metamodel.modulestudio.Entity
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Loggable extends AbstractExtension implements EntityExtensionInterface {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    /**
     * Generates additional annotations on class level.
     */
    override classAnnotations(Entity it) '''
         ' '* @Gedmo\Loggable(logEntryClass="IF !container.application.targets('1.3.5')\ENDIFentityClassName('logEntry', false)")
    '''

    /**
     * Additional field annotations.
     */
    override columnAnnotations(DerivedField it) '''
        IF entity.loggable * @Gedmo\Versioned
        ENDIF
    '''

    /**
     * Generates additional entity properties.
     */
    override properties(Entity it) '''
    '''

    /**
     * Generates additional accessor methods.
     */
    override accessors(Entity it) '''
    '''

    /**
     * Returns the extension class type.
     */
    override extensionClassType(Entity it) {
        'logEntry'
    }

    /**
     * Returns the extension class import statements.
     */
    override extensionClassImports(Entity it) '''
        use Gedmo\Loggable\Entity\IF !container.application.targets('1.3.5')MappedSuperclass\ENDIFextensionBaseClass;
    '''

    /**
     * Returns the extension base class.
     */
    override extensionBaseClass(Entity it) {
        'AbstractLogEntry'
    }

    /**
     * Returns the extension class description.
     */
    override extensionClassDescription(Entity it) {
        'Entity extension domain class storing ' + name.formatForDisplay + ' log entries.'
    }

    /**
     * Returns the extension implementation class ORM annotations.
     */
    override extensionClassImplAnnotations(Entity it) '''
         ' '*
         ' '* @ORM\Entity(repositoryClass="repositoryClass(extensionClassType)")
         ' '* @ORM\Table(name="fullEntityTableName_log_entry",
         ' '*     indexes={
         ' '*         @ORM\Index(name="log_class_lookup_idx", columns={"object_class"}),
         ' '*         @ORM\Index(name="log_date_lookup_idx", columns={"logged_at"}),
         ' '*         @ORM\Index(name="log_user_lookup_idx", columns={"username"})
         ' '*     }
         ' '* )
    '''
}
