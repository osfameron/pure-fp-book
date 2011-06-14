use MooseX::Declare;
use List::Types;

role List {
    # use Sub::Call::Tail tail => { -as => 'tail_call' };
    use Sub::Import 'Sub::Call::Tail', tail => { -as => 'tail_call' };
    use MooseX::MultiMethods;
    use Moose::Util::TypeConstraints;

    requires 'head';
    requires 'tail';

    # can be called as a class method
    multi method fromArray ($self:) {
        return List::Empty->new;
    }
    multi method fromArray ($self: $head, @tail) {
        tail_call List::Link->new(
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
        tail_call $self->tail->nth( $pos - 1 );
    }

    multi method map (List::Link $self: CodeRef $f) {
        tail_call $self->new( 
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
            tail_call $self->new( 
                head => $head,
                tail => $self->tail->filter( $f ),
            );
        }
        else {
            tail_call $self->tail->filter( $f );
        }
    }
}

class List::Link with List {
    has head => ( is => 'ro', isa => 'Any' );
    has tail => ( is => 'ro', isa => 'List' ),
}

class List::Empty with List {
    use MooseX::Singleton;

    method head { die "Can't take head of empty list!" }
    method tail { die "Can't take tail of empty list!" }
}

1;
