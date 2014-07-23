package com.devfactory.keystone.tests

import org.eclipse.xtext.junit4.InjectWith
import com.devfactory.KeyStoneInjectorProvider
import org.junit.runner.RunWith
import org.eclipse.xtext.junit4.XtextRunner
import com.google.inject.Inject
import static org.junit.Assert.*
import org.junit.Test
import org.eclipse.xtext.xbase.compiler.CompilationTestHelper

@InjectWith(KeyStoneInjectorProvider)
@RunWith(XtextRunner)
class CompilerTests {
	@Inject extension CompilationTestHelper
	
	@Test
	def void compileSimpleExpression(){
'''
tell x
	click
end
'''.compile([ assertEquals(
'''
(function($_){
var $_=x;
$_.Click();
})();
'''.toString(), it.generatedCode.values.head)])
	}
	
	@Test
	def void compileSimpleExpressionWithLogFolder(){
'''
#the log folder name
tell x
	click
end
'''.compile([ assertEquals(
'''
(function($_){
try{Log.AppendFolder("the log folder name");
var $_=x;
$_.Click();
}finally{Log.PopLogFolder();}
})();
'''.toString(), it.generatedCode.values.head)])
	}
	
	@Test
	def void compileNestedExpression(){
'''
tell x
	tell y
		right click
	end
	click
end
'''.compile([ assertEquals(
'''
(function($_){
var $_=x;
(function($_){
var $_=$_.y;
$_.ClickR();
})($_);
$_.Click();
})();
'''.toString, it.generatedCode.values.head)])		
	}
	
	@Test
	def void compileNestedExpressionWithLogFolderName(){
'''
tell x
	#nested log folder name
	tell y
		right click
	end
	click
end
'''.compile([ assertEquals(
'''
(function($_){
var $_=x;
(function($_){
try{Log.AppendFolder("nested log folder name");
var $_=$_.y;
$_.ClickR();
}finally{Log.PopLogFolder();}
})($_);
$_.Click();
})();
'''.toString, it.generatedCode.values.head)])		
	}
	
	@Test
	def void compileSelectorExpression(){
'''
tell y of x
	right click
end
tell x
	click
end
'''.compile([ assertEquals(
'''
(function($_){
var $_=x.y;
$_.ClickR();
})();

(function($_){
var $_=x;
$_.Click();
})();
'''.toString, it.generatedCode.values.head)])		
	}
	
	@Test
	def void compileSelectorExpression2(){
'''
tell z of y of x
	tell a
		double click
	end
	right click
end
tell x
	click
end
'''.compile([ assertEquals(
'''
(function($_){
var $_=x.y.z;
(function($_){
var $_=$_.a;
$_.DblClick();
})($_);
$_.ClickR();
})();

(function($_){
var $_=x;
$_.Click();
})();
'''.toString, it.generatedCode.values.head)])		
	}
	
	@Test
	def void compileSelectorExpression3(){
'''
tell x
	tell [a 1, b "2", c true]:2
		click
	end
end
'''.compile([ assertEquals(
'''
(function($_){
var $_=x;
(function($_){
var $_=(new VBArray($_.FindAllChildren(["a","b","c"], [1,"2",true]))).toArray()[2];
$_.Click();
})($_);
})();
'''.toString, it.generatedCode.values.head)])		
	}
	
	@Test
	def void compileSelectorExpression4(){
'''
tell x
	tell [a 1, b "2", c true]->5:2
		click
	end
end
'''.compile([ assertEquals(
'''
(function($_){
var $_=x;
(function($_){
var $_=(new VBArray($_.FindAllChildren(["a","b","c"], [1,"2",true],5))).toArray()[2];
$_.Click();
})($_);
})();
'''.toString, it.generatedCode.values.head)])		
	}
	
	@Test
	def void compileSelectorExpression5(){
'''
tell x
	tell [a 1, b "2", c true]->5:2
		tell [e "hello", f "world"]:0
			click
		end
		click
	end
end
'''.compile([ assertEquals(
'''
(function($_){
var $_=x;
(function($_){
var $_=(new VBArray($_.FindAllChildren(["a","b","c"], [1,"2",true],5))).toArray()[2];
(function($_){
var $_=(new VBArray($_.FindAllChildren(["e","f"], ["hello","world"]))).toArray()[0];
$_.Click();
})($_);
$_.Click();
})($_);
})();
'''.toString, it.generatedCode.values.head)])		
	}
	
