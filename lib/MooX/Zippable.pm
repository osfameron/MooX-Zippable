=head1 NAME

MooX::Zippable - helpers for writing immutable code

=head1 SYNOPSIS

    package Foo;
    use Moo;
    with 'MooX::Zippable';

    has foo   => ( isa => 'ro' );
    has child => ( isa => 'ro' );

and later...

    my $foo = Foo->new( foo => 1 );
    my $bar = $foo->but( foo => 2 );

    say $foo->foo; # still 1
    say $bar->foo; # 2

Support for updating linked objects

    my $foo = Foo->new(
        foo => 1,
        child => Foo->new( foo => 1 )
    );

    my $bar = $foo->traverse
        ->go('child')
        ->set(foo => 2)
        ->focus;

    say $foo->child->foo; # still 1
    say $bar->child->foo; # 2

=head1 METHODS

=head2 C<but( $attribute =E<gt> $value, ... )>

Returns a copy of the object, but with the specified attributes overridden.

By default we just call C<-E<gt>new(%$self, ...)> which is a shallow copy.
This does mean that objects will share array/hash references!  This is
considered a feature (you're writing purely functional code, so won't be
destructively updating those references, right?)

If that restriction hurts you, then you may wish to override C<but> (or port
the feature from L<MooseX::Attribute::ChainedClone> which supports finer
grained cloning).

=head2 C<set_hashref( $attribute, $key =E<gt> $value, ...)>

Modify a hashref attribute functionally, adding/overriding keys.

=head2 C<unset_hashref( $attribute, $key, $key2, ...)>

Mofify a hashref attribute functionally, removing keys.

=head2 traverse

Returns a I<zipper> on this object.  You can use the zipper to descend into
child objects and modify them.

If we were using standard Moo with read-write accessors, we might update
an object like this:

    $employee->company->address->telephone( '01234 567 890' );

Because we are using immutable objects we can't simply call:

    $employee->company->address->but(telephone => '01234 567 890' );

All that will do will return a copy of the address object, with the new
telephone number.  e.g.

    say $employee->company->address->telephone; # has not been updated!

To update it, you'd have to update every intermediate object in turn:

    my $employee2 = $employee->but(
        company => $employee->company->but(
            address => $employee->company->address->but(
                telephone => '01234 567 890' )));

Yuck!  Instead, we can call traverse and descend the tree, and set the new field.
The zipper will take care of updating all the intermediate references.

    my $employee2 = $employee->traverse
        ->go('company')
        ->go('address')
        ->set( telephone => '01234 567 890' )
        ->focus;

=head3 C<$zipper-E<gt>go($accessor)>

Traverses to an accessor of the object, keeping a breadcrumb trail back to the previous
object, so that it knows how to zip all the data back up.

=head3 C<$zipper-E<gt>set($accessor =E<gt> $value)>

Seemingly "update" a field of the object.  In fact, behind the scenes, the zipper is
calling C<but> and returning a copy of the object with the values updated.

=head3 C<$zipper-E<gt>call($method =E<gt> @args)>

Assumes that C<$method> returns a copy of the same object.  As with C<set>, you can
imagine that C<call> is updating the object in place, but in fact behind the scenes
everything is immutable.  (In fact, C<set> is itself implemented as:
C<$zipper-E<gt>call( but => $accessor => $value )>)

=head3 C<$zipper-E<gt>up>

Go back up a level

=head3 C<$zipper-E<gt>top>

Go back to the top of the object.  The returned value is I<still> a zipper!  To
return the object instead, use C<focus>

=head3 C<$zipper-E<gt>focus>

Return to the top of the zipper, zipping up all the data you've changed using
C<call> and C<set>, and return the modified copy of the object.

=head1 CAVEATS

    18:46 <@haarg> and you'll want to document the caveats re: but
    18:46 <@osfameron> which caveats?
    18:47 <@haarg> such as only working with hashref based objects, not supporting things with init_arg
    18:47 <@haarg> re-applying coercions
    18:48 <@haarg> running things through BUILDARGS again

See https://github.com/haarg/MooX-Clone/ for a Moosier implementation of ->but!

=head1 SEE ALSO

=over 4

=item *

L<MooseX::Attribute::ChainedClone>

=item *

L<Data::Zipper>

=item *

Zippers in Haskell. L<http://learnyouahaskell.com/zippers> for example.

=back

=cut

package MooX::Zippable;
use Moo::Role;

sub but {
    my $self = shift;
    return $self->new(%$self, @_);
}

sub traverse {
    my ($self, @traversals) = @_;

    return MooX::Zipper->new( head => $self );
}

package MooX::Zipper;
use Moo;
with 'MooX::Zippable';
use Types::Standard qw( ArrayRef );

has head => (
    is => 'ro',
);

has dir => (
    is => 'ro',
);

has zip => (
    is => 'ro',
);

sub go {
    my ($self, $dir) = @_;
    return $self->but(
        head => $self->head->$dir,
        dir => $dir,
        zip => $self,
    );
}

sub call {
    my ($self, $method, @args) = @_;
    return $self->but(
        head => $self->head->$method(@args),
    );
}

sub set {
    my ($self, %args) = @_;
    return $self->but(
        head => $self->head->but(%args)
    );
}

sub set_hashref {
    my ($self, $attr, %args) = @_;
	my $a = $self->head->$attr;
	croak("$attr is not a HASH ref")
	  unless ref($a) eq 'HASH';
	my %a = (%$a, %args);
	return $self->but(
        head => $self->head->but($attr => {%a}),
    );
}

sub unset_hashref {
    my ($self, $attr, @keys) = @_;
	my $a = $self->head->$attr;
	croak("$attr is not a HASH ref")
	  unless ref($a) eq 'HASH';
	my %a = %$a;
	foreach my $k (@keys) {
	  delete $a{$k};
	}
	return $self->but(
        head => $self->head->but($attr => {%a}),
    );
}

sub up {
    my $self = shift;
    return $self->zip->but(
        head => $self->zip->head->but(
            $self->dir => $self->head
        ),
    );
}

sub top {
    my $self = shift;
    return $self unless $self->zip;
    return $self->up->top;
}

sub focus {
    my $self = shift;
    $self->top->head;
}

=head1 AUTHOR and LICENCE

osfameron@cpan.org

Licensed under the same terms as Perl itself.

=cut

1
