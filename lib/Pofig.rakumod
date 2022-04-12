# Pofig.rakumod
#
# Pofig - Portable system Figure out
#
# Copyright (c) 2022, Oleksii Cherniavskyi
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

unit module Pofig;

use POSIX:from<Perl5>;

my $distro_version;
my $config_os;
my $config_os_version;
my $config_os_vmajor;
my $config_os_vminor;
my $config_kernel_version;
my $config_kernel_vmajor;
my $config_kernel_vminor;
my $config_kernel_vrevision;
my $config_distro;
my $config_distro_version;
my $config_distro_vmajor;
my $config_distro_vminor;
my $config_arch;

my $devnull = $*SPEC.devnull;

my $have_lsb_release = (run 'lsb_release', :out($devnull), :err($devnull)).so ?? True !! False;

my ($sysname, $nodename, $release, $version, $machine) = uname;

($config_os_vmajor, $config_os_vminor) = split ".", $release;

given $sysname {
  when m:i/netbsd/ {
    $config_os = "netbsd";
  }
  when m:i/openbsd/ {
    $config_os = "openbsd";
  }
  when m:i/sunos/ {
    $config_os = "solaris";
    $config_os_vmajor = $config_os_vminor = "";
    if $release ~~ m/^5\./ {
      $config_os_vmajor = (split ".", $release)[1];
    }
  }
  when m:i/aix/ {
    $config_os = "aix";
    $config_os_vmajor = $version ~~ m/^\d+/ ?? $version !! "";
    $config_os_vminor = $release ~~ m/^\d+/ ?? $release !! "";
  }
  when m:i/"hp-ux"/ {
    $config_os = "hpux";
    ($config_os_vmajor, $config_os_vminor) = ($release ~~ m/(\d+)\.(\d+)/)[0..1];
  }
  when m:i/freebsd/ {
    $config_os = "freebsd";
  }
  when m:i/darwin/ {
    $config_os = "";

    if run 'sw_vers', :out($devnull), :err($devnull) {
      my $prod_name = qqx{sw_vers -productName 2>$devnull};
      $prod_name ~~ s:g/ \s //;
      $config_os = "macos" if $prod_name ~~ /macos/;

      my $prod_version = qqx{sw_vers -productVersion 2>$devnull};
      ($config_os_vmajor, $config_os_vminor) = split ".", $prod_version;
    }
  }
  when m:i/cygwin/ {
    $config_os = "cygwin";
  }
  when m:i/minix/ {
    $config_os = "minix";
  }
  when m:i/^gnu$/ {
    $config_os = "gnuhurd";
    ($config_kernel_vmajor, $config_kernel_vminor) = ($release ~~ m/(\d+)\.(\d+)/)[0..1];
    $config_os_vmajor = $config_os_vminor = "";
  }
  when m:i/linux/ {
    $config_os = "gnulinux";
    ($config_kernel_vmajor, $config_kernel_vminor, $config_kernel_vrevision) = split ".", $release;
    $config_kernel_vrevision ~~ s/^(\d*).*/$0/;
    $config_os_vmajor = $config_os_vminor = "";
  }
  when m:i/^procnto || ^qnx/ {
    $config_os = "qnx";
  }
  when m:i/dragonfly/ {
    $config_os = "dragonfly";
  }
}

given $*KERNEL.hardware {
  when m:i/^x86_64 || ^8664 || ^amd64 || ^authenticamd || ^genuineintel || ^em64t/ {
    $config_arch = "x86_64";
  }
  when m:i/aarch64/ {
    $config_arch = "arm64";
  }
  when m:i/alpha/ {
    $config_arch = "alpha";
  }
  when m:i/arm/ {
    $config_arch = "arm";
  }
  when m:i/^i.?86 || ^x86/ {
    $config_arch = "x86";
  }
  when m:i/ia64/ {
    $config_arch = "ia64";
  }
  when m:i/^macppc || ^ppc || ^powerpc/ {
    $config_arch = "powerpc";
  }
  when m:i/^mips64/ {
    $config_arch = "mips64";
  }
  when m:i/mips/ {
    $config_arch = "mips";
  }
  when m:i/^sparc64/ {
    $config_arch = "sparc64";
  }
  when m:i/^sparc/ {
    $config_arch = "sparc";
  }
}

