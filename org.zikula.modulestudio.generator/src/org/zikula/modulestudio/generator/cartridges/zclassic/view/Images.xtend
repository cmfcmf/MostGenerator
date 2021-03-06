package org.zikula.modulestudio.generator.cartridges.zclassic.view

import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Images {
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    /**
     * Entry point for all application images.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        val imagePath = getAppImagePath
        if (!shouldBeSkipped(imagePath + 'index.html')) {
            // This index.html file will be removed later. At the moment we need it to create according directories.
            fsa.generateFile(imagePath + 'index.html', msUrl)
        }

        if (!shouldBeSkipped(imagePath + 'admin.png')) {
            //fsa.generateFile(imagePath + 'admin.png', adminImage)
        }
    }

    /**
     * admin icon 48x48
     * /
    def private adminImage(Application it) {
    }*/
}
