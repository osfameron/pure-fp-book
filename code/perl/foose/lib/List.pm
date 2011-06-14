package List;

use Sub::Import 'Sub::Call::Tail' => tail => { -as => 'tail_call' };
use Foose::ADT;
use MooseX::MultiMethods;

BEGIN {
    # TODO sugar these in Foose::ADT
    class_type 'List::Empty';
    class_type 'List::Link';
}

constructor Empty => ();
constructor Link => (
    safeHead => Any,
    safeTail  => class_type('List'), # TODO export List by default
);

multi method head (List::Empty $self:) {
    die "Can't take head of an empty list";
}
multi method tail (List::Empty $self:) {
    die "Can't take tail of an empty list";
}
multi method head (List::Link $self:) {
    return $self->safeHead;
}
multi method tail (List::Link $self:) {
    return $self->safeTail;
}

method fromArray ($self: @array) {
    if (! @array) {
        return List::Empty->new;
    }

    my ($head, @tail) = @array;
    return List::Link->new(
        $head,
        $self->fromArray(@tail),
    );
}

multi method nth (List::Empty $self: Int $pos) { 
    die "Can't index into an Empty list"; 
}
multi method nth (Int $pos where { $_ == 0 }) {
    return $self->head;
}
multi method nth (Int $pos where { $_ > 0 }) {
    die "EEEK!" if $pos < 0;
    tail_call $self->tail->nth( $pos - 1 );
}

# HUH: why do I need this for Foose test, but not Moose one?
multi method nth (Int $pos) {
    die "Negative! $pos";
}

multi method map (List::Link $self: CodeRef $f) {
    tail_call $self->new( 
        $f->($self->head),
        $self->tail->map( $f )
    );
}
multi method map (List::Empty $self: CodeRef $f) { 
    return $self;
}

multi method filter (List::Empty $self: CodeRef $f) { 
    return $self;
}
multi method filter (List::Link $self: CodeRef $f) {
    my $head = $self->head;
    if ($f->($head)) {
        tail_call $self->new( 
            $head,
            $self->tail->filter( $f ),
        );
    }
    else {
        tail_call $self->tail->filter( $f );
    }
}

1;
