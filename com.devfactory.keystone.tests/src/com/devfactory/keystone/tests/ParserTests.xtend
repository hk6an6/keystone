package com.devfactory.keystone.tests

import org.eclipse.xtext.junit4.InjectWith
import com.devfactory.KeyStoneInjectorProvider
import org.junit.runner.RunWith
import org.eclipse.xtext.junit4.XtextRunner
import com.devfactory.keyStone.ExpressionStatement
import org.eclipse.xtext.junit4.util.ParseHelper
import com.google.inject.Inject
import static org.junit.Assert.*
import org.junit.Test
import org.eclipse.xtext.junit4.validation.ValidationTestHelper
import com.devfactory.keyStone.Assertion
import com.devfactory.keyStone.Action
import com.devfactory.keyStone.OpenBrowserActionParams
import com.devfactory.keyStone.BrowseToActionParams
import com.devfactory.keyStone.Step
import com.devfactory.keyStone.SearchSettings
import com.devfactory.keyStone.KeyboardActionParams
import com.devfactory.keyStone.DragActionParams
import com.devfactory.keyStone.Assignment
import com.devfactory.keyStone.DataDrivenStep

@InjectWith(KeyStoneInjectorProvider)
@RunWith(XtextRunner)
class ParserTests {
	@Inject extension ParseHelper<ExpressionStatement>
	@Inject extension ValidationTestHelper
	@Test
	def void parseLiteral() {
		val syntaxRoot = '''
tell a(1)
	click
end
'''.parse
		syntaxRoot.assertNoErrors
		assertEquals('1', syntaxRoot.expression.head.context.arguments.head.value)
	}
	
	@Test
	def void parseLiteralWithLogFolder() {
		val syntaxRoot = '''
#the log folder name
tell a(1)
	click
end
'''.parse
		syntaxRoot.assertNoErrors
		assertEquals('#the log folder name', syntaxRoot.expression.head.folderName.trim)
		assertEquals('1', syntaxRoot.expression.head.context.arguments.head.value)
	}

	@Test
	def void parseLiteral2() {
		val syntaxRoot = '''
tell a(12)
	click
end
'''.parse
		syntaxRoot.assertNoErrors
		assertEquals('12', syntaxRoot.expression.head.context.arguments.head.value)
	}

	@Test
	def void parseLiteral3() {
		val syntaxRoot = '''
tell a(01)
	click
end
'''.parse
		syntaxRoot.assertNoErrors
		assertEquals('01', syntaxRoot.expression.head.context.arguments.head.value)
	}

	@Test
	def void parseLiteral4() {
		val syntaxRoot = '''
tell a(001)
	click
end
'''.parse
		syntaxRoot.assertNoErrors
		assertEquals('001', syntaxRoot.expression.head.context.arguments.head.value)
	}

	@Test
	def void parseLiteral5() {
		val syntaxRoot = '''
tell a(100)
	click
end
'''.parse
		syntaxRoot.assertNoErrors
		assertEquals('100', syntaxRoot.expression.head.context.arguments.head.value)
	}

	@Test
	def void parseLiteral6() {
		val syntaxRoot = '''
tell a(1.0)
	click
end
'''.parse
		syntaxRoot.assertNoErrors
		assertEquals('1.0', syntaxRoot.expression.head.context.arguments.head.value)
	}

	@Test
	def void parseLiteral7() {
		val syntaxRoot = '''
tell a(01.01)
	click
end
'''.parse
		syntaxRoot.assertNoErrors
		assertEquals('01.01', syntaxRoot.expression.head.context.arguments.head.value)
	}

	@Test
	def void parseLiteral8() {
		val syntaxRoot = '''
tell a(001.001)
	click
end
'''.parse
		syntaxRoot.assertNoErrors
		assertEquals('001.001', syntaxRoot.expression.head.context.arguments.head.value)
	}

	@Test
	def void parseLiteral9() {
		val syntaxRoot = '''
tell a(true)
	click
end
'''.parse
		syntaxRoot.assertNoErrors
		assertEquals('true', syntaxRoot.expression.head.context.arguments.head.value)
	}

	@Test
	def void parseLiteral10() {
		val syntaxRoot = '''
tell a(false)
	click
end
'''.parse
		syntaxRoot.assertNoErrors
		assertEquals('false', syntaxRoot.expression.head.context.arguments.head.value)
	}

	@Test
	def void parseLiteral11() {
		val syntaxRoot = '''
tell a("this is a string")
	click
end
'''.parse
		syntaxRoot.assertNoErrors
		assertEquals('this is a string', syntaxRoot.expression.head.context.arguments.head.value)
	}

	@Test
	def void parseLiteral12() {
		val syntaxRoot = '''
tell a('this is a string')
	click
end
'''.parse
		syntaxRoot.assertNoErrors
		assertEquals("this is a string", syntaxRoot.expression.head.context.arguments.head.value)
	}

	@Test
	def void parseFailure() {
		try {
			val syntaxRoot = '''
1
'''.parse
			syntaxRoot.assertNoErrors
			assertEquals('001', syntaxRoot.expression.head.context.arguments.head.value)
			assertEquals('fail if you reach this line!', syntaxRoot.expression.head.context.arguments.head.value)
		} catch (Throwable x) {
			assertTrue("parsing failed, just as expected!", true);
		}
	}

