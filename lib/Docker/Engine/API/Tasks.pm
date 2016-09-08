package Docker::Engine::API::Tasks;
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
        endpoint => "/tasks",
        params   => {
          filters => $self->{http}->undef_stripper_to_json(
            {
              id      => defined($opts->{filters}->{id})      ? ["$opts->{filters}->{id}"]      : undef,
              name    => defined($opts->{filters}->{name})    ? ["$opts->{filters}->{name}"]    : undef,
              service => defined($opts->{filters}->{service}) ? ["$opts->{filters}->{service}"] : undef,
              node    => defined($opts->{filters}->{node})    ? ["$opts->{filters}->{node}"]    : undef,
              label   => defined($opts->{filters}->{label})   ? ["$opts->{filters}->{label}"]   : undef,
              'desired-state' => defined($opts->{filters}->{'desired-state'}) ? ["$opts->{filters}->{'desired-state'}"] : undef
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
        endpoint => "/tasks/$opts->{id}"
      }
    )
  );
}

1;
