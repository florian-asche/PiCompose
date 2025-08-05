# Audio debugging Pipewire and more

If you have trouble with your audio playback or the microphone you can find help here.

## Audio Troubleshooting Tips
If no audio is playing:
1. Check the appropriate output in alsamixer (e.g., set Headphone output to maximum). Maybe you need to switch the soundcard before maxing your volume.
2. Verify the audio device is properly connected and recognized
3. Ensure the correct audio device is selected in your system settings

## Hardware Testing Commands
Test the Seeed Studio 2-mic HAT directly:
```bash
speaker-test -D plughw:CARD=seeed2micvoicec,DEV=0 -c2 -twav
```

Test audio through PipeWire:
```bash
speaker-test -D pipewire -c2 -twav
```

## Audio Mixer
If no audio is playing, adjust the output volume in alsamixer, for example, set the Headphone output to maximum.

Check and adjust volume levels for both standard and Seeed Studio sound cards:
- Switch between cards using F6
- Use alsamixer to adjust volume levels:
```bash
alsamixer
```

## List Available Audio Devices
View all available audio devices and their configurations:
```bash
aplay -L
```
It should list the seeed2micvoicec or Lite hardware from seeedstudio.


Example output:
```
null
    Discard all samples (playback) or generate zero samples (capture)
sysdefault
    Default Audio Device
lavrate
    Rate Converter Plugin Using Libav/FFmpeg Library
samplerate
    Rate Converter Plugin Using Samplerate Library
speexrate
    Rate Converter Plugin Using Speex Resampler
jack
    JACK Audio Connection Kit
oss
    Open Sound System
pipewire
    PipeWire Sound Server
pulse
    PulseAudio Sound Server
speex
    Plugin using Speex DSP (resample, agc, denoise, echo, dereverb)
upmix
    Plugin for channel upmix (4,6,8)
vdownmix
    Plugin for channel downmix (stereo) with a simple spacialization
default
playback
capture
dmixed
array
hw:CARD=vc4hdmi,DEV=0
    vc4-hdmi, MAI PCM i2s-hifi-0
    Direct hardware device without any conversions
plughw:CARD=vc4hdmi,DEV=0
    vc4-hdmi, MAI PCM i2s-hifi-0
    Hardware device with all software conversions
sysdefault:CARD=vc4hdmi
    vc4-hdmi, MAI PCM i2s-hifi-0
    Default Audio Device
hdmi:CARD=vc4hdmi,DEV=0
    vc4-hdmi, MAI PCM i2s-hifi-0
    HDMI Audio Output
dmix:CARD=vc4hdmi,DEV=0
    vc4-hdmi, MAI PCM i2s-hifi-0
    Direct sample mixing device
usbstream:CARD=vc4hdmi
    vc4-hdmi
    USB Stream Output
hw:CARD=seeed2micvoicec,DEV=0
    seeed-2mic-voicecard, 3f203000.i2s-wm8960-hifi wm8960-hifi-0
    Direct hardware device without any conversions
plughw:CARD=seeed2micvoicec,DEV=0
    seeed-2mic-voicecard, 3f203000.i2s-wm8960-hifi wm8960-hifi-0
    Hardware device with all software conversions
sysdefault:CARD=seeed2micvoicec
    seeed-2mic-voicecard, 3f203000.i2s-wm8960-hifi wm8960-hifi-0
    Default Audio Device
dmix:CARD=seeed2micvoicec,DEV=0
    seeed-2mic-voicecard, 3f203000.i2s-wm8960-hifi wm8960-hifi-0
    Direct sample mixing device
usbstream:CARD=seeed2micvoicec
    seeed-2mic-voicecard
    USB Stream Output
```

## List PipeWire Objects
List all PipeWire objects and nodes:
```bash
pw-cli list-objects Node
```



