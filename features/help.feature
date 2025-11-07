@help
Feature: Testing neuronet help

  Background:
    * Given command "./bin/neuronet"

  Scenario: --help
    * Given option "--help"
    * When we run command
    * Then exit status is "0"
    * Then stderr is ""

  Scenario: -h
    * Given option "-h"
    * When we run command
    * Then exit status is "0"
    * Then stderr is ""

  # HelpParser checks for errors when both flags are set
  Scenario: -h --help
    * Given option "-h --help"
    * When we run command
    * Then exit status is "0"
    * Then stderr is ""