if ! $config_arch {
  given $machine {
    when m:i/^x86_64 || ^8664 || ^amd64 || ^authenticamd || ^genuineintel || ^em64t/ {
      $config_arch = "x86_64";
    }
    when m:i/aarch64/ {
      $config_arch = "arm64";
    }
    when m:i/alpha/ {
      $config_arch = "alpha";
    }
    when m:i/arm/ {
      $config_arch = "arm";
    }
    when m:i/^i.?86 || ^x86/ {
      $config_arch = "x86";
    }
    when m:i/ia64/ {
      $config_arch = "ia64";
    }
    when m:i/^macppc || ^ppc || ^powerpc/ {
      $config_arch = "powerpc";
    }
    when m:i/^mips64/ {
      $config_arch = "mips64";
    }
    when m:i/mips/ {
      $config_arch = "mips";
    }
    when m:i/^sparc64/ {
      $config_arch = "sparc64";
    }
    when m:i/^sparc/ {
      $config_arch = "sparc";
    }
  }
}

if ! $config_arch {
  my $uname_p = qqx{uname -p 2>$devnull};
  given $uname_p {
    when m:i/^alpha/ {
      $config_arch = "alpha";
    }
    when m:i/^x86_64 || ^amd64/ {
      $config_arch = "x86_64";
    }
    when m:i/arm/ {
      $config_arch = "arm";
    }
    when m:i/^i.?86 || ^x86/ {
      $config_arch = "x86";
    }
    when m:i/mips/ {
      $config_arch = "mips";
    }
    when m:i/^powerpc/ {
      $config_arch = "powerpc";
    }
    when m:i/^sparc64/ {
      $config_arch = "sparc64";
    }
    when m:i/^sparc/ {
      $config_arch = "sparc";
    }
  }
}

