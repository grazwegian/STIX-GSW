pro stx_rebin_time_from_file, time_bin_filename, hstart_time, counts, triggers, time_bin_center, duration, triggers_err, counts_err, rcr, time_shift = time_shift  

default, time_shift, 0 
readcol, time_bin_filename, DELIMITER=' ',HH1,MM1,SS1,HH2,MM2,SS2,binsize

ngroups = n_elements(binsize)
nbins = ((hh2-hh1)*3600+(mm2-mm1)*60+(ss2-ss1))/binsize

tod = list()
for i =0, ngroups-1 do tod.add, (hh1[i])*3600+(mm1[i])*60+(ss1[i])+findgen(nbins[i])*binsize[i]
td = tod.ToArray(dim = 1)
nt = n_elements(td)
hst = anytim(hstart_time ,/time_only)

stxt = hst + time_shift + [time_bin_center - duration/2., time_bin_center[-1] + duration[-1]/2.]
group = value_locate( stxt,  td)

idx_close = lonarr(nt)
diff_close = fltarr(nt)
for i =0, nt-1 do begin
  near = Min(Abs(stxt - td[i]), index)
  idx_close[i] = index
  diff_close[i] = near
endfor
idx_start = max(where(idx_close eq 0))
ic = idx_close[idx_start:-1]
nc=  n_elements(ic)


new_counts = fltarr(32 ,n_elements(ic)-1)
for i =0,nc-2 do new_counts[*,i]= total(counts[*,ic[i]:ic[I+1]-1], 2)

new_triggers= fltarr(n_elements(ic)-1)
for i =0,nc-2 do new_triggers[i]= total(triggers[ic[i]:ic[I+1]-1])

new_time_bin_center= fltarr(n_elements(ic)-1)
for i =0,nc-2 do new_time_bin_center[i]= (stxt[ic[I+1]]-stxt[ic[i]])/2.+stxt[ic[i]]-hst - time_shift


new_duration = fltarr(n_elements(ic)-1)
for i =0,nc-2 do new_duration[i]= total(duration[ic[i]:ic[I+1]-1])

new_triggers_err= fltarr(n_elements(ic)-1)
for i =0,nc-2 do new_triggers_err[i]= sqrt(total(triggers_err[ic[i]:ic[I+1]-1]^2.))

new_counts_err = fltarr(32 ,n_elements(ic)-1)

for i =0,nc-2 do new_counts_err[*,i]= sqrt(total(counts_err[*,ic[i]:ic[I+1]-1]^2., 2))

new_rcr= fltarr(n_elements(ic)-1)
for i =0,nc-2 do new_rcr[i]= rcr[ic[i]]

counts = new_counts
triggers = new_triggers
time_bin_center = new_time_bin_center
duration = new_duration
triggers_err = new_triggers_err
counts_err = new_counts_err
rcr = new_rcr

end