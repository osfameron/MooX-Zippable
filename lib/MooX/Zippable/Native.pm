package MooX::Zippable::Native;
use Carp qw(croak);
use Moo::Role;
with 'MooX::Zippable';
use MooX::Zippable::Autobox;

sub traverse {
    my ($self, %args) = @_;
    return $self->zipper_class->new( head => $self, %args );
}

1;
