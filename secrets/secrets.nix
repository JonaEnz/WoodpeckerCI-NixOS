let
  jona = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMpVPlCOdKUuDPwJfPWDfwjhm21XDfwg4hjBLbOOirh joen@DESKTOP-DU6229O";
  users = [ jona ];
  woodpecker = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHNJbmWYRMqvXHbnJ7cmri3uR1y2OOpToU2JT8M1kKJl root@nixos";
  systems = [ woodpecker ];
in
{
  "woodpecker-server.env.age".publicKeys = [ jona woodpecker ];
  "woodpecker-agent.env.age".publicKeys = [ jona woodpecker ];
  "tailscale-auth-token.age".publicKeys = [ jona woodpecker ];
  "minio.env.age".publicKeys = [ jona woodpecker ];
}
