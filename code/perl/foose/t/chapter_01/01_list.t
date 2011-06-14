use strict; use warnings;
use Test::More;
use Test::Moose;
use Test::Exception;

use signatures;

use_ok ('List');

my $list = List->fromArray( 10..20 );

TODO: {
    # NOTE, Foose will shortly be refactored to use Role instead of
    # ABC, in the same way as the moose/ examples do.
    isa_ok  ($list, 'List' );

    local $TODO = 1;
    does_ok  ($list, 'List' );
}

isa_ok   ($list, 'List::Link' );

is $list->first,       10, 'First value ok';
is $list->nth(1),      11, 'This one goes to 11';
is $list->rest->first, 11, '... and this one';
is $list->nth(10),     20, 'Tenth element ok';
dies_ok {
    $list->nth(11);
} 'exception on >10';
dies_ok {
    $list->nth(-1);
} 'exception on <0';

my @users = ({
    first_name => 'Bob',
    last_name  => 'Smith',
}, {
    first_name => 'Aisha',
    last_name  => 'Chaudhury',
});
sub full_name ($record) {
    return join ' ' => 
        $record->{first_name},
        $record->{last_name};
}

my $users = List->fromArray(@users);
my $names = $users->map( \&full_name );

is $names->nth(0), 'Bob Smith',       'map ok';
is $names->nth(1), 'Aisha Chaudhury', 'map ok';

my $filtered = $list->filter( sub { (shift) % 2 });

is $filtered->first,  11, 'odd filter';
is $filtered->nth(1), 13, 'odd filter';


done_testing;
