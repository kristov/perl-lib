package HTTP::SSPA;

use Moose;
use Plack::Request;
use Plack::Response;
use JSON;
use Template;
use HTTP::Tool;
use Moose::Util::TypeConstraints;

subtype 'SiteObject'
    => as 'Object'
    => where { $_->can( 'dispatch' ) }
    => message { 'The site object needs a dispatch() method: see the manual' };

has req => (
    is  => 'rw',
    isa => 'Plack::Request',
);

has site => (
    is  => 'rw',
    isa => 'SiteObject',
    required => 1,
);

has params => (
    is  => 'rw',
    isa => 'HashRef',
    default => sub { {} },
);

has template => (
    is  => 'rw',
    isa => 'Maybe[Str]',
);

has app_root => (
    is  => 'rw',
    isa => 'Str',
    required => 1,
);

has tool => (
    is => 'ro',
    isa => 'HTTP::Tool',
    lazy => 1,
    builder => '_build_tool',
);

sub _build_tool {
    my ( $self ) = @_;
    return HTTP::Tool->new( { directory_root => $self->app_root } );
}

has theme => (
    is  => 'rw',
    isa => 'Str',
    required => 0,
    default => 'Cyborg',
);

my $HANDLER_STATIC = sub {
    my ( $self ) = @_;
    my $file = $self->req->path;
    my $app_root = $self->app_root;
    if ( -e "$app_root/public$file" ) {
        return $self->tool->slurp( "$app_root/public/$file" );
    }
    return;
};

my $HANDLER_404 = sub {
    my ( $self ) = @_;
    return;
};

sub process {
    my ( $self, $env ) = @_;

    my $req = Plack::Request->new( $env );
    my $res = Plack::Response->new( 404 );

    $self->req( $req );

    my $params = $req->parameters->mixed;
    $self->params( $params );

    my %DISPATCH = $self->site->dispatch;

    if ( $DISPATCH{BEFORE} ) {
        $DISPATCH{BEFORE}->( $self );
    }

    my $path   = $req->path;
    my $method = $req->method;

    my $handler_group;
    my $handler;

    if ( $DISPATCH{$method} ) {
        $handler_group = $DISPATCH{$method};
    }
    elsif ( $DISPATCH{ANY} ) {
        $handler_group = $DISPATCH{ANY};
    }
    elsif ( exists $DISPATCH{404} ) {
        $handler_group = $DISPATCH{404};
        die "here";
    }
    else {
        $handler_group = $HANDLER_STATIC;
    }

    if ( ref $handler_group eq 'CODE' ) {
        $handler = $handler_group;
    }
    else {
        if ( $handler_group->{$path} ) {
            $handler = $handler_group->{$path};
        }
        elsif ( $handler_group->{'*'} ) {
            $handler = $handler_group->{'*'};
        }
        else {
            $handler = $HANDLER_STATIC;
        }
    }

    my $response = $handler->( $self );

    if ( $self->template ) {
        $response = $self->_template( $self );
        $self->template( undef );
    }
    elsif ( $response && ref $response ) {
        $response = JSON::encode_json( $response );
    }

    if ( $response ) {
        $res->status( 200 );
        $res->body( $response );
    }
    else {
        $res->status( 404 );
        $res->body( $response );
    }

    $res->finalize;
}

sub _template {
    my ( $self ) = @_;

    my $layout = 'main';
    my $template_path = $self->app_root . '/views';

    my $vars = $self->params;
    my $template = $self->template;

    $template = "$template.tt" if $template !~ /\.tt$/;

    my $output = $self->tool->render_template( "$template_path/$template", $vars );

    if ( -e "$template_path/layouts/$layout.tt" ) {
        my $wrapper = "";
        $output = $self->tool->render_template( "layouts/$layout.tt", { %{ $vars }, content => $output } );
    }

    return $output;
}

sub render {
    my ( $self, $template, $data ) = @_;
    return $self->tool->render_template( $template, $data );
}

sub set_theme {
    my ( $self, $theme ) = @_;
    $self->theme( $theme );
}

sub add_lib {
    my ( $self, @libs ) = @_;
}

sub libs {
    my ( $self ) = @_;

    my $manifest = $self->tool->static->static_manifest;
    my $libs = $manifest->{libs};

    my @js;
    my @css;

    push @js, "/static/libs/$_" for @{ $libs->{jquery}->{'2.1.4'}->{js} };
    push @js, "/static/libs/$_" for @{ $libs->{bootstrap}->{'3.3.5'}->{js} };
    #push @css, "/static/libs/$_" for @{ $libs->{bootstrap}->{'3.3.5'}->{css} };
    my $theme = $self->theme;
    push @css, "/static/libs/BootstrapThemes/$theme/bootstrap.css";

    return {
        js  => \@js,
        css => \@css,
    };
}

1;
