# -*- Mode: Python -*-
"""
Low level term evaluation functions.
"""
cimport cython

cimport numpy as np
import numpy as np

from sfepy.fem.extmods.mappings cimport (VolumeGeometry, SurfaceGeometry,
                                         CVolumeMapping, CSurfaceMapping)
from sfepy.fem.extmods._fmfield cimport (FMField,
                                         array2fmfield4, array2fmfield3,
                                         array2fmfield2, array2fmfield1,
                                         array2pint1, array2pint2)

from sfepy.fem.extmods.types cimport int32, float64, complex128

cdef extern from 'terms.h':
    cdef int32 _dq_state_in_qp \
         'dq_state_in_qp'(FMField *out, FMField *state, int32 offset,
                          FMField *bf,
                          int32 *conn, int32 nEl, int32 nEP)

    cdef int32 _dq_grad \
         'dq_grad'(FMField *out, FMField *state, int32 offset,
                   VolumeGeometry *vg, int32 *conn, int32 nEl, int32 nEP)

    cdef int32 _dq_grad_extra \
         'dq_grad_extra'(FMField *out, FMField *state, int32 offset,
                         SurfaceGeometry *sg,
                         int32 *conn, int32 nEl, int32 nEP)

    cdef int32 _dq_div_vector \
         'dq_div_vector'(FMField *out, FMField *state, int32 offset,
                         VolumeGeometry *vg,
                         int32 *conn, int32 nEl, int32 nEP)

    cdef int32 _d_volume_surface \
         'd_volume_surface'(FMField *out, FMField *in_,
                            FMField *bf, SurfaceGeometry *sg,
                            int32 *conn, int32 nEl, int32 nEP)

    cdef int32 _di_surface_moment \
         'di_surface_moment'(FMField *out, FMField *in_,
                             FMField *bf, SurfaceGeometry *sg,
                             int32 *conn, int32 nEl, int32 nEP)

    cdef int32 _dq_finite_strain_tl \
         'dq_finite_strain_tl'(FMField *mtxF, FMField *detF, FMField *vecCS,
                               FMField *trC, FMField *in2C, FMField *vecInvCS,
                               FMField *vecES,
                               FMField *state, int32 offset,
                               VolumeGeometry *vg,
                               int32 *conn, int32 nEl, int32 nEP)

    cdef int32 _dq_finite_strain_ul \
         'dq_finite_strain_ul'(FMField *mtxF, FMField *detF, FMField *vecBS,
                               FMField *trB, FMField *in2B, FMField *vecES,
                               FMField *state, int32 offset,
                               VolumeGeometry *vg,
                               int32 *conn, int32 nEl, int32 nEP)

    cdef int32 _dq_tl_finite_strain_surface \
         'dq_tl_finite_strain_surface'(FMField *mtxF, FMField *detF,
                                       FMField *mtxFI,
                                       FMField *state, int32 offset,
                                       SurfaceGeometry *sg,
                                       int32 *fis, int32 nFa, int32 nFP,
                                       int32 *conn, int32 nEl, int32 nE)

    cdef int32 _dq_tl_he_stress_bulk \
         'dq_tl_he_stress_bulk'(FMField *out,FMField *mat,
                                FMField *detF, FMField *vecInvCS)

    cdef int32 _dq_ul_he_stress_bulk \
         'dq_ul_he_stress_bulk'(FMField *out,FMField *mat,
                                FMField *detF)

    cdef int32 _dq_tl_he_stress_neohook \
         'dq_tl_he_stress_neohook'(FMField *out, FMField *mat,
                                   FMField *detF, FMField *trC,
                                   FMField *vecInvCS)

    cdef int32 _dq_ul_he_stress_neohook \
         'dq_ul_he_stress_neohook'(FMField *out, FMField *mat,
                                   FMField *detF, FMField *trB, FMField *vecBS)

    cdef int32 _dq_tl_he_stress_mooney_rivlin \
         'dq_tl_he_stress_mooney_rivlin'(FMField *out, FMField *mat,
                                         FMField *detF, FMField *trC,
                                         FMField *vecInvCS, FMField *vecCS,
                                         FMField *in2C)

    cdef int32 _dq_ul_he_stress_mooney_rivlin \
         'dq_ul_he_stress_mooney_rivlin'(FMField *out, FMField *mat,
                                         FMField *detF, FMField *trB,
                                         FMField *vecBS, FMField *in2B)

    cdef int32 _dq_tl_he_tan_mod_bulk \
         'dq_tl_he_tan_mod_bulk'(FMField *out, FMField *mat,
                                 FMField *detF, FMField *vecInvCS)

    cdef int32 _dq_ul_he_tan_mod_bulk \
         'dq_ul_he_tan_mod_bulk'(FMField *out, FMField *mat, FMField *detF)

    cdef int32 _dq_tl_he_tan_mod_neohook \
         'dq_tl_he_tan_mod_neohook'(FMField *out, FMField *mat,
                                    FMField *detF, FMField *trC,
                                    FMField *vecInvCS)

    cdef int32 _dq_ul_he_tan_mod_neohook \
         'dq_ul_he_tan_mod_neohook'(FMField *out, FMField *mat,
                                    FMField *detF, FMField *trB,
                                    FMField *vecBS)

    cdef int32 _dq_tl_he_tan_mod_mooney_rivlin \
         'dq_tl_he_tan_mod_mooney_rivlin'(FMField *out, FMField *mat,
                                          FMField *detF, FMField *trC,
                                          FMField *vecInvCS, FMField *vecCS,
                                          FMField *in2C)

    cdef int32 _dq_ul_he_tan_mod_mooney_rivlin \
         'dq_ul_he_tan_mod_mooney_rivlin'(FMField *out, FMField *mat,
                                          FMField *detF, FMField *trB,
                                          FMField *vecBS, FMField *in2B)

    cdef int32 _dw_he_rtm \
         'dw_he_rtm'(FMField *out,
                     FMField *stress, FMField *tan_mod,
                     FMField *mtxF, FMField *detF,
                     VolumeGeometry *vg,
                     int32 isDiff, int32 mode_ul)

    cdef int32 _de_he_rtm \
         'de_he_rtm'(FMField *out,
                     FMField *stress, FMField *detF,
                     VolumeGeometry *vg,
                     int32 *elList, int32 elList_nRow,
                     int32 mode_ul)

    cdef int32 _dq_tl_stress_bulk_pressure \
         'dq_tl_stress_bulk_pressure'(FMField *out, FMField *pressure_qp,
                                      FMField *detF, FMField *vecInvCS)
    cdef int32 _dq_ul_stress_bulk_pressure \
         'dq_ul_stress_bulk_pressure'(FMField *out, FMField *pressure_qp,
                                      FMField *det)
    cdef int32 _dq_tl_tan_mod_bulk_pressure_u \
         'dq_tl_tan_mod_bulk_pressure_u'(FMField *out, FMField *pressure_qp,
                                         FMField *detF, FMField *vecInvCS)
    cdef int32 _dq_ul_tan_mod_bulk_pressure_u \
         'dq_ul_tan_mod_bulk_pressure_u'(FMField *out, FMField *pressure_qp,
                                         FMField *detF)

    cdef int32 _dw_tl_volume \
         'dw_tl_volume'(FMField *out, FMField *bf, FMField *mtxF,
                        FMField *vecInvCS, FMField *detF,
                        VolumeGeometry *vg, int32 transpose,
                        int32 mode)
    cdef int32 _dw_ul_volume \
         'dw_ul_volume'(FMField *out, FMField *bf, FMField *detF,
                        VolumeGeometry *vg, int32 transpose,
                        int32 mode)

    cdef int32 _dw_tl_diffusion \
         'dw_tl_diffusion'(FMField *out, FMField *pressure_grad,
                           FMField *mtxD, FMField *ref_porosity,
                           FMField *mtxF, FMField *detF,
                           VolumeGeometry *vg, int32 mode)

    cdef int32 _dw_tl_surface_traction \
         'dw_tl_surface_traction'(FMField *out, FMField *traction,
                                  FMField *detF, FMField *mtxFI,
                                  FMField *bf, SurfaceGeometry *sg,
                                  int32 *fis, int32 nFa, int32 nFP,
                                  int32 mode)

    cdef int32 _dq_def_grad \
         'dq_def_grad'(FMField *out, FMField *state, VolumeGeometry *vg,
                       int32 *conn, int32 nEl, int32 nEP,
                       int32 *elList, int32 elList_nRow, int32 mode)

    cdef int32 _he_residuum_from_mtx \
         'he_residuum_from_mtx'(FMField *out, FMField *mtxD,
                                FMField *state,
                                int32 *conn, int32 nEl, int32 nEP,
                                int32 *elList, int32 elList_nRo)
    cdef int32 _he_eval_from_mtx \
         'he_eval_from_mtx'(FMField *out, FMField *mtxD,
                            FMField *stateV, FMField *stateU,
                            int32 *conn, int32 nEl, int32 nEP,
                            int32 *elList, int32 elList_nRo)

    cdef int32 _dw_volume_wdot_scalar \
         'dw_volume_wdot_scalar'(FMField *out, float64 coef, FMField *state_qp,
                                 FMField *bf, FMField *mtxD,
                                 VolumeGeometry *vg,
                                 int32 *elList, int32 elList_nRow,
                                 int32 isDiff)

    cdef int32 _dw_laplace \
         'dw_laplace'(FMField *out, FMField *grad,
                      FMField *coef, VolumeGeometry *vg,
                      int32 isDiff)

    cdef int32 _d_laplace \
         'd_laplace'(FMField *out, FMField *gradP1, FMField *gradP2,
                     FMField *coef, VolumeGeometry *vg)
    cdef int32 _dw_diffusion \
         'dw_diffusion'(FMField *out, FMField *grad,
                        FMField *mtxD, VolumeGeometry *vg,
                        int32 isDiff)
    cdef int32 _d_diffusion \
         'd_diffusion'(FMField *out, FMField *gradP1, FMField *gradP2,
                       FMField *mtxD, VolumeGeometry *vg)
    cdef int32 _dw_permeability_r \
         'dw_permeability_r'(FMField *out, FMField *mtxD, VolumeGeometry *vg,
                             int32 *conn, int32 nEl, int32 nEP,
                             int32 *elList, int32 elList_nRow)
    cdef int32 _dw_diffusion_coupling \
         'dw_diffusion_coupling'(FMField *out, FMField *state, int32 offset,
                                 FMField *mtxD, FMField *bf,
                                 VolumeGeometry *vg,
                                 int32 *conn, int32 nEl, int32 nEP,
                                 int32 *elList, int32 elList_nRow,
                                 int32 isDiff, int32 mod)
    cdef int32 _d_diffusion_coupling \
         'd_diffusion_coupling'(FMField *out, FMField *stateP, FMField *stateQ,
                                FMField *mtxD, FMField *bf, VolumeGeometry *vg,
                                int32 *conn, int32 nEl, int32 nEP,
                                int32 *elList, int32 elList_nRow,
                                int32 isDiff, int32 mod)
    cdef int32 _de_diffusion_velocity \
         'de_diffusion_velocity'(FMField *out, FMField *grad,
                                 FMField *mtxD, VolumeGeometry *vg,
                                 int32 mode)
    cdef int32 _d_surface_flux \
         'd_surface_flux'(FMField *out, FMField *grad,
                          FMField *mtxD, SurfaceGeometry *sg, int32 mode)

    cdef int32 _dw_lin_elastic_iso \
         'dw_lin_elastic_iso'(FMField *out, FMField *strain,
                              FMField *lam, FMField *mu, VolumeGeometry *vg,
                              int32 isDiff)
    cdef int32 _dw_lin_elastic \
         'dw_lin_elastic'(FMField *out, float64 coef, FMField *strain,
                          FMField *mtxD, VolumeGeometry *vg,
                          int32 isDiff)
    cdef int32 _d_lin_elastic \
         'd_lin_elastic'(FMField *out, float64 coef, FMField *strainV,
                         FMField *strainU, FMField *mtxD, VolumeGeometry *vg)

    cdef int32 _dw_lin_prestress \
         'dw_lin_prestress'(FMField *out, FMField *stress, VolumeGeometry *vg,
                            int32 *elList, int32 elList_nRow, int32 isDiff)

    cdef int32 _dw_lin_strain_fib \
         'dw_lin_strain_fib'(FMField *out, FMField *mtxD, FMField *mat,
                             VolumeGeometry *vg,
                             int32 *elList, int32 elList_nRow)

    cdef int32 _de_cauchy_strain \
         'de_cauchy_strain'(FMField *out, FMField *strain,
                            VolumeGeometry *vg, int32 mode)
    cdef int32 _de_cauchy_stress \
         'de_cauchy_stress'(FMField *out, FMField *strain,
                            FMField *mtxD,  VolumeGeometry *vg,
                            int32 mode)
    cdef int32 _dq_cauchy_strain \
         'dq_cauchy_strain'(FMField *out, FMField *state, int32 offset,
                            VolumeGeometry *vg,
                            int32 *conn, int32 nEl, int32 nEP)

    cdef int32 _dw_surface_ltr \
         'dw_surface_ltr'(FMField *out, FMField *bf,
                          FMField *traction, SurfaceGeometry *sg)

    cdef int32 _dw_volume_lvf \
         'dw_volume_lvf'(FMField *out, FMField *bf, FMField *forceQP,
                         VolumeGeometry *vg)

    cdef int32 _dw_mass \
         'dw_mass'(FMField *out, FMField *coef, FMField *state,
                   FMField *bf, VolumeGeometry *vg,
                   int32 isDiff)

    cdef int32 _dw_mass_scalar \
         'dw_mass_scalar'(FMField *out, FMField *coef,
                          FMField *state, FMField *bf, VolumeGeometry *vg,
                          int32 isDiff)

    cdef int32 _d_mass_scalar \
         'd_mass_scalar'(FMField *out, FMField *coef,
                         FMField *stateP, FMField *stateQ,
                         FMField *bf, VolumeGeometry *vg)

    cdef int32 _dw_surf_mass_scalar \
         'dw_surf_mass_scalar'(FMField *out, FMField *coef,
                               FMField *state, FMField *bf,
                               SurfaceGeometry *sg,
                               int32 isDiff)

    cdef int32 _term_ns_asm_div_grad \
         'term_ns_asm_div_grad'(FMField *out, FMField *grad,
                                FMField *viscosity, VolumeGeometry *vg,
                                int32 isDiff)

    cdef int32 _term_ns_asm_convect \
         'term_ns_asm_convect'(FMField *out, FMField *grad, FMField *state,
                               FMField *bf, VolumeGeometry *vg,
                               int32 isDiff)

    cdef int32 _dw_lin_convect \
         'dw_lin_convect'(FMField *out, FMField *grad, FMField *stateB,
                          FMField *bf, VolumeGeometry *vg,
                          int32 isDiff)

    cdef int32 _dw_div \
         'dw_div'(FMField *out, FMField *coef, FMField *div,
                  FMField *bf, VolumeGeometry *vg,
                  int32 isDiff)

    cdef int32 _dw_grad \
         'dw_grad'(FMField *out, FMField *coef, FMField *state,
                   FMField *bf, VolumeGeometry *vg,
                   int32 isDiff)

    cdef int32 _dw_st_pspg_c \
         'dw_st_pspg_c'(FMField *out,
                        FMField *stateB, FMField *stateU,
                        FMField *coef,
                        VolumeGeometry *vg_p, VolumeGeometry *vg_u,
                        int32 *conn, int32 nEl, int32 nEP,
                        int32 isDiff)

    cdef int32 _dw_st_supg_p \
         'dw_st_supg_p'(FMField *out,
                        FMField *stateB, FMField *gradP,
                        FMField *coef,
                        VolumeGeometry *vg_u, VolumeGeometry *vg_p,
                        int32 isDiff)

    cdef int32 _dw_st_supg_c \
         'dw_st_supg_c'(FMField *out,
                        FMField *stateB, FMField *stateU,
                        FMField *coef, VolumeGeometry *vg,
                        int32 *conn, int32 nEl, int32 nEP,
                        int32 isDiff)

    cdef int32 _dw_st_grad_div \
         'dw_st_grad_div'(FMField *out, FMField *div,
                          FMField *coef, VolumeGeometry *vg,
                          int32 isDiff)

    cdef int32 _dw_biot_grad \
         'dw_biot_grad'(FMField *out, float64 coef, FMField *pressure_qp,
                        FMField *bf, FMField *mtxD, VolumeGeometry *vg,
                        int32 isDiff)

    cdef int32 _dw_biot_div \
         'dw_biot_div'(FMField *out, float64 coef, FMField *strain,
                       FMField *bf, FMField *mtxD, VolumeGeometry *vg,
                       int32 isDiff)

    cdef int32 _d_biot_div \
         'd_biot_div'(FMField *out, float64 coef, FMField *state,
                      FMField *strain, FMField *mtxD, VolumeGeometry *vg)

    cdef int32 _dw_piezo_coupling \
         'dw_piezo_coupling'(FMField *out, FMField *strain,
                             FMField *charge_grad,
                             FMField *mtxG, VolumeGeometry *vg,
                             int32 mode)

    cdef int32 _d_piezo_coupling \
         'd_piezo_coupling'(FMField *out, FMField *strain,
                            FMField *charge_grad,
                            FMField *mtxG, VolumeGeometry *vg)

    cdef int32 _dw_electric_source \
         'dw_electric_source'(FMField *out, FMField *grad, FMField *coef,
                              FMField *bf, VolumeGeometry *vg)

    cdef int32 _d_diffusion_sa \
         'd_diffusion_sa'(FMField *out,
                          FMField *stateQ, FMField *stateP, FMField *stateW,
                          FMField *mtxD,
                          VolumeGeometry *vg, VolumeGeometry *vg_w,
                          int32 *conn, int32 nEl, int32 nEP,
                          int32 *conn_w, int32 nEl_w, int32 nEP_w,
                          int32 *elList, int32 elList_nRow)

    cdef int32 _dw_surf_laplace \
         'dw_surf_laplace'(FMField *out, FMField *state, FMField *coef,
                           FMField *gbf, SurfaceGeometry *sg,
                           int32 *conn, int32 nEl, int32 nEP,
                           int32 *elList, int32 elList_nRow,
                           int32 isDiff)

    cdef int32 _d_surf_laplace \
         'd_surf_laplace'(FMField *out, FMField *stateP,
                          FMField *stateQ, FMField *coef,
                          FMField *gbf, SurfaceGeometry *sg,
                          int32 *conn, int32 nEl, int32 nEP,
                          int32 *elList, int32 elList_nRo)

    cdef int32 _dw_surf_lcouple \
         'dw_surf_lcouple'(FMField *out, FMField *state, FMField *coef,
                           FMField *bf, FMField *gbf, SurfaceGeometry *sg,
                           int32 *conn, int32 nEl, int32 nEP,
                           int32 *elList, int32 elList_nRow,
                           int32 isDiff)

    cdef int32 _d_surf_lcouple \
         'd_surf_lcouple'(FMField *out, FMField *stateP,
                          FMField *stateQ, FMField *coef,
                          FMField *bf, FMField *gbf, SurfaceGeometry *sg,
                          int32 *conn, int32 nEl, int32 nEP,
                          int32 *elList, int32 elList_nRo)

    cdef int32 _dw_adj_convect1 \
         'dw_adj_convect1'(FMField *out, FMField *state, int32 offset,
                           FMField *velocity, int32 voffset, FMField *bf,
                           VolumeGeometry *vg,
                           int32 *conn, int32 nEl, int32 nEP,
                           int32 *elList, int32 elList_nRow,
                           int32 isDiff)

    cdef int32 _dw_adj_convect2 \
         'dw_adj_convect2'(FMField *out, FMField *state, int32 offset,
                           FMField *velocity, int32 voffset, FMField *bf,
                           VolumeGeometry *vg,
                           int32 *conn, int32 nEl, int32 nEP,
                           int32 *elList, int32 elList_nRow,
                           int32 isDiff)

    cdef int32 _dw_st_adj_supg_c \
         'dw_st_adj_supg_c'(FMField *out,
                            FMField *stateU, int32 offsetU,
                            FMField *stateW, int32 offsetW,
                            FMField *coef, FMField *bf, VolumeGeometry *vg,
                            int32 *conn, int32 nEl, int32 nEP,
                            int32 *elList, int32 elList_nRow,
                            int32 isDiff)

    cdef int32 _dw_st_adj1_supg_p \
         'dw_st_adj1_supg_p'(FMField *out,
                             FMField *stateP, int32 offsetP,
                             FMField *stateW, int32 offsetW,
                             FMField *coef, FMField *bf_w,
                             VolumeGeometry *vg_w, VolumeGeometry *vg_p,
                             int32 *conn_w, int32 nEl_w, int32 nEP_w,
                             int32 *conn_p, int32 nEl_p, int32 nEP_p,
                             int32 *elList, int32 elList_nRow,
                             int32 isDiff)

    cdef int32 _dw_st_adj2_supg_p \
         'dw_st_adj2_supg_p'(FMField *out,
                             FMField *stateU, int32 offsetU,
                             FMField *stateR, int32 offsetR,
                             FMField *coef, FMField *bf_u,
                             VolumeGeometry *vg_u, VolumeGeometry *vg_r,
                             int32 *conn_u, int32 nEl_u, int32 nEP_u,
                             int32 *conn_r, int32 nEl_r, int32 nEP_r,
                             int32 *elList, int32 elList_nRow,
                             int32 isDiff)

    cdef int32 _d_of_nsMinGrad \
         'd_of_nsMinGrad'(FMField *out, FMField *velocity, int32 offset,
                          float64 viscosity, VolumeGeometry *vg,
                          int32 *conn, int32 nEl, int32 nEP,
                          int32 *elList, int32 elList_nRow)

    cdef int32 _d_of_nsSurfMinDPress \
         'd_of_nsSurfMinDPress'(FMField *out, FMField *pressure, int32 offset,
                                float64 weight, float64 bpress,
                                FMField *bf, SurfaceGeometry *sg,
                                int32 *conn, int32 nEl, int32 nEP,
                                int32 *elList, int32 elList_nRow, int32 isDiff)

    cdef int32 _d_sd_div \
         'd_sd_div'(FMField *out,
                    FMField *stateU, int32 offsetU,
                    FMField *stateP, int32 offsetP,
                    FMField *vecMV, int32 offsetMV,
                    FMField *bf_p,
                    VolumeGeometry *vg_u,
                    VolumeGeometry *vg_p,
                    VolumeGeometry *vg_mv,
                    int32 *conn_u, int32 nEl_u, int32 nEP_u,
                    int32 *conn_p, int32 nEl_p, int32 nEP_p,
                    int32 *conn_mv, int32 nEl_mv, int32 nEP_mv,
                    int32 *elList, int32 elList_nRow,
                    int32 mode)

    cdef int32 _d_sd_div_grad \
         'd_sd_div_grad'(FMField *out,
                         FMField *stateU, int32 offsetU,
                         FMField *stateW, int32 offsetW,
                         FMField *vecMV, int32 offsetMV,
                         float64 viscosity,
                         VolumeGeometry *vg_u,
                         VolumeGeometry *vg_mv,
                         int32 *conn_u, int32 nEl_u, int32 nEP_u,
                         int32 *conn_mv, int32 nEl_mv, int32 nEP_mv,
                         int32 *elList, int32 elList_nRow,
                         int32 mode)

    cdef int32 _d_sd_convect \
         'd_sd_convect'(FMField *out,
                        FMField *stateU, int32 offsetU,
                        FMField *stateW, int32 offsetW,
                        FMField *vecMV, int32 offsetMV,
                        FMField *bf_u, FMField *bf_w,
                        VolumeGeometry *vg_u,
                        VolumeGeometry *vg_w,
                        VolumeGeometry *vg_mv,
                        int32 *conn_u, int32 nEl_u, int32 nEP_u,
                        int32 *conn_w, int32 nEl_w, int32 nEP_w,
                        int32 *conn_mv, int32 nEl_mv, int32 nEP_mv,
                        int32 *elList, int32 elList_nRow,
                        int32 mode)

    cdef int32 _d_sd_testPQ \
         'd_sd_testPQ'(FMField *out,
                       FMField *stateP, int32 offsetP,
                       FMField *stateQ, int32 offsetQ,
                       FMField *vecMV, int32 offsetMV,
                       FMField *bf, VolumeGeometry *vg,
                       int32 *conn, int32 nEl, int32 nEP,
                       int32 *elList, int32 elList_nRow,
                       int32 mode)

    cdef int32 _d_sd_st_grad_div \
         'd_sd_st_grad_div'(FMField *out,
                            FMField *stateU, int32 offsetU,
                            FMField *stateW, int32 offsetW,
                            FMField *vecMV, int32 offsetMV,
                            float64 gamma,
                            VolumeGeometry *vg_u,
                            VolumeGeometry *vg_mv,
                            int32 *conn_u, int32 nEl_u, int32 nEP_u,
                            int32 *conn_mv, int32 nEl_mv, int32 nEP_mv,
                            int32 *elList, int32 elList_nRow,
                            int32 mode)

    cdef int32 _d_sd_st_supg_c \
         'd_sd_st_supg_c'(FMField *out,
                          FMField *stateU, int32 offsetU,
                          FMField *stateB, int32 offsetB,
                          FMField *stateW, int32 offsetW,
                          FMField *vecMV, int32 offsetMV,
                          FMField *bf_u,
                          FMField *coef,
                          VolumeGeometry *vg_u,
                          VolumeGeometry *vg_mv,
                          int32 *conn_u, int32 nEl_u, int32 nEP_u,
                          int32 *conn_mv, int32 nEl_mv, int32 nEP_mv,
                          int32 *elList, int32 elList_nRow,
                          int32 mode)

    cdef int32 _d_sd_st_pspg_c \
         'd_sd_st_pspg_c'(FMField *out,
                          FMField *stateU, int32 offsetU,
                          FMField *stateB, int32 offsetB,
                          FMField *stateR, int32 offsetR,
                          FMField *vecMV, int32 offsetMV,
                          FMField *bf_u,
                          FMField *coef,
                          VolumeGeometry *vg_u,
                          VolumeGeometry *vg_r,
                          VolumeGeometry *vg_mv,
                          int32 *conn_u, int32 nEl_u, int32 nEP_u,
                          int32 *conn_r, int32 nEl_r, int32 nEP_r,
                          int32 *conn_mv, int32 nEl_mv, int32 nEP_mv,
                          int32 *elList, int32 elList_nRow,
                          int32 mode)

    cdef int32 _d_sd_st_pspg_p \
         'd_sd_st_pspg_p'(FMField *out,
                          FMField *stateP, int32 offsetP,
                          FMField *stateR, int32 offsetR,
                          FMField *vecMV, int32 offsetMV,
                          FMField *coef,
                          VolumeGeometry *vg_p,
                          VolumeGeometry *vg_mv,
                          int32 *conn_p, int32 nEl_p, int32 nEP_p,
                          int32 *conn_mv, int32 nEl_mv, int32 nEP_mv,
                          int32 *elList, int32 elList_nRow,
                          int32 mode)

