#!/usr/bin/env perl

use Test::More;

use_ok('ACME::RPE::Type::Acceleration');

my $obj = ACME::RPE::Type::Acceleration->new({ft_s2 => 1});
ok($obj, 'created object');
is(sprintf('%0.3f', $obj->m_s2), 0.305, 'convert 1 ft/s2 into m/s2');
done_testing();
