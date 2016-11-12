package ACME::Geo::Line;

use strict;
use warnings;
use ACME::Geo::Point;
use ACME::Geo::BoundingBox;

use constant M_PI   => 3.14159265;
use constant STARTP => 0;
use constant ENDP   => 1;
use constant NORMAL => 2;
use constant FORM   => 3;
use constant BBOX   => 4;

sub new {
    my ( $class, $start, $end, $normal ) = @_;
    my $self = [ $start, $end, $normal ];
    bless( $self, $class );
    return $self;
}

sub new_from_point_refs {
    my ( $class, $start, $end, $normal ) = @_;
    my $startp = ACME::Geo::Point->new( @{ $start } );
    my $endp = ACME::Geo::Point->new( @{ $end } );
    my $normalp;
    if ( $normal ) {
        $normalp = ACME::Geo::Point->new( @{ $normal } );
    }
    return $class->new( $startp, $endp, $normalp );
}

sub start { return $_[0]->[STARTP] }
sub end { return $_[0]->[ENDP] }
sub normal { return $_[0]->[NORMAL] }

sub distance_to_point {
    my ( $self, $point ) = @_;

    my $px = $self->[ENDP]->X - $self->[STARTP]->X;
    my $py = $self->[ENDP]->Y - $self->[STARTP]->Y;

    my $something = ( $px * $px ) + ( $py * $py );
    return 0 if $something == 0;

    my $u = ( ( $point->X - $self->[STARTP]->X ) * $px + ( $point->Y - $self->[STARTP]->Y ) * $py) / $something;

    if ( $u > 1 ) {
        $u = 1;
    }
    elsif ( $u < 0 ) {
        $u = 0;
    }

    my $x = $self->[STARTP]->X + $u * $px;
    my $y = $self->[STARTP]->Y + $u * $py;

    my $dx = $x - $point->X;
    my $dy = $y - $point->Y;

    my $dist = sqrt( ( $dx * $dx ) + ( $dy * $dy ) );

    return $dist;
}

sub intersect {
    my ( $self, $line ) = @_;

    my $ss = $self->[STARTP];
    my $se = $self->[ENDP];

    my $ls = $line->[STARTP];
    my $le = $line->[ENDP];

    my $ssx = $ss->X;
    my $ssy = $ss->Y;

    my $sex = $se->X;
    my $sey = $se->Y;

    my $lsx = $ls->X;
    my $lsy = $ls->Y;

    my $lex = $ls->X;
    my $ley = $ls->Y;

    my $s1x = $se->X - $ss->X;
    my $s1y = $se->Y - $ss->Y;

    my $s2x = $le->X - $ls->X;
    my $s2y = $le->Y - $ls->Y;

    my $something = ( -$s2x * $s1y + $s1x * $s2y );
    return () if $something == 0;

    my $s = ( -$s1y * ( $ss->X - $ls->X ) + $s1x * ( $ss->Y - $ls->Y ) ) / $something;
    my $t = (  $s2x * ( $ss->Y - $ls->Y ) - $s2y * ( $ss->X - $ls->X ) ) / $something;

    if ( $s >= 0 && $s <= 1 && $t >= 0 && $t <= 1 ) {
        my $ix = $ss->X + ( $t * $s1x );
        my $iy = $ss->Y + ( $t * $s1y );
        return ACME::Geo::Point->new( $ix, $iy );
    }

    return ();
}

sub intersect_imaginary_line {
    my ( $self, $line ) = @_;

    my $ss = $self->[STARTP];
    my $se = $self->[ENDP];

    my $ls = $line->[STARTP];
    my $le = $line->[ENDP];

    my $a1 = $se->Y - $ss->Y;
    my $b1 = $ss->X - $se->X;

    my $a2 = $le->Y - $ls->Y;
    my $b2 = $ls->X - $le->X;

    my $c1 = ( $a1 * $ss->X ) + ( $b1 * $ss->Y );
    my $c2 = ( $a2 * $ls->X ) + ( $b2 * $ls->Y );

    my $det = ( $a1 * $b2 ) - ( $a2 * $b1 );

    if ( $det != 0 ) {
        my $x = ( $b2 * $c1 - $b1 * $c2 ) / $det;
        my $y = ( $a1 * $c2 - $a2 * $c1 ) / $det;
        return ACME::Geo::Point->new( $x, $y );
    }

    return ();
}

