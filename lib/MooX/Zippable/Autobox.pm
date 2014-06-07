use strictures;

package MooX::Zippable::Autobox;
use base 'autobox';

require MooX::Zippable::Hash;
require MooX::Zippable::Scalar;
require MooX::Zippable::Array;

require MooX::Zipper::Hash;
require MooX::Zipper::Scalar;
require MooX::Zipper::Array;

sub import {
    my $class = shift;
    $class->SUPER::import(
        HASH => 'MooX::Zippable::Hash',
        SCALAR => 'MooX::Zippable::Scalar',
        ARRAY => 'MooX::Zippable::Array',
    );
}

1;
