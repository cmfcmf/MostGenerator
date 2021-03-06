package org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff

import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class DependencyInjection {
    extension FormattingExtensions = new FormattingExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    FileHelper fh = new FileHelper

    def generate(Application it, IFileSystemAccess fsa) {
        if (targets('1.3.5')) {
            return
        }
        val extensionFileName = vendor.formatForCodeCapital + name.formatForCodeCapital + 'Extension.php'
        generateClassPair(fsa, getAppSourceLibPath + 'DependencyInjection/' + extensionFileName,
            fh.phpFileContent(it, extensionBaseImpl), fh.phpFileContent(it, extensionImpl)
        )
    }

    def private extensionBaseImpl(Application it) '''
        namespace appNamespace\DependencyInjection\Base;

        use Symfony\Component\Config\FileLocator;
        use Symfony\Component\DependencyInjection\ContainerBuilder;
        use Symfony\Component\DependencyInjection\Loader\YamlFileLoader;
        use Symfony\Component\HttpKernel\DependencyInjection\Extension;

        /**
         * Base class for service definition loader using the DependencyInjection extension.
         */
        class vendor.formatForCodeCapitalname.formatForCodeCapitalExtension extends Extension
        {
            /**
             * Loads service definition file containing persistent event handlers.
             * Responds to the app.config configuration parameter.
             *
             * @param array            $configs
             * @param ContainerBuilder $container
             */
            public function load(array $configs, ContainerBuilder $container)
            {
                $loader = new YamlFileLoader($container, new FileLocator(__DIR__ . '/../../Resources/config'));
        
                $loader->load('services.yml');
            }
        }
    '''

    def private extensionImpl(Application it) '''
        namespace appNamespace\DependencyInjection;

        use appNamespace\DependencyInjection\Base\vendor.formatForCodeCapitalname.formatForCodeCapitalExtension as Basevendor.formatForCodeCapitalname.formatForCodeCapitalExtension;

        /**
         * Implementation class for service definition loader using the DependencyInjection extension.
         */
        class vendor.formatForCodeCapitalname.formatForCodeCapitalExtension extends Basevendor.formatForCodeCapitalname.formatForCodeCapitalExtension
        {
            // custom enhancements can go here
        }
    '''
}
