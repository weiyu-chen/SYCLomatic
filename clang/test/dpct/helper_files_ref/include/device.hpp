//==---- device.hpp -------------------------------*- C++ -*----------------==//
//
// Copyright (C) Intel Corporation
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
// See https://llvm.org/LICENSE.txt for license information.
//
//===----------------------------------------------------------------------===//

#ifndef __DPCT_DEVICE_HPP__
#define __DPCT_DEVICE_HPP__

#include <CL/sycl.hpp>
#include <algorithm>
#include <cstring>
#include <iostream>
#include <mutex>
#include <set>
#include <sstream>
#include <map>
#include <vector>
#include <thread>
#if defined(__linux__)
#include <unistd.h>
#include <sys/syscall.h>
#endif
#if defined(_WIN64)
#define NOMINMAX
#include <windows.h>
#endif


namespace dpct {

/// SYCL default exception handler
auto exception_handler = [](cl::sycl::exception_list exceptions) {
  for (std::exception_ptr const &e : exceptions) {
    try {
      std::rethrow_exception(e);
    } catch (cl::sycl::exception const &e) {
      std::cerr << "Caught asynchronous SYCL exception:" << std::endl
                << e.what() << std::endl
                << "Exception caught at file:" << __FILE__
                << ", line:" << __LINE__ << std::endl;
    }
  }
};

typedef cl::sycl::event *event_ptr;

/// Destroy \p event pointed memory.
///
/// \param event Pointer to the sycl::event address.
static void destroy_event(event_ptr event) {
    delete event;
}

class device_info {
public:
  // get interface
  const char *get_name() const { return _name; }
  char *get_name() { return _name; }
  template <typename WorkItemSizesTy = cl::sycl::id<3>,
            std::enable_if_t<std::is_same_v<WorkItemSizesTy, cl::sycl::id<3>> ||
                                 std::is_same_v<WorkItemSizesTy, int *>,
                             int> = 0>
  auto get_max_work_item_sizes() const {
    if constexpr (std::is_same_v<WorkItemSizesTy, cl::sycl::id<3>>)
      return _max_work_item_sizes;
    else
      return _max_work_item_sizes_i;
  }
  template <typename WorkItemSizesTy = cl::sycl::id<3>,
            std::enable_if_t<std::is_same_v<WorkItemSizesTy, cl::sycl::id<3>> ||
                                 std::is_same_v<WorkItemSizesTy, int *>,
                             int> = 0>
  auto get_max_work_item_sizes() {
    if constexpr (std::is_same_v<WorkItemSizesTy, cl::sycl::id<3>>)
      return _max_work_item_sizes;
    else
      return _max_work_item_sizes_i;
  }
  bool get_host_unified_memory() const { return _host_unified_memory; }
  int get_major_version() const { return _major; }
  int get_minor_version() const { return _minor; }
  int get_integrated() const { return _integrated; }
  int get_max_clock_frequency() const { return _frequency; }
  int get_max_compute_units() const { return _max_compute_units; }
  int get_max_work_group_size() const { return _max_work_group_size; }
  int get_max_sub_group_size() const { return _max_sub_group_size; }
  int get_max_work_items_per_compute_unit() const {
    return _max_work_items_per_compute_unit;
  }
  template <typename NDRangeSizeTy = size_t *,
            std::enable_if_t<std::is_same_v<NDRangeSizeTy, size_t *> ||
                                 std::is_same_v<NDRangeSizeTy, int *>,
                             int> = 0>
  auto get_max_nd_range_size() const {
    if constexpr (std::is_same_v<NDRangeSizeTy, size_t *>)
      return _max_nd_range_size;
    else
      return _max_nd_range_size_i;
  }
  template <typename NDRangeSizeTy = size_t *,
            std::enable_if_t<std::is_same_v<NDRangeSizeTy, size_t *> ||
                                 std::is_same_v<NDRangeSizeTy, int *>,
                             int> = 0>
  auto get_max_nd_range_size() {
    if constexpr (std::is_same_v<NDRangeSizeTy, size_t *>)
      return _max_nd_range_size;
    else
      return _max_nd_range_size_i;
  }
  size_t get_global_mem_size() const { return _global_mem_size; }
  size_t get_local_mem_size() const { return _local_mem_size; }
  // set interface
  void set_name(const char *name) { std::strncpy(_name, name, 256); }
  void set_max_work_item_sizes(const cl::sycl::id<3> max_work_item_sizes) {
    _max_work_item_sizes = max_work_item_sizes;
    for (int i = 0; i < 3; ++i)
      _max_work_item_sizes_i[i] = max_work_item_sizes[i];
  }
  void set_host_unified_memory(bool host_unified_memory) {
    _host_unified_memory = host_unified_memory;
  }
  void set_major_version(int major) { _major = major; }
  void set_minor_version(int minor) { _minor = minor; }
  void set_integrated(int integrated) { _integrated = integrated; }
  void set_max_clock_frequency(int frequency) { _frequency = frequency; }
  void set_max_compute_units(int max_compute_units) {
    _max_compute_units = max_compute_units;
  }
  void set_global_mem_size(size_t global_mem_size) {
    _global_mem_size = global_mem_size;
  }
  void set_local_mem_size(size_t local_mem_size) {
    _local_mem_size = local_mem_size;
  }
  void set_max_work_group_size(int max_work_group_size) {
    _max_work_group_size = max_work_group_size;
  }
  void set_max_sub_group_size(int max_sub_group_size) {
    _max_sub_group_size = max_sub_group_size;
  }
  void
  set_max_work_items_per_compute_unit(int max_work_items_per_compute_unit) {
    _max_work_items_per_compute_unit = max_work_items_per_compute_unit;
  }
  void set_max_nd_range_size(int max_nd_range_size[]) {
    for (int i = 0; i < 3; i++) {
      _max_nd_range_size[i] = max_nd_range_size[i];
      _max_nd_range_size_i[i] = max_nd_range_size[i];
    }
  }

private:
  char _name[256];
  cl::sycl::id<3> _max_work_item_sizes;
  int _max_work_item_sizes_i[3];
  bool _host_unified_memory = false;
  int _major;
  int _minor;
  int _integrated = 0;
  int _frequency;
  int _max_compute_units;
  int _max_work_group_size;
  int _max_sub_group_size;
  int _max_work_items_per_compute_unit;
  size_t _global_mem_size;
  size_t _local_mem_size;
  size_t _max_nd_range_size[3];
  int _max_nd_range_size_i[3];
};

/// dpct device extension
class device_ext : public cl::sycl::device {
public:
  device_ext() : cl::sycl::device(), _ctx(*this) {}
  ~device_ext() {
    std::lock_guard<std::mutex> lock(m_mutex);
    for (auto &task : _tasks) {
      if (task.joinable())
        task.join();
    }
    _tasks.clear();
    _queues.clear();
  }
  device_ext(const cl::sycl::device &base)
      : cl::sycl::device(base), _ctx(*this) {
#ifdef DPCT_USM_LEVEL_NONE
    _queues.push_back(
        std::make_shared<cl::sycl::queue>(_ctx, base, exception_handler));
#else
    _queues.push_back(std::make_shared<cl::sycl::queue>(
        _ctx, base, exception_handler, cl::sycl::property::queue::in_order()));
#endif
    _saved_queue = _default_queue = _queues[0].get();
  }