if $have_lsb_release {
  my $lsb_id = qqx{lsb_release -id 2>$devnull};
  given $lsb_id {
    when m:i/fedora/ {
      $config_distro = "fedora";
    }
    when m:i/red \s* hat/ {
      $config_distro = "redhat";
    }
    when m:i/centos/ {
      $config_distro = "centos";
    }
    when m:i/devuan/ {
      $config_distro = "devuan";
    }
    when m:i/opensuse/ {
      $config_distro = "opensuse";
    }
    when m:i/suse.*enterprise/ {
      $config_distro = "suse";
    }
    when m:i/ubuntu/ {
      $config_distro = "ubuntu";
    }
    when m:i/debian/ {
      $config_distro = "debian";
    }
    when m:i/linux \s* mint/ {
      $config_distro = "mint";
    }
  }

  $distro_version = qqx{lsb_release -r 2>$devnull}.subst( /^Release.*? (\d+) .*/, { $0 });
} elsif ("/etc/os-release".IO andthen .f && .r) {
  my $data = slurp "/etc/os-release";

  given $data {
    when m:i/pidora/ {
      $config_distro = "pidora";
    }
    when m:i/fedora/ {
      $config_distro = "fedora";
    }
    when m:i/red \s* hat/ {
      $config_distro = "redhat";
    }
    when m:i/centos/ {
      $config_distro = "centos";
    }
    when m:i/devuan/ {
      $config_distro = "devuan";
    }
    when m:i/gentoo/ {
      $config_distro = "gentoo";
    }
    when m:i/arch \s linux/ {
      $config_distro = "arch";
    }
    when m:i/opensuse/ {
      $config_distro = "opensuse";
    }
    when m:i/suse .* enterprise/ {
      $config_distro = "suse";
    }
    when m:i/ubuntu/ {
      $config_distro = "ubuntu";
    }
    when m:i/slackware/ {
      $config_distro = "slackware";
    }
    when m:i/debian/ {
      $config_distro = "debian";
    }
    when m:i/linux \s* mint/ {
      $config_distro = "mint";
    }
  }

  $distro_version = $data ~~ /VERSION_ID .*? (\d+)/ ?? $0 !! "";
} elsif ("/etc/issue".IO andthen .f && .r) {
  my $data = slurp "/etc/issue";

  given $data {
    when m:i/devuan/ {
      $config_distro = "devuan";
      $distro_version = $data ~~ m:i/(\d+)/ ?? $0 !! "";
    }
    when m:i/arch \s linux/ {
      $config_distro = "arch";
    }
    when m:i/pidora/ {
      $config_distro = "pidora";
      $distro_version = $data ~~ m:i/pidora.*?(\d+)\D*(\d*)/ ?? "$0.$1" !! "";
    }
    when m:i/fedora/ {
      $config_distro = "fedora";
      $distro_version = $data ~~ m:i/fedora.*?(\d+)\D*(\d*)/ ?? "$0.$1" !! "";
    }
    when m:i/red \s* hat/ {
      $config_distro = "redhat";
      $distro_version = $data ~~ m:i/red \s* hat.*?(\d+)\D*(\d*)/ ?? "$0.$1" !! "";
    }
    when m:i/centos/ {
      $config_distro = "centos";
      $distro_version = $data ~~ m:i/centos.*?(\d+)\D*(\d*)/ ?? "$0.$1" !! "";
    }
    when m:i/opensuse/ {
      $config_distro = "opensuse";
      $distro_version = $data ~~ m:i/opensuse.*?(\d+)\D*(\d*)/ ?? "$0.$1" !! "";
    }
    when m:i/suse \s* linux \s* enterprise/ {
      $config_distro = "suse";
      $distro_version = $data ~~ m:i/suse \s* linux.*?(\d+)\D*(\d*)/ ?? "$0.$1" !! "";
    }
    when m:i/ubuntu/ {
      $config_distro = "ubuntu";
      $distro_version = $data ~~ m:i/(\d+)/ ?? $0 !! "";
    }
    when m:i/debian/ {
      $config_distro = "debian";
      $distro_version = $data ~~ m:i/(\d+)/ ?? $0 !! "";
    }
    when m:i/linux \s* mint/ {
      $config_distro = "mint";
      $distro_version = $data ~~ m:i/linux \s* mint.*?(\d+)/ ?? $0 !! "";
    }
  }
}


if ! $config_distro {
  if "/etc/debian_version".IO.f {
    $config_distro = "debian";
  } elsif "/etc/devuan_version".IO.f {
    $config_distro = "devuan";
  } elsif "/etc/pidora-release".IO.f {
    $config_distro = "pidora";
    if "/etc/pidora-release".IO.r {
      my $data = slurp "/etc/pidora-release";
      $distro_version = $data ~~ m:i/pidora.*?(\d+)\D*(\d*)/ ?? "$0.$1" !! "";
    }
  } elsif "/etc/fedora-release".IO.f {
    $config_distro = "fedora";
    if "/etc/fedora-release".IO.r {
      my $data = slurp "/etc/fedora-release";
      $distro_version = $data ~~ m:i/fedora.*?(\d+)\D*(\d*)/ ?? "$0.$1" !! "";
    }
  } elsif "/etc/redhat-release".IO.f {
    $config_distro = "redhat";
    if "/etc/redhat-release".IO.r {
      my $data = slurp "/etc/redhat-release";
      my $dist_pat = rx/red \s* hat/;
      if $data ~~ m:i/centos/ {
        $config_distro = "centos";
        $dist_pat = rx/centos/;
      }
      $distro_version = $data ~~ m:i/$dist_pat.*?(\d+)\D*(\d*)/ ?? "$0.$1" !! "";
    }
  } elsif "/etc/slackware-version".IO.f {
    $config_distro = "slackware";
    if "/etc/slackware-version".IO.r {
      my $data = slurp "/etc/slackware-version";
      $distro_version = $data ~~ m:i/.*?(\d+)\.?\d*/ ?? $0 !! "";
    }
  } elsif "/etc/gentoo-release".IO.f {
    $config_distro = "gentoo";
  } elsif "/etc/arch-release".IO.f {
    $config_distro = "arch";
  } elsif "/etc/SuSE-release".IO.r {
    my $data = slurp "/etc/SuSE-release";
    if $data ~~ m:i/opensuse/ {
      $config_distro = "opensuse";
    } else {
      $config_distro = "suse";
    }
    my ($distro_major, $distro_minor) = ($data ~~
                                          m:i/
                                              version .*?
                                              (\d+)
                                              .* patchlevel .*?
                                              (\d+)
                                          /
                                        )[0..1];
    $distro_version = "$distro_major.$distro_minor";
  }
}