	@Test
	def void parseIdentifier() {
		val syntaxRoot = '''
tell x
	click
end
'''.parse
		syntaxRoot.assertNoErrors
		assertEquals('x', syntaxRoot.expression.head.context.value)
	}

	@Test
	def void parseIdentifier2() {
		val syntaxRoot = '''
tell x_yz12
	click
end
'''.parse
		syntaxRoot.assertNoErrors
		assertEquals('x_yz12', syntaxRoot.expression.head.context.value)
	}

	@Test
	def void parseMember() {
		val syntaxRoot = '''
tell x.b
	click
end
'''.parse
		syntaxRoot.assertNoErrors
		assertEquals('x', syntaxRoot.expression.head.context.left.value)
		assertEquals('b', syntaxRoot.expression.head.context.right.value)
	}

	@Test
	def void parseMember2() {
		val syntaxRoot = '''
tell x.b.c
	click
end
'''.parse
		syntaxRoot.assertNoErrors
		assertEquals('x', syntaxRoot.expression.head.context.left.left.value)
		assertEquals('b', syntaxRoot.expression.head.context.left.right.value)
		assertEquals('c', syntaxRoot.expression.head.context.right.value)
	}

	@Test
	def void parseMember3() {
		val syntaxRoot = '''
tell a.x_yz12.c.x_yz14
	click
end
'''.parse
		syntaxRoot.assertNoErrors
		assertEquals('a', syntaxRoot.expression.head.context.left.left.left.value)
		assertEquals('x_yz12', syntaxRoot.expression.head.context.left.left.right.value)
		assertEquals('c', syntaxRoot.expression.head.context.left.right.value)
		assertEquals('x_yz14', syntaxRoot.expression.head.context.right.value)
	}

	@Test
	def void parseCall() {
		val syntaxRoot = '''
tell b()
	click
end
'''.parse
		syntaxRoot.assertNoErrors
		assertEquals('b', syntaxRoot.expression.head.context.left.value)
	}

	@Test
	def void parseCall1() {
		val syntaxRoot = '''
tell x(1)
	click
end
'''.parse
		syntaxRoot.assertNoErrors
		assertEquals('x', syntaxRoot.expression.head.context.left.value)
		assertEquals('1', syntaxRoot.expression.head.context.arguments.head.value)
	}

	@Test
	def void parseCall2() {
		val syntaxRoot = '''
tell x(c.d)
	click
end
'''.parse
		syntaxRoot.assertNoErrors
		assertEquals('x', syntaxRoot.expression.head.context.left.value)
		assertEquals('c', syntaxRoot.expression.head.context.arguments.head.left.value)
		assertEquals('d', syntaxRoot.expression.head.context.arguments.head.right.value)
	}

	@Test
	def void parseCall3() {
		val syntaxRoot = '''
tell x(c.d())
	click
end
'''.parse
		syntaxRoot.assertNoErrors
		assertEquals('x', syntaxRoot.expression.head.context.left.value)
		assertEquals('c', syntaxRoot.expression.head.context.arguments.head.left.value)
		assertEquals('d', syntaxRoot.expression.head.context.arguments.head.right.left.value)
	}

	@Test
	def void parseCall4() {
		val syntaxRoot = '''
tell x().d()
	click
end
'''.parse
		syntaxRoot.assertNoErrors
		assertEquals('x', syntaxRoot.expression.head.context.left.left.value)
		assertEquals('d', syntaxRoot.expression.head.context.right.left.value)
	}

	@Test
	def void parseSelector() {
		val syntaxRoot = '''
tell x of b
	click
end
'''.parse
		syntaxRoot.assertNoErrors
		assertEquals('x', syntaxRoot.expression.head.context.left.value)
		assertEquals('b', syntaxRoot.expression.head.context.right.value)
	}

	@Test
	def void parseSelector2() {
		val syntaxRoot = '''
tell x of b of c
	click
end
'''.parse
		syntaxRoot.assertNoErrors
		assertEquals('x', syntaxRoot.expression.head.context.left.left.value)
		assertEquals('b', syntaxRoot.expression.head.context.left.right.value)
		assertEquals('c', syntaxRoot.expression.head.context.right.value)
	}
	
	@Test
	def void parseSimpleAssert() {
		val syntaxRoot = '''
tell x
	assert a 1
end
'''.parse
		syntaxRoot.assertNoErrors
		assertEquals('x', syntaxRoot.expression.head.context.value)
		assertEquals('a', (syntaxRoot.expression.head.actions.head as Assertion).filter.property.value)
		assertEquals('1', (syntaxRoot.expression.head.actions.head as Assertion).filter.value.value)
	}
	
	@Test
	def void parseSimpleAssert2() {
		val syntaxRoot = '''
tell x
	assert a "'this is a string'"
end
'''.parse
		syntaxRoot.assertNoErrors
		assertEquals('x', syntaxRoot.expression.head.context.value)
		assertEquals('a', (syntaxRoot.expression.head.actions.head as Assertion).filter.property.value)
		assertEquals("'this is a string'", (syntaxRoot.expression.head.actions.head as Assertion).filter.value.value)
	}
	
