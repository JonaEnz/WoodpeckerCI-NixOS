{ pkgs, config, lib, ... }:
{
  networking.firewall.allowedTCPPorts = [ 9001 ];

  services.prometheus = {
    enable = true;
    port = 9001;

    exporters = {
      node = {
        enable = true;
        enabledCollectors = [ "systemd" ];
        port = 9102;
      };
    };

    scrapeConfigs = [
      {
        job_name = "${config.networking.hostName}";
        static_configs = [{
          targets =
            [
              "localhost:${toString config.services.prometheus.exporters.node.port}"
            ];
        }];
      }
    ];
  };
}
