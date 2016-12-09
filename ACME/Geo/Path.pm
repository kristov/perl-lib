package ACME::Geo::Path;

use strict;
use warnings;
use ACME::Geo::Line;
use Math::Geometry::Planar;

sub new {
    my ( $class, @lines ) = @_;

    my @new_lines;

    if ( @lines ) {
        my $last_line;
        my $first_line;
        LINE: for my $line ( @lines ) {
            $first_line = $line if !defined $first_line;

            if ( !defined $last_line ) {
                $last_line = $line;
                next LINE;
            }

            if ( $last_line->line_on_same_imaginary_line( $line ) ) {
                my $new_line = ACME::Geo::Line->new( $last_line->start, $line->end, $last_line->normal );
                $last_line = $new_line;
            }
            else {
                push @new_lines, $last_line;
                $last_line = $line;
            }
        }
        if ( $last_line->line_on_same_imaginary_line( $first_line ) ) {
            my $new_line = ACME::Geo::Line->new( $last_line->start, $first_line->end, $last_line->normal );
            my $orig_first = shift @new_lines;
            unshift @new_lines, $new_line;
        }
        else {
            push @new_lines, $last_line;
        }
    }

    my $self = [ @new_lines ];
    bless( $self, $class );
    return $self;
}

sub first_line { return $_[0]->[0] }
sub last_line { return $_[0]->[-1] }

sub closed {
    my ( $self ) = @_;
    return $self->first_line->start->equal( $self->last_line->end ) ? 1 : 0;
}

sub has_zero_length_lines {
    my ( $self ) = @_;
    my $has_zero_length_lines = 0;
    for my $line ( @{ $self } ) {
        $has_zero_length_lines = 1 if $line->start->equal( $line->end );
    }
    return $has_zero_length_lines;
}

sub parallel_path {
    my ( $self, $distance, $normal ) = @_;

    my @parallels;
    my $prev_parallel;
    my $first_line;
    my $prev_line;
    my $first_parallel;

    for my $line ( @{ $self } ) {

        my $parallel = $line->parallel( $distance, $normal );

        if ( $prev_parallel ) {
            my ( $point ) = $prev_parallel->intersect_imaginary_line( $parallel );
            if ( $point ) {
                $prev_parallel->move_end( $point );
                $parallel->move_start( $point );
            }
            else {
                warn sprintf( "no intersect between: [ %0.2f, %0.2f ]=[ %0.2f, %0.2f ] and [ %0.2f, %0.2f ]=[ %0.2f, %0.2f ]\n",
                    $prev_parallel->start->X, $prev_parallel->start->Y,
                    $prev_parallel->end->X, $prev_parallel->end->Y,
                    $parallel->start->X, $parallel->start->Y,
                    $parallel->end->X, $parallel->end->Y,
                );
            }
        }
        push @parallels, $parallel;

        $prev_parallel = $parallels[-1];
        $first_parallel = $parallels[0] if !$first_parallel;
        $first_line = $line if !defined $first_line;
        $prev_line = $line;
    }

    if ( $prev_line ) {
        if ( $prev_line->end->equal( $first_line->start ) ) {
            my ( $point ) = $prev_parallel->intersect_imaginary_line( $first_parallel );
            if ( $point ) {
                $prev_parallel->move_end( $point );
                $first_parallel->move_start( $point );
            }
        }
    }

    return ACME::Geo::Path->new( @parallels );
}

sub translate {
    my ( $self, $byx, $byy ) = @_;
    for my $line ( @{ $self } ) {
        $line->translate( $byx, $byy );
    }
}

sub self_intersects {
    my ( $self ) = @_;

    my $nr_lines = scalar( @{ $self } );
    for ( my $l1x = 0; $l1x < $nr_lines; $l1x++ ) {
        for ( my $l2x = 0; $l2x < $nr_lines; $l2x++ ) {
            next if $l2x <= $l1x;
            return 1 if $self->[$l1x]->interesct( $self->[$l2x] );
        }
    }
}

sub reverse {
    my ( $self ) = @_;
    my @lines = reverse( @{ $self } );
    map { $_->flip } @lines;
    $self = \@lines;
    return $self;
}

sub equal {
    my ( $self, $path ) = @_;

    my $equal_count = 0;

    my $self_sorted = join( ',', sort { $a cmp $b } map { sprintf( '%0.1f:%0.1f', $_->start->X, $_->start->Y ) } @{ $self } );
    my $path_sorted = join( ',', sort { $a cmp $b } map { sprintf( '%0.1f:%0.1f', $_->start->X, $_->start->Y ) } @{ $path } );

    return ( $self_sorted eq $path_sorted ) ? 1 : 0;
}

sub union {
    my ( $self, $path ) = @_;

    my $self_gpc = _path_2_mgp( $self )->convert2gpc;
    my $path_gpc = _path_2_mgp( $path )->convert2gpc;

    my $union_gpc = GpcClip( 'UNION', $self_gpc, $path_gpc );

    my @contours = Gpc2Polygons( $union_gpc );
    if ( scalar( @contours ) > 1 ) {
        die "can not deal with multiple contour output";
    }

    my $polygons = $contours[0]->polygons;
    if ( scalar( @{ $polygons } ) > 1 ) {
        die "can not deal with multiple polygon output";
    }

    return _mgp_2_path( $polygons->[0] );
}

sub _mgp_2_path {
    my ( $points ) = @_;

    my @lines;
    my $last_point;
    my $first_point;
    POINT: for my $point ( @{ $points } ) {
        if ( !defined $last_point ) {
            $last_point = $point;
            $first_point = $point;
            next POINT;
        }
        my $start = ACME::Geo::Point->new( $last_point->[0], $last_point->[1] );
        my $end = ACME::Geo::Point->new( $point->[0], $point->[1] );
        my $line = ACME::Geo::Line->new( $start, $end );
        push @lines, $line;
        $last_point = $point;
    }
    my $start = ACME::Geo::Point->new( $last_point->[0], $last_point->[1] );
    my $end = ACME::Geo::Point->new( $first_point->[0], $first_point->[1] );
    my $line = ACME::Geo::Line->new( $start, $end );
    push @lines, $line;

    return ACME::Geo::Path->new( @lines );
}

sub _path_2_mgp {
    my ( $path ) = @_;

    my $mgp = Math::Geometry::Planar->new;
    my $points = [];
    for my $line ( @{ $path } ) {
        my $start = $line->start;
        push @{ $points }, [ $start->X, $start->Y ];
    }
    $mgp->points( $points );

    return $mgp;
}

sub bounding_box {
    my ( $self ) = @_;
    return ACME::Geo::BoundingBox->new_from_lines( @{ $self } );
}

1;