	@Test
	def void parseSimpleAssert3() {
		val syntaxRoot = '''
tell x
	assert a '"this is a string"'
end
'''.parse
		syntaxRoot.assertNoErrors
		assertEquals('x', syntaxRoot.expression.head.context.value)
		assertEquals('a', (syntaxRoot.expression.head.actions.head as Assertion).filter.property.value)
		assertEquals("\"this is a string\"", (syntaxRoot.expression.head.actions.head as Assertion).filter.value.value)
	}
	
	@Test
	def void parseSimpleAssert4() {
		val syntaxRoot = '''
tell x
	assert a true
end
'''.parse
		syntaxRoot.assertNoErrors
		assertEquals('x', syntaxRoot.expression.head.context.value)
		assertEquals('a', (syntaxRoot.expression.head.actions.head as Assertion).filter.property.value)
		assertEquals("true", (syntaxRoot.expression.head.actions.head as Assertion).filter.value.value)
	}
	
	@Test
	def void parseSimpleAssert5() {
		val syntaxRoot = '''
tell x
	assert a 1 and b 2
end
'''.parse
		syntaxRoot.assertNoErrors
		assertEquals('x', syntaxRoot.expression.head.context.value)
		assertEquals('a', (syntaxRoot.expression.head.actions.head as Assertion).filter.left.property.value)
		assertEquals("1", (syntaxRoot.expression.head.actions.head as Assertion).filter.left.value.value)
		assertEquals('b', (syntaxRoot.expression.head.actions.head as Assertion).filter.right.property.value)
		assertEquals("2", (syntaxRoot.expression.head.actions.head as Assertion).filter.right.value.value)
	}
	
	@Test
	def void parseSimpleAssert6() {
		val syntaxRoot = '''
tell x
	assert a 1 and b 2 and c 3
end
'''.parse
		syntaxRoot.assertNoErrors
		assertEquals('x', syntaxRoot.expression.head.context.value)
		assertEquals('a', (syntaxRoot.expression.head.actions.head as Assertion).filter.left.property.value)
		assertEquals("1", (syntaxRoot.expression.head.actions.head as Assertion).filter.left.value.value)
		assertEquals('b', (syntaxRoot.expression.head.actions.head as Assertion).filter.right.left.property.value)
		assertEquals("2", (syntaxRoot.expression.head.actions.head as Assertion).filter.right.left.value.value)
		assertEquals('c', (syntaxRoot.expression.head.actions.head as Assertion).filter.right.right.property.value)
		assertEquals("3", (syntaxRoot.expression.head.actions.head as Assertion).filter.right.right.value.value)
	}
	
	@Test
	def void parseSimpleAssert7() {
		val syntaxRoot = '''
tell x
	assert a /a[rg]egex/
end
'''.parse
		syntaxRoot.assertNoErrors
		assertEquals('x', syntaxRoot.expression.head.context.value)
		assertEquals('a', (syntaxRoot.expression.head.actions.head as Assertion).filter.property.value)
		assertEquals('/a[rg]egex/', (syntaxRoot.expression.head.actions.head as Assertion).filter.value.value)
	}
	
	@Test
	def void parseSimpleAssert8() {
		val syntaxRoot = '''
tell x
	assert a /a[rg]egex/ and b 2 and c 3
end
'''.parse
		syntaxRoot.assertNoErrors
		assertEquals('x', syntaxRoot.expression.head.context.value)
		assertEquals('a', (syntaxRoot.expression.head.actions.head as Assertion).filter.left.property.value)
		assertEquals("/a[rg]egex/", (syntaxRoot.expression.head.actions.head as Assertion).filter.left.value.value)
		assertEquals('b', (syntaxRoot.expression.head.actions.head as Assertion).filter.right.left.property.value)
		assertEquals("2", (syntaxRoot.expression.head.actions.head as Assertion).filter.right.left.value.value)
		assertEquals('c', (syntaxRoot.expression.head.actions.head as Assertion).filter.right.right.property.value)
		assertEquals("3", (syntaxRoot.expression.head.actions.head as Assertion).filter.right.right.value.value)
	}
	
	@Test
	def void parseSimpleAssert9() {
		val syntaxRoot = '''
tell x
	assert a regex c
end
'''.parse
		syntaxRoot.assertNoErrors
		assertEquals('x', syntaxRoot.expression.head.context.value)
		assertEquals('a', (syntaxRoot.expression.head.actions.head as Assertion).filter.property.value)
		assertEquals('c', (syntaxRoot.expression.head.actions.head as Assertion).filter.value.value)
		assertTrue((syntaxRoot.expression.head.actions.head as Assertion).filter.valueIsRegex)
	}
	
	@Test
	def void parseSimpleAssert10() {
		val syntaxRoot = '''
tell x
	assert a regex c and b 2 and c 3
end
'''.parse
		syntaxRoot.assertNoErrors
		assertEquals('x', syntaxRoot.expression.head.context.value)
		assertEquals('a', (syntaxRoot.expression.head.actions.head as Assertion).filter.left.property.value)
		assertEquals("c", (syntaxRoot.expression.head.actions.head as Assertion).filter.left.value.value)
		assertTrue((syntaxRoot.expression.head.actions.head as Assertion).filter.left.valueIsRegex)
		assertEquals('b', (syntaxRoot.expression.head.actions.head as Assertion).filter.right.left.property.value)
		assertEquals("2", (syntaxRoot.expression.head.actions.head as Assertion).filter.right.left.value.value)
		assertEquals('c', (syntaxRoot.expression.head.actions.head as Assertion).filter.right.right.property.value)
		assertEquals("3", (syntaxRoot.expression.head.actions.head as Assertion).filter.right.right.value.value)
	}
	