def dq_state_in_qp(np.ndarray out not None,
                   np.ndarray state not None,
                   np.ndarray bf not None,
                   np.ndarray conn not None):
    cdef int32 ret
    cdef FMField _out[1], _state[1], _bf[1]
    cdef int32 *_conn, n_el, n_ep

    array2fmfield4(_out, out)
    array2fmfield1(_state, state)
    array2fmfield3(_bf, bf)
    array2pint2(&_conn, &n_el, &n_ep, conn)

    ret = _dq_state_in_qp(_out, _state, 0, _bf, _conn, n_el, n_ep)
    return ret

def dq_grad(np.ndarray out not None,
            np.ndarray state not None,
            CVolumeMapping cmap not None,
            np.ndarray conn not None):
    cdef int32 ret
    cdef FMField _out[1], _state[1]
    cdef int32 *_conn, n_el, n_ep

    array2fmfield4(_out, out)
    array2fmfield1(_state, state)
    array2pint2(&_conn, &n_el, &n_ep, conn)

    ret = _dq_grad(_out, _state, 0, cmap.geo, _conn, n_el, n_ep)
    return ret

def dq_grad_extra(np.ndarray out not None,
                  np.ndarray state not None,
                  CSurfaceMapping cmap not None,
                  np.ndarray conn not None):
    cdef int32 ret
    cdef FMField _out[1], _state[1]
    cdef int32 *_conn, n_el, n_ep

    array2fmfield4(_out, out)
    array2fmfield1(_state, state)
    array2pint2(&_conn, &n_el, &n_ep, conn)

    ret = _dq_grad_extra(_out, _state, 0, cmap.geo, _conn, n_el, n_ep)
    return ret

