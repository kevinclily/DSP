function [demod_vec_tot] = qam_demod_adaptive(noisy_mod_vec,bk,mapping,UnitAveragePower,bits_remainding,quotient,m)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%% demodulation of all frames except last one
demod_vec_tot = [];
for k =1:1:quotient
    for l =1:1:length(bk)
        Mk = bk(l);
        if Mk ~= 0
            demod_vec = qamdemod(noisy_mod_vec((k-1)*length(bk) + l), 2^Mk, mapping, 'OutputType', 'bit', 'UnitAveragePower', UnitAveragePower, 'PlotConstellation', false);
        else
            demod_vec = [];
        end
        demod_vec_tot = [demod_vec_tot; demod_vec];
    end
      
    
end

%% for last frame 
bk(m) = bits_remainding;
for l =1:1:m
    Mk = bk(l);
    if Mk ~= 0
        demod_vec = qamdemod(noisy_mod_vec((quotient)*length(bk) + l), 2^Mk, mapping, 'OutputType', 'bit', 'UnitAveragePower', UnitAveragePower, 'PlotConstellation', false);
    else
        demod_vec = [];
    end
    demod_vec_tot = [demod_vec_tot; demod_vec];
end


end



