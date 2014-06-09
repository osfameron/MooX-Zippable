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
