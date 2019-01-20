#!/usr/bin/env perl

use Test::More;

use_ok('ACME::RPE::Type::Force');

my $one_n = ACME::RPE::Type::Force->new({newtons => 1});
ok($one_n, 'created object');
is(sprintf('%0.3f', $one_n->pound_force), 0.225, 'convert 1N to pound force');
done_testing();
