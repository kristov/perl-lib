package ACME::Geo::Layer;

use strict;
use warnings;
use ACME::Geo::Path;

sub new {
    my ( $class, @paths ) = @_;
    my $self = [ @paths ];
    bless( $self, $class );
    return $self;
}

sub new_from_unsorted_lines {
    my ( $class, @lines ) = @_;

    my @paths;

    if ( @lines ) {

        my @tmp;
        for my $line ( @lines ) {
            push @tmp, [ $line ];
        }

        my $something_done = 1;

        while ( $something_done ) {

            $something_done = 0;

            my $tmp_length = scalar( @tmp );

            for ( my $idx1 = 0; $idx1 < $tmp_length; $idx1++ ) {

                next unless defined $tmp[$idx1];

                for ( my $idx2 = 0; $idx2 < $tmp_length; $idx2++ ) {

                    next if $idx1 == $idx2;
                    next unless defined $tmp[$idx2];

                    if ( $tmp[$idx1]->[0]->start->equal( $tmp[$idx2]->[-1]->end ) ) {
                        while ( my $nr2line = pop @{ $tmp[$idx2] } ) {
                            unshift @{ $tmp[$idx1] }, $nr2line;
                            $something_done = 1;
                        }
                        $tmp[$idx2] = undef;
                    }
                    elsif ( $tmp[$idx1]->[0]->start->equal( $tmp[$idx2]->[0]->start ) ) {
                        while ( my $nr2line = shift @{ $tmp[$idx2] } ) {
                            $nr2line->flip;
                            unshift @{ $tmp[$idx1] }, $nr2line;
                            $something_done = 1;
                        }
                        $tmp[$idx2] = undef;
                    }
                    elsif ( $tmp[$idx1]->[-1]->end->equal( $tmp[$idx2]->[0]->start ) ) {
                        while ( my $nr2line = shift @{ $tmp[$idx2] } ) {
                            push @{ $tmp[$idx1] }, $nr2line;
                            $something_done = 1;
                        }
                        $tmp[$idx2] = undef;
                    }
                    elsif ( $tmp[$idx1]->[-1]->end->equal( $tmp[$idx2]->[-1]->end ) ) {
                        while ( my $nr2line = pop @{ $tmp[$idx2] } ) {
                            $nr2line->flip;
                            push @{ $tmp[$idx1] }, $nr2line;
                            $something_done = 1;
                        }
                        $tmp[$idx2] = undef;
                    }
                }
            }
        }

        for my $group ( @tmp ) {
            if ( defined $group ) {
                my $path = ACME::Geo::Path->new( @{ $group } );
                push @paths, $path;
            }
        }
    }

    return $class->new( @paths );
}

sub nr_paths {
    my ( $self ) = @_;
    return scalar( @{ $self } );
}

sub bounding_box {
    my ( $self ) = @_;

    my $work_bbox;
    for my $path ( @{ $self } ) {
        my $bbox = $path->bounding_box;
        $work_bbox = $bbox->union( $work_bbox );
    }

    return $work_bbox;
}

sub translate {
    my ( $self, $byx, $byy ) = @_;

    for my $path ( @{ $self } ) {
        $path->translate( $byx, $byy );
    }
}

sub equal {
    my ( $self, $layer ) = @_;

    my $equal_path_count = 0;

    for my $path ( @{ $self } ) {
        for my $other_path ( @{ $layer } ) {
            if ( $other_path->equal( $path ) ) {
                $equal_path_count++;
            }
        }
    }

    return (
        $equal_path_count == scalar( @{ $self } ) &&
        $equal_path_count == scalar( @{ $layer } )
    ) ? 1 : 0;
}

1;
