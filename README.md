# N60 Pro ImmortalWrt 云编译（GitHub Actions）

为磊科 N60 Pro（512MB / 128MB）定制的 ImmortalWrt 25.12 固件，基于官方 ImmortalWrt 源码编译。

## 包含内容

- 基础：LuCI、防火墙、PPPoE、DHCP/DNS、IPv6、WiFi 驱动、USB、SSH
- 主题：Argon（默认主题，中文；官方源自带）
- 代理：PassWall + sing-box
- 去广告：AdGuardHome
- DNS：AdGuardHome 过滤 + PassWall 国内外分流（SmartDNS 已去掉，避免四层 DNS 串联）
- VPN：WireGuard（内置于网络接口）
- DDNS、Attended Sysupgrade（升级保留软件包）、nlbwmon、WoL、UPnP（用户要求增加，刷后在 服务 → UPnP 里启用）
- 加速：Turbo ACC（官方源；若无则自动跳过，内置硬件流量分载已能跑满千兆）+ BBR 拥塞控制（kmod-tcp-bbr）
- 限速：eqos（官方源，轻量按 IP 限速；QoSmate 已去掉，与硬件加速互斥）
- IPTV：igmpproxy + udpxy
- 监控：CPU 温度显示；网页终端 ttyd；设备上网控制；断网看门狗 watchcat
- USB 存储驱动：block-mount、kmod-usb-storage、kmod-usb-storage-uas、kmod-usb3、kmod-fs-ext4、e2fsprogs（128MB 闪存紧张时可插 U 盘扩容 /overlay；UAS 让 USB 3.0 跑满速，e2fsprogs 可在路由器上直接把 U 盘格成 ext4）
- 无线默认关闭（有线主路由）

## 使用方法

1. 在 GitHub 上新建一个仓库（Public，名字任意，如 `n60pro-immortalwrt`）
2. 把本目录里的全部文件上传到仓库根目录（保持目录结构，尤其是 `.github/workflows/build.yml`）
3. 打开仓库的 Actions 页面，点左侧 "Build ImmortalWrt N60 Pro"，点 "Run workflow"，确认
4. 等待编译完成（首次约 1–2 小时，GitHub 免费额度内）
5. 编译成功后，在该次运行的 Artifacts 里下载固件压缩包，解压得到 `immortalwrt-...-netcore_n60-pro-squashfs-sysupgrade.itb`
6. 用该 `.itb` 通过 LuCI「系统 → 备份/升级」或 sysupgrade 命令升级（不要用 U-Boot 网页恢复刷 `.itb`，那个只认特定格式；`.itb` 是给系统内升级用的）

## 注意事项

- 首次编译时间较长，请耐心等待；如果失败，点进失败的步骤看日志。
- Turbo ACC 走官方源，若官方源没有则自动跳过（内置硬件流量分载已能跑满千兆，不影响使用）。
- AdGuardHome 的中文语言包官方源没有，已在配置里列出 `luci-i18n-adguardhome-zh-cn`，有源提供就打进去，没有则自动跳过、AdGuardHome 用英文界面。
- v4 已去掉的包：iStore（依赖 opkg，在 25.12/apk 上不可靠）、SmartDNS（与 AdGuardHome + PassWall 重复）、QoSmate（与硬件加速互斥）、luci-app-statistics（collectd + rrdtool 体积大，已有 nlbwmon）。如需这些功能，刷机后用 LuCI → 系统 → 软件包或 `apk add` 自行安装。
- v5 补充：USB 驱动加了 kmod-usb-storage-uas（UASP）和 e2fsprogs（mkfs.ext4）；删了 chenmozhijin 专属的 TURBOACC_INCLUDE_* 两行，改加官方 kmod-tcp-bbr。
- v8 补充：PassWall 默认的 Shadowsocks-Rust 子选项已关（它会在 aarch64 上默认拉起庞大的 Rust 工具链；sing-box 已原生支持 Shadowsocks，含 SS-2022）。diy-part2.sh 里仍保留 download-ci-llvm 改 false 的兜底（万一仍有包拉起 Rust，编译不会再因 CI 产物 404 失败）。
- v9 补充：PassWall 只留 sing-box 一个内核。PassWall 在 aarch64 上默认同时勾 xray-core 和 sing-box（各 25–35MB），128MB 闪存只留 sing-box；另关 PassWall 的 SmartDNS 子选项（它默认 y，会把 v4 删掉的 smartdns 又拉回来）。
- 后期直接装插件：可以。两种方式：① LuCI → 系统 → 软件包，搜官方源里的包安装；② SSH 上 `apk update && apk add <包名>`。前提是路由器已能上网（PPPoE 通）。官方源 25.12 的包都能这样装。
- 闪存提醒：N60 Pro 只有 128MB 闪存，sing-box（约 30MB）+ AdGuardHome（约 40MB）占了大头，刷机后 /overlay 剩余空间有限。后续更新 PassWall 规则库或 AdGuardHome 过滤列表时注意空间；空间紧张时可插 USB 3.0 U 盘扩容 /overlay（USB 驱动已编进固件）。
- 固件默认 LAN 为 192.168.1.1，root 无密码（首次进 LuCI 后立即设密码），无线默认关闭。
- 每次重新运行都会拉取最新源码和软件包，相当于升级到最新 25.12。

## 刷机格式说明（.itb 与 U-Boot）

- 编译产物是 `*-squashfs-sysupgrade.itb`（FIT 格式），用 LuCI 系统内升级刷入。
- 当前路由器上的 821KB 标准版 U-Boot 已验证能正常引导 `.itb`（之前官方 25.12.2 的 `.itb` 就是这么刷起来并正常进 LuCI 的），一般不需要换 U-Boot。
- 万一刷完重启卡住无法引导，再按住 Reset 键通电进 U-Boot 网页后台（192.168.1.1），换刷专用于 FIT 格式的 U-Boot 后重试。

## 文件说明

- `.github/workflows/build.yml`：GitHub Actions 工作流
- `n60-pro.config`：编译配置（目标机型 + 软件包清单）
- `diy-part1.sh`：第三方源占位（v4 已无第三方源，全部走官方源）
- `diy-part2.sh`：编译后处理（目前为空）
- `files/etc/uci-defaults/99-n60pro-defaults`：首次启动设置（关无线、默认 Argon 主题、中文界面；已加 `uci -q` 容错）
