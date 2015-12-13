package MooX::Zippable::Base;
use Moo::Role;
with 'MooX::But';
require MooX::Zipper;

sub zipper_module { 'MooX::Zipper' }

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
