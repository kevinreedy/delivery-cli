Feature: local

  The `delivery local` command runs Workflow phases on your local
  workstation, it requires your project to have the `project.toml`
  file inside the `.delivery/` directory where a user can configure
  the command(s) to run.

Background:
  When I clean up the ruby env so I can run other ruby bins like ChefDK
  Given I am in a chefdk generated cookbook called "local"

Scenario: When local --help is run
  When I run `delivery local --help`
  Then the output should contain "cleanup"
  Then the output should contain "deploy"
  Then the output should contain "lint"
  Then the output should contain "provision"
  Then the output should contain "smoke"
  Then the output should contain "syntax"
  Then the output should contain "unit"
  And the exit status should be 0

Scenario: When local is run with no subcommands
  When I run `delivery local`
  Then the output should contain "error: The following required arguments were not provided:"
  And the exit status should be 1

Scenario: When local is run with an invalid subcommand
  When I run `delivery local bogus`
  Then the output should contain "error: 'bogus' isn't a valid value for '<phase>'"
  And the exit status should be 1

Scenario: Executing the lint phase locally
  When I run `delivery local lint`
  Then the output should match /Running.*Lint.*Phase/
  And the output should contain "no offenses detected"
  And the exit status should be 0

Scenario: Executing the syntax phase locally
  When I run `delivery local syntax`
  Then the output should match /Running.*Syntax.*Phase/
  And the exit status should be 0

Scenario: Executing the unit phase locally
  When I invoke a pseudo tty with command "delivery local unit"
  And I want to debug the pseudo tty command
  And I cd inside my ptty to "local"
  And I run my ptty command
  Then the ptty output should contain "Running.*Unit.*Phase"
  And the ptty output should contain "0 failures"
  And the ptty exit status should be 0

Scenario: Verify that when we modify the `.delivery/project.toml`
          the `delivery local` command picks it up
  When I have a custom project.toml file
  And I invoke a pseudo tty with command "delivery local unit"
  And I cd inside my ptty to "local"
  And I run my ptty command
  Then the ptty output should contain "This is a cool unit test"
  And the ptty exit status should be 0

Scenario: When the project has an invalid `.delivery/project.toml`
  When I have an incomplete project.toml file
  And I invoke a pseudo tty with command "delivery local lint"
  And I cd inside my ptty to "local"
  And I run my ptty command
  Then the ptty exit status should be 1
  And the ptty output should contain "Attempted to decode invalid TOML"

Scenario: When `.delivery/project.toml` file is missing fail and
          show a helpful message about how to recover, additionally
	  run the command to prove it will actually fix it
  When I successfully run `rm -rf .delivery/project.toml`
  And I run `delivery local lint`
  Then the exit status should be 1
  And the output should contain:
    """
    The .delivery/project.toml file was not found.

    You can generate this file using the command:
    	chef generate build-cookbook [NAME]
    """
  Then I run `chef generate build-cookbook .`
  And I run `delivery local lint`
  And the exit status should be 0
  And the output should match /Running.*Lint.*Phase/
  And the output should contain "no offenses detected"
