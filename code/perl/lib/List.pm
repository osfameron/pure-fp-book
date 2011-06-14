use MooseX::Declare;
use List::Types;

role List {
    use Sub::Call::Tail;
    use MooseX::MultiMethods;
    use Moose::Util::TypeConstraints;

    requires 'head';
    requires 'tail';

    # can be called as a class method
    method fromArray ($self: @array) {
        if (! @array) {
            return List::Empty->new;
        }

        my ($head, @tail) = @array;
        tail List::Link->new(
            head => $head,
            tail => $self->fromArray(@tail),
        );
    }

    multi method nth (List::Empty $self: Int $pos) { 
        die "Can't index into an Empty list"; 
    }
    multi method nth (Int $pos where { $_ == 0 }) {
        return $self->head;
    }
    multi method nth (Int $pos where { $_ > 0 }) {
        tail $self->tail->nth( $pos - 1 );
    }

    multi method map (List::Link $self: CodeRef $f) {
        tail $self->new( 
            head => $f->($self->head),
            tail => $self->tail->map( $f )
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
            tail $self->new( 
                head => $head,
                tail => $self->tail->filter( $f ),
            );
        }
        else {
            tail $self->tail->filter( $f );
        }
    }
}

class List::Link with List {
    has head => ( is => 'ro', isa => 'Any' );
    has tail => ( is => 'ro', isa => 'List' ),
}

class List::Empty with List {
    method head { die "Can't take head of empty list!" }
    method tail { die "Can't take head of empty list!" }
}

1;
