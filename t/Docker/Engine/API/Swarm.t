use v5.24;
use Test::More;
use lib '../../../../lib';
use lib 'lib';
use Docker::Engine::API;
use JSON::PP;
use Env;

unless (-d '/tmp/swarmtest') {
  mkdir '/tmp/swarmtest';
}

my $d = Docker::Engine::API->new(
  {
    base_url => $ENV{'prove_url'} // 'http://127.0.0.1:3375'
  }
);

my $s = $d->{swarm};

my $res = $s->init(
  {
    ListenAddr      => '127.0.0.1',
    ForceNewCluster => JSON::PP->true()
  }
);
is($res->{status}, 200, "Init swarm");

$res = $s->join(
  {
    ListenAddr   => '127.0.0.1',
    RemoteAddres => (127.0.0.1)
  }
);
is($res->{status}, 406, "Join swarm");

$res = $s->inspect();
my $version = decode_json($res->{content})->{Version}->{Index};

$res = $s->update(
  {
    version => $version,
    Raft    => {
      HeartbeatTick => 55
    },
    CAConfig => {
      NodeCertExpiry => 7776000000000000
    }
  }
);
is($res->{status}, 200, "$res->{content} Update swarm");

$res = $s->leave();
is($res->{status}, 200, "$res->{content} Leave swarm");

done_testing();