	@Test
	def void parseSimpleAssert11() {
		val syntaxRoot = '''
tell x
	assert not found [wText "hello"]:0
end
'''.parse
		syntaxRoot.assertNoErrors
		assertEquals('x', syntaxRoot.expression.head.context.value)
		assertEquals('wText', ((syntaxRoot.expression.head.actions.head as Assertion).child as SearchSettings).properties.head.value)
		assertEquals('hello', ((syntaxRoot.expression.head.actions.head as Assertion).child as SearchSettings).expected.head.value)
		assertEquals(true, (syntaxRoot.expression.head.actions.head as Assertion).negated)
	}
	
	@Test
	def void parseSimpleAssert12() {
		val syntaxRoot = '''
tell x
	assert found [wText "hello"]:0
end
'''.parse
		syntaxRoot.assertNoErrors
		assertEquals('x', syntaxRoot.expression.head.context.value)
		assertEquals('wText', ((syntaxRoot.expression.head.actions.head as Assertion).child as SearchSettings).properties.head.value)
		assertEquals('hello', ((syntaxRoot.expression.head.actions.head as Assertion).child as SearchSettings).expected.head.value)
		assertEquals(false, (syntaxRoot.expression.head.actions.head as Assertion).negated)
	}
	
	@Test
	def void parseSimpleAssert13() {
		val syntaxRoot = '''
tell x
	assert not wText "hello"
end
'''.parse
		syntaxRoot.assertNoErrors
		assertEquals('x', syntaxRoot.expression.head.context.value)
		assertEquals(true, (syntaxRoot.expression.head.actions.head as Assertion).negated)
		assertEquals('wText', (syntaxRoot.expression.head.actions.head as Assertion).filter.property.value)
		assertEquals('hello', (syntaxRoot.expression.head.actions.head as Assertion).filter.value.value)
	}
	
	@Test
	def void parseSimpleAssert14() {
		val syntaxRoot = '''
tell x
	assert not wText /hello/
end
'''.parse
		syntaxRoot.assertNoErrors
		assertEquals('x', syntaxRoot.expression.head.context.value)
		assertEquals(true, (syntaxRoot.expression.head.actions.head as Assertion).negated)
		assertEquals('wText', (syntaxRoot.expression.head.actions.head as Assertion).filter.property.value)
		assertEquals('/hello/', (syntaxRoot.expression.head.actions.head as Assertion).filter.value.value)
	}
	
	@Test
	def void parseSimpleAssert15() {
		val syntaxRoot = '''
tell x
	assert wText lt "hello"
end
'''.parse
		syntaxRoot.assertNoErrors
		assertEquals('x', syntaxRoot.expression.head.context.value)
		assertEquals(false, (syntaxRoot.expression.head.actions.head as Assertion).negated)
		assertEquals('wText', (syntaxRoot.expression.head.actions.head as Assertion).filter.property.value)
		assertEquals('hello', (syntaxRoot.expression.head.actions.head as Assertion).filter.value.value)
		assertEquals('lt', (syntaxRoot.expression.head.actions.head as Assertion).filter.operator)
	}
	
	@Test
	def void parseSimpleAssert16() {
		val syntaxRoot = '''
tell x
	assert wText gt "hello"
end
'''.parse
		syntaxRoot.assertNoErrors
		assertEquals('x', syntaxRoot.expression.head.context.value)
		assertEquals(false, (syntaxRoot.expression.head.actions.head as Assertion).negated)
		assertEquals('wText', (syntaxRoot.expression.head.actions.head as Assertion).filter.property.value)
		assertEquals('hello', (syntaxRoot.expression.head.actions.head as Assertion).filter.value.value)
		assertEquals('gt', (syntaxRoot.expression.head.actions.head as Assertion).filter.operator)
	}
	
	@Test
	def void parseSimpleAssert17() {
		val syntaxRoot = '''
tell x
	assert wText lte "hello"
end
'''.parse
		syntaxRoot.assertNoErrors
		assertEquals('x', syntaxRoot.expression.head.context.value)
		assertEquals(false, (syntaxRoot.expression.head.actions.head as Assertion).negated)
		assertEquals('wText', (syntaxRoot.expression.head.actions.head as Assertion).filter.property.value)
		assertEquals('hello', (syntaxRoot.expression.head.actions.head as Assertion).filter.value.value)
		assertEquals('lte', (syntaxRoot.expression.head.actions.head as Assertion).filter.operator)
	}
	
	@Test
	def void parseSimpleAssert18() {
		val syntaxRoot = '''
tell x
	assert wText gte "hello"
end
'''.parse
		syntaxRoot.assertNoErrors
		assertEquals('x', syntaxRoot.expression.head.context.value)
		assertEquals(false, (syntaxRoot.expression.head.actions.head as Assertion).negated)
		assertEquals('wText', (syntaxRoot.expression.head.actions.head as Assertion).filter.property.value)
		assertEquals('hello', (syntaxRoot.expression.head.actions.head as Assertion).filter.value.value)
		assertEquals('gte', (syntaxRoot.expression.head.actions.head as Assertion).filter.operator)
	}
	
