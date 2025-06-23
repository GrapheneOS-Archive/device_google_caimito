#
# Copyright (C) 2021 The Android Open-Source Project
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

SHIPPING_API_LEVEL := 34

ifdef RELEASE_GOOGLE_CAIMAN_RADIO_DIR
RELEASE_GOOGLE_PRODUCT_RADIO_DIR := $(RELEASE_GOOGLE_CAIMAN_RADIO_DIR)
endif
ifdef RELEASE_GOOGLE_CAIMAN_RADIOCFG_DIR
RELEASE_GOOGLE_PRODUCT_RADIOCFG_DIR := $(RELEASE_GOOGLE_CAIMAN_RADIOCFG_DIR)
endif
RELEASE_GOOGLE_BOOTLOADER_CAIMAN_DIR ?= 24D1# Keep this for pdk TODO: b/327119000
RELEASE_GOOGLE_PRODUCT_BOOTLOADER_DIR := bootloader/$(RELEASE_GOOGLE_BOOTLOADER_CAIMAN_DIR)
$(call soong_config_set,caimito_bootloader,prebuilt_dir,$(RELEASE_GOOGLE_BOOTLOADER_CAIMAN_DIR))

ifdef RELEASE_KERNEL_CAIMAN_VERSION
TARGET_LINUX_KERNEL_VERSION := $(RELEASE_KERNEL_CAIMAN_VERSION)
else
TARGET_LINUX_KERNEL_VERSION ?= 6.1
endif

ifdef RELEASE_KERNEL_CAIMAN_DIR
TARGET_KERNEL_DIR ?= $(RELEASE_KERNEL_CAIMAN_DIR)
TARGET_BOARD_KERNEL_HEADERS ?= $(RELEASE_KERNEL_CAIMAN_DIR)/kernel-headers

ifneq ($(TARGET_BOOTS_16K),true)
PRODUCT_16K_DEVELOPER_OPTION := $(RELEASE_GOOGLE_CAIMAN_16K_DEVELOPER_OPTION)
endif

include device/google/caimito/device-caimito-16k-common.mk

else
TARGET_KERNEL_DIR ?= device/google/caimito-kernels/6.1/24D1
TARGET_BOARD_KERNEL_HEADERS ?= device/google/caimito-kernels/6.1/24D1/kernel-headers
endif

LOCAL_PATH := device/google/caimito

ifneq (,$(filter userdebug eng, $(TARGET_BUILD_VARIANT)))
    USE_UWBFIELDTESTQM := true
endif
ifeq ($(filter factory_caiman, $(TARGET_PRODUCT)),)
    include device/google/caimito/caiman/uwb/uwb_calibration.mk
endif

$(call inherit-product-if-exists, vendor/google_devices/caimito/prebuilts/device-vendor-caiman.mk)
$(call inherit-product-if-exists, vendor/google_devices/zumapro/prebuilts/device-vendor.mk)
$(call inherit-product-if-exists, vendor/google_devices/zumapro/proprietary/device-vendor.mk)
$(call inherit-product-if-exists, vendor/google_devices/caiman/proprietary/device-vendor.mk)
$(call inherit-product-if-exists, vendor/google_devices/caimito/proprietary/caiman/device-vendor-caiman.mk)
$(call inherit-product-if-exists, vendor/qorvo/uwb/qm35-hal/Device.mk)

ifeq ($(filter factory_caiman, $(TARGET_PRODUCT)),)
    $(call inherit-product-if-exists, vendor/google_devices/caimito/proprietary/WallpapersCaiman.mk)
endif

# display
DEVICE_PACKAGE_OVERLAYS += device/google/caimito/caiman/overlay

ifeq ($(RELEASE_PIXEL_AIDL_AUDIO_HAL),true)
USE_AUDIO_HAL_AIDL := true
endif

include device/google/caimito/audio/caiman/audio-tables.mk
include device/google/zumapro/device-shipping-common.mk
include device/google/gs-common/bcmbt/bluetooth.mk
include device/google/gs-common/touch/gti/predump_gti.mk
include device/google/caimito/fingerprint/ultrasonic_udfps.mk
include device/google/gs-common/modem/radio_ext/radio_ext.mk
include device/google/gs-common/pixelsupport/pixelsupport.mk
include device/google/gs-common/gril/hidl/1.7/gril_hidl.mk

# Increment the SVN for any official public releases
ifdef RELEASE_SVN_CAIMAN
TARGET_SVN ?= $(RELEASE_SVN_CAIMAN)
else
# Set this for older releases that don't use build flag
TARGET_SVN ?= 04
endif

PRODUCT_VENDOR_PROPERTIES += \
    ro.vendor.build.svn=$(TARGET_SVN)

# Set device family property for SMR
PRODUCT_PROPERTY_OVERRIDES += \
    ro.build.device_family=CM4KM4TK4TG4

# Set build properties for SMR builds
ifeq ($(RELEASE_IS_SMR), true)
    ifneq (,$(RELEASE_BASE_OS_CAIMAN))
        PRODUCT_BASE_OS := $(RELEASE_BASE_OS_CAIMAN)
    endif
