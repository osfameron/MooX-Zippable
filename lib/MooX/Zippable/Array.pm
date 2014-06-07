package MooX::Zippable::Array;
use Moo::Role;
with 'MooX::Zippable::Native';

use constant zipper_class => 'MooX::Zipper::Array';
sub but {
    my ($self, %args) = @_;
    my @array = @$self;
    for my $k (keys %args) {
        $array[$k] = $args{$k};
    }
    return \@array;
}

1;
