// Test class for ErrorReporter functionality
Class constructor()

Function _cleanupTestErrors($errorTexts : Collection)
	// Helper to remove specific test errors from Storage so they don't cause test failures
	Use (Storage:C1525.testErrors)
		var $i : Integer
		For ($i; Storage:C1525.testErrors.length-1; 0; -1)
			var $text : Text
			$text:=Storage:C1525.testErrors[$i].text
			If ($errorTexts.indexOf($text)>=0)
				Storage:C1525.testErrors.remove($i)
			End if
		End for
	End use

Function test_reportHostError($t : cs:C1710.Testing)
	// Test that reportHostError creates the correct error structure
	// Clear any existing errors
	Use (Storage:C1525)
		Storage:C1525.testErrors:=New shared collection:C1527
	End use

	var $reporter : cs:C1710.ErrorReporter
	$reporter:=cs:C1710.ErrorReporter.new()

	var $testCallChain : Collection
	$testCallChain:=Get call chain:C1662
	$reporter.reportHostError(512; "HostMethod"; "someFormula"; 42; 123; $testCallChain)

	// Verify error was stored
	Use (Storage:C1525.testErrors)
		$t.assert.areEqual($t; 1; Storage:C1525.testErrors.length; "Should store one error")

		var $error : Object
		$error:=Storage:C1525.testErrors[0]

		$t.assert.areEqual($t; 512; $error.code; "Should store error code")
		$t.assert.areEqual($t; "HostMethod"; $error.text; "Should store error text")
		$t.assert.areEqual($t; "someFormula"; $error.method; "Should store error method")
		$t.assert.areEqual($t; 42; $error.line; "Should store error line")
		$t.assert.areEqual($t; 123; $error.processNumber; "Should store process number")
		$t.assert.areEqual($t; "host"; $error.context; "Should mark as host context")
		$t.assert.isFalse($t; $error.isLocal; "Host errors should not be local")
		$t.assert.isNotNull($t; $error.timestamp; "Should have timestamp")
	End use

Function test_reportLocalError($t : cs:C1710.Testing)
	// Test that reportLocalError creates the correct error structure

	Use (Storage:C1525)
		Storage:C1525.testErrors:=New shared collection:C1527
	End use

	var $reporter : cs:C1710.ErrorReporter
	$reporter:=cs:C1710.ErrorReporter.new()
	$reporter.reportLocalError(123; "LocalMethod"; "localFormula"; 10; 456)

	Use (Storage:C1525.testErrors)
		$t.assert.areEqual($t; 1; Storage:C1525.testErrors.length; "Should store one error")

		var $error : Object
		$error:=Storage:C1525.testErrors[0]

		$t.assert.areEqual($t; 123; $error.code; "Should store error code")
		$t.assert.areEqual($t; "LocalMethod"; $error.text; "Should store error text")
		$t.assert.areEqual($t; "localFormula"; $error.method; "Should store error method")
		$t.assert.areEqual($t; 10; $error.line; "Should store error line")
		$t.assert.areEqual($t; 456; $error.processNumber; "Should store process number")
		$t.assert.areEqual($t; "local"; $error.context; "Should mark as local context")
		$t.assert.isTrue($t; $error.isLocal; "Local errors should be marked local")
		$t.assert.isNotNull($t; $error.timestamp; "Should have timestamp")
	End use

Function test_reportGlobalError($t : cs:C1710.Testing)
	// Test that reportGlobalError creates the correct error structure

	Use (Storage:C1525)
		Storage:C1525.testErrors:=New shared collection:C1527
	End use

	var $reporter : cs:C1710.ErrorReporter
	$reporter:=cs:C1710.ErrorReporter.new()
	$reporter.reportGlobalError(789; "GlobalMethod"; "globalFormula"; 99; 321)

	Use (Storage:C1525.testErrors)
		$t.assert.areEqual($t; 1; Storage:C1525.testErrors.length; "Should store one error")

		var $error : Object
		$error:=Storage:C1525.testErrors[0]

		$t.assert.areEqual($t; 789; $error.code; "Should store error code")
		$t.assert.areEqual($t; "GlobalMethod"; $error.text; "Should store error text")
		$t.assert.areEqual($t; "globalFormula"; $error.method; "Should store error method")
		$t.assert.areEqual($t; 99; $error.line; "Should store error line")
		$t.assert.areEqual($t; 321; $error.processNumber; "Should store process number")
		$t.assert.areEqual($t; "global"; $error.context; "Should mark as global context")
		$t.assert.isFalse($t; $error.isLocal; "Global errors should not be local")
		$t.assert.isNotNull($t; $error.timestamp; "Should have timestamp")
	End use