	@Test
	def void parseOpenBrowser(){
		val syntaxRoot =
'''
tell Browsers
	open browser InternetExplorer
end
'''.parse
		syntaxRoot.assertNoErrors
		assertEquals('Browsers', syntaxRoot.expression.head.context.value)
		assertEquals('open', (syntaxRoot.expression.head.actions.head as Action).name)
		assertTrue((syntaxRoot.expression.head.actions.head as Action).actionParams instanceof OpenBrowserActionParams)
		assertEquals('InternetExplorer', ((syntaxRoot.expression.head.actions.head as Action).actionParams as OpenBrowserActionParams).browserName)
	}
	
	@Test
	def void parseBrowseTo(){
		val syntaxRoot =
'''
tell Browsers.CurrentBrowser
	browse to "http://www.google.com"
end
'''.parse
		syntaxRoot.assertNoErrors
		assertEquals('Browsers', syntaxRoot.expression.head.context.left.value)
		assertEquals('CurrentBrowser', syntaxRoot.expression.head.context.right.value)
		assertEquals('browse', (syntaxRoot.expression.head.actions.head as Action).name)
		assertTrue((syntaxRoot.expression.head.actions.head as Action).actionParams instanceof BrowseToActionParams)
		assertEquals("http://www.google.com", ((syntaxRoot.expression.head.actions.head as Action).actionParams as BrowseToActionParams).url.value)
	}
	
	@Test
	def void parseTerminate(){
		val syntaxRoot =
'''
tell Browsers.CurrentBrowser
	terminate
end
'''.parse
		syntaxRoot.assertNoErrors
		assertEquals('Browsers', syntaxRoot.expression.head.context.left.value)
		assertEquals('CurrentBrowser', syntaxRoot.expression.head.context.right.value)
		assertEquals('terminate', (syntaxRoot.expression.head.actions.head as Action).name)
	}
	
	@Test
	def void parseClose(){
		val syntaxRoot =
'''
tell Browsers.CurrentBrowser
	close
end
'''.parse
		syntaxRoot.assertNoErrors
		assertEquals('Browsers', syntaxRoot.expression.head.context.left.value)
		assertEquals('CurrentBrowser', syntaxRoot.expression.head.context.right.value)
		assertEquals('close', (syntaxRoot.expression.head.actions.head as Action).name)
	}
	
	@Test
	def void parseMaximize(){
		val syntaxRoot =
'''
tell x
	maximize
end
'''.parse
		syntaxRoot.assertNoErrors
		assertEquals('x', syntaxRoot.expression.head.context.value)
		assertEquals('maximize', (syntaxRoot.expression.head.actions.head as Action).name)
	}
	
	@Test
	def void parseRun(){
		val syntaxRoot =
'''
tell TestedApps.Items(0)
	run
end
'''.parse
		syntaxRoot.assertNoErrors
		assertEquals('TestedApps', syntaxRoot.expression.head.context.left.value)
		assertEquals('Items', syntaxRoot.expression.head.context.right.left.value)
		assertEquals('run', (syntaxRoot.expression.head.actions.head as Action).name)
	}
	
	@Test
	def void parseSimpleDrag(){
		val syntaxRoot =
'''
tell x
	drag to 5 10
end
'''.parse
		syntaxRoot.assertNoErrors
		assertEquals('x', syntaxRoot.expression.head.context.value)
		assertEquals('drag', (syntaxRoot.expression.head.actions.head as Action).name)
		assertEquals('5', ((syntaxRoot.expression.head.actions.head as Action).actionParams as DragActionParams).x)
		assertEquals('10', ((syntaxRoot.expression.head.actions.head as Action).actionParams as DragActionParams).y)
	}
	
	@Test
	def void parseDragToObject(){
		val syntaxRoot =
'''
tell x
	drag to y
end
'''.parse
		syntaxRoot.assertNoErrors
		assertEquals('x', syntaxRoot.expression.head.context.value)
		assertEquals('drag', (syntaxRoot.expression.head.actions.head as Action).name)
		assertEquals('y', ((syntaxRoot.expression.head.actions.head as Action).actionParams as DragActionParams).target.value)
	}
	
	@Test
	def void parseDragToObjectWithDropsite(){
		val syntaxRoot =
'''
tell x
	drag to y 5 5
end
'''.parse
		syntaxRoot.assertNoErrors
		assertEquals('x', syntaxRoot.expression.head.context.value)
		assertEquals('drag', (syntaxRoot.expression.head.actions.head as Action).name)
		assertEquals('y', ((syntaxRoot.expression.head.actions.head as Action).actionParams as DragActionParams).target.value)
		assertEquals('5', ((syntaxRoot.expression.head.actions.head as Action).actionParams as DragActionParams).x)
		assertEquals('5', ((syntaxRoot.expression.head.actions.head as Action).actionParams as DragActionParams).y)
	}
	
