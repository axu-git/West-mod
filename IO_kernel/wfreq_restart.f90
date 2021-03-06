!
! Copyright (C) 2015-2017 M. Govoni 
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
MODULE wfreq_restart
  !----------------------------------------------------------------------------
  !
  USE iotk_module
  USE kinds,                   ONLY : DP
  USE io_files,                ONLY : tmp_dir
  !
  IMPLICIT NONE
  !
  SAVE
  !
  ! BKS: band, k
  !
  TYPE :: bks_type
     INTEGER :: lastdone_ks
     INTEGER :: lastdone_band
     INTEGER :: old_ks
     INTEGER :: old_band
     INTEGER :: max_ks
     INTEGER :: max_band
     INTEGER :: min_ks
     INTEGER :: min_band
  END TYPE bks_type
  !
  ! BKSQ: band, k, q (solve_wfreq_q)
  ! 
  TYPE :: bksq_type
     INTEGER :: lastdone_q
     INTEGER :: lastdone_ks
     INTEGER :: lastdone_band
     INTEGER :: old_q
     INTEGER :: old_ks
     INTEGER :: old_band
     INTEGER :: max_q
     INTEGER :: max_ks
     INTEGER :: max_band
     INTEGER :: min_q
     INTEGER :: min_ks
     INTEGER :: min_band
  END TYPE bksq_type
  !
  ! BKSKS: band, k, k1 (solve_gfreq_q)
  !
  TYPE :: bksks_type
     INTEGER :: lastdone_ks
     INTEGER :: lastdone_kks
     INTEGER :: lastdone_band
     INTEGER :: old_ks
     INTEGER :: old_kks
     INTEGER :: old_band
     INTEGER :: max_ks
     INTEGER :: max_kks
     INTEGER :: max_band
     INTEGER :: min_ks
     INTEGER :: min_kks
     INTEGER :: min_band
  END TYPE bksks_type
  !
  INTERFACE solvewfreq_restart_write
     MODULE PROCEDURE solvewfreq_restart_write_real, solvewfreq_restart_write_complex, solvewfreq_restart_write_complex_q
  END INTERFACE 
  !
  INTERFACE solvewfreq_restart_read
     MODULE PROCEDURE solvewfreq_restart_read_real, solvewfreq_restart_read_complex, solvewfreq_restart_read_complex_q
  END INTERFACE 
  !
  CONTAINS
    !
    ! BKS
    !
    !------------------------------------------------------------------------
    SUBROUTINE write_bks(bks,dirname,fname)
      !------------------------------------------------------------------------
      !
      USE mp_global,            ONLY : my_image_id,me_bgrp,inter_image_comm,nimage,intra_bgrp_comm
      USE mp_world,             ONLY : mpime,root,world_comm,nproc
      USE io_global,            ONLY : stdout 
      USE mp,                   ONLY : mp_barrier,mp_bcast,mp_get,mp_sum
      USE io_files,             ONLY : delete_if_present
      !
      IMPLICIT NONE
      !
      ! I/O
      !
      TYPE(bks_type),INTENT(IN) :: bks
      CHARACTER(LEN=512),INTENT(IN) :: dirname, fname
      INTEGER :: iunout
      !
      ! Workspace
      !
      INTEGER :: ierr
      !
      IF ( mpime == root ) THEN
         !
         ! ... open XML descriptor
         !
         CALL iotk_free_unit( iunout, ierr )
         CALL iotk_open_write( iunout, FILE = TRIM( dirname ) // '/' // TRIM(fname) , BINARY = .FALSE., IERR = ierr )
         !
      END IF
      !
      CALL mp_bcast( ierr, root, world_comm )
      !
      CALL errore( 'wfreq_restart', 'cannot open restart file for writing', ierr )
      !
      IF ( mpime == root ) THEN  
         !
         CALL iotk_write_begin( iunout, "BKS-SUMMARY" )
         CALL iotk_write_dat( iunout, "lastdone_ks"  , bks%lastdone_ks   )
         CALL iotk_write_dat( iunout, "lastdone_band", bks%lastdone_band )
         CALL iotk_write_dat( iunout, "old_ks"       , bks%old_ks       )
         CALL iotk_write_dat( iunout, "old_band"     , bks%old_band     )
         CALL iotk_write_dat( iunout, "max_ks"       , bks%max_ks       )
         CALL iotk_write_dat( iunout, "max_band"     , bks%max_band     )
         CALL iotk_write_dat( iunout, "min_ks"       , bks%min_ks       )
         CALL iotk_write_dat( iunout, "min_band"     , bks%min_band     )
         CALL iotk_write_end( iunout, "BKS-SUMMARY"  )
         !
         CALL iotk_close_write( iunout )
         !
      END IF
      !
      CALL mp_barrier(world_comm)
      !
    END SUBROUTINE
    !
    !------------------------------------------------------------------------
    SUBROUTINE write_bksq(bksq,dirname,fname)
      !------------------------------------------------------------------------
      !
      USE mp_global,            ONLY : my_image_id,me_bgrp,inter_image_comm,nimage,intra_bgrp_comm
      USE mp_world,             ONLY : mpime,root,world_comm,nproc
      USE io_global,            ONLY : stdout 
      USE mp,                   ONLY : mp_barrier,mp_bcast,mp_get,mp_sum
      USE io_files,             ONLY : delete_if_present
      !
      IMPLICIT NONE
      !
      ! I/O
      !
      TYPE(bksq_type),INTENT(IN) :: bksq
      CHARACTER(LEN=512),INTENT(IN) :: dirname, fname
      INTEGER :: iunout
      !
      ! Workspace
      !
      INTEGER :: ierr
      !
      IF ( mpime == root ) THEN
         !
         ! ... open XML descriptor
         !
         CALL iotk_free_unit( iunout, ierr )
         CALL iotk_open_write( iunout, FILE = TRIM( dirname ) // '/' // TRIM(fname) , BINARY = .FALSE., IERR = ierr )
         !
      END IF
      !
      CALL mp_bcast( ierr, root, world_comm )
      !
      CALL errore( 'wfreq_restart', 'cannot open restart file for writing', ierr )
      !
      IF ( mpime == root ) THEN  
         !
         CALL iotk_write_begin( iunout, "BKSQ-SUMMARY" )
         CALL iotk_write_dat( iunout, "lastdone_q"   , bksq%lastdone_q   )
         CALL iotk_write_dat( iunout, "lastdone_ks"  , bksq%lastdone_ks  )
         CALL iotk_write_dat( iunout, "lastdone_band", bksq%lastdone_band)
         CALL iotk_write_dat( iunout, "old_q"        , bksq%old_q        )
         CALL iotk_write_dat( iunout, "old_ks"       , bksq%old_ks       )
         CALL iotk_write_dat( iunout, "old_band"     , bksq%old_band     )
         CALL iotk_write_dat( iunout, "max_q"        , bksq%max_q        )
         CALL iotk_write_dat( iunout, "max_ks"       , bksq%max_ks       )
         CALL iotk_write_dat( iunout, "max_band"     , bksq%max_band     )
         CALL iotk_write_dat( iunout, "min_q"        , bksq%min_q        )
         CALL iotk_write_dat( iunout, "min_ks"       , bksq%min_ks       )
         CALL iotk_write_dat( iunout, "min_band"     , bksq%min_band     )
         CALL iotk_write_end( iunout, "BKSQ-SUMMARY"  )
         !
         CALL iotk_close_write( iunout )
         !
      END IF
      !
      CALL mp_barrier(world_comm)
      !
    END SUBROUTINE
    !
    !------------------------------------------------------------------------
    SUBROUTINE write_bksks(bksks,dirname,fname)
      !------------------------------------------------------------------------
      !
      USE mp_global,            ONLY : my_image_id,me_bgrp,inter_image_comm,nimage,intra_bgrp_comm
      USE mp_world,             ONLY : mpime,root,world_comm,nproc
      USE io_global,            ONLY : stdout 
      USE mp,                   ONLY : mp_barrier,mp_bcast,mp_get,mp_sum
      USE io_files,             ONLY : delete_if_present
      !
      IMPLICIT NONE
      !
      ! I/O
      !
      TYPE(bksks_type),INTENT(IN) :: bksks
      CHARACTER(LEN=512),INTENT(IN) :: dirname, fname
      INTEGER :: iunout
      !
      ! Workspace
      !
      INTEGER :: ierr
      !
      IF ( mpime == root ) THEN
         !
         ! ... open XML descriptor
         !
         CALL iotk_free_unit( iunout, ierr )
         CALL iotk_open_write( iunout, FILE = TRIM( dirname ) // '/' // TRIM(fname) , BINARY = .FALSE., IERR = ierr )
         !
      END IF
      !
      CALL mp_bcast( ierr, root, world_comm )
      !
      CALL errore( 'wfreq_restart', 'cannot open restart file for writing', ierr )
      !
      IF ( mpime == root ) THEN  
         !
         CALL iotk_write_begin( iunout, "BKSKS-SUMMARY" )
         CALL iotk_write_dat( iunout, "lastdone_ks"  , bksks%lastdone_ks  )
         CALL iotk_write_dat( iunout, "lastdone_kks" , bksks%lastdone_kks )
         CALL iotk_write_dat( iunout, "lastdone_band", bksks%lastdone_band)
         CALL iotk_write_dat( iunout, "old_ks"       , bksks%old_ks       )
         CALL iotk_write_dat( iunout, "old_kks"      , bksks%old_kks      )
         CALL iotk_write_dat( iunout, "old_band"     , bksks%old_band     )
         CALL iotk_write_dat( iunout, "max_ks"       , bksks%max_ks       )
         CALL iotk_write_dat( iunout, "max_kks"      , bksks%max_kks      )
         CALL iotk_write_dat( iunout, "max_band"     , bksks%max_band     )
         CALL iotk_write_dat( iunout, "min_ks"       , bksks%min_ks       )
         CALL iotk_write_dat( iunout, "min_kks"      , bksks%min_kks      )
         CALL iotk_write_dat( iunout, "min_band"     , bksks%min_band     )
         CALL iotk_write_end( iunout, "BKSKS-SUMMARY"  )
         !
         CALL iotk_close_write( iunout )
         !
      END IF
      !
      CALL mp_barrier(world_comm)
      !
    END SUBROUTINE
    !
    !------------------------------------------------------------------------
    SUBROUTINE read_bks(bks,dirname,fname)
      !------------------------------------------------------------------------
      !
      USE mp_global,            ONLY : my_image_id,me_bgrp,inter_image_comm,nimage,intra_bgrp_comm
      USE mp_world,             ONLY : mpime,root,world_comm,nproc
      USE io_global,            ONLY : stdout 
      USE mp,                   ONLY : mp_barrier,mp_bcast,mp_get,mp_sum
      USE io_files,             ONLY : delete_if_present
      !
      IMPLICIT NONE
      !
      ! I/O
      !
      TYPE(bks_type),INTENT(OUT) :: bks
      CHARACTER(LEN=512),INTENT(IN) :: dirname, fname
      INTEGER :: iunout
      !
      ! Workspace
      !
      INTEGER :: ierr
      !
      IF ( mpime == root ) THEN
         !
         ! ... open XML descriptor
         !
         CALL iotk_free_unit( iunout, ierr )
         CALL iotk_open_read( iunout, FILE = TRIM( dirname ) // '/' // TRIM(fname) , BINARY = .FALSE., IERR = ierr )
         !
      END IF
      !
      CALL mp_bcast( ierr, root, world_comm )
      !
      CALL errore( 'wfreq_restart', 'cannot open restart file for reading', ierr )
      !
      IF ( mpime == root ) THEN  
         !
         CALL iotk_scan_begin( iunout, "BKS-SUMMARY" )
         CALL iotk_scan_dat( iunout, "lastdone_ks"  , bks%lastdone_ks   )
         CALL iotk_scan_dat( iunout, "lastdone_band", bks%lastdone_band )
         CALL iotk_scan_dat( iunout, "old_ks"       , bks%old_ks        )
         CALL iotk_scan_dat( iunout, "old_band"     , bks%old_band      )
         CALL iotk_scan_dat( iunout, "max_ks"       , bks%max_ks        )
         CALL iotk_scan_dat( iunout, "max_band"     , bks%max_band      )
         CALL iotk_scan_dat( iunout, "min_ks"       , bks%min_ks        )
         CALL iotk_scan_dat( iunout, "min_band"     , bks%min_band      )
         CALL iotk_scan_end( iunout, "BKS-SUMMARY"  )
         !
         CALL iotk_close_read( iunout )
         !
      END IF
      !
      CALL mp_bcast( bks%lastdone_ks   , root , world_comm )
      CALL mp_bcast( bks%lastdone_band , root , world_comm )
      CALL mp_bcast( bks%old_ks        , root , world_comm )
      CALL mp_bcast( bks%old_band      , root , world_comm )
      CALL mp_bcast( bks%max_ks        , root , world_comm )
      CALL mp_bcast( bks%max_band      , root , world_comm )
      CALL mp_bcast( bks%min_ks        , root , world_comm )
      CALL mp_bcast( bks%min_band      , root , world_comm )
      !
    END SUBROUTINE
    !
    !------------------------------------------------------------------------
    SUBROUTINE read_bksq(bksq,dirname,fname)
      !------------------------------------------------------------------------
      !
      USE mp_global,            ONLY : my_image_id,me_bgrp,inter_image_comm,nimage,intra_bgrp_comm
      USE mp_world,             ONLY : mpime,root,world_comm,nproc
      USE io_global,            ONLY : stdout 
      USE mp,                   ONLY : mp_barrier,mp_bcast,mp_get,mp_sum
      USE io_files,             ONLY : delete_if_present
      !
      IMPLICIT NONE
      !
      ! I/O
      !
      TYPE(bksq_type),INTENT(OUT) :: bksq
      CHARACTER(LEN=512),INTENT(IN) :: dirname, fname
      INTEGER :: iunout
      !
      ! Workspace
      !
      INTEGER :: ierr
      !
      IF ( mpime == root ) THEN
         !
         ! ... open XML descriptor
         !
         CALL iotk_free_unit( iunout, ierr )
         CALL iotk_open_read( iunout, FILE = TRIM( dirname ) // '/' // TRIM(fname) , BINARY = .FALSE., IERR = ierr )
         !
      END IF
      !
      CALL mp_bcast( ierr, root, world_comm )
      !
      CALL errore( 'wfreq_restart', 'cannot open restart file for reading', ierr )
      !
      IF ( mpime == root ) THEN  
         !
         CALL iotk_scan_begin( iunout, "BKSQ-SUMMARY" )
         CALL iotk_scan_dat( iunout, "lastdone_q"   , bksq%lastdone_q    )
         CALL iotk_scan_dat( iunout, "lastdone_ks"  , bksq%lastdone_ks   )
         CALL iotk_scan_dat( iunout, "lastdone_band", bksq%lastdone_band )
         CALL iotk_scan_dat( iunout, "old_q"        , bksq%old_q         )
         CALL iotk_scan_dat( iunout, "old_ks"       , bksq%old_ks        )
         CALL iotk_scan_dat( iunout, "old_band"     , bksq%old_band      )
         CALL iotk_scan_dat( iunout, "max_q"        , bksq%max_q         )
         CALL iotk_scan_dat( iunout, "max_ks"       , bksq%max_ks        )
         CALL iotk_scan_dat( iunout, "max_band"     , bksq%max_band      )
         CALL iotk_scan_dat( iunout, "min_q"        , bksq%min_q         )
         CALL iotk_scan_dat( iunout, "min_ks"       , bksq%min_ks        )
         CALL iotk_scan_dat( iunout, "min_band"     , bksq%min_band      )
         CALL iotk_scan_end( iunout, "BKSQ-SUMMARY"  )
         !
         CALL iotk_close_read( iunout )
         !
      END IF
      !
      CALL mp_bcast( bksq%lastdone_q    , root , world_comm )
      CALL mp_bcast( bksq%lastdone_ks   , root , world_comm )
      CALL mp_bcast( bksq%lastdone_band , root , world_comm )
      CALL mp_bcast( bksq%old_q         , root , world_comm )
      CALL mp_bcast( bksq%old_ks        , root , world_comm )
      CALL mp_bcast( bksq%old_band      , root , world_comm )
      CALL mp_bcast( bksq%max_q         , root , world_comm )
      CALL mp_bcast( bksq%max_ks        , root , world_comm )
      CALL mp_bcast( bksq%max_band      , root , world_comm )
      CALL mp_bcast( bksq%min_q         , root , world_comm )
      CALL mp_bcast( bksq%min_ks        , root , world_comm )
      CALL mp_bcast( bksq%min_band      , root , world_comm )
      !
    END SUBROUTINE
    !
    !------------------------------------------------------------------------
    SUBROUTINE read_bksks(bksks,dirname,fname)
      !------------------------------------------------------------------------
      !
      USE mp_global,            ONLY : my_image_id,me_bgrp,inter_image_comm,nimage,intra_bgrp_comm
      USE mp_world,             ONLY : mpime,root,world_comm,nproc
      USE io_global,            ONLY : stdout 
      USE mp,                   ONLY : mp_barrier,mp_bcast,mp_get,mp_sum
      USE io_files,             ONLY : delete_if_present
      !
      IMPLICIT NONE
      !
      ! I/O
      !
      TYPE(bksks_type),INTENT(OUT) :: bksks
      CHARACTER(LEN=512),INTENT(IN) :: dirname, fname
      INTEGER :: iunout
      !
      ! Workspace
      !
      INTEGER :: ierr
      !
      IF ( mpime == root ) THEN
         !
         ! ... open XML descriptor
         !
         CALL iotk_free_unit( iunout, ierr )
         CALL iotk_open_read( iunout, FILE = TRIM( dirname ) // '/' // TRIM(fname) , BINARY = .FALSE., IERR = ierr )
         !
      END IF
      !
      CALL mp_bcast( ierr, root, world_comm )
      !
      CALL errore( 'wfreq_restart', 'cannot open restart file for reading', ierr )
      !
      IF ( mpime == root ) THEN  
         !
         CALL iotk_scan_begin( iunout, "BKSKS-SUMMARY" )
         CALL iotk_scan_dat( iunout, "lastdone_ks"  , bksks%lastdone_ks   )
         CALL iotk_scan_dat( iunout, "lastdone_kks" , bksks%lastdone_kks  )
         CALL iotk_scan_dat( iunout, "lastdone_band", bksks%lastdone_band )
         CALL iotk_scan_dat( iunout, "old_ks"       , bksks%old_ks        )
         CALL iotk_scan_dat( iunout, "old_kks"      , bksks%old_kks       )
         CALL iotk_scan_dat( iunout, "old_band"     , bksks%old_band      )
         CALL iotk_scan_dat( iunout, "max_ks"       , bksks%max_ks        )
         CALL iotk_scan_dat( iunout, "max_kks"      , bksks%max_kks       )
         CALL iotk_scan_dat( iunout, "max_band"     , bksks%max_band      )
         CALL iotk_scan_dat( iunout, "min_ks"       , bksks%min_ks        )
         CALL iotk_scan_dat( iunout, "min_kks"      , bksks%min_kks       )
         CALL iotk_scan_dat( iunout, "min_band"     , bksks%min_band      )
         CALL iotk_scan_end( iunout, "BKSKS-SUMMARY"  )
         !
         CALL iotk_close_read( iunout )
         !
      END IF
      !
      CALL mp_bcast( bksks%lastdone_ks   , root , world_comm )
      CALL mp_bcast( bksks%lastdone_kks  , root , world_comm )
      CALL mp_bcast( bksks%lastdone_band , root , world_comm )
      CALL mp_bcast( bksks%old_ks        , root , world_comm )
      CALL mp_bcast( bksks%old_kks       , root , world_comm )
      CALL mp_bcast( bksks%old_band      , root , world_comm )
      CALL mp_bcast( bksks%max_ks        , root , world_comm )
      CALL mp_bcast( bksks%max_kks       , root , world_comm )
      CALL mp_bcast( bksks%max_band      , root , world_comm )
      CALL mp_bcast( bksks%min_ks        , root , world_comm )
      CALL mp_bcast( bksks%min_kks       , root , world_comm )
      CALL mp_bcast( bksks%min_band      , root , world_comm )
      !
    END SUBROUTINE
    !
    !------------------------------------------------------------------------
    SUBROUTINE clear_bks(dirname,fname)
      !------------------------------------------------------------------------
      !
      USE mp_global,            ONLY : my_image_id,me_bgrp,inter_image_comm,nimage,intra_bgrp_comm
      USE mp_world,             ONLY : mpime,root,world_comm,nproc
      USE io_global,            ONLY : stdout 
      USE mp,                   ONLY : mp_barrier,mp_bcast,mp_get,mp_sum
      USE io_files,             ONLY : delete_if_present
      !
      IMPLICIT NONE
      !
      ! I/O
      !
      CHARACTER(LEN=512),INTENT(IN) :: dirname, fname
      !
      ! Workspace
      !
      INTEGER :: ierr
      !
      IF ( mpime == root ) THEN
         !
         CALL delete_if_present( TRIM( dirname ) // '/' // TRIM(fname) ) 
         !
      END IF
      !
      CALL mp_barrier( world_comm )
      !
    END SUBROUTINE
    !
    !
    ! SOLVEWFREQ
    !
    !------------------------------------------------------------------------
    SUBROUTINE solvewfreq_restart_write_real(bks,dmat,zmat,npg,npl)
      !------------------------------------------------------------------------
      !
      USE mp_global,            ONLY : my_image_id,me_bgrp,inter_image_comm,nimage,intra_bgrp_comm
      USE mp_world,             ONLY : mpime,root,world_comm,nproc
      USE io_global,            ONLY : stdout 
      USE westcom,              ONLY : west_prefix
      USE mp,                   ONLY : mp_barrier,mp_bcast,mp_get,mp_sum
      USE io_files,             ONLY : delete_if_present
      USE distribution_center,  ONLY : ifr,rfr
      USE west_io,              ONLY : serial_data_write 
      !
      IMPLICIT NONE
      !
      ! I/O
      !
      TYPE(bks_type),INTENT(IN) :: bks
      INTEGER, INTENT(IN) :: npg, npl
      REAL(DP), INTENT(IN) :: dmat(npg,npl,ifr%nloc)
      COMPLEX(DP), INTENT(IN) :: zmat(npg,npl,rfr%nloc)
      !
      ! Workspace
      !
      INTEGER :: ierr
      CHARACTER(LEN=512) :: dirname,fname
      CHARACTER(29) :: my_label
      CHARACTER(33) :: my_label2
      INTEGER :: local_j,global_j
      INTEGER :: ip, ip_glob
      REAL(DP),ALLOCATABLE :: tmp_dmat(:,:,:) 
      COMPLEX(DP),ALLOCATABLE :: tmp_zmat(:,:,:) 
      LOGICAL :: lproc
      INTEGER :: iunit
      !
      ! BARRIER
      !
      CALL mp_barrier(world_comm)
      CALL start_clock('sw_restart')
      !
      ! MKDIR 
      !
      dirname = TRIM( tmp_dir ) // TRIM( west_prefix ) // '.wfreq.restart'
      CALL my_mkdir( dirname )
      !  
      ! DMAT
      !
      ALLOCATE( tmp_dmat( npg, npl, ifr%nglob ))
      tmp_dmat = 0._DP
      DO ip = 1, ifr%nloc
         ip_glob = ifr%l2g(ip)
         tmp_dmat(:,:,ip_glob) = dmat(:,:,ip)
      ENDDO
      CALL mp_sum( tmp_dmat, intra_bgrp_comm ) 
      !
      WRITE(my_label,'("dmat_iks",i5.5,"_iv",i5.5,"_I",i6.6)') bks%lastdone_ks, bks%lastdone_band, my_image_id
      fname=TRIM( dirname ) // '/' // TRIM(my_label)
      iunit = 2000 + my_image_id
      lproc = (me_bgrp == 0)
      CALL serial_data_write(lproc,iunit,fname,tmp_dmat,npg,npl,ifr%nglob)
      !
      DEALLOCATE(tmp_dmat)
      !
      ! ZMAT
      !
      ALLOCATE( tmp_zmat( npg, npl, rfr%nglob ))
      tmp_zmat = 0._DP
      DO ip = 1, rfr%nloc
         ip_glob = rfr%l2g(ip)
         tmp_zmat(:,:,ip_glob) = zmat(:,:,ip)
      ENDDO
      CALL mp_sum( tmp_zmat, intra_bgrp_comm ) 
      !   
      WRITE(my_label,'("zmat_iks",i5.5,"_iv",i5.5,"_I",i6.6)') bks%lastdone_ks, bks%lastdone_band, my_image_id
      fname=TRIM( dirname ) // '/' // TRIM(my_label)
      iunit = 2000 + my_image_id
      lproc = (me_bgrp == 0)
      CALL serial_data_write(lproc,iunit,fname,tmp_zmat,npg,npl,rfr%nglob)
      !
      DEALLOCATE(tmp_zmat)
      !
      ! CLEAR
      !
      IF(bks%old_ks/=0.AND.bks%old_band/=0) THEN
         IF( me_bgrp == 0 ) THEN
            WRITE(my_label2,'("dmat_iks",i5.5,"_iv",i5.5,"_I",i6.6,".raw")') &
            & bks%old_ks, bks%old_band, my_image_id
            fname=TRIM(my_label2)
            CALL delete_if_present( TRIM( dirname ) // '/' // TRIM( fname ) )
            WRITE(my_label2,'("zmat_iks",i5.5,"_iv",i5.5,"_I",i6.6,".raw")') & 
            & bks%old_ks, bks%old_band, my_image_id
            fname=TRIM(my_label2)
            CALL delete_if_present( TRIM( dirname ) // '/' // TRIM( fname ) )
         ENDIF
      ENDIF
      !
      ! CREATE THE SUMMARY FILE
      !
      fname = "summary_w.xml"
      CALL write_bks( bks, dirname, fname ) 
      !
      CALL stop_clock('sw_restart')
      !
    END SUBROUTINE
    !
    !------------------------------------------------------------------------
    SUBROUTINE solvewfreq_restart_write_complex(bks,dmat,zmat,npg,npl)
      !------------------------------------------------------------------------
      !
      USE mp_global,            ONLY : my_image_id,me_bgrp,inter_image_comm,nimage,intra_bgrp_comm
      USE mp_world,             ONLY : mpime,root,world_comm,nproc
      USE io_global,            ONLY : stdout 
      USE westcom,              ONLY : west_prefix
      USE mp,                   ONLY : mp_barrier,mp_bcast,mp_get,mp_sum
      USE io_files,             ONLY : delete_if_present
      USE distribution_center,  ONLY : ifr,rfr
      USE west_io,              ONLY : serial_data_write 
      !
      IMPLICIT NONE
      !
      ! I/O
      !
      TYPE(bks_type),INTENT(IN) :: bks
      INTEGER, INTENT(IN) :: npg, npl
      COMPLEX(DP), INTENT(IN) :: dmat(npg,npl,ifr%nloc)
      COMPLEX(DP), INTENT(IN) :: zmat(npg,npl,rfr%nloc)
      !
      ! Workspace
      !
      INTEGER :: ierr
      CHARACTER(LEN=512) :: dirname,fname
      CHARACTER(29) :: my_label
      CHARACTER(33) :: my_label2
      INTEGER :: local_j,global_j
      INTEGER :: ip, ip_glob
      COMPLEX(DP),ALLOCATABLE :: tmp_dmat(:,:,:) 
      COMPLEX(DP),ALLOCATABLE :: tmp_zmat(:,:,:) 
      LOGICAL :: lproc
      INTEGER :: iunit
      !
      ! BARRIER
      !
      CALL mp_barrier(world_comm)
      CALL start_clock('sw_restart')
      !
      ! MKDIR 
      !
      dirname = TRIM( tmp_dir ) // TRIM( west_prefix ) // '.wfreq.restart'
      CALL my_mkdir( dirname )
      !  
      ! DMAT
      !
      ALLOCATE( tmp_dmat( npg, npl, ifr%nglob ))
      tmp_dmat = 0._DP
      DO ip = 1, ifr%nloc
         ip_glob = ifr%l2g(ip)
         tmp_dmat(:,:,ip_glob) = dmat(:,:,ip)
      ENDDO
      CALL mp_sum( tmp_dmat, intra_bgrp_comm ) 
      !
      WRITE(my_label,'("dmat_iks",i5.5,"_iv",i5.5,"_I",i6.6)') bks%lastdone_ks, bks%lastdone_band, my_image_id
      fname=TRIM( dirname ) // '/' // TRIM(my_label)
      iunit = 2000 + my_image_id
      lproc = (me_bgrp == 0)
      CALL serial_data_write(lproc,iunit,fname,tmp_dmat,npg,npl,ifr%nglob)
      !
      DEALLOCATE(tmp_dmat)
      !
      ! ZMAT
      !
      ALLOCATE( tmp_zmat( npg, npl, rfr%nglob ))
      tmp_zmat = 0._DP
      DO ip = 1, rfr%nloc
         ip_glob = rfr%l2g(ip)
         tmp_zmat(:,:,ip_glob) = zmat(:,:,ip)
      ENDDO
      CALL mp_sum( tmp_zmat, intra_bgrp_comm ) 
      !   
      WRITE(my_label,'("zmat_iks",i5.5,"_iv",i5.5,"_I",i6.6)') bks%lastdone_ks, bks%lastdone_band, my_image_id
      fname=TRIM( dirname ) // '/' // TRIM(my_label)
      iunit = 2000 + my_image_id
      lproc = (me_bgrp == 0)
      CALL serial_data_write(lproc,iunit,fname,tmp_zmat,npg,npl,rfr%nglob)
      !
      DEALLOCATE(tmp_zmat)
      !
      ! CLEAR
      !
      IF(bks%old_ks/=0.AND.bks%old_band/=0) THEN
         IF( me_bgrp == 0 ) THEN
            WRITE(my_label2,'("dmat_iks",i5.5,"_iv",i5.5,"_I",i6.6,".raw")') &
            & bks%old_ks, bks%old_band, my_image_id
            fname=TRIM(my_label2)
            CALL delete_if_present( TRIM( dirname ) // '/' // TRIM( fname ) )
            WRITE(my_label2,'("zmat_iks",i5.5,"_iv",i5.5,"_I",i6.6,".raw")') & 
            & bks%old_ks, bks%old_band, my_image_id
            fname=TRIM(my_label2)
            CALL delete_if_present( TRIM( dirname ) // '/' // TRIM( fname ) )
         ENDIF
      ENDIF
      !
      ! CREATE THE SUMMARY FILE
      !
      fname = "summary_w.xml"
      CALL write_bks( bks, dirname, fname ) 
      !
      CALL stop_clock('sw_restart')
      !
    END SUBROUTINE
    !
    !------------------------------------------------------------------------
    SUBROUTINE solvewfreq_restart_write_complex_q(bksq,dmat,zmat,npg,npl)
      !------------------------------------------------------------------------
      !
      USE mp_global,            ONLY : my_image_id,me_bgrp,inter_image_comm,nimage,intra_bgrp_comm
      USE mp_world,             ONLY : mpime,root,world_comm,nproc
      USE io_global,            ONLY : stdout 
      USE westcom,              ONLY : west_prefix
      USE mp,                   ONLY : mp_barrier,mp_bcast,mp_get,mp_sum
      USE io_files,             ONLY : delete_if_present
      USE distribution_center,  ONLY : ifr,rfr
      USE west_io,              ONLY : serial_data_write 
      USE types_bz_grid,        ONLY : q_grid
      !
      IMPLICIT NONE
      !
      ! I/O
      !
      TYPE(bksq_type),INTENT(IN) :: bksq
      INTEGER, INTENT(IN) :: npg, npl
      COMPLEX(DP), INTENT(IN) :: dmat(npg,npl,ifr%nloc,q_grid%np)
      COMPLEX(DP), INTENT(IN) :: zmat(npg,npl,rfr%nloc,q_grid%np)
      !
      ! Workspace
      !
      INTEGER :: ierr
      CHARACTER(LEN=512) :: dirname,fname
      CHARACTER(37) :: my_label
      CHARACTER(41) :: my_label2
      INTEGER :: local_j,global_j
      INTEGER :: ip, ip_glob, iq
      COMPLEX(DP),ALLOCATABLE :: tmp_dmat(:,:,:,:) 
      COMPLEX(DP),ALLOCATABLE :: tmp_zmat(:,:,:,:) 
      LOGICAL :: lproc
      INTEGER :: iunit
      !
      ! BARRIER
      !
      CALL mp_barrier(world_comm)
      CALL start_clock('sw_restart')
      !
      ! MKDIR 
      !
      dirname = TRIM( tmp_dir ) // TRIM( west_prefix ) // '.wfreq.restart'
      CALL my_mkdir( dirname )
      !  
      ! DMAT
      !
      ALLOCATE( tmp_dmat( npg, npl, ifr%nglob, q_grid%np ))
      tmp_dmat = 0._DP
      DO iq = 1, q_grid%np
         DO ip = 1, ifr%nloc
            ip_glob = ifr%l2g(ip)
            tmp_dmat(:,:,ip_glob,iq) = dmat(:,:,ip,iq)
         ENDDO
      ENDDO
      CALL mp_sum( tmp_dmat, intra_bgrp_comm ) 
      !
      WRITE(my_label,'("dmat_iq",i5.5,"_iks",i5.5,"_iv",i5.5,"_I",i6.6)') bksq%lastdone_q,bksq%lastdone_ks,bksq%lastdone_band,&
                                                                          & my_image_id
      fname=TRIM( dirname ) // '/' // TRIM(my_label)
      iunit = 2000 + my_image_id
      lproc = (me_bgrp == 0)
      CALL serial_data_write(lproc,iunit,fname,tmp_dmat,npg,npl,ifr%nglob,q_grid%np)
      !
      DEALLOCATE(tmp_dmat)
      !
      ! ZMAT
      !
      ALLOCATE( tmp_zmat( npg, npl, rfr%nglob, q_grid%np ))
      tmp_zmat = 0._DP
      DO iq = 1, q_grid%np
         DO ip = 1, rfr%nloc
            ip_glob = rfr%l2g(ip)
            tmp_zmat(:,:,ip_glob,iq) = zmat(:,:,ip,iq)
         ENDDO
      ENDDO
      CALL mp_sum( tmp_zmat, intra_bgrp_comm ) 
      !   
      WRITE(my_label,'("zmat_iq",i5.5,"_iks",i5.5,"_iv",i5.5,"_I",i6.6)') bksq%lastdone_q,bksq%lastdone_ks,bksq%lastdone_band,&
                                                                          & my_image_id
      fname=TRIM( dirname ) // '/' // TRIM(my_label)
      iunit = 2000 + my_image_id
      lproc = (me_bgrp == 0)
      CALL serial_data_write(lproc,iunit,fname,tmp_zmat,npg,npl,rfr%nglob,q_grid%np)
      !
      DEALLOCATE(tmp_zmat)
      !
      ! CLEAR
      !
      IF(bksq%old_q/=0.AND.bksq%old_ks/=0.AND.bksq%old_band/=0) THEN
         IF( me_bgrp == 0 ) THEN
            WRITE(my_label2,'("dmat_iq",i5.5,"_iks",i5.5,"_iv",i5.5,"_I",i6.6,".raw")') &
            & bksq%old_q, bksq%old_ks, bksq%old_band, my_image_id
            fname=TRIM(my_label2)
            CALL delete_if_present( TRIM( dirname ) // '/' // TRIM( fname ) )
            WRITE(my_label2,'("zmat_iq",i5.5,"_iks",i5.5,"_iv",i5.5,"_I",i6.6,".raw")') & 
            & bksq%old_q, bksq%old_ks, bksq%old_band, my_image_id
            fname=TRIM(my_label2)
            CALL delete_if_present( TRIM( dirname ) // '/' // TRIM( fname ) )
         ENDIF
      ENDIF
      !
      ! CREATE THE SUMMARY FILE
      !
      fname = "summary_w.xml"
      CALL write_bksq ( bksq, dirname, fname ) 
      !
      CALL stop_clock('sw_restart')
      !
    END SUBROUTINE
    !
    !
    !
    !
    !
    !------------------------------------------------------------------------
    SUBROUTINE solvewfreq_restart_read_real( bks, dmat, zmat, npg, npl )
      !------------------------------------------------------------------------
      !
      USE mp_global,            ONLY : my_image_id,me_bgrp,inter_image_comm,nimage,intra_bgrp_comm
      USE mp_world,             ONLY : mpime,root,world_comm
      USE io_global,            ONLY : stdout 
      USE westcom,              ONLY : west_prefix
      USE mp,                   ONLY : mp_barrier,mp_bcast,mp_get
      USE distribution_center,  ONLY : ifr,rfr
      USE west_io,              ONLY : serial_data_read 
      !
      IMPLICIT NONE
      !
      ! I/O
      !
      TYPE(bks_type), INTENT(OUT) :: bks
      INTEGER, INTENT(IN) :: npg, npl
      REAL(DP), INTENT(OUT) :: dmat(npg,npl,ifr%nloc)
      COMPLEX(DP), INTENT(OUT) :: zmat(npg,npl,rfr%nloc)
      !
      ! Workspace
      !
      INTEGER :: ierr
      CHARACTER(LEN=512) :: dirname,fname
      REAL(DP), EXTERNAL :: GET_CLOCK
      REAL(DP) :: time_spent(2)
      CHARACTER(20),EXTERNAL :: human_readable_time
      CHARACTER(29) :: my_label
      INTEGER :: local_j,global_j
      INTEGER :: ip,ip_glob
      REAL(DP),ALLOCATABLE :: tmp_dmat(:,:,:)
      COMPLEX(DP),ALLOCATABLE :: tmp_zmat(:,:,:)
      LOGICAL :: lproc
      INTEGER :: iunit
      !
      ! BARRIER
      !
      CALL mp_barrier(world_comm)
      !
      ! MKDIR 
      !
      dirname = TRIM( tmp_dir ) // TRIM( west_prefix ) // '.wfreq.restart'
      CALL my_mkdir( dirname )
      !
      CALL start_clock('sw_restart')
      time_spent(1)=get_clock('sw_restart')
      !
      ! CREATE THE SUMMARY FILE
      !
      fname = "summary_w.xml"
      CALL read_bks( bks, dirname, fname )
      !
      ! READ
      !
      ALLOCATE( tmp_dmat( npg, npl, ifr%nglob ))
      !
      WRITE(my_label,'("dmat_iks",i5.5,"_iv",i5.5,"_I",i6.6)') bks%lastdone_ks, bks%lastdone_band, my_image_id
      fname=TRIM( dirname ) // '/' // TRIM(my_label) 
      lproc = (me_bgrp==0) 
      iunit = 2000 + my_image_id
      CALL serial_data_read(lproc,iunit,fname,tmp_dmat,npg,npl,ifr%nglob)
      !
      CALL mp_bcast( tmp_dmat, 0, intra_bgrp_comm)
      DO ip = 1, ifr%nloc
         ip_glob = ifr%l2g(ip)
         dmat(:,:,ip) = tmp_dmat(:,:,ip_glob)
      ENDDO
      DEALLOCATE(tmp_dmat)
      !
      ALLOCATE( tmp_zmat( npg, npl, rfr%nglob ))
      !
      WRITE(my_label,'("zmat_iks",i5.5,"_iv",i5.5,"_I",i6.6)') bks%lastdone_ks, bks%lastdone_band, my_image_id
      fname=TRIM( dirname ) // '/' // TRIM(my_label) 
      lproc = (me_bgrp==0) 
      iunit = 2000 + my_image_id
      CALL serial_data_read(lproc,iunit,fname,tmp_zmat,npg,npl,rfr%nglob)
      !
      CALL mp_bcast( tmp_zmat, 0, intra_bgrp_comm)
      DO ip = 1, rfr%nloc
         ip_glob = rfr%l2g(ip)
         zmat(:,:,ip) = tmp_zmat(:,:,ip_glob)
      ENDDO
      DEALLOCATE(tmp_zmat)
      !
      ! BARRIER
      !
      CALL mp_barrier(world_comm)
      time_spent(2)=get_clock('sw_restart')
      CALL stop_clock('sw_restart')
      !
      WRITE(stdout,'(1/, 5x,"[I/O] -------------------------------------------------------")')
      WRITE(stdout, "(5x, '[I/O] RESTART read in ',a20)") human_readable_time(time_spent(2)-time_spent(1)) 
      WRITE(stdout, "(5x, '[I/O] In location : ',a)") TRIM( dirname )  
      WRITE(stdout,'(5x,"[I/O] -------------------------------------------------------")')
      !
    END SUBROUTINE
    !
    !------------------------------------------------------------------------
    SUBROUTINE solvewfreq_restart_read_complex( bks, dmat, zmat, npg, npl )
      !------------------------------------------------------------------------
      !
      USE mp_global,            ONLY : my_image_id,me_bgrp,inter_image_comm,nimage,intra_bgrp_comm
      USE mp_world,             ONLY : mpime,root,world_comm
      USE io_global,            ONLY : stdout 
      USE westcom,              ONLY : west_prefix
      USE mp,                   ONLY : mp_barrier,mp_bcast,mp_get
      USE distribution_center,  ONLY : ifr,rfr
      USE west_io,              ONLY : serial_data_read 
      !
      IMPLICIT NONE
      !
      ! I/O
      !
      TYPE(bks_type), INTENT(OUT) :: bks
      INTEGER, INTENT(IN) :: npg, npl
      COMPLEX(DP), INTENT(OUT) :: dmat(npg,npl,ifr%nloc)
      COMPLEX(DP), INTENT(OUT) :: zmat(npg,npl,rfr%nloc)
      !
      ! Workspace
      !
      INTEGER :: ierr
      CHARACTER(LEN=512) :: dirname,fname
      REAL(DP), EXTERNAL :: GET_CLOCK
      REAL(DP) :: time_spent(2)
      CHARACTER(20),EXTERNAL :: human_readable_time
      CHARACTER(29) :: my_label
      INTEGER :: local_j,global_j
      INTEGER :: ip,ip_glob
      COMPLEX(DP),ALLOCATABLE :: tmp_dmat(:,:,:)
      COMPLEX(DP),ALLOCATABLE :: tmp_zmat(:,:,:)
      LOGICAL :: lproc
      INTEGER :: iunit
      !
      ! BARRIER
      !
      CALL mp_barrier(world_comm)
      !
      ! MKDIR 
      !
      dirname = TRIM( tmp_dir ) // TRIM( west_prefix ) // '.wfreq.restart'
      CALL my_mkdir( dirname )
      !
      CALL start_clock('sw_restart')
      time_spent(1)=get_clock('sw_restart')
      !
      ! CREATE THE SUMMARY FILE
      !
      fname = "summary_w.xml"
      CALL read_bks( bks, dirname, fname )
      !
      ! READ
      !
      ALLOCATE( tmp_dmat( npg, npl, ifr%nglob ))
      !
      WRITE(my_label,'("dmat_iks",i5.5,"_iv",i5.5,"_I",i6.6)') bks%lastdone_ks, bks%lastdone_band, my_image_id
      fname=TRIM( dirname ) // '/' // TRIM(my_label) 
      lproc = (me_bgrp==0) 
      iunit = 2000 + my_image_id
      CALL serial_data_read(lproc,iunit,fname,tmp_dmat,npg,npl,ifr%nglob)
      !
      CALL mp_bcast( tmp_dmat, 0, intra_bgrp_comm)
      DO ip = 1, ifr%nloc
         ip_glob = ifr%l2g(ip)
         dmat(:,:,ip) = tmp_dmat(:,:,ip_glob)
      ENDDO
      DEALLOCATE(tmp_dmat)
      !
      ALLOCATE( tmp_zmat( npg, npl, rfr%nglob ))
      !
      WRITE(my_label,'("zmat_iks",i5.5,"_iv",i5.5,"_I",i6.6)') bks%lastdone_ks, bks%lastdone_band, my_image_id
      fname=TRIM( dirname ) // '/' // TRIM(my_label) 
      lproc = (me_bgrp==0) 
      iunit = 2000 + my_image_id
      CALL serial_data_read(lproc,iunit,fname,tmp_zmat,npg,npl,rfr%nglob)
      !
      CALL mp_bcast( tmp_zmat, 0, intra_bgrp_comm)
      DO ip = 1, rfr%nloc
         ip_glob = rfr%l2g(ip)
         zmat(:,:,ip) = tmp_zmat(:,:,ip_glob)
      ENDDO
      DEALLOCATE(tmp_zmat)
      !
      ! BARRIER
      !
      CALL mp_barrier(world_comm)
      time_spent(2)=get_clock('sw_restart')
      CALL stop_clock('sw_restart')
      !
      WRITE(stdout,'(1/, 5x,"[I/O] -------------------------------------------------------")')
      WRITE(stdout, "(5x, '[I/O] RESTART read in ',a20)") human_readable_time(time_spent(2)-time_spent(1)) 
      WRITE(stdout, "(5x, '[I/O] In location : ',a)") TRIM( dirname )  
      WRITE(stdout,'(5x,"[I/O] -------------------------------------------------------")')
      !
    END SUBROUTINE
    !
    !------------------------------------------------------------------------
    SUBROUTINE solvewfreq_restart_read_complex_q( bksq, dmat, zmat, npg, npl )
      !------------------------------------------------------------------------
      !
      USE mp_global,            ONLY : my_image_id,me_bgrp,inter_image_comm,nimage,intra_bgrp_comm
      USE mp_world,             ONLY : mpime,root,world_comm
      USE io_global,            ONLY : stdout 
      USE westcom,              ONLY : west_prefix
      USE mp,                   ONLY : mp_barrier,mp_bcast,mp_get
      USE distribution_center,  ONLY : ifr,rfr
      USE west_io,              ONLY : serial_data_read 
      USE types_bz_grid,        ONLY : q_grid
      !
      IMPLICIT NONE
      !
      ! I/O
      !
      TYPE(bksq_type), INTENT(OUT) :: bksq
      INTEGER, INTENT(IN) :: npg, npl
      COMPLEX(DP), INTENT(OUT) :: dmat(npg,npl,ifr%nloc,q_grid%np)
      COMPLEX(DP), INTENT(OUT) :: zmat(npg,npl,rfr%nloc,q_grid%np)
      !
      ! Workspace
      !
      INTEGER :: ierr
      CHARACTER(LEN=512) :: dirname,fname
      REAL(DP), EXTERNAL :: GET_CLOCK
      REAL(DP) :: time_spent(2)
      CHARACTER(20),EXTERNAL :: human_readable_time
      CHARACTER(37) :: my_label
      INTEGER :: local_j,global_j
      INTEGER :: ip,ip_glob,iq
      COMPLEX(DP),ALLOCATABLE :: tmp_dmat(:,:,:,:)
      COMPLEX(DP),ALLOCATABLE :: tmp_zmat(:,:,:,:)
      LOGICAL :: lproc
      INTEGER :: iunit
      !
      ! BARRIER
      !
      CALL mp_barrier(world_comm)
      !
      ! MKDIR 
      !
      dirname = TRIM( tmp_dir ) // TRIM( west_prefix ) // '.wfreq.restart'
      CALL my_mkdir( dirname )
      !
      CALL start_clock('sw_restart')
      time_spent(1)=get_clock('sw_restart')
      !
      ! CREATE THE SUMMARY FILE
      !
      fname = "summary_w.xml"
      CALL read_bksq( bksq, dirname, fname )
      !
      ! READ
      !
      ALLOCATE( tmp_dmat( npg, npl, ifr%nglob, q_grid%np ))
      !
      WRITE(my_label,'("dmat_iq",i5.5,"_iks",i5.5,"_iv",i5.5,"_I",i6.6)') bksq%lastdone_q,bksq%lastdone_ks,bksq%lastdone_band,&
                                                                          & my_image_id
      fname=TRIM( dirname ) // '/' // TRIM(my_label) 
      lproc = (me_bgrp==0) 
      iunit = 2000 + my_image_id
      CALL serial_data_read(lproc,iunit,fname,tmp_dmat,npg,npl,ifr%nglob,q_grid%np)
      !
      CALL mp_bcast( tmp_dmat, 0, intra_bgrp_comm)
      DO iq = 1, q_grid%np
         DO ip = 1, ifr%nloc
            ip_glob = ifr%l2g(ip)
            dmat(:,:,ip,iq) = tmp_dmat(:,:,ip_glob,iq)
         ENDDO
      ENDDO
      DEALLOCATE(tmp_dmat)
      !
      ALLOCATE( tmp_zmat( npg, npl, rfr%nglob, q_grid%np ))
      !
      WRITE(my_label,'("zmat_iq",i5.5,"_iks",i5.5,"_iv",i5.5,"_I",i6.6)') bksq%lastdone_q,bksq%lastdone_ks,bksq%lastdone_band,&
                                                                          & my_image_id
      fname=TRIM( dirname ) // '/' // TRIM(my_label) 
      lproc = (me_bgrp==0) 
      iunit = 2000 + my_image_id
      CALL serial_data_read(lproc,iunit,fname,tmp_zmat,npg,npl,rfr%nglob,q_grid%np)
      !
      CALL mp_bcast( tmp_zmat, 0, intra_bgrp_comm)
      DO iq = 1, q_grid%np
         DO ip = 1, rfr%nloc
            ip_glob = rfr%l2g(ip)
            zmat(:,:,ip,iq) = tmp_zmat(:,:,ip_glob,iq)
         ENDDO
      ENDDO
      DEALLOCATE(tmp_zmat)
      !
      ! BARRIER
      !
      CALL mp_barrier(world_comm)
      time_spent(2)=get_clock('sw_restart')
      CALL stop_clock('sw_restart')
      !
      WRITE(stdout,'(1/, 5x,"[I/O] -------------------------------------------------------")')
      WRITE(stdout, "(5x, '[I/O] RESTART read in ',a20)") human_readable_time(time_spent(2)-time_spent(1)) 
      WRITE(stdout, "(5x, '[I/O] In location : ',a)") TRIM( dirname )  
      WRITE(stdout,'(5x,"[I/O] -------------------------------------------------------")')
      !
    END SUBROUTINE
    !
    !
    ! GFREQ
    !
    !------------------------------------------------------------------------
    SUBROUTINE solvegfreq_restart_write( bks )
      !------------------------------------------------------------------------
      !
      USE mp_global,            ONLY : my_image_id,me_bgrp,inter_image_comm,nimage
      USE mp_world,             ONLY : mpime,root,world_comm,nproc
      USE io_global,            ONLY : stdout 
      USE westcom,              ONLY : west_prefix
      USE mp,                   ONLY : mp_barrier,mp_bcast,mp_get
      USE io_files,             ONLY : delete_if_present
      !
      IMPLICIT NONE
      !
      ! I/O
      !
      TYPE(bks_type), INTENT(IN) :: bks
      !
      ! Workspace
      !
      INTEGER :: ierr
      CHARACTER(LEN=512) :: dirname,fname
      REAL(DP), EXTERNAL :: GET_CLOCK
      REAL(DP) :: time_spent(2)
      CHARACTER(20),EXTERNAL :: human_readable_time
      !
      ! BARRIER
      !
      CALL mp_barrier(world_comm)
      !
      ! MKDIR 
      !
      dirname = TRIM( tmp_dir ) // TRIM( west_prefix ) // '.wfreq.restart'
      CALL my_mkdir( dirname )
      !
      CALL start_clock('sg_restart')
      !
      fname = "summary_g.xml"
      CALL write_bks( bks, dirname, fname )
      !
      CALL stop_clock('sg_restart')
      !
    END SUBROUTINE
    !
    !------------------------------------------------------------------------
    SUBROUTINE solvegfreq_restart_write_q( bksks )
      !------------------------------------------------------------------------
      !
      USE mp_global,            ONLY : my_image_id,me_bgrp,inter_image_comm,nimage
      USE mp_world,             ONLY : mpime,root,world_comm,nproc
      USE io_global,            ONLY : stdout 
      USE westcom,              ONLY : west_prefix
      USE mp,                   ONLY : mp_barrier,mp_bcast,mp_get
      USE io_files,             ONLY : delete_if_present
      !
      IMPLICIT NONE
      !
      ! I/O
      !
      TYPE(bksks_type), INTENT(IN) :: bksks
      !
      ! Workspace
      !
      INTEGER :: ierr
      CHARACTER(LEN=512) :: dirname,fname
      REAL(DP), EXTERNAL :: GET_CLOCK
      REAL(DP) :: time_spent(2)
      CHARACTER(20),EXTERNAL :: human_readable_time
      !
      ! BARRIER
      !
      CALL mp_barrier(world_comm)
      !
      ! MKDIR 
      !
      dirname = TRIM( tmp_dir ) // TRIM( west_prefix ) // '.wfreq.restart'
      CALL my_mkdir( dirname )
      !
      CALL start_clock('sg_restart')
      !
      fname = "summary_g.xml"
      CALL write_bksks( bksks, dirname, fname )
      !
      CALL stop_clock('sg_restart')
      !
    END SUBROUTINE
    !
    !
    !------------------------------------------------------------------------
    SUBROUTINE solvegfreq_restart_read( bks )
      !------------------------------------------------------------------------
      !
      USE mp_global,            ONLY : my_image_id,me_bgrp,inter_image_comm,nimage
      USE mp_world,             ONLY : mpime,root,world_comm
      USE io_global,            ONLY : stdout 
      USE westcom,              ONLY : west_prefix
      USE mp,                   ONLY : mp_barrier,mp_bcast,mp_get
      !
      IMPLICIT NONE
      !
      ! I/O
      !
      TYPE(bks_type),INTENT(OUT) :: bks 
      !
      ! Workspace
      !
      INTEGER :: ierr
      CHARACTER(LEN=512) :: dirname,fname
      REAL(DP), EXTERNAL :: GET_CLOCK
      REAL(DP) :: time_spent(2)
      CHARACTER(20),EXTERNAL :: human_readable_time
      !
      ! BARRIER
      !
      CALL mp_barrier(world_comm)
      !
      ! MKDIR 
      !
      dirname = TRIM( tmp_dir ) // TRIM( west_prefix ) // '.wfreq.restart'
      CALL my_mkdir( dirname )
      !
      CALL start_clock('sg_restart')
      time_spent(1)=get_clock('sg_restart')
      !
      fname = "summary_g.xml"
      CALL read_bks( bks, dirname, fname ) 
      !
      ! BARRIER
      !
      CALL mp_barrier(world_comm)
      time_spent(2)=get_clock('sg_restart')
      CALL stop_clock('sg_restart')
      !
      WRITE(stdout,'(1/, 5x,"[I/O] -------------------------------------------------------")')
      WRITE(stdout, "(5x, '[I/O] RESTART read in ',a20)") human_readable_time(time_spent(2)-time_spent(1)) 
      WRITE(stdout, "(5x, '[I/O] In location : ',a)") TRIM( dirname )  
      WRITE(stdout,'(5x,"[I/O] -------------------------------------------------------")')
      !
    END SUBROUTINE
    !
    !
    !
    !------------------------------------------------------------------------
    SUBROUTINE solvegfreq_restart_read_q( bksks )
      !------------------------------------------------------------------------
      !
      USE mp_global,            ONLY : my_image_id,me_bgrp,inter_image_comm,nimage
      USE mp_world,             ONLY : mpime,root,world_comm
      USE io_global,            ONLY : stdout 
      USE westcom,              ONLY : west_prefix
      USE mp,                   ONLY : mp_barrier,mp_bcast,mp_get
      !
      IMPLICIT NONE
      !
      ! I/O
      !
      TYPE(bksks_type),INTENT(OUT) :: bksks
      !
      ! Workspace
      !
      INTEGER :: ierr
      CHARACTER(LEN=512) :: dirname,fname
      REAL(DP), EXTERNAL :: GET_CLOCK
      REAL(DP) :: time_spent(2)
      CHARACTER(20),EXTERNAL :: human_readable_time
      !
      ! BARRIER
      !
      CALL mp_barrier(world_comm)
      !
      ! MKDIR 
      !
      dirname = TRIM( tmp_dir ) // TRIM( west_prefix ) // '.wfreq.restart'
      CALL my_mkdir( dirname )
      !
      CALL start_clock('sg_restart')
      time_spent(1)=get_clock('sg_restart')
      !
      fname = "summary_g.xml"
      CALL read_bksks( bksks, dirname, fname ) 
      !
      ! BARRIER
      !
      CALL mp_barrier(world_comm)
      time_spent(2)=get_clock('sg_restart')
      CALL stop_clock('sg_restart')
      !
      WRITE(stdout,'(1/, 5x,"[I/O] -------------------------------------------------------")')
      WRITE(stdout, "(5x, '[I/O] RESTART read in ',a20)") human_readable_time(time_spent(2)-time_spent(1)) 
      WRITE(stdout, "(5x, '[I/O] In location : ',a)") TRIM( dirname )  
      WRITE(stdout,'(5x,"[I/O] -------------------------------------------------------")')
      !
    END SUBROUTINE
    !
END MODULE
