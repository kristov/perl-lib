#!/usr/bin/env perl

use Test::More;

use_ok('ACME::RPE::Definitions');

ACME::RPE::Definitions::rocket_mass_ratio({
    initial_mass => ACME::RPE::Type::Mass->new({kilograms => 200}),
    final_mass => ACME::RPE::Type::Mass->new({kilograms => 130}),
    operating_duration => ACME::RPE::Type::Time->new({seconds => 3}),
});

done_testing();
