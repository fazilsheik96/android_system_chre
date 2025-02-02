#
# Copyright 2019 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

LOCAL_PATH := $(call my-dir)

# Don't build the daemon for targets that don't contain a vendor image as
# libsdsprpc and libadsprpc are provided by vendor code
ifeq ($(BUILDING_VENDOR_IMAGE),true)

ifeq ($(CHRE_DAEMON_ENABLED),true)

include $(CLEAR_VARS)

# CHRE AP-side daemon
# NOTE: This can't be converted to a blueprint file until libsdsprpc /
# libadsprpc is converted as blueprint targets can't depend on targets exposed
# by makefiles
LOCAL_MODULE := chre
LOCAL_LICENSE_KINDS := SPDX-license-identifier-Apache-2.0 SPDX-license-identifier-BSD
LOCAL_LICENSE_CONDITIONS := notice
LOCAL_NOTICE_FILE := $(LOCAL_PATH)/NOTICE
LOCAL_MODULE_OWNER := google
LOCAL_MODULE_TAGS := optional
LOCAL_VENDOR_MODULE := true
LOCAL_INIT_RC := chre_daemon.rc

LOCAL_CPP_EXTENSION := .cc
LOCAL_CFLAGS += -Wall -Werror -Wextra
LOCAL_CFLAGS += -DCHRE_DAEMON_METRIC_ENABLED

LOCAL_TIDY_CHECKS := -google-runtime-int

# Enable the LPMA feature for devices that support audio
ifeq ($(CHRE_DAEMON_LPMA_ENABLED),true)
LOCAL_CFLAGS += -DCHRE_DAEMON_LPMA_ENABLED
endif

ifeq ($(CHRE_DAEMON_LOAD_INTO_SENSORSPD),true)
LOCAL_CFLAGS += -DCHRE_DAEMON_LOAD_INTO_SENSORSPD
endif

MSM_SRC_FILES := \
    host/common/fbs_daemon_base.cc \
    host/msm/daemon/fastrpc_daemon.cc \
    host/msm/daemon/main.cc \
    host/msm/daemon/generated/chre_slpi_stub.c

MSM_INCLUDES := \
    system/chre/host/msm/daemon

LOCAL_SRC_FILES := \
    host/common/daemon_base.cc \
    host/common/config_util.cc \
    host/common/file_stream.cc \
    host/common/fragmented_load_transaction.cc \
    host/common/host_protocol_host.cc \
    host/common/log_message_parser.cc \
    host/common/socket_server.cc \
    host/common/st_hal_lpma_handler.cc \
    platform/shared/host_protocol_common.cc

LOCAL_C_INCLUDES := \
    external/fastrpc/inc \
    system/chre/external/flatbuffers/include \
    system/chre/host/common/include \
    system/chre/platform/shared/include \
    system/chre/platform/slpi/include \
    system/chre/util/include \
    system/libbase/include \
    system/core/libcutils/include \
    system/logging/liblog/include \
    system/core/libutils/include

LOCAL_SHARED_LIBRARIES := \
    libjsoncpp \
    libutils \
    libcutils \
    liblog \
    libhidlbase \
    libbase \
    android.hardware.soundtrigger@2.0 \
    libpower \
    libprotobuf-cpp-lite \
    pixelatoms-cpp \
    android.frameworks.stats-V1-ndk \
    libbinder_ndk

LOCAL_SRC_FILES += $(MSM_SRC_FILES)
LOCAL_C_INCLUDES += $(MSM_INCLUDES)

LOCAL_CPPFLAGS += -std=c++20
LOCAL_CFLAGS += -Wno-sign-compare
LOCAL_CFLAGS += -Wno-c++11-narrowing
LOCAL_CFLAGS += -Wno-deprecated-volatile
PIGWEED_DIR = external/pigweed
PIGWEED_DIR_RELPATH = ../../$(PIGWEED_DIR)
LOCAL_CFLAGS += -I$(PIGWEED_DIR)/pw_bytes/public
LOCAL_CFLAGS += -I$(PIGWEED_DIR)/pw_polyfill/public
LOCAL_CFLAGS += -I$(PIGWEED_DIR)/pw_polyfill/public_overrides
LOCAL_CFLAGS += -I$(PIGWEED_DIR)/pw_polyfill/standard_library_public
LOCAL_CFLAGS += -I$(PIGWEED_DIR)/pw_preprocessor/public
LOCAL_CFLAGS += -I$(PIGWEED_DIR)/pw_tokenizer/public
LOCAL_CFLAGS += -I$(PIGWEED_DIR)/pw_varint/public
LOCAL_CFLAGS += -I$(PIGWEED_DIR)/pw_span/public

LOCAL_SRC_FILES += $(PIGWEED_DIR_RELPATH)/pw_tokenizer/detokenize.cc
LOCAL_SRC_FILES += $(PIGWEED_DIR_RELPATH)/pw_tokenizer/decode.cc
LOCAL_SRC_FILES += $(PIGWEED_DIR_RELPATH)/pw_varint/varint.cc

ifeq ($(CHRE_DAEMON_USE_SDSPRPC),true)
LOCAL_SHARED_LIBRARIES += libsdsprpc
else
LOCAL_SHARED_LIBRARIES += libadsprpc
endif

include $(BUILD_EXECUTABLE)

endif   # CHRE_DAEMON_ENABLED
endif   # BUILDING_VENDOR_IMAGE
