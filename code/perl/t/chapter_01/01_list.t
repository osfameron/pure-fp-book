use Test::More;
use Test::Moose;

use_ok ('List');

my $list = List->fromArray( 10..20 );

does_ok  ($list, 'List' );
isa_ok   ($list, 'List::Link' );

is $list->head, 10, 'First value ok';

done_testing;
