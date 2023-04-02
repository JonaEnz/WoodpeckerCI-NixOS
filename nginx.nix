{ config, ... }:
{
  services.nginx.enable = true;
  networking.firewall.allowedTCPPorts = [ 443 80 ];

  security.acme.acceptTerms = true;
  security.acme.defaults = {
    email = "jona_enzinger@outlook.com";
  };
}
