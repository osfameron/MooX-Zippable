=head1 NAME

MooX::Zipper::Array - a zipper on Array references

=head1 SYNOPSIS

    use MooX::Zippable::Autobox;
    my $zipper = [ 1,2,3 ]->zip;

=head1 METHODS

All the methods of L<MooX::Zipper> are provided.  In addition:

=head2 C<go>

This is overridden to allow us to descend into an array via its index.

=head2 C<set>

This is specialised to set items on the arrayref with its index.

(The specialisation happens in L<MooX::Zippable::Array>C<-E<gt>but>.)

=head2 C<delete>

Remove the specified indices completely (as per C<splice>)

=head2 C<push>

Push an item onto the end of the array.

=head2 C<pop>

In scalar context, returns a zipper onto the array with the final element
popped from the end.  In list context, returns the element and the zipper:

    use MooX::Zippable::Autobox;
    my $x = [1,2,3]->zip->pop->focus; # [1,2]

    my $y = [1,2,3]->zip;
    my ($elem, $y2) = $y->pop; # 3, and a zipper onto [1,2]

=head2 C<unshift>

Unshift an item onto the beginning of the array.

=head2 C<shift>

In scalar context, returns a zipper onto the array with the first element
shifted from the beginning.  In list context, returns the element and the
zipper:

    use MooX::Zippable::Autobox;
    my $x = [1,2,3]->zip->shift->focus; # [2,3]

    my $y = [1,2,3]->zip;
    my ($elem, $y2) = $y->shift; # 1, and a zipper onto [2,3]

=head2 C<reverse>

Reverses the array

=head2 C<sort>

Sorts the array, with an optional subroutine (which must be declared with C<@_>)

    $zip = $zip->sort; # default lexicographic order
    $zip = $zip->sort( sub { $_[0] <=> $_[1] }; # numerically

=head2 C<mapDo>

Apply the supplied coderef to every element.  This feature is experimental, see
the test-case for more details.  Use-cases and documentation patches welcome if
you find this useful.

=cut

package MooX::Zipper::Array;
use Moo;
extends 'MooX::Zipper';
with 'MooX::Zippable';
use MooX::Zippable::Autobox conditional => 1;

sub traverse {
    my ($self, $dir) = @_;
    return $self->focus->[$dir];
}

sub push {
    my ($self, @items) = @_;
    return $self->but(
        focus => [ @{$self->focus}, @items ]
    )
}

sub unshift {
    my ($self, @items) = @_;
    return $self->but(
        focus => [ @items, @{$self->focus} ]
    )
}

# NB, possibly rename hash's unset to delete also?
sub delete {
    my ($self, @keys) = @_;
    my @focus = @{$self->focus};
    for my $k (sort { $b <=> $a } @keys) {
        splice @focus, $k, 1;
    }
    return $self->but(
        focus => \@focus,
    );
}

sub reverse {
    my $self = shift;
    return $self->but(
        focus => [ reverse @{$self->focus} ]
    );
}

sub mapDo {
    my ($self, $code) = @_;
    my @focus = map { 
            local $_ = $_->parent;            
            $code->($_)->focus;
        } 
        @{ $self->focus };

    return $self->but(
        focus => \@focus,
    );
}

sub pop {
    my $self = shift;
    my @focus = @{ $self->focus };
    my $elem = pop @focus,
    my $zip = $self->but( focus => \@focus );
    return wantarray ? ($elem, $zip) : $zip;
}

sub shift {
    my $self = shift;
    my @focus = @{ $self->focus };
    my $elem = shift @focus,
    my $zip = $self->but( focus => \@focus );
    return wantarray ? ($elem, $zip) : $zip;
}

sub sort {
    my ($self, $sub) = @_;
    my @focus = @{ $self->focus };
    @focus = $sub ?
        sort { $sub->($a, $b) } @focus
        : sort @focus;
    return $self->but( focus => \@focus );
}

1;