	@Test
	def void compileSelectorExpression6(){
'''
tell x
	tell [a 1]:2
		click
		assert wText "good"
		click
	end
end
'''.compile([ assertEquals(
'''
(function($_){
var $_=x;
(function($_){
var $_=(new VBArray($_.FindAllChildren(["a"], [1]))).toArray()[2];
$_.Click();
if($_.wText == "good"){Log.Checkpoint($_.wText + " == " + "good", 'passed', 300, undefined, ($_ && aqObject.IsSupported($_, "Picture")) ? $_.Picture(): null);}else{Log.Error($_.wText + " == " + "good")}
$_.Click();
})($_);
})();
'''.toString, it.generatedCode.values.head)])		
	}
	
	@Test
	def void compileSelectorExpression7(){
'''
tell x
	tell [a 1]:2
		click
		assert wText "good"
		tell y
			click
		end
		click
	end
end
'''.compile([ assertEquals(
'''
(function($_){
var $_=x;
(function($_){
var $_=(new VBArray($_.FindAllChildren(["a"], [1]))).toArray()[2];
$_.Click();
if($_.wText == "good"){Log.Checkpoint($_.wText + " == " + "good", 'passed', 300, undefined, ($_ && aqObject.IsSupported($_, "Picture")) ? $_.Picture(): null);}else{Log.Error($_.wText + " == " + "good")}
(function($_){
var $_=$_.y;
$_.Click();
})($_);
$_.Click();
})($_);
})();
'''.toString, it.generatedCode.values.head)])		
	}
	

@Test
	def void compileSelectorExpression8(){
'''
tell x
	tell [ab a.b]:0
		click
	end
end
'''.compile([ assertEquals(
'''
(function($_){
var $_=x;
(function($_){
var $_=(new VBArray($_.FindAllChildren(["ab"], [a.b]))).toArray()[0];
$_.Click();
})($_);
})();
'''.toString, it.generatedCode.values.head)])		
	}
	
	@Test
	def void compileWaitAction(){
'''
tell x
	wait for childName 500
end
'''.compile([ assertEquals(
'''
(function($_){
var $_=x;
if(!$_.waitChild(childName,500).Exists) throw "Child object was not found. Try waiting longer";
})();
'''.toString, it.generatedCode.values.head)])		
	}
	
	@Test
	def void compileWaitAction2(){
'''
tell x
	wait for property ProjectVariables.propertyName expectedValue 500
end
'''.compile([ assertEquals(
'''
(function($_){
var $_=x;
if(!$_.waitProperty(ProjectVariables.propertyName,expectedValue,500)) throw "Wait condition was never met. Try waiting longer.";
})();
'''.toString, it.generatedCode.values.head)])		
	}
	
	@Test
	def void compileWaitAction3(){
'''
tell x
	wait for "Aliases.childName*" 500
end
'''.compile([ assertEquals(
'''
(function($_){
var $_=x;
if(!$_.waitChild("Aliases.childName*",500).Exists) throw "Child object was not found. Try waiting longer";
})();
'''.toString, it.generatedCode.values.head)])		
	}
	
	@Test
	def void compileWaitAction4(){
'''
tell x
	wait for property "Project.Variables?propertyName" "*expectedValue" 500
end
'''.compile([ assertEquals(
'''
(function($_){
var $_=x;
if(!$_.waitProperty("Project.Variables?propertyName","*expectedValue",500)) throw "Wait condition was never met. Try waiting longer.";
})();
'''.toString, it.generatedCode.values.head)])		
	}
	
	@Test
	def void compileDragTo(){
'''
tell x
	drag to y
end
'''.compile([ assertEquals(
'''
(function($_){
var $_=x;
$_.Drag(Math.floor($_.Width/2),Math.floor($_.Height/2),(y.Left+Math.floor(y.Width/2)) - ($_.Left + Math.floor($_.Width/2)), (y.Top+Math.floor(y.Height/2)) - ($_.Top + Math.floor($_.Height/2)));
})();
'''.toString, it.generatedCode.values.head)])		
	}
	
