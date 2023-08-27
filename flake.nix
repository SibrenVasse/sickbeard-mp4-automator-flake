{
  description = "Sickbeard's MP4 Automator";

  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.0.tar.gz";
    flake-utils.url =
      "https://flakehub.com/f/numtide/flake-utils/0.1.85.tar.gz";
    mach-nix.url = "github:DavHau/mach-nix";
  };

  outputs = { self, nixpkgs, flake-utils, mach-nix, ... }:
    let
      ver = "0.0.20230814";
    in flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in rec {
        defaultPackage = mach-nix.lib.${system}.buildPythonApplication rec {
          pname = "sbmp4a";
          version = ver;
          format = "setuptools";

          src = pkgs.fetchFromGitHub {
            owner = "mdhiggins";
            repo = "sickbeard_mp4_automator";
            rev = "5cbc33749bf771678702c7196302f7c1515758ae";
            hash = "sha256-ExUlagZ9rt+bAFcORdB69YtpGNY/Dj6Gdgdo85GMa1k=";
          };

          requirements = builtins.readFile ./requirements.txt;

          #propagatedBuildInputs = [ pkgs.python311Packages.setuptools ];

          preBuild = ''
            # Use our setup.py because sbmp4a doesn't provide one.
            cp ${./setup.py} setup.py
            substituteInPlace setup.py --replace VERSION ${ver}
          '';

          postInstall = ''
            manual=$out/bin/sbmp4a
            mkdir -p $out/bin
            cp ${src}/manual.py $manual

            # This program creates the two ini file if they are missing, so we
            # provide one that fits our environment so it doesn't try to write
            # into a read-only file system.
            config=$out/lib/python3.9/site-packages/sbmp4a/config
            cp ${./autoProcess.ini} $config/autoProcess.ini
            cp ${./logging.ini} $config/logging.ini

            # Logging is also done inside the source tree, which we don't want
            # and Nix can't handle (ro filesystem), so we redirect that to the
            # /tmp/ partition.
            logpy=$out/lib/python3.9/site-packages/sbmp4a/resources/log.py
            substituteInPlace $logpy --replace "logpath = configpath" "logpath = '/tmp/sbmp4a'"

            # Replace various import statements because sbmp4a wasn't written
            # as an application, it was written as a standalone application we're
            # forcing into a Nix package.
            #
            # This has the elegance of a monkey beating on a black obelisk with a bone.
            for i in $(find $out -name "*.py") $manual
            do
              echo "fixing imports: $i"

              for j in autoprocess converter resources
              do
                substituteInPlace $i --replace "from $j" "from sbmp4a.$j"
              done
            done
          '';

          meta = with pkgs.lib; {
            description =
              "Automatically convert video files to a standardized format with metadata tagging to create a beautiful and uniform media library";
            homepage = "https://github.com/mdhiggins/sbmp4a";
            license = licenses.mit;
            maintainers = with maintainers; [ ];
          };
        };

        formatter = pkgs.alejandra;
      });
}
