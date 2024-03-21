;---------------------------------------------------------------------------
;+
; :project:
;       STIX
;
; :name:
;       stx_date2echan_file
;
; :description:
;    This function returns the filename corresponding to the science energy channel boundaries active on STIX on a given date.
;
; :categories:
;    spectroscopy, calibration
;
; :params:
;    date : in, required, type="string"
;           The date of observation in anytim format
;
; :returns:
;    String with filename of Energy Channel csv
;
; :examples:
;    echan_filename = stx_date2echan_file('2021-04-17')
;
; :history:
;    06-Mar-2024 - ECMD (Graz), initial release based on stx_date2elut_file
;    
;-
function stx_date2echan_file, date

  elut_index = loc_file( 'science_echan_index.csv', path = getenv('STX_DET'))

  str_index = read_csv(elut_index, n_table_header = 1)

  file_index = value_locate(anytim(str_index.FIELD2), anytim(date))

  elut_filename = (str_index.FIELD4)[file_index]

  return, elut_filename
end
