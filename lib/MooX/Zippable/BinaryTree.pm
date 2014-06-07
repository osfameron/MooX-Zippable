package MooX::Zippable::BinaryTree;
use Carp qw(croak);
use Moo::Role;
with 'MooX::Zippable';
require MooX::Zipper::BinaryTree;

requires 'left', 'right', 'has_left', 'has_right'; # on Zippable

sub traverse {
    my ($self, %args) = @_;
    return MooX::Zipper::BinaryTree->new( head => $self, %args );
}

1;
