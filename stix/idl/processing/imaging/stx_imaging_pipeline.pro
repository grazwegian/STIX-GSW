;+
; NAME:
;    stx_imaging_pipeline
;
; PURPOSE:
;    Read STIX L1 data and auxiliary data to construct a map using MEM_GE
;
; CALLING SEQUENCE:
;    result = stx_imaging_pipeline(stix_uid, time_range, energy_range, xy_flare [, imsize=imsize, pixel=pixel, x_ptg=x_ptg, y_ptg=y_ptg])
;    
; INPUTS:
;    stix_uid    : string giving the unique ID of the STIX L1 data
;    time_range  : start and end time to consider, in any format accepted by function anytim
;    energy_range: energy range to consider (in keV)
;    xy_flare    : position (quasi-heliocentric, in arcsec) of the flare, also used for map center
;
; OPTIONAL INPUTS:
;   imsize       : size (in pixels) of the image to be generated (default: [128, 128])
;   pixel        : size (in arcsec) of one pixel in the map (default: [2.,2.])
;   x_ptg, y_ptg : if provided, use these values instead of those found in the auxiliary file to correct for pointing
;
; OUTPUTS:
;   Returns a map object that can be displayed with plot_map
;
; EXAMPLES:
;   mem_ge_map = stx_imaging_pipeline('2109230031', ['23-Sep-2021 15:20:30', '23-Sep-2021 15:22:30'], [18,28], [650.,-650.])
;   map_1 = stx_imaging_pipeline('2110090002', ['2021-10-09T06:29:50','2021-10-09T06:32:30'], [18,28], [20., 420.])
;   map_2 = stx_imaging_pipeline('2110090002', ['2021-10-09T06:29:50','2021-10-09T06:32:30'], [4,8], [20., 420.])
;
; MODIFICATION HISTORY:
;    2022-05-19: F. Schuller (AIP, Germany): created
;    2022-08-30, FSc: use stx_estimate_location to find source position if not given
;    2022-09-09, FSc: added optional argument bkg_uid
;    2022-10-06, FSc: adapted to recent changes in other procedures
;
;-
function stx_imaging_pipeline, stix_uid, time_range, energy_range, bkg_uid=bkg_uid, $
                               xy_flare=xy_flare, imsize=imsize, pixel=pixel, x_ptg=x_ptg, y_ptg=y_ptg, $
                               use_sas=use_sas, dont_use_sas=dont_use_sas
  if n_params() lt 3 then begin
    print, "STX_IMAGING_PIPELINE"
    print, "Syntax: result = stx_imaging_pipeline(stix_uid, time_range, energy_range [, xy_flare=xy_flare, imsize=imsize, pixel=pixel, x_ptg=x_ptg, y_ptg=y_ptg])"
    return, 0
  endif

  ; Input directories - TO BE ADAPTED depending on local installation - FIX ME!
  aux_data_folder = '/store/data/STIX/L2_FITS_AUX/'
;   l1a_data_folder = '/store/data/STIX/L1A_FITS/L1/'
  l1a_data_folder = '/store/data/STIX/L1_FITS_SCI/'

  default, imsize, [128, 128]
  default, pixel,  [2.,2.]

  ;;;;
  ; Read auxiliary file: first, extract date from time_range[0]
  time_0 = anytim2utc(anytim(time_range[0], /tai), /ccsds)
  day_0 = strmid(str_replace(time_0,'-'),0,8)
;  aux_fits_file = aux_data_folder + 'solo_L2_stix-aux-auxiliary_'+day_0+'_V01.fits'
  ; AUX files changed name in September 2022, therefore:
  aux_fits_file = aux_data_folder + 'solo_L2_stix-aux-ephemeris_'+day_0+'_V01.fits'
  ; Extract data at requested time
  if ~file_test(aux_fits_file) then message,"Cannot find auxiliary data file "+aux_fits_file
;  aux_data = stx_create_auxiliary_data(aux_fits_file, time_range, /dont_use_sas)
  aux_data = stx_create_auxiliary_data(aux_fits_file, time_range, use_sas=use_sas, dont_use_sas=dont_use_sas)
  
  ; If an aspect solution is given as input, use that one
  if keyword_set(x_ptg) then aux_data.stx_pointing[0] = x_ptg
  if keyword_set(y_ptg) then aux_data.stx_pointing[1] = y_ptg
  
  ;;;;
  ; Read and process STIX L1A data
  l1a_file_list = file_search(l1a_data_folder + '*' + stix_uid + '*.fits')
  if l1a_file_list[0] eq '' then message,"Could not find any data for UID "+stix_uid $
     else path_sci_file = l1a_file_list[0]
  print, " INFO: Found L1A file "+path_sci_file

  if keyword_set(bkg_uid) then begin
    l1a_file_list = file_search(l1a_data_folder + '*' + bkg_uid + '*.fits')
    if l1a_file_list[0] eq '' then message,"Could not find any data for UID "+bkg_uid $
       else path_bkg_file = l1a_file_list[0]
  endif

  ; If not given, try to estimate the location of the source from the data
  !p.background=0
  if not keyword_set(xy_flare) then begin
    stx_estimate_flare_location, path_sci_file, time_range, aux_data, flare_loc=xy_flare, energy_range=energy_range
    print, xy_flare, format='(" *** INFO: Estimated flare location = (",F7.1,", ",F7.1,") arcsec")'
    print, xy_flare / aux_data.rsun, format='(" ... in units of solar radius = (",F6.3,", ",F6.3,")")'

    ; The coordinates given as input to the imaging pipeline have to be conceived in the STIX reference frame.
    ; Therefore, we perform a transformation from Helioprojective Cartesian to STIX reference frame with 'stx_hpc2stx_coord'
    mapcenter = stx_hpc2stx_coord(xy_flare, aux_data)
    xy_flare  = mapcenter
  endif else mapcenter = xy_flare
  
  ; Compute calibrated visibilities
  ;; vis=stix2vis_sep2021(path_sci_file, time_range, energy_range, mapcenter, aux_data, path_bkg_file=path_bkg_file, xy_flare=xy_flare)
  vis = stx_construct_calibrated_visibility(path_sci_file, time_range, energy_range, mapcenter, $
                                            path_bkg_file=path_bkg_file, xy_flare=xy_flare)

  ; Finally, generate the map using MEM_GE
  out_map = stx_mem_ge(vis,imsize,pixel,aux_data,total_flux=max(abs(vis.obsvis)), /silent)
  return, out_map
end
