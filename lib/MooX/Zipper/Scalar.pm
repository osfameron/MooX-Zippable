package MooX::Zipper::Scalar;
use Carp qw(croak);
use Moo;
extends 'MooX::Zipper';
with 'MooX::Zippable';
use MooX::Zippable::Autobox;
use Scalar::Util 'reftype';

sub go { croak "Can't traverse a scalar" }

sub set { croak "Can't set a scalar key, perhaps you wanted to ->replace?" }

sub call { 
    my ($self, $code) = @_;
    croak "Can't call a method on a scalar, try a callback?"
        unless reftype $code eq 'CODE';
    return $self->next::method($code);
}

1;
