// RUN: %clang_cc1 -internal-isystem %S/Inputs -disable-llvm-passes \
// RUN:    -triple spir64-unknown-unknown -fsycl-is-device -S \
// RUN:    -emit-llvm %s -o - | FileCheck %s
// RUN: %clang_cc1 -internal-isystem %S/Inputs -disable-llvm-passes \
// RUN:    -triple spir64-unknown-unknown -fsycl-is-device -DTEST_SCALAR -S \
// RUN:    -emit-llvm %s -o - | FileCheck %s

// Tests the generation of IR annotation calls from
// __sycl_detail__::add_ir_annotations_member attributes.

#include "mock_properties.hpp"
#include "sycl.hpp"

#ifdef TEST_SCALAR
#define TEST_T char
#else
#define TEST_T int *
#endif

template <typename... Properties> class g {
public:
  TEST_T x
#ifdef __SYCL_DEVICE_ONLY__
      [[__sycl_detail__::add_ir_annotations_member(Properties::name..., Properties::value...)]]
#endif
      ;

  g() : x() {}
  g(TEST_T _x) : x(_x) {}
};

class h {
public:
  TEST_T x
#ifdef __SYCL_DEVICE_ONLY__
      [[__sycl_detail__::add_ir_annotations_member(
          "Prop11", "Prop12", "Prop13", "Prop14", "Prop15", "Prop16", "Prop17",
          "Another property string", 2, false, TestEnum::Enum1, nullptr, nullptr, ScopedTestEnum::ScopedEnum2)]]
#endif
      ;

  h() : x() {}
  h(TEST_T _x) : x(_x) {}
};

template <typename... Properties> class gh {
public:
  TEST_T x
#ifdef __SYCL_DEVICE_ONLY__
      [[__sycl_detail__::add_ir_annotations_member(
          Properties::name..., "Prop11", "Prop12", "Prop13", "Prop14", "Prop15", "Prop16", "Prop17",
          Properties::value..., "Another property string", 2, false, TestEnum::Enum1, nullptr, nullptr, ScopedTestEnum::ScopedEnum2)]]
#endif
      ;

  gh() : x() {}
  gh(TEST_T _x) : x(_x) {}
};

template <typename... Properties> class hg {
public:
  TEST_T x
#ifdef __SYCL_DEVICE_ONLY__
      [[__sycl_detail__::add_ir_annotations_member(
          "Prop11", "Prop12", "Prop13", "Prop14", "Prop15", "Prop16", "Prop17", Properties::name...,
          "Another property string", 2, false, TestEnum::Enum1, nullptr, nullptr, ScopedTestEnum::ScopedEnum2, Properties::value...)]]
#endif
      ;

  hg() : x() {}
  hg(TEST_T _x) : x(_x) {}
};

int main() {
  sycl::queue q;
  g<prop1, prop2, prop3, prop4, prop5, prop6, prop7> a;
  q.submit([&](sycl::handler &h) {
    h.single_task<class test_kernel1>(
        [=]() {
          (void)a.x;
        });
  });
  h b;
  q.submit([&](sycl::handler &h) {
    h.single_task<class test_kernel2>(
        [=]() {
          (void)b.x;
        });
  });
  gh<prop1, prop2, prop3, prop4, prop5, prop6, prop7> c;
  q.submit([&](sycl::handler &h) {
    h.single_task<class test_kernel3>(
        [=]() {
          (void)c.x;
        });
  });
  hg<prop1, prop2, prop3, prop4, prop5, prop6, prop7> d;
  q.submit([&](sycl::handler &h) {
    h.single_task<class test_kernel4>(
        [=]() {
          (void)d.x;
        });
  });
}

// CHECK-DAG: @[[AnnotName:.*]] = private unnamed_addr constant [16 x i8] c"sycl-properties\00", section "llvm.metadata"