	@Test
	def void parseDragToObjectGrabFrom(){
		val syntaxRoot =
'''
tell x
	drag to y grab from 5 10
end
'''.parse
		syntaxRoot.assertNoErrors
		assertEquals('x', syntaxRoot.expression.head.context.value)
		assertEquals('drag', (syntaxRoot.expression.head.actions.head as Action).name)
		assertEquals('y', ((syntaxRoot.expression.head.actions.head as Action).actionParams as DragActionParams).target.value)
		assertTrue(((syntaxRoot.expression.head.actions.head as Action).actionParams as DragActionParams).grab)
		assertEquals('5', ((syntaxRoot.expression.head.actions.head as Action).actionParams as DragActionParams).OX)
		assertEquals('10', ((syntaxRoot.expression.head.actions.head as Action).actionParams as DragActionParams).OY)
	}
	
	@Test
	def void parseDragToCoordinateGrabFrom(){
		val syntaxRoot =
'''
tell x
	drag to 1 2 grab from 5 10
end
'''.parse
		syntaxRoot.assertNoErrors
		assertEquals('x', syntaxRoot.expression.head.context.value)
		assertEquals('drag', (syntaxRoot.expression.head.actions.head as Action).name)
		assertEquals('1', ((syntaxRoot.expression.head.actions.head as Action).actionParams as DragActionParams).x)
		assertEquals('2', ((syntaxRoot.expression.head.actions.head as Action).actionParams as DragActionParams).y)
		assertTrue(((syntaxRoot.expression.head.actions.head as Action).actionParams as DragActionParams).grab)
		assertEquals('5', ((syntaxRoot.expression.head.actions.head as Action).actionParams as DragActionParams).OX)
		assertEquals('10', ((syntaxRoot.expression.head.actions.head as Action).actionParams as DragActionParams).OY)
	}
	
	@Test
	def void parseDragToObjectWithOffsetGrabFrom(){
		val syntaxRoot =
'''
tell x
	drag to y 1 2 grab from 5 10
end
'''.parse
		syntaxRoot.assertNoErrors
		assertEquals('x', syntaxRoot.expression.head.context.value)
		assertEquals('drag', (syntaxRoot.expression.head.actions.head as Action).name)
		assertEquals('y', ((syntaxRoot.expression.head.actions.head as Action).actionParams as DragActionParams).target.value)
		assertEquals('1', ((syntaxRoot.expression.head.actions.head as Action).actionParams as DragActionParams).x)
		assertEquals('2', ((syntaxRoot.expression.head.actions.head as Action).actionParams as DragActionParams).y)
		assertTrue(((syntaxRoot.expression.head.actions.head as Action).actionParams as DragActionParams).grab)
		assertEquals('5', ((syntaxRoot.expression.head.actions.head as Action).actionParams as DragActionParams).OX)
		assertEquals('10', ((syntaxRoot.expression.head.actions.head as Action).actionParams as DragActionParams).OY)
	}
	
	@Test
	def void parseRefresh(){
		val syntaxRoot =
'''
tell x
	refresh
end
'''.parse
		syntaxRoot.assertNoErrors
		assertEquals('x', syntaxRoot.expression.head.context.value)
		assertEquals('refresh', (syntaxRoot.expression.head.actions.head as Action).name)
	}
	
	@Test
	def void parseAliasedRefresh(){
		val syntaxRoot =
'''
tell x
	aliasedRefresh
end
'''.parse
		syntaxRoot.assertNoErrors
		assertEquals('x', syntaxRoot.expression.head.context.value)
		assertEquals('aliasedRefresh', (syntaxRoot.expression.head.actions.head as Action).name)
	}
	
	@Test
	def void parseType(){
		val syntaxRoot =
'''
tell x
	type 'Hello world'
end
'''.parse
		syntaxRoot.assertNoErrors
		assertEquals('x', syntaxRoot.expression.head.context.value)
		assertEquals('type', (syntaxRoot.expression.head.actions.head as Action).name)
		assertEquals('Hello world', ((syntaxRoot.expression.head.actions.head as Action).actionParams as KeyboardActionParams).text.value)
	}
	
	@Test
	def void parseTypeOverwrite(){
		val syntaxRoot =
'''
tell x
	type overwrite 'Hello world'
end
'''.parse
		syntaxRoot.assertNoErrors
		assertEquals('x', syntaxRoot.expression.head.context.value)
		assertEquals('type', (syntaxRoot.expression.head.actions.head as Action).name)
		assertEquals('Hello world', ((syntaxRoot.expression.head.actions.head as Action).actionParams as KeyboardActionParams).text.value)
		assertTrue(((syntaxRoot.expression.head.actions.head as Action).actionParams as KeyboardActionParams).overwrite)
	}
	
	@Test
	def void parseNestedStep() {
		val syntaxRoot = '''
tell x
	tell y
		click
	end
end
'''.parse
		syntaxRoot.assertNoErrors
		assertEquals('x', syntaxRoot.expression.head.context.value)
		assertEquals('y', (syntaxRoot.expression.head.actions.head as Step).context.value)
		assertEquals('click', ((syntaxRoot.expression.head.actions.head as Step).actions.head as Action).name)
	}
	
