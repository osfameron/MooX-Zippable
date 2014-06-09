use strictures;

package MooX::Zippable::Autobox;

BEGIN {
    our $IMPORTED = 0;
}

sub import {
    my ($class, %args) = @_;
    my $target = caller;

    our $IMPORTED;

    if ($args{conditional}) {
        return unless $IMPORTED;
    }
    else {
        $IMPORTED++;
        require MooX::Zipper::Hash;
        require MooX::Zipper::Scalar;
        require MooX::Zipper::Array;

        require MooX::Zippable::Hash;
        require MooX::Zippable::Scalar;
        require MooX::Zippable::Array;
    }

    # oddly, this seems to have to go here, rather than else { } above
    eval "use base 'autobox'";

    $class->autobox::import( 
        HASH => 'MooX::Zippable::Hash',
        SCALAR => 'MooX::Zippable::Scalar',
        ARRAY => 'MooX::Zippable::Array',
    );
}

1;
