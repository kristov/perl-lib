package ACME::RPE::Type::Acceleration;

use Moose;

use constant ACCL_GRAVITY_SEALEVEL => 9.8066;
use constant MS2_TO_FTS2 => 3.28084;

has 'm_s2' => (
    is => 'ro',
    isa => 'Num',
    required => 0,
    lazy => 1,
    builder => '_build_m_s2',
);

sub _build_m_s2 {
    my ($self) = @_;
    return $self->ft_s2 / MS2_TO_FTS2;
}

has 'ft_s2' => (
    is => 'ro',
    isa => 'Num',
    required => 0,
    lazy => 1,
    builder => '_build_ft_s2',
);

sub _build_ft_s2 {
    my ($self) = @_;
    return $self->m_s2 * MS2_TO_FTS2;
}

sub gravity_sealevel {
    my ($self) = @_;
    return $self->new({m_s2 => ACCL_GRAVITY_SEALEVEL});
}

__PACKAGE__->meta->make_immutable;
