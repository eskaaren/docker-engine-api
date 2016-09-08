use v5.24;
use Test::More tests => 21;
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

my $c = $d->{containers};

my $res = $c->remove(
  {
    id    => 'testcontainer',
    v     => 1,
    force => 1
  }
);

$res = $c->list(
  {
    limit => 1,
    filters => {
      status => 'running'
    }
  }
);
is($res->{status}, 200, "List containers");

$res = $c->create(
  {
    name   => 'testcontainer',
    config => {
      Cmd   => ['ping', '-c', '20', '127.0.0.1'],
      Image => 'alpine'
    }
  }
);
is($res->{status}, 201, "Create container");

my $id = decode_json($res->{content})->{Id};

$res = $c->start(
  {
    id => $id
  }
);
is($res->{status}, 204, "Start container");

$res = $c->stats(
  {
    id     => $id,
    stream => 0
  }
);
is($res->{status}, 200, "Container stats");

$res = $c->inspect(
  {
    id   => $id,
    size => 1
  }
);
is($res->{status}, 200, "Container inspect");

$res = $c->top(
  {
    id      => $id,
    ps_args => 'aux'
  }
);
is($res->{status}, 200, "Container top");

$res = $c->logs(
  {
    id         => $id,
    details    => 1,
    follow     => 0,
    stdout     => 1,
    stderr     => 1,
    since      => 0,
    timestamps => 1,
    tail       => 'all'

  }
);
is($res->{status}, 200, "Container logs");

$res = $c->kill(
  {
    id     => $id,
    signal => 'SIGKILL'
  }
);
is($res->{status}, 204, "Kill container");

$res = $c->restart(
  {
    id => $id,
    t  => 0
  }
);
is($res->{status}, 204, "Restart container");

$res = $c->update(
  {
    id     => $id,
    config => {
      CpuShares => 512
    }
  }
);
is($res->{status}, 200, "Update container");

$res = $c->rename(
  {
    id   => $id,
    name => 'renamed_testcontainer'
  }
);
is($res->{status}, 204, "$res->{content} Rename container");

$res = $c->pause(
  {
    id => $id,
  }
);
is($res->{status}, 204, "Pause container");

$res = $c->unpause(
  {
    id => $id,
  }
);
is($res->{status}, 204, "Unpause container");

open my $fh, '>', '/tmp/swarmtest/containerexport.tar';
$res = $c->export(
  {
    id => $id
  }
);
print $fh $res->{content};
close $fh;

my $export_ls = `tar -tf /tmp/swarmtest/containerexport.tar`;
like($export_ls, qr/bin/, "Container export");

$res = $c->stop(
  {
    id => $id,
    t  => 0
  }
);
is($res->{status}, 204, "Stop container");

$res = $c->remove(
  {
    id    => $id,
    v     => 1,
    force => 1
  }
);
is($res->{status}, 204, "Delete container");

my $dir = `pwd`;
chomp $dir;
$res = $c->create(
  {
    name   => 'testcontainer',
    config => {
      Cmd        => ['sleep 10'],
      Image      => 'alpine',
      HostConfig => {
        Binds => ["$dir/t/Docker/Engine/API:/tmp"]
      }
    }
  }
);
$id = decode_json($res->{content})->{Id};

$res = $c->archive(
  {
    id   => $id,
    op   => 'get',
    path => '/tmp/'
  }
);

open my $fh, '>', '/tmp/swarmtest/download_tmp.tar';
print $fh $res->{content};
close $fh;

my $download_ls = `tar -tf /tmp/swarmtest/download_tmp.tar`;
like($download_ls, qr/testdata.txt/, "Container download archive");

system('tar cvf /tmp/swarmtest/upload_tmp.tar /tmp/swarmtest > /dev/null 2>&1');
$res = $c->archive(
  {
    id                   => $id,
    op                   => 'put',
    path                 => '/root/',
    noOverwriteDirNonDir => 0,
    archive              => '/tmp/swarmtest/download_tmp.tar'
  }
);
is($res->{status}, 200, "Container upload archive");

$res = $c->archive(
  {
    id   => $id,
    op   => 'head',
    path => '/tmp/'
  }
);
is($res->{status}, 200, "Container head archive");

$res = $c->changes(
  {
    id => $id
  }
);
like($res->{content}, qr/testdata.txt/, "Container changes");

$res = $c->wait(
  {
    id => $id
  }
);
my $wait_status_code = decode_json($res->{content})->{StatusCode};
is($wait_status_code, 0, "Wait container");

END {
  $res = $c->remove(
    {
      id    => $id,
      v     => 1,
      force => 1
    }
  );
}
