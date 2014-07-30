package org.zikula.modulestudio.generator.cartridges.zclassic.view.formcomponents

import de.guite.modulestudio.metamodel.modulestudio.AbstractDateField
import de.guite.modulestudio.metamodel.modulestudio.BooleanField
import de.guite.modulestudio.metamodel.modulestudio.DateField
import de.guite.modulestudio.metamodel.modulestudio.DatetimeField
import de.guite.modulestudio.metamodel.modulestudio.DecimalField
import de.guite.modulestudio.metamodel.modulestudio.DerivedField
import de.guite.modulestudio.metamodel.modulestudio.EmailField
import de.guite.modulestudio.metamodel.modulestudio.EntityField
import de.guite.modulestudio.metamodel.modulestudio.FloatField
import de.guite.modulestudio.metamodel.modulestudio.IntegerField
import de.guite.modulestudio.metamodel.modulestudio.ListField
import de.guite.modulestudio.metamodel.modulestudio.StringField
import de.guite.modulestudio.metamodel.modulestudio.TextField
import de.guite.modulestudio.metamodel.modulestudio.TimeField
import de.guite.modulestudio.metamodel.modulestudio.UploadField
import de.guite.modulestudio.metamodel.modulestudio.UrlField
import de.guite.modulestudio.metamodel.modulestudio.UserField
import java.math.BigInteger
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class SimpleFields {
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    Validation validationHelper = new Validation

    def formRow(DerivedField it, String groupSuffix, String idSuffix) '''
        formLabel(groupSuffix, idSuffix)
        IF !isLegacyApp
            <div class="col-lg-9">
        ENDIF
        formField(groupSuffix, idSuffix)
        IF !isLegacyApp
            </div>
        ENDIF
        validationHelper.mandatoryValidationMessage(it, idSuffix)
        validationHelper.additionalValidationMessages(it, idSuffix)
    '''

    def private dispatch formLabel(DerivedField it, String groupSuffix, String idSuffix) '''
        initDocumentationToolTip
        {formlabel for=templateIdWithSuffix(name.formatForCode, idSuffix) __text='formLabelText'IF mandatory mandatorysym='1'ENDIFformLabelAdditions}
    '''

    def private dispatch formLabel(UploadField it, String groupSuffix, String idSuffix) '''
        initDocumentationToolTip
        IF mandatory
            {assign var='mandatorySym' value='1'}
            {if $mode ne 'create'}
                {assign var='mandatorySym' value='0'}
            {/if}
        ENDIF
        {formlabel for=templateIdWithSuffix(name.formatForCode, idSuffix) __text='formLabelText'IF mandatory mandatorysym=$mandatorySymENDIFformLabelAdditions}<br />{* break required for Google Chrome *}
    '''

    def private initDocumentationToolTip(DerivedField it) '''
        IF documentation !== null && documentation != ''
            {gt text='documentation.replace("'", '"')' assign='toolTip'}
        ENDIF
    '''

    def private formLabelAdditions(DerivedField it) ''' cssClass='IF documentation !== null && documentation != ''entity.container.application.appName.toLowerCase-form-tooltipsENDIFIF !isLegacyApp col-lg-3 control-labelENDIF'IF documentation !== null && documentation != '' title=$toolTipENDIFIF !isLegacyApp data-toggle='tooltip'ENDIF'''

    def private formLabelText(DerivedField it) {
        name.formatForDisplayCapital
    }

    def private groupAndId(EntityField it, String groupSuffix, String idSuffix) '''group=templateIdWithSuffix(entity.name.formatForDB, groupSuffix) id=templateIdWithSuffix(name.formatForCode, idSuffix)'''

    def private dispatch formField(BooleanField it, String groupSuffix, String idSuffix) '''
        {formcheckbox groupAndId(groupSuffix, idSuffix) readOnly=readonly.displayBool __title='name.formatForDisplay ?'validationHelper.fieldValidationCssClass(it, false)}
    '''

    def private dispatch formField(IntegerField it, String groupSuffix, String idSuffix) '''
        {formintinput groupAndId(groupSuffix, idSuffix) mandatory=mandatory.displayBool __title='Enter the name.formatForDisplay of the entity.name.formatForDisplay' maxLength=lengthIF minValue.toString != '0' minValue=minValueENDIFIF maxValue.toString != '0' maxValue=maxValueENDIFvalidationHelper.fieldValidationCssClass(it, true)}
        val hasMin = minValue.compareTo(BigInteger.valueOf(0)) > 0
        val hasMax = maxValue.compareTo(BigInteger.valueOf(0)) > 0
        IF hasMin || hasMax
            IF hasMin && hasMax
                IF minValue == maxValue
                    <span class="IF isLegacyAppz-formnoteELSEhelp-blockENDIF">{gt text='Note: this value must exactly be %s.' tag1='minValue'}</span>
                ELSE
                    <span class="IF isLegacyAppz-formnoteELSEhelp-blockENDIF">{gt text='Note: this value must be between %1$s and %2$s.' tag1='minValue' tag2='maxValue'}</span>
                ENDIF
            ELSEIF hasMin
                <span class="IF isLegacyAppz-formnoteELSEhelp-blockENDIF">{gt text='Note: this value must be greater than %s.' tag1='minValue'}</span>
            ELSEIF hasMax
                <span class="IF isLegacyAppz-formnoteELSEhelp-blockENDIF">{gt text='Note: this value must be less than %s.' tag1='maxValue'}</span>
            ENDIF
        ENDIF
    '''

    def private dispatch showCurrency(DecimalField it) {
        !isLegacyApp && currency
    }

    def private dispatch showCurrency(FloatField it) {
        !isLegacyApp && currency
    }

    def private dispatch formField(DecimalField it, String groupSuffix, String idSuffix) '''
        IF showCurrency
            <div class="input-group">
                <span class="input-group-addon">{gt text='$' comment='Currency symbol'}</span>
        ENDIF
            {formfloatinput groupAndId(groupSuffix, idSuffix) mandatory=mandatory.displayBool __title='Enter the name.formatForDisplay of the entity.name.formatForDisplay'IF minValue != 0 && minValue.toString != '0.0' && minValue.toString() != '0.00' minValue=minValueENDIFIF maxValue != 0 && maxValue.toString() != '0.0' && maxValue.toString() != '0.00' maxValue=maxValueENDIF maxLength=(length+3+scale)IF scale != 2 precision=scaleENDIFvalidationHelper.fieldValidationCssClass(it, true)}
        IF showCurrency
            </div>
        ENDIF
        val hasMin = minValue > 0
        val hasMax = maxValue > 0
        IF hasMin || hasMax
            IF hasMin && hasMax
                IF minValue == maxValue
                    <span class="IF isLegacyAppz-formnoteELSEhelp-blockENDIF">{gt text='Note: this value must exactly be %s.' tag1='minValue'}</span>
                ELSE
                    <span class="IF isLegacyAppz-formnoteELSEhelp-blockENDIF">{gt text='Note: this value must be between %1$s and %2$s.' tag1='minValue' tag2='maxValue'}</span>
                ENDIF
            ELSEIF hasMin
                <span class="IF isLegacyAppz-formnoteELSEhelp-blockENDIF">{gt text='Note: this value must be greater than %s.' tag1='minValue'}</span>
            ELSEIF hasMax
                <span class="IF isLegacyAppz-formnoteELSEhelp-blockENDIF">{gt text='Note: this value must be less than %s.' tag1='maxValue'}</span>
            ENDIF
        ENDIF
    '''

    def private dispatch formField(FloatField it, String groupSuffix, String idSuffix) '''
        IF showCurrency
            <div class="input-group">
                <span class="input-group-addon">{gt text='$' comment='Currency symbol'}</span>
        ENDIF
            {formfloatinput groupAndId(groupSuffix, idSuffix) mandatory=mandatory.displayBool __title='Enter the name.formatForDisplay of the entity.name.formatForDisplay'IF minValue != 0 && minValue.toString != '0.0' && minValue.toString() != '0.00' minValue=minValueENDIFIF maxValue != 0 && maxValue.toString() != '0.0' && maxValue.toString() != '0.00' maxValue=maxValueENDIFvalidationHelper.fieldValidationCssClass(it, true)}
        IF showCurrency
            </div>
        ENDIF
        val hasMin = minValue > 0
        val hasMax = maxValue > 0
        IF hasMin || hasMax
            IF hasMin && hasMax
                IF minValue == maxValue
                    <span class="IF isLegacyAppz-formnoteELSEhelp-blockENDIF">{gt text='Note: this value must exactly be %s.' tag1='minValue'}</span>
                ELSE
                    <span class="IF isLegacyAppz-formnoteELSEhelp-blockENDIF">{gt text='Note: this value must be between %1$s and %2$s.' tag1='minValue' tag2='maxValue'}</span>
                ENDIF
            ELSEIF hasMin
                <span class="IF isLegacyAppz-formnoteELSEhelp-blockENDIF">{gt text='Note: this value must be greater than %s.' tag1='minValue'}</span>
            ELSEIF hasMax
                <span class="IF isLegacyAppz-formnoteELSEhelp-blockENDIF">{gt text='Note: this value must be less than %s.' tag1='maxValue'}</span>
            ENDIF
        ENDIF
    '''

    def private dispatch formField(StringField it, String groupSuffix, String idSuffix) '''
        IF country
            {entity.container.application.appName.formatForDBCountrySelector groupAndId(groupSuffix, idSuffix) mandatory=mandatory.displayBool __title='Choose the name.formatForDisplay of the entity.name.formatForDisplay'IF !isLegacyApp cssClass='form-control'ENDIF}
        ELSEIF language || locale
            {formlanguageselector groupAndId(groupSuffix, idSuffix) mandatory=mandatory.displayBoolIF mandatory addAllOption=falseENDIF __title='Choose the name.formatForDisplay of the entity.name.formatForDisplay'IF !isLegacyApp cssClass='form-control'ENDIF}
        ELSEIF htmlcolour
            {entity.container.application.appName.formatForDBColourInput groupAndId(groupSuffix, idSuffix) mandatory=mandatory.displayBool __title='Choose the name.formatForDisplay of the entity.name.formatForDisplay'validationHelper.fieldValidationCssClass(it, true)}
        ELSE
            {formtextinput groupAndId(groupSuffix, idSuffix) mandatory=mandatory.displayBool readOnly=readonly.displayBool __title='Enter the name.formatForDisplay of the entity.name.formatForDisplay' textMode='IF passwordpasswordELSEsinglelineENDIF'IF minLength > 0 minLength=minLengthENDIF maxLength=lengthvalidationHelper.fieldValidationCssClass(it, true)}
        ENDIF
        IF regexp !== null && regexp != ''
            <span class="IF isLegacyAppz-formnoteELSEhelp-blockENDIF">{gt text='Note: this value mustIF regexpOpposite notENDIF conform to the regular expression "%s".' tag1='regexp.replace('\'', '')'}</span>
        ENDIF
    '''

    def private dispatch formField(TextField it, String groupSuffix, String idSuffix) '''
        {formtextinput groupAndId(groupSuffix, idSuffix) mandatory=mandatory.displayBool __title='Enter the name.formatForDisplay of the entity.name.formatForDisplay' textMode='multiline'IF minLength > 0 minLength=minLengthENDIF rows='6/*8*/'IF isLegacyApp cols='50'ENDIFvalidationHelper.fieldValidationCssClass(it, true)}
        IF regexp !== null && regexp != ''
            <span class="IF isLegacyAppz-formnoteELSEhelp-blockENDIF">{gt text='Note: this value mustIF regexpOpposite notENDIF conform to the regular expression "%s".' tag1='regexp.replace('\'', '')'}</span>
        ENDIF
    '''

    def private dispatch formField(EmailField it, String groupSuffix, String idSuffix) '''
        IF !isLegacyApp
            <div class="input-group">
                <span class="input-group-addon">@</span>
        ENDIF
            {formemailinput groupAndId(groupSuffix, idSuffix) mandatory=mandatory.displayBool readOnly=readonly.displayBool __title='Enter the name.formatForDisplay of the entity.name.formatForDisplay' textMode='singleline'IF minLength > 0 minLength=minLengthENDIF maxLength=lengthvalidationHelper.fieldValidationCssClass(it, true)}
        IF !isLegacyApp
            </div>
        ENDIF
    '''

    def private dispatch formField(UrlField it, String groupSuffix, String idSuffix) '''
        {formurlinput groupAndId(groupSuffix, idSuffix) mandatory=mandatory.displayBool readOnly=readonly.displayBool __title='Enter the name.formatForDisplay of the entity.name.formatForDisplay' textMode='singleline'IF minLength > 0 minLength=minLengthENDIF maxLength=lengthvalidationHelper.fieldValidationCssClass(it, true)}
    '''

    def private dispatch formField(UploadField it, String groupSuffix, String idSuffix) '''
        IF mandatory
            {if $mode eq 'create'}
                {formuploadinput groupAndId(groupSuffix, idSuffix) mandatory=mandatory.displayBool readOnly=readonly.displayBoolvalidationHelper.fieldValidationCssClass(it, true)}
            {else}
                {formuploadinput groupAndId(groupSuffix, idSuffix) mandatory=false readOnly=readonly.displayBoolvalidationHelper.fieldValidationCssClassOptional(it, true)}
                <span class="IF isLegacyAppz-formnoteELSEhelp-blockENDIF"><a id="resetname.formatForCodeCapitalVal" href="javascript:void(0);" class="IF isLegacyAppz-hideELSEhiddenENDIF">{gt text='Reset to empty value'}</a></span>
            {/if}
        ELSE
            {formuploadinput groupAndId(groupSuffix, idSuffix) mandatory=false readOnly=readonly.displayBoolvalidationHelper.fieldValidationCssClassOptional(it, true)}
            <span class="IF isLegacyAppz-formnoteELSEhelp-blockENDIF"><a id="resetname.formatForCodeCapitalVal" href="javascript:void(0);" class="IF isLegacyAppz-hideELSEhiddenENDIF" IF isLegacyAppstyle="clear:left;"ENDIF>{gt text='Reset to empty value'}</a></span>
        ENDIF

            <span class="IF isLegacyAppz-formnoteELSEhelp-blockENDIF">{gt text='Allowed file extensions:'} <span id="name.formatForCodeFileExtensions">allowedExtensions</span></span>
        IF allowedFileSize > 0
            <span class="IF isLegacyAppz-formnoteELSEhelp-blockENDIF">{gt text='Allowed file size:'} {'allowedFileSize'|entity.container.application.appName.formatForDBGetFileSize:'':false:false}</span>
        ENDIF
        decideWhetherToShowCurrentFile
    '''

    def private decideWhetherToShowCurrentFile(UploadField it) '''
        val fieldName = entity.name.formatForDB + '.' + name.formatForCode
        {if $mode ne 'create'}
            {if $fieldName ne ''}
                showCurrentFile
            {/if}
        {/if}
    '''

    def private showCurrentFile(UploadField it) '''
        val appNameSmall = entity.container.application.appName.formatForDB
        val objName = entity.name.formatForDB
        val realName = objName + '.' + name.formatForCode
        <span class="IF isLegacyAppz-formnoteELSEhelp-blockENDIF">
            {gt text='Current file'}:
            <a href="{$realNameFullPathUrl}" title="{$formattedEntityTitle|replace:"\"":""}"{if $realNameMeta.isImage} IF isLegacyApprel="imageviewer[entity.name.formatForDB]"ELSEclass="lightbox"ENDIF{/if}>
            {if $realNameMeta.isImage}
                {thumb image=$realNameFullPath objectid="entity.name.formatForCodeIF entity.hasCompositeKeysFOR pkField : entity.getPrimaryKeyFields-`$objName.pkField.name.formatForCode`ENDFORELSE-`$objName.entity.primaryKeyFields.head.name.formatForCode`ENDIF" preset=$entity.name.formatForCodeThumbPresetname.formatForCodeCapital tag=true img_alt=$formattedEntityTitleIF !isLegacyApp img_class='img-thumbnail'ENDIF}
            {else}
                {gt text='Download'} ({$realNameMeta.size|appNameSmallGetFileSize:$realNameFullPath:false:false})
            {/if}
            </a>
        </span>
        IF !mandatory
            <span class="IF isLegacyAppz-formnoteELSEhelp-blockENDIF">
                {formcheckbox group='entity.name.formatForDB' id='name.formatForCodeDeleteFile' readOnly=false __title='Delete name.formatForDisplay ?'}
                {formlabel for='name.formatForCodeDeleteFile' __text='Delete existing file'}
            </span>
        ENDIF
    '''

    def private dispatch formField(ListField it, String groupSuffix, String idSuffix) '''
        IF multiple == true && useChecks == true
            {formcheckboxlist groupAndId(groupSuffix, idSuffix) mandatory=mandatory.displayBool __title='Choose the name.formatForDisplay' repeatColumns=2IF !isLegacyApp cssClass='form-control'ENDIF}
        ELSE
            {formdropdownlist groupAndId(groupSuffix, idSuffix) mandatory=mandatory.displayBool __title='Choose the name.formatForDisplay' selectionMode='IF multiplemultipleELSEsingleENDIF'IF !isLegacyApp cssClass='form-control'ENDIF}
        ENDIF
        IF multiple && min > 0 && max > 0
            IF min == max
                <span class="IF isLegacyAppz-formnoteELSEhelp-blockENDIF">{gt text='Note: you must select exactly %s choices.' tag1='min'}</span>
            ELSE
                <span class="IF isLegacyAppz-formnoteELSEhelp-blockENDIF">{gt text='Note: you must select between %1$s and %2$s choices.' tag1='min' tag2='max'}</span>
            ENDIF
        ENDIF
    '''

    def private dispatch formField(UserField it, String groupSuffix, String idSuffix) '''
        {entity.container.application.appName.formatForDBUserInput groupAndId(groupSuffix, idSuffix) mandatory=mandatory.displayBool readOnly=readonly.displayBool __title='Enter a part of the user name to search' cssClass='IF mandatoryrequiredENDIFIF !isLegacyAppIF mandatory ENDIFform-controlENDIF'}
        {if $mode ne 'create' && $entity.name.formatForDB.name.formatForDB && !$inlineUsage}
            <span class="IF isLegacyAppz-formnoteELSEhelp-blockENDIF avatar">
                {useravatar uid=$entity.name.formatForDB.name.formatForDB rating='g'}
            </span>
            {checkpermissionblock component='Users::' instance='::' level='ACCESS_ADMIN'}
            <span class="IF isLegacyAppz-formnoteELSEhelp-blockENDIF"><a href="{modurl modname='IF isLegacyAppUsersELSEZikulaUsersModuleENDIF' type='admin' func='modify' userid=$entity.name.formatForDB.name.formatForDB}" title="{gt text='Switch to users administration'}">{gt text='Manage user'}</a></span>
            {/checkpermissionblock}
        {/if}
    '''

    def private dispatch formField(AbstractDateField it, String groupSuffix, String idSuffix) '''
        formFieldDetails(groupSuffix, idSuffix)
        IF past
            <span class="IF isLegacyAppz-formnoteELSEhelp-blockENDIF">{gt text='Note: this value must be in the past.'}</span>
        ELSEIF future
            <span class="IF isLegacyAppz-formnoteELSEhelp-blockENDIF">{gt text='Note: this value must be in the future.'}</span>
        ENDIF
    '''

    def private dispatch formFieldDetails(AbstractDateField it, String groupSuffix, String idSuffix) {
    }
    def private dispatch formFieldDetails(DatetimeField it, String groupSuffix, String idSuffix) '''
        {if $mode ne 'create'}
            {formdateinput groupAndId(groupSuffix, idSuffix) mandatory=mandatory.displayBool __title='Enter the name.formatForDisplay of the entity.name.formatForDisplay' includeTime=truevalidationHelper.fieldValidationCssClass(it, true)}
        {else}
            {formdateinput groupAndId(groupSuffix, idSuffix) mandatory=mandatory.displayBool __title='Enter the name.formatForDisplay of the entity.name.formatForDisplay' includeTime=trueIF defaultValue !== null && defaultValue != '' && defaultValue != 'now' defaultValue='defaultValue'ELSEIF mandatory || !nullable defaultValue='now'ENDIFvalidationHelper.fieldValidationCssClass(it, true)}
        {/if}
        /*TODO: visible=false*/
        IF !mandatory && nullable
            <span class="IF isLegacyAppz-formnoteELSEhelp-blockENDIF"><a id="resetname.formatForCodeCapitalVal" href="javascript:void(0);" class="IF isLegacyAppz-hideELSEhiddenENDIF">{gt text='Reset to empty value'}</a></span>
        ENDIF
    '''

    def private dispatch formFieldDetails(DateField it, String groupSuffix, String idSuffix) '''
        {if $mode ne 'create'}
            {formdateinput groupAndId(groupSuffix, idSuffix) mandatory=mandatory.displayBool __title='Enter the name.formatForDisplay of the entity.name.formatForDisplay' useSelectionMode=truevalidationHelper.fieldValidationCssClass(it, true)}
        {else}
            {formdateinput groupAndId(groupSuffix, idSuffix) mandatory=mandatory.displayBool __title='Enter the name.formatForDisplay of the entity.name.formatForDisplay' useSelectionMode=trueIF defaultValue !== null && defaultValue != '' && defaultValue != 'now' defaultValue='defaultValue'ELSEIF mandatory || !nullable defaultValue='today'ENDIFvalidationHelper.fieldValidationCssClass(it, true)}
        {/if}
        IF !mandatory && nullable
            <span class="IF isLegacyAppz-formnoteELSEhelp-blockENDIF"><a id="resetname.formatForCodeCapitalVal" href="javascript:void(0);" class="IF isLegacyAppz-hideELSEhiddenENDIF">{gt text='Reset to empty value'}</a></span>
        ENDIF
    '''

    def private dispatch formFieldDetails(TimeField it, String groupSuffix, String idSuffix) '''
        {* TODO: support time fields in Zikula (see https://github.com/Guite/MostGenerator/issues/87 for more information) *}
        {formtextinput groupAndId(groupSuffix, idSuffix) mandatory=mandatory.displayBool readOnly=readonly.displayBool __title='Enter the name.formatForDisplay of the entity.name.formatForDisplay' textMode='singleline' maxLength=8validationHelper.fieldValidationCssClass(it, true)}
    '''

    def private isLegacyApp(DerivedField it) {
        entity.container.application.targets('1.3.5')
    }
}
