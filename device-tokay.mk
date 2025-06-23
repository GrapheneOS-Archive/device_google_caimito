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

ifdef RELEASE_GOOGLE_TOKAY_RADIO_DIR
RELEASE_GOOGLE_PRODUCT_RADIO_DIR ?= $(RELEASE_GOOGLE_TOKAY_RADIO_DIR)
endif
ifdef RELEASE_GOOGLE_TOKAY_RADIOCFG_DIR
RELEASE_GOOGLE_PRODUCT_RADIOCFG_DIR ?= $(RELEASE_GOOGLE_TOKAY_RADIOCFG_DIR)
endif
RELEASE_GOOGLE_BOOTLOADER_TOKAY_DIR ?= 24D1# Keep this for pdk TODO: b/327119000
RELEASE_GOOGLE_PRODUCT_BOOTLOADER_DIR := bootloader/$(RELEASE_GOOGLE_BOOTLOADER_TOKAY_DIR)
$(call soong_config_set,caimito_bootloader,prebuilt_dir,$(RELEASE_GOOGLE_BOOTLOADER_TOKAY_DIR))

ifdef RELEASE_KERNEL_TOKAY_VERSION
TARGET_LINUX_KERNEL_VERSION := $(RELEASE_KERNEL_TOKAY_VERSION)
else
TARGET_LINUX_KERNEL_VERSION ?= 6.1
endif

ifdef RELEASE_KERNEL_TOKAY_DIR
TARGET_KERNEL_DIR ?= $(RELEASE_KERNEL_TOKAY_DIR)
TARGET_BOARD_KERNEL_HEADERS ?= $(RELEASE_KERNEL_TOKAY_DIR)/kernel-headers

ifneq ($(TARGET_BOOTS_16K),true)
PRODUCT_16K_DEVELOPER_OPTION := $(RELEASE_GOOGLE_TOKAY_16K_DEVELOPER_OPTION)
endif

include device/google/caimito/device-caimito-16k-common.mk

else
TARGET_KERNEL_DIR ?= device/google/caimito-kernels/6.1/24D1
TARGET_BOARD_KERNEL_HEADERS ?= device/google/caimito-kernels/6.1/24D1/kernel-headers
endif

$(call inherit-product-if-exists, vendor/google_devices/caimito/prebuilts/device-vendor-tokay.mk)
$(call inherit-product-if-exists, vendor/google_devices/zumapro/prebuilts/device-vendor.mk)
$(call inherit-product-if-exists, vendor/google_devices/zumapro/proprietary/device-vendor.mk)
$(call inherit-product-if-exists, vendor/google_devices/tokay/proprietary/device-vendor.mk)
$(call inherit-product-if-exists, vendor/google_devices/caimito/proprietary/tokay/device-vendor-tokay.mk)

ifeq ($(filter factory_tokay, $(TARGET_PRODUCT)),)
    $(call inherit-product-if-exists, vendor/google_devices/caimito/proprietary/WallpapersTokay.mk)
endif

# display
DEVICE_PACKAGE_OVERLAYS += device/google/caimito/tokay/overlay

ifeq ($(RELEASE_PIXEL_AIDL_AUDIO_HAL),true)
USE_AUDIO_HAL_AIDL := true
endif

include device/google/caimito/audio/tokay/audio-tables.mk
include device/google/zumapro/device-shipping-common.mk
include device/google/gs-common/bcmbt/bluetooth.mk
include device/google/gs-common/touch/gti/predump_gti.mk
include device/google/caimito/fingerprint/ultrasonic_udfps.mk
include device/google/gs-common/modem/radio_ext/radio_ext.mk
include device/google/gs-common/pixelsupport/pixelsupport.mk
include device/google/gs-common/gril/hidl/1.7/gril_hidl.mk

# Increment the SVN for any official public releases
ifdef RELEASE_SVN_TOKAY
TARGET_SVN ?= $(RELEASE_SVN_TOKAY)
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
    ifneq (,$(RELEASE_BASE_OS_TOKAY))
        PRODUCT_BASE_OS := $(RELEASE_BASE_OS_TOKAY)
    endif
endif

