package org.zikula.modulestudio.generator.tests.lib;

import com.google.common.base.Objects;
import com.google.inject.Injector;
import org.eclipse.xtext.junit4.IInjectorProvider;
import org.eclipse.xtext.junit4.IRegistryConfigurator;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.jnario.lib.AbstractSpecCreator;
import org.zikula.modulestudio.generator.tests.lib.MostDslInjectorProvider;

/**
 * See http://jnario.org/org/jnario/spec/tests/integration/CustomizingTheSpecCreationSpec.html
 * and https://groups.google.com/forum/#!msg/jnario/U_jVMQKC5wA/IUQ1N3HGTK8J
 * 
 * This allows using
 *     @CreateWith(typeof(GuiceSpecCreator))
 * as a replacement for
 *     // JUnit 4 Runner, backups and restores EMF Registries
 *     @RunWith(typeof(XtextRunner)) // There is also ParameterizedXtextRunner
 *     // Google Guice Injector
 *     @InjectWith(typeof(MostDslUiInjectorProvider))
 * 
 * Detailed explaination:
 * Xtext offers a specific org.junit.runner.Runner. This allows in combination with a
 * org.eclipse.xtext.junit4.IInjectorProvider language specific injections within the test.
 * 
 * Since we have fragment = junit.Junit4Fragment {} in our workflow
 * Xtext already generated the class org.xtext.example.mydsl.MyDslInjectorProvider.
 * 
 * To wire these things up we annotate your Test with
 *     @RunWith(typeof(XtextRunner))
 * and
 *     @InjectWith(typeof(MyDslInjectorProvider))
 */
@SuppressWarnings("all")
public class GuiceSpecCreator extends AbstractSpecCreator {
  private Injector injector;
  
  private static MostDslInjectorProvider injectorProvider = new Function0<MostDslInjectorProvider>() {
    public MostDslInjectorProvider apply() {
      MostDslInjectorProvider _mostDslInjectorProvider = new MostDslInjectorProvider();
      return _mostDslInjectorProvider;
    }
  }.apply();
  
  public <T extends Object> T create(final Class<T> klass) {
    T _xblockexpression = null;
    {
      boolean _equals = Objects.equal(this.injector, null);
      if (_equals) {
        this.beforeSpecRun();
      }
      T _instance = this.injector.<T>getInstance(klass);
      _xblockexpression = (_instance);
    }
    return _xblockexpression;
  }
  
  public void beforeSpecRun() {
    IInjectorProvider _injectorProvider = GuiceSpecCreator.getInjectorProvider();
    Injector _injector = _injectorProvider.getInjector();
    this.injector = _injector;
    IInjectorProvider _injectorProvider_1 = GuiceSpecCreator.getInjectorProvider();
    if ((_injectorProvider_1 instanceof IRegistryConfigurator)) {
      IInjectorProvider _injectorProvider_2 = GuiceSpecCreator.getInjectorProvider();
      ((IRegistryConfigurator) _injectorProvider_2).setupRegistry();
    }
  }
  
  public void afterSpecRun() {
    IInjectorProvider _injectorProvider = GuiceSpecCreator.getInjectorProvider();
    if ((_injectorProvider instanceof IRegistryConfigurator)) {
      IInjectorProvider _injectorProvider_1 = GuiceSpecCreator.getInjectorProvider();
      ((IRegistryConfigurator) _injectorProvider_1).restoreRegistry();
    }
  }
  
  public static IInjectorProvider getInjectorProvider() {
    return GuiceSpecCreator.injectorProvider;
  }
}