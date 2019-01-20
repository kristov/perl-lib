#!/usr/bin/env perl

use Test::More;

use_ok('ACME::RPE::Type::Mass');

my $one_kg = ACME::RPE::Type::Mass->new({kilograms => 1});
ok($one_kg, 'created object');
is(sprintf('%0.3f', $one_kg->pounds), 2.205, 'convert 1kg to pounds');
is(sprintf('%0.3f', $one_kg->force_sealevel->newtons), 9.807, 'correct force at sealevel');
done_testing();
