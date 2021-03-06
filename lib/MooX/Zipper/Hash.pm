=head1 NAME

MooX::Zipper::Hash - a zipper on Hash references

=head1 SYNOPSIS

    use MooX::Zippable::Autobox;
    my $zipper = { foo => 1 }->traverse;

=head1 METHODS

All the methods of L<MooX::Zipper> are provided.  In addition:

=head2 C<go>

This is overridden to allow us to descend into a hash via its key.

=head2 C<set>

This is specialised to set the hashref keys, rather than using any
Moo functionality.

(The specialisation happens in L<MooX::Zippable::Hash>C<-E<gt>but>.)

=head2 C<unset>

Remove the specified keys.

=cut

package MooX::Zipper::Hash;
use Moo;
extends 'MooX::Zipper';
with 'MooX::Zippable';
use MooX::Zippable::Autobox conditional => 1;

sub go {
    my ($self, $dir) = @_;
    return $self->head->{$dir}->traverse(
        dir => $dir,
        zip => $self,
    );
}

sub unset {
    my ($self, @keys) = @_;
    my %hash = %{ $self->head };
	foreach my $k (@keys) {
	  delete $hash{$k};
	}
	return $self->but(
        head => \%hash,
    );
}

1;
