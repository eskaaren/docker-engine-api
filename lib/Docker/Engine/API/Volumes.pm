package Docker::Engine::API::Volumes;
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
        endpoint => '/volumes',
        params   => {
          filters => $self->{http}->undef_stripper_to_json(
            {
              name     => $opts->{filters}->{name}     // undef,
              dangling => $opts->{filters}->{dangling} // undef,
              driver   => $opts->{filters}->{driver}   // undef
            }
          ) // undef
        }
      }
    )
  );
}

sub create {
  my ($self, $opts) = @_;

  return $self->{http}->post(
    $self->{http}->url_builder(
      {
        endpoint => '/volumes/create'
      }
    ),
    {
      headers => {'Content-Type' => 'application/json'},
      content => $self->{http}->undef_stripper_to_json(
        {
          Name       => $opts->{Name}       // undef,
          Driver     => $opts->{Driver}     // undef,
          DriverOpts => $opts->{DriverOpts} // undef,
          Labels     => $opts->{Labels}     // undef
        }
      )
    }
  );
}

sub inspect {
  my ($self, $opts) = @_;

  return $self->{http}->get(
    $self->{http}->url_builder(
      {
        endpoint => "/volumes/$opts->{name}"
      }
    )
  );
}

sub remove {
  my ($self, $opts) = @_;

  return $self->{http}->delete(
    $self->{http}->url_builder(
      {
        endpoint => "/volumes/$opts->{name}"
      }
    )
  );
}

1;
