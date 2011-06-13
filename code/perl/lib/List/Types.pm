package List::Types;

use MooseX::Types -declare => [qw/ List /];
use Moose::Util::TypeConstraints;

class_type 'List::Empty';
class_type 'List::Link';
role_type  'List', { role => 'List' };

1;
