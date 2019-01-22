#!/usr/bin/env perl

use Test::More;

use_ok('ACME::RPE::Definitions');

sub test_specific_impulse {
    my $mass_flow = ACME::RPE::Type::MassFlow->new({kg_s => 23.3});
    my $force = ACME::RPE::Type::Force->new({N => 54_857});
    $Is_mf = ACME::RPE::Definitions::specific_impulse({
        mass_flow => $mass_flow,
        force => $force,
    });
    is(sprintf("%0.0f", $Is_mf->s), 240, 'specific impulse correct (mass_flow + force)');

    my $total_impulse = ACME::RPE::Type::Impulse->new({N_s => 164_808});
    my $propellant_mass = ACME::RPE::Type::Mass->new({kg => 70});
    $Is_ip = ACME::RPE::Definitions::specific_impulse({
        total_impulse => $total_impulse,
        propellant_mass => $propellant_mass,
    });
    is(sprintf("%0.0f", $Is_ip->s), 240, 'specific impulse correct (total_impulse + propellant_mass)');
}

sub test_thrust {
    my $mass_flow = ACME::RPE::Type::MassFlow->new({kg_s => 23.3});
    my $exit_velocity = ACME::RPE::Type::Velocity->new({m_s => 2354});

    my $Th = ACME::RPE::Definitions::thrust({
        mass_flow => $mass_flow,
        exit_velocity => $exit_velocity,
    });
    is(sprintf("%0.0f", $Th->N), 54_848, 'thrust correct');
}

test_specific_impulse();
test_thrust();

done_testing();
