package MooX::Zipper::BinaryTree;
use Moo;
extends 'MooX::Zipper';

has gt => (
    is => 'ro',
    predicate => 'has_gt',
);
has lt => (
    is => 'ro',
    predicate => 'has_lt',
);

sub left {
    my $self = shift;
    $self->go('left')->but(
        defined $self->gt ? (gt => $self->gt) : (),
        lt => $self->head->value
    );
}

sub right {
    my $self = shift;
    $self->go('right')->but(
        gt => $self->head->value,
        defined $self->lt ? (lt => $self->lt) : (),
    );
}

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

sub next {
    my $self = shift;
    return $self->right->leftmost if $self->head->has_right;
    return $self->up if $self->dir eq 'left';
    # the complex case, where we have a right parent.
    
    my $zip = $self->up;

    while ($zip->dir eq 'right') {
        $zip = $zip->up;
        return unless $zip->zip; # e.g. we are back at top
    }

    return $zip->up; # on a left path;
}

sub prev {
    my $self = shift;
    return $self->left->rightmost if $self->head->has_left;
    return $self->up if $self->dir eq 'right';
    # the complex case, where we have a left parent.
    
    my $zip = $self->up;

    while ($zip->dir eq 'left') {
        $zip = $zip->up;
        return unless $zip->zip; # e.g. we are back at top
    }

    return $zip->up; # on a right path;
}

sub find {
    my ($self, $find) = @_;
    my $cmp = $self->head->can('cmp') || sub { $_[0] cmp $_[1] };
    return $self->up->find($find) if ($self->has_lt and $cmp->($self->lt, $find) < 0);
    return $self->up->find($find) if ($self->has_gt and $cmp->($self->gt, $find) > 0);

    my $cmpd = $cmp->($self->head->value, $find) or return $self;
    if ($cmpd > 0 and $self->head->has_left) {
        return $self->left->find($find);
    }
    if ($cmpd < 0 and $self->head->has_right) {
        return $self->right->find($find);
    }
    return undef;
}

1;