def dq_div_vector(np.ndarray out not None,
                  np.ndarray state not None,
                  CVolumeMapping cmap not None,
                  np.ndarray conn not None):
    cdef int32 ret
    cdef FMField _out[1], _state[1]
    cdef int32 *_conn, n_el, n_ep

    array2fmfield4(_out, out)
    array2fmfield1(_state, state)
    array2pint2(&_conn, &n_el, &n_ep, conn)

    ret = _dq_div_vector(_out, _state, 0, cmap.geo, _conn, n_el, n_ep)
    return ret

def d_volume_surface(np.ndarray out not None,
                     np.ndarray in_ not None,
                     np.ndarray bf not None,
                     CSurfaceMapping cmap not None,
                     np.ndarray conn not None):
    cdef int32 ret
    cdef FMField _out[1], _in_[1], _bf[1]
    cdef int32 *_conn, n_el, n_ep

    array2fmfield4(_out, out)
    array2fmfield2(_in_, in_)
    array2fmfield3(_bf, bf)
    array2pint2(&_conn, &n_el, &n_ep, conn)

    ret = _d_volume_surface(_out, _in_, _bf, cmap.geo, _conn, n_el, n_ep)
    return ret

def di_surface_moment(np.ndarray out not None,
                      np.ndarray in_ not None,
                      np.ndarray bf not None,
                      CSurfaceMapping cmap not None,
                      np.ndarray conn not None):
    cdef int32 ret
    cdef FMField _out[1], _in_[1], _bf[1]
    cdef int32 *_conn, n_el, n_ep

    array2fmfield4(_out, out)
    array2fmfield2(_in_, in_)
    array2fmfield3(_bf, bf)
    array2pint2(&_conn, &n_el, &n_ep, conn)

    ret = _di_surface_moment(_out, _in_, _bf, cmap.geo, _conn, n_el, n_ep)
    return ret

