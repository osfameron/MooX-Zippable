package Tree;
use Moo;
has value => ( is => 'rw' ); # for mutable testing
has left => ( is => 'ro', predicate => 'has_left' );
has right => ( is => 'ro', predicate => 'has_right' );
with 'MooX::Zippable::BinaryTree';

sub cmp { $_[0] <=> $_[1] }

sub leaves {
    my $self = shift;
    if ($self->has_left) {
        return (
            $self->left->leaves, 
            $self->has_right ? $self->right->leaves : ()
        );
    }
    elsif ($self->has_right) {
        die "Unexpected case";
    }
    else {
        return $self->value;
    }
}

sub fromList {
    my ($class, @list) = @_;

    my $pivot = int((@list - 1) / 2);
    $class->new(
        value => $list[$pivot],
        $pivot ? ( left => $class->fromList(@list[0..($pivot-1)]) ) : (),
        ($pivot < $#list) ? (right => $class->fromList(@list[($pivot+1)..$#list])) : (),
    );
}

1;