	@Test
	def void compileDragTo2(){
'''
tell x
	drag to 5 5
end
'''.compile([ assertEquals(
'''
(function($_){
var $_=x;
$_.Drag(Math.floor($_.Width/2),Math.floor($_.Height/2),5- ($_.Left + Math.floor($_.Width/2)), 5- ($_.Top + Math.floor($_.Height/2)));
})();
'''.toString, it.generatedCode.values.head)])		
	}
	
	@Test
	def void compileDragTo3(){
'''
tell x
	drag to y 5 5
end
'''.compile([ assertEquals(
'''
(function($_){
var $_=x;
$_.Drag(Math.floor($_.Width/2),Math.floor($_.Height/2),(y.Left+5) - ($_.Left + Math.floor($_.Width/2)), (y.Top+5) - ($_.Top + Math.floor($_.Height/2)));
})();
'''.toString, it.generatedCode.values.head)])		
	}
	
	@Test
	def void compileDragTo4(){
'''
tell x
	drag to y 1 2 grab from 3 4
end
'''.compile([ assertEquals(
'''
(function($_){
var $_=x;
$_.Drag(3,4,(y.Left+1) - ($_.Left + 3), (y.Top+2) - ($_.Top + 4));
})();
'''.toString, it.generatedCode.values.head)])		
	}
	
	@Test
	def void compileDragTo5(){
'''
tell x
	drag to 1 2 grab from 3 4
end
'''.compile([ assertEquals(
'''
(function($_){
var $_=x;
$_.Drag(3,4,1- ($_.Left + 3), 2- ($_.Top + 4));
})();
'''.toString, it.generatedCode.values.head)])		
	}
	
	@Test
	def void compileDragTo6(){
'''
tell x
	drag to y grab from 3 4
end
'''.compile([ assertEquals(
'''
(function($_){
var $_=x;
$_.Drag(3,4,(y.Left+Math.floor(y.Width/2)) - ($_.Left + 3), (y.Top+Math.floor(y.Height/2)) - ($_.Top + 4));
})();
'''.toString, it.generatedCode.values.head)])		
	}
	
	@Test
	def void compileOpenBrowser(){
'''
tell Browsers
	open browser InternetExplorer
end
'''.compile([ assertEquals(
'''
(function($_){
var $_=Browsers;
$_.Item(btIExplorer).Run();
})();
'''.toString, it.generatedCode.values.head)])		
	}
	
	@Test
	def void compileBrowseTo(){
'''
tell Browsers.CurrentBrowser
	browse to "http://www.google.com"
end
'''.compile([ assertEquals(
'''
(function($_){
var $_=Browsers.CurrentBrowser;
$_.Navigate("http://www.google.com");
})();
'''.toString, it.generatedCode.values.head)])		
	}
	
	@Test
	def void compileTerminate(){
'''
tell Browsers.CurrentBrowser
	terminate
end
'''.compile([ assertEquals(
'''
(function($_){
var $_=Browsers.CurrentBrowser;
$_.Terminate();
})();
'''.toString, it.generatedCode.values.head)])		
	}
	
	@Test
	def void compileClose(){
'''
tell Browsers.CurrentBrowser
	close
end
'''.compile([ assertEquals(
'''
(function($_){
var $_=Browsers.CurrentBrowser;
$_.Close();
})();
'''.toString, it.generatedCode.values.head)])		
	}
	
	@Test
	def void compileMaximize(){
'''
tell x
	maximize
end
'''.compile([ assertEquals(
'''
(function($_){
var $_=x;
$_.Maximize();
})();
'''.toString, it.generatedCode.values.head)])		
	}
	
	@Test
	def void compileRun(){
'''
tell TestedApps.Items(0)
	run
end
'''.compile([ assertEquals(
'''
(function($_){
var $_=TestedApps.Items(0);
$_.Run();
})();
'''.toString, it.generatedCode.values.head)])		
	}
	
