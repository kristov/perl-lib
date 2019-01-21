#!/usr/bin/env perl

use Test::More;

use_ok('ACME::RPE::Definitions');

sub test_specific_impulse {
    my $mass_flow = ACME::RPE::Type::MassFlow->new({kg_s => 23.3});
    my $force = ACME::RPE::Type::Force->new({N => 54_857});

    my $Is = ACME::RPE::Definitions::specific_impulse_mass_flow_force({
        mass_flow => $mass_flow,
        force => $force,
    });

    is(sprintf("%0.3f", $Is->s), 240.081, 'specific impulse correct');
}

test_specific_impulse();

done_testing();
