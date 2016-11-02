package ACME::Geo::Path;

use strict;
use warnings;

sub new {
    my ( $class, @lines ) = @_;
    my $self = [ @lines ];
    bless( $self, $class );
    return $self;
}

sub first_line { return $_[0]->[0] }
sub last_line { return $_[0]->[-1] }

sub closed {
    my ( $self ) = @_;
    return $self->first_line->start->equal( $self->last_line->end ) ? 1 : 0;
}

sub parallel_path {
    my ( $self, $normal ) = @_;

    my @parallels;
    my $prev_parallel;
    my $first_line;
    my $prev_line;
    my $first_parallel;

    for my $line ( @{ $self } ) {

        my $parallel = $line->parallel( 1, $normal );

        if ( $prev_parallel ) {
            my ( $point ) = $prev_parallel->intersect_imaginary_line( $parallel );
            if ( $point ) {
                $prev_parallel->move_end( $point );
                $parallel->move_start( $point );
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

1;