  int is_native_atomic_supported() { return 0; }
  int get_major_version() const {
    int major, minor;
    get_version(major, minor);
    return major;
  }

  int get_minor_version() const {
    int major, minor;
    get_version(major, minor);
    return minor;
  }

  int get_max_compute_units() const {
    return get_device_info().get_max_compute_units();
  }

  int get_max_clock_frequency() const {
    return get_device_info().get_max_clock_frequency();
  }

  int get_integrated() const { return get_device_info().get_integrated(); }

  void get_device_info(device_info &out) const {
    device_info prop;
    prop.set_name(get_info<cl::sycl::info::device::name>().c_str());

    int major, minor;
    get_version(major, minor);
    prop.set_major_version(major);
    prop.set_minor_version(minor);

    prop.set_max_work_item_sizes(
        get_info<cl::sycl::info::device::max_work_item_sizes>());
    prop.set_host_unified_memory(
        get_info<cl::sycl::info::device::host_unified_memory>());

    // max_clock_frequency parameter is not supported on host device
    if (is_host()) {
      // This code may need to be updated. Currently max_clock_frequency for
      // host device is initialized with 1, in assumption that if other devices
      // exist and they are being selected based on this parameter, other
      // devices would have higher priority.
      prop.set_max_clock_frequency(1);
    } else {
      prop.set_max_clock_frequency(
          get_info<cl::sycl::info::device::max_clock_frequency>());
    }

    prop.set_max_compute_units(
        get_info<cl::sycl::info::device::max_compute_units>());
    prop.set_max_work_group_size(
        get_info<cl::sycl::info::device::max_work_group_size>());
    prop.set_global_mem_size(
        get_info<cl::sycl::info::device::global_mem_size>());
    prop.set_local_mem_size(get_info<cl::sycl::info::device::local_mem_size>());

    size_t max_sub_group_size = 1;
    std::vector<size_t> sub_group_sizes =
        get_info<cl::sycl::info::device::sub_group_sizes>();

    for (const auto &sub_group_size : sub_group_sizes) {
      if (max_sub_group_size < sub_group_size)
        max_sub_group_size = sub_group_size;
    }

    prop.set_max_sub_group_size(max_sub_group_size);

    prop.set_max_work_items_per_compute_unit(
        get_info<cl::sycl::info::device::max_work_group_size>());
    int max_nd_range_size[] = {0x7FFFFFFF, 0x7FFFFFFF, 0x7FFFFFFF};
    prop.set_max_nd_range_size(max_nd_range_size);

    out = prop;
  }

