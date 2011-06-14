use strict; use warnings;
use Test::More;
use Test::Moose;
use Test::Exception;

use signatures;
use Data::Thunk;
use Data::Dumper;

use_ok ('List');

my $list = List->fromArray( 10..20 );

does_ok  ($list, 'List' );
isa_ok   ($list, 'List::Link' );

is $list->head,       10, 'First value ok';
is $list->nth(1),     11, 'This one goes to 11';
is $list->tail->head, 11, '... and this one';
is $list->nth(10),    20, 'Tenth element ok';
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

is $filtered->head,   11, 'odd filter';
is $filtered->nth(1), 13, 'odd filter';

my $e1 = List::Empty->new();
my $e2 = List::Empty->new();
is $e1, $e2, 'List::Empty is a singleton';

sub add ($x,$y) { $x + $y }
is $list->foldl( \&add, 0 ), 165, 'foldl';
is $list->foldr( \&add, 0 ), 165, 'foldr';

if (0) {
# the following works if tail typeconstraint is relaxed,
# but laziness plays badly with typeconstraints for now
my $infinite;
$infinite = List::Link->new({
    head => 'foo',
    tail => (lazy_object { $infinite }, class=>'List::Link')
});
is $infinite->nth(42), 'foo', 'The meaning of life';
sub const ($x,$y) { return $x }
is $infinite->foldr(\&const, undef), 'foo', 'foldr on infinite list';
}

done_testing;
