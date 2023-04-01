{ pkgs, age, ... }: {
  age.secrets."minio.env".file = ./secrets/minio.env.age;

  networking.firewall.allowedTCPPorts = [ 9001 9002 ];

  services.minio = {
    enable = true;
    listenAddress = ":9001";
    consoleAddress = ":9002";
    region = "germany-frankfurt-1";
    rootCredentialsFile = "/run/agenix/minio.env";
  };
}
