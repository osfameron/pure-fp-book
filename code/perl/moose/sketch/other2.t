package Foo;

use base 'Class::Accessor';
__PACKAGE__->mk_accessors(qw/ name other /);

package main;
use Test::More;
use Data::Thunk;

my $deaths = 0;
sub Foo::DESTROY {
    my $self = shift;
    $deaths++;
    diag "And so, I die! " . $self->name;
}

my $x;
$x = Foo->new({
    name => 'one',
    other => Foo->new({
        name => 'two',
        other => lazy { $x },
    })
});

is $x->other->name,        'two';
is $x->other->other->name, 'one';

undef $x;
is $deaths, 0;
