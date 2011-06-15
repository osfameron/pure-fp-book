use MooseX::Declare;
use List::Types;

role List {
    # use Sub::Call::Tail tail => { -as => 'tail_call' };
    use Sub::Import 'Sub::Call::Tail', tail => { -as => 'tail_call' };
    use MooseX::MultiMethods;
    use Moose::Util::TypeConstraints;
    use Data::Thunk;

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

=begin tricky to optimize as tail calls

    multi method toArray (List::Empty $self:) { 
        return ()
    }
    multi method toArray (List::Link $self:) {
        ($self->head, $self->tail->toArray);
    }

=end
=cut

    method toArray () {
        # iterative, so we'll maintain our own stack
        my @array;
        my $list = $self;
        while ($list->isa('List::Link')) {
            push @array, $list->head;
            $list = $list->tail;
        }
        return @array;
    }

    multi method take (List::Empty $self: Int $n) { 
        return $self;
    }
    multi method take (List::Link $self: Int $n where { $_ == 0 }) {
        return List::Empty->new;
    }
    multi method take (List::Link $self: Int $n where { $_ > 0 }) {
        tail_call List::Link->new({
            head => $self->head,
            tail => $self->tail->take( $n - 1 ),
        });
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

    multi method map (List::Empty $self: CodeRef $f) { 
        return $self;
    }
    multi method map (List::Link $self: CodeRef $f) {
        tail_call $self->new( 
            head => $f->($self->head),
            tail => $self->tail->map( $f )
        );
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

    multi method foldl (List::Empty $self: CodeRef $f, $acc) {
        return $acc;
    }
    multi method foldl (List::Link $self: CodeRef $f, $acc) {
        tail_call $self->tail->foldl($f, $f->($self->head, $acc));
    }

    multi method foldr (List::Empty $self: CodeRef $f, $acc) {
        return $acc;
    }
    # not tail recursive!  haskell optimizes this naturally using laziness, 
    # so let's try annotating part with lazy {} as per: 
    # 23:11 <Twey> You just have to make sure the ‘f x _’ is evaluated 
    #              and the ‘foldr f z xs’ isn't
    multi method foldr (List::Link $self: CodeRef $f, $acc) {
        tail_call $f->(
            $self->head, 
            lazy_object { $self->tail->foldr($f, $acc) }, class=>'List::Link',
        );
    }
}

class List::Link with List {
    has head => ( 
        is => 'ro', 
        isa => 'Any',
    );
    has tail => ( 
        is      => 'ro', 
        isa     => 'List',
        lazy    => 1, 
        default => method { $self->_lazyTail->() },
    ); 
    has lazyTail => ( 
        # this is conceptually a write-only attribute, so _lazyTail
        # is flagged as "private"
        is     => 'bare', 
        reader => '_lazyTail',
        isa    => 'CodeRef',
    );
}

class List::Empty with List {
    use MooseX::Singleton;

    method head { die "Can't take head of empty list!" }
    method tail { die "Can't take tail of empty list!" }
}

1;
