#!/bin/bash
# diy-part1.sh - add third-party feeds (runs inside openwrt/ before feeds update)
#
# v4 (2026-11-15): third-party feeds removed after review.
# - Turbo ACC: chenmozhijin feed removed (known firewall4 conflict on 25.12);
#   use the official ImmortalWrt luci-app-turboacc via n60-pro.config instead.
#   Built-in hardware flow offload already covers gigabit speed.
# - QoSmate: removed (conflicts with hardware flow offload; eqos kept as backup).
# - Argon: no longer cloned; official 25.12 luci feed already has luci-theme-argon 3.x.
# - iStore: removed (opkg-dependent, unreliable on 25.12/apk; use LuCI Software or apk).
# No third-party feeds are needed now. This script is kept as a no-op placeholder
# so the workflow step does not break.
:

