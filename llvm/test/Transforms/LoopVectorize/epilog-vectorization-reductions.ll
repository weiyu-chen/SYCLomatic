; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -loop-vectorize -force-vector-width=4 -enable-epilogue-vectorization -epilogue-vectorization-force-VF=4 -S | FileCheck %s

;
; Integer reduction with a start value of 5
;
define i64 @int_reduction_add(i64* %a, i64 %N) {
; CHECK-LABEL: @int_reduction_add(
; CHECK-NEXT:  iter.check:
; CHECK-NEXT:    [[MIN_ITERS_CHECK:%.*]] = icmp ult i64 [[N:%.*]], 4
; CHECK-NEXT:    br i1 [[MIN_ITERS_CHECK]], label [[VEC_EPILOG_SCALAR_PH:%.*]], label [[VECTOR_MAIN_LOOP_ITER_CHECK:%.*]]
; CHECK:       vector.main.loop.iter.check:
; CHECK-NEXT:    [[MIN_ITERS_CHECK1:%.*]] = icmp ult i64 [[N]], 4
; CHECK-NEXT:    br i1 [[MIN_ITERS_CHECK1]], label [[VEC_EPILOG_PH:%.*]], label [[VECTOR_PH:%.*]]
; CHECK:       vector.ph:
; CHECK-NEXT:    [[N_MOD_VF:%.*]] = urem i64 [[N]], 4
; CHECK-NEXT:    [[N_VEC:%.*]] = sub i64 [[N]], [[N_MOD_VF]]
; CHECK-NEXT:    br label [[VECTOR_BODY:%.*]]
; CHECK:       vector.body:
; CHECK-NEXT:    [[INDEX:%.*]] = phi i64 [ 0, [[VECTOR_PH]] ], [ [[INDEX_NEXT:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    [[VEC_PHI:%.*]] = phi <4 x i64> [ <i64 5, i64 0, i64 0, i64 0>, [[VECTOR_PH]] ], [ [[TMP4:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    [[TMP0:%.*]] = add i64 [[INDEX]], 0
; CHECK-NEXT:    [[TMP1:%.*]] = getelementptr inbounds i64, i64* [[A:%.*]], i64 [[TMP0]]
; CHECK-NEXT:    [[TMP2:%.*]] = getelementptr inbounds i64, i64* [[TMP1]], i32 0
; CHECK-NEXT:    [[TMP3:%.*]] = bitcast i64* [[TMP2]] to <4 x i64>*
; CHECK-NEXT:    [[WIDE_LOAD:%.*]] = load <4 x i64>, <4 x i64>* [[TMP3]], align 4
; CHECK-NEXT:    [[TMP4]] = add <4 x i64> [[WIDE_LOAD]], [[VEC_PHI]]
; CHECK-NEXT:    [[INDEX_NEXT]] = add nuw i64 [[INDEX]], 4
; CHECK-NEXT:    [[TMP5:%.*]] = icmp eq i64 [[INDEX_NEXT]], [[N_VEC]]
; CHECK-NEXT:    br i1 [[TMP5]], label [[MIDDLE_BLOCK:%.*]], label [[VECTOR_BODY]], !llvm.loop [[LOOP0:![0-9]+]]
; CHECK:       middle.block:
; CHECK-NEXT:    [[TMP6:%.*]] = call i64 @llvm.vector.reduce.add.v4i64(<4 x i64> [[TMP4]])
; CHECK-NEXT:    [[CMP_N:%.*]] = icmp eq i64 [[N]], [[N_VEC]]
; CHECK-NEXT:    br i1 [[CMP_N]], label [[FOR_END:%.*]], label [[VEC_EPILOG_ITER_CHECK:%.*]]
; CHECK:       vec.epilog.iter.check:
; CHECK-NEXT:    [[N_VEC_REMAINING:%.*]] = sub i64 [[N]], [[N_VEC]]
; CHECK-NEXT:    [[MIN_EPILOG_ITERS_CHECK:%.*]] = icmp ult i64 [[N_VEC_REMAINING]], 4
; CHECK-NEXT:    br i1 [[MIN_EPILOG_ITERS_CHECK]], label [[VEC_EPILOG_SCALAR_PH]], label [[VEC_EPILOG_PH]]
; CHECK:       vec.epilog.ph:
; CHECK-NEXT:    [[BC_MERGE_RDX:%.*]] = phi i64 [ 5, [[VECTOR_MAIN_LOOP_ITER_CHECK]] ], [ [[TMP6]], [[VEC_EPILOG_ITER_CHECK]] ]
; CHECK-NEXT:    [[VEC_EPILOG_RESUME_VAL:%.*]] = phi i64 [ [[N_VEC]], [[VEC_EPILOG_ITER_CHECK]] ], [ 0, [[VECTOR_MAIN_LOOP_ITER_CHECK]] ]
; CHECK-NEXT:    [[N_MOD_VF3:%.*]] = urem i64 [[N]], 4
; CHECK-NEXT:    [[N_VEC4:%.*]] = sub i64 [[N]], [[N_MOD_VF3]]
; CHECK-NEXT:    [[TMP7:%.*]] = insertelement <4 x i64> zeroinitializer, i64 [[BC_MERGE_RDX]], i32 0
; CHECK-NEXT:    br label [[VEC_EPILOG_VECTOR_BODY:%.*]]
; CHECK:       vec.epilog.vector.body:
; CHECK-NEXT:    [[OFFSET_IDX:%.*]] = phi i64 [ [[VEC_EPILOG_RESUME_VAL]], [[VEC_EPILOG_PH]] ], [ [[INDEX_NEXT9:%.*]], [[VEC_EPILOG_VECTOR_BODY]] ]
; CHECK-NEXT:    [[VEC_PHI7:%.*]] = phi <4 x i64> [ [[TMP7]], [[VEC_EPILOG_PH]] ], [ [[TMP12:%.*]], [[VEC_EPILOG_VECTOR_BODY]] ]
; CHECK-NEXT:    [[TMP8:%.*]] = add i64 [[OFFSET_IDX]], 0
; CHECK-NEXT:    [[TMP9:%.*]] = getelementptr inbounds i64, i64* [[A]], i64 [[TMP8]]
; CHECK-NEXT:    [[TMP10:%.*]] = getelementptr inbounds i64, i64* [[TMP9]], i32 0
; CHECK-NEXT:    [[TMP11:%.*]] = bitcast i64* [[TMP10]] to <4 x i64>*
; CHECK-NEXT:    [[WIDE_LOAD8:%.*]] = load <4 x i64>, <4 x i64>* [[TMP11]], align 4
; CHECK-NEXT:    [[TMP12]] = add <4 x i64> [[WIDE_LOAD8]], [[VEC_PHI7]]
; CHECK-NEXT:    [[INDEX_NEXT9]] = add nuw i64 [[OFFSET_IDX]], 4
; CHECK-NEXT:    [[TMP13:%.*]] = icmp eq i64 [[INDEX_NEXT9]], [[N_VEC4]]
; CHECK-NEXT:    br i1 [[TMP13]], label [[VEC_EPILOG_MIDDLE_BLOCK:%.*]], label [[VEC_EPILOG_VECTOR_BODY]], !llvm.loop [[LOOP2:![0-9]+]]
; CHECK:       vec.epilog.middle.block:
; CHECK-NEXT:    [[TMP14:%.*]] = call i64 @llvm.vector.reduce.add.v4i64(<4 x i64> [[TMP12]])
; CHECK-NEXT:    [[CMP_N5:%.*]] = icmp eq i64 [[N]], [[N_VEC4]]
; CHECK-NEXT:    br i1 [[CMP_N5]], label [[FOR_END_LOOPEXIT:%.*]], label [[VEC_EPILOG_SCALAR_PH]]
; CHECK:       vec.epilog.scalar.ph:
; CHECK-NEXT:    [[BC_RESUME_VAL:%.*]] = phi i64 [ [[N_VEC4]], [[VEC_EPILOG_MIDDLE_BLOCK]] ], [ [[N_VEC]], [[VEC_EPILOG_ITER_CHECK]] ], [ 0, [[ITER_CHECK:%.*]] ]
; CHECK-NEXT:    [[BC_MERGE_RDX10:%.*]] = phi i64 [ 5, [[ITER_CHECK]] ], [ [[TMP6]], [[VEC_EPILOG_ITER_CHECK]] ], [ [[TMP14]], [[VEC_EPILOG_MIDDLE_BLOCK]] ]
; CHECK-NEXT:    br label [[FOR_BODY:%.*]]
; CHECK:       for.body:
; CHECK-NEXT:    [[IV:%.*]] = phi i64 [ [[BC_RESUME_VAL]], [[VEC_EPILOG_SCALAR_PH]] ], [ [[IV_NEXT:%.*]], [[FOR_BODY]] ]
; CHECK-NEXT:    [[SUM:%.*]] = phi i64 [ [[BC_MERGE_RDX10]], [[VEC_EPILOG_SCALAR_PH]] ], [ [[ADD:%.*]], [[FOR_BODY]] ]
; CHECK-NEXT:    [[ARRAYIDX:%.*]] = getelementptr inbounds i64, i64* [[A]], i64 [[IV]]
; CHECK-NEXT:    [[TMP15:%.*]] = load i64, i64* [[ARRAYIDX]], align 4
; CHECK-NEXT:    [[ADD]] = add i64 [[TMP15]], [[SUM]]
; CHECK-NEXT:    [[IV_NEXT]] = add nuw nsw i64 [[IV]], 1
; CHECK-NEXT:    [[EXITCOND_NOT:%.*]] = icmp eq i64 [[IV_NEXT]], [[N]]
; CHECK-NEXT:    br i1 [[EXITCOND_NOT]], label [[FOR_END_LOOPEXIT]], label [[FOR_BODY]], !llvm.loop [[LOOP4:![0-9]+]]
; CHECK:       for.end.loopexit:
; CHECK-NEXT:    [[ADD_LCSSA2:%.*]] = phi i64 [ [[ADD]], [[FOR_BODY]] ], [ [[TMP14]], [[VEC_EPILOG_MIDDLE_BLOCK]] ]
; CHECK-NEXT:    br label [[FOR_END]]
; CHECK:       for.end:
; CHECK-NEXT:    [[ADD_LCSSA:%.*]] = phi i64 [ [[TMP6]], [[MIDDLE_BLOCK]] ], [ [[ADD_LCSSA2]], [[FOR_END_LOOPEXIT]] ]
; CHECK-NEXT:    ret i64 [[ADD_LCSSA]]
;
entry:
  br label %for.body

for.body:
  %iv = phi i64 [ 0, %entry ], [ %iv.next, %for.body ]
  %sum = phi i64 [ 5, %entry ], [ %add, %for.body ]
  %arrayidx = getelementptr inbounds i64, i64* %a, i64 %iv
  %0 = load i64, i64* %arrayidx
  %add = add i64 %0, %sum
  %iv.next = add nuw nsw i64 %iv, 1
  %exitcond.not = icmp eq i64 %iv.next, %N
  br i1 %exitcond.not, label %for.end, label %for.body

for.end:
  ret i64 %add
}

;
; Floating point max reduction
;
define float @fp_reduction_max(float* noalias %a, i64 %N) {
; CHECK-LABEL: @fp_reduction_max(
; CHECK-NEXT:  iter.check:
; CHECK-NEXT:    [[MIN_ITERS_CHECK:%.*]] = icmp ult i64 [[N:%.*]], 4
; CHECK-NEXT:    br i1 [[MIN_ITERS_CHECK]], label [[VEC_EPILOG_SCALAR_PH:%.*]], label [[VECTOR_MAIN_LOOP_ITER_CHECK:%.*]]
; CHECK:       vector.main.loop.iter.check:
; CHECK-NEXT:    [[MIN_ITERS_CHECK1:%.*]] = icmp ult i64 [[N]], 4
; CHECK-NEXT:    br i1 [[MIN_ITERS_CHECK1]], label [[VEC_EPILOG_PH:%.*]], label [[VECTOR_PH:%.*]]
; CHECK:       vector.ph:
; CHECK-NEXT:    [[N_MOD_VF:%.*]] = urem i64 [[N]], 4
; CHECK-NEXT:    [[N_VEC:%.*]] = sub i64 [[N]], [[N_MOD_VF]]
; CHECK-NEXT:    br label [[VECTOR_BODY:%.*]]
; CHECK:       vector.body:
; CHECK-NEXT:    [[INDEX:%.*]] = phi i64 [ 0, [[VECTOR_PH]] ], [ [[INDEX_NEXT:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    [[VEC_PHI:%.*]] = phi <4 x float> [ zeroinitializer, [[VECTOR_PH]] ], [ [[TMP5:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    [[TMP0:%.*]] = add i64 [[INDEX]], 0
; CHECK-NEXT:    [[TMP1:%.*]] = getelementptr inbounds float, float* [[A:%.*]], i64 [[TMP0]]
; CHECK-NEXT:    [[TMP2:%.*]] = getelementptr inbounds float, float* [[TMP1]], i32 0
; CHECK-NEXT:    [[TMP3:%.*]] = bitcast float* [[TMP2]] to <4 x float>*
; CHECK-NEXT:    [[WIDE_LOAD:%.*]] = load <4 x float>, <4 x float>* [[TMP3]], align 4
; CHECK-NEXT:    [[TMP4:%.*]] = fcmp fast ogt <4 x float> [[VEC_PHI]], [[WIDE_LOAD]]
; CHECK-NEXT:    [[TMP5]] = select <4 x i1> [[TMP4]], <4 x float> [[VEC_PHI]], <4 x float> [[WIDE_LOAD]]
; CHECK-NEXT:    [[INDEX_NEXT]] = add nuw i64 [[INDEX]], 4
; CHECK-NEXT:    [[TMP6:%.*]] = icmp eq i64 [[INDEX_NEXT]], [[N_VEC]]
; CHECK-NEXT:    br i1 [[TMP6]], label [[MIDDLE_BLOCK:%.*]], label [[VECTOR_BODY]], !llvm.loop [[LOOP5:![0-9]+]]
; CHECK:       middle.block:
; CHECK-NEXT:    [[TMP7:%.*]] = call fast float @llvm.vector.reduce.fmax.v4f32(<4 x float> [[TMP5]])
; CHECK-NEXT:    [[CMP_N:%.*]] = icmp eq i64 [[N]], [[N_VEC]]
; CHECK-NEXT:    br i1 [[CMP_N]], label [[FOR_END:%.*]], label [[VEC_EPILOG_ITER_CHECK:%.*]]
; CHECK:       vec.epilog.iter.check:
; CHECK-NEXT:    [[N_VEC_REMAINING:%.*]] = sub i64 [[N]], [[N_VEC]]
; CHECK-NEXT:    [[MIN_EPILOG_ITERS_CHECK:%.*]] = icmp ult i64 [[N_VEC_REMAINING]], 4
; CHECK-NEXT:    br i1 [[MIN_EPILOG_ITERS_CHECK]], label [[VEC_EPILOG_SCALAR_PH]], label [[VEC_EPILOG_PH]]
; CHECK:       vec.epilog.ph:
; CHECK-NEXT:    [[BC_MERGE_RDX:%.*]] = phi float [ 0.000000e+00, [[VECTOR_MAIN_LOOP_ITER_CHECK]] ], [ [[TMP7]], [[VEC_EPILOG_ITER_CHECK]] ]
; CHECK-NEXT:    [[VEC_EPILOG_RESUME_VAL:%.*]] = phi i64 [ [[N_VEC]], [[VEC_EPILOG_ITER_CHECK]] ], [ 0, [[VECTOR_MAIN_LOOP_ITER_CHECK]] ]
; CHECK-NEXT:    [[N_MOD_VF3:%.*]] = urem i64 [[N]], 4
; CHECK-NEXT:    [[N_VEC4:%.*]] = sub i64 [[N]], [[N_MOD_VF3]]
; CHECK-NEXT:    [[MINMAX_IDENT_SPLATINSERT:%.*]] = insertelement <4 x float> poison, float [[BC_MERGE_RDX]], i32 0
; CHECK-NEXT:    [[MINMAX_IDENT_SPLAT:%.*]] = shufflevector <4 x float> [[MINMAX_IDENT_SPLATINSERT]], <4 x float> poison, <4 x i32> zeroinitializer
; CHECK-NEXT:    br label [[VEC_EPILOG_VECTOR_BODY:%.*]]
; CHECK:       vec.epilog.vector.body:
; CHECK-NEXT:    [[OFFSET_IDX:%.*]] = phi i64 [ [[VEC_EPILOG_RESUME_VAL]], [[VEC_EPILOG_PH]] ], [ [[INDEX_NEXT9:%.*]], [[VEC_EPILOG_VECTOR_BODY]] ]
; CHECK-NEXT:    [[VEC_PHI7:%.*]] = phi <4 x float> [ [[MINMAX_IDENT_SPLAT]], [[VEC_EPILOG_PH]] ], [ [[TMP13:%.*]], [[VEC_EPILOG_VECTOR_BODY]] ]
; CHECK-NEXT:    [[TMP8:%.*]] = add i64 [[OFFSET_IDX]], 0
; CHECK-NEXT:    [[TMP9:%.*]] = getelementptr inbounds float, float* [[A]], i64 [[TMP8]]
; CHECK-NEXT:    [[TMP10:%.*]] = getelementptr inbounds float, float* [[TMP9]], i32 0
; CHECK-NEXT:    [[TMP11:%.*]] = bitcast float* [[TMP10]] to <4 x float>*
; CHECK-NEXT:    [[WIDE_LOAD8:%.*]] = load <4 x float>, <4 x float>* [[TMP11]], align 4
; CHECK-NEXT:    [[TMP12:%.*]] = fcmp fast ogt <4 x float> [[VEC_PHI7]], [[WIDE_LOAD8]]
; CHECK-NEXT:    [[TMP13]] = select <4 x i1> [[TMP12]], <4 x float> [[VEC_PHI7]], <4 x float> [[WIDE_LOAD8]]
; CHECK-NEXT:    [[INDEX_NEXT9]] = add nuw i64 [[OFFSET_IDX]], 4
; CHECK-NEXT:    [[TMP14:%.*]] = icmp eq i64 [[INDEX_NEXT9]], [[N_VEC4]]
; CHECK-NEXT:    br i1 [[TMP14]], label [[VEC_EPILOG_MIDDLE_BLOCK:%.*]], label [[VEC_EPILOG_VECTOR_BODY]], !llvm.loop [[LOOP6:![0-9]+]]
; CHECK:       vec.epilog.middle.block:
; CHECK-NEXT:    [[TMP15:%.*]] = call fast float @llvm.vector.reduce.fmax.v4f32(<4 x float> [[TMP13]])
; CHECK-NEXT:    [[CMP_N5:%.*]] = icmp eq i64 [[N]], [[N_VEC4]]
; CHECK-NEXT:    br i1 [[CMP_N5]], label [[FOR_END_LOOPEXIT:%.*]], label [[VEC_EPILOG_SCALAR_PH]]
; CHECK:       vec.epilog.scalar.ph:
; CHECK-NEXT:    [[BC_RESUME_VAL:%.*]] = phi i64 [ [[N_VEC4]], [[VEC_EPILOG_MIDDLE_BLOCK]] ], [ [[N_VEC]], [[VEC_EPILOG_ITER_CHECK]] ], [ 0, [[ITER_CHECK:%.*]] ]
; CHECK-NEXT:    [[BC_MERGE_RDX10:%.*]] = phi float [ 0.000000e+00, [[ITER_CHECK]] ], [ [[TMP7]], [[VEC_EPILOG_ITER_CHECK]] ], [ [[TMP15]], [[VEC_EPILOG_MIDDLE_BLOCK]] ]
; CHECK-NEXT:    br label [[FOR_BODY:%.*]]
; CHECK:       for.body:
; CHECK-NEXT:    [[INDVARS_IV:%.*]] = phi i64 [ [[IV_NEXT:%.*]], [[FOR_BODY]] ], [ [[BC_RESUME_VAL]], [[VEC_EPILOG_SCALAR_PH]] ]
; CHECK-NEXT:    [[RESULT_08:%.*]] = phi float [ [[V0:%.*]], [[FOR_BODY]] ], [ [[BC_MERGE_RDX10]], [[VEC_EPILOG_SCALAR_PH]] ]
; CHECK-NEXT:    [[ARRAYIDX:%.*]] = getelementptr inbounds float, float* [[A]], i64 [[INDVARS_IV]]
; CHECK-NEXT:    [[L0:%.*]] = load float, float* [[ARRAYIDX]], align 4
; CHECK-NEXT:    [[C0:%.*]] = fcmp fast ogt float [[RESULT_08]], [[L0]]
; CHECK-NEXT:    [[V0]] = select fast i1 [[C0]], float [[RESULT_08]], float [[L0]]
; CHECK-NEXT:    [[IV_NEXT]] = add i64 [[INDVARS_IV]], 1
; CHECK-NEXT:    [[EXITCOND:%.*]] = icmp eq i64 [[IV_NEXT]], [[N]]
; CHECK-NEXT:    br i1 [[EXITCOND]], label [[FOR_END_LOOPEXIT]], label [[FOR_BODY]], !llvm.loop [[LOOP7:![0-9]+]]
; CHECK:       for.end.loopexit:
; CHECK-NEXT:    [[V0_LCSSA2:%.*]] = phi float [ [[V0]], [[FOR_BODY]] ], [ [[TMP15]], [[VEC_EPILOG_MIDDLE_BLOCK]] ]
; CHECK-NEXT:    br label [[FOR_END]]
; CHECK:       for.end:
; CHECK-NEXT:    [[V0_LCSSA:%.*]] = phi float [ [[TMP7]], [[MIDDLE_BLOCK]] ], [ [[V0_LCSSA2]], [[FOR_END_LOOPEXIT]] ]
; CHECK-NEXT:    ret float [[V0_LCSSA]]
;
entry:
  br label %for.body

for.body:
  %indvars.iv = phi i64 [ %iv.next, %for.body ], [ 0, %entry ]
  %result.08 = phi float [ %v0, %for.body ], [ 0.000000e+00, %entry ]
  %arrayidx = getelementptr inbounds float, float* %a, i64 %indvars.iv
  %l0 = load float, float* %arrayidx
  %c0 = fcmp fast ogt float %result.08, %l0
  %v0 = select fast i1 %c0, float %result.08, float %l0
  %iv.next = add i64 %indvars.iv, 1
  %exitcond = icmp eq i64 %iv.next, %N
  br i1 %exitcond, label %for.end, label %for.body

for.end:
  ret float %v0
}

;
; Extension is required before the reduction operation & result is truncated
;
define i16 @reduction_or_trunc(i16* noalias nocapture %ptr) {
; CHECK-LABEL: @reduction_or_trunc(
; CHECK-NEXT:  iter.check:
; CHECK-NEXT:    br i1 false, label [[VEC_EPILOG_SCALAR_PH:%.*]], label [[VECTOR_MAIN_LOOP_ITER_CHECK:%.*]]
; CHECK:       vector.main.loop.iter.check:
; CHECK-NEXT:    br i1 false, label [[VEC_EPILOG_PH:%.*]], label [[VECTOR_PH:%.*]]
; CHECK:       vector.ph:
; CHECK-NEXT:    br label [[VECTOR_BODY:%.*]]
; CHECK:       vector.body:
; CHECK-NEXT:    [[INDEX:%.*]] = phi i32 [ 0, [[VECTOR_PH]] ], [ [[INDEX_NEXT:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    [[VEC_PHI:%.*]] = phi <4 x i32> [ zeroinitializer, [[VECTOR_PH]] ], [ [[TMP9:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    [[TMP0:%.*]] = add i32 [[INDEX]], 0
; CHECK-NEXT:    [[TMP1:%.*]] = and <4 x i32> [[VEC_PHI]], <i32 65535, i32 65535, i32 65535, i32 65535>
; CHECK-NEXT:    [[TMP2:%.*]] = getelementptr inbounds i16, i16* [[PTR:%.*]], i32 [[TMP0]]
; CHECK-NEXT:    [[TMP3:%.*]] = getelementptr inbounds i16, i16* [[TMP2]], i32 0
; CHECK-NEXT:    [[TMP4:%.*]] = bitcast i16* [[TMP3]] to <4 x i16>*
; CHECK-NEXT:    [[WIDE_LOAD:%.*]] = load <4 x i16>, <4 x i16>* [[TMP4]], align 2
; CHECK-NEXT:    [[TMP5:%.*]] = zext <4 x i16> [[WIDE_LOAD]] to <4 x i32>
; CHECK-NEXT:    [[TMP6:%.*]] = or <4 x i32> [[TMP1]], [[TMP5]]
; CHECK-NEXT:    [[INDEX_NEXT]] = add nuw i32 [[INDEX]], 4
; CHECK-NEXT:    [[TMP7:%.*]] = icmp eq i32 [[INDEX_NEXT]], 256
; CHECK-NEXT:    [[TMP8:%.*]] = trunc <4 x i32> [[TMP6]] to <4 x i16>
; CHECK-NEXT:    [[TMP9]] = zext <4 x i16> [[TMP8]] to <4 x i32>
; CHECK-NEXT:    br i1 [[TMP7]], label [[MIDDLE_BLOCK:%.*]], label [[VECTOR_BODY]], !llvm.loop [[LOOP8:![0-9]+]]
; CHECK:       middle.block:
; CHECK-NEXT:    [[TMP10:%.*]] = trunc <4 x i32> [[TMP9]] to <4 x i16>
; CHECK-NEXT:    [[TMP11:%.*]] = call i16 @llvm.vector.reduce.or.v4i16(<4 x i16> [[TMP10]])
; CHECK-NEXT:    [[TMP12:%.*]] = zext i16 [[TMP11]] to i32
; CHECK-NEXT:    [[CMP_N:%.*]] = icmp eq i32 256, 256
; CHECK-NEXT:    br i1 [[CMP_N]], label [[FOR_END:%.*]], label [[VEC_EPILOG_ITER_CHECK:%.*]]
; CHECK:       vec.epilog.iter.check:
; CHECK-NEXT:    br i1 true, label [[VEC_EPILOG_SCALAR_PH]], label [[VEC_EPILOG_PH]]
; CHECK:       vec.epilog.ph:
; CHECK-NEXT:    [[BC_MERGE_RDX:%.*]] = phi i32 [ 0, [[VECTOR_MAIN_LOOP_ITER_CHECK]] ], [ [[TMP12]], [[VEC_EPILOG_ITER_CHECK]] ]
; CHECK-NEXT:    [[VEC_EPILOG_RESUME_VAL:%.*]] = phi i32 [ 256, [[VEC_EPILOG_ITER_CHECK]] ], [ 0, [[VECTOR_MAIN_LOOP_ITER_CHECK]] ]
; CHECK-NEXT:    [[TMP13:%.*]] = insertelement <4 x i32> zeroinitializer, i32 [[BC_MERGE_RDX]], i32 0
; CHECK-NEXT:    br label [[VEC_EPILOG_VECTOR_BODY:%.*]]
; CHECK:       vec.epilog.vector.body:
; CHECK-NEXT:    [[OFFSET_IDX:%.*]] = phi i32 [ [[VEC_EPILOG_RESUME_VAL]], [[VEC_EPILOG_PH]] ], [ [[INDEX_NEXT6:%.*]], [[VEC_EPILOG_VECTOR_BODY]] ]
; CHECK-NEXT:    [[VEC_PHI4:%.*]] = phi <4 x i32> [ [[TMP13]], [[VEC_EPILOG_PH]] ], [ [[TMP23:%.*]], [[VEC_EPILOG_VECTOR_BODY]] ]
; CHECK-NEXT:    [[TMP14:%.*]] = add i32 [[OFFSET_IDX]], 0
; CHECK-NEXT:    [[TMP15:%.*]] = and <4 x i32> [[VEC_PHI4]], <i32 65535, i32 65535, i32 65535, i32 65535>
; CHECK-NEXT:    [[TMP16:%.*]] = getelementptr inbounds i16, i16* [[PTR]], i32 [[TMP14]]
; CHECK-NEXT:    [[TMP17:%.*]] = getelementptr inbounds i16, i16* [[TMP16]], i32 0
; CHECK-NEXT:    [[TMP18:%.*]] = bitcast i16* [[TMP17]] to <4 x i16>*
; CHECK-NEXT:    [[WIDE_LOAD5:%.*]] = load <4 x i16>, <4 x i16>* [[TMP18]], align 2
; CHECK-NEXT:    [[TMP19:%.*]] = zext <4 x i16> [[WIDE_LOAD5]] to <4 x i32>
; CHECK-NEXT:    [[TMP20:%.*]] = or <4 x i32> [[TMP15]], [[TMP19]]
; CHECK-NEXT:    [[INDEX_NEXT6]] = add nuw i32 [[OFFSET_IDX]], 4
; CHECK-NEXT:    [[TMP21:%.*]] = icmp eq i32 [[INDEX_NEXT6]], 256
; CHECK-NEXT:    [[TMP22:%.*]] = trunc <4 x i32> [[TMP20]] to <4 x i16>
; CHECK-NEXT:    [[TMP23]] = zext <4 x i16> [[TMP22]] to <4 x i32>
; CHECK-NEXT:    br i1 [[TMP21]], label [[VEC_EPILOG_MIDDLE_BLOCK:%.*]], label [[VEC_EPILOG_VECTOR_BODY]], !llvm.loop [[LOOP9:![0-9]+]]
; CHECK:       vec.epilog.middle.block:
; CHECK-NEXT:    [[TMP24:%.*]] = trunc <4 x i32> [[TMP23]] to <4 x i16>
; CHECK-NEXT:    [[TMP25:%.*]] = call i16 @llvm.vector.reduce.or.v4i16(<4 x i16> [[TMP24]])
; CHECK-NEXT:    [[TMP26:%.*]] = zext i16 [[TMP25]] to i32
; CHECK-NEXT:    [[CMP_N2:%.*]] = icmp eq i32 256, 256
; CHECK-NEXT:    br i1 [[CMP_N2]], label [[FOR_END_LOOPEXIT:%.*]], label [[VEC_EPILOG_SCALAR_PH]]
; CHECK:       vec.epilog.scalar.ph:
; CHECK-NEXT:    [[BC_RESUME_VAL:%.*]] = phi i32 [ 256, [[VEC_EPILOG_MIDDLE_BLOCK]] ], [ 256, [[VEC_EPILOG_ITER_CHECK]] ], [ 0, [[ITER_CHECK:%.*]] ]
; CHECK-NEXT:    [[BC_MERGE_RDX7:%.*]] = phi i32 [ 0, [[ITER_CHECK]] ], [ [[TMP12]], [[VEC_EPILOG_ITER_CHECK]] ], [ [[TMP26]], [[VEC_EPILOG_MIDDLE_BLOCK]] ]
; CHECK-NEXT:    br label [[FOR_BODY:%.*]]
; CHECK:       for.body:
; CHECK-NEXT:    [[IV:%.*]] = phi i32 [ [[IV_NEXT:%.*]], [[FOR_BODY]] ], [ [[BC_RESUME_VAL]], [[VEC_EPILOG_SCALAR_PH]] ]
; CHECK-NEXT:    [[SUM_02P:%.*]] = phi i32 [ [[XOR:%.*]], [[FOR_BODY]] ], [ [[BC_MERGE_RDX7]], [[VEC_EPILOG_SCALAR_PH]] ]
; CHECK-NEXT:    [[SUM_02:%.*]] = and i32 [[SUM_02P]], 65535
; CHECK-NEXT:    [[GEP:%.*]] = getelementptr inbounds i16, i16* [[PTR]], i32 [[IV]]
; CHECK-NEXT:    [[LOAD:%.*]] = load i16, i16* [[GEP]], align 2
; CHECK-NEXT:    [[EXT:%.*]] = zext i16 [[LOAD]] to i32
; CHECK-NEXT:    [[XOR]] = or i32 [[SUM_02]], [[EXT]]
; CHECK-NEXT:    [[IV_NEXT]] = add i32 [[IV]], 1
; CHECK-NEXT:    [[EXITCOND:%.*]] = icmp eq i32 [[IV_NEXT]], 256
; CHECK-NEXT:    br i1 [[EXITCOND]], label [[FOR_END_LOOPEXIT]], label [[FOR_BODY]], !llvm.loop [[LOOP10:![0-9]+]]
; CHECK:       for.end.loopexit:
; CHECK-NEXT:    [[XOR_LCSSA1:%.*]] = phi i32 [ [[XOR]], [[FOR_BODY]] ], [ [[TMP26]], [[VEC_EPILOG_MIDDLE_BLOCK]] ]
; CHECK-NEXT:    br label [[FOR_END]]
; CHECK:       for.end:
; CHECK-NEXT:    [[XOR_LCSSA:%.*]] = phi i32 [ [[TMP12]], [[MIDDLE_BLOCK]] ], [ [[XOR_LCSSA1]], [[FOR_END_LOOPEXIT]] ]
; CHECK-NEXT:    [[RET:%.*]] = trunc i32 [[XOR_LCSSA]] to i16
; CHECK-NEXT:    ret i16 [[RET]]
;
entry:
  br label %for.body

for.body:
  %iv = phi i32 [ %iv.next, %for.body ], [ 0, %entry ]
  %sum.02p = phi i32 [ %xor, %for.body ], [ 0, %entry ]
  %sum.02 = and i32 %sum.02p, 65535
  %gep = getelementptr inbounds i16, i16* %ptr, i32 %iv
  %load = load i16, i16* %gep
  %ext = zext i16 %load to i32
  %xor = or i32 %sum.02, %ext
  %iv.next = add i32 %iv, 1
  %exitcond = icmp eq i32 %iv.next, 256
  br i1 %exitcond, label %for.end, label %for.body

for.end:
  %ret = trunc i32 %xor to i16
  ret i16 %ret
}

;
; More than one reduction in the loop
;
define float @multiple_fp_rdx(float* %A, i64 %N) {
; CHECK-LABEL: @multiple_fp_rdx(
; CHECK-NEXT:  iter.check:
; CHECK-NEXT:    [[MIN_ITERS_CHECK:%.*]] = icmp ult i64 [[N:%.*]], 4
; CHECK-NEXT:    br i1 [[MIN_ITERS_CHECK]], label [[VEC_EPILOG_SCALAR_PH:%.*]], label [[VECTOR_MAIN_LOOP_ITER_CHECK:%.*]]
; CHECK:       vector.main.loop.iter.check:
; CHECK-NEXT:    [[MIN_ITERS_CHECK1:%.*]] = icmp ult i64 [[N]], 4
; CHECK-NEXT:    br i1 [[MIN_ITERS_CHECK1]], label [[VEC_EPILOG_PH:%.*]], label [[VECTOR_PH:%.*]]
; CHECK:       vector.ph:
; CHECK-NEXT:    [[N_MOD_VF:%.*]] = urem i64 [[N]], 4
; CHECK-NEXT:    [[N_VEC:%.*]] = sub i64 [[N]], [[N_MOD_VF]]
; CHECK-NEXT:    br label [[VECTOR_BODY:%.*]]
; CHECK:       vector.body:
; CHECK-NEXT:    [[INDEX:%.*]] = phi i64 [ 0, [[VECTOR_PH]] ], [ [[INDEX_NEXT:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    [[VEC_PHI:%.*]] = phi <4 x float> [ <float 1.500000e+01, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00>, [[VECTOR_PH]] ], [ [[TMP5:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    [[VEC_PHI2:%.*]] = phi <4 x float> [ <float 1.000000e+01, float 0.000000e+00, float 0.000000e+00, float 0.000000e+00>, [[VECTOR_PH]] ], [ [[TMP4:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    [[TMP0:%.*]] = add i64 [[INDEX]], 0
; CHECK-NEXT:    [[TMP1:%.*]] = getelementptr inbounds float, float* [[A:%.*]], i64 [[TMP0]]
; CHECK-NEXT:    [[TMP2:%.*]] = getelementptr inbounds float, float* [[TMP1]], i32 0
; CHECK-NEXT:    [[TMP3:%.*]] = bitcast float* [[TMP2]] to <4 x float>*
; CHECK-NEXT:    [[WIDE_LOAD:%.*]] = load <4 x float>, <4 x float>* [[TMP3]], align 4
; CHECK-NEXT:    [[TMP4]] = fadd fast <4 x float> [[VEC_PHI2]], [[WIDE_LOAD]]
; CHECK-NEXT:    [[TMP5]] = fmul fast <4 x float> [[VEC_PHI]], [[WIDE_LOAD]]
; CHECK-NEXT:    [[INDEX_NEXT]] = add nuw i64 [[INDEX]], 4
; CHECK-NEXT:    [[TMP6:%.*]] = icmp eq i64 [[INDEX_NEXT]], [[N_VEC]]
; CHECK-NEXT:    br i1 [[TMP6]], label [[MIDDLE_BLOCK:%.*]], label [[VECTOR_BODY]], !llvm.loop [[LOOP11:![0-9]+]]
; CHECK:       middle.block:
; CHECK-NEXT:    [[TMP7:%.*]] = call fast float @llvm.vector.reduce.fadd.v4f32(float -0.000000e+00, <4 x float> [[TMP4]])
; CHECK-NEXT:    [[TMP8:%.*]] = call fast float @llvm.vector.reduce.fmul.v4f32(float 1.000000e+00, <4 x float> [[TMP5]])
; CHECK-NEXT:    [[CMP_N:%.*]] = icmp eq i64 [[N]], [[N_VEC]]
; CHECK-NEXT:    br i1 [[CMP_N]], label [[FOR_END:%.*]], label [[VEC_EPILOG_ITER_CHECK:%.*]]
; CHECK:       vec.epilog.iter.check:
; CHECK-NEXT:    [[N_VEC_REMAINING:%.*]] = sub i64 [[N]], [[N_VEC]]
; CHECK-NEXT:    [[MIN_EPILOG_ITERS_CHECK:%.*]] = icmp ult i64 [[N_VEC_REMAINING]], 4
; CHECK-NEXT:    br i1 [[MIN_EPILOG_ITERS_CHECK]], label [[VEC_EPILOG_SCALAR_PH]], label [[VEC_EPILOG_PH]]
; CHECK:       vec.epilog.ph:
; CHECK-NEXT:    [[BC_MERGE_RDX:%.*]] = phi float [ 1.500000e+01, [[VECTOR_MAIN_LOOP_ITER_CHECK]] ], [ [[TMP8]], [[VEC_EPILOG_ITER_CHECK]] ]
; CHECK-NEXT:    [[BC_MERGE_RDX3:%.*]] = phi float [ 1.000000e+01, [[VECTOR_MAIN_LOOP_ITER_CHECK]] ], [ [[TMP7]], [[VEC_EPILOG_ITER_CHECK]] ]
; CHECK-NEXT:    [[VEC_EPILOG_RESUME_VAL:%.*]] = phi i64 [ [[N_VEC]], [[VEC_EPILOG_ITER_CHECK]] ], [ 0, [[VECTOR_MAIN_LOOP_ITER_CHECK]] ]
; CHECK-NEXT:    [[N_MOD_VF6:%.*]] = urem i64 [[N]], 4
; CHECK-NEXT:    [[N_VEC7:%.*]] = sub i64 [[N]], [[N_MOD_VF6]]
; CHECK-NEXT:    [[TMP9:%.*]] = insertelement <4 x float> <float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00>, float [[BC_MERGE_RDX]], i32 0
; CHECK-NEXT:    [[TMP10:%.*]] = insertelement <4 x float> zeroinitializer, float [[BC_MERGE_RDX3]], i32 0
; CHECK-NEXT:    br label [[VEC_EPILOG_VECTOR_BODY:%.*]]
; CHECK:       vec.epilog.vector.body:
; CHECK-NEXT:    [[OFFSET_IDX:%.*]] = phi i64 [ [[VEC_EPILOG_RESUME_VAL]], [[VEC_EPILOG_PH]] ], [ [[INDEX_NEXT13:%.*]], [[VEC_EPILOG_VECTOR_BODY]] ]
; CHECK-NEXT:    [[VEC_PHI10:%.*]] = phi <4 x float> [ [[TMP9]], [[VEC_EPILOG_PH]] ], [ [[TMP16:%.*]], [[VEC_EPILOG_VECTOR_BODY]] ]
; CHECK-NEXT:    [[VEC_PHI11:%.*]] = phi <4 x float> [ [[TMP10]], [[VEC_EPILOG_PH]] ], [ [[TMP15:%.*]], [[VEC_EPILOG_VECTOR_BODY]] ]
; CHECK-NEXT:    [[TMP11:%.*]] = add i64 [[OFFSET_IDX]], 0
; CHECK-NEXT:    [[TMP12:%.*]] = getelementptr inbounds float, float* [[A]], i64 [[TMP11]]
; CHECK-NEXT:    [[TMP13:%.*]] = getelementptr inbounds float, float* [[TMP12]], i32 0
; CHECK-NEXT:    [[TMP14:%.*]] = bitcast float* [[TMP13]] to <4 x float>*
; CHECK-NEXT:    [[WIDE_LOAD12:%.*]] = load <4 x float>, <4 x float>* [[TMP14]], align 4
; CHECK-NEXT:    [[TMP15]] = fadd fast <4 x float> [[VEC_PHI11]], [[WIDE_LOAD12]]
; CHECK-NEXT:    [[TMP16]] = fmul fast <4 x float> [[VEC_PHI10]], [[WIDE_LOAD12]]
; CHECK-NEXT:    [[INDEX_NEXT13]] = add nuw i64 [[OFFSET_IDX]], 4
; CHECK-NEXT:    [[TMP17:%.*]] = icmp eq i64 [[INDEX_NEXT13]], [[N_VEC7]]
; CHECK-NEXT:    br i1 [[TMP17]], label [[VEC_EPILOG_MIDDLE_BLOCK:%.*]], label [[VEC_EPILOG_VECTOR_BODY]], !llvm.loop [[LOOP12:![0-9]+]]
; CHECK:       vec.epilog.middle.block:
; CHECK-NEXT:    [[TMP18:%.*]] = call fast float @llvm.vector.reduce.fadd.v4f32(float -0.000000e+00, <4 x float> [[TMP15]])
; CHECK-NEXT:    [[TMP19:%.*]] = call fast float @llvm.vector.reduce.fmul.v4f32(float 1.000000e+00, <4 x float> [[TMP16]])
; CHECK-NEXT:    [[CMP_N8:%.*]] = icmp eq i64 [[N]], [[N_VEC7]]
; CHECK-NEXT:    br i1 [[CMP_N8]], label [[FOR_END_LOOPEXIT:%.*]], label [[VEC_EPILOG_SCALAR_PH]]
; CHECK:       vec.epilog.scalar.ph:
; CHECK-NEXT:    [[BC_RESUME_VAL:%.*]] = phi i64 [ [[N_VEC7]], [[VEC_EPILOG_MIDDLE_BLOCK]] ], [ [[N_VEC]], [[VEC_EPILOG_ITER_CHECK]] ], [ 0, [[ITER_CHECK:%.*]] ]
; CHECK-NEXT:    [[BC_MERGE_RDX14:%.*]] = phi float [ 1.500000e+01, [[ITER_CHECK]] ], [ [[TMP8]], [[VEC_EPILOG_ITER_CHECK]] ], [ [[TMP19]], [[VEC_EPILOG_MIDDLE_BLOCK]] ]
; CHECK-NEXT:    [[BC_MERGE_RDX15:%.*]] = phi float [ 1.000000e+01, [[ITER_CHECK]] ], [ [[TMP7]], [[VEC_EPILOG_ITER_CHECK]] ], [ [[TMP18]], [[VEC_EPILOG_MIDDLE_BLOCK]] ]
; CHECK-NEXT:    br label [[FOR_BODY:%.*]]
; CHECK:       for.body:
; CHECK-NEXT:    [[IV:%.*]] = phi i64 [ [[BC_RESUME_VAL]], [[VEC_EPILOG_SCALAR_PH]] ], [ [[IV_NEXT:%.*]], [[FOR_BODY]] ]
; CHECK-NEXT:    [[PROD:%.*]] = phi float [ [[BC_MERGE_RDX14]], [[VEC_EPILOG_SCALAR_PH]] ], [ [[MUL:%.*]], [[FOR_BODY]] ]
; CHECK-NEXT:    [[SUM:%.*]] = phi float [ [[BC_MERGE_RDX15]], [[VEC_EPILOG_SCALAR_PH]] ], [ [[ADD:%.*]], [[FOR_BODY]] ]
; CHECK-NEXT:    [[ARRAYIDX:%.*]] = getelementptr inbounds float, float* [[A]], i64 [[IV]]
; CHECK-NEXT:    [[TMP20:%.*]] = load float, float* [[ARRAYIDX]], align 4
; CHECK-NEXT:    [[ADD]] = fadd fast float [[SUM]], [[TMP20]]
; CHECK-NEXT:    [[MUL]] = fmul fast float [[PROD]], [[TMP20]]
; CHECK-NEXT:    [[IV_NEXT]] = add nuw nsw i64 [[IV]], 1
; CHECK-NEXT:    [[EXITCOND_NOT:%.*]] = icmp eq i64 [[IV_NEXT]], [[N]]
; CHECK-NEXT:    br i1 [[EXITCOND_NOT]], label [[FOR_END_LOOPEXIT]], label [[FOR_BODY]], !llvm.loop [[LOOP13:![0-9]+]]
; CHECK:       for.end.loopexit:
; CHECK-NEXT:    [[ADD_LCSSA5:%.*]] = phi float [ [[ADD]], [[FOR_BODY]] ], [ [[TMP18]], [[VEC_EPILOG_MIDDLE_BLOCK]] ]
; CHECK-NEXT:    [[MUL_LCSSA4:%.*]] = phi float [ [[MUL]], [[FOR_BODY]] ], [ [[TMP19]], [[VEC_EPILOG_MIDDLE_BLOCK]] ]
; CHECK-NEXT:    br label [[FOR_END]]
; CHECK:       for.end:
; CHECK-NEXT:    [[ADD_LCSSA:%.*]] = phi float [ [[TMP7]], [[MIDDLE_BLOCK]] ], [ [[ADD_LCSSA5]], [[FOR_END_LOOPEXIT]] ]
; CHECK-NEXT:    [[MUL_LCSSA:%.*]] = phi float [ [[TMP8]], [[MIDDLE_BLOCK]] ], [ [[MUL_LCSSA4]], [[FOR_END_LOOPEXIT]] ]
; CHECK-NEXT:    [[DIV:%.*]] = fdiv float [[MUL_LCSSA]], [[ADD_LCSSA]]
; CHECK-NEXT:    ret float [[DIV]]
;
entry:
  br label %for.body

for.body:
  %iv = phi i64 [ 0, %entry ], [ %iv.next, %for.body ]
  %prod = phi float [ 15.000000e+00, %entry ], [ %mul, %for.body ]
  %sum = phi float [ 10.000000e+00, %entry ], [ %add, %for.body ]
  %arrayidx = getelementptr inbounds float, float* %A, i64 %iv
  %0 = load float, float* %arrayidx
  %add = fadd fast float %sum, %0
  %mul = fmul fast float %prod, %0
  %iv.next = add nuw nsw i64 %iv, 1
  %exitcond.not = icmp eq i64 %iv.next, %N
  br i1 %exitcond.not, label %for.end, label %for.body

for.end:
  %div = fdiv float %mul, %add
  ret float %div
}

;
; Start value of the reduction is a Phi node from the outer loop
;
define i32 @reduction_phi_start_val(i32* %A, i64 %N) {
; CHECK-LABEL: @reduction_phi_start_val(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[ITER_CHECK:%.*]]
; CHECK:       iter.check:
; CHECK-NEXT:    [[OUTER_IV:%.*]] = phi i64 [ [[OUTER_IV_NEXT:%.*]], [[FOR_COND:%.*]] ], [ 0, [[ENTRY:%.*]] ]
; CHECK-NEXT:    [[START_SUM:%.*]] = phi i32 [ [[SUB_LCSSA:%.*]], [[FOR_COND]] ], [ 5, [[ENTRY]] ]
; CHECK-NEXT:    [[MIN_ITERS_CHECK:%.*]] = icmp ult i64 [[N:%.*]], 4
; CHECK-NEXT:    br i1 [[MIN_ITERS_CHECK]], label [[VEC_EPILOG_SCALAR_PH:%.*]], label [[VECTOR_MAIN_LOOP_ITER_CHECK:%.*]]
; CHECK:       vector.main.loop.iter.check:
; CHECK-NEXT:    [[MIN_ITERS_CHECK1:%.*]] = icmp ult i64 [[N]], 4
; CHECK-NEXT:    br i1 [[MIN_ITERS_CHECK1]], label [[VEC_EPILOG_PH:%.*]], label [[VECTOR_PH:%.*]]
; CHECK:       vector.ph:
; CHECK-NEXT:    [[N_MOD_VF:%.*]] = urem i64 [[N]], 4
; CHECK-NEXT:    [[N_VEC:%.*]] = sub i64 [[N]], [[N_MOD_VF]]
; CHECK-NEXT:    [[TMP0:%.*]] = insertelement <4 x i32> zeroinitializer, i32 [[START_SUM]], i32 0
; CHECK-NEXT:    br label [[VECTOR_BODY:%.*]]
; CHECK:       vector.body:
; CHECK-NEXT:    [[INDEX:%.*]] = phi i64 [ 0, [[VECTOR_PH]] ], [ [[INDEX_NEXT:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    [[VEC_PHI:%.*]] = phi <4 x i32> [ [[TMP0]], [[VECTOR_PH]] ], [ [[TMP5:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    [[TMP1:%.*]] = add i64 [[INDEX]], 0
; CHECK-NEXT:    [[TMP2:%.*]] = getelementptr inbounds i32, i32* [[A:%.*]], i64 [[TMP1]]
; CHECK-NEXT:    [[TMP3:%.*]] = getelementptr inbounds i32, i32* [[TMP2]], i32 0
; CHECK-NEXT:    [[TMP4:%.*]] = bitcast i32* [[TMP3]] to <4 x i32>*
; CHECK-NEXT:    [[WIDE_LOAD:%.*]] = load <4 x i32>, <4 x i32>* [[TMP4]], align 4
; CHECK-NEXT:    [[TMP5]] = sub <4 x i32> [[VEC_PHI]], [[WIDE_LOAD]]
; CHECK-NEXT:    [[INDEX_NEXT]] = add nuw i64 [[INDEX]], 4
; CHECK-NEXT:    [[TMP6:%.*]] = icmp eq i64 [[INDEX_NEXT]], [[N_VEC]]
; CHECK-NEXT:    br i1 [[TMP6]], label [[MIDDLE_BLOCK:%.*]], label [[VECTOR_BODY]], !llvm.loop [[LOOP14:![0-9]+]]
; CHECK:       middle.block:
; CHECK-NEXT:    [[TMP7:%.*]] = call i32 @llvm.vector.reduce.add.v4i32(<4 x i32> [[TMP5]])
; CHECK-NEXT:    [[CMP_N:%.*]] = icmp eq i64 [[N]], [[N_VEC]]
; CHECK-NEXT:    br i1 [[CMP_N]], label [[FOR_COND]], label [[VEC_EPILOG_ITER_CHECK:%.*]]
; CHECK:       vec.epilog.iter.check:
; CHECK-NEXT:    [[N_VEC_REMAINING:%.*]] = sub i64 [[N]], [[N_VEC]]
; CHECK-NEXT:    [[MIN_EPILOG_ITERS_CHECK:%.*]] = icmp ult i64 [[N_VEC_REMAINING]], 4
; CHECK-NEXT:    br i1 [[MIN_EPILOG_ITERS_CHECK]], label [[VEC_EPILOG_SCALAR_PH]], label [[VEC_EPILOG_PH]]
; CHECK:       vec.epilog.ph:
; CHECK-NEXT:    [[BC_MERGE_RDX:%.*]] = phi i32 [ [[START_SUM]], [[VECTOR_MAIN_LOOP_ITER_CHECK]] ], [ [[TMP7]], [[VEC_EPILOG_ITER_CHECK]] ]
; CHECK-NEXT:    [[VEC_EPILOG_RESUME_VAL:%.*]] = phi i64 [ [[N_VEC]], [[VEC_EPILOG_ITER_CHECK]] ], [ 0, [[VECTOR_MAIN_LOOP_ITER_CHECK]] ]
; CHECK-NEXT:    [[N_MOD_VF3:%.*]] = urem i64 [[N]], 4
; CHECK-NEXT:    [[N_VEC4:%.*]] = sub i64 [[N]], [[N_MOD_VF3]]
; CHECK-NEXT:    [[TMP8:%.*]] = insertelement <4 x i32> zeroinitializer, i32 [[BC_MERGE_RDX]], i32 0
; CHECK-NEXT:    br label [[VEC_EPILOG_VECTOR_BODY:%.*]]
; CHECK:       vec.epilog.vector.body:
; CHECK-NEXT:    [[OFFSET_IDX:%.*]] = phi i64 [ [[VEC_EPILOG_RESUME_VAL]], [[VEC_EPILOG_PH]] ], [ [[INDEX_NEXT9:%.*]], [[VEC_EPILOG_VECTOR_BODY]] ]
; CHECK-NEXT:    [[VEC_PHI7:%.*]] = phi <4 x i32> [ [[TMP8]], [[VEC_EPILOG_PH]] ], [ [[TMP13:%.*]], [[VEC_EPILOG_VECTOR_BODY]] ]
; CHECK-NEXT:    [[TMP9:%.*]] = add i64 [[OFFSET_IDX]], 0
; CHECK-NEXT:    [[TMP10:%.*]] = getelementptr inbounds i32, i32* [[A]], i64 [[TMP9]]
; CHECK-NEXT:    [[TMP11:%.*]] = getelementptr inbounds i32, i32* [[TMP10]], i32 0
; CHECK-NEXT:    [[TMP12:%.*]] = bitcast i32* [[TMP11]] to <4 x i32>*
; CHECK-NEXT:    [[WIDE_LOAD8:%.*]] = load <4 x i32>, <4 x i32>* [[TMP12]], align 4
; CHECK-NEXT:    [[TMP13]] = sub <4 x i32> [[VEC_PHI7]], [[WIDE_LOAD8]]
; CHECK-NEXT:    [[INDEX_NEXT9]] = add nuw i64 [[OFFSET_IDX]], 4
; CHECK-NEXT:    [[TMP14:%.*]] = icmp eq i64 [[INDEX_NEXT9]], [[N_VEC4]]
; CHECK-NEXT:    br i1 [[TMP14]], label [[VEC_EPILOG_MIDDLE_BLOCK:%.*]], label [[VEC_EPILOG_VECTOR_BODY]], !llvm.loop [[LOOP15:![0-9]+]]
; CHECK:       vec.epilog.middle.block:
; CHECK-NEXT:    [[TMP15:%.*]] = call i32 @llvm.vector.reduce.add.v4i32(<4 x i32> [[TMP13]])
; CHECK-NEXT:    [[CMP_N5:%.*]] = icmp eq i64 [[N]], [[N_VEC4]]
; CHECK-NEXT:    br i1 [[CMP_N5]], label [[FOR_COND_LOOPEXIT:%.*]], label [[VEC_EPILOG_SCALAR_PH]]
; CHECK:       vec.epilog.scalar.ph:
; CHECK-NEXT:    [[BC_RESUME_VAL:%.*]] = phi i64 [ [[N_VEC4]], [[VEC_EPILOG_MIDDLE_BLOCK]] ], [ [[N_VEC]], [[VEC_EPILOG_ITER_CHECK]] ], [ 0, [[ITER_CHECK]] ]
; CHECK-NEXT:    [[BC_MERGE_RDX10:%.*]] = phi i32 [ [[START_SUM]], [[ITER_CHECK]] ], [ [[TMP7]], [[VEC_EPILOG_ITER_CHECK]] ], [ [[TMP15]], [[VEC_EPILOG_MIDDLE_BLOCK]] ]
; CHECK-NEXT:    br label [[FOR_BODY:%.*]]
; CHECK:       for.body:
; CHECK-NEXT:    [[IV:%.*]] = phi i64 [ [[BC_RESUME_VAL]], [[VEC_EPILOG_SCALAR_PH]] ], [ [[IV_NEXT:%.*]], [[FOR_BODY]] ]
; CHECK-NEXT:    [[SUM:%.*]] = phi i32 [ [[BC_MERGE_RDX10]], [[VEC_EPILOG_SCALAR_PH]] ], [ [[SUB:%.*]], [[FOR_BODY]] ]
; CHECK-NEXT:    [[ARRAYIDX:%.*]] = getelementptr inbounds i32, i32* [[A]], i64 [[IV]]
; CHECK-NEXT:    [[LOAD:%.*]] = load i32, i32* [[ARRAYIDX]], align 4
; CHECK-NEXT:    [[SUB]] = sub nsw i32 [[SUM]], [[LOAD]]
; CHECK-NEXT:    [[IV_NEXT]] = add nuw nsw i64 [[IV]], 1
; CHECK-NEXT:    [[EXITCOND_NOT:%.*]] = icmp eq i64 [[IV_NEXT]], [[N]]
; CHECK-NEXT:    br i1 [[EXITCOND_NOT]], label [[FOR_COND_LOOPEXIT]], label [[FOR_BODY]], !llvm.loop [[LOOP16:![0-9]+]]
; CHECK:       for.cond.loopexit:
; CHECK-NEXT:    [[SUB_LCSSA2:%.*]] = phi i32 [ [[SUB]], [[FOR_BODY]] ], [ [[TMP15]], [[VEC_EPILOG_MIDDLE_BLOCK]] ]
; CHECK-NEXT:    br label [[FOR_COND]]
; CHECK:       for.cond:
; CHECK-NEXT:    [[SUB_LCSSA]] = phi i32 [ [[TMP7]], [[MIDDLE_BLOCK]] ], [ [[SUB_LCSSA2]], [[FOR_COND_LOOPEXIT]] ]
; CHECK-NEXT:    [[OUTER_IV_NEXT]] = add nuw nsw i64 [[OUTER_IV]], 1
; CHECK-NEXT:    [[OUTER_EXITCOND_NOT:%.*]] = icmp eq i64 [[OUTER_IV_NEXT]], [[N]]
; CHECK-NEXT:    br i1 [[OUTER_EXITCOND_NOT]], label [[FOR_END:%.*]], label [[ITER_CHECK]]
; CHECK:       for.end:
; CHECK-NEXT:    [[SUB_LCSSA_LCSSA:%.*]] = phi i32 [ [[SUB_LCSSA]], [[FOR_COND]] ]
; CHECK-NEXT:    ret i32 [[SUB_LCSSA_LCSSA]]
;
entry:
  br label %for.cond.preheader

for.cond.preheader:
  %outer.iv = phi i64 [ %outer.iv.next, %for.cond ], [ 0, %entry ]
  %start.sum = phi i32 [ %sub, %for.cond ], [ 5, %entry ]
  br label %for.body

for.body:
  %iv = phi i64 [ 0, %for.cond.preheader ], [ %iv.next, %for.body ]
  %sum = phi i32 [ %start.sum, %for.cond.preheader ], [ %sub, %for.body ]
  %arrayidx = getelementptr inbounds i32, i32* %A, i64 %iv
  %load = load i32, i32* %arrayidx, align 4
  %sub = sub nsw i32 %sum, %load
  %iv.next = add nuw nsw i64 %iv, 1
  %exitcond.not = icmp eq i64 %iv.next, %N
  br i1 %exitcond.not, label %for.cond, label %for.body

for.cond:
  %outer.iv.next = add nuw nsw i64 %outer.iv, 1
  %outer.exitcond.not = icmp eq i64 %outer.iv.next, %N
  br i1 %outer.exitcond.not, label %for.end, label %for.cond.preheader

for.end:
  ret i32 %sub
}