// CHECK-DAG: @[[Prop1Name:.*]] = private unnamed_addr constant [6 x i8] c"Prop1\00", section "llvm.metadata"
// CHECK-DAG: @[[Prop2Name:.*]] = private unnamed_addr constant [6 x i8] c"Prop2\00", section "llvm.metadata"
// CHECK-DAG: @[[Prop3Name:.*]] = private unnamed_addr constant [6 x i8] c"Prop3\00", section "llvm.metadata"
// CHECK-DAG: @[[Prop4Name:.*]] = private unnamed_addr constant [6 x i8] c"Prop4\00", section "llvm.metadata"
// CHECK-DAG: @[[Prop5Name:.*]] = private unnamed_addr constant [6 x i8] c"Prop5\00", section "llvm.metadata"
// CHECK-DAG: @[[Prop6Name:.*]] = private unnamed_addr constant [6 x i8] c"Prop6\00", section "llvm.metadata"
// CHECK-DAG: @[[Prop7Name:.*]] = private unnamed_addr constant [6 x i8] c"Prop7\00", section "llvm.metadata"
// CHECK-DAG: @[[Prop11Name:.*]] = private unnamed_addr constant [7 x i8] c"Prop11\00", section "llvm.metadata"
// CHECK-DAG: @[[Prop12Name:.*]] = private unnamed_addr constant [7 x i8] c"Prop12\00", section "llvm.metadata"
// CHECK-DAG: @[[Prop13Name:.*]] = private unnamed_addr constant [7 x i8] c"Prop13\00", section "llvm.metadata"
// CHECK-DAG: @[[Prop14Name:.*]] = private unnamed_addr constant [7 x i8] c"Prop14\00", section "llvm.metadata"
// CHECK-DAG: @[[Prop15Name:.*]] = private unnamed_addr constant [7 x i8] c"Prop15\00", section "llvm.metadata"
// CHECK-DAG: @[[Prop16Name:.*]] = private unnamed_addr constant [7 x i8] c"Prop16\00", section "llvm.metadata"
// CHECK-DAG: @[[Prop17Name:.*]] = private unnamed_addr constant [7 x i8] c"Prop17\00", section "llvm.metadata"

// CHECK-DAG: @[[Prop1Value:.*]] = private unnamed_addr constant [16 x i8] c"Property string\00", section "llvm.metadata"
// CHECK-DAG: @[[Prop2_7_14Value:.*]] = private unnamed_addr constant [2 x i8] c"1\00", section "llvm.metadata"
// CHECK-DAG: @[[Prop3Value:.*]] = private unnamed_addr constant [5 x i8] c"true\00", section "llvm.metadata"
// CHECK-DAG: @[[Prop4_12_17Value:.*]] = private unnamed_addr constant [2 x i8] c"2\00", section "llvm.metadata"
// CHECK-DAG: @[[Prop11Value:.*]] = private unnamed_addr constant [24 x i8] c"Another property string\00", section "llvm.metadata"
// CHECK-DAG: @[[Prop13Value:.*]] = private unnamed_addr constant [6 x i8] c"false\00", section "llvm.metadata"