def dq_finite_strain_tl(np.ndarray mtx_f not None,
                        np.ndarray det_f not None,
                        np.ndarray vec_cs not None,
                        np.ndarray tr_c not None,
                        np.ndarray in_2c not None,
                        np.ndarray vec_inv_cs not None,
                        np.ndarray vec_es not None,
                        np.ndarray state not None,
                        CVolumeMapping cmap not None,
                        np.ndarray conn not None):
    cdef int32 ret
    cdef FMField _mtx_f[1], _det_f[1], _vec_cs[1], _tr_c[1], _in_2c[1]
    cdef FMField _vec_inv_cs[1], _vec_es[1], _state[1]
    cdef int32 *_conn, n_el, n_ep

    array2fmfield4(_mtx_f, mtx_f)
    array2fmfield4(_det_f, det_f)
    array2fmfield4(_vec_cs, vec_cs)
    array2fmfield4(_tr_c, tr_c)
    array2fmfield4(_in_2c, in_2c)
    array2fmfield4(_vec_inv_cs, vec_inv_cs)
    array2fmfield4(_vec_es, vec_es)
    array2fmfield1(_state, state)
    array2pint2(&_conn, &n_el, &n_ep, conn)

    ret = _dq_finite_strain_tl(_mtx_f, _det_f, _vec_cs, _tr_c, _in_2c,
                               _vec_inv_cs, _vec_es, _state, 0, cmap.geo,
                               _conn, n_el, n_ep)
    return ret