	@Test
	def void compileRefresh(){
'''
tell x
	refresh
end
'''.compile([ assertEquals(
'''
(function($_){
var $_=x;
$_.Refresh();
})();
'''.toString, it.generatedCode.values.head)])		
	}
	
	@Test
	def void compileAliasedRefresh(){
'''
tell x
	aliasedRefresh
end
'''.compile([ assertEquals(
'''
(function($_){
var $_=x;
$_.Refresh();$_.RefreshMappingInfo();
})();
'''.toString, it.generatedCode.values.head)])		
	}
	
	@Test
	def void compileType(){
'''
tell x
	type 'hello world'
end
'''.compile([ assertEquals(
'''
(function($_){
var $_=x;
$_.Keys('hello world');
})();
'''.toString, it.generatedCode.values.head)])		
	}
	
	@Test
	def void compileTypeOverwrite(){
'''
tell x
	type overwrite 'hello world'
end
'''.compile([ assertEquals(
'''
(function($_){
var $_=x;
$_.Keys('^ahello world');
})();
'''.toString, it.generatedCode.values.head)])		
	}
	
	@Test
	def void compileAssertRegex(){
'''
tell x
	assert a /a[rg]gex/
end
'''.compile([ assertEquals(
'''
(function($_){
var $_=x;
if(aqString.StrMatches("a[rg]gex", $_.a)){Log.Checkpoint("/a[rg]gex/ ~= " + $_.a, 'passed', 300, undefined, ($_ && aqObject.IsSupported($_, "Picture")) ? $_.Picture(): null);}else{Log.Error("/a[rg]gex/ ~= " + $_.a)}
})();
'''.toString, it.generatedCode.values.head)])		
	}
	
	@Test
	def void compileAssertRegex2(){
'''
tell x
	assert a /a[rg]gex/ and b 1
end
'''.compile([ assertEquals(
'''
(function($_){
var $_=x;
if((aqString.StrMatches("a[rg]gex", $_.a) && $_.b == 1)){Log.Checkpoint("/a[rg]gex/ ~= " + $_.a + " && " + $_.b + " == " + 1, 'passed', 300, undefined, ($_ && aqObject.IsSupported($_, "Picture")) ? $_.Picture(): null);}else{Log.Error("/a[rg]gex/ ~= " + $_.a + " && " + $_.b + " == " + 1)}
})();
'''.toString, it.generatedCode.values.head)])		
	}
	
	@Test
	def void compileAssertRegex3(){
'''
tell x
	assert a regex b
end
'''.compile([ assertEquals(
'''
(function($_){
var $_=x;
if(aqString.StrMatches(b, $_.a)){Log.Checkpoint("/"+b+"/ ~= " + $_.a, 'passed', 300, undefined, ($_ && aqObject.IsSupported($_, "Picture")) ? $_.Picture(): null);}else{Log.Error("/"+b+"/ ~= " + $_.a)}
})();
'''.toString, it.generatedCode.values.head)])		
	}
	
	@Test
	def void compileAssertRegex4(){
'''
tell x
	assert a regex c and b 1
end
'''.compile([ assertEquals(
'''
(function($_){
var $_=x;
if((aqString.StrMatches(c, $_.a) && $_.b == 1)){Log.Checkpoint("/"+c+"/ ~= " + $_.a + " && " + $_.b + " == " + 1, 'passed', 300, undefined, ($_ && aqObject.IsSupported($_, "Picture")) ? $_.Picture(): null);}else{Log.Error("/"+c+"/ ~= " + $_.a + " && " + $_.b + " == " + 1)}
})();
'''.toString, it.generatedCode.values.head)])		
	}
	
	@Test
	def void compileAssert1(){
'''
tell x
	assert a 1 and c "two" and b true and d ProjectVariables.expectedD
end
'''.compile([ assertEquals(
'''
(function($_){
var $_=x;
if(($_.a == 1 && ($_.c == "two" && ($_.b == true && $_.d == ProjectVariables.expectedD)))){Log.Checkpoint($_.a + " == " + 1 + " && " + $_.c + " == " + "two" + " && " + $_.b + " == " + true + " && " + $_.d + " == " + ProjectVariables.expectedD, 'passed', 300, undefined, ($_ && aqObject.IsSupported($_, "Picture")) ? $_.Picture(): null);}else{Log.Error($_.a + " == " + 1 + " && " + $_.c + " == " + "two" + " && " + $_.b + " == " + true + " && " + $_.d + " == " + ProjectVariables.expectedD)}
})();
'''.toString, it.generatedCode.values.head)])		
	}
	
