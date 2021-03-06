!
! Copyright (C) 2015-2019 M. Govoni 
! This file is distributed under the terms of the
! GNU General Public License. See the file `License'
! in the root directory of the present distribution,
! or http://www.gnu.org/copyleft/gpl.txt .
!
! This file is part of WEST. 
!
! Contributors to this file: 
! Marco Govoni
!
!-----------------------------------------------------------------------
MODULE logfile_mod
  !-----------------------------------------------------------------------
  !
  USE kinds,                ONLY : DP
  USE conversions,          ONLY : dtoa, itoa, ltoa 
  !
  IMPLICIT NONE
  !
  !
  CONTAINS
    !
    SUBROUTINE append_log(jsonText,attr)
       !
       USE westcom,    ONLY: logfile
       !
       USE forpy_mod,  ONLY: call_py, call_py_noret, import_py, module_py
       USE forpy_mod,  ONLY: tuple, tuple_create 
       USE forpy_mod,  ONLY: dict, dict_create 
       USE forpy_mod,  ONLY: list, list_create 
       USE forpy_mod,  ONLY: object, cast
       USE forpy_mod,  ONLY : exception_matches, KeyError, err_clear, err_print 
       !
       IMPLICIT NONE
       !
       CHARACTER(LEN=:),ALLOCATABLE,INTENT(IN) :: jsonText
       TYPE(dict),INTENT(IN) :: attr
       !
       INTEGER :: IERR
       TYPE(tuple) :: args
       TYPE(dict) :: kwargs
       TYPE(module_py) :: pymod
       TYPE(object) :: return_obj
       !
       IERR = import_py(pymod, "logfile")
       !  
       IERR = tuple_create(args, 2)
       IERR = args%setitem(0, logfile // ".prova" )
       IERR = args%setitem(1, jsonText )
       IERR = dict_create(kwargs)
       IERR = kwargs%setitem("attributes", attr )
       !
       IERR = call_py(return_obj, pymod, "append_xml_message", args, kwargs)
       !
       CALL args%destroy
       CALL kwargs%destroy
       CALL return_obj%destroy
       CALL pymod%destroy 
       !
    END SUBROUTINE
    !
    SUBROUTINE clear_log()
       !
       USE westcom,    ONLY: logfile
       !
       USE forpy_mod,  ONLY: call_py, call_py_noret, import_py, module_py
       USE forpy_mod,  ONLY: tuple, tuple_create 
       USE forpy_mod,  ONLY: dict, dict_create 
       USE forpy_mod,  ONLY: list, list_create 
       USE forpy_mod,  ONLY: object, cast
       USE forpy_mod,  ONLY : exception_matches, KeyError, err_clear, err_print 
       !
       IMPLICIT NONE
       !
       INTEGER :: IERR
       TYPE(tuple) :: args
       TYPE(dict) :: kwargs
       TYPE(module_py) :: pymod
       TYPE(object) :: return_obj
       !
       IERR = import_py(pymod, "logfile")
       !  
       IERR = tuple_create(args, 1)
       IERR = args%setitem(0, logfile // ".prova" )
       IERR = dict_create(kwargs)
       !
       IERR = call_py(return_obj, pymod, "clear_file", args, kwargs)
       !
       CALL args%destroy
       CALL kwargs%destroy
       CALL return_obj%destroy
       CALL pymod%destroy 
       !
    END SUBROUTINE
    !
END MODULE
