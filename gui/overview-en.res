        ��  ��                  �  4   ��
 O V E R V I E W - E N       0	        ﻿Calculating file size of an uncompressed RAW video stream is as follows:
file size=(width*height*bites per pixel)*frame rate*duration
 
and for an uncompressed RAW audio stream:
file size=sampling rate*bit depth*duration*number of channels
 
Since it requires a lot of resources to store and transfer RAW files, those who can afford these resources are not concerned with these calculations.
 
At best, users tend to use lossless compression formats. Which consist of algorithms to process and shorten binary data without disposing any of it. The output size is completely depends on the content itself. e.g. 20 seconds of silence audio vs 20 seconds of heavy metal music are completely different. The output size is unpredictable. Some known lossless compression standards are  PNG,Huffyuv,FLAC,...
 
Finally and luckily, we have Lossy Compression. Which contains advanced (psychovisual and psychoacoustics) analysis algorithms to keep the most important part of our data (to us, humans) while disposing the rest of it. It’s being used almost anywhere, online video streaming, Blu-ray disks, internet televisions, audio podcasts, just to name a few. Some known lossy compression standards are  MP3,JPEG,H264,...
Most of the encoders for these standards can operate in two modes, quality based in which the user selects a quality measure and leaves the rest to the encoder and the output size becomes unpredictable, again, depending on the content. The other mode is bitrate based in which the user selects a constant or an average bitrate and leaves the rest to the encoder, thus the output file size becomes predictable. This is where bitrate calculators like BitHesab come in handy.
 
knowing duration of a movie and our desired file size we can calculate desired video and audio bitrates, or knowing which bitrates we are going to use for video and audio streams, we can calculate the resulting file size beforehand and do modifications if needed. The formulas are:
 
video bitrate = (file size / time) - audio bitrate
file size = (video bitrate + audio bitrate) * time
 
(note: it is very important to consider bit<>byte conversion and storage vs transfer difference into account)
(note 2: some encoders won’t really respect what you decide, they do whatever they want to do at the end:P )
  