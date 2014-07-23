/*
 * generated by Xtext
 */
package com.devfactory.validation

import com.devfactory.keyStone.KeyStonePackage
import com.devfactory.keyStone.Step
import com.devfactory.keyStone.Action
import com.devfactory.keyStone.OpenBrowserActionParams

import org.eclipse.xtext.validation.Check
import com.devfactory.keyStone.BrowseToActionParams
import com.devfactory.keyStone.RootStep
import com.devfactory.keyStone.SearchSettings
import com.devfactory.keyStone.Expression
import com.devfactory.keyStone.StringLiteral
import com.devfactory.keyStone.NumberLiteral
import com.devfactory.keyStone.RegularExpression
import com.devfactory.keyStone.BooleanLiteral

/**
 * Custom validation rules. 
 *
 * see http://www.eclipse.org/Xtext/documentation.html#validation
 */
class KeyStoneValidator extends AbstractKeyStoneValidator {

//  public static val INVALID_NAME = 'invalidName'
//
//	@Check
//	def checkGreetingStartsWithCapital(Greeting greeting) {
//		if (!Character.isUpperCase(greeting.name.charAt(0))) {
//			warning('Name should start with a capital', 
//					MyDslPackage.Literals.GREETING__NAME,
//					INVALID_NAME)
//		}
//	}
public static val ONLY_VALID_FOR_BROWSERS = "'open browser' only works on the built-in 'Browsers' object"
	public static val ONLY_VALID_FOR_CURRENT_BROWSER = "'open browser' only works on the built-in 'Browsers.CurrentBrowser' object"
	public static val ONLY_VALID_AT_TOP_LEVEL = "This 'tell' statement must be top level"
	public static val SEARCH_NOT_ALLOWED_AT_TOP_LEVEL = "This 'tell' statement must NEVER be top level"
	public static val ONLY_FOR_TESTEDAPPS = 'This action is only valid on "TestedApps"'
	public static val ONLY_FOR_MAPPED_OBJECTS = 'This action is only valid on objects that have been name mapped.';
	
	val TARGETS_ONLY_VALID_AT_TOP_LEVEL = #['Process','Sys','TestedApps','Browsers','Log'].toMap[toString]
	
	def text(StringLiteral stringLiteral){
		'''"«stringLiteral.value.replace("\"","\\\"")»"'''
	}
	def text(RegularExpression regex){
		'''/«regex.value»/'''
	}
	def text(SearchSettings search){
		val result = new StringBuilder
		for(var i = 0; i < search.properties.length; i++){
			result.append(text(search.properties.get(i)))
			result.append('=')
			result.append(text(search.expected.get(i)))
		}
		'''[«result.toString»]«IF search.depth != null»->«text(search.depth as Expression)»«ENDIF»:«text(search.index as Expression)»'''
	}
	def text(Expression expression){
		if(expression.arguments != null && expression.arguments.length > 0){
			'''«text(expression.left)»(«expression.arguments.map[ text ].join(",")»);'''
		} else if(expression.left != null){
			'''«text(expression.left)».«text(expression.right)»'''
		} else if (expression instanceof SearchSettings) {
			text(expression as SearchSettings)
		} else {
			if(expression instanceof StringLiteral){
				text(expression as StringLiteral)
			}else if (expression instanceof RegularExpression){
				text(expression as RegularExpression)
			}else { //if (expression instanceof NumberLiteral || expression instanceof BooleanLiteral){
				expression.value
			}
		}
	}
	
	@Check
	def checkTriggeredOnBrowsers(Action action){
		val step = (action.eContainer as Step)
		if(action.name == "open" && step != null && action.actionParams != null){
			if(action.actionParams instanceof OpenBrowserActionParams && (step.context.value == null || step.context.value != "Browsers")){
				error("this action is only valid for the 'Browsers' object", KeyStonePackage.Literals.ACTION__NAME, ONLY_VALID_FOR_BROWSERS)
			}	
		}
	}
	@Check
	def checkTriggeredOnCurrentBrowser(Action action){
		val step = (action.eContainer as Step)
		if(action.name == "browse" && step != null && action.actionParams != null){
			val target = step.context.text.toString
			if(action.actionParams instanceof BrowseToActionParams && (target != "Browsers.CurrentBrowser" && !target.startsWith("Browsers.Item("))){
				error("this action is only valid for the 'Browsers.CurrentBrowser' object, or for one of the installed browsers. Try using any of: Browsers.CurrentBrowser , Browsers.Item(btIExplorer), Browsers.Item(btFirefox), Browsers.Item(btChrome), Browsers.Item(btOpera), Browsers.Item(btSafari)", KeyStonePackage.Literals.ACTION__NAME, ONLY_VALID_FOR_CURRENT_BROWSER)
			}
		}
	}
	@Check
	def checkAliasedObjectIsTarget(Action action){
		if(action.name == 'aliasedRefresh'){
			warning("This action will only work on name mapped objects", KeyStonePackage.Literals.ACTION__NAME, ONLY_FOR_MAPPED_OBJECTS)
		}
	}
	@Check
	def checkOlyAtTopLevel(Step step){
		if(!(step instanceof RootStep) && step.context != null && step.context.value != null){
			val target = step.context.text.toString
			if(TARGETS_ONLY_VALID_AT_TOP_LEVEL.containsKey(target)){
				error('''You may only address '«target»' on a top level 'tell' statement''', KeyStonePackage.Literals.STEP__CONTEXT, ONLY_VALID_AT_TOP_LEVEL)
			}
			TARGETS_ONLY_VALID_AT_TOP_LEVEL.forEach[targetName, targetNamePart|
				if(target.startsWith(targetName)){
					error('''You may only address '«targetName»' on a top level 'tell' statement''', KeyStonePackage.Literals.STEP__CONTEXT, ONLY_VALID_AT_TOP_LEVEL)
				}
			]
		}
	}
	@Check
	def checkSearchIsUsedAtTopLevel(Step step){
		if(step.context.value != null){
			if(step instanceof RootStep && step.context != null){
				if(step.context instanceof SearchSettings)
				error("You may only run searches within nested 'tell' statements", KeyStonePackage.Literals.STEP__CONTEXT, SEARCH_NOT_ALLOWED_AT_TOP_LEVEL)
			}
		}
	}
	@Check
	def checkRunUsedOnTestedApps(Action action){
		val step = (action.eContainer as Step)
		if(action.name == 'run'){
			if(!step.context.text.toString.startsWith("TestedApps.")){
				error("This action is only available on a member of the TestedApps collection.", KeyStonePackage.Literals.ACTION__NAME)
			}
		}
	}
}
