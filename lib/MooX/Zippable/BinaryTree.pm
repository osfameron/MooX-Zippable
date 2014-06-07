package MooX::Zippable::BinaryTree;
use Carp qw(croak);
use Moo::Role;
with 'MooX::Zippable';
require MooX::Zipper::BinaryTree;

sub traverse {
    my ($self, %args) = @_;
    return MooX::Zipper::BinaryTree->new( head => $self, %args );
}

1;
