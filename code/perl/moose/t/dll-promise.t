=for Haskell example
    data Node = Empty | Node Int Node Node
        deriving Show
        
    x = let y = Node 2 x y
            z = Node 3 y Empty
         in Node 1 Empty y

=cut

use MooseX::Declare;
use Moose::Util::TypeConstraints;

BEGIN { role_type 'DLL' };
role DLL { }

class DLL::Empty with DLL { }

use MooseX::Promise;

class DLL::Node with DLL with MooseX::Promise::Role {
    has val => (
        isa => 'Any',
        is  => 'ro',
    );
    has prev => (
        traits => ['Promise'],
        isa => 'DLL',
        is => 'ro',
    );
    has next => (
        traits => ['Promise'],
        isa => 'DLL',
        is => 'ro',
    );
}


package main;
use Test::More;
use MooseX::Promise 'promise';

use syntax 'function';
fun empty { 
    DLL::Empty->new 
}
fun node ($val, $prev, $next) {
    DLL::Node->new(
        val  => $val, 
        prev => $prev, 
        next => $next,
    );
}

my $list = do {
    my ($x, $y, $z);
    $x = node 1, empty,        promise {$y};
    $y = node 2, promise {$x}, promise {$z},
    $z = node 3, promise {$y}, empty;
    $x;
};

is $list->val,                          1;
is $list->next->val,                    2;
is $list->next->next->val,              3;
is $list->next->prev->val,              1;
is $list->next->next->prev->val,        2;
is $list->next->next->prev->next->val,  3;

done_testing;
