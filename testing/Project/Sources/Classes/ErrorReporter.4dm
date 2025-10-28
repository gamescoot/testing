// Centralized error reporting for the testing framework
// Records errors from various sources into the shared error tracking system
//
// Context types:
// - "local" : Errors from within the test process (captured per-test)
// - "global": Errors from other processes (captured at end of run)
// - "host"  : Errors from the host project (captured like global errors)
//
// For host project integration, use Testing_ReportHostError() shared method
// (host projects cannot directly access component classes)

// Static utility class - no instance state needed
Class constructor()

Function reportHostError($errorCode : Integer; $errorText : Text; $errorMethod : Text; $errorLine : Integer; $processNumber : Integer; $callChain : Collection)
	// Report an error from the host project
	// Host errors are treated like global errors (captured at end, not per-test)
	This:C1470._storeError($errorCode; $errorText; $errorMethod; $errorLine; $processNumber; "host"; False:C215; $callChain)

Function reportLocalError($errorCode : Integer; $errorText : Text; $errorMethod : Text; $errorLine : Integer; $processNumber : Integer; $callChain : Collection)
	// Report a local component error (from within test process)
	// Local errors are captured per-test, associated with the specific test that failed
	If ($callChain=Null:C1517)
		$callChain:=Get call chain:C1662
	End if
	This:C1470._storeError($errorCode; $errorText; $errorMethod; $errorLine; $processNumber; "local"; True:C214; $callChain)

Function reportGlobalError($errorCode : Integer; $errorText : Text; $errorMethod : Text; $errorLine : Integer; $processNumber : Integer; $callChain : Collection)
	// Report a global component error (from outside test process)
	// Global errors occur outside the test process and are captured at the end
	If ($callChain=Null:C1517)
		$callChain:=Get call chain:C1662
	End if
	This:C1470._storeError($errorCode; $errorText; $errorMethod; $errorLine; $processNumber; "global"; False:C215; $callChain)

Function _storeError($errorCode : Integer; $errorText : Text; $errorMethod : Text; $errorLine : Integer; $processNumber : Integer; $context : Text; $isLocal : Boolean; $callChain : Collection)
	// Internal method that does the actual error storage work

	// Ensure shared error storage exists
	If (Storage:C1525.testErrors=Null:C1517)
		Use (Storage:C1525)
			Storage:C1525.testErrors:=New shared collection:C1527
		End use
	End if

	var $errorInfo : Object
	$errorInfo:=New shared object:C1526()


		// Convert callChain to shared collection
	var $sharedCallChain : Collection
	If ($callChain#Null:C1517)
		$sharedCallChain:=$callChain.copy(ck shared:K85:29; $errorInfo)
	Else
		$sharedCallChain:=Null:C1517
	End if


	
	Use (Storage:C1525.testErrors)
		Storage:C1525.testErrors.push($errorInfo)

	End use
		Use ($errorInfo)
					OB SET($errorInfo;\
		"code"; $errorCode; \
		"text"; $errorText; \
		"method"; $errorMethod; \
		"line"; $errorLine; \
		"timestamp"; Milliseconds:C459; \
		"processNumber"; $processNumber; \
		"context"; $context; \
		"isLocal"; $isLocal)
		$errorInfo.callChain:=$sharedCallChain
	End use
