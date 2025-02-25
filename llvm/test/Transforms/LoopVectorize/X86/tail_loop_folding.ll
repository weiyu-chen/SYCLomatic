; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -loop-vectorize -S | FileCheck %s
; RUN: opt < %s -loop-vectorize -prefer-predicate-over-epilogue=predicate-dont-vectorize -S | FileCheck %s

target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

define dso_local void @tail_folding_enabled(i32* noalias nocapture %A, i32* noalias nocapture readonly %B, i32* noalias nocapture readonly %C) local_unnamed_addr #0 {
; CHECK-LABEL: @tail_folding_enabled(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br i1 false, label [[SCALAR_PH:%.*]], label [[VECTOR_PH:%.*]]
; CHECK:       vector.ph:
; CHECK-NEXT:    br label [[VECTOR_BODY:%.*]]
; CHECK:       vector.body:
; CHECK-NEXT:    [[INDEX:%.*]] = phi i64 [ 0, [[VECTOR_PH]] ], [ [[INDEX_NEXT:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    [[TMP0:%.*]] = add i64 [[INDEX]], 0
; CHECK-NEXT:    [[BROADCAST_SPLATINSERT:%.*]] = insertelement <8 x i64> poison, i64 [[INDEX]], i32 0
; CHECK-NEXT:    [[BROADCAST_SPLAT:%.*]] = shufflevector <8 x i64> [[BROADCAST_SPLATINSERT]], <8 x i64> poison, <8 x i32> zeroinitializer
; CHECK-NEXT:    [[VEC_IV:%.*]] = add <8 x i64> [[BROADCAST_SPLAT]], <i64 0, i64 1, i64 2, i64 3, i64 4, i64 5, i64 6, i64 7>
; CHECK-NEXT:    [[TMP1:%.*]] = icmp ule <8 x i64> [[VEC_IV]], <i64 429, i64 429, i64 429, i64 429, i64 429, i64 429, i64 429, i64 429>
; CHECK-NEXT:    [[TMP2:%.*]] = getelementptr inbounds i32, i32* [[B:%.*]], i64 [[TMP0]]
; CHECK-NEXT:    [[TMP3:%.*]] = getelementptr inbounds i32, i32* [[TMP2]], i32 0
; CHECK-NEXT:    [[TMP4:%.*]] = bitcast i32* [[TMP3]] to <8 x i32>*
; CHECK-NEXT:    [[WIDE_MASKED_LOAD:%.*]] = call <8 x i32> @llvm.masked.load.v8i32.p0v8i32(<8 x i32>* [[TMP4]], i32 4, <8 x i1> [[TMP1]], <8 x i32> poison)
; CHECK-NEXT:    [[TMP5:%.*]] = getelementptr inbounds i32, i32* [[C:%.*]], i64 [[TMP0]]
; CHECK-NEXT:    [[TMP6:%.*]] = getelementptr inbounds i32, i32* [[TMP5]], i32 0
; CHECK-NEXT:    [[TMP7:%.*]] = bitcast i32* [[TMP6]] to <8 x i32>*
; CHECK-NEXT:    [[WIDE_MASKED_LOAD1:%.*]] = call <8 x i32> @llvm.masked.load.v8i32.p0v8i32(<8 x i32>* [[TMP7]], i32 4, <8 x i1> [[TMP1]], <8 x i32> poison)
; CHECK-NEXT:    [[TMP8:%.*]] = add nsw <8 x i32> [[WIDE_MASKED_LOAD1]], [[WIDE_MASKED_LOAD]]
; CHECK-NEXT:    [[TMP9:%.*]] = getelementptr inbounds i32, i32* [[A:%.*]], i64 [[TMP0]]
; CHECK-NEXT:    [[TMP10:%.*]] = getelementptr inbounds i32, i32* [[TMP9]], i32 0
; CHECK-NEXT:    [[TMP11:%.*]] = bitcast i32* [[TMP10]] to <8 x i32>*
; CHECK-NEXT:    call void @llvm.masked.store.v8i32.p0v8i32(<8 x i32> [[TMP8]], <8 x i32>* [[TMP11]], i32 4, <8 x i1> [[TMP1]])
; CHECK-NEXT:    [[INDEX_NEXT]] = add i64 [[INDEX]], 8
; CHECK-NEXT:    [[TMP12:%.*]] = icmp eq i64 [[INDEX_NEXT]], 432
; CHECK-NEXT:    br i1 [[TMP12]], label [[MIDDLE_BLOCK:%.*]], label [[VECTOR_BODY]], !llvm.loop [[LOOP0:![0-9]+]]
; CHECK:       middle.block:
; CHECK-NEXT:    br i1 true, label [[FOR_COND_CLEANUP:%.*]], label [[SCALAR_PH]]
; CHECK:       scalar.ph:
; CHECK-NEXT:    [[BC_RESUME_VAL:%.*]] = phi i64 [ 432, [[MIDDLE_BLOCK]] ], [ 0, [[ENTRY:%.*]] ]
; CHECK-NEXT:    br label [[FOR_BODY:%.*]]
; CHECK:       for.cond.cleanup:
; CHECK-NEXT:    ret void
; CHECK:       for.body:
; CHECK-NEXT:    [[INDVARS_IV:%.*]] = phi i64 [ [[BC_RESUME_VAL]], [[SCALAR_PH]] ], [ [[INDVARS_IV_NEXT:%.*]], [[FOR_BODY]] ]
; CHECK-NEXT:    [[ARRAYIDX:%.*]] = getelementptr inbounds i32, i32* [[B]], i64 [[INDVARS_IV]]
; CHECK-NEXT:    [[TMP13:%.*]] = load i32, i32* [[ARRAYIDX]], align 4
; CHECK-NEXT:    [[ARRAYIDX2:%.*]] = getelementptr inbounds i32, i32* [[C]], i64 [[INDVARS_IV]]
; CHECK-NEXT:    [[TMP14:%.*]] = load i32, i32* [[ARRAYIDX2]], align 4
; CHECK-NEXT:    [[ADD:%.*]] = add nsw i32 [[TMP14]], [[TMP13]]
; CHECK-NEXT:    [[ARRAYIDX4:%.*]] = getelementptr inbounds i32, i32* [[A]], i64 [[INDVARS_IV]]
; CHECK-NEXT:    store i32 [[ADD]], i32* [[ARRAYIDX4]], align 4
; CHECK-NEXT:    [[INDVARS_IV_NEXT]] = add nuw nsw i64 [[INDVARS_IV]], 1
; CHECK-NEXT:    [[EXITCOND:%.*]] = icmp eq i64 [[INDVARS_IV_NEXT]], 430
; CHECK-NEXT:    br i1 [[EXITCOND]], label [[FOR_COND_CLEANUP]], label [[FOR_BODY]], !llvm.loop [[LOOP2:![0-9]+]]
;
entry:
  br label %for.body

for.cond.cleanup:
  ret void

for.body:
  %indvars.iv = phi i64 [ 0, %entry ], [ %indvars.iv.next, %for.body ]
  %arrayidx = getelementptr inbounds i32, i32* %B, i64 %indvars.iv
  %0 = load i32, i32* %arrayidx, align 4
  %arrayidx2 = getelementptr inbounds i32, i32* %C, i64 %indvars.iv
  %1 = load i32, i32* %arrayidx2, align 4
  %add = add nsw i32 %1, %0
  %arrayidx4 = getelementptr inbounds i32, i32* %A, i64 %indvars.iv
  store i32 %add, i32* %arrayidx4, align 4
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %exitcond = icmp eq i64 %indvars.iv.next, 430
  br i1 %exitcond, label %for.cond.cleanup, label %for.body, !llvm.loop !6
}

; Marking function as optsize turns tail folding on, as if explicit tail folding
; flag was enabled.
define dso_local void @tail_folding_disabled(i32* noalias nocapture %A, i32* noalias nocapture readonly %B, i32* noalias nocapture readonly %C) local_unnamed_addr #0 {
; CHECK-LABEL: @tail_folding_disabled(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br i1 false, label [[SCALAR_PH:%.*]], label [[VECTOR_PH:%.*]]
; CHECK:       vector.ph:
; CHECK-NEXT:    br label [[VECTOR_BODY:%.*]]
; CHECK:       vector.body:
; CHECK-NEXT:    [[INDEX:%.*]] = phi i64 [ 0, [[VECTOR_PH]] ], [ [[INDEX_NEXT:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    [[TMP0:%.*]] = add i64 [[INDEX]], 0
; CHECK-NEXT:    [[BROADCAST_SPLATINSERT:%.*]] = insertelement <8 x i64> poison, i64 [[INDEX]], i32 0
; CHECK-NEXT:    [[BROADCAST_SPLAT:%.*]] = shufflevector <8 x i64> [[BROADCAST_SPLATINSERT]], <8 x i64> poison, <8 x i32> zeroinitializer
; CHECK-NEXT:    [[VEC_IV:%.*]] = add <8 x i64> [[BROADCAST_SPLAT]], <i64 0, i64 1, i64 2, i64 3, i64 4, i64 5, i64 6, i64 7>
; CHECK-NEXT:    [[TMP1:%.*]] = icmp ule <8 x i64> [[VEC_IV]], <i64 429, i64 429, i64 429, i64 429, i64 429, i64 429, i64 429, i64 429>
; CHECK-NEXT:    [[TMP2:%.*]] = getelementptr inbounds i32, i32* [[B:%.*]], i64 [[TMP0]]
; CHECK-NEXT:    [[TMP3:%.*]] = getelementptr inbounds i32, i32* [[TMP2]], i32 0
; CHECK-NEXT:    [[TMP4:%.*]] = bitcast i32* [[TMP3]] to <8 x i32>*
; CHECK-NEXT:    [[WIDE_MASKED_LOAD:%.*]] = call <8 x i32> @llvm.masked.load.v8i32.p0v8i32(<8 x i32>* [[TMP4]], i32 4, <8 x i1> [[TMP1]], <8 x i32> poison)
; CHECK-NEXT:    [[TMP5:%.*]] = getelementptr inbounds i32, i32* [[C:%.*]], i64 [[TMP0]]
; CHECK-NEXT:    [[TMP6:%.*]] = getelementptr inbounds i32, i32* [[TMP5]], i32 0
; CHECK-NEXT:    [[TMP7:%.*]] = bitcast i32* [[TMP6]] to <8 x i32>*
; CHECK-NEXT:    [[WIDE_MASKED_LOAD1:%.*]] = call <8 x i32> @llvm.masked.load.v8i32.p0v8i32(<8 x i32>* [[TMP7]], i32 4, <8 x i1> [[TMP1]], <8 x i32> poison)
; CHECK-NEXT:    [[TMP8:%.*]] = add nsw <8 x i32> [[WIDE_MASKED_LOAD1]], [[WIDE_MASKED_LOAD]]
; CHECK-NEXT:    [[TMP9:%.*]] = getelementptr inbounds i32, i32* [[A:%.*]], i64 [[TMP0]]
; CHECK-NEXT:    [[TMP10:%.*]] = getelementptr inbounds i32, i32* [[TMP9]], i32 0
; CHECK-NEXT:    [[TMP11:%.*]] = bitcast i32* [[TMP10]] to <8 x i32>*
; CHECK-NEXT:    call void @llvm.masked.store.v8i32.p0v8i32(<8 x i32> [[TMP8]], <8 x i32>* [[TMP11]], i32 4, <8 x i1> [[TMP1]])
; CHECK-NEXT:    [[INDEX_NEXT]] = add i64 [[INDEX]], 8
; CHECK-NEXT:    [[TMP12:%.*]] = icmp eq i64 [[INDEX_NEXT]], 432
; CHECK-NEXT:    br i1 [[TMP12]], label [[MIDDLE_BLOCK:%.*]], label [[VECTOR_BODY]], !llvm.loop [[LOOP4:![0-9]+]]
; CHECK:       middle.block:
; CHECK-NEXT:    br i1 true, label [[FOR_COND_CLEANUP:%.*]], label [[SCALAR_PH]]
; CHECK:       scalar.ph:
; CHECK-NEXT:    [[BC_RESUME_VAL:%.*]] = phi i64 [ 432, [[MIDDLE_BLOCK]] ], [ 0, [[ENTRY:%.*]] ]
; CHECK-NEXT:    br label [[FOR_BODY:%.*]]
; CHECK:       for.cond.cleanup:
; CHECK-NEXT:    ret void
; CHECK:       for.body:
; CHECK-NEXT:    [[INDVARS_IV:%.*]] = phi i64 [ [[BC_RESUME_VAL]], [[SCALAR_PH]] ], [ [[INDVARS_IV_NEXT:%.*]], [[FOR_BODY]] ]
; CHECK-NEXT:    [[ARRAYIDX:%.*]] = getelementptr inbounds i32, i32* [[B]], i64 [[INDVARS_IV]]
; CHECK-NEXT:    [[TMP13:%.*]] = load i32, i32* [[ARRAYIDX]], align 4
; CHECK-NEXT:    [[ARRAYIDX2:%.*]] = getelementptr inbounds i32, i32* [[C]], i64 [[INDVARS_IV]]
; CHECK-NEXT:    [[TMP14:%.*]] = load i32, i32* [[ARRAYIDX2]], align 4
; CHECK-NEXT:    [[ADD:%.*]] = add nsw i32 [[TMP14]], [[TMP13]]
; CHECK-NEXT:    [[ARRAYIDX4:%.*]] = getelementptr inbounds i32, i32* [[A]], i64 [[INDVARS_IV]]
; CHECK-NEXT:    store i32 [[ADD]], i32* [[ARRAYIDX4]], align 4
; CHECK-NEXT:    [[INDVARS_IV_NEXT]] = add nuw nsw i64 [[INDVARS_IV]], 1
; CHECK-NEXT:    [[EXITCOND:%.*]] = icmp eq i64 [[INDVARS_IV_NEXT]], 430
; CHECK-NEXT:    br i1 [[EXITCOND]], label [[FOR_COND_CLEANUP]], label [[FOR_BODY]], !llvm.loop [[LOOP5:![0-9]+]]
;
entry:
  br label %for.body

for.cond.cleanup:
  ret void

for.body:
  %indvars.iv = phi i64 [ 0, %entry ], [ %indvars.iv.next, %for.body ]
  %arrayidx = getelementptr inbounds i32, i32* %B, i64 %indvars.iv
  %0 = load i32, i32* %arrayidx, align 4
  %arrayidx2 = getelementptr inbounds i32, i32* %C, i64 %indvars.iv
  %1 = load i32, i32* %arrayidx2, align 4
  %add = add nsw i32 %1, %0
  %arrayidx4 = getelementptr inbounds i32, i32* %A, i64 %indvars.iv
  store i32 %add, i32* %arrayidx4, align 4
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %exitcond = icmp eq i64 %indvars.iv.next, 430
  br i1 %exitcond, label %for.cond.cleanup, label %for.body, !llvm.loop !10
}

; Check that fold tail under optsize passes the reduction live-out value
; through a select.
; int reduction_i32(int *A, int *B, int N) {
;   int sum = 0;
;   for (int i = 0; i < N; ++i)
;     sum += (A[i] + B[i]);
;   return sum;
; }
;

define i32 @reduction_i32(i32* nocapture readonly %A, i32* nocapture readonly %B, i32 %N) #0 {
; CHECK-LABEL: @reduction_i32(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP0:%.*]] = add i32 [[N:%.*]], -1
; CHECK-NEXT:    [[TMP1:%.*]] = zext i32 [[TMP0]] to i64
; CHECK-NEXT:    [[TMP2:%.*]] = add nuw nsw i64 [[TMP1]], 1
; CHECK-NEXT:    br i1 false, label [[SCALAR_PH:%.*]], label [[VECTOR_PH:%.*]]
; CHECK:       vector.ph:
; CHECK-NEXT:    [[N_RND_UP:%.*]] = add i64 [[TMP2]], 7
; CHECK-NEXT:    [[N_MOD_VF:%.*]] = urem i64 [[N_RND_UP]], 8
; CHECK-NEXT:    [[N_VEC:%.*]] = sub i64 [[N_RND_UP]], [[N_MOD_VF]]
; CHECK-NEXT:    [[TRIP_COUNT_MINUS_1:%.*]] = sub i64 [[TMP2]], 1
; CHECK-NEXT:    [[BROADCAST_SPLATINSERT:%.*]] = insertelement <8 x i64> poison, i64 [[TRIP_COUNT_MINUS_1]], i32 0
; CHECK-NEXT:    [[BROADCAST_SPLAT:%.*]] = shufflevector <8 x i64> [[BROADCAST_SPLATINSERT]], <8 x i64> poison, <8 x i32> zeroinitializer
; CHECK-NEXT:    br label [[VECTOR_BODY:%.*]]
; CHECK:       vector.body:
; CHECK-NEXT:    [[INDEX:%.*]] = phi i64 [ 0, [[VECTOR_PH]] ], [ [[INDEX_NEXT:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    [[VEC_PHI:%.*]] = phi <8 x i32> [ zeroinitializer, [[VECTOR_PH]] ], [ [[TMP12:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    [[TMP3:%.*]] = add i64 [[INDEX]], 0
; CHECK-NEXT:    [[BROADCAST_SPLATINSERT1:%.*]] = insertelement <8 x i64> poison, i64 [[INDEX]], i32 0
; CHECK-NEXT:    [[BROADCAST_SPLAT2:%.*]] = shufflevector <8 x i64> [[BROADCAST_SPLATINSERT1]], <8 x i64> poison, <8 x i32> zeroinitializer
; CHECK-NEXT:    [[VEC_IV:%.*]] = add <8 x i64> [[BROADCAST_SPLAT2]], <i64 0, i64 1, i64 2, i64 3, i64 4, i64 5, i64 6, i64 7>
; CHECK-NEXT:    [[TMP4:%.*]] = icmp ule <8 x i64> [[VEC_IV]], [[BROADCAST_SPLAT]]
; CHECK-NEXT:    [[TMP5:%.*]] = getelementptr inbounds i32, i32* [[A:%.*]], i64 [[TMP3]]
; CHECK-NEXT:    [[TMP6:%.*]] = getelementptr inbounds i32, i32* [[TMP5]], i32 0
; CHECK-NEXT:    [[TMP7:%.*]] = bitcast i32* [[TMP6]] to <8 x i32>*
; CHECK-NEXT:    [[WIDE_MASKED_LOAD:%.*]] = call <8 x i32> @llvm.masked.load.v8i32.p0v8i32(<8 x i32>* [[TMP7]], i32 4, <8 x i1> [[TMP4]], <8 x i32> poison)
; CHECK-NEXT:    [[TMP8:%.*]] = getelementptr inbounds i32, i32* [[B:%.*]], i64 [[TMP3]]
; CHECK-NEXT:    [[TMP9:%.*]] = getelementptr inbounds i32, i32* [[TMP8]], i32 0
; CHECK-NEXT:    [[TMP10:%.*]] = bitcast i32* [[TMP9]] to <8 x i32>*
; CHECK-NEXT:    [[WIDE_MASKED_LOAD3:%.*]] = call <8 x i32> @llvm.masked.load.v8i32.p0v8i32(<8 x i32>* [[TMP10]], i32 4, <8 x i1> [[TMP4]], <8 x i32> poison)
; CHECK-NEXT:    [[TMP11:%.*]] = add nsw <8 x i32> [[WIDE_MASKED_LOAD3]], [[WIDE_MASKED_LOAD]]
; CHECK-NEXT:    [[TMP12]] = add <8 x i32> [[TMP11]], [[VEC_PHI]]
; CHECK-NEXT:    [[TMP13:%.*]] = select <8 x i1> [[TMP4]], <8 x i32> [[TMP12]], <8 x i32> [[VEC_PHI]]
; CHECK-NEXT:    [[INDEX_NEXT]] = add i64 [[INDEX]], 8
; CHECK-NEXT:    [[TMP14:%.*]] = icmp eq i64 [[INDEX_NEXT]], [[N_VEC]]
; CHECK-NEXT:    br i1 [[TMP14]], label [[MIDDLE_BLOCK:%.*]], label [[VECTOR_BODY]], !llvm.loop [[LOOP6:![0-9]+]]
; CHECK:       middle.block:
; CHECK-NEXT:    [[TMP15:%.*]] = call i32 @llvm.vector.reduce.add.v8i32(<8 x i32> [[TMP13]])
; CHECK-NEXT:    br i1 true, label [[FOR_COND_CLEANUP:%.*]], label [[SCALAR_PH]]
; CHECK:       scalar.ph:
; CHECK-NEXT:    [[BC_RESUME_VAL:%.*]] = phi i64 [ [[N_VEC]], [[MIDDLE_BLOCK]] ], [ 0, [[ENTRY:%.*]] ]
; CHECK-NEXT:    [[BC_MERGE_RDX:%.*]] = phi i32 [ 0, [[ENTRY]] ], [ [[TMP15]], [[MIDDLE_BLOCK]] ]
; CHECK-NEXT:    br label [[FOR_BODY:%.*]]
; CHECK:       for.body:
; CHECK-NEXT:    [[INDVARS_IV:%.*]] = phi i64 [ [[INDVARS_IV_NEXT:%.*]], [[FOR_BODY]] ], [ [[BC_RESUME_VAL]], [[SCALAR_PH]] ]
; CHECK-NEXT:    [[SUM_0:%.*]] = phi i32 [ [[SUM_1:%.*]], [[FOR_BODY]] ], [ [[BC_MERGE_RDX]], [[SCALAR_PH]] ]
; CHECK-NEXT:    [[INDVARS_IV_NEXT]] = add nuw nsw i64 [[INDVARS_IV]], 1
; CHECK-NEXT:    [[ARRAYIDXA:%.*]] = getelementptr inbounds i32, i32* [[A]], i64 [[INDVARS_IV]]
; CHECK-NEXT:    [[TMP16:%.*]] = load i32, i32* [[ARRAYIDXA]], align 4
; CHECK-NEXT:    [[ARRAYIDXB:%.*]] = getelementptr inbounds i32, i32* [[B]], i64 [[INDVARS_IV]]
; CHECK-NEXT:    [[TMP17:%.*]] = load i32, i32* [[ARRAYIDXB]], align 4
; CHECK-NEXT:    [[ADD:%.*]] = add nsw i32 [[TMP17]], [[TMP16]]
; CHECK-NEXT:    [[SUM_1]] = add nuw nsw i32 [[ADD]], [[SUM_0]]
; CHECK-NEXT:    [[LFTR_WIDEIV:%.*]] = trunc i64 [[INDVARS_IV_NEXT]] to i32
; CHECK-NEXT:    [[EXITCOND:%.*]] = icmp eq i32 [[LFTR_WIDEIV]], [[N]]
; CHECK-NEXT:    br i1 [[EXITCOND]], label [[FOR_COND_CLEANUP]], label [[FOR_BODY]], !llvm.loop [[LOOP7:![0-9]+]]
; CHECK:       for.cond.cleanup:
; CHECK-NEXT:    [[SUM_1_LCSSA:%.*]] = phi i32 [ [[SUM_1]], [[FOR_BODY]] ], [ [[TMP15]], [[MIDDLE_BLOCK]] ]
; CHECK-NEXT:    ret i32 [[SUM_1_LCSSA]]
;
entry:
  br label %for.body

for.body:
  %indvars.iv = phi i64 [ %indvars.iv.next, %for.body ], [ 0, %entry ]
  %sum.0 = phi i32 [ %sum.1, %for.body ], [ 0, %entry ]
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %arrayidxA = getelementptr inbounds i32, i32* %A, i64 %indvars.iv
  %0 = load i32, i32* %arrayidxA, align 4
  %arrayidxB = getelementptr inbounds i32, i32* %B, i64 %indvars.iv
  %1 = load i32, i32* %arrayidxB, align 4
  %add = add nsw i32 %1, %0
  %sum.1 = add nuw nsw i32 %add, %sum.0
  %lftr.wideiv = trunc i64 %indvars.iv.next to i32
  %exitcond = icmp eq i32 %lftr.wideiv, %N
  br i1 %exitcond, label %for.cond.cleanup, label %for.body

for.cond.cleanup:
  ret i32 %sum.1
}

; CHECK:      !0 = distinct !{!0, !1}
; CHECK-NEXT: !1 = !{!"llvm.loop.isvectorized", i32 1}
; CHECK-NEXT: !2 = distinct !{!2, !3, !1}
; CHECK-NEXT: !3 = !{!"llvm.loop.unroll.runtime.disable"}
; CHECK-NEXT: !4 = distinct !{!4, !1}
; CHECK-NEXT: !5 = distinct !{!5, !3, !1}

attributes #0 = { nounwind optsize uwtable "target-cpu"="core-avx2" "target-features"="+avx,+avx2" }

!6 = distinct !{!6, !7, !8}
!7 = !{!"llvm.loop.vectorize.predicate.enable", i1 true}
!8 = !{!"llvm.loop.vectorize.enable", i1 true}

!10 = distinct !{!10, !11, !12}
!11 = !{!"llvm.loop.vectorize.predicate.enable", i1 false}
!12 = !{!"llvm.loop.vectorize.enable", i1 true}
