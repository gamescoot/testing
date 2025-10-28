//%attributes = {}
// TestErrorHandler
// Local error handler for the testing framework
// Captures runtime errors and records minimal metadata for later reporting

var $errorCode : Integer
var $errorText : Text
var $errorMethod : Text
var $errorLine : Integer
var $processNumber : Integer
var $callChain : Collection

$errorCode:=Error
$errorText:=Error method
$errorMethod:=Error formula
$errorLine:=Error line
$processNumber:=Current process:C322
$callChain:=Get call chain:C1662

// Report error using the centralized ErrorReporter class
var $reporter : cs:C1710.ErrorReporter
$reporter:=cs:C1710.ErrorReporter.new()
$reporter.reportLocalError($errorCode; $errorText; $errorMethod; $errorLine; $processNumber; $callChain)

// Continue execution - don't interrupt the test