endif

# Set build properties for EMR builds
ifeq ($(RELEASE_IS_EMR), true)
    ifneq (,$(RELEASE_BASE_OS_CAIMAN))
        PRODUCT_PROPERTY_OVERRIDES += \
        ro.build.version.emergency_base_os=$(RELEASE_BASE_OS_CAIMAN)
    endif
endif

# go/lyric-soong-variables
$(call soong_config_set,lyric,camera_hardware,caiman)
$(call soong_config_set,lyric,tuning_product,caiman)
$(call soong_config_set,google3a_config,target_device,caiman)

# Init files
PRODUCT_COPY_FILES += \
	device/google/caimito/conf/init.caiman.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.caiman.rc

# NFC
PRODUCT_COPY_FILES += \
	frameworks/native/data/etc/android.hardware.nfc.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.nfc.xml \
	frameworks/native/data/etc/android.hardware.nfc.hce.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.nfc.hce.xml \
	frameworks/native/data/etc/android.hardware.nfc.hcef.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.nfc.hcef.xml \
	frameworks/native/data/etc/com.nxp.mifare.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/com.nxp.mifare.xml \
	frameworks/native/data/etc/android.hardware.nfc.ese.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.nfc.ese.xml \

PRODUCT_PACKAGES += \
	$(RELEASE_PACKAGE_NFC_STACK) \
	Tag \
	android.hardware.nfc-service.st \
	NfcOverlayCaiman

# SecureElement
PRODUCT_PACKAGES += \
	android.hardware.secure_element-service.thales

PRODUCT_COPY_FILES += \
	frameworks/native/data/etc/android.hardware.se.omapi.ese.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.se.omapi.ese.xml \
	frameworks/native/data/etc/android.hardware.se.omapi.uicc.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.se.omapi.uicc.xml \

PRODUCT_PACKAGES += \
    camera_front_mipi_coex_table \
    camera_rear_main_dbr_coex_table \
    camera_rear_main_mipi_coex_table \
    camera_rear_tele_mipi_coex_table \
    camera_rear_wide_mipi_coex_table \
    display_primary_mipi_coex_table

# Spatial Audio
PRODUCT_PACKAGES += \
	libspatialaudio

ifneq ($(USE_AUDIO_HAL_AIDL),true)
# HIDL Sound Dose
PRODUCT_PACKAGES += \
	android.hardware.audio.sounddose-vendor-impl \
	audio_sounddose_aoc
endif

PRODUCT_PACKAGES += \
    libspeechenhancer

# Bluetooth hci_inject test tool
PRODUCT_PACKAGES_DEBUG += \
    hci_inject

# Bluetooth SAR test tool
PRODUCT_PACKAGES_DEBUG += \
    sar_test

# Bluetooth EWP test tool
PRODUCT_PACKAGES_DEBUG += \
    ewp_tool

# Override BQR mask to enable LE Audio Choppy report, remove BTRT logging
ifneq (,$(filter userdebug eng, $(TARGET_BUILD_VARIANT)))
PRODUCT_PRODUCT_PROPERTIES += \
    persist.bluetooth.bqr.event_mask=295006 \
    persist.bluetooth.bqr.vnd_quality_mask=29 \
    persist.bluetooth.bqr.vnd_trace_mask=0 \
    persist.bluetooth.vendor.btsnoop=true
endif

# Spatial Audio
PRODUCT_PACKAGES += \
	libspatialaudio \
	librondo

# UWB Overlay
PRODUCT_PACKAGES += \
    UwbOverlayCM4

# WiFi Overlay
PRODUCT_PACKAGES += \
    WifiOverlay2024

# Settings Overlay
PRODUCT_PACKAGES += \
    SettingsCaimanOverlay

# Trusty liboemcrypto.so
PRODUCT_SOONG_NAMESPACES += vendor/google_devices/caimito/prebuilts

# UWB
PRODUCT_SOONG_NAMESPACES += \
    device/google/caimito/caiman/uwb

# Location
PRODUCT_SOONG_NAMESPACES += device/google/caimito/location/caiman
$(call soong_config_set, gpssdk, buildtype, $(TARGET_BUILD_VARIANT))
PRODUCT_PACKAGES += gps.cfg

#Thermal VT estimator
PRODUCT_PACKAGES += \
    libthermal_tflite_wrapper

PRODUCT_VENDOR_PROPERTIES += \
    persist.vendor.udfps.als_feed_forward_supported=true \
    persist.vendor.udfps.lhbm_controlled_in_hal_supported=true

# OIS with system imu
PRODUCT_VENDOR_PROPERTIES += \
    persist.vendor.camera.ois_with_system_imu=true

# Allow external binning setting
PRODUCT_VENDOR_PROPERTIES += \
    persist.vendor.camera.allow_external_binning_setting=true

# Camera Vendor property
PRODUCT_VENDOR_PROPERTIES += \
    persist.vendor.camera.front_720P_always_binning=true

# Enable camera exif model/make reporting
PRODUCT_VENDOR_PROPERTIES += \
    persist.vendor.camera.exif_reveal_make_model=true