sub parallel {
    my ( $self, $distance, $flip ) = @_;

    my $angle = $self->start->angle_between( $self->end );
    my $tangent = $flip ? ( $angle + ( M_PI / 2 ) ) : ( $angle - ( M_PI / 2 ) );

    my $startn = $self->start->point_angle_distance_from( $tangent, $distance );
    my $endn = $self->end->point_angle_distance_from( $tangent, $distance );

    return ACME::Geo::Line->new( $startn, $endn );
}

sub line_on_same_imaginary_line {
    my ( $self, $line ) = @_;

    my $sf = $self->formula;
    my $lf = $line->formula;

    my $same_slope = 0;
    if ( !defined $sf->[0] && !defined $lf->[0] ) {
        $same_slope = 1;
    }
    elsif ( defined $sf->[0] && defined $lf->[0] && $sf->[0] == $lf->[0] ) {
        $same_slope = 1;
    }
    my $same_offset = $sf->[1] == $lf->[1];

    return ( $same_slope && $same_offset ) ? 1 : 0;
}

sub formula {
    my ( $self ) = @_;
    if ( !defined $self->[FORM] ) {
        $self->[FORM] = $self->_generate_formula;
    }
    return $self->[FORM];
}

sub _generate_formula {
    my ( $self ) = @_;

    my $start = $self->[STARTP];
    my $end = $self->[ENDP];

    my $x1 = $start->X;
    my $x2 = $end->X;
    my $y1 = $start->Y;
    my $y2 = $end->Y;

    my $xd = $x2 - $x1;
    my $yd = $y2 - $y1;

    my $s = ( $xd == 0 ) ? undef : $yd / $xd;

    my $o = ( $xd == 0 ) ? $x1 : ( $y2 - ( $s * $x2 ) );

    my ( $xl, $xu ) = ( $x1 > $x2 ) ? ( $x2, $x1 ) : ( $x1, $x2 );
    my ( $yl, $yu ) = ( $y1 > $y2 ) ? ( $y2, $y1 ) : ( $y1, $y2 );

    return [ $s, $o, [ $xl, $xu ], [ $yl, $yu ] ];
}

sub translate {
    my ( $self, $byx, $byy ) = @_;
    $self->[STARTP]->translate( $byx, $byy );
    $self->[ENDP]->translate( $byx, $byy );
}

sub flip {
    my ( $self ) = @_;
    my $end = $self->[ENDP];
    $self->[ENDP] = $self->[STARTP];
    $self->[STARTP] = $end;
    $self->[FORM] = undef;
    $self->[BBOX] = undef;
}

sub equal {
    my ( $self, $line ) = @_;
    return ( $self->[STARTP]->equal( $line->[STARTP] ) && $self->[ENDP]->equal( $line->[ENDP] ) ) ? 1 : 0;
}

sub move_start {
    my ( $self, $point ) = @_;
    $self->[STARTP] = $point;
}

sub move_end {
    my ( $self, $point ) = @_;
    $self->[ENDP] = $point;
}

sub length {
    my ( $self ) = @_;
    my $dx = $self->[ENDP]->X - $self->[STARTP]->X;
    my $dy = $self->[ENDP]->Y - $self->[STARTP]->Y;
    my $dxr2 = $dx * $dx;
    my $dyr2 = $dy * $dy;
    my $l = sqrt( $dxr2 + $dyr2 );
    return sprintf( '%0.4f', $l );
}

sub bounding_box {
    my ( $self ) = @_;
    if ( !defined $self->[BBOX] ) {
        $self->[BBOX] = ACME::Geo::BoundingBox->new_from_line( $self );
    }
    return $self->[BBOX];
}

1;
