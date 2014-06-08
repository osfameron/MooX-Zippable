use strictures;

use Test::More;

use lib 't/lib';
use Tree;

sub tree { Tree->fromList( 1..255 ) };

subtest 'next' => sub {
    my $zipper = tree->traverse->leftmost;
    my @list = ($zipper->head->value);
    while ($zipper = $zipper->next) {
        push @list, $zipper->head->value;
    }
    is_deeply \@list, [1..255], 'next iteration ok';
};

subtest 'prev' => sub {
    my $zipper = tree->traverse->rightmost;
    my @list = ($zipper->head->value);
    while ($zipper = $zipper->prev) {
        push @list, $zipper->head->value;
    }
    is_deeply \@list, [reverse 1..255], 'prev iteration ok';
};

subtest 'modify' => sub {
    my $mult10 = sub { $_[0]->but(value => $_[0]->value * 10) };
    my $tree = tree->traverse
        ->leftmost
        ->call($mult10)
        ->next->call($mult10)
        ->next->call($mult10)
        ->focus;
    is_deeply [ $tree->values ], [ 10,20,30, 4..255 ];
};

subtest 'find' => sub {
    my $zip = tree->traverse;
    for (20, 255, 1, 100) {
        $zip = $zip->find($_);
        is $zip->head->value, $_, "Found $_";
    }

    is $zip->find(256), undef, 'Number not found';
};

done_testing;
