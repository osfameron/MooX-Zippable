use strictures;
use Test::Most;
use Data::Dumper;

{
    package Foo;
    use Moo;
    with 'MooX::Zippable';

    has number => (
        is => 'ro',
    );

    has child => (
        is => 'ro',
    );

    has hash => (
        is => 'ro',
        builder => sub {+{}},
    );

    sub add_number {
        my ($self, $add) = @_;
        return $self->but(
            number => $self->number + $add,
        );
    }
}

my $struct = Foo->new(
    number => 1,
    child => Foo->new(
        number => 2,
        child => Foo->new(
            number => 3,
            child => Foo->new(
                number => 4
            )
        )
    )
);

subtest "Sanity check - the current way" => sub {

    my $struct = $struct
        ->add_number(15)
        ->but(child => $struct->child->add_number(10)
            ->but( child => $struct->child->child->add_number(5)
                ->but( child => $struct->child->child->child->add_number(1))));
        
    is_deeply $struct, Foo->new(
        number => 16,
        child => Foo->new(
            number => 12,
            child => Foo->new(
                number => 8,
                child => Foo->new(
                    number => 5
                )
            )
        )
    );
};

subtest "With zipper" => sub {

    my $struct = $struct->traverse
        # ->set(number => 16)
        ->call(add_number => 15)
        ->go('child')->call(add_number => 10)
        ->go('child')->call(add_number => 5)
        ->go('child')->call(add_number => 1)
        ->focus;

    is_deeply $struct, Foo->new(
        number => 16,
        child => Foo->new(
            number => 12,
            child => Foo->new(
                number => 8,
                child => Foo->new(
                    number => 5
                )
            )
        )
    );
};

subtest "Test callback" => sub {

    my $add_number = sub {
	  my ($i, $num) = @_;
	  return $i->but(
        number => $i->number + $num,
      );
	};

    my $struct = $struct->traverse
        # ->set(number => 16)
        ->call($add_number => 15)
        ->go('child')->call($add_number => 10)
        ->go('child')->call($add_number => 5)
        ->go('child')->call($add_number => 1)
        ->focus;

    is_deeply $struct, Foo->new(
        number => 16,
        child => Foo->new(
            number => 12,
            child => Foo->new(
                number => 8,
                child => Foo->new(
                    number => 5
                )
            )
        )
    );
};

subtest "Do block" => sub {
    my $struct1 = $struct->traverse
        ->dive('child', 'child')
        ->do( sub { $_->go('child')->call(add_number => 1) } ) # implicit focus
        ->call(add_number => 10)
        ->focus;

    my $struct2 = $struct->doTraverse(sub {
        $_->dive('child', 'child')
        ->call(add_number => 10)
        ->go('child')->call(add_number => 1 )
        # look ma, no ->focus!
        });

    my $expected = Foo->new(
        number => 1,
        child => Foo->new(
            number => 2,
            child => Foo->new(
                number => 13,
                child => Foo->new(
                    number => 5,
                )
            )
        )
    );

    is_deeply $struct1, $expected, 'implicit focus for do block';
    is_deeply $struct2, $expected, 'implicit focus for doTraverse block';
    
};

subtest "is_top" => sub {
    my $zip = $struct->traverse;
    ok $zip->is_top, 'is_top';
    ok ! $zip->go('child')->is_top, 'child is not top';

    ok $zip->go('child')->go('child')->up(2)->is_top, 'up(2) gets us back to top';
};

done_testing;
