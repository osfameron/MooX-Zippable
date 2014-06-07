package MooX::Zipper::Array;
use Moo;
extends 'MooX::Zipper';
with 'MooX::Zippable';
use MooX::Zippable::Autobox;

sub go {
    my ($self, $dir) = @_;
    return $self->head->[$dir]->traverse(
        dir => $dir,
        zip => $self,
    );
}

sub push {
    my ($self, @items) = @_;
    return $self->but(
        head => [ @{$self->head}, @items ]
    )
}

sub unshift {
    my ($self, @items) = @_;
    return $self->but(
        head => [ @items, @{$self->head} ]
    )
}

# NB, possibly rename hash's unset to delete also?
sub delete {
    my ($self, @keys) = @_;
    my @head = @{$self->head};
    for my $k (sort { $b <=> $a } @keys) {
        splice @head, $k, 1;
    }
    return $self->but(
        head => \@head,
    );
}

sub reverse {
    my $self = shift;
    return $self->but(
        head => [ reverse @{$self->head} ]
    );
}

sub mapDo {
    my ($self, $code) = @_;
    my @head = map { 
            local $_ = $_->traverse;            
            $code->($_)->focus;
        } 
        @{ $self->head };

    return $self->but(
        head => \@head,
    );
}

1;