// CHECK-DAG: @[[GArgs:.*]] = private unnamed_addr constant { [6 x i8]*, [16 x i8]*, [6 x i8]*, [2 x i8]*, [6 x i8]*, [5 x i8]*, [6 x i8]*, [2 x i8]*, [6 x i8]*, i8*, [6 x i8]*, i8*, [6 x i8]*, [2 x i8]* } { [6 x i8]* @[[Prop1Name]], [16 x i8]* @[[Prop1Value]], [6 x i8]* @[[Prop2Name]], [2 x i8]* @[[Prop2_7_14Value]], [6 x i8]* @[[Prop3Name]], [5 x i8]* @[[Prop3Value]], [6 x i8]* @[[Prop4Name]], [2 x i8]* @[[Prop4_12_17Value]], [6 x i8]* @[[Prop5Name]], i8* null, [6 x i8]* @[[Prop6Name]], i8* null, [6 x i8]* @[[Prop7Name]], [2 x i8]* @[[Prop2_7_14Value]] }, section "llvm.metadata"
// CHECK-DAG: @[[HArgs:.*]] = private unnamed_addr constant { [7 x i8]*, [24 x i8]*, [7 x i8]*, [2 x i8]*, [7 x i8]*, [6 x i8]*, [7 x i8]*, [2 x i8]*, [7 x i8]*, i8*, [7 x i8]*, i8*, [7 x i8]*, [2 x i8]* } { [7 x i8]* @[[Prop11Name]], [24 x i8]* @[[Prop11Value]], [7 x i8]* @[[Prop12Name]], [2 x i8]* @[[Prop4_12_17Value]], [7 x i8]* @[[Prop13Name]], [6 x i8]* @[[Prop13Value]], [7 x i8]* @[[Prop14Name]], [2 x i8]* @[[Prop2_7_14Value]], [7 x i8]* @[[Prop15Name]], i8* null, [7 x i8]* @[[Prop16Name]], i8* null, [7 x i8]* @[[Prop17Name]], [2 x i8]* @[[Prop4_12_17Value]] }, section "llvm.metadata"
// CHECK-DAG: @[[GHArgs:.*]] = private unnamed_addr constant { [6 x i8]*, [16 x i8]*, [6 x i8]*, [2 x i8]*, [6 x i8]*, [5 x i8]*, [6 x i8]*, [2 x i8]*, [6 x i8]*, i8*, [6 x i8]*, i8*, [6 x i8]*, [2 x i8]*, [7 x i8]*, [24 x i8]*, [7 x i8]*, [2 x i8]*, [7 x i8]*, [6 x i8]*, [7 x i8]*, [2 x i8]*, [7 x i8]*, i8*, [7 x i8]*, i8*, [7 x i8]*, [2 x i8]* } { [6 x i8]* @[[Prop1Name]], [16 x i8]* @[[Prop1Value]], [6 x i8]* @[[Prop2Name]], [2 x i8]* @[[Prop2_7_14Value]], [6 x i8]* @[[Prop3Name]], [5 x i8]* @[[Prop3Value]], [6 x i8]* @[[Prop4Name]], [2 x i8]* @[[Prop4_12_17Value]], [6 x i8]* @[[Prop5Name]], i8* null, [6 x i8]* @[[Prop6Name]], i8* null, [6 x i8]* @[[Prop7Name]], [2 x i8]* @[[Prop2_7_14Value]], [7 x i8]* @[[Prop11Name]], [24 x i8]* @[[Prop11Value]], [7 x i8]* @[[Prop12Name]], [2 x i8]* @[[Prop4_12_17Value]], [7 x i8]* @[[Prop13Name]], [6 x i8]* @[[Prop13Value]], [7 x i8]* @[[Prop14Name]], [2 x i8]* @[[Prop2_7_14Value]], [7 x i8]* @[[Prop15Name]], i8* null, [7 x i8]* @[[Prop16Name]], i8* null, [7 x i8]* @[[Prop17Name]], [2 x i8]* @[[Prop4_12_17Value]] }, section "llvm.metadata"
// CHECK-DAG: @[[HGArgs:.*]] = private unnamed_addr constant { [7 x i8]*, [24 x i8]*, [7 x i8]*, [2 x i8]*, [7 x i8]*, [6 x i8]*, [7 x i8]*, [2 x i8]*, [7 x i8]*, i8*, [7 x i8]*, i8*, [7 x i8]*, [2 x i8]*, [6 x i8]*, [16 x i8]*, [6 x i8]*, [2 x i8]*, [6 x i8]*, [5 x i8]*, [6 x i8]*, [2 x i8]*, [6 x i8]*, i8*, [6 x i8]*, i8*, [6 x i8]*, [2 x i8]* } { [7 x i8]* @[[Prop11Name]], [24 x i8]* @[[Prop11Value]], [7 x i8]* @[[Prop12Name]], [2 x i8]* @[[Prop4_12_17Value]], [7 x i8]* @[[Prop13Name]], [6 x i8]* @[[Prop13Value]], [7 x i8]* @[[Prop14Name]], [2 x i8]* @[[Prop2_7_14Value]], [7 x i8]* @[[Prop15Name]], i8* null, [7 x i8]* @[[Prop16Name]], i8* null, [7 x i8]* @[[Prop17Name]], [2 x i8]* @[[Prop4_12_17Value]], [6 x i8]* @[[Prop1Name]], [16 x i8]* @[[Prop1Value]], [6 x i8]* @[[Prop2Name]], [2 x i8]* @[[Prop2_7_14Value]], [6 x i8]* @[[Prop3Name]], [5 x i8]* @[[Prop3Value]], [6 x i8]* @[[Prop4Name]], [2 x i8]* @[[Prop4_12_17Value]], [6 x i8]* @[[Prop5Name]], i8* null, [6 x i8]* @[[Prop6Name]], i8* null, [6 x i8]* @[[Prop7Name]], [2 x i8]* @[[Prop2_7_14Value]] }, section "llvm.metadata"

