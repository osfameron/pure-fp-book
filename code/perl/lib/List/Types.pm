package List::Types;

use MooseX::Types -declare => [qw/ List Empty Link /];

class_type Empty, { class => 'List::Empty' };
class_type Link,  { class => 'List::Link' };
role_type  List,  { role => 'List' };

1;