  device_info get_device_info() const {
    device_info prop;
    get_device_info(prop);
    return prop;
  }

  void reset() {
    std::lock_guard<std::mutex> lock(m_mutex);
    // The queues are shared_ptrs and the ref counts of the shared_ptrs increase
    // only in wait_and_throw(). If there is no other thread calling
    // wait_and_throw(), the queues will be destructed. The destructor waits for
    // all commands executing on the queue to complete. It isn't possible to
    // destroy a queue immediately. This is a synchronization point in SYCL.
    _queues.clear();
    // create new default queue.
#ifdef DPCT_USM_LEVEL_NONE
    _queues.push_back(
        std::make_shared<cl::sycl::queue>(_ctx, *this, exception_handler));
#else
    _queues.push_back(std::make_shared<cl::sycl::queue>(
        _ctx, *this, exception_handler, cl::sycl::property::queue::in_order()));
#endif
    _saved_queue = _default_queue = _queues.front().get();
  }

  cl::sycl::queue &default_queue() { return *_default_queue; }

  void queues_wait_and_throw() {
    std::unique_lock<std::mutex> lock(m_mutex);
    std::vector<std::shared_ptr<cl::sycl::queue>> current_queues(
        _queues);
    lock.unlock();
    for (const auto &q : current_queues) {
      q->wait_and_throw();
    }
    // Guard the destruct of current_queues to make sure the ref count is safe.
    lock.lock();
  }
  cl::sycl::queue *create_queue(bool enable_exception_handler = false) {
    std::lock_guard<std::mutex> lock(m_mutex);
    cl::sycl::async_handler eh = {};
    if (enable_exception_handler) {
      eh = exception_handler;
    }
#ifdef DPCT_USM_LEVEL_NONE
    _queues.push_back(std::make_shared<cl::sycl::queue>(
        _ctx, *this, eh));
#else
    _queues.push_back(std::make_shared<cl::sycl::queue>(
        _ctx, *this, eh,
        cl::sycl::property::queue::in_order()));
#endif
    return _queues.back().get();
  }
  void destroy_queue(cl::sycl::queue *&queue) {
    std::lock_guard<std::mutex> lock(m_mutex);
    _queues.erase(std::remove_if(_queues.begin(), _queues.end(),
                                  [=](const std::shared_ptr<cl::sycl::queue> &q) -> bool {
                                    return q.get() == queue;
                                  }),
                   _queues.end());
    queue = nullptr;
  }
  void set_saved_queue(cl::sycl::queue* q) {
    std::lock_guard<std::mutex> lock(m_mutex);
    _saved_queue = q;
  }
  cl::sycl::queue* get_saved_queue() const {
    std::lock_guard<std::mutex> lock(m_mutex);
    return _saved_queue;
  }
  cl::sycl::context get_context() const { return _ctx; }

private:
  void get_version(int &major, int &minor) const {
    // Version string has the following format:
    // a. OpenCL<space><major.minor><space><vendor-specific-information>
    // b. <major.minor>
    std::string ver;
    ver = get_info<cl::sycl::info::device::version>();
    std::string::size_type i = 0;
    while (i < ver.size()) {
      if (isdigit(ver[i]))
        break;
      i++;
    }
    major = std::stoi(&(ver[i]));
    while (i < ver.size()) {
      if (ver[i] == '.')
        break;
      i++;
    }
    i++;
    minor = std::stoi(&(ver[i]));
  }
  void add_task(std::thread &&task) {
    std::lock_guard<std::mutex> lock(m_mutex);
    _tasks.push_back(std::move(task));
  }
  friend void async_dpct_free(std::vector<void *>,
                              std::vector<cl::sycl::event>,
                              cl::sycl::queue &);
  cl::sycl::queue *_default_queue;
  cl::sycl::queue *_saved_queue;
  cl::sycl::context _ctx;
  std::vector<std::shared_ptr<cl::sycl::queue>> _queues;
  mutable std::mutex m_mutex;
  std::vector<std::thread> _tasks;
};

static inline unsigned int get_tid() {
#if defined(__linux__)
  return syscall(SYS_gettid);
#elif defined(_WIN64)
  return GetCurrentThreadId();
#else
#error "Only support Windows and Linux."
#endif
}

/// device manager
class dev_mgr {
public:
  device_ext &current_device() {
    unsigned int dev_id=current_device_id();
    check_id(dev_id);
    return *_devs[dev_id];
  }
  device_ext &cpu_device() const {
    std::lock_guard<std::mutex> lock(m_mutex);
    if (_cpu_device == -1) {
      throw std::runtime_error("no valid cpu device");
    } else {
      return *_devs[_cpu_device];
    }
  }
  device_ext &get_device(unsigned int id) const {
    std::lock_guard<std::mutex> lock(m_mutex);
    check_id(id);
    return *_devs[id];
  }
  unsigned int current_device_id() const {
   std::lock_guard<std::mutex> lock(m_mutex);
   auto it=_thread2dev_map.find(get_tid());
   if(it != _thread2dev_map.end())
      return it->second;
    return DEFAULT_DEVICE_ID;
  }
  void select_device(unsigned int id) {
    std::lock_guard<std::mutex> lock(m_mutex);
    check_id(id);
    _thread2dev_map[get_tid()]=id;
  }
  unsigned int device_count() { return _devs.size(); }

