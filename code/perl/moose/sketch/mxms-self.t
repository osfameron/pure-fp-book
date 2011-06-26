package Foo;
use Moose;
use MooseX::MultiMethods;
use feature 'say';

has foo => (
    isa => 'Int',
    is  => 'ro',
);

use Data::Dumper;
multi method yelp_if ($self: CodeRef $f where { print Data::Dumper::Dumper(\@_) }) {
    warn $f->($self);
    say "YELP!";
}
multi method yelp_if ($self: CodeRef $f) {
    say "{stony silence}";
}

package main;
use Test::More;

sub is_odd {
    my $x = shift;
    $x->foo % 2;
}
my $foo = Foo->new( foo => 4 );
$foo->yelp_if( \&is_odd );

my $foo2 = Foo->new( foo => 3 );
$foo2->yelp_if( \&is_odd );