# Set build properties for EMR builds
ifeq ($(RELEASE_IS_EMR), true)
    ifneq (,$(RELEASE_BASE_OS_TOKAY))
        PRODUCT_PROPERTY_OVERRIDES += \
        ro.build.version.emergency_base_os=$(RELEASE_BASE_OS_TOKAY)
    endif
endif

# go/lyric-soong-variables
$(call soong_config_set,lyric,camera_hardware,tokay)
$(call soong_config_set,lyric,tuning_product,tokay)
$(call soong_config_set,google3a_config,target_device,tokay)

# Init files
PRODUCT_COPY_FILES += \
	device/google/caimito/conf/init.tokay.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.tokay.rc

# Recovery files
PRODUCT_COPY_FILES += \
        device/google/caimito/conf/init.recovery.device.rc:$(TARGET_COPY_OUT_RECOVERY)/root/init.recovery.tokay.rc

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
	NfcOverlayTokay

# SecureElement
PRODUCT_PACKAGES += \
	android.hardware.secure_element-service.thales

PRODUCT_COPY_FILES += \
	frameworks/native/data/etc/android.hardware.se.omapi.ese.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.se.omapi.ese.xml \
	frameworks/native/data/etc/android.hardware.se.omapi.uicc.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.se.omapi.uicc.xml \

PRODUCT_PACKAGES += \
    camera_front_dbr_coex_table \
    camera_front_mipi_coex_table \
    camera_rear_main_mipi_coex_table \
    camera_rear_wide_mipi_coex_table \
    display_primary_mipi_coex_table \
    display_primary_ssc_coex_table

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

# Bluetooth OPUS codec
PRODUCT_PRODUCT_PROPERTIES += \
    persist.bluetooth.opus.enabled=true

# Bluetooth SAR test tool
PRODUCT_PACKAGES_DEBUG += \
    sar_test

# Bluetooth EWP test tool
PRODUCT_PACKAGES_DEBUG += \
    ewp_tool

# Bluetooth AAC VBR
PRODUCT_PRODUCT_PROPERTIES += \
    persist.bluetooth.a2dp_aac.vbr_supported=true

# Bluetooth Super Wide Band
PRODUCT_PRODUCT_PROPERTIES += \
    bluetooth.hfp.swb.supported=true

# Override BQR mask to enable LE Audio Choppy report, remove BTRT logging
ifneq (,$(filter userdebug eng, $(TARGET_BUILD_VARIANT)))
PRODUCT_PRODUCT_PROPERTIES += \
    persist.bluetooth.bqr.event_mask=295006 \
    persist.bluetooth.bqr.vnd_quality_mask=29 \
    persist.bluetooth.bqr.vnd_trace_mask=0 \
    persist.bluetooth.vendor.btsnoop=true
else
PRODUCT_PRODUCT_PROPERTIES += \
    persist.bluetooth.bqr.event_mask=295006 \
    persist.bluetooth.bqr.vnd_quality_mask=16 \
    persist.bluetooth.bqr.vnd_trace_mask=0 \
    persist.bluetooth.vendor.btsnoop=false
endif

# default BDADDR for EVB only
PRODUCT_PROPERTY_OVERRIDES += \
	ro.vendor.bluetooth.evb_bdaddr="22:22:22:33:44:55"

# Spatial Audio
PRODUCT_PACKAGES += \
	libspatialaudio \
	librondo

# Keymaster HAL
#LOCAL_KEYMASTER_PRODUCT_PACKAGE ?= android.hardware.keymaster@4.1-service

# Gatekeeper HAL
#LOCAL_GATEKEEPER_PRODUCT_PACKAGE ?= android.hardware.gatekeeper@1.0-service.software


# Gatekeeper
# PRODUCT_PACKAGES += \
# 	android.hardware.gatekeeper@1.0-service.software

# Keymint replaces Keymaster
# PRODUCT_PACKAGES += \
# 	android.hardware.security.keymint-service

# Keymaster
#PRODUCT_PACKAGES += \
#	android.hardware.keymaster@4.0-impl \
#	android.hardware.keymaster@4.0-service

