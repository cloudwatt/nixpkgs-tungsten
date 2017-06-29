# This file defines derivations built by Hydra

let
  images = import ./image.nix {};
  controller = import ./controller.nix {};
in
  images //
  { contrailApi = controller.contrailApi; }
