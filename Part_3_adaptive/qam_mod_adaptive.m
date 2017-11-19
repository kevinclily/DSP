function [mod_vec_tot,m,bits_remainding,quotient] = qam_mod_adaptive(bk,sequence,mapping,UnitAveragePower)
%This function create a QAM modulation of the input sequence with several
%arguments such as the mapping, the QAM order, ... notice that mapping can
%be either 'gray' or 'bin' and UniAveragPozer can be either true or false

%% 0-padding the #bits such that the modulation works proprely -> not smart :(
%%% sum(bk) represents the number of bits that you can modulate per frame 
remainder = rem(length(sequence),sum(bk));
quotient = floor(length(sequence)/sum(bk)); %% number of frame required in the OFDM
padding = sum(bk) - remainder;
M = (quotient+1)*length(bk); %% length of total modulated vector 
%sequence = [sequence ;zeros(padding,1)];

%% modulation of all frames except last one
mod_vec_tot = zeros(M,1) +1i*zeros(M,1);
for k =1:1:quotient
    for l =1:1:length(bk)
        Mk = bk(l);
        seq_k = sequence(1:Mk);
        sequence = sequence(Mk+1:end);
        if Mk == 0
            mod_vec = 0;
        else
            mod_vec = qammod(seq_k, 2^Mk,mapping, 'InputType', 'bit', 'UnitAveragePower', UnitAveragePower, 'PlotConstellation', false);
        end
        mod_vec_tot((k-1)*length(bk) + l) =  mod_vec;
    end
    
end
%% treating last frame (remainder)
m = 1; %% is the index of bk where all bits are modulated
while (sum(bk(1:m)) < remainder ) m=m+1;end
bits_remainding = rem(remainder,sum(bk(1:m-1)));
bk_last = bk;
bk_last(m) = bits_remainding ;

for l =1:1:m
    Mk = bk_last(l);
    seq_k = sequence(1:Mk);
    sequence = sequence(Mk+1:end);
    if Mk == 0
        mod_vec = 0;
    else
        mod_vec = qammod(seq_k, 2^Mk,mapping, 'InputType', 'bit', 'UnitAveragePower', UnitAveragePower, 'PlotConstellation', false);
    end
    mod_vec_tot(quotient*length(bk_last) + l) =  mod_vec;
end

end