#PRODUCT_PACKAGES += android.hardware.keymaster@4.0-service.remote
#PRODUCT_PACKAGES += android.hardware.keymaster@4.1-service.remote
#LOCAL_KEYMASTER_PRODUCT_PACKAGE := android.hardware.keymaster@4.1-service
#LOCAL_KEYMASTER_PRODUCT_PACKAGE ?= android.hardware.keymaster@4.1-service

# PRODUCT_PROPERTY_OVERRIDES += \
# 	ro.hardware.keystore_desede=true \
# 	ro.hardware.keystore=software \
# 	ro.hardware.gatekeeper=software

# PowerStats HAL
PRODUCT_SOONG_NAMESPACES += \
    device/google/caimito/powerstats/tokay

# WiFi Overlay
PRODUCT_PACKAGES += \
    WifiOverlay2024

# Settings Overlay
PRODUCT_PACKAGES += \
    SettingsTokayOverlay

# Trusty liboemcrypto.so
PRODUCT_SOONG_NAMESPACES += vendor/google_devices/caimito/prebuilts

# Location
PRODUCT_SOONG_NAMESPACES += device/google/caimito/location/tokay
$(call soong_config_set, gpssdk, buildtype, $(TARGET_BUILD_VARIANT))
PRODUCT_PACKAGES += gps.cfg
# For GPS property
PRODUCT_VENDOR_PROPERTIES += ro.vendor.gps.pps.enabled=true

# Display function property settings
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
    vendor.display.lbe.supported=1 \
    ro.vendor.primarydisplay.google-tk4c.temperature_path=/dev/thermal/tz-by-name/disp_therm/temp \
    ro.vendor.display.read_temp_interval=30

#Thermal VT estimator
PRODUCT_PACKAGES += \
    libthermal_tflite_wrapper

PRODUCT_VENDOR_PROPERTIES += \
	persist.device_config.configuration.disable_rescue_party=true

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

# Exynos RIL and telephony
# Support RIL Domain-selection
SUPPORT_RIL_DOMAIN_SELECTION := true

SUPPORT_VENDOR_SATELLITE_SERVICE := true

# Support NTN(satellite) with dual SIM
NTN_DUAL_SIM := true

# Keyboard height ratio and bottom padding in dp for portrait mode
PRODUCT_PRODUCT_PROPERTIES += \
          ro.com.google.ime.kb_pad_port_b=8 \
          ro.com.google.ime.height_ratio=1.09

# Enable Bluetooth AutoOn feature
PRODUCT_PRODUCT_PROPERTIES += \
    bluetooth.server.automatic_turn_on=true

# Window Extensions
$(call inherit-product, $(SRC_TARGET_DIR)/product/window_extensions.mk)

# ETM
ifneq (,$(filter userdebug eng, $(TARGET_BUILD_VARIANT)))
$(call inherit-product-if-exists, device/google/common/etm/device-userdebug-modules.mk)
endif

# Connectivity Resources Overlay for Thread host settings
PRODUCT_PACKAGES += \
    ConnectivityResourcesOverlayCaimitoOverride

# Thread Dispatcher enablement in Bluetooth HAL
PRODUCT_PRODUCT_PROPERTIES += \
    persist.bluetooth.thread_dispatcher.enabled=false

#Component Override for Pixel Troubleshooting App
PRODUCT_COPY_FILES += \
    device/google/caimito/tokay/tokay-component-overrides.xml:$(TARGET_COPY_OUT_VENDOR)/etc/sysconfig/tokay-component-overrides.xml

# Bluetooth device id
# Tokay: 0x4112
PRODUCT_PRODUCT_PROPERTIES += \
    bluetooth.device_id.product_id=16658

# Set support for LEA multicodec
PRODUCT_PRODUCT_PROPERTIES += \
    bluetooth.core.le_audio.codec_extension_aidl.enabled=true

# Reduce lmkd aggressiveness
PRODUCT_PROPERTY_OVERRIDES += \
    ro.lmk.swap_free_low_percentage=7

# Enable APF by default
PRODUCT_VENDOR_PROPERTIES += \
    vendor.powerhal.apf_disabled=false \
    vendor.powerhal.apf_enabled=true

PRODUCT_VENDOR_PROPERTIES := $(filter-out ro.vendor.build.svn=% , $(PRODUCT_VENDOR_PROPERTIES))
