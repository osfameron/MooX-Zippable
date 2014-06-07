package MooX::Zipper::BinaryTree;
use Moo;
extends 'MooX::Zipper';

# requires 'left', 'right', 'has_left', 'has_right'; # on Zippable

sub next {
    my $self = shift;
    return $self->right->leftmost if $self->head->has_right;
    return $self->up if $self->dir eq 'left';
    # the complex case, where we have a right parent.
    
    my $zip = $self->up;
    while ($zip->dir eq 'right') {
        $zip = $zip->up;
    }
    return unless $zip->zip; # e.g. we are back at top
    return $zip->up; # on a left path;
}

sub left { $_[0]->go('left') }
sub right { $_[0]->go('right') }
sub first { $_[0]->top->leftmost }
sub last { $_[0]->top->rightmost }

sub leftmost {
    my $self = shift;
    my $zip = $self;
    while ($zip->head->has_left) {
        $zip = $zip->left;
    }
    return $zip;
}

sub rightmost {
    my $self = shift;
    my $zip = $self;
    while ($zip->head->has_right) {
        $zip = $zip->right;
    }
    return $zip;
}

1;
