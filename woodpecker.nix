{ pkgs, config, ... }: {
  age.secrets."woodpecker-server.env".file = ./secrets/woodpecker-server.env.age;
  age.secrets."woodpecker-agent.env".file = ./secrets/woodpecker-agent.env.age;
  virtualisation.docker.enable = true;

  #boot.binfmt.emulatedSystems = [
  #  "x86_64-linux"
  #];

  environment.systemPackages = with pkgs; [
    docker-buildx
  ];

  systemd.services."docker-emulation-setup" = {
    description = "Adds emulation of x64 and others to docker";

    after = [ ];
    wants = [ "network-pre.target" ];
    wantedBy = [ "multi-user.target" "docker-woodpecker-agent-amd64.service" ];

    # set this service as a oneshot job
    serviceConfig.Type = "oneshot";

    # have the job run this shell script
    script = with pkgs; ''
      (${docker}/bin/docker buildx inspect --bootstrap | grep amd64) || {
        ${docker}/bin/docker run --privileged --rm tonistiigi/binfmt --install all 
      }
    '';
  };

  services.nginx = {
    virtualHosts."woodpecker.jonaenz.de" =
      {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          recommendedProxySettings = true;
          proxyPass = "http://127.0.0.1:8000";
        };
      };
  };

  services.woodpecker-server = {
    enable = true;
    environmentFile = "/run/agenix/woodpecker-server.env";
    # EnvironmentFile includes WOODPECKER_AGENT_SECRET and SCM config
    environment = {
      WOODPECKER_HOST = "https://woodpecker.jonaenz.de";
      WOODPECKER_OPEN = "false";
      WOODPECKER_ADMIN = "JonaEnz";
      WOODPECKER_SERVER_ADDR = ":8000";
      WOODPECKER_GRPC_ADDR = ":9000";
    };
  };
  services.woodpecker-agents = {
    agents = {
      "agent1" = {
        enable = true;
        environment = {
          WOODPECKER_SERVER = "localhost:9000";
          WOODPECKER_BACKEND = "docker";
          WOODPECKER_MAX_PROCS = "2";
        };
        environmentFile = [ "/run/agenix/woodpecker-agent.env" ];
        # EnvironmentFile includes WOODPECKER_AGENT_SECRET
        extraGroups = [ "docker" ];
      };
    };
  };

  virtualisation.oci-containers.backend = "docker";
  virtualisation.oci-containers.containers."woodpecker-agent-amd64" = {
    image = "woodpeckerci/woodpecker-agent:latest";
    cmd = [ "agent" ];
    autoStart = true;
    extraOptions = [ "--network=host" "--platform=linux/amd64" ];
    environmentFiles = [ "/run/agenix/woodpecker-agent.env" ];
    volumes = [ "/var/run/docker.sock:/var/run/docker.sock" ];
    environment = {
      WOODPECKER_HEALTHCHECK = "false";
      WOODPECKER_SERVER = "localhost:9000";
      WOODPECKER_BACKEND = "docker";
      WOODPECKER_MAX_PROCS = "2";
    };
  };

}
