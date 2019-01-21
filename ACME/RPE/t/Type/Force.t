#!/usr/bin/env perl

use Test::More;

use_ok('ACME::RPE::Type::Force');

my $obj = ACME::RPE::Type::Force->new({N => 1});
ok($obj, 'created object');
is(sprintf('%0.3f', $obj->lbf), 0.225, 'convert 1N to pound force');
done_testing();
