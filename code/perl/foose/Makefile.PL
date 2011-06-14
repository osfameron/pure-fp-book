use inc::Module::Install;
 
# Define metadata
name           'Pure-FP-Book';
# all_from       'lib/Your/Module.pm';
 
# Specific dependencies
requires       'Foose'; # from https://github.com/osfameron/foose
requires       'Sub::Call::Tail';
requires       'MooseX::MultiMethods';
requires       'signatures';

test_requires  'Test::More'  => '0.42';
 
WriteAll;
