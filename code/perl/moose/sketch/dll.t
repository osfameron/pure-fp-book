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
class DLL::Node with DLL {
    has val => (
        isa => 'Any',
        is  => 'ro',
    );
    has prev => (
        # isa => 'DLL',
        isa => 'Any',
        is => 'ro',
    );
    has next => (
        # isa => 'DLL',
        isa => 'Any',
        is => 'ro',
    );
}


package main;
use Test::More;

use Data::Thunk;
use syntax 'function';

fun empty { 
    DLL::Empty->new 
}
fun node ($val,$prev,$next) { 
   DLL::Node->new(val=>$val, prev=>$prev, next=>$next);
}

my $list = do {
    my ($x, $y, $z);
    $x = lazy { node 1, empty, $y };
    $y = lazy { node 2, $x,    $z };
    $z = lazy { node 3, $y, empty };
    # $x = lazy_new 'DLL::Node' => args=>[val=>1, prev=>empty, next=>$y];
    # $y = lazy_new 'DLL::Node' => args=>[val=>2, prev=>$x,    next=>$z];
    # $z = lazy_new 'DLL::Node' => args=>[val=>3, prev=>$y, next=>empty];
    # $x = lazy_object { node 1, empty, $y }, class=>'DLL::Node';
    # $y = lazy_object { node 2, $x,    $z }, class=>'DLL::Node';
    # $z = lazy_object { node 3, $y, empty }, class=>'DLL::Node';
    $x;
};

is $list->val,                          1;
is $list->next->val,                    2;
is $list->next->next->val,              3;
is $list->next->prev->val,              1;
is $list->next->next->prev->val,        2;
is $list->next->next->prev->next->val,  3;

done_testing;
