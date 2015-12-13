package MooX::Zippable::Base;
use Moo::Role;
with 'MooX::But';
use Module::Runtime 'use_module';

has zipper_class => (
    is => 'ro',
    default => 'MooX::Zipper',
);

has zipper_module => (
    is => 'lazy',
    default => sub {
        my $self = shift;
        use_module $self->zipper_class;
    },
);

sub traverse {
    my ($self, %args) = @_;

    return $self->zipper_module->new( head => $self, %args );
}

sub doTraverse {
    my ($self, $code) = @_;
    for ($self->traverse) {
        my $zipper = $code->($_);
        my $value = $zipper->focus;
        return $value;
    }
}

1;
