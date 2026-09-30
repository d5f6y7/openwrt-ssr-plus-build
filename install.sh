#!/bin/sh
# SSR Plus+ 一键安装脚本（mipsel_24kc / OpenWrt 24.10）
# 用法：wget -qO- https://cdn.jsdelivr.net/gh/d5f6y7/ssr-plus-install/install.sh | sh

REPO="d5f6y7/openwrt-ssr-plus-build"
TAG="mipsel_24kc-openwrt-24.10"
TARBALL="ssr-plus-mipsel_24kc-openwrt-24.10.tar.gz"
TMPDIR="/tmp/ssr-plus-ipk"

echo "== SSR Plus+ 一键安装 =="

if ! command -v opkg >/dev/null 2>&1; then
  echo "错误：未找到 opkg，请在 OpenWrt 路由器上运行。"
  exit 1
fi

if ! opkg print-architecture 2>/dev/null | grep -q "mipsel_24kc"; then
  echo "警告：当前架构似乎不是 mipsel_24kc，继续安装可能失败。"
fi

echo "获取 release 信息..."
API_URL="https://api.github.com/repos/${REPO}/releases/tags/${TAG}"
URL=$(wget -qO- "$API_URL" 2>/dev/null | grep -o '"browser_download_url": *"[^"]*\.tar\.gz"' | head -n 1 | sed 's/^"browser_download_url": *"//;s/"$//')

if [ -z "$URL" ]; then
  echo "错误：release ${TAG} 中没有找到安装包（构建可能还没完成）。"
  exit 1
fi

mkdir -p "$TMPDIR"
echo "下载安装包..."
wget -O "$TMPDIR/$TARBALL" "$URL" || { echo "下载失败"; exit 1; }

echo "解压安装包..."
tar -xzf "$TMPDIR/$TARBALL" -C "$TMPDIR" || { echo "解压失败"; exit 1; }

echo "安装 ipk ..."
opkg update
opkg install $TMPDIR/*.ipk
opkg install luci-i18n-base-zh-cn 2>/dev/null || true

rm -rf "$TMPDIR"
echo "== 安装完成，请刷新 LuCI，在 服务 里找 ShadowsocksR Plus+ =="
