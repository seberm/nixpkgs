{ lib
, python3
}:

python3.pkgs.buildPythonApplication rec {
  pname = "whoogle-search";
  version = "0.7.2";

  src = python3.pkgs.fetchPypi {
    inherit pname version;
    hash = "sha256-RNmHo0SUHrYGNFgKBncpszNmjW0imqxhpnH+LS/oEK0=";
  };

  # FIXME: Is it possible to specify dataDir from service configuration here?
  postInstall = ''
    mv $out/${python3.sitePackages}/app/static $out/${python3.sitePackages}/app/static_runtime
    ln -s /var/lib/whoogle-search/static $out/${python3.sitePackages}/app/static
  '';

  postPatch = ''
    # Remove the version pinning
    sed -i 's/[><=]=[0-9.]*//' requirements.txt

    # Remove dev packages and packages installed by dependencies
    cat <<EOF | sed --in-place --file - requirements.txt
/pytest/d
/pycodestyle/d
/pluggy/d
/packaging/d
/py/d
/more-itertools/d
/pysocks/d
/attrs/d
/cachelib/d
/certifi/d
/cffi/d
/chardet/d
/click/d
/idna/d
/itsdangerous/d
/jinja2/d
/markupsafe/d
/pycparser/d
/pyopenssl/d
/pyparsing/d
/soupsieve/d
/urllib3/d
/wcwidth/d
/werkzeug/d
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

  # Disable tests because they require network connection
  doCheck = false;

  meta = with lib; {
    description = "A self-hosted, ad-free, privacy-respecting metasearch engine";
    license = with licenses; [ mit ];
    homepage = "https://github.com/benbusby/whoogle-search";
    maintainers = with maintainers; [ seberm ];
  };
}
