use strictures;
use Test::Most;

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

subtest "Hash traversals" => sub {

    my $struct = $struct->traverse
        ->go('hash')
            ->set(a => 'b', c => 'd')
            ->up
        ->go('child')
            ->go('hash')
                ->set(b => 'c', d => 'a')
                ->up
            ->go('child')
                ->go('hash')
                    ->set(b => 'c', 'c' => 'd')
                    ->up
                ->go('hash')
                    ->unset(qw(b c))
                    ->up
                ->go('child')
                    ->go('hash')
                        ->unset(qw(foo bar))
        ->focus;

    eq_or_diff $struct,
        (bless { number => 1, child =>
            (bless { number => 2, child =>
                (bless {
                    number => 3,
                    child => (bless {
                        number => 4, hash => {},
                    }, 'Foo'),
                    hash => {},
                }, 'Foo'),
                hash => {qw(b c d a)},
            }, 'Foo'),
            hash => {qw(a b c d)},
        }, 'Foo');
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

subtest "Deeply into hash" => sub {
    my $foo = Foo->new( hash => { foo => { bar => { baz => 2 } } } );
    my $bar = $foo->traverse
        ->go('hash')->go('foo')->go('bar')
        ->set(baz => 3)
        ->focus;

    is $foo->hash->{foo}{bar}{baz}, 2, 'sanity check';
    is $bar->hash->{foo}{bar}{baz}, 3, 'traverse hash set ok';
};

subtest "Dive" => sub {
    my $foo = Foo->new( hash => { foo => { bar => { baz => 2 } } } );
    my $bar = $foo->traverse->dive(hash=>foo=>'bar')->set(baz=>3)->focus;
    my $baz = $foo->traverse->dive(hash=>foo=>bar=>'baz')->replace(4)->focus;
    my $qux = $foo->traverse->dive(hash=>foo=>'bar')->replace({ baz => 5 })->focus;

    is $foo->hash->{foo}{bar}{baz}, 2, 'sanity check';
    is $bar->hash->{foo}{bar}{baz}, 3, 'traverse hash set ok';
    is $baz->hash->{foo}{bar}{baz}, 4, 'traverse hash/scalar ok';
    is $qux->hash->{foo}{bar}{baz}, 5, 'replace whole hash ok';
};

done_testing;
