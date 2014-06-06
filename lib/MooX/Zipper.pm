package MooX::Zipper;
use Moo;
with 'MooX::But';
use MooX::Zippable::Autobox;

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
    return $self->head->$dir->traverse(
        dir => $dir,
        zip => $self,
    );
}

sub dive {
    my ($self, @dirs) = @_;
    my $zip = $self;
    for my $dir (@dirs) {
        $zip = $zip->go($dir);
    }
    return $zip;
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

sub replace {
    my ($self, $new) = @_;
    return $self->but(
        head => $new,
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

sub do {
    my ($self, $code) = @_;
    for ($self->head->traverse) {
        # localises to $_
        return $self->but(
            head => $code->($_)->focus,
        );
    }
}

1;