  /// Returns the instance of device manager singleton.
  static dev_mgr &instance() {
    static dev_mgr d_m;
    return d_m;
  }
  dev_mgr(const dev_mgr &) = delete;
  dev_mgr &operator=(const dev_mgr &) = delete;
  dev_mgr(dev_mgr &&) = delete;
  dev_mgr &operator=(dev_mgr &&) = delete;

private:
  mutable std::mutex m_mutex;
  dev_mgr() {
    cl::sycl::device default_device =
        cl::sycl::device(cl::sycl::default_selector{});
    _devs.push_back(std::make_shared<device_ext>(default_device));

    std::vector<cl::sycl::device> sycl_all_devs =
        cl::sycl::device::get_devices(cl::sycl::info::device_type::all);
    // Collect other devices except for the default device.
    if (default_device.is_cpu())
      _cpu_device = 0;
    for (auto &dev : sycl_all_devs) {
      if (dev == default_device) {
        continue;
      }
      _devs.push_back(std::make_shared<device_ext>(dev));
      if (_cpu_device == -1 && dev.is_cpu()) {
        _cpu_device = _devs.size() - 1;
      }
    }
  }
  void check_id(unsigned int id) const {
    if (id >= _devs.size()) {
      throw std::runtime_error("invalid device id");
    }
  }
  std::vector<std::shared_ptr<device_ext>> _devs;
  /// DEFAULT_DEVICE_ID is used, if current_device_id() can not find current
  /// thread id in _thread2dev_map, which means default device should be used
  /// for the current thread.
  const unsigned int DEFAULT_DEVICE_ID = 0;
  /// thread-id to device-id map.
  std::map<unsigned int, unsigned int> _thread2dev_map;
  int _cpu_device = -1;
};

/// Util function to get the default queue of current device in
/// dpct device manager.
static inline cl::sycl::queue &get_default_queue() {
  return dev_mgr::instance().current_device().default_queue();
}

/// Util function to get the current device.
static inline device_ext &get_current_device() {
  return dev_mgr::instance().current_device();
}

/// Util function to get a device by id.
static inline device_ext &get_device(unsigned int id) {
  return dev_mgr::instance().get_device(id);
}

/// Util function to get the context of the default queue of current
/// device in dpct device manager.
static inline cl::sycl::context get_default_context() {
  return dpct::get_current_device().get_context();
}

/// Util function to get a CPU device.
static inline device_ext &cpu_device() {
  return dev_mgr::instance().cpu_device();
}

static inline unsigned int select_device(unsigned int id){
  dev_mgr::instance().select_device(id);
  return id;
}

} // namespace dpct

#endif // __DPCT_DEVICE_HPP__
