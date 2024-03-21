;---------------------------------------------------------------------------
;+
; :project:
;       STIX
;
; :name:
;       stx_sum_fine_bins
;
; :description:
;    This procedure saves a property file at given location. The properties... etc.
;
; :categories:
;    spectroscopy
;
; :params:
;    spectrogram : in, required, type="stx_fsw_sd_spectrogram structure"
;             a required string input
;             
;    livetime : in, required, type="stx_fsw_sd_spectrogram structure"
;             a required string input
;
;
; :returns:
;    spectrogram : type="stx_fsw_sd_spectrogram structure"
;               an output float value
;
; :examples:
;     summed_spectrogram = stx_sum_fine_bins(spectrogram, eff_livetime_fraction_expanded)
;
; :history:
;    20-Mar-2022 - ECMD (Graz), initial release
;
;-
function stx_sum_fine_bins, spectrogram, livetime 

energy_edges = spectrogram.energy_axis.edges_2

time_range = atime(stx_time2any([spectrogram.time_axis.time_start[0], spectrogram.time_axis.time_end[-1]]))

counts = spectrogram.counts
error = spectrogram.error

ospex4binning = ospex(/no)
ospex4binning -> set, spex_ct_edges = energy_edges
data_obj = ospex4binning->get(/obj,class='spex_data')

elut_filename = stx_date2elut_file(time_range[0])
stx_read_elut, ekev_actual = ekev_actual, elut_filename = elut_filename

echan_filename = stx_date2echan_file(time_range[0])
science_energy_channels = stx_science_energy_channels(/reset, basefile = echan_filename)

fine_e = stx_read_summed_bins('summed_bins_19032024.txt')

energy_ranges = get_edge_products(fine_e, /edges_2)
counts_str = {data:counts, edata:error, ltime:livetime}

energy_summed_counts = data_obj->bin_data(data = counts_str, intervals = energy_ranges, $
  eresult = energy_summed_error, ltime = energy_summed_ltime, index = index)
ltime  = reform(energy_summed_ltime[0,*])

e_axis_summed = stx_construct_energy_axis(energy_edges = fine_e, select = indgen(n_elements(index[0,*])+1))
energy_edges_used = where_arr(fix(10*e_axis.edges_1), fix(10*e_axis_summed.edges_1))
n_energy_edges = n_elements(energy_edges_used)
n_energies = n_energy_edges-1

pixels_used = where( spectrogram.pixel_mask gt 0)
n_pixels = n_elements(pixels_used)
detectors_used = where(spectrogram.detector_mask gt 0)
n_detectors = n_elements(detectors_used)

ave_edge  = mean(reform(ekev_actual[energy_edges_used, pixels_used, detectors_used, 0], n_energy_edges, n_pixels, n_detectors), dim = 2)
ave_edge  = mean(reform(ave_edge, n_energy_edges, n_detectors), dim = 2)

edge_products, ave_edge, width = ewidth

eff_ewidth =  (e_axis_summed.width)/ewidth

energy_summed_counts =  energy_summed_counts * reform(reproduce(eff_ewidth, n_times),n_energies, n_times)

energy_summed_counts =  reform(energy_summed_counts,[n_energies, n_times])

energy_summed_error =  energy_summed_error * reform(reproduce(eff_ewidth, n_times),n_energies, n_times)

energy_summed_error =  reform(energy_summed_error, [n_energies, n_times])

obj_destroy, ospex4binning
obj_destroy, data_obj

;insert the information from the telemetry file into the expected stx_fsw_sd_spectrogram structure
spectrogram = { $
  type          : "stx_fsw_sd_spectrogram", $
  counts        : energy_summed_counts, $
  trigger       : transpose(spectrogram.trigger), $
  time_axis     : spectrogram.time_axis , $
  energy_axis   : e_axis_summed, $
  pixel_mask    : spectrogram.pixel_mask , $
  detector_mask : spectrogram.detector_mask, $
  rcr           : spectrogram.rcr,$
  error         : energy_summed_error}

return, spectrogram
end