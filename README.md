# Erisia server-builder <a href="https://travis-ci.org/Erisia/builder"><img align="right" src="https://travis-ci.org/Erisia/builder.svg?branch=master"></a>
Build scripts for the server

Make a server directory, then run update-and-start.sh using its relative path. Example:
```
$ mkdir erisia
$ cd erisia
$ git clone https://github.com/Erisia/builder.git git
$ git/update-and-start.sh
```

## Updating manifests

The .nix files used for building the modpack are generated by cursetool
from the .yaml files in `manifest/`, and should always be updated after
any change to the .yaml files.
```
$ cursetool/run.sh update manifest/e19.yaml
```

The Curse website occasionally breaks, causing mod pages to redirect to
themselves. Cursetool will use a cached value if this happens. In the event
that no cache can be found, it will backoff and retry until it can successfully
retrieve the mod page.

## General contribution workflow

Requires nix package manager and a unix environment (You can also use nixos!) of your choice to run it in.

1. Clone down this repository
1. Create a directory to house the server
1. Navigate into it and run `../update_and_start.sh` Choose the server you intend to build
1. Assuming all this succeeds, you can safely a text editor like atom or vscode to edit the files under manifest and base in the builder folder.  These files are the ones that influence what mods the server is running as well as the configs that get deployed to the client. See Updating Manifests for how to actually update a manifest once you've made changes in it.

Once you've updated with cursetool and tried your changes with `update_and_start.sh` you can push your changes back up to the repo (use a branch or a fork please) and open a pull request against master.  At that point an admin can pull your changes into the server.


# License

Everything in this Git repository is MIT-licensed, with the exception
of the `third_party` directory and mods/configuration data in the `base`
directory; see third_party/README.md for details.

It isn't currently in shape for reuse, but if you wish to do so, make
sure to expunge base and third_party.
