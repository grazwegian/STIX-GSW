;+
; :description:
;    This function creates a vector of summed energy bin edges from a
;    look-up file to use in when combining fine energy channels. 
;
; :params:
;    fpath:  in, optional, type="string", default="$STX_CFL/summed_bins_19032024.txt"
;            full file path of look-up file for use
;
; :keywords:
;
; :returns:
;    Vector of energy edges to replace the observed finer set of bins. 
;
; :errors:
;    If a vector of indices is not created, this function returns the
;    following error codes:
;       -11 = look-up file not present,
;       -21 = empty look-up file,
;       -31 = too many subcollimator indices in look-up file.
;
; :history:
;    19-Mar-2024 - ECMD (Graz), initial version based on stx_cfl_read_mask 
;
;-
function stx_read_summed_bins, bin_file
  
  ;  Set default file path location
  bin_file = exist( bin_file ) ? bin_file : loc_file( 'summed_bins_19032024.txt', path = getenv('STX_DET') )
  ;  Return error if look-up file does not exist
  if ~file_exist( bin_file ) then return, -11 
  
  ind = stx_read_mask(bin_file)
   
   ;  Return error if look-up file contains > 32 entries
   if ( n_elements( ind ) gt 32 ) then return, -31

  ;  Pass out vector of subcollimator indices
  return, ind
  
end
