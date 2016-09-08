package Docker::Engine::API;
use v5.24;
use lib '../../../lib';
use Docker::Engine::API::Containers;
use Docker::Engine::API::Images;
use Docker::Engine::API::Misc;
use Docker::Engine::API::Volumes;
use Docker::Engine::API::Networks;
use Docker::Engine::API::Nodes;
use Docker::Engine::API::Swarm;
use Docker::Engine::API::Services;
use Docker::Engine::API::Tasks;
use Env;
use feature qw/postderef/;
use strict;
use warnings FATAL => 'all';

our $VERSION = '1.24';

sub new {
  my ($class, $opts) = @_;

  my $cert_path = $ENV{DOCKER_CERT_PATH};

  my $self = {
    host       => $opts->{base_url}   || $ENV{DOCKER_HOST},
    tls_verify => $opts->{tls_verify} || $ENV{DOCKER_TLS_VERIFY},
    ca_file    => $opts->{ca_file}    || $cert_path ? "$cert_path/ca.pem" : undef,
    cert_file  => $opts->{cert_file}  || $cert_path ? "$cert_path/cert.pem" : undef,
    key_file   => $opts->{key_file}   || $cert_path ? "$cert_path/key.pem" : undef,
    containers => Docker::Engine::API::Containers->new({base_url => $opts->{base_url}}),
    images     => Docker::Engine::API::Images->new({base_url     => $opts->{base_url}}),
    misc       => Docker::Engine::API::Misc->new({base_url       => $opts->{base_url}}),
    volumes    => Docker::Engine::API::Volumes->new({base_url    => $opts->{base_url}}),
    networks   => Docker::Engine::API::Networks->new({base_url   => $opts->{base_url}}),
    nodes      => Docker::Engine::API::Nodes->new({base_url      => $opts->{base_url}}),
    swarm      => Docker::Engine::API::Swarm->new({base_url      => $opts->{base_url}}),
    services   => Docker::Engine::API::Services->new({base_url   => $opts->{base_url}}),
    tasks      => Docker::Engine::API::Tasks->new({base_url      => $opts->{base_url}})
  };

  return bless $self, $class;
}

1;
