include $(TOPDIR)/rules.mk

LUCI_TITLE:=24spark Theme
LUCI_DEPENDS:=+luci-base
LUCI_PKGARCH:=all

PKG_NAME:=luci-theme-24spark
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

include $(TOPDIR)/feeds/luci/luci.mk

define Package/luci-theme-24spark
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Themes
  TITLE:=$(LUCI_TITLE)
  DEPENDS:=$(LUCI_DEPENDS)
  PKGARCH:=$(LUCI_PKGARCH)
endef

define Package/luci-theme-24spark/description
  Clean light theme for 24spark firmware.
endef

$(eval $(call BuildPackage,luci-theme-24spark))