def dq_finite_strain_ul(np.ndarray mtx_f not None,
                        np.ndarray det_f not None,
                        np.ndarray vec_bs not None,
                        np.ndarray tr_b not None,
                        np.ndarray in_2b not None,
                        np.ndarray vec_es not None,
                        np.ndarray state not None,
                        CVolumeMapping cmap not None,
                        np.ndarray conn not None):
    cdef int32 ret
    cdef FMField _mtx_f[1], _det_f[1], _vec_bs[1], _tr_b[1], _in_2b[1]
    cdef FMField _vec_es[1], _state[1]
    cdef int32 *_conn, n_el, n_ep

    array2fmfield4(_mtx_f, mtx_f)
    array2fmfield4(_det_f, det_f)
    array2fmfield4(_vec_bs, vec_bs)
    array2fmfield4(_tr_b, tr_b)
    array2fmfield4(_in_2b, in_2b)
    array2fmfield4(_vec_es, vec_es)
    array2fmfield1(_state, state)
    array2pint2(&_conn, &n_el, &n_ep, conn)

    ret = _dq_finite_strain_ul(_mtx_f, _det_f, _vec_bs, _tr_b, _in_2b,
                               _vec_es, _state, 0, cmap.geo,
                               _conn, n_el, n_ep)
    return ret

