{ ... }: {
  boot.kernelModules = [ "tun" ];

  services = {
    avahi = {
      enable = true;
      nssmdns4 = true;
      publish = {
        enable = true;
        userServices = true;
      };
    };
    openthread-border-router = {
      enable = true;
      backboneInterfaces = [ "wlan0" ];
      radio = {
        device = "/dev/serial/by-id/usb-ITead_Sonoff_Zigbee_3.0_USB_Dongle_Plus_feda63ed458aef1199e0c3a3ef8776e9-if00-port0";
        baudRate = 460800;
        flowControl = false;
      };
      web.enable = true;
    };
    matter-server = {
      enable = true;
      openFirewall = true;
    };
    home-assistant = {
      enable = true;
      extraComponents = [
        "default_config"
        "otbr"
        "thread"
        "matter"
        "mqtt"
      ];
    };
  };

  networking.firewall = {
    allowedUDPPorts = [ 5353 ];
    allowedTCPPorts = [ 8123 ];
  };
}
