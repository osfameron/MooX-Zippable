package MooX::Zippable::Scalar;
use Moo::Role;
with 'MooX::Zippable::Native';

use constant zipper_class => 'MooX::Zipper::Scalar';
sub but {
    my ($self, $value) = @_;
    return $value;
}

1;
