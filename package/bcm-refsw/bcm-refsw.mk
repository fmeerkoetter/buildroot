################################################################################
#
# bcm-refsw
#
################################################################################

ifeq ($(BR2_PACKAGE_BCM_REFSW_13_1),y)
BCM_REFSW_VERSION = 13.1
else ifeq ($(BR2_PACKAGE_BCM_REFSW_13_4),y)
BCM_REFSW_VERSION = 13.4-1
else ifeq ($(BR2_PACKAGE_BCM_REFSW_15_2),y)
BCM_REFSW_VERSION = 15.2
else ifeq ($(BR2_PACKAGE_BCM_REFSW_16_1),y)
BCM_REFSW_VERSION = 16.1-3
else ifeq ($(BR2_PACKAGE_BCM_REFSW_16_2),y)
BCM_REFSW_VERSION = 16.2-7
else ifeq ($(BR2_PACKAGE_BCM_REFSW_16_3),y)
BCM_REFSW_VERSION = 16.3-1
else ifeq ($(BR2_PACKAGE_BCM_REFSW_17_1),y)
BCM_REFSW_VERSION = 17.1-1
else ifeq ($(BR2_PACKAGE_BCM_REFSW_17_1_RDK),y)
BCM_REFSW_VERSION = 17.1-4
else ifeq ($(BR2_PACKAGE_BCM_REFSW_17_2),y)
BCM_REFSW_VERSION = 17.2-1
else ifeq ($(BR2_PACKAGE_BCM_REFSW_17_3),y)
BCM_REFSW_VERSION = 17.3-1
else ifeq ($(BR2_PACKAGE_BCM_REFSW_17_3_RDK),y)
BCM_REFSW_VERSION = 17.3-2
else ifeq ($(BR2_PACKAGE_BCM_REFSW_17_4),y)
BCM_REFSW_VERSION = 17.4-2
else
BCM_REFSW_VERSION = 16.2-7
endif

BCM_REFSW_SITE = git@github.com:Metrological/bcm-refsw.git
BCM_REFSW_SITE_METHOD = git

BCM_REFSW_DEPENDENCIES = linux host-pkgconf host-flex host-bison host-gperf
BCM_REFSW_LICENSE = PROPRIETARY
BCM_REFSW_INSTALL_STAGING = YES
BCM_REFSW_INSTALL_TARGET = YES

BCM_REFSW_PROVIDES = libegl libgles
ifeq ($(BR2_PACKAGE_WESTEROS),y)
	BCM_REFSW_DEPENDENCIES += wayland
endif

# SOC related info
include package/bcm-refsw/platforms.inc

ifeq ($(BR2_TOOLCHAIN_HEADERS_AT_LEAST_3_14),y)
BCM_PMLIB_VERSION = 314
else
BCM_PMLIB_VERSION = 26
endif

BCM_REFSW_CONF_OPTS += \
	CROSS_COMPILE="${TARGET_CROSS}" \
	LINUX=${LINUX_DIR} \
	HOST_DIR="${HOST_DIR}"

BCM_REFSW_MAKE_ENV += \
	B_REFSW_ARCH=$(ARCH)-linux \
	B_REFSW_CROSS_COMPILE="${TARGET_CROSS}" \
	B_REFSW_VERBOSE=n \
	B_REFSW_DEBUG_LEVEL=wrn \
	BCHP_VER=$(BCM_REFSW_PLATFORM_REV) \
	NEXUS_TOP="$(BCM_REFSW_DIR)/nexus" \
	NEXUS_PLATFORM=$(BCM_REFSW_PLATFORM) \
	NEXUS_MODE=proxy \
	NEXUS_HEADERS=y \
	NEXUS_EXTRA_CFLAGS="$(TARGET_CFLAGS) -Wno-error=undef" \
	NEXUS_EXTRA_LDFLAGS="$(TARGET_LDFLAGS)" \
	VCX=$(BCM_REFSW_PLATFORM_VC) \
	V3D_EXTRA_CFLAGS="$(TARGET_CFLAGS)" \
	V3D_EXTRA_LDFLAGS="$(TARGET_LDFLAGS)" \
	NEXUS_IR_INPUT_EXTENSION_INC="${@D}/nexus/extensions/insert_ir_input/insert_ir_input.inc" \

ifeq ($(BR2_PACKAGE_BCM_REFSW_15_2),y)
BCM_REFSW_MAKE_ENV += CLIENT=y
else
BCM_REFSW_MAKE_ENV += NXCLIENT_SUPPORT=y
endif

