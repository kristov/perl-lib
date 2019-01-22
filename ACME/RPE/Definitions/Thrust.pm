package ACME::RPE::Definitions::Thrust;

use strict;
use warnings;
use Params::Validate;
use ACME::RPE::Type;

sub thrust {
    validate(@_, {
        mass_flow => {isa => 'ACME::RPE::Type::MassFlow'},
        exit_velocity => {isa => 'ACME::RPE::Type::Velocity'},
    });

    my $mass_flow = $_[0]->{mass_flow};
    my $exit_velocity = $_[0]->{exit_velocity};

    return ACME::RPE::Type::Force->new({N => $mass_flow->kg_s * $exit_velocity->m_s});
}

1;
