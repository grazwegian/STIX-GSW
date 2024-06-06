function stx_energy_range2binmask, energy_range, basefile, integer = integer

default, basefile, 'ScienceEnergyChannels_1000.csv'
sci = stx_science_energy_channels(basefile = basefile, /reset, /str)

if energy_range[1] le energy_range[0] then message, 'Upper energy edge must be greater than lower edge.'


min = where(energy_range[0] eq sci.elower, count_min)
if count_min eq 0 then message, 'Energy edge ' + strtrim(energy_range[0],2) +' not found in science channel file' 
max = where(energy_range[1] eq sci.eupper, count_max)
if count_max eq 0 then message, 'Energy edge ' + strtrim(energy_range[0],2) +' not found in science channel file'

mask = intarr(32)

mask[min:max] = 1
integer = stx_mask2integer(mask)
return, mask
end