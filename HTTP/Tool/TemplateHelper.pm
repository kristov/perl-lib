package HTTP::Tool::TemplateHelper;

use Moose;

has tool => (
    is => 'ro',
    isa => 'HTTP::Tool',
    required => 1,
);

sub img_url {
    my ( $self, $img ) = @_;
    return "https://192.168.2.2/static/images/$img";
}

sub web_url {
    my ( $self, $img ) = @_;
    my ( $file, $ext ) = $img =~ m/(.+)\.([a-z]+)$/;
    return "https://192.168.2.2/static/images/$file" . '_web.' . $ext;
}

sub thumb_url {
    my ( $self, $img ) = @_;
    my ( $file, $ext ) = $img =~ m/(.+)\.([a-z]+)$/;
    return "https://192.168.2.2/static/images/$file" . '_thumbnail.' . $ext;
}

sub add_sub {
    my ( $self, $app, $name, $sub ) = @_;
    my $fqs = __PACKAGE__ . "::$name";
    {
        no strict 'refs';
        *{ $fqs } = sub {
            $sub->( $app );
        };
    }
}

1;