def dq_tl_finite_strain_surface(np.ndarray mtx_f not None,
                                np.ndarray det_f not None,
                                np.ndarray mtx_fi not None,
                                np.ndarray state not None,
                                CSurfaceMapping cmap not None,
                                np.ndarray fis not None,
                                np.ndarray conn not None):
    cdef int32 ret
    cdef FMField _mtx_f[1], _det_f[1], _mtx_fi[1], _state[1]
    cdef int32 *_conn, n_el, n_ep, *_fis, n_fa, n_fp

    array2fmfield4(_mtx_f, mtx_f)
    array2fmfield4(_det_f, det_f)
    array2fmfield4(_mtx_fi, mtx_fi)
    array2fmfield1(_state, state)
    array2pint2(&_fis, &n_fa, &n_fp, fis)
    array2pint2(&_conn, &n_el, &n_ep, conn)

    ret = _dq_tl_finite_strain_surface(_mtx_f, _det_f, _mtx_fi, _state, 0,
                                       cmap.geo,
                                       _fis, n_fa, n_fp, _conn, n_el, n_ep)
    return ret

def dq_tl_he_stress_bulk(np.ndarray out not None,
                         np.ndarray mat not None,
                         np.ndarray det_f not None,
                         np.ndarray vec_inv_cs not None):
    cdef int32 ret
    cdef FMField _out[1], _mat[1], _det_f[1], _vec_inv_cs[1]

    array2fmfield4(_out, out)
    array2fmfield4(_mat, mat)
    array2fmfield4(_det_f, det_f)
    array2fmfield4(_vec_inv_cs, vec_inv_cs)

    ret = _dq_tl_he_stress_bulk(_out, _mat, _det_f, _vec_inv_cs)
    return ret

def dq_ul_he_stress_bulk(np.ndarray out not None,
                         np.ndarray mat not None,
                         np.ndarray det_f not None):
    cdef int32 ret
    cdef FMField _out[1], _mat[1], _det_f[1]

    array2fmfield4(_out, out)
    array2fmfield4(_mat, mat)
    array2fmfield4(_det_f, det_f)

    ret = _dq_ul_he_stress_bulk(_out, _mat, _det_f)
    return ret

def dq_tl_he_stress_neohook(np.ndarray out not None,
                            np.ndarray mat not None,
                            np.ndarray det_f not None,
                            np.ndarray tr_c not None,
                            np.ndarray vec_inv_cs not None):
    cdef int32 ret
    cdef FMField _out[1], _mat[1], _det_f[1], _tr_c[1], _vec_inv_cs[1]

    array2fmfield4(_out, out)
    array2fmfield4(_mat, mat)
    array2fmfield4(_det_f, det_f)
    array2fmfield4(_tr_c, tr_c)
    array2fmfield4(_vec_inv_cs, vec_inv_cs)

    ret = _dq_tl_he_stress_neohook(_out, _mat, _det_f, _tr_c, _vec_inv_cs)
    return ret

def dq_ul_he_stress_neohook(np.ndarray out not None,
                            np.ndarray mat not None,
                            np.ndarray det_f not None,
                            np.ndarray tr_b not None,
                            np.ndarray vec_bs not None):
    cdef int32 ret
    cdef FMField _out[1], _mat[1], _det_f[1], _tr_b[1], _vec_bs[1]

    array2fmfield4(_out, out)
    array2fmfield4(_mat, mat)
    array2fmfield4(_det_f, det_f)
    array2fmfield4(_tr_b, tr_b)
    array2fmfield4(_vec_bs, vec_bs)

    ret = _dq_ul_he_stress_neohook(_out, _mat, _det_f, _tr_b, _vec_bs)
    return ret

def dq_tl_he_stress_mooney_rivlin(np.ndarray out not None,
                                  np.ndarray mat not None,
                                  np.ndarray det_f not None,
                                  np.ndarray tr_c not None,
                                  np.ndarray vec_inv_cs not None,
                                  np.ndarray vec_cs not None,
                                  np.ndarray in_2c not None):
    cdef int32 ret
    cdef FMField _out[1], _mat[1], _det_f[1], _tr_c[1], _vec_inv_cs[1]
    cdef FMField _vec_cs[1], _in_2c[1]

    array2fmfield4(_out, out)
    array2fmfield4(_mat, mat)
    array2fmfield4(_det_f, det_f)
    array2fmfield4(_tr_c, tr_c)
    array2fmfield4(_vec_inv_cs, vec_inv_cs)
    array2fmfield4(_vec_cs, vec_cs)
    array2fmfield4(_in_2c, in_2c)

    ret = _dq_tl_he_stress_mooney_rivlin(_out, _mat, _det_f, _tr_c,
                                         _vec_inv_cs, _vec_cs, _in_2c)
    return ret

def dq_ul_he_stress_mooney_rivlin(np.ndarray out not None,
                                  np.ndarray mat not None,
                                  np.ndarray det_f not None,
                                  np.ndarray tr_b not None,
                                  np.ndarray vec_bs not None,
                                  np.ndarray in_2b not None):
    cdef int32 ret
    cdef FMField _out[1], _mat[1], _det_f[1], _tr_b[1], _vec_bs[1], _in_2b[1]

    array2fmfield4(_out, out)
    array2fmfield4(_mat, mat)
    array2fmfield4(_det_f, det_f)
    array2fmfield4(_tr_b, tr_b)
    array2fmfield4(_vec_bs, vec_bs)
    array2fmfield4(_in_2b, in_2b)

    ret = _dq_ul_he_stress_mooney_rivlin(_out, _mat, _det_f, _tr_b,
                                         _vec_bs, _in_2b)
    return ret

def dq_tl_he_tan_mod_bulk(np.ndarray out not None,
                          np.ndarray mat not None,
                          np.ndarray det_f not None,
                          np.ndarray vec_inv_cs not None):
    cdef int32 ret
    cdef FMField _out[1], _mat[1], _det_f[1], _vec_inv_cs[1]

    array2fmfield4(_out, out)
    array2fmfield4(_mat, mat)
    array2fmfield4(_det_f, det_f)
    array2fmfield4(_vec_inv_cs, vec_inv_cs)

    ret = _dq_tl_he_tan_mod_bulk(_out, _mat, _det_f, _vec_inv_cs)
    return ret

def dq_ul_he_tan_mod_bulk(np.ndarray out not None,
                          np.ndarray mat not None,
                          np.ndarray det_f not None):
    cdef int32 ret
    cdef FMField _out[1], _mat[1], _det_f[1]

    array2fmfield4(_out, out)
    array2fmfield4(_mat, mat)
    array2fmfield4(_det_f, det_f)

    ret = _dq_ul_he_tan_mod_bulk(_out, _mat, _det_f)
    return ret

