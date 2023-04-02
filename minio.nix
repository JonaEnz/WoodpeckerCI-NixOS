{ pkgs, age, ... }: {
  age.secrets."minio.env".file = ./secrets/minio.env.age;

  networking.firewall.allowedTCPPorts = [ 8001 8002 ];

  services.nginx = {
    enable = true;
    virtualHosts."minio.woodpecker.jonaenz.de" =
      {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          recommendedProxySettings = true;
          proxyPass = "http://127.0.0.1:8001";
          extraConfig = ''
            client_max_body_size 0;
          '';
        };
      };
  };

  services.minio = {
    enable = true;
    listenAddress = ":8001";
    consoleAddress = ":8002";
    region = "germany-frankfurt-1";
    rootCredentialsFile = "/run/agenix/minio.env";
  };
}
