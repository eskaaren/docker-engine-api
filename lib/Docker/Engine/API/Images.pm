package Docker::Engine::API::Images;
use v5.24;
use lib '../../../../lib';
use Docker::Engine::API::HTTP;
use Archive::Tar::File;
use MIME::Base64;
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
        endpoint => '/images/json',
        params   => {
          all     => $opts->{all}     // undef,
          digests => $opts->{digests} // undef,
          filter  => $opts->{filter}  // undef,
          filters => $self->{http}->undef_stripper_to_json(
            {
              dangling => defined($opts->{filters}->{dangling}) ? ["$opts->{filters}->{dangling}"] : undef,
              label    => defined($opts->{filters}->{label})    ? ["$opts->{filters}->{label}"]    : undef,
              before   => defined($opts->{filters}->{before})   ? ["$opts->{filters}->{before}"]   : undef,
              since    => defined($opts->{filters}->{since})    ? ["$opts->{filters}->{since}"]    : undef
            }
          ) // undef
        }
      }
    )
  );
}

sub build {
  my ($self, $tarfile, $opts) = @_;
  my $tar = Archive::Tar::File->new(file => $tarfile);

  return $self->{http}->post(
    $self->{http}->url_builder(
      {
        endpoint => '/build',
        params   => {
          dockerfile          => $opts->{dockerfile}          // undef,
          t                   => $opts->{t}                   // undef,
          remote              => $opts->{remote}              // undef,
          q                   => $opts->{q}                   // undef,
          nocache             => $opts->{nocache}             // undef,
          pull                => $opts->{pull}                // undef,
          rm                  => $opts->{rm}                  // undef,
          forcerm             => $opts->{forcerm}             // undef,
          memory              => $opts->{memory}              // undef,
          memswap             => $opts->{memswap}             // undef,
          cpushares           => $opts->{cpushares}           // undef,
          cpusetcpus          => $opts->{cpusetcpus}          // undef,
          cpuperiod           => $opts->{cpuperiod}           // undef,
          cpuquota            => $opts->{cpuquota}            // undef,
          buildargs           => $opts->{buildargs}           // undef,
          shmsize             => $opts->{shmsize}             // undef,
          labels              => encode_json($opts->{labels}) // undef,
          'Content-type'      => $opts->{'Content-type'}      // undef,
          'X-Registry-Config' => $opts->{'X-Registry-Config'} // undef
        }
      }
    ),
    {
      headers => {'Content-Type' => 'application/x-tar'},
      content => $tar->get_content()
    }
  );
}

sub create {
  my ($self, $opts) = @_;

  return $self->{http}->post(
    $self->{http}->url_builder(
      {
        endpoint => '/images/create',
        params   => {
          fromImage => $opts->{fromImage} // undef,
          fromSrc   => $opts->{fromSrc}   // undef,
          repo      => $opts->{repo}      // undef,
          tag       => $opts->{tag}       // undef,
        }
      }
    ),
    {
      headers => {
        'X-Registry-Auth' => $opts->{'X-Registry-Auth'}
      }
    }
  );
}

sub inspect {
  my ($self, $opts) = @_;

  return $self->{http}->get(
    $self->{http}->url_builder(
      {
        endpoint => "/images/$opts->{name}/json"
      }
    )
  );
}

sub history {
  my ($self, $opts) = @_;

  return $self->{http}->get(
    $self->{http}->url_builder(
      {
        endpoint => "/images/$opts->{name}/history"
      }
    )
  );
}

sub push {
  my ($self, $opts) = @_;

  return $self->{http}->post(
    $self->{http}->url_builder(
      {
        endpoint => "/images/$opts->{name}/push",
        params   => {
          tag => $opts->{tag} // undef
        }
      }
    ),
    {
      headers => {
        'X-Registry-Auth' => $opts->{'X-Registry-Auth'}
      }
    }
  );
}

sub tag {
  my ($self, $opts) = @_;

  return $self->{http}->post(
    $self->{http}->url_builder(
      {
        endpoint => "/images/$opts->{name}/tag",
        params   => {
          repo => $opts->{repo} // undef,
          tag  => $opts->{tag}  // undef
        }
      }
    )
  );
}

sub remove {
  my ($self, $opts) = @_;

  return $self->{http}->delete(
    $self->{http}->url_builder(
      {
        endpoint => "/images/$opts->{name}",
        params   => {
          force   => $opts->{force}   // undef,
          noprune => $opts->{noprune} // undef
        }
      }
    )
  );
}

sub search {
  my ($self, $opts) = @_;

  return $self->{http}->get(
    $self->{http}->url_builder(
      {
        endpoint => '/images/search',
        params   => {
          term  => $opts->{term}  // undef,
          limit => $opts->{limit} // undef,
          filters => $self->{http}->undef_stripper_to_json(
            {
              stars => defined($opts->{filters}->{stars}) ? ["$opts->{filters}->{stars}"] : undef,
              'is-automated' => defined($opts->{filters}->{'is-automated'}) ? ["$opts->{filters}->{'is-automated'}"] : undef,
              'is-official' => defined($opts->{filters}->{'is-official'}) ? ["$opts->{filters}->{'is-official'}"] : undef,
            }
          ) // undef
        }
      }
    )
  );
}

1;
