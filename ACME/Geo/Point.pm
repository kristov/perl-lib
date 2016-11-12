package ACME::Geo::Point;

use strict;
use warnings;

use constant XI => 0;
use constant YI => 1;

sub new {
    my ( $class, $X, $Y ) = @_;
    my $self = [
        sprintf( '%0.4f', $X ),
        sprintf( '%0.4f', $Y ),
    ];
    bless( $self, $class );
    return $self;
}

sub X { return $_[0]->[XI] }
sub Y { return $_[0]->[YI] }

sub distance {
    my ( $self, $point ) = @_;

    my ( $x1, $y1 ) = ( $self->[XI], $self->[YI] );
    my ( $x2, $y2 ) = ( $point->[XI], $point->[YI] );

    my $q = sqrt( ( $x2 - $x1 ) ** 2 + ( $y2 - $y1 ) ** 2 );

    return $q;
}

sub point_angle_distance_from {
    my ( $self, $angle, $distance ) = @_;

    my $x = ( $distance * cos( $angle ) ) + $self->[XI];
    my $y = ( $distance * sin( $angle ) ) + $self->[YI];

    return ACME::Geo::Point->new( $x, $y );
}

sub closest_of_two {
    my ( $self, $point1, $point2 ) = @_;

    my $point1d = $point1->distance( $self );
    my $point2d = $point2->distance( $self );

    return $point2d > $point1d ? $point1 : $point2;
}

sub order_by_distance_asc {
    my ( $self, @points ) = @_;
    my %object = map { ( "$_" => $_ ) } @points;
    my %distance;
    for my $id ( keys %object ) {
        $distance{$id} = $object{$id}->distance( $self );
    }
    my @sorted_ids = sort { $distance{$a} <=> $distance{$b} } keys %object;
    return map { $object{$_} } @sorted_ids;
}

sub angle_between {
    my ( $self, $point ) = @_;
    return atan2( ( $point->[YI] - $self->[YI] ), ( $point->[XI] - $self->[XI] ) );
}

sub translate {
    my ( $self, $byx, $byy ) = @_;
    $self->[XI] = sprintf( '%0.4f', $self->[XI] + $byx );
    $self->[YI] = sprintf( '%0.4f', $self->[YI] + $byy );
}

sub equal {
    my ( $self, $point ) = @_;
    return (
        $self->[XI] == $point->[XI] &&
        $self->[YI] == $point->[YI]
    ) ? 1 : 0;
}

1;
