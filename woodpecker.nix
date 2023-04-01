{ pkgs, config, ... }: {
  age.secrets."woodpecker-server.env".file = ./secrets/woodpecker-server.env.age;
  age.secrets."woodpecker-agent.env".file = ./secrets/woodpecker-agent.env.age;
  virtualisation.docker.enable = true;

  networking.firewall.allowedTCPPorts = [ 443 80 ];

  security.acme.acceptTerms = true;
  security.acme.certs = {
    "woodpecker.jonaenz.de" = {
      email = "jona_enzinger@outlook.com";
    };
  };

  services.nginx = {
    enable = true;
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
          WOODPECKER_MAX_PROCS = "4";
        };
        environmentFile = [ "/run/agenix/woodpecker-agent.env" ];
        # EnvironmentFile includes WOODPECKER_AGENT_SECRET
        extraGroups = [ "docker" ];
      };
    };
  };
}
