# Hardware - Respeaker Lite

## Base

- [Raspberry Pi Zero 2 W](https://www.raspberrypi.com/products/raspberry-pi-zero-2-w/)
- [SD-Card](https://www.amazon.de/Samsung-microSD-Karte-SD-Adapter-Speicherkarte-MB-ME128SA/dp/B0CVBBPZ28/ref=sr_1_11?__mk_de_DE=%C3%85M%C3%85%C5%BD%C3%95%C3%91&crid=26Z2MAN8CG7C1&dib=eyJ2IjoiMSJ9._Kk8qR1UI_lIYFfD5SyvkcPoueNxeFLjWe8aplAqFBUWwbYxPYLuvsLca4U8eeA_-FT2_ImPU3V1lz-gF2zfW1y0NhTUe8nh2iMQBGAO9vnQXcFnzvdcPbGfBqVlNoUi6BlVh2u4n1X0KlTeju_8fCrZ1HCZc46M0OPpgj8b3w6yIsUwsOhlXQveEBW4q2fAEoSuu50MGNYSioj7cXFTedcZZcRvnI8RHgIwREpyRJI.QRdNNpvyMdRUfGgGu_jaElBaN5qNGkBHicDPTEPapAk&dib_tag=se&keywords=samsung%2Bsd%2Bcard%2B16gb&qid=1743299132&sprefix=samsung%2Bsd%2Bcard%2B16gb%2Caps%2C92&sr=8-11&th=1)
- [Power Supply](...)

## Speaker

- [Speaker](https://www.laskakit.cz/2-reproduktory-bose-10w-4-40mm--klon/)
- [Passiv Radiator](https://www.laskakit.cz/bose-pasivni-membrana-pro-soundlink-mini--klon/)
- [Cable for Speaker](https://de.aliexpress.com/item/1005005491577017.html?spm=a2g0o.order_list.order_list_main.364.4dac5c5fKkDzIc&gatewayAdapt=glo2deu)

## Mic Array

### ReSpeaker Lite Board

<img src="respeaker_lite.jpg" alt="ReSpeaker Lite Board" style="width: 300px; height: auto;">

#### General

USB 2-Mic Array with Onboard AI Audio Processing Algorithms,
compatible with Seeed Studio XIAO ESP32S3 (Sense), Raspberry Pi, Adafruit QT Py

- [ReSpeaker Lite](https://www.seeedstudio.com/ReSpeaker-Lite-p-5928.html?srsltid=AfmBOopODKrejEe7WIXSLV5fjLuhhK8PO-AXG3WnDI1N1pwBu-PTWQHf)
- [Cable](https://de.aliexpress.com/item/1005004792246478.html?spm=a2g0o.order_list.order_list_main.5.4dac5c5fKkDzIc&gatewayAdapt=glo2deu)
- [3D Print Design](...)

Other helpfull links:

- [Respeaker Wiki](https://wiki.seeedstudio.com/reSpeaker_usb_v3/)

#### Workaround

I in connection with the Raspberry Pi Zero 2W there is a bug in RPI-OS where the board stops working after 7 or 8 sound outputs which a reconnect to the audio card.
I implemented a workaround for that. Open issue: https://github.com/respeaker/ReSpeaker_Lite/issues/8

#### Firmware

In order to use this board with the Raspberry Pi Zero 2W you need to flash the usb-firmware. More information in the official Seeedstudio Wiki. I am currently running the [respeaker_lite_usb_dfu_firmware_v2.0.7.bin](https://github.com/respeaker/ReSpeaker_Lite/blob/master/xmos_firmwares/respeaker_lite_usb_dfu_firmware_v2.0.7.binhttps:/)

### ReSpeaker 2-Mics Pi HAT v1 Board

<img src="respeaker_2michats.webp" alt="ReSpeaker 2-Mics Pi HAT" style="width: 300px; height: auto;">

#### General

The board is older but also cheaper.

- [ReSpeaker 2Mic HAT](https://wiki.keyestudio.com/Ks0314_keyestudio_ReSpeaker_2-Mic_Pi_HAT_V1.0)
- [3D Print Design](...)

Other helpfull links:

- [Wiki](...)
- [Firmware]()
