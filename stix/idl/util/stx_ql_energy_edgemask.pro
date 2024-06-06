function stx_ql_energy_edgemask, basefile, integer = integer, upperedge = upperedge
compile_opt strictarrsubs
default, basefile, 'ScienceEnergyChannels_1000.csv'
sci = stx_science_energy_channels(basefile = basefile, /reset, /str)
ql =  sci.ql_channel

find_changes,ql,idx,state

idx_valid = idx[where(state ge 0)] 
upperedge = 0
if idx[-1] eq 32 then upperedge = 1 else  idx_valid = [idx_valid, idx[-1]]

edgemask = intarr(32)
edgemask[idx_valid] = 1
integer = stx_mask2integer(edgemask)
return, edgemask 
end