	@Test
	def void parseNestedStepWithLogFolderName() {
		val syntaxRoot = '''
tell x
	#The nested log folder name
	tell y
		click
	end
end
'''.parse
		syntaxRoot.assertNoErrors
		assertEquals('x', syntaxRoot.expression.head.context.value)
		assertEquals('y', (syntaxRoot.expression.head.actions.head as Step).context.value)
		assertEquals('#The nested log folder name', (syntaxRoot.expression.head.actions.head as Step).folderName.trim)
		assertEquals('click', ((syntaxRoot.expression.head.actions.head as Step).actions.head as Action).name)
	}
	
	@Test
	def void parseNestedStep2() {
		val syntaxRoot = '''
tell x
	tell y
		tell z
			double click
		end
		right click
	end
	click
end
'''.parse
		syntaxRoot.assertNoErrors
		assertEquals('x', syntaxRoot.expression.head.context.value)
		assertEquals('y', (syntaxRoot.expression.head.actions.head as Step).context.value)
		assertEquals('z', ((syntaxRoot.expression.head.actions.head as Step).actions.head as Step).context.value)
		assertEquals('double click', (((syntaxRoot.expression.head.actions.head as Step).actions.head as Step).actions.head as Action).name)
		assertEquals('right click', ((syntaxRoot.expression.head.actions.head as Step).actions.get(1) as Action).name)
		assertEquals('click', (syntaxRoot.expression.head.actions.get(1) as Action).name)
	}
	
	@Test
	def void parseSearchSettings(){
		val syntaxRoot =
'''
tell x
	tell [a 1]:0
		click
	end
end
'''.parse
		syntaxRoot.assertNoErrors
		assertEquals("a",((syntaxRoot.expression.head.actions.head as Step).context as SearchSettings).properties.head.value)
		assertEquals("1",((syntaxRoot.expression.head.actions.head as Step).context as SearchSettings).expected.head.value)
		assertEquals("0",((syntaxRoot.expression.head.actions.head as Step).context as SearchSettings).index.value)
	}
	
	@Test
	def void parseSearchSettings2(){
		val syntaxRoot =
'''
tell x
	tell [ab 1, bcd 'two', cdefg true]:5
		click
	end
end
'''.parse
		syntaxRoot.assertNoErrors
		assertEquals("ab",((syntaxRoot.expression.head.actions.head as Step).context as SearchSettings).properties.head.value)
		assertEquals("1",((syntaxRoot.expression.head.actions.head as Step).context as SearchSettings).expected.head.value)
		assertEquals("bcd",((syntaxRoot.expression.head.actions.head as Step).context as SearchSettings).properties.get(1).value)
		assertEquals("two",((syntaxRoot.expression.head.actions.head as Step).context as SearchSettings).expected.get(1).value)
		assertEquals("cdefg",((syntaxRoot.expression.head.actions.head as Step).context as SearchSettings).properties.get(2).value)
		assertEquals("true",((syntaxRoot.expression.head.actions.head as Step).context as SearchSettings).expected.get(2).value)
		assertEquals("5",((syntaxRoot.expression.head.actions.head as Step).context as SearchSettings).index.value)
	}
	
	@Test
	def void parseSearchSettings3(){
		val syntaxRoot =
'''
tell x
	tell [ab 1, bcd 'two', cdefg true]->2:5
		click
	end
end
'''.parse
		syntaxRoot.assertNoErrors
		assertEquals("ab",((syntaxRoot.expression.head.actions.head as Step).context as SearchSettings).properties.head.value)
		assertEquals("1",((syntaxRoot.expression.head.actions.head as Step).context as SearchSettings).expected.head.value)
		assertEquals("bcd",((syntaxRoot.expression.head.actions.head as Step).context as SearchSettings).properties.get(1).value)
		assertEquals("two",((syntaxRoot.expression.head.actions.head as Step).context as SearchSettings).expected.get(1).value)
		assertEquals("cdefg",((syntaxRoot.expression.head.actions.head as Step).context as SearchSettings).properties.get(2).value)
		assertEquals("true",((syntaxRoot.expression.head.actions.head as Step).context as SearchSettings).expected.get(2).value)
		assertEquals("2",((syntaxRoot.expression.head.actions.head as Step).context as SearchSettings).depth.value)
		assertEquals("5",((syntaxRoot.expression.head.actions.head as Step).context as SearchSettings).index.value)
	}
	
	@Test
	def void parseSearchSettingsWithProjectVar(){
		val syntaxRoot =
'''
tell x
	tell [ab a.b]:0
		click
	end
end
'''.parse
		syntaxRoot.assertNoErrors
		assertEquals("ab", ((syntaxRoot.expression.head.actions.head as Step).context as SearchSettings).properties.head.value)
		assertEquals("a", ((syntaxRoot.expression.head.actions.head as Step).context as SearchSettings).expected.head.left.value)
		assertEquals("b", ((syntaxRoot.expression.head.actions.head as Step).context as SearchSettings).expected.head.right.value)
	}
	