	@Test
	def void compileAssert2(){
'''
tell x
	assert a true and b ProjectVariables.ExpectedB and c /is a (regex)?/ and d 1 and e "string"
end
'''.compile([ assertEquals(
'''
(function($_){
var $_=x;
if(($_.a == true && ($_.b == ProjectVariables.ExpectedB && (aqString.StrMatches("is a (regex)?", $_.c) && ($_.d == 1 && $_.e == "string"))))){Log.Checkpoint($_.a + " == " + true + " && " + $_.b + " == " + ProjectVariables.ExpectedB + " && " + "/is a (regex)?/ ~= " + $_.c + " && " + $_.d + " == " + 1 + " && " + $_.e + " == " + "string", 'passed', 300, undefined, ($_ && aqObject.IsSupported($_, "Picture")) ? $_.Picture(): null);}else{Log.Error($_.a + " == " + true + " && " + $_.b + " == " + ProjectVariables.ExpectedB + " && " + "/is a (regex)?/ ~= " + $_.c + " && " + $_.d + " == " + 1 + " && " + $_.e + " == " + "string")}
})();
'''.toString, it.generatedCode.values.head)])		
	}
	
	@Test
	def void compileAssert3(){
'''
tell x
	assert not found [wText "hello"]:0
end
'''.compile([ assertEquals(
'''
(function($_){
var $_=x;
if(!((new VBArray($_.FindAllChildren(["wText"], ["hello"]))).toArray().length)){Log.Checkpoint("object does not exist","object does not exist",300, undefined, ($_ && aqObject.IsSupported($_, "Picture")) ? $_.Picture(): null);}else{Log.Error("object does not exist");};
})();
'''.toString, it.generatedCode.values.head)])		
	}
	
	@Test
	def void compileAssert4(){
'''
tell x
	assert found [wText "hello"]:0
end
'''.compile([ assertEquals(
'''
(function($_){
var $_=x;
if(((new VBArray($_.FindAllChildren(["wText"], ["hello"]))).toArray().length)){Log.Checkpoint("object does exist","object does exist",300, undefined, ($_ && aqObject.IsSupported($_, "Picture")) ? $_.Picture(): null);}else{Log.Error("object does exist");};
})();
'''.toString, it.generatedCode.values.head)])		
	}
	
	@Test
	def void compileAssert5(){
'''
tell x
	assert not wText "hello"
end
'''.compile([ assertEquals(
'''
(function($_){
var $_=x;
if($_.wText != "hello"){Log.Checkpoint($_.wText + " != " + "hello", 'passed', 300, undefined, ($_ && aqObject.IsSupported($_, "Picture")) ? $_.Picture(): null);}else{Log.Error($_.wText + " != " + "hello")}
})();
'''.toString, it.generatedCode.values.head)])		
	}
	
	@Test
	def void compileAssert6(){
'''
tell x
	assert not wText "hello" and WndClassName 'bling'
end
'''.compile([ assertEquals(
'''
(function($_){
var $_=x;
if(($_.wText != "hello" && $_.WndClassName != "bling")){Log.Checkpoint($_.wText + " != " + "hello" + " && " + $_.WndClassName + " != " + "bling", 'passed', 300, undefined, ($_ && aqObject.IsSupported($_, "Picture")) ? $_.Picture(): null);}else{Log.Error($_.wText + " != " + "hello" + " && " + $_.WndClassName + " != " + "bling")}
})();
'''.toString, it.generatedCode.values.head)])		
	}
	
	@Test
	def void compileAssert7(){
'''
tell x
	assert not wText /hello/
end
'''.compile([ assertEquals(
'''
(function($_){
var $_=x;
if(!aqString.StrMatches("hello", $_.wText)){Log.Checkpoint("/hello/ ~! " + $_.wText, 'passed', 300, undefined, ($_ && aqObject.IsSupported($_, "Picture")) ? $_.Picture(): null);}else{Log.Error("/hello/ ~! " + $_.wText)}
})();
'''.toString, it.generatedCode.values.head)])		
	}
	