// CHECK-DAG: %{{.*}} = call i8 addrspace(4)* @llvm.ptr.annotation.p4i8(i8 {{.*}}, i8* getelementptr inbounds ([16 x i8], [16 x i8]* @[[AnnotName]], i32 0, i32 0), i8* getelementptr inbounds {{.*}}, i32 {{.*}}, i8* bitcast ({ [6 x i8]*, [16 x i8]*, [6 x i8]*, [2 x i8]*, [6 x i8]*, [5 x i8]*, [6 x i8]*, [2 x i8]*, [6 x i8]*, i8*, [6 x i8]*, i8*, [6 x i8]*, [2 x i8]* }* @[[GArgs]] to i8*))
// CHECK-DAG: %{{.*}} = call i8 addrspace(4)* @llvm.ptr.annotation.p4i8(i8 {{.*}}, i8* getelementptr inbounds ([16 x i8], [16 x i8]* @[[AnnotName]], i32 0, i32 0), i8* getelementptr inbounds {{.*}}, i32 {{.*}}, i8* bitcast ({ [7 x i8]*, [24 x i8]*, [7 x i8]*, [2 x i8]*, [7 x i8]*, [6 x i8]*, [7 x i8]*, [2 x i8]*, [7 x i8]*, i8*, [7 x i8]*, i8*, [7 x i8]*, [2 x i8]* }* @[[HArgs]] to i8*))
// CHECK-DAG: %{{.*}} = call i8 addrspace(4)* @llvm.ptr.annotation.p4i8(i8 {{.*}}, i8* getelementptr inbounds ([16 x i8], [16 x i8]* @[[AnnotName]], i32 0, i32 0), i8* getelementptr inbounds {{.*}}, i32 {{.*}}, i8* bitcast ({ [6 x i8]*, [16 x i8]*, [6 x i8]*, [2 x i8]*, [6 x i8]*, [5 x i8]*, [6 x i8]*, [2 x i8]*, [6 x i8]*, i8*, [6 x i8]*, i8*, [6 x i8]*, [2 x i8]*, [7 x i8]*, [24 x i8]*, [7 x i8]*, [2 x i8]*, [7 x i8]*, [6 x i8]*, [7 x i8]*, [2 x i8]*, [7 x i8]*, i8*, [7 x i8]*, i8*, [7 x i8]*, [2 x i8]* }* @[[GHArgs]] to i8*))
// CHECK-DAG: %{{.*}} = call i8 addrspace(4)* @llvm.ptr.annotation.p4i8(i8 {{.*}}, i8* getelementptr inbounds ([16 x i8], [16 x i8]* @[[AnnotName]], i32 0, i32 0), i8* getelementptr inbounds {{.*}}, i32 {{.*}}, i8* bitcast ({ [7 x i8]*, [24 x i8]*, [7 x i8]*, [2 x i8]*, [7 x i8]*, [6 x i8]*, [7 x i8]*, [2 x i8]*, [7 x i8]*, i8*, [7 x i8]*, i8*, [7 x i8]*, [2 x i8]*, [6 x i8]*, [16 x i8]*, [6 x i8]*, [2 x i8]*, [6 x i8]*, [5 x i8]*, [6 x i8]*, [2 x i8]*, [6 x i8]*, i8*, [6 x i8]*, i8*, [6 x i8]*, [2 x i8]* }* @[[HGArgs]] to i8*))
