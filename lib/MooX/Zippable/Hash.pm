package MooX::Zippable::Hash;
use Moo::Role;
with 'MooX::Zippable::Native';

use constant zipper_class => 'MooX::Zipper::Hash';
sub but {
    my ($self, %args) = @_;
    return { %{$self}, %args };
}

1;
