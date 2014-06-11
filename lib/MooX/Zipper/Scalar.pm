=head1 NAME

MooX::Zipper::Scalar - a zipper on Scalar values

=head1 SYNOPSIS

    use MooX::Zippable::Autobox;
    my $zipper = 42->zip;

=head1 METHODS

There isn't all that much you can do with a scalar traversal, however it is
provided for consistency.

=head2 C<go>, C<set>

These make no sense, and so raise an error.  However C<replace> will work.

=head2 C<call>

While you can't call a method on a scalar, you can supply a coderef.

    42->zip->call( sub { $_[0] + 1 } )->focus; # 43

=cut

package MooX::Zipper::Scalar;
use Carp qw(croak);
use Moo;
extends 'MooX::Zipper';
with 'MooX::Zippable';
use MooX::Zippable::Autobox conditional => 1;
use Scalar::Util 'reftype';

sub traverse { croak "Can't traverse a scalar" }

sub set { croak "Can't set a scalar key, perhaps you wanted to ->replace?" }

sub call { 
    my ($self, $code) = @_;
    croak "Can't call a method on a scalar, try a callback?"
        unless reftype $code eq 'CODE';
    return $self->next::method($code);
}

1;
