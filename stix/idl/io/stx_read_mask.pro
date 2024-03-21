;+
; :description:
;    This function creates a vector of subcollimator indices from a
;    look-up file
;
; :params:
;    fpath:  in, optional, type="string", default="$STX_CFL/stx_cfl_subc_mask.txt"
;            full file path of subcollimator mask look-up file.
;
; :keywords:
;
; :returns:
;    Vector of subcollimator indices corresponding to a list of STIX
;    subcollimators to be used in averaging over a sub-set of the 30 
;    Fourier channels (in order to determine relative flux levels in 
;    typical detector quadrants).
;
; :errors:
;    If a vector of indices is not created, this function returns the
;    following error codes:
;       -11 = look-up file not present,
;       -21 = empty look-up file,
;       -31 = too many subcollimator indices in look-up file.
;
; :history:
;    20-Jun-2013 - Shaun Bloomfield (TCD), created routine
;    11-Sep-2013 - Shaun Bloomfield (TCD), now uses environment
;                  variables for look-up file default locations
;    19-Mar-2024 - ECMD (Graz), changed stx_cfl_read_mask to the more
;                  general stx_read_mask               
;
;-
function stx_read_mask, fpath
  
  ;  Read in subcollimator indices, should contain only 1 line after 
  ;  2 header lines
  asc = rd_ascii( fpath, lines = [3] )
  ;  Return error if look-up file contains no entries
  if ( asc eq '' ) then return, -21
  
  ;  Split single string of subcollimator indices into numeric vector
  ind = str2number( strsplit( asc, ' ', /extract ) )

  ;  Pass out vector of subcollimator indices
  return, ind
  
end