	@Test
	def void parseSetVariable(){
		val syntaxRoot =
'''
tell x
	set ProjectVariables.MyVar1 to wText
	set ProjectVariables.MyVar2 to "hey"
	set ProjectVariables.MyVar3 to false
	set ProjectVariables.MyVar4 to 1
	set ProjectVariables.MyVar5 to 1.1
	set ProjectVariables.MyVar6 to true
	tell y
		set ProjectVariables.MyVar1 to wText
		set ProjectVariables.MyVar2 to "hey"
		set ProjectVariables.MyVar3 to false
		set ProjectVariables.MyVar4 to 1
		set ProjectVariables.MyVar5 to 1.1
		set ProjectVariables.MyVar6 to true
	end
end
'''.parse
		syntaxRoot.assertNoErrors
		assertEquals('x', syntaxRoot.expression.head.context.value)
		assertEquals('y', (syntaxRoot.expression.head.actions.get(6) as Step).context.value)
		assertEquals('MyVar1', (syntaxRoot.expression.head.actions.get(0) as Assignment).variableName.right.value)
		assertEquals('MyVar2', (syntaxRoot.expression.head.actions.get(1) as Assignment).variableName.right.value)
		assertEquals('MyVar3', (syntaxRoot.expression.head.actions.get(2) as Assignment).variableName.right.value)
		assertEquals('MyVar4', (syntaxRoot.expression.head.actions.get(3) as Assignment).variableName.right.value)
		assertEquals('MyVar5', (syntaxRoot.expression.head.actions.get(4) as Assignment).variableName.right.value)
		assertEquals('MyVar6', (syntaxRoot.expression.head.actions.get(5) as Assignment).variableName.right.value)
		assertEquals('MyVar1', ((syntaxRoot.expression.head.actions.get(6) as Step).actions.get(0) as Assignment).variableName.right.value)
		assertEquals('MyVar2', ((syntaxRoot.expression.head.actions.get(6) as Step).actions.get(1) as Assignment).variableName.right.value)
		assertEquals('MyVar3', ((syntaxRoot.expression.head.actions.get(6) as Step).actions.get(2) as Assignment).variableName.right.value)
		assertEquals('MyVar4', ((syntaxRoot.expression.head.actions.get(6) as Step).actions.get(3) as Assignment).variableName.right.value)
		assertEquals('MyVar5', ((syntaxRoot.expression.head.actions.get(6) as Step).actions.get(4) as Assignment).variableName.right.value)
		assertEquals('MyVar6', ((syntaxRoot.expression.head.actions.get(6) as Step).actions.get(5) as Assignment).variableName.right.value)
		assertEquals('true', ((syntaxRoot.expression.head.actions.get(6) as Step).actions.get(5) as Assignment).assignedValue.value)
	}
	
	@Test
	def void parseOnFrom(){
		val syntaxRoot =
'''
tell x
	on every customer,street,city,state,zip from MyDataSource
		assert wText customer
	end
end
'''.parse
		syntaxRoot.assertNoErrors
		assertEquals('x', (syntaxRoot.expression.head.context.value))
		assertTrue((syntaxRoot.expression.head.actions.head) instanceof DataDrivenStep)
		assertEquals('MyDataSource', ((syntaxRoot.expression.head.actions.head) as DataDrivenStep).dataSource.value)
		assertEquals('customer', ((syntaxRoot.expression.head.actions.head) as DataDrivenStep).columnNames.get(0).value)
		assertEquals('street', ((syntaxRoot.expression.head.actions.head) as DataDrivenStep).columnNames.get(1).value)
		assertEquals('city', ((syntaxRoot.expression.head.actions.head) as DataDrivenStep).columnNames.get(2).value)
		assertEquals('state', ((syntaxRoot.expression.head.actions.head) as DataDrivenStep).columnNames.get(3).value)
		assertEquals('zip', ((syntaxRoot.expression.head.actions.head) as DataDrivenStep).columnNames.get(4).value)
		assertTrue(((syntaxRoot.expression.head.actions.head) as DataDrivenStep).actions.head instanceof Assertion)
	}
	
	@Test
	def void parseOnFrom2(){
		val syntaxRoot =
'''
tell x
	on every customer,street,city,state,zip from MyDataSource
		tell y
			assert wText customer
		end
	end
end
'''.parse
		syntaxRoot.assertNoErrors
		assertEquals('x', (syntaxRoot.expression.head.context.value))
		assertTrue((syntaxRoot.expression.head.actions.head) instanceof DataDrivenStep)
		assertEquals('MyDataSource', ((syntaxRoot.expression.head.actions.head) as DataDrivenStep).dataSource.value)
		assertEquals('customer', ((syntaxRoot.expression.head.actions.head) as DataDrivenStep).columnNames.get(0).value)
		assertEquals('street', ((syntaxRoot.expression.head.actions.head) as DataDrivenStep).columnNames.get(1).value)
		assertEquals('city', ((syntaxRoot.expression.head.actions.head) as DataDrivenStep).columnNames.get(2).value)
		assertEquals('state', ((syntaxRoot.expression.head.actions.head) as DataDrivenStep).columnNames.get(3).value)
		assertEquals('zip', ((syntaxRoot.expression.head.actions.head) as DataDrivenStep).columnNames.get(4).value)
		assertTrue(((syntaxRoot.expression.head.actions.head) as DataDrivenStep).actions.head instanceof Step)
		assertEquals('y', (((syntaxRoot.expression.head.actions.head) as DataDrivenStep).actions.head as Step).context.value)
	}
}