ifeq ($(BR2_PACKAGE_BCM_REFSW_SAGE),y)
BCM_REFSW_MAKE_ENV += SAGE_SUPPORT=y
else
BCM_REFSW_MAKE_ENV += SAGE_SUPPORT=n
endif

ifeq ($(shell expr $(BCM_REFSW_VERSION) \>= 17.1),1)
BCM_REFSW_VCX = $(BCM_REFSW_DIR)/BSEAV/lib/gpu/${BCM_REFSW_PLATFORM_VC}
else
BCM_REFSW_VCX = $(BCM_REFSW_DIR)/rockford/middleware/${BCM_REFSW_PLATFORM_VC}
endif

BCM_REFSW_OUTPUT = $(BCM_REFSW_DIR)/obj.${BCM_REFSW_PLATFORM}
BCM_REFSW_BIN = ${BCM_REFSW_OUTPUT}/nexus/bin

ifneq ($(BR2_PACKAGE_WEBBRIDGE_PLUGIN_IRNEXUS_MODE),)
BCM_REFSW_IRMODE=$(call qstrip,$(BR2_PACKAGE_WEBBRIDGE_PLUGIN_IRNEXUS_MODE))
else
ifneq ($(BR2_PACKAGE_WPEFRAMEWORK_REMOTECONTROL_IRNEXUS_MODE),)
BCM_REFSW_IRMODE=$(call qstrip,$(BR2_PACKAGE_WPEFRAMEWORK_REMOTECONTROL_IRNEXUS_MODE))
else
BCM_REFSW_IRMODE=23
endif
endif

ifeq ($(BCM_REFSW_PLATFORM_VC),vc5)
	ifeq ($(shell expr $(BCM_REFSW_VERSION) \>= 16.2),1)
        BCM_REFSW_VCX_KHRN = $(BCM_REFSW_VCX)/driver/libs/khrn/include
	else
		BCM_REFSW_VCX_KHRN = $(BCM_REFSW_VCX)/driver/interface/khronos/include
	endif
else
	BCM_REFSW_VCX_KHRN = $(BCM_REFSW_VCX)/driver/interface/khronos/include
endif

# Nexus build and install targets
include package/bcm-refsw/nexus.inc

# Graphics build and install targets
include package/bcm-refsw/graphics.inc

# NX Server build and install targets
include package/bcm-refsw/nxserver.inc

# Wayland-EGL build and install targets
ifeq ($(BR2_PACKAGE_WESTEROS),y)
	include package/bcm-refsw/wayland-egl.inc
endif

define BCM_REFSW_BUILD_CMDS
	$(BCM_REFSW_BUILD_NEXUS)
	$(BCM_REFSW_BUILD_NXSERVER)
	$(BCM_REFSW_BUILD_NXCLIENT_EXAMPLES)
	$(BCM_REFSW_BUILD_PMLIB)
	$(BCM_REFSW_BUILD_GRAPHICS)
	$(BCM_REFSW_BUILD_EGLCUBE)
	$(BCM_REFSW_BUILD_WAYLAND_EGL)
	$(BCM_REFSW_BUILD_NEXUS_LIBB_OS)
endef

define BCM_REFSW_INSTALL_STAGING_CMDS
	$(call BCM_REFSW_INSTALL_NEXUS_DEV,         $(STAGING_DIR))
	$(call BCM_REFSW_INSTALL_GRAPHICS_DEV,      $(STAGING_DIR))
	$(call BCM_REFSW_INSTALL_NXSERVER_DEV,      $(STAGING_DIR))
	$(call BCM_REFSW_INSTALL_WAYLAND_EGL_DEV,   $(STAGING_DIR))
	$(call BCM_REFSW_INSTALL_PMLIB_DEV,         $(STAGING_DIR))
	$(call BCM_REFSW_INSTALL_NEXUS_LIBB_OS_DEV, $(STAGING_DIR))
endef

define BCM_REFSW_INSTALL_TARGET_CMDS
	$(call BCM_REFSW_INSTALL_NEXUS,             $(TARGET_DIR))
	$(call BCM_REFSW_INSTALL_WAKEUP,            $(TARGET_DIR))
	$(call BCM_REFSW_INSTALL_GRAPHICS,          $(TARGET_DIR))
	$(call BCM_REFSW_INSTALL_NXSERVER,          $(TARGET_DIR))
	$(call BCM_REFSW_INSTALL_EGLCUBE,           $(TARGET_DIR))
	$(call BCM_REFSW_INSTALL_WAYLAND_EGL,       $(TARGET_DIR))
	$(call BCM_REFSW_INSTALL_NEXUS_LIBB_OS,     $(TARGET_DIR))
endef

$(eval $(generic-package))