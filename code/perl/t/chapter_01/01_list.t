use Test::More;
use Test::Moose;
use Test::Exception;

use_ok ('List');

my $list = List->fromArray( 10..20 );

does_ok  ($list, 'List' );
isa_ok   ($list, 'List::Link' );

is $list->head,    10, 'First value ok';
is $list->nth(1),  11, 'This one goes to 11';
is $list->nth(10), 20, 'Tenth element ok';
dies_ok {
    $list->nth(11);
} 'exception on >10';
dies_ok {
    $list->nth(-1);
} 'exception on <0';

done_testing;
