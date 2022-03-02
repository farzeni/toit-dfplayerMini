# DFPlayerMini Toit Driver

A UART interface to the [DFPlayerMini](https://wiki.dfrobot.com/DFPlayer_Mini_SKU_DFR0299#target_6) MP3 module for the ESP32 [Toit framework](https://toit.io/)

The DFPlayer Mini MP3 Player is a small and low price MP3 module with an simplified output directly to the speaker. The module can be used as a stand alone module with attached battery, speaker and push buttons or used in combination with a microcontroller with RX/TX capabilities.

## Hardware tested

[DFRobot - DFPlayerMini](https://www.dfrobot.com/product-1121.html)  

## Connections

Some pins are preferred (more efficient) for use as UART pins on the ESP 32:

tx = 17, rx = 16

(Note that pins 16 and 17 are used for PSRAM on some modules, so they cannot be used for UART0.)

## Installation

This package can be installed with

```
toit pkg install github.com/farzeni/toit-dfplayerMini
```

where `<PATH_TO_HOST_PACKAGE>` is the folder containing this README.

## References

[User Manual of DFPlayerMini](https://github.com/Arduinolibrary/DFPlayer_Mini_mp3/raw/master/DFPlayer%20Mini%20Manual.pdf)
[DRRobot Wiki Page](https://wiki.dfrobot.com/DFPlayer_Mini_SKU_DFR0299#target_6)
