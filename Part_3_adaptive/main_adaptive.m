clear all;
close all;
mkdir('/Users/matthieu/GitHub/DSP')
addpath(genpath('/Users/matthieu/GitHub/DSP'))

load('IRest.mat');
load('pnk.mat');
channel_IR = h;
%% Variable initilisation 
% Defining first what is the length of the packet 
N=1000; %N must be even
% Gamma = 10 allows to believe to a theoretical BER of 10^-6 per freq. bins
gamma = 100;
eq = fft(h,N);
%pnk = compute_pnk(N-1);
bk = compute_bk(eq(2:N/2),gamma,pnk(2:end));
fourier_sig = mag2db(abs(eq));
plot(fourier_sig);
title('DFT of IR (2nd method)');
xlabel('frequency [Hz]');
ylabel('Magnitude [dB]');
grid on
% Exercise session 4: DMT-OFDM transmission scheme

% Constants
Nq=6; %max 6
prefix_value = length(h)+1; %% ti has just to be longer !!! 
SNR=20; %Signal to noise ratio
L=10; %channel order

%% Convert BMP image to bitstream
[bitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');

%% QAM modulation

[qamStream,m,bits_remainding,quotient] = qam_mod_adaptive(bk,bitStream,'bin',true);
%%%%%%%%%%%% Check remainder %%%%%%%%%%%%%%
remainder = mod(length(qamStream),(N/2 -1));


% OFDM modulation
% input,length of packet N,prefix-> TRUE or FALSE, length of prefix,
% remainder
ofdmStream = ofdm_mod(qamStream,N,true,prefix_value,remainder); 
% Channel with a random TF
% Channel with true impulse response 
rxOfdmStream = filter(h,1,ofdmStream);
% Adding white noise
rxOfdmStream = awgn(rxOfdmStream, SNR, 'measured'); %%%% ALWAYS ADD 'measured'
% OFDM demodulation + equalization

rxQamStream = ofdm_demod(rxOfdmStream,N,true,prefix_value,remainder,eq);
% QAM demodulation
rxBitStream = qam_demod_adaptive(rxQamStream,bk,'bin',true,bits_remainding,quotient,m);

% Compute BER
[berTransmission] = ber(bitStream,rxBitStream);

% Construct image from bitstream
imageRx = bitstreamtoimage(rxBitStream, imageSize, bitsPerPixel);

% Plot images
figure
subplot(2,1,1); colormap(colorMap); image(imageData); axis image; title('Original image'); drawnow;
subplot(2,1,2); colormap(colorMap); image(imageRx); axis image; title(['Received image']); drawnow;

