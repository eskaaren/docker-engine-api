package Docker::Engine::API::Nodes;
use v5.24;
use lib '../../../../lib';
use Docker::Engine::API::HTTP;
use JSON::PP;
use strict;
use warnings;

sub new {
  my ($class, $self) = @_;
  $self->{http} = Docker::Engine::API::HTTP->new($self->{base_url});
  return bless $self, $class;
}

sub list {
  my ($self, $opts) = @_;

  return $self->{http}->get(
    $self->{http}->url_builder(
      {
        endpoint => "/nodes",
        params   => {
          filters => $self->{http}->undef_stripper_to_json(
            {
              id         => defined($opts->{filters}->{id})         ? ["$opts->{filters}->{id}"]         : undef,
              name       => defined($opts->{filters}->{name})       ? ["$opts->{filters}->{name}"]       : undef,
              membership => defined($opts->{filters}->{membership}) ? ["$opts->{filters}->{membership}"] : undef,
              role       => defined($opts->{filters}->{role})       ? ["$opts->{filters}->{role}"]       : undef
            }
          ) // undef
        }
      }
    )
  );
}

sub inspect {
  my ($self, $opts) = @_;

  return $self->{http}->get(
    $self->{http}->url_builder(
      {
        endpoint => "/nodes/$opts->{id}"
      }
    )
  );
}

1;
