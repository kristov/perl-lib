package ACME::Geo::3D::Part;

use strict;
use warnings;
use ACME::Geo::Layer;

use constant THREEGONS  => 0;
use constant BCUBE      => 1;

sub new {
    my ( $class, @three_gons ) = @_;
    my $self = [ \@three_gons, undef ];
    bless( $self, $class );
    return $self;
}

sub polygon_zplane_intersection {
    my ( $self, $z ) = @_;

    my @lines;
    for my $three_gon ( @{ $self->[THREEGONS] } ) {
        my $line = $three_gon->line_zplane_intersection( $z );
        push @lines, $line if $line;
    }

    my $layer = ACME::Geo::Layer->new_from_unsorted_lines( @lines );
    return $layer;
}

sub bounding_cube {
    my ( $self ) = @_;
    if ( !defined $self->[BCUBE] ) {
        $self->[BCUBE] = ACME::Geo::3D::BoundingCube->new_from_3gons( @{ $self->[THREEGONS] } );
    }
    return $self->[BCUBE];
}

1;