def dq_tl_he_tan_mod_neohook(np.ndarray out not None,
                             np.ndarray mat not None,
                             np.ndarray det_f not None,
                             np.ndarray tr_c not None,
                             np.ndarray vec_inv_cs not None):
    cdef int32 ret
    cdef FMField _out[1], _mat[1], _det_f[1], _tr_c[1], _vec_inv_cs[1]

    array2fmfield4(_out, out)
    array2fmfield4(_mat, mat)
    array2fmfield4(_det_f, det_f)
    array2fmfield4(_tr_c, tr_c)
    array2fmfield4(_vec_inv_cs, vec_inv_cs)

    ret = _dq_tl_he_tan_mod_neohook(_out, _mat, _det_f, _tr_c, _vec_inv_cs)
    return ret

def dq_ul_he_tan_mod_neohook(np.ndarray out not None,
                             np.ndarray mat not None,
                             np.ndarray det_f not None,
                             np.ndarray tr_b not None,
                             np.ndarray vec_bs not None):
    cdef int32 ret
    cdef FMField _out[1], _mat[1], _det_f[1], _tr_b[1], _vec_bs[1]

    array2fmfield4(_out, out)
    array2fmfield4(_mat, mat)
    array2fmfield4(_det_f, det_f)
    array2fmfield4(_tr_b, tr_b)
    array2fmfield4(_vec_bs, vec_bs)

    ret = _dq_ul_he_tan_mod_neohook(_out, _mat, _det_f, _tr_b, _vec_bs)
    return ret

def dq_tl_he_tan_mod_mooney_rivlin(np.ndarray out not None,
                                   np.ndarray mat not None,
                                   np.ndarray det_f not None,
                                   np.ndarray tr_c not None,
                                   np.ndarray vec_inv_cs not None,
                                   np.ndarray vec_cs not None,
                                   np.ndarray in_2c not None):
    cdef int32 ret
    cdef FMField _out[1], _mat[1], _det_f[1], _tr_c[1], _vec_inv_cs[1]
    cdef FMField _vec_cs[1], _in_2c[1]

    array2fmfield4(_out, out)
    array2fmfield4(_mat, mat)
    array2fmfield4(_det_f, det_f)
    array2fmfield4(_tr_c, tr_c)
    array2fmfield4(_vec_inv_cs, vec_inv_cs)
    array2fmfield4(_vec_cs, vec_cs)
    array2fmfield4(_in_2c, in_2c)

    ret = _dq_tl_he_tan_mod_mooney_rivlin(_out, _mat, _det_f, _tr_c,
                                          _vec_inv_cs, _vec_cs, _in_2c)
    return ret

def dq_ul_he_tan_mod_mooney_rivlin(np.ndarray out not None,
                                   np.ndarray mat not None,
                                   np.ndarray det_f not None,
                                   np.ndarray tr_b not None,
                                   np.ndarray vec_bs not None,
                                   np.ndarray in_2b not None):
    cdef int32 ret
    cdef FMField _out[1], _mat[1], _det_f[1], _tr_b[1], _vec_bs[1], _in_2b[1]

    array2fmfield4(_out, out)
    array2fmfield4(_mat, mat)
    array2fmfield4(_det_f, det_f)
    array2fmfield4(_tr_b, tr_b)
    array2fmfield4(_vec_bs, vec_bs)
    array2fmfield4(_in_2b, in_2b)

    ret = _dq_ul_he_tan_mod_mooney_rivlin(_out, _mat, _det_f, _tr_b,
                                          _vec_bs, _in_2b)
    return ret

def dw_he_rtm(np.ndarray out not None,
              np.ndarray stress not None,
              np.ndarray tan_mod not None,
              np.ndarray mtx_f not None,
              np.ndarray det_f not None,
              CVolumeMapping cmap not None,
              int32 is_diff, int32 mode_ul):
    cdef int32 ret
    cdef FMField _out[1], _stress[1], _tan_mod[1], _mtx_f[1], _det_f[1]

    array2fmfield4(_out, out)
    array2fmfield4(_stress, stress)
    array2fmfield4(_tan_mod, tan_mod)
    array2fmfield4(_mtx_f, mtx_f)
    array2fmfield4(_det_f, det_f)

    ret = _dw_he_rtm(_out, _stress, _tan_mod, _mtx_f, _det_f,
                     cmap.geo, is_diff, mode_ul)
    return ret

def de_he_rtm(np.ndarray out not None,
              np.ndarray stress not None,
              np.ndarray det_f not None,
              CVolumeMapping cmap not None,
              np.ndarray el_list not None,
              int32 mode_ul):
    cdef int32 ret
    cdef FMField _out[1], _stress[1], _det_f[1]
    cdef int32 *_el_list, n_el

    array2fmfield4(_out, out)
    array2fmfield4(_stress, stress)
    array2fmfield4(_det_f, det_f)
    array2pint1(&_el_list, &n_el, el_list)

    ret = _de_he_rtm(_out, _stress, _det_f,
                     cmap.geo, _el_list, n_el, mode_ul)
    return ret

def dq_tl_stress_bulk_pressure(np.ndarray out not None,
                               np.ndarray pressure_qp not None,
                               np.ndarray det_f not None,
                               np.ndarray vec_inv_cs not None):
    cdef int32 ret
    cdef FMField _out[1], _pressure_qp[1], _det_f[1], _vec_inv_cs[1]

    array2fmfield4(_out, out)
    array2fmfield4(_pressure_qp, pressure_qp)
    array2fmfield4(_det_f, det_f)
    array2fmfield4(_vec_inv_cs, vec_inv_cs)

    ret = _dq_tl_stress_bulk_pressure(_out, _pressure_qp, _det_f, _vec_inv_cs)
    return ret

def dq_ul_stress_bulk_pressure(np.ndarray out not None,
                               np.ndarray pressure_qp not None,
                               np.ndarray det_f not None):
    cdef int32 ret
    cdef FMField _out[1], _pressure_qp[1], _det_f[1]

    array2fmfield4(_out, out)
    array2fmfield4(_pressure_qp, pressure_qp)
    array2fmfield4(_det_f, det_f)

    ret = _dq_ul_stress_bulk_pressure(_out, _pressure_qp, _det_f)
    return ret

