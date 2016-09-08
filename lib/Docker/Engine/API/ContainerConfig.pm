package Docker::Engine::API::ContainerConfig;
use v5.24;
use strict;
use warnings;

sub new {
  my ($class) = @_;

  my $self = {
    config => {
      AttachStdin     => undef,
      AttachStdout    => undef,
      AttachStderr    => undef,
      Cmd             => [],
      Domainname      => undef,
      Entrypoint      => undef,
      Env             => undef,
      ExposedPorts    => {},
      Hostname        => "",
      Image           => "",
      Labels          => {},
      MacAddress      => undef,
      NetworkDisabled => undef,
      OnBuild         => undef,
      OpenStdin       => undef,
      StdinOnce       => undef,
      Tty             => undef,
      User            => "",
      Volumes         => undef,
      WorkingDir      => '',
      Mounts          => [],
      HostConfig      => {
        Binds            => [],
        PortBindings     => {},
        BlkioWeight      => 0,
        CapAdd           => undef,
        CapDrop          => undef,
        ContainerIDFile  => "",
        CpusetCpus       => "",
        CpusetMems       => "",
        CpuShares        => 0,
        CpuPeriod        => 100000,
        CpuQuota         => 0,
        Devices          => [],
        Dns              => undef,
        DnsSearch        => undef,
        ExtraHosts       => undef,
        IpcMode          => "",
        Links            => undef,
        LxcConf          => [],
        Memory           => 0,
        MemorySwap       => 0,
        MemorySwappiness => -1,
        OomKillDisable   => undef,
        NetworkMode      => "bridge",
        Privileged       => undef,
        ReadonlyRootfs   => undef,
        PublishAllPorts  => undef,
        RestartPolicy    => {
          MaximumRetryCount => 2,
          Name              => "on-failure"
        },
        LogConfig => {
          Config => {},
          Type   => "json-file"
        },
        SecurityOpt  => undef,
        VolumesFrom  => undef,
        Ulimits      => [],
        CgroupParent => "",
        ConsoleSize  => [0, 0],
        PidMode      => "",
        UTSMode      => "",
        GroupAdd     => undef,
      }
    }
  };

  return bless $self, $class;
}

sub override {
  my ($self, $config) = @_;

  for my $k (keys %$config) {
    $self->{config}->{$k} = $config->{$k};
  }

  return $self->{config};
}

1;
