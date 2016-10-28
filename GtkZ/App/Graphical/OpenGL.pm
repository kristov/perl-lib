package GtkZ::App::Graphical::OpenGL;

use Moose;
use GtkZ::App::Graphical;
use Glib qw( TRUE FALSE );
use Gtk2::GLExt;
use OpenGL qw/:all/;
extends 'GtkZ::App::Graphical';

before 'run' => sub {
    my ( $self ) = @_;
    Glib::Timeout->add( 30, sub { $self->render( @_ ) }, $self->da );
};

has 'gl_config' => (
    is => 'rw',
    isa => 'Gtk2::Gdk::GLExt::Config',
    builder => '_build_gl_config',
);

sub _build_gl_config {
    my ( $self ) = @_;

    Gtk2::GLExt->init;

    my $gl_config = Gtk2::Gdk::GLExt::Config->new_by_mode( [ 'rgb', 'depth', 'double' ] );
    if ( !$gl_config ) {
        $gl_config = Gtk2::Gdk::GLExt::Config->new_by_mode( [ 'rgb', 'depth' ] );
        if ( !$gl_config ) {
            die "Unable to create GLExt config";
        }
    }

    $self->da->set_gl_capability( $gl_config, undef, 1, 'rgba-type' );
    $self->da->signal_connect_after( realize => sub { $self->realize( @_ ) } );
    return $gl_config;
}

my $room;
my $room_rot = 0;
my $room_ang = 0;
my @room_pos = (0, 0, 3 * -20);
my $source;

sub realize {
    my ( $self, $widget, $data ) = @_;

    my $glcontext = $widget->get_gl_context;
    my $gldrawable = $widget->get_gl_drawable;

    # OpenGL BEGIN
    return unless( $gldrawable->gl_begin( $glcontext ) );

    my @LightAmbient = ( 0.5, 0.5, 0.5, 1.0 );
    my @LightDiffuse = ( 1.0, 1.0, 1.0, 1.0 );
    my @LightPosition = ( 0.0, 0.0, 2.0, 1.0 );

    my $alloc = $widget->allocation;
    glViewport(0, 0, $alloc->width, $alloc->height);
    glShadeModel( GL_SMOOTH );
    glClearColor( 0, 0, 0, 0 );
    glClearDepth( 1.0 );
    glEnable( GL_DEPTH_TEST );
    glDepthFunc( GL_LEQUAL ); # GL_LESS
    glHint( GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST );

    glLightfv_p( GL_LIGHT1, GL_AMBIENT, @LightAmbient );
    glLightfv_p( GL_LIGHT1, GL_DIFFUSE, @LightDiffuse );
    glLightfv_p( GL_LIGHT1, GL_POSITION, @LightPosition );
    glEnable( GL_LIGHT1 );

    #glBlendFunc( GL_SRC_ALPHA,GL_ONE );

    #glPolygonMode( GL_BACK, GL_FILL );
    #glPolygonMode( GL_FRONT, GL_LINE );

    glLoadIdentity();

    $room = glGenLists( 2 );

    my @tmp = @{ $self->corners };

    glNewList( $room, GL_COMPILE );
    glBegin( GL_QUADS );
    glColor4f( 0, 0, 0.75, 1 );
    for my $corner ( @tmp ) {
        glNormal3f( @{ $corner->{normal} } );
        for my $vertex ( @{ $corner->{verticies} } ) {
            glVertex3f( @{ $vertex } );
        }
    }
    glEnd();
    glEndList();

    $gldrawable->gl_end;
    # OpenGL END
}

sub prep_frame {
    my ( $self ) = @_;
    glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
    glEnable( GL_LIGHTING );
    glEnable( GL_COLOR_MATERIAL );
}

sub end_frame {
    my ( $self ) = @_;
}

sub set_projection_3d {
    my ( $self, $alloc ) = @_;

    glMatrixMode( GL_PROJECTION );
    glLoadIdentity();
    gluPerspective( 45.0, $alloc->width / $alloc->height, 0.1, 100.0 );

    glMatrixMode( GL_MODELVIEW );
    glLoadIdentity();
}

sub set_view_3d {
    my ( $self ) = @_;
    glTranslated( @room_pos );
    glRotated( $room_rot, 0, 1, 0 );
    glRotated( 5, 1, 0, 0 );
}

sub set_world_lights {
    my ( $self ) = @_;
    glLightfv_p( GL_LIGHT0, GL_POSITION, 0.0, 0.0, 1.0, 0.0 );
    glEnable( GL_LIGHT0 );
}

sub draw_frame {
    my ( $self, $alloc ) = @_;
    $self->set_projection_3d( $alloc );
    $self->set_view_3d;
    $self->set_world_lights;
    $self->draw_view;
}

sub draw_view {
    my ( $self ) = @_;
    glCallList( $room );
    glEnd();

}

# The main drawing function.
sub render {
    my ( $self, $widget ) = @_;

    my $glcontext = $widget->get_gl_context;
    my $gldrawable = $widget->get_gl_drawable;

    return unless $gldrawable->gl_begin( $glcontext );

    my $alloc = $widget->allocation;

    $self->prep_frame;
    $self->draw_frame( $alloc );

    $room_ang += 0.1;
    $room_rot += 0.5;

    if( $gldrawable->is_double_buffered ) {
        $gldrawable->swap_buffers;
    }
    else {
        glFlush ();
    }
    $gldrawable->gl_end;

    return TRUE;
}

sub button_clicked {}
sub motion_notify {}
sub scroll {}

__PACKAGE__->meta->make_immutable;
