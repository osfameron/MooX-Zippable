=head1 Benchmarks

We create a tree of 7 levels (255 elements) to do some typical manipulations.

=cut

use strictures;
use Data::Dumper;
use Test::More;
use Storable 'dclone';
use Benchmark 'cmpthese';
use lib 't/lib';
use Tree;

sub tree { Tree->fromList( 1..255 ) };
my $mult10 = sub { $_[0]->but(value => $_[0]->value * 10) };

=head1 Task 1

Multiply first 3 nodes by 10

=head2 Results and analysis

On my vagrant box:

               Rate mutable_c    zipper   mutable
    mutable_c 219/s        --       -2%      -21%
    zipper    224/s        2%        --      -19%
    mutable   276/s       26%       23%        --

Mutable access is faster, as you'd imagine (though the code is less nice, that 
could indeed be improved by providing a mutable zipper, as dysfun has suggested).

However, if you want to then keep copies, by using dclone, zipper turns out to
be marginally faster.

=cut

sub t1_exp { Tree->fromList( 10, 20, 30, 4..255 ) }

sub t1_zipper {
    return tree->traverse
        ->leftmost
        ->call($mult10)
        ->next->call($mult10)
        ->next->call($mult10)
        ->focus;
}

sub t1_mutable {
    my $tree = tree;
    my $subtree = $tree->left->left->left->left->left->left;
    for ($subtree, $subtree->left, $subtree->right) {
        $_->value($_->value * 10);
    }
    return $tree;
}

sub t1_mutable_with_clone {
    my $tree = dclone(tree);
    my $subtree = $tree->left->left->left->left->left->left;
    for ($subtree, $subtree->left, $subtree->right) {
        $_->value($_->value * 10);
    }
    return $tree;
}

is_deeply t1_zipper(), t1_exp();
is_deeply t1_mutable(), t1_exp();
is_deeply t1_mutable_with_clone(), t1_exp();

cmpthese 1000 => {
    zipper => \&t1_zipper,
    mutable => \&t1_mutable,
    mutable_c => \&t1_mutable_with_clone,
};

=head1 Task 2

Multiply first and last nodes by 10

=head2 Results and analysis

On my vagrant box:

               Rate    zipper mutable_c   mutable
    zipper    213/s        --       -3%      -23%
    mutable_c 219/s        3%        --      -21%
    mutable   277/s       30%       27%        --

In this worst case scenario, using zipper is slightly less efficient than
cloning the whole structure and modifying it.

=cut

sub t2_exp { Tree->fromList( 10, 2..254, 2550 ) }

sub t2_zipper {
    return tree->traverse
        ->first->call($mult10)
        ->last->call($mult10)
        ->focus;
}

sub t2_mutable {
    my $tree = tree;
    my $left = $tree->left->left->left->left->left->left->left;
    my $right = $tree->right->right->right->right->right->right->right;
    for ($left, $right) {
        $_->value($_->value * 10);
    }
    return $tree;
}

sub t2_mutable_with_clone {
    my $tree = dclone(tree);
    my $left = $tree->left->left->left->left->left->left->left;
    my $right = $tree->right->right->right->right->right->right->right;
    for ($left, $right) {
        $_->value($_->value * 10);
    }
    return $tree;
}

is_deeply t2_zipper(), t2_exp();
is_deeply t2_mutable(), t2_exp();
is_deeply t2_mutable_with_clone(), t2_exp();

cmpthese 1000 => {
    zipper => \&t2_zipper,
    mutable => \&t2_mutable,
    mutable_c => \&t2_mutable_with_clone,
};

done_testing;
