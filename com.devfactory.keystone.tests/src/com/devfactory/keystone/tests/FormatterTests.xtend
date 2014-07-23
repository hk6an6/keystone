package com.devfactory.keystone.tests

import org.eclipse.xtext.junit4.InjectWith
import com.devfactory.KeyStoneInjectorProvider
import org.junit.runner.RunWith
import org.eclipse.xtext.junit4.XtextRunner
import com.google.inject.Inject
import org.eclipse.xtext.formatting.INodeModelFormatter
import static org.junit.Assert.*
import org.junit.Test
import org.eclipse.xtext.resource.XtextResource
import org.eclipse.xtext.junit4.util.ParseHelper
import com.devfactory.keyStone.ExpressionStatement

@InjectWith(KeyStoneInjectorProvider)
@RunWith(XtextRunner)
class FormatterTests {
	@Inject extension ParseHelper<ExpressionStatement>
	@Inject extension INodeModelFormatter
	
	def void assertFormattedAs(CharSequence actual, CharSequence expected){
		assertEquals(expected.toString, (actual.parse.eResource as XtextResource).parseResult.rootNode.format(0, actual.length).formattedText)
	}
	
	@Test
	def void testFormatTell(){
'''
tell x
	click
end
'''.assertFormattedAs(
'''
tell x
	click
end
'''
)
	}
}