if $config_distro eq "debian" and ! $distro_version and ( "/etc/debian_version".IO andthen .f and .r) {
  my $data = slurp "/etc/debian_version";
  $distro_version = $data ~~ m/(\d+)/ ?? $0 !! "";
}

if $distro_version {
  $config_distro_vmajor = $distro_version ~~ m/(\d+)/ ?? $0 !! "";
  $config_distro_vminor = $distro_version ~~ m/\d+ \. (\d+)/ ?? $0 !! "";
}

$config_os_version = $config_os_vmajor ?? $config_os_vmajor ~ ($config_os_vminor ?? "." ~ $config_os_vminor !! "") !! "";
$config_distro_version = $config_distro_vmajor ?? $config_distro_vmajor ~ ($config_distro_vminor ?? "." ~ $config_distro_vminor !! "") !! "";
$config_kernel_version = $config_kernel_vmajor ??
                            $config_kernel_vmajor ~ ($config_kernel_vminor ??
                                "." ~ $config_kernel_vminor ~ ($config_kernel_vrevision ??
                                    "." ~ $config_kernel_vrevision
                                !! "")
                            !! "")
                         !! "";

my $all_props = q:to/HDOC/;
OPERATING SYSTEMS
------------------------------------------------------
aix               IBM AIX
cygwin            Cygwin
dragonfly         DragonFly BSD
freebsd           FreeBSD
gnuhurd           GNU/Hurd
gnulinux          GNU/Linux
hpux              HP-UX
macos             Apple macOS
minix             MINIX
netbsd            NetBSD
openbsd           OpenBSD
qnx               QNX
solaris           Solaris

DISTRIBUTIONS
------------------------------------------------------
arch              Arch
centos            CentOS
debian            Debian
devuan            Devuan
fedora            Fedora
gentoo            Gentoo
mint              Linux Mint
opensuse          OpenSUSE
pidora            Pidora
redhat            Red Hat
slackware         Slackware
suse              Suse Linux Enterprise
ubuntu            Ubuntu

ARCHITECTURES
------------------------------------------------------
alpha             Alpha
arm               ARM (Advanced RISC Machine)
arm64             ARM 64-bit (ARMv8, AArch64 or ARM64)
ia64              IA-64
mips              MIPS
mips64            MIPS64
powerpc           PowerPC
sparc             SPARC
sparc64           SPARC64
x86               x86
x86_64            x86-64 (AMD64)
HDOC

sub help-props is export { $all_props }
sub os-name is export { $config_os || "undefined" }
sub os-version is export { $config_os_version || "undefined" }
sub os-vmajor is export { $config_os_vmajor || "undefined" }
sub os-vminor is export { $config_os_vminor || "undefined" }
sub kernel-version is export { $config_kernel_version || "undefined" }
sub kernel-vmajor is export { $config_kernel_vmajor || "undefined" }
sub kernel-vminor is export { $config_kernel_vminor || "undefined" }
sub kernel-vrevision is export { $config_kernel_vrevision || "undefined" }
sub distro-name is export { $config_distro || "undefined" }
sub distro-version is export { $config_distro_version || "undefined" }
sub distro-vmajor is export { $config_distro_vmajor || "undefined" }
sub distro-vminor is export { $config_distro_vminor || "undefined" }
sub arch-name is export { $config_arch || "undefined" }
