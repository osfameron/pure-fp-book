use strict; use warnings;
use Test::More;
use Test::Moose;
use Test::Exception;

use signatures;
use Data::Dumper;

use_ok('List');

my $list = List->fromArray( 1..5 );

my $zipper = $list->cursor;

ok $zipper->canMoveNext, 'canMoveNext';

is $zipper->value, 1, 'value';

for (2..5) {
    $zipper = $zipper->moveNext;
    is $zipper->value, $_, 'moveNext';
}
ok ! $zipper->canMoveNext, '!canMoveNext';
ok $zipper->canMovePrev, 'canMovePrev';

for (reverse 1..4) {
    $zipper = $zipper->movePrev;
    is $zipper->value, $_, 'movePrev';
}
ok ! $zipper->canMovePrev, '!canMovePrev';
$zipper = $zipper->moveLast;
is $zipper->value, 5, 'moveLast';
$zipper = $zipper->moveFirst;
is $zipper->value, 1, 'moveFirst';

done_testing;
