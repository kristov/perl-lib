#!/usr/bin/env perl

use Test::More;

use_ok('ACME::RPE::Type::Mass');

my $obj = ACME::RPE::Type::Mass->new({kg => 1});
ok($obj, 'created object');
is(sprintf('%0.3f', $obj->lb), 2.205, 'convert 1kg to lb');
done_testing();
