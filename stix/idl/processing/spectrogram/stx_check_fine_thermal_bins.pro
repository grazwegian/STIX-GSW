;---------------------------------------------------------------------------
;+
; :project:
;       STIX
;
; :name:
;       stx_check_fine_thermal_bins
;
; :description:
;
;    This function checks the time of the observation and returns an average energy
;    shift if required.
;
;    When STIX was switched on during the RSCW of November 2020 the detector settings
;    resulted in a shift of energy calibration. For the duration of this RSCW until the
;    upload of an ELUT which accounts for this a shift of the energy science channel
;    boundaries is needed.
;
; :categories:
;     spectroscopy, io
;
; :params:
;    start_time : in, required, type="string"
;             The start time of the observation being analysed
; :returns:
;    expected_energy_shift: the expected energy shift that should be applied in keV
;
; :examples:
;    expected_energy_shift = stx_check_energy_shift('2020-11-18T00:00:00')
;
; :history:
;    20-Mar-2024 - ECMD (Graz), initial release
;
;-
function stx_check_fine_thermal_bins, start_time,  sum_fine_bins = sum_fine_bins

  ; Determin if time range of observation is during autumn 2023 fine energy bin campaign 
  fine_bin_campaign_2023 = (anytim(start_time) gt anytim('2023-07-31T00:05:58') $
    and anytim(start_time) lt anytim('2023-11-05T00:01:00'))

  if ~fine_bin_campaign_2023 and sum_fine_bins then begin
    print, '***********************************************************************'
    print, 'Warning: sum_fine_bins keyword currently only valid for 31 July to
    print, '5 November 2023'
    print, '************************************************************************'
    sum_fine_bins = 0
  endif

  default, sum_fine_bins, fine_bin_campaign_2023

  if sum_fine_bins ne 0 then begin
    print, '***********************************************************************'
    print, 'Warning: Due to the energy binning in the selected observation time'
    print, 'the bins between 6.3 and 7.3 have been summed.'
    print, '************************************************************************'
  endif

  return, sum_fine_bins
end