Function test_multipleErrors($t : cs:C1710.Testing)
	// Test that multiple errors can be reported and stored

	Use (Storage:C1525)
		Storage:C1525.testErrors:=New shared collection:C1527
	End use

	var $reporter : cs:C1710.ErrorReporter
	$reporter:=cs:C1710.ErrorReporter.new()

	var $testCallChain : Collection
	$testCallChain:=Get call chain:C1662
	$reporter.reportHostError(1; "Host1"; "formula1"; 1; 100; $testCallChain)
	$reporter.reportLocalError(2; "Local1"; "formula2"; 2; 200)
	$reporter.reportGlobalError(3; "Global1"; "formula3"; 3; 300)

	Use (Storage:C1525.testErrors)
		$t.assert.areEqual($t; 3; Storage:C1525.testErrors.length; "Should store three errors")

		$t.assert.areEqual($t; "host"; Storage:C1525.testErrors[0].context; "First should be host")
		$t.assert.areEqual($t; "local"; Storage:C1525.testErrors[1].context; "Second should be local")
		$t.assert.areEqual($t; "global"; Storage:C1525.testErrors[2].context; "Third should be global")
	End use

Function test_errorStorageInitialization($t : cs:C1710.Testing)
	// Test that ErrorReporter initializes storage if it doesn't exist

	// Clear existing errors
	Use (Storage:C1525)
		Storage:C1525.testErrors:=New shared collection:C1527
	End use

	var $reporter : cs:C1710.ErrorReporter
	$reporter:=cs:C1710.ErrorReporter.new()

	var $testCallChain : Collection
	$testCallChain:=Get call chain:C1662
	$reporter.reportHostError(100; "TestMethod"; "testFormula"; 1; 1; $testCallChain)

	// Verify storage was initialized
	$t.assert.isNotNull($t; Storage:C1525.testErrors; "Should initialize Storage.testErrors")
	$t.assert.areEqual($t; Is collection:K8:32; Value type:C1509(Storage:C1525.testErrors); "Should be a collection")

	Use (Storage:C1525.testErrors)
		$t.assert.areEqual($t; 1; Storage:C1525.testErrors.length; "Should have one error")
	End use

	// Clean up test errors
	This:C1470._cleanupTestErrors(New collection:C1472("TestMethod"))

Function test_errorStructureIsShared($t : cs:C1710.Testing)
	// Test that error objects are properly copied as shared

	Use (Storage:C1525)
		Storage:C1525.testErrors:=New shared collection:C1527
	End use

	var $reporter : cs:C1710.ErrorReporter
	$reporter:=cs:C1710.ErrorReporter.new()

	var $testCallChain : Collection
	$testCallChain:=Get call chain:C1662
	$reporter.reportHostError(999; "TestShared"; "formula"; 5; 5; $testCallChain)

	Use (Storage:C1525.testErrors)
		var $error : Object
		$error:=Storage:C1525.testErrors[0]

		// Verify all required fields exist and have correct types
		$t.assert.areEqual($t; Is real:K8:4; Value type:C1509($error.code); "Code should be real")
		$t.assert.areEqual($t; Is text:K8:3; Value type:C1509($error.text); "Text should be text")
		$t.assert.areEqual($t; Is text:K8:3; Value type:C1509($error.method); "Method should be text")
		$t.assert.areEqual($t; Is real:K8:4; Value type:C1509($error.line); "Line should be real")
		$t.assert.areEqual($t; Is real:K8:4; Value type:C1509($error.timestamp); "Timestamp should be real")
		$t.assert.areEqual($t; Is real:K8:4; Value type:C1509($error.processNumber); "Process number should be real")
		$t.assert.areEqual($t; Is text:K8:3; Value type:C1509($error.context); "Context should be text")
		$t.assert.areEqual($t; Is boolean:K8:9; Value type:C1509($error.isLocal); "IsLocal should be boolean")
	End use

Function test_contextValues($t : cs:C1710.Testing)
	// Verify that each error type sets the correct context and isLocal values

	Use (Storage:C1525)
		Storage:C1525.testErrors:=New shared collection:C1527
	End use

	var $reporter : cs:C1710.ErrorReporter
	$reporter:=cs:C1710.ErrorReporter.new()

	var $testCallChain : Collection
	$testCallChain:=Get call chain:C1662
	$reporter.reportHostError(1; "hostMethod"; "hostFormula"; 1; 1; $testCallChain)
	$reporter.reportLocalError(2; "localMethod"; "localFormula"; 2; 2)
	$reporter.reportGlobalError(3; "globalMethod"; "globalFormula"; 3; 3)

	Use (Storage:C1525.testErrors)
		// Host error
		$t.assert.areEqual($t; "host"; Storage:C1525.testErrors[0].context; "Host context should be 'host'")
		$t.assert.isFalse($t; Storage:C1525.testErrors[0].isLocal; "Host should not be local")

		// Local error
		$t.assert.areEqual($t; "local"; Storage:C1525.testErrors[1].context; "Local context should be 'local'")
		$t.assert.isTrue($t; Storage:C1525.testErrors[1].isLocal; "Local should be local")

		// Global error
		$t.assert.areEqual($t; "global"; Storage:C1525.testErrors[2].context; "Global context should be 'global'")
		$t.assert.isFalse($t; Storage:C1525.testErrors[2].isLocal; "Global should not be local")
	End use

	// Clean up test errors
	This:C1470._cleanupTestErrors(New collection:C1472("hostMethod"; "localMethod"; "globalMethod"))

Function test_timestampIsRecent($t : cs:C1710.Testing)
	// Verify that timestamps are generated at report time

	Use (Storage:C1525)
		Storage:C1525.testErrors:=New shared collection:C1527
	End use

	var $beforeTime : Integer
	$beforeTime:=Milliseconds:C459

	var $reporter : cs:C1710.ErrorReporter
	$reporter:=cs:C1710.ErrorReporter.new()

	var $testCallChain : Collection
	$testCallChain:=Get call chain:C1662
	$reporter.reportHostError(1; "timestampMethod"; "timestampFormula"; 1; 1; $testCallChain)

	var $afterTime : Integer
	$afterTime:=Milliseconds:C459

	Use (Storage:C1525.testErrors)
		var $errorTimestamp : Integer
		$errorTimestamp:=Storage:C1525.testErrors[0].timestamp

		$t.assert.isTrue($t; $errorTimestamp>=$beforeTime; "Timestamp should be >= before time")
		$t.assert.isTrue($t; $errorTimestamp<=$afterTime; "Timestamp should be <= after time")
	End use

	// Clean up test errors
	This:C1470._cleanupTestErrors(New collection:C1472("timestampMethod"))

Function test_noInstanceStateRequired($t : cs:C1710.Testing)
	// Verify that multiple instances work independently (stateless class)

	Use (Storage:C1525)
		Storage:C1525.testErrors:=New shared collection:C1527
	End use

	var $reporter1 : cs:C1710.ErrorReporter
	var $reporter2 : cs:C1710.ErrorReporter
	$reporter1:=cs:C1710.ErrorReporter.new()
	$reporter2:=cs:C1710.ErrorReporter.new()

	var $testCallChain : Collection
	$testCallChain:=Get call chain:C1662
	$reporter1.reportHostError(1; "reporter1Method"; "reporter1Formula"; 1; 1; $testCallChain)
	$reporter2.reportLocalError(2; "reporter2Method"; "reporter2Formula"; 2; 2)

	Use (Storage:C1525.testErrors)
		$t.assert.areEqual($t; 2; Storage:C1525.testErrors.length; "Both reporters should store to same storage")
		$t.assert.areEqual($t; "host"; Storage:C1525.testErrors[0].context; "First reporter stored host error")
		$t.assert.areEqual($t; "local"; Storage:C1525.testErrors[1].context; "Second reporter stored local error")
	End use

	// Clean up test errors
	This:C1470._cleanupTestErrors(New collection:C1472("reporter1Method"; "reporter2Method"))
