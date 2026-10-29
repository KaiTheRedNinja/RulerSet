# RulerSet
A digital set of measuring tools
## Why
I have often needed a measuring tape, without having one nearby. The built in Measure app doesn't work in tight spaces nor in low light, especially on non-Pro devices like mine.
I plan to create a measurement app that does NOT rely on the camera, and instead uses user input on the screen itself to measure items.

## Feature Plan
- [x] Simple ruler, incl. right-angle
- [x] Simple protractor
- [x] Simple level
- [ ] Differential angle measurement using gyroscope
- [ ] 3-axis angle measurements
- [ ] Inches-cm-mm setting
- [ ] Skeuomorphic starting UI

## Change in Plan
Originally, I had planned to use the phone's accelerometer to measure displacement. However, I discovered through experimentation that the iPhone's accelerometer has an error of about 0.001g, with noise of about 0.0005g. 
This may not sound like much, but it translates to 0.981 cm/s2 of error and 0.4905 cm/s2 of noise, with the error/noise compounding once I use it to determine displacement. Over just a single second, this starts at 1cm/s of drift, 
increasing drastically. The signal of small movements is also completely lost in the noise.

Due to this, frankly, unacceptable inaccuracy of the accelerometer, I am ditching plans to use the accelerometer to measure displacement. Instead, I am relying on the user's touch.
