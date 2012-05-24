package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.export

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Controller
import de.guite.modulestudio.metamodel.modulestudio.Entity
import de.guite.modulestudio.metamodel.modulestudio.StringField
import de.guite.modulestudio.metamodel.modulestudio.TextField
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions

class Kml {
    @Inject extension ControllerExtensions = new ControllerExtensions()
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()

    def generate(Entity it, String appName, Controller controller, IFileSystemAccess fsa) {
        println('Generating ' + controller.formattedName + ' kml view templates for entity "' + name.formatForDisplay + '"')
        if (controller.hasActions('view'))
            fsa.generateFile(templateFileWithExtension(controller, name, 'view', 'kml'), kmlView(appName, controller))
        if (controller.hasActions('display'))
            fsa.generateFile(templateFileWithExtension(controller, name, 'display', 'kml'), kmlDisplay(appName, controller))
    }

    def private kmlView(Entity it, String appName, Controller controller) '''
        {* purpose of this template: «nameMultiple.formatForDisplay» view kml view in «controller.formattedName» area *}
        {«appName.formatForDB»TemplateHeaders contentType='application/vnd.google-earth.kml+xml'}
        <?xml version="1.0" encoding="UTF-8"?>
        <kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2">
        <Document>
        {foreach item='item' from=$items name='coordinates'}
            <Placemark>
                «val stringFields = fields.filter(typeof(StringField)) + fields.filter(typeof(TextField))»
                <name>«IF !stringFields.isEmpty»{$item->get«stringFields.head.name.formatForCodeCapital»()}«ELSE»{gt text='«name.formatForDisplayCapital»'}«ENDIF»</name>
                <Point>
                    <coordinates>{$item->getLongitude()}, {$item->getLatitude()}, 0</coordinates>
                </Point>
            </Placemark>
        {/foreach}
        </Document>
        </kml>
    '''

    def private kmlDisplay(Entity it, String appName, Controller controller) '''
        «val objName = name.formatForCode»
        {* purpose of this template: «nameMultiple.formatForDisplay» display kml view in «controller.formattedName» area *}
        {«appName.formatForDB»TemplateHeaders contentType='application/vnd.google-earth.kml+xml'}
        <?xml version="1.0" encoding="UTF-8"?>
        <kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2">
        <Document>
            <Placemark>
                «val stringFields = fields.filter(typeof(StringField)) + fields.filter(typeof(TextField))»
                <name>«IF !stringFields.isEmpty»{$«objName»->get«stringFields.head.name.formatForCodeCapital»()}«ELSE»{gt text='«name.formatForDisplayCapital»'}«ENDIF»</name>
                <Point>
                    <coordinates>{$«objName»->getLongitude()}, {$«objName»->getLatitude()}, 0</coordinates>
                </Point>
            </Placemark>
        </Document>
        </kml>
    '''
}