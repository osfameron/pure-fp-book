use inc::Module::Install;
 
# Define metadata
name           'Pure-FP-Book';
# all_from       'lib/Your/Module.pm';
 
# Specific dependencies
requires       'MooseX::Declare';
requires       'Sub::Call::Tail';
requires       'MooseX::MultiMethods';
requires       'MooseX::Singleton';
requires       'signatures';

test_requires  'Test::More'  => '0.42';
 
WriteAll;
