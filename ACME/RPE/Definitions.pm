package ACME::RPE::Definitions;

use strict;
use warnings;
use Params::Validate;
use ACME::RPE::Type;

sub specific_impulse {
    if (exists $_[0]->{mass_flow} && exists $_[0]->{force}) {
        return __PACKAGE__->specific_impulse_mass_flow_force(@_);
    }
    elsif (exists $_[0]->{total_impulse} && exists $_[0]->{propellant_mass}) {
        return __PACKAGE__->specific_impulse_total_impulse_propellant_mass(@_);
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
}

1;
