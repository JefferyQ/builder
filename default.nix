with import <nixpkgs> {};
with stdenv;

with import ./lib/lib.nix;

let
  forgeMajor = "1.7.10";
  forgeMinor = "10.13.4.1566";
in

rec {

  servers = {
    erisia-12 = {
      serverId = "erisia";
      serverDesc = "Erisia #12: Vivat Apparatus";
      server = server;
    };

    erisia-13 = {
      serverId = "test-tfp";
      serverDesc = "TFP: Ave Dolor";
      server = tfp-server;
    };
  };

  ServerPack = mkServerPack {
    inherit forgeMajor forgeMinor servers;
  };

  ## TerraFirmaPunk ##

  tfp = mkBasePack {
    src = fetchzip {
      url = https://madoka.brage.info/baughn/TerraFirmaPunk-2.0.3.zip;
      sha256 = "0qvqg81jkrg1p4rl3q965dgdr0k5930vyv748g2b399071b30cbf";
    };

    modConfig = {
      Opis = {
        required = false;
      };
      AutoRun = {
        side = "CLIENT";
      };
      BetterFoliage = {
        side = "CLIENT";
        required = false;
      };
      DynamicLights = {
        side = "CLIENT";
        required = false;
      };
      MobDismemberment = {
        side = "CLIENT";
      };
      SoundFilters = {
        side = "CLIENT";
      };
      ArmorStatusHUD = {
        side = "CLIENT";
        required = false;
      };
      DamageIndicatorsMod = {
        side = "CLIENT";
        required = false;
      };
      fastcraft = {
        required = false;
      };
    };
  };

  tfp-mods = (builtins.removeAttrs tfp.mods [
    "Aroma1997Core"
  ]) // {
    # Libraries.
    ForgeMultiPart = mkMod {
      name = "ForgeMultiPart-1.7.10";
      src = fetchurl {
        url = http://files.minecraftforge.net/maven/codechicken/ForgeMultipart/1.7.10-1.2.0.347/ForgeMultipart-1.7.10-1.2.0.347-universal.jar;
        sha256 = "0r3mgss1fakbrrkiifrf06dcdwnxbwsryiiw0l2k4sbjvk58hah0";
      };
    };

    # bspkrsCore = fetchCurse {
    #   name = "bspkrsCore";
    #   target = "[1.7.10]bspkrsCore-universal-6.16.jar";
    # };

    # CodeChickenLib = mkMod {
    #   name = "CodeChickenLib-1.1.3.140";
    #   src = fetchurl {
    #     url = http://files.minecraftforge.net/maven/codechicken/CodeChickenLib/1.7.10-1.1.3.140/CodeChickenLib-1.7.10-1.1.3.140-universal.jar;
    #     sha256 = "06jf4h34by7d9dfbgsb3ii7fm6kqirny645afvb8c8wlg65n0rvr";
    #   };
    # };

    eirairc = fetchCurse {
      name = "eirairc";
      target = "eirairc-mc1.7.10-2.9.402.jar";
      side = "SERVER";
    };

    # Extra cosmetic mods.
    DynamicSurroundings = fetchCurse {
      name = "238891-dynamic-surroundings";
      target = "DynamicSurroundings-1.7.10-1.0.5.6.jar";
      side = "CLIENT";
      required = false;
    };

    # # Needed by StellarSky and Photoptics.
    # StellarAPI = fetchCurse {
    #   name = "stellar-api";
    #   target = "Stellar API v0.1.3.6b [1.7.10]";
    # };

    # # TODO: Tweak this to work with TFC.
    # Photoptics = fetchCurse {
    #   name = "photoptics";
    #   target = "Photoptics v0.1.1.7 [1.7.10] (Stellar API v0.1.3.6)";
    # };

    # StellarSky = fetchCurse {
    #   name = "stellar-sky";
    #   target = "Stellar Sky v0.1.5.3d[1.7.10] (Stellar API v0.1.3.6(b))";
    # };

    Shaders = mkMod {
      name = "shaders";
      src = fetchurl {
        url = http://www.karyonix.net/shadersmod/files/ShadersModCore-v2.3.31-mc1.7.10-f.jar;
        sha256 = "1a5wz4haa6639asrskraj1vdafi7f16gv9dib9inqsjdc9hvkv3j";
      };
      side = "CLIENT";
      required = false;
    };

    # Fastcraft conflicts with TickProfiler.
    # For now, disabling the latter. Not sure if the former is of any use, but we've got Opis.
    # TickProfiler = mkMod {
    #   name = "TickProfiler-1.7.20-jenkins-29";
    #   src = fetchurl {
    #     url = https://jenkins.nallar.me/job/TickProfiler/branch/1.7.10/lastSuccessfulBuild/artifact/build/libs/TickProfiler-1.7.10.jenkins.29.jar;
    #     sha256 = "10k8h6aybaswvqbxpqn3rrka929dacfra2n9g7l6knzym8k3ghp3";
    #   };
    #   side = "SERVER";
    # };
  };

  tfp-resourcepack = fetchzip {
    url = https://madoka.brage.info/baughn/ResourcePack-tfp.zip;
    sha256 = "01wrf1vnwwgd5vazmbs24kwhb4njys33wbx65inagkfpz7sg9mxs";
    stripRoot = false;
  };

  tfp-server = mkServer {
    name = "erisia-13";

    mods = tfp-mods;

    inherit forgeMajor;
    forge = fetchForge {
      major = forgeMajor; minor = forgeMinor;
      sha1 = "4d2xzm7w6xwk09q7sbcsbnsalc09xp0v";
    };

    # These are applied in order. In case of overwrites nothing is deleted.
    # They're also copied to the client, after applying the below patches.
    extraDirs = [
      (tfp.getDir "config")
      (tfp.getDir "scripts")
      (tfp.getDir "mods/resources")
      (bevos.getDir "libraries")
      tfp-resourcepack
    ];

    # These are applied after everything else.
    # And in order, if it matters.
    # TODO: Write something that understands what it's doing.
    configPatches = [
      # Keep the SD behaviour we're used to.
      ''sed -i StorageDrawers.cfg -e s/B:invertShift=false/B:invertShift=true/''
      # No, don't lock people out if they die. :'(
      ''sed -i hqm/hqmconfig.cfg -e 's/B:"Auto-start hardcore mode"=true/B:"Auto-start hardcore mode"=false/' ''
    ];
  };

  ##########################
  ## Erisia 12 below here ##
  ##########################

  bevos = mkBasePack {
    src = fetchzip {
      url = https://madoka.brage.info/baughn/BevosT.zip;
      sha256 = "09q0vv8qnm3hspz5bks80jf3n5cmn94b2y9bv8svffxisf0l6k0y";
      stripRoot = false;
    };

    # This lets you set options for mods in the base back.
    # Same way as for mods added to it, below.
    modConfig = {
      fastcraft = {
        required = false;
        side = "CLIENT";
      };
    };
  };

  # This is where we add mods that weren't part of Bevos.
  mods = bevos.mods // {
    # TODO: The below has a hell of a lot of not-using-the-version-option.
    # Because it never works.
    # It should be possible to make use of the perl version-number parser to fix that.

    # These mod(s) override mods that exist in Bevo's pack, so the attribute name
    # actually matters. For everything else, it pretty much doesn't.

    # None at the moment.

    # Server-side mods:
    dynmap = mkMod {
      name = "dynmapforge";
      src = fetchurl {
        url = https://bloxgaming.com/bloxgate/Dynmap-2.2-forge-1.7.10.jar;
        sha256 = "d6391dc83af1cd2ec51ffceb4e6bb58bf1419a96336ca92360acfd90a91ce9b9";
      };
      side = "SERVER";
    };

    eirairc = fetchCurse {
      name = "eirairc";
      target = "eirairc-mc1.7.10-2.9.402.jar";
      side = "SERVER";
    };

    # Client-side:
    WhatsThisPack = fetchCurse {
      name = "wtp-whats-this-pack";
      target = "WTP-1.7.10-1.0.29.1.jar";
      side = "CLIENT";
    };

    DynamicSurroundings = fetchCurse {
      name = "238891-dynamic-surroundings";
      target = "DynamicSurroundings-1.7.10-1.0.5.6.jar";
      side = "CLIENT";
      required = false;
    };

    # StellarSky = fetchCurse {
    #   name = "stellar-sky";
    #   target = "Stellar Sky v0.1.2.9b[1.7.10] (SciAPI v1.1.0.0)";
    #   side = "CLIENT";
    #   required = false;
    #   # TODO: Make this depend on sciapi, make both optional.
    #   # Implement dependencies.
    # };

    # sciapi = fetchCurse {
    #   name = "sciapi";
    #   target = "SciAPI v1.1.0.0[1.7.10]";
    #   side = "CLIENT";
    # };

    # Both-sided:

    # Opis appears to be incompatible with ForgeEssentials.
    
    # Opis = fetchCurse {
    #   name = "opis";
    #   target = "Opis-1.2.5_1.7.10.jar";
    #   required = false;
    # };

    # # TODO: Opis depends on this.
    # MobiusCore = fetchCurse {
    #   name = "mobiuscore";
    #   target = "MobiusCore-1.2.5_1.7.10.jar";
    #   required = false;
    # };

    TickProfiler = mkMod {
      name = "TickProfiler-1.7.20-jenkins-29";
      src = fetchurl {
        url = https://jenkins.nallar.me/job/TickProfiler/branch/1.7.10/lastSuccessfulBuild/artifact/build/libs/TickProfiler-1.7.10.jenkins.29.jar;
        sha256 = "10k8h6aybaswvqbxpqn3rrka929dacfra2n9g7l6knzym8k3ghp3";
      };
      side = "SERVER";
    };
    
    ImmibisCore = mkMod {
      name = "ImmibisCore-59.1.4";
      src = fetchurl {
        url = https://madoka.brage.info/baughn/ImmibisCore-59.1.4.jar;
        md5 = "14dbc89ce3d361541234ac183270b5a1";
      };
    };

    DimensionalAnchors = mkMod {
      name = "DimensionalAnchors-59.0.3";
      src = fetchurl {
        url = https://madoka.brage.info/baughn/DimensionalAnchors-59.0.3.jar;
        md5 = "65669c1fab43ae1d3ef41a659fdd530c";
      };
    };

    ElectricalAge = mkMod rec {
      ver = "51.15";
      name = "ElectricalAge-${ver}";
      src = fetchurl {
        url = "https://madoka.brage.info/baughn/ElectricalAge-${ver}.jar";
        sha256 = "c5d7e665f743f8e7122b551b0f11c335b1e7dfc8a021acbfd7d2edddc1bbe374";
      };
    };
    
    PrometheusIntegration = mkMod {
      name = "PrometheusIntegration-1.1.0";
      src = fetchurl {
        url = https://madoka.brage.info/baughn/prometheus-integration-1.1.0.jar;
        sha256 = "04i2l2h2dqsbz8gri7ihkhdsrqpn2g3kfyh1swp45vivvl6f9fa3";
      };
      side = "SERVER";
    };

    Agricraft = fetchCurse {
      name = "AgriCraft";
      version = "1.5.0";
    };
    Automagy = fetchCurse {
      name = "Automagy";
      target = "v0.28.2";
    };
    BiomesOPlenty = fetchCurse {
      name = "biomes-o-plenty";
      target = "BiomesOPlenty-1.7.10-2.1.0.1889-universal.jar";
    };
    Farseek = fetchCurse { # streams dependency
      name = "Farseek";
      target = "Farseek-1.0.11.jar";
    };
    Flatsigns = fetchCurse {
      name = "flatsigns";
      target = "FlatSigns-1.7.10-universal-2.1.0.19.jar";
    };
    ForbiddenMagic = fetchCurse {
      name = "forbidden-magic";
      target = "Forbidden Magic-1.7.10-0.574.jar";
    };
    IguanasTinkerTweaks = fetchCurse {
      name = "iguanas-tinker-tweaks";
      target = "IguanaTinkerTweaks-1.7.10-2.1.6.jar";
    };
    MagicBees = fetchCurse {
      name = "magic-bees";
      target = "magicbees-1.7.10-2.4.3.jar";
    };
    Streams = fetchCurse {
      name = "streams";
      target = "Streams-0.2.jar";
    };
    RTG = fetchCurse {
      name = "realistic-terrain-generation";
      target = "RTG-1.7.10-0.7.0";
    };
    TcNodeTracker = fetchCurse {
      name = "thaumcraft-node-tracker";
      target = "tcnodetracker-1.7.10-1.1.2.jar";
    };
    ThaumicEnergistics = fetchCurse {
      name = "thaumic-energistics";
      target = "Thaumic Energistics 1.0.0.1";
    };
    ThaumicHorizons = fetchCurse {
      name = "thaumic-horizons";
      target = "thaumichorizons-1.7.10-1.1.9.jar";
    };
    ThaumicTinkerer = fetchCurse {
      name = "thaumic-tinkerer";
      target = "Thaumic Tinkerer 164";
    };
    TravellersGear = fetchCurse {
      name = "travellers-gear";
      target = "Traveller's Gear v1.16.6";
    };
    Witchery = fetchCurse {
      name = "witchery";
      version = "0.24.1";
    };
    WitchingGadgets = fetchCurse {
      name = "witching-gadgets";
      target = "Witching Gadgets v1.1.10";
    };
    Ztones = fetchCurse {
      name = "ztones";
      target = "Ztones-1.7.10-2.2.1.jar";
    };

    # Reika's mods below. Beware.
    DragonAPI = fetchCurse {
      name = "dragonapi";
      target = "DragonAPI 1.7.10 V14d.jar";
    };
    RotaryCraft = fetchCurse {
      name = "rotarycraft";
      target = "RotaryCraft 1.7.10 V14d.jar";
    };
    
    #ForgeEssentials
    ForgeEssentials = fetchCurse {
      name = "forge-essentials-74735";
      target = "forgeessentials-1.7.10-1.4.4.1146";
      side = "SERVER";
    };
    ForgeEssentialsClient = fetchCurse {
      name = "forge-essentials-client";
      target = "forgeessentials-1.7.10-1.4.4.1146-client";
      side = "CLIENT";
      required = false;
    };

    # Adds extra paintings!
    BiblioCraft = mkMod {
      name = bevos.mods.BiblioCraft.name;

      src = mkDerivation {
        name = "BiblioCraft-tampered";

        src = bevos.mods.BiblioCraft;
        extraPaintings = ./extraPaintings;

        buildInputs = [ zip imagemagick ];

        builder = mkBuilder ''
          cp "$(find $src -name \*.jar)" tmp.zip &
          mkdir -p assets/bibliocraft/textures/custompaintings
          pushd assets/bibliocraft/textures/custompaintings
          for i in $(find $extraPaintings -type f); do
            convert $i -resize '512x512>' $(echo $(basename $i) | sed 's/\..*//').png &
          done
          wait
          popd
          chmod u+w tmp.zip
          zip -r tmp.zip assets
          mv tmp.zip $out
        '';
      };
    };
  };

  resourcepack = fetchzip {
    url = https://madoka.brage.info/baughn/ResourcePack.zip;
    sha256 = "1xlw05895qvrhdn075lg88g07f1bc5h8xmj7v76434rcwbr5s2dd";
    stripRoot = false;
  };

  server = mkServer {
    name = "erisia-12";

    mods = mods;

    inherit forgeMajor;
    forge = fetchForge {
      major = forgeMajor; minor = forgeMinor;
      sha1 = "4d2xzm7w6xwk09q7sbcsbnsalc09xp0v";
    };

    # These are applied in order. In case of overwrites nothing is deleted.
    # They're also copied to the client, after applying the below patches.
    extraDirs = [
      (bevos.getDir "config")
      (bevos.getDir "scripts")
      (bevos.getDir "libraries")
      (bevos.getDir "mods/resources")
      resourcepack
      # This is, of course, inside the git repository. Being last, any files you
      # put here override files in Bevos' zips.
      ./base
    ];

    # These are applied after everything else.
    # And in order, if it matters.
    # TODO: Write something that understands what it's doing.
    configPatches = [
      ''sed -i StorageDrawers.cfg -e s/B:invertShift=false/B:invertShift=true/''

      # AOBD / RotC integration is frequently buggy, and nearly pointless anyway.
      ''sed -i aobd.cfg -e s/B:RotaryCraft=true/B:RotaryCraft=false/''

      # Start AE off with a more useful default, if we're overwriting the config every time anyway.
      ''sed -i AppliedEnergistics2/AppliedEnergistics2.cfg -e "s/S:SEARCH_MODE=.*/S:SEARCH_MODE=NEI_AUTOSEARCH/"''

      #disable extremely annoying tree planting
      ''sed -i scottstweaks.cfg -e s/B:doPlantGrowable=true/B:doPlantGrowable=false/''

      # So many client configs.
      ''find . | grep -i client | xargs rm''

      # Patch an entity ID conflict. It didn't happen before. ...I don't know.
      ''sed -i "MatterOverdrive/Matter Overdrive.cfg" -e "s/I:entity.failed_pig.id=38/I:entity.failed_pig.id=138/"''

     # Why on notch's green overworld would anyone ever want expensive safari nets?    
     ''sed -i "powercrystals/minefactoryreloaded/common.cfg" -e "s/B:ExpensiveSafariNet=true/B:ExpensiveSafariNet=false/"''

    ];
  };

}
