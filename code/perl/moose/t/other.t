use MooseX::Declare;

class Foo {
    has name => (
        is => 'ro',
        isa => 'Str',
    );
    has other => (
        is => 'rw',
    );
}

package main;
use Data::Thunk;
use Test::More;
use Scalar::Util 'weaken';

my $deaths = 0;
sub Foo::DEMOLISH {
    my $self = shift;
    diag "And so, I die! " . $self->name;
    $self->other(undef);
    $deaths++;
}

my $x;
$x = Foo->new(
    name => 'one',
    other => Foo->new(
        name => 'two',
        other => lazy { $x },
    )
);

is $x->other->name,        'two';
is $x->other->other->name, 'one';

is $deaths, 0;
weaken $x->other->{other};
is $deaths, 0;
$x = $x->other;
is $deaths, 1;
undef $x;
is $deaths, 2;

done_testing;