# Media Performance Class 15
PRODUCT_PRODUCT_PROPERTIES += ro.odm.build.media_performance_class=35

# Display RRS default Config
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += persist.vendor.display.primary.boot_config=960x2142@120:120
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += ro.vendor.primarydisplay.preferred_mode=960x2142@120:120

ifeq ($(filter factory_caiman, $(TARGET_PRODUCT)),)
    PRODUCT_DEFAULT_PROPERTY_OVERRIDES += ro.vendor.primarydisplay.xrr.version=2.1
    PRODUCT_DEFAULT_PROPERTY_OVERRIDES += ro.vendor.primarydisplay.blocking_zone.min_refresh_rate_by_nits=:1
    PRODUCT_DEFAULT_PROPERTY_OVERRIDES += ro.vendor.primarydisplay.vrr.expected_present.headsup_ns=30000000
    PRODUCT_DEFAULT_PROPERTY_OVERRIDES += ro.vendor.primarydisplay.vrr.expected_present.timeout_ns=500000000
endif

# Display OP HZ Config
PRODUCT_VENDOR_PROPERTIES += \
    vendor.primarydisplay.op.hs_hz=120 \
    vendor.primarydisplay.op.ns_hz=120

# Display fixed TE2
PRODUCT_VENDOR_PROPERTIES += vendor.primarydisplay.fixed_te2.default_rate_hz=120

# Vibrator HAL
$(call soong_config_set,haptics,kernel_ver,v$(subst .,_,$(TARGET_LINUX_KERNEL_VERSION)))
ACTUATOR_MODEL := luxshare_ict_081545
ADAPTIVE_HAPTICS_FEATURE := adaptive_haptics_v1
PRODUCT_VENDOR_PROPERTIES += \
    ro.vendor.vibrator.hal.chirp.enabled=1 \
    ro.vendor.vibrator.hal.device.mass=0.222 \
    ro.vendor.vibrator.hal.loc.coeff=2.8 \
    persist.vendor.vibrator.hal.context.enable=false \
    persist.vendor.vibrator.hal.context.scale=60 \
    persist.vendor.vibrator.hal.context.fade=true \
    persist.vendor.vibrator.hal.context.cooldowntime=1600 \
    persist.vendor.vibrator.hal.context.settlingtime=5000 \
    ro.vendor.vibrator.hal.pm.activetimeout=5

# Override Output Distortion Gain
PRODUCT_VENDOR_PROPERTIES += \
    vendor.audio.hapticgenerator.distortion.output.gain=0.48

# PKVM Memory Reclaim
PRODUCT_VENDOR_PROPERTIES += \
    hypervisor.memory_reclaim.supported=1

# Set support one-handed mode
PRODUCT_PRODUCT_PROPERTIES += \
    ro.support_one_handed_mode=true

# Keyboard height ratio and bottom padding in dp for portrait mode
PRODUCT_PRODUCT_PROPERTIES += \
          ro.com.google.ime.kb_pad_port_b=8 \
          ro.com.google.ime.height_ratio=1.12

# Exynos RIL and telephony
# Support RIL Domain-selection
SUPPORT_RIL_DOMAIN_SELECTION := true

SUPPORT_VENDOR_SATELLITE_SERVICE := true

# Support NTN(satellite) with dual SIM
NTN_DUAL_SIM := true

# ETM
ifneq (,$(filter userdebug eng, $(TARGET_BUILD_VARIANT)))
$(call inherit-product-if-exists, device/google/common/etm/device-userdebug-modules.mk)
endif

# Enable Bluetooth AutoOn feature
PRODUCT_PRODUCT_PROPERTIES += \
    bluetooth.server.automatic_turn_on=true

# Window Extensions
$(call inherit-product, $(SRC_TARGET_DIR)/product/window_extensions.mk)

# Connectivity Resources Overlay for Thread host settings
PRODUCT_PACKAGES += \
    ConnectivityResourcesOverlayCaimitoOverride

# Thread Dispatcher enablement in Bluetooth HAL
PRODUCT_PRODUCT_PROPERTIES += \
    persist.bluetooth.thread_dispatcher.enabled=false

#Component Override for Pixel Troubleshooting App
PRODUCT_COPY_FILES += \
    device/google/caimito/caiman/caiman-component-overrides.xml:$(TARGET_COPY_OUT_VENDOR)/etc/sysconfig/caiman-component-overrides.xml

# Bluetooth device id
# Caiman: 0x4110
PRODUCT_PRODUCT_PROPERTIES += \
    bluetooth.device_id.product_id=16656

# Set support for LEA multicodec
PRODUCT_PRODUCT_PROPERTIES += \
    bluetooth.core.le_audio.codec_extension_aidl.enabled=true

# Enable APF by default
PRODUCT_VENDOR_PROPERTIES += \
    vendor.powerhal.apf_disabled=false \
    vendor.powerhal.apf_enabled=true

PRODUCT_VENDOR_PROPERTIES := $(filter-out ro.vendor.build.svn=% , $(PRODUCT_VENDOR_PROPERTIES))

PRODUCT_PACKAGES += fir-proximity-feature.xml
