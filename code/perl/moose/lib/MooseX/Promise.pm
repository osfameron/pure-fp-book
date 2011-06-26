package MooseX::Promise;
# use Sub::Exporter -setup => { exports => ['promise'] };
use base 'Exporter';
our @EXPORT = ('promise');
our @EXPORT_OK = ('promise');

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
1;

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

1;
