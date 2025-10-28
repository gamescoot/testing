# 4D Unit Testing Framework

A comprehensive unit testing framework for the 4D platform with test tagging, filtering, and CI/CD integration.

## Key Features

- **Auto test discovery** - Finds test classes ending with "Test"
- **Test tagging** - Organize tests with `// #tags: unit, integration, slow`
- **Flexible filtering** - Run specific tests by name, pattern, or tags
- **Multiple output formats** - Human-readable and JSON output
- **CI/CD ready** - Structured JSON output for automated testing
- **Transaction management** - Automatic test isolation with rollback
- **Subtests** - Run table-driven tests with `t.run`

## Quick Example

```4d
// UserServiceTest.4dm
Class constructor()

// #tags: unit, fast
Function test_user_creation($t : cs.Testing)
    var $user : Object
    $user:=New object("name"; "John"; "email"; "john@example.com")
    
    $t.assert.isNotNull($t; $user.name; "User should have a name")
    $t.assert.areEqual($t; "John"; $user.name; "User name should be correct")

// #tags: integration, database
Function test_user_persistence($t : cs.Testing)
    // Database operations are automatically rolled back
    var $user : cs.UsersEntity
    $user:=ds.Users.new()
    $user.name:="John"
    $user.email:="john@example.com"
    var $result : Object
    $result:=$user.save()
    $t.assert.isTrue($t; $result.success; "User should be saved successfully")
```

## Setup

**Step 1:** Create `Testing_ReportHostError` project method:

```4d
// Error handler to capture host project errors and report to testing component
cs.Testing.ErrorReporter.new().reportHostError(Error; Error method; Error formula; Error line; Current process; Get call chain)
```

**Step 2:** Create `Testing_ReportGlobalError` project method:

```4d
// Error handler to capture global project errors and report to testing component
cs.Testing.ErrorReporter.new().reportGlobalError(Error; Error method; Error formula; Error line; Current process; Get call chain)
```

**Step 3:** Create `RunTests` project method:

```4d
// Necessary to run tests using the Testing component, passing in cs from host.
// Use as entrypoint when calling via tool4d
// e.g. tool4d --project Project/MyProject.4DProject --skip-onstartup --dataless --startup-method "RunTests"
ON ERR CALL("Testing_ReportGlobalError"; ek global)
ON ERR CALL("Testing_ReportHostError")
Testing_RunTestsWithCs(cs)
ON ERR CALL("")
ON ERR CALL(""; ek global)
```

## Running Tests

```bash
# Run all tests
tool4d --project YourProject.4DProject --startup-method "RunTests"

# Run with JSON output
tool4d --project YourProject.4DProject --startup-method "RunTests" --user-param "format=json"

# Run specific tests
tool4d --project YourProject.4DProject --startup-method "RunTests" --user-param "test=UserServiceTest"
tool4d --project YourProject.4DProject --startup-method "RunTests" --user-param "test=UserServiceTest.test_user_creation"

# Filter by tags
tool4d --project YourProject.4DProject --startup-method "RunTests" --user-param "tags=unit"
tool4d --project YourProject.4DProject --startup-method "RunTests" --user-param "tags=unit excludeTags=slow"
```

## Table-Driven Tests

Use subtests to build table-driven tests. Each call to `t.run` executes the provided function with a fresh testing context. If a subtest fails, the parent test is marked as failed. Subtests run with the same `This` object as the parent test, so helper methods and state remain accessible. Pass optional data as the third argument when the test logic lives in a separate method.

```4d
Function test_math($t : cs.Testing)
    var $cases : Collection
    $cases:=[New object("name"; "1+1"; "in"; 1; "want"; 2)]

    var $case : Object
    For each ($case; $cases)
        $t.run($case.name; This._checkMathCase; $case)
    End for each

Function _checkMathCase($t : cs.Testing; $case : Object)
    $t.assert.areEqual($t; $case.want; $case.in+1; "math works")
```

## Output

**Human format:**
```
  ✓ test_user_creation (1ms)
  ✓ test_user_persistence (5ms)

2 tests passed
```

**JSON format:**
```json
{
  "totalTests": 2,
  "passed": 2,
  "failed": 0,
  "passRate": 100,
  "status": "success"
}
```

## Documentation

- [Detailed Guide](docs/guide.md) - Complete documentation with examples
- [CI/CD Integration](docs/guide.md#cicd-integration)
- [Advanced Features](docs/guide.md#test-tagging)

## License

MIT License
