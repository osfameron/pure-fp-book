package List::Types;

use Moose::Util::TypeConstraints;
class_type 'List::Empty';
class_type 'List::Link';
role_type   'List';

1;
