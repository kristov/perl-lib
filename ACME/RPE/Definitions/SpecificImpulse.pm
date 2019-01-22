package ACME::RPE::Definitions::SpecificImpulse;

use strict;
use warnings;
use Params::Validate;
use ACME::RPE::Type;

sub specific_impulse {
    if (exists $_[0]->{mass_flow} && exists $_[0]->{force}) {
        return specific_impulse_mass_flow_force(@_);
    }
    elsif (exists $_[0]->{total_impulse} && exists $_[0]->{propellant_mass}) {
        return specific_impulse_total_impulse_propellant_mass(@_);
    }
}

sub specific_impulse_mass_flow_force {
    validate(@_, {
        mass_flow => {isa => 'ACME::RPE::Type::MassFlow'},
        force => {isa => 'ACME::RPE::Type::Force'},
    });

    my $mass_flow = $_[0]->{mass_flow};
    my $force = $_[0]->{force};

    return ACME::RPE::Type::SpecificImpulse->new({s => $force->N / ($mass_flow->kg_s * 9.8066)});
}

sub specific_impulse_total_impulse_propellant_mass {
    validate(@_, {
        total_impulse => {isa => 'ACME::RPE::Type::Impulse'},
        propellant_mass => {isa => 'ACME::RPE::Type::Mass'},
    });

    my $total_impulse = $_[0]->{total_impulse};
    my $propellant_mass = $_[0]->{propellant_mass};

    my $gravity = ACME::RPE::Type::Acceleration->gravity_sealevel();
    my $weight = $propellant_mass->kg * $gravity->m_s2;

    return ACME::RPE::Type::SpecificImpulse->new({s => $total_impulse->N_s / $weight});
}

1;
