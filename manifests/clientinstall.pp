# Definition: ipa::clientinstall
#
# Installs an IPA client
define ipa::clientinstall (
  $host         = $name,
  $masterfqdn   = {},
  $domain       = {},
  $realm        = {},
  $adminpw      = {},
  $otp          = {},
  $mkhomedir    = {},
  $ntp          = {},
  $fixedprimary = false
) {

  Exec["client-install-${host}"] ~> Ipa::Flushcache["client-${host}"]

  $mkhomediropt = $mkhomedir ? {
    true    => '--mkhomedir',
    default => undef
  }

  $ntpopt = $ntp ? {
    true    => undef,
    default => '--no-ntp'
  }

  $fixedprimaryopt = $fixedprimary ? {
    true    => '--fixed-primary',
    default => undef
  }

  $extravars = "${mkhomediropt} ${ntpopt} ${fixedprimaryopt}"

  $clientinstallcmd = shellquote('/usr/sbin/ipa-client-install',"--server=${masterfqdn}","--hostname=${host}","--domain=${domain}","--realm=${realm}","--password=${otp}")
  $dc = prefix([regsubst($domain,'(\.)',',dc=','G')],'dc=')
  $searchostldapcmd = shellquote('/usr/bin/k5start','-u',"host/${host}",'-f','/etc/krb5.keytab','--','/usr/bin/ldapsearch','-Y','GSSAPI','-H',"ldap://${masterfqdn}",'-b',$dc,"fqdn=${host}")

  exec { "client-install-${host}":
    command   => "/bin/echo | ${clientinstallcmd} ${extravars} --unattended",
    unless    => "${searchostldapcmd} | /bin/grep ^krbLastPwdChange",
    timeout   => '0',
    tries     => '60',
    try_sleep => '90',
    returns   => ['0','1'],
    logoutput => 'on_failure'
  }

  ipa::flushcache { "client-${host}":
  }
}
