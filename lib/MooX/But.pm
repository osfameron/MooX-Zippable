=head1 NAME

MooX::But - simple, functional object clone

=head1 SYNOPSIS

    package Foo;
    use Moo;
    with 'MooX::But';

    my $foo = $bar->but( baz => 1 );

C<$foo> is now a copy of C<$bar>, except that the C<baz> field
is set to 1.

=head1 METHODS

We provide only one method:

=head2 C<but( $attribute =E<gt> $value, ... )>

Returns a copy of the object, but with the specified attributes overridden.

This simply calls C<-E<gt>new(%$self, ...)> which is a shallow copy. This does
mean that objects will share array/hash references!  This is considered a
feature (you're writing purely functional code, so won't be destructively
updating those references, right?)

It also only works with hashref based objects, does not support C<init_arg>
and re-applies coercions and BUILDARGS.  If those things are important to
you then see L<https://github.com/haarg/MooX-CloneWith/> which supports
finer grained cloning, similar to L<MooseX::Attribute::ChainedClone>.

=cut

package MooX::But;
use Moo::Role;

sub but {
    my $self = shift;
    return $self->new(%$self, @_);
}

1;
