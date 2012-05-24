package org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.DerivedField
import de.guite.modulestudio.metamodel.modulestudio.BooleanField
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import de.guite.modulestudio.metamodel.modulestudio.IntegerField
import de.guite.modulestudio.metamodel.modulestudio.DecimalField
import de.guite.modulestudio.metamodel.modulestudio.FloatField
import de.guite.modulestudio.metamodel.modulestudio.AbstractDateField

class FileHelper {
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension ModelExtensions = new ModelExtensions()
    @Inject extension ModelJoinExtensions = new ModelJoinExtensions()
    @Inject extension Utils = new Utils()

    def phpFileHeader(Application it) '''
        <?php
        /**
         * «name».
         *
         * @copyright «author»
         * @license «license»
         * @package «name»
         * @author «author»«IF email != null && email != ''» <«email»>«ENDIF».
         * @link «IF url != ''»«url»«ELSE»«msUrl»«ENDIF»
         * @link http://zikula.org
         * @version Generated by ModuleStudio «msVersion» («msUrl») at «timestamp».
         */

    '''

    def msWeblink(Application it) '''
        <p class="z-center">
            Powered by <a href="«msUrl»" title="Get the MOST out of Zikula!">ModuleStudio «msVersion»</a>
        </p>
    '''


    def getterAndSetterMethods(Object it, String name, String type, Boolean isMany, Boolean useHint, String init) '''
        «getterMethod(name, type, isMany)»
        «setterMethod(name, type, isMany, useHint, init)»
    '''

    def getterMethod(Object it, String name, String type, Boolean isMany) '''
        /**
         * Get «name.formatForDisplay».
         *
         * @return «type»«IF type.toLowerCase != 'array' && isMany»[]«ENDIF»
         */
        public function get«name.formatForCodeCapital»()
        {
            return $this->«name»;
        }
        «/* this last line is on purpose */»
    '''

    def setterMethod(Object it, String name, String type, Boolean isMany, Boolean useHint, String init) '''
        /**
         * Set «name.formatForDisplay».
         *
         * @param «type»«IF type.toLowerCase != 'array' && isMany»[]«ENDIF» $«name».
         *
         * @return void
         */
        public function set«name.formatForCodeCapital»(«IF useHint»«type» «ENDIF»$«name»«IF init != ''» = «init»«ENDIF»)
        {
            «setterMethodImpl(name, type)»
        }
        «/* this last line is on purpose */»
    '''

    def private dispatch setterMethodImpl(Object it, String name, String type) '''
        $this->«name» = $«name»;
    '''

    def triggerPropertyChangeListeners(DerivedField it, String name) '''
        «IF entity.hasNotifyPolicy»
            $this->_onPropertyChanged('«name.formatForCode»', $this->«name.formatForCode», $«name»);
        «ENDIF»
    '''

    def private dispatch setterMethodImpl(DerivedField it, String name, String type) '''
        if ($«name» != $this->«name.formatForCode») {
            «triggerPropertyChangeListeners(name)»
            «setterAssignment(name, type)»
        }
    '''

    def private dispatch setterMethodImpl(BooleanField it, String name, String type) '''
        if ($«name» !== $this->«name.formatForCode») {
            «triggerPropertyChangeListeners(name)»
            $this->«name» = (bool)$«name»;
        }
    '''

    def private dispatch setterAssignment(DerivedField it, String name, String type) '''
            $this->«name» = $«name»;
    '''

    def private setterAssignmentNumeric(DerivedField it, String name, String type) '''
        «val aggregators = getAggregatingRelationships»
        «IF !aggregators.isEmpty»
            $diff = abs($this->«name» - $«name»);
        «ENDIF»
        $this->«name» = $«name»;
        «IF !aggregators.isEmpty»
        	«FOR aggregator : aggregators»
        	$this->«aggregator.sourceAlias.formatForCode»->add«name.formatForCodeCapital»Without«entity.name.formatForCodeCapital»($diff);
            «ENDFOR»
        «ENDIF»
    '''

    def private dispatch setterAssignment(IntegerField it, String name, String type) '''
        «setterAssignmentNumeric(name, type)»
    '''
    def private dispatch setterAssignment(DecimalField it, String name, String type) '''
        «setterAssignmentNumeric(name, type)»
    '''
    def private dispatch setterAssignment(FloatField it, String name, String type) '''
        «setterAssignmentNumeric(name, type)»
    '''

    def private dispatch setterAssignment(AbstractDateField it, String name, String type) '''
            if (is_object($«name») && $«name» instanceOf \DateTime) {
                $this->«name» = $«name»;
            } else {
                $this->«name» = new \DateTime($«name»);
            }
    '''
}
