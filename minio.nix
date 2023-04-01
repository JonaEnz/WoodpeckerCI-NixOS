{ pkgs, age, ... }: {
  age.secrets."minio.env".file = ./secrets/minio.env.age;

  networking.firewall.allowedTCPPorts = [ 8001 8002 ];

  services.minio = {
    enable = true;
    listenAddress = ":8001";
    consoleAddress = ":8002";
    region = "germany-frankfurt-1";
    rootCredentialsFile = "/run/agenix/minio.env";
  };
}
