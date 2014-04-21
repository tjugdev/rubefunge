Rubefunge
=========

Rubefunge is a [Befunge-93](http://esolangs.org/wiki/Befunge) compliant interpreter and debugger written in Ruby.

To install, clone this repository and run:

    gem install bundler
    bundle install

Once installed, tests can be run with `rake test`.


Basic Usage
-----------
To run a program, run
  * `rubefunge FILE`     - for the interpreter
  * `rubefunge -d FILE`  - for the debugger
See `rubefunge --help` for more info