def dq_tl_tan_mod_bulk_pressure_u(np.ndarray out not None,
                                  np.ndarray pressure_qp not None,
                                  np.ndarray det_f not None,
                                  np.ndarray vec_inv_cs not None):
    cdef int32 ret
    cdef FMField _out[1], _pressure_qp[1], _det_f[1], _vec_inv_cs[1]

    array2fmfield4(_out, out)
    array2fmfield4(_pressure_qp, pressure_qp)
    array2fmfield4(_det_f, det_f)
    array2fmfield4(_vec_inv_cs, vec_inv_cs)

    ret = _dq_tl_tan_mod_bulk_pressure_u(_out, _pressure_qp, _det_f,
                                         _vec_inv_cs)
    return ret

def dq_ul_tan_mod_bulk_pressure_u(np.ndarray out not None,
                                  np.ndarray pressure_qp not None,
                                  np.ndarray det_f not None):
    cdef int32 ret
    cdef FMField _out[1], _pressure_qp[1], _det_f[1]

    array2fmfield4(_out, out)
    array2fmfield4(_pressure_qp, pressure_qp)
    array2fmfield4(_det_f, det_f)

    ret = _dq_ul_tan_mod_bulk_pressure_u(_out, _pressure_qp, _det_f)
    return ret

def dw_tl_volume(np.ndarray out not None,
                 np.ndarray bf not None,
                 np.ndarray mtx_f not None,
                 np.ndarray vec_inv_cs not None,
                 np.ndarray det_f not None,
                 CVolumeMapping cmap not None,
                 int32 transpose, int32 mode):
    cdef int32 ret
    cdef FMField _out[1], _bf[1], _mtx_f[1], _vec_inv_cs[1], _det_f[1]

    array2fmfield4(_out, out)
    array2fmfield3(_bf, bf)
    array2fmfield4(_mtx_f, mtx_f)
    array2fmfield4(_vec_inv_cs, vec_inv_cs)
    array2fmfield4(_det_f, det_f)

    ret = _dw_tl_volume(_out, _bf, _mtx_f, _vec_inv_cs, _det_f,
                        cmap.geo, transpose, mode)
    return ret

def dw_ul_volume(np.ndarray out not None,
                 np.ndarray bf not None,
                 np.ndarray det_f not None,
                 CVolumeMapping cmap not None,
                 int32 transpose, int32 mode):
    cdef int32 ret
    cdef FMField _out[1], _bf[1], _det_f[1]

    array2fmfield4(_out, out)
    array2fmfield3(_bf, bf)
    array2fmfield4(_det_f, det_f)

    ret = _dw_ul_volume(_out, _bf, _det_f, cmap.geo, transpose, mode)
    return ret

def dw_tl_diffusion(np.ndarray out not None,
                    np.ndarray pressure_grad not None,
                    np.ndarray mtx_d not None,
                    np.ndarray ref_porosity not None,
                    np.ndarray mtx_f not None,
                    np.ndarray det_f not None,
                    CVolumeMapping cmap not None,
                    int32 mode):
    cdef int32 ret
    cdef FMField _out[1], _pressure_grad[1], _mtx_d[1], _ref_porosity[1]
    cdef FMField _mtx_f[1], _det_f[1]

    array2fmfield4(_out, out)
    array2fmfield4(_pressure_grad, pressure_grad)
    array2fmfield4(_mtx_d, mtx_d)
    array2fmfield4(_ref_porosity, ref_porosity)
    array2fmfield4(_mtx_f, mtx_f)
    array2fmfield4(_det_f, det_f)

    ret = _dw_tl_diffusion(_out, _pressure_grad, _mtx_d, _ref_porosity,
                           _mtx_f, _det_f, cmap.geo, mode)
    return ret

def dw_tl_surface_traction(np.ndarray out not None,
                           np.ndarray traction not None,
                           np.ndarray det_f not None,
                           np.ndarray mtx_fi not None,
                           np.ndarray bf not None,
                           CSurfaceMapping cmap not None,
                           np.ndarray fis not None,
                           int32 mode):
    cdef int32 ret
    cdef FMField _out[1], _traction[1], _det_f[1], _mtx_fi[1], _bf[1]
    cdef int32 *_fis, n_fa, n_fp

    array2fmfield4(_out, out)
    array2fmfield4(_traction, traction)
    array2fmfield4(_det_f, det_f)
    array2fmfield4(_mtx_fi, mtx_fi)
    array2fmfield4(_bf, bf)
    array2pint2(&_fis, &n_fa, &n_fp, fis)

    ret = _dw_tl_surface_traction(_out, _traction, _det_f, _mtx_fi, _bf,
                                       cmap.geo, _fis, n_fa, n_fp, mode)
    return ret

def dq_def_grad(np.ndarray out not None,
                np.ndarray state not None,
                CVolumeMapping cmap not None,
                np.ndarray conn not None,
                np.ndarray el_list not None,
                int32 mode):
    cdef int32 ret
    cdef FMField _out[1], _state[1]
    cdef int32 *_conn, n_el, n_ep, *_el_list, n_el2

    array2fmfield4(_out, out)
    array2fmfield1(_state, state)
    array2pint2(&_conn, &n_el, &n_ep, conn)
    array2pint1(&_el_list, &n_el2, el_list)

    ret = _dq_def_grad(_out, _state, cmap.geo,
                       _conn, n_el, n_ep, _el_list, n_el2, mode)
    return ret

def he_residuum_from_mtx(np.ndarray out not None,
                         np.ndarray mtx_d not None,
                         np.ndarray state not None,
                         np.ndarray conn not None,
                         np.ndarray el_list not None):
    cdef int32 ret
    cdef FMField _out[1], _mtx_d[1], _state[1]
    cdef int32 *_conn, n_el, n_ep, *_el_list, n_el2

    array2fmfield4(_out, out)
    array2fmfield4(_mtx_d, mtx_d)
    array2fmfield1(_state, state)
    array2pint2(&_conn, &n_el, &n_ep, conn)
    array2pint1(&_el_list, &n_el2, el_list)

    ret = _he_residuum_from_mtx(_out, _mtx_d, _state,
                                _conn, n_el, n_ep, _el_list, n_el2)
    return ret

def he_eval_from_mtx(np.ndarray out not None,
                     np.ndarray mtx_d not None,
                     np.ndarray state_v not None,
                     np.ndarray state_u not None,
                     np.ndarray conn not None,
                     np.ndarray el_list not None):
    cdef int32 ret
    cdef FMField _out[1], _mtx_d[1], _state_v[1], _state_u[1]
    cdef int32 *_conn, n_el, n_ep, *_el_list, n_el2

    array2fmfield4(_out, out)
    array2fmfield4(_mtx_d, mtx_d)
    array2fmfield1(_state_v, state_v)
    array2fmfield1(_state_u, state_u)
    array2pint2(&_conn, &n_el, &n_ep, conn)
    array2pint1(&_el_list, &n_el2, el_list)

    ret = _he_eval_from_mtx(_out, _mtx_d, _state_v, _state_u,
                            _conn, n_el, n_ep, _el_list, n_el2)
    return ret