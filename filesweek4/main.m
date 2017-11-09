clear all;
close all;
load('IRest.mat')
channel_IR = h;
% Exercise session 4: DMT-OFDM transmission scheme

% Constants
Nq=6; %max 6
N=10e3; %N must be even
prefix_value = length(h)+1; %% ti has just to be longer !!! 
SNR=50; %Signal to noise ratio
L=10; %channel order

% Convert BMP image to bitstream
[bitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');

% QAM modulation
qamStream = qam_mod_2(Nq,bitStream,'bin',true);

%%%%%%%%%%%% Check remainder %%%%%%%%%%%%%%
remainder = mod(length(qamStream),(N/2 -1));

% OFDM modulation
% input,length of packet N,prefix-> TRUE or FALSE, length of prefix,
% remainder
ofdmStream = ofdm_mod(qamStream,N,true,prefix_value,remainder); 

% Channel with a random TF
%num=randi([0 20],1,L);
%den=[1 zeros(1,L-1)];
%H=filt(num,den);
%num = -0.5:0.05:-0.05;
%num = -num
%rxOfdmStream = filter(num,1,ofdmStream);

% Channel with true impulse response 
%num=randi([0 20],1,L);
%den=[1 zeros(1,L-1)];
%H=filt(num,den);
rxOfdmStream = filter(h,1,ofdmStream);

% Adding white noise
rxOfdmStream = awgn(rxOfdmStream, SNR, 'measured'); %%%% ALWAYS ADD 'measured'

% OFDM demodulation + equalization
eq = fft(h,N);
fourier_sig = mag2db(abs(eq));
plot(fourier_sig);
title('DFT of IR (2nd method)');
xlabel('frequency [Hz]');
ylabel('Magnitude [dB]');
grid on
rxQamStream = ofdm_demod(rxOfdmStream,N,true,prefix_value,remainder,eq);

% QAM demodulation
rxBitStream = qam_demod(rxQamStream,Nq,'bin',true);

% Compute BER
[berTransmission] = ber(bitStream,rxBitStream);

% Construct image from bitstream
imageRx = bitstreamtoimage(rxBitStream, imageSize, bitsPerPixel);

% Plot images
subplot(2,1,1); colormap(colorMap); image(imageData); axis image; title('Original image'); drawnow;
subplot(2,1,2); colormap(colorMap); image(imageRx); axis image; title(['Received image']); drawnow;
