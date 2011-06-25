package MooseX::Promise;
use Sub::Exporter -setup => { exports => ['promise'] };

sub promise (&) { bless $_[0], 'MooseX::Promise' }

package MooseX::Promise::Role;
use Moose::Role;

use Moose::Util::TypeConstraints;

has _promises => (
    traits    => ['Hash'],
    is        => 'ro',
    isa       => 'HashRef[MooseX::Promise]',
    default   => sub { {} },
    predicate => 'has_promise',
    handles   => {
        _set_promise    => 'set',
        _get_promise    => 'get',
        _delete_promise => 'delete',
    },
);

around BUILDARGS => sub {
    my ($orig, $class, %args) = @_;
    while (my ($k, $v) = each %args) {
        if (eval { $v->isa('MooseX::Promise')}) {
            delete $args{$k};
            $args{_promises}{$k} = $v;
        }
    }
    $class->$orig(%args);
};

package MooseX::Promise::Attribute::Trait;
use Moose::Role;
use signatures;

use Moose::Util::TypeConstraints;

around new => sub ($orig, $class, $attr_name, %options) {
    my $attr;
    $attr = $class->$orig( 
        $attr_name,
        %options, 
        lazy => 1,
        default => sub ($self) {
            $self->_get_promise($attr_name)->();
        }
    );
};

=begin accessors for later
# for now, let's just fuck with BUILDARGS instead for this Proof of Concept

around set_value => sub ($orig, $attr, $self,$value) {
    # this never gets called?
    if ( eval { $value->isa('MooseX::Promise') }) {
        # don't actually set, but store in promise hash
        $self->_set_promise($attr->name, $value);
    }
    else {
        $attr->$orig($self, $value);
    }
};
around _inline_set_value => sub {
    # eeeek
};

=end
=cut

package Moose::Meta::Attribute::Custom::Trait::Promise;
sub register_implementation { 'MooseX::Promise::Attribute::Trait' }

package Foo;
use Moose;
import MooseX::Promise;
with 'MooseX::Promise::Role';

has foo => (
    traits => ['Promise'],
    is  => 'rw',
    isa => 'Int'
);

package main;
use Test::More;
use Test::Exception;

# import MooseX::Promise 'promise'; # not sure why this doesn't work
sub promise (&) { bless $_[0], 'MooseX::Promise' }

my $new = 0;
my $x = Foo->new( foo => promise { $new++; 42 });

is $new, 0,     'accessor has never been called';
is $x->foo, 42, 'is set correctly';
is $new, 1,     '... and has therefore been called';
is $x->foo, 42, '... is still set correctly';
is $new, 1,     "... but doens't need to be called again";

my $y = Foo->new( foo => promise { "hello" });
ok 1,           'setting to a promise works';
dies_ok { $y->foo } "but we've broken the promise of its type";

SKIP: {
    skip "Can't test yet, as accessors inlined", 3;

    $x->foo( promise { "hello" });
    ok 1,           'setting to a promise works';
    dies_ok { $x->foo } "but we've broken the promise of its type";
}

done_testing;
