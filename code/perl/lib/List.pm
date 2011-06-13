use MooseX::Declare;

role List {
    use Sub::Call::Tail;

    requires 'head';
    requires 'tail';

    method fromArray (ClassName $class: @array) {
        if (! @array) {
            return List::Empty->new;
        }

        my ($head, @tail) = @array;
        tail List::Link->new(
            head => $head,
            tail => $class->fromArray(@tail),
        );
    }
}

class List::Link with List {
    use Moose::Util::TypeConstraints 'role_type';

    has head => ( is => 'ro', isa => 'Any' );
    has tail => ( is => 'ro', isa => role_type('List') ),
}

class List::Empty with List {
    method head { die "Can't take head of empty list!" }
    method tail { die "Can't take head of empty list!" }
}

1;