	@Test
	def void compileAssert8(){
'''
tell x
	assert not wText "hello" and WndClassName /bling/
end
'''.compile([ assertEquals(
'''
(function($_){
var $_=x;
if(($_.wText != "hello" && !aqString.StrMatches("bling", $_.WndClassName))){Log.Checkpoint($_.wText + " != " + "hello" + " && " + "/bling/ ~! " + $_.WndClassName, 'passed', 300, undefined, ($_ && aqObject.IsSupported($_, "Picture")) ? $_.Picture(): null);}else{Log.Error($_.wText + " != " + "hello" + " && " + "/bling/ ~! " + $_.WndClassName)}
})();
'''.toString, it.generatedCode.values.head)])		
	}
	
	@Test
	def void compileAssert9(){
'''
tell x
	assert wText lt "hello"
end
'''.compile([ assertEquals(
'''
(function($_){
var $_=x;
if($_.wText < "hello"){Log.Checkpoint($_.wText + " less than " + "hello", 'passed', 300, undefined, ($_ && aqObject.IsSupported($_, "Picture")) ? $_.Picture(): null);}else{Log.Error($_.wText + " less than " + "hello")}
})();
'''.toString, it.generatedCode.values.head)])		
	}
	
	@Test
	def void compileAssert10(){
'''
tell x
	assert not wText gte "hello"
end
'''.compile([ assertEquals(
'''
(function($_){
var $_=x;
if(!($_.wText >= "hello")){Log.Checkpoint($_.wText + " not equal or greater than " + "hello", 'passed', 300, undefined, ($_ && aqObject.IsSupported($_, "Picture")) ? $_.Picture(): null);}else{Log.Error($_.wText + " not equal or greater than " + "hello")}
})();
'''.toString, it.generatedCode.values.head)])		
	}
	
	@Test
	def void compilePauseFor(){
'''
tell x
	pause for 500
end
'''.compile([ assertEquals(
'''
(function($_){
var $_=x;
aqUtils.Delay(500);
})();
'''.toString, it.generatedCode.values.head)])		
	}
	
	@Test
	def void compileSetVariable(){
'''
tell x
	set ProjectVariables.MyVar1 to wText
	set ProjectVariables.MyVar2 to "hey"
	set ProjectVariables.MyVar3 to false
	set ProjectVariables.MyVar4 to 1
	set ProjectVariables.MyVar5 to 1.1
	set ProjectVariables.MyVar6 to true
	set ProjectVariables.MyVar6 to ProjectVariables.MyVar3
	tell y
		set ProjectVariables.MyVar1 to wText
		set ProjectVariables.MyVar2 to "hey"
		set ProjectVariables.MyVar3 to false
		set ProjectVariables.MyVar4 to 1
		set ProjectVariables.MyVar5 to 1.1
		set ProjectVariables.MyVar6 to true
		set ProjectVariables.MyVar6 to ProjectVariables.MyVar3
	end
end
'''.compile([ assertEquals(
'''
(function($_){
var $_=x;
ProjectVariables.MyVar1 = $_.wText;
ProjectVariables.MyVar2 = "hey";
ProjectVariables.MyVar3 = false;
ProjectVariables.MyVar4 = 1;
ProjectVariables.MyVar5 = 1.1;
ProjectVariables.MyVar6 = true;
ProjectVariables.MyVar6 = $_.ProjectVariables.MyVar3;
(function($_){
var $_=$_.y;
ProjectVariables.MyVar1 = $_.wText;
ProjectVariables.MyVar2 = "hey";
ProjectVariables.MyVar3 = false;
ProjectVariables.MyVar4 = 1;
ProjectVariables.MyVar5 = 1.1;
ProjectVariables.MyVar6 = true;
ProjectVariables.MyVar6 = $_.ProjectVariables.MyVar3;
})($_);
})();
'''.toString, it.generatedCode.values.head)])		
	}
}