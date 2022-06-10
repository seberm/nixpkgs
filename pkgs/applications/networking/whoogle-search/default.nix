{ lib
, python3
, nixosTests
}:

python3.pkgs.buildPythonApplication rec {
  pname = "whoogle-search";
  version = "0.7.3";

  src = python3.pkgs.fetchPypi {
    inherit pname version;
    hash = "sha256-h82eTeEF0+EF3nO2ew7oWBZiFYL6fYMHF1ZiLDXvexE=";
  };

  postInstall = ''
    mv $out/${python3.sitePackages}/app/static $out/${python3.sitePackages}/app/static_runtime

    # FIXME: Is it possible to specify dataDir from service configuration here?
    ln -s /var/lib/whoogle-search/static $out/${python3.sitePackages}/app/static
  '';

  postPatch = ''
    # Remove the version pinning
    sed -i 's/[><=]=[0-9.]*//' requirements.txt

    # Remove dev packages
    cat <<EOF | sed --in-place --file - requirements.txt
/pytest/d
/pycodestyle/d
EOF
  '';

  propagatedBuildInputs = with python3.pkgs; [
    beautifulsoup4
    cssutils
    cryptography
    defusedxml
    flask
    flask-session
    python-dotenv
    requests
    stem
    waitress
  ];

  doCheck = false;

  passthru.tests = {
    inherit (nixosTests) whoogle-search;
  };


  meta = with lib; {
    description = "A self-hosted, ad-free, privacy-respecting metasearch engine";
    license = with licenses; [ mit ];
    homepage = "https://github.com/benbusby/whoogle-search";
    maintainers = with maintainers; [ seberm ];
  };
}
