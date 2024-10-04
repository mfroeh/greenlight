{ pkgs, lib, config, inputs, ... }:

{
  # Enable reading of .env for secrets
  dotenv.enable = true;

  # https://devenv.sh/packages/
  packages = [
    pkgs.git
    pkgs.go-migrate
    pkgs.hey
  ];

  # https://devenv.sh/languages/
  languages.go.enable = true;

  # postgres
  services.postgres.enable = true;
  services.postgres.initialScript = ''
    CREATE DATABASE greenlight;
    CREATE role greenlight WITH LOGIN PASSWORD 'pa55word';
    GRANT ALL ON DATABASE greenlight TO greenlight;
    ALTER DATABASE greenlight OWNER to greenlight;
  '';

  services.postgres.listen_addresses = "localhost";
  services.postgres.port = 5432;

  env.GREENLIGHT_DB_DSN = "postgres://greenlight:pa55word@localhost:5432/greenlight?sslmode=disable";

  # https://devenv.sh/scripts/
  scripts.hello.exec = ''
    echo hello from $GREET
  '';

  enterShell = ''
    hello
    git --version
  '';

  # https://devenv.sh/tasks/
  # tasks = {
  #   "myproj:setup".exec = "mytool build";
  #   "devenv:enterShell".after = [ "myproj:setup" ];
  # };

  # https://devenv.sh/tests/
  enterTest = ''
    echo "Running tests"
    git --version | grep --color=auto "${pkgs.git.version}"
  '';

  # https://devenv.sh/pre-commit-hooks/
  # pre-commit.hooks.shellcheck.enable = true;

  # See full reference at https://devenv.sh/reference/options/
}
