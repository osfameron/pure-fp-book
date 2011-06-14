package List;

use Sub::Call::Tail;
use Foose::ADT;
use MooseX::MultiMethods;

BEGIN {
    # TODO sugar these in Foose::ADT
    class_type 'List::Empty';
    class_type 'List::Link';
}

constructor Empty => ();
constructor Link => (
    safeFirst => Any,
    safeRest  => class_type('List'), # TODO export List by default
);

multi method first (List::Empty $self:) {
    die "Can't take first of an empty list";
}
multi method rest (List::Empty $self:) {
    die "Can't take rest of an empty list";
}
multi method first (List::Link $self:) {
    return $self->safeFirst;
}
multi method rest (List::Link $self:) {
    return $self->safeRest;
}

method fromArray ($self: @array) {
    if (! @array) {
        return List::Empty->new;
    }

    my ($first, @rest) = @array;
    return List::Link->new(
        $first,
        $self->fromArray(@rest),
    );
}

multi method nth (List::Empty $self: Int $pos) { 
    die "Can't index into an Empty list"; 
}
multi method nth (Int $pos where { $_ == 0 }) {
    return $self->first;
}
multi method nth (Int $pos where { $_ > 0 }) {
    die "EEEK!" if $pos < 0;
    tail $self->rest->nth( $pos - 1 );
}

# HUH: why do I need this for Foose test, but not Moose one?
multi method nth (Int $pos) {
    die "Negative! $pos";
}

multi method map (List::Link $self: CodeRef $f) {
    tail $self->new( 
        $f->($self->first),
        $self->rest->map( $f )
    );
}
multi method map (List::Empty $self: CodeRef $f) { 
    return $self;
}

multi method filter (List::Empty $self: CodeRef $f) { 
    return $self;
}
multi method filter (List::Link $self: CodeRef $f) {
    my $first = $self->first;
    if ($f->($first)) {
        tail $self->new( 
            $first,
            $self->rest->filter( $f ),
        );
    }
    else {
        tail $self->rest->filter( $f );
    }
}

1;
