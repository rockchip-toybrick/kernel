#! /usr/bin/env python
# -*- coding: utf-8 -*-

# Copyright (c) 2011-2012, The Linux Foundation. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of The Linux Foundation nor
#       the names of its contributors may be used to endorse or promote
#       products derived from this software without specific prior written
#       permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NON-INFRINGEMENT ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# Invoke gcc, looking for warnings, and causing a failure if there are
# non-whitelisted warnings.

from __future__ import print_function
import errno
import re
import os
import sys
import subprocess

allowed_warnings = set([
    "posix-cpu-timers.c:1268", # kernel/time/posix-cpu-timers.c:1268:13: warning: 'now' may be used uninitialized in this function
    "af_unix.c:1036", # net/unix/af_unix.c:1036:20: warning: 'hash' may be used uninitialized in this function
    "sunxi_sram.c:214", # drivers/soc/sunxi/sunxi_sram.c:214:24: warning: 'device' may be used uninitialized in this function
    "ks8851.c:298", # drivers/net/ethernet/micrel/ks8851.c:298:2: warning: 'rxb[0]' may be used uninitialized in this function
    "ks8851.c:421", # drivers/net/ethernet/micrel/ks8851.c:421:20: warning: 'rxb[0]' may be used uninitialized in this function
    "compat_binfmt_elf.c:58", # fs/compat_binfmt_elf.c:58:13: warning: 'cputime_to_compat_timeval' defined but not used
    "memcontrol.c:5337", # mm/memcontrol.c:5337:12: warning: initialization from incompatible pointer type
    "atags_to_fdt.c:98", # arch/arm/boot/compressed/atags_to_fdt.c:98:1: warning: the frame size of 1032 bytes is larger than 1024 bytes
    "drm_edid.c:3506", # drivers/gpu/drm/drm_edid.c:3506:13: warning: 'cea_db_is_hdmi_forum_vsdb' defined but not used
    # W=1
    "bounds.c:15", # kernel/bounds.c:15:6: warning: no previous prototype for ‘foo’
    "cpufeature.h:157", # arch/arm64/include/asm/cpufeature.h:157:68: warning: signed and unsigned type in conditional expression
    "sched.h:1211", # include/linux/sched.h:1211:1: warning: type qualifiers ignored on function return type
    "vdso.c:119", # arch/arm64/kernel/vdso.c:119:6: warning: ‘memcmp’ reading 4 bytes from a region of size 1 [-Wstringop-overflow=]
    "syscalls.h:195", # include/linux/syscalls.h:195:18: warning: ‘sys_set_tid_address’ alias between functions of incompatible types ‘long int(int *)’ and ‘long int(long int)’ [-Wattribute-alias]
    "compat.h:48", # include/linux/compat.h:48:18: warning: ‘compat_sys_sysctl’ alias between functions of incompatible types ‘long int(struct compat_sysctl_args *)’ and ‘long int(long int)’ [-Wattribute-alias]
    "exec.c:1084", # fs/exec.c:1084:32: warning: argument to ‘sizeof’ in ‘strncpy’ call is the same expression as the source; did you mean to use the size of the destination? [-Wsizeof-pointer-memaccess]
    "regcache-rbtree.c:36", # drivers/base/regmap/regcache-rbtree.c:36:1: warning: alignment 1 of ‘struct regcache_rbtree_node’ is less than 8 [-Wpacked-not-aligned]
    "dhd_linux.c:6913", # drivers/net/wireless/rockchip_wlan/rkwifi/bcmdhd/dhd_linux.c:6913:39: warning: argument to ‘sizeof’ in ‘strncpy’ call is the same expression as the source; did you mean to use the size of the destination? [-Wsizeof-pointer-memaccess]
    "dhd_linux.c:9284", # drivers/net/wireless/rockchip_wlan/rkwifi/bcmdhd/dhd_linux.c:9284:4: warning: ‘strncat’ specified bound 2 equals source length [-Wstringop-overflow=]
    "dhd_linux.c:15081", # drivers/net/wireless/rockchip_wlan/rkwifi/bcmdhd/dhd_linux.c:15081:2: warning: ‘strncpy’ output truncated before terminating nul copying 11 bytes from a string of the same length [-Wstringop-truncation]
    "bcmutils.h:39", # drivers/net/wireless/rockchip_wlan/rkwifi/bcmdhd/include/bcmutils.h:39:57: warning: ‘strncpy’ output truncated before terminating nul copying 45 bytes from a string of the same length [-Wstringop-truncation]
    "wl_android.c:2977", # drivers/net/wireless/rockchip_wlan/rkwifi/bcmdhd/wl_android.c:2977:2: warning: ‘strncpy’ output truncated before terminating nul copying 3 bytes from a string of the same length [-Wstringop-truncation]
    "wl_cfg80211.c:3522", # drivers/net/wireless/rockchip_wlan/rkwifi/bcmdhd/wl_cfg80211.c:3522:3: warning: ‘strncpy’ output truncated before terminating nul copying 3 bytes from a string of the same length [-Wstringop-truncation]
    "scsi.c:555", # drivers/nvme/host/scsi.c:555:2: warning: ‘strncpy’ output truncated before terminating nul copying 8 bytes from a string of the same length [-Wstringop-truncation]
    "sctp.h:306", # include/uapi/linux/sctp.h:306:1: warning: alignment 4 of ‘struct sctp_paddr_change’ is less than 8 [-Wpacked-not-aligned]
    "sctp.h:580", # include/uapi/linux/sctp.h:580:1: warning: alignment 4 of ‘struct sctp_setpeerprim’ is less than 8 [-Wpacked-not-aligned]
    "sctp.h:579", # include/uapi/linux/sctp.h:579:26: warning: ‘sspp_addr’ offset 4 in ‘struct sctp_setpeerprim’ isn’t aligned to 8 [-Wpacked-not-aligned]
    "sctp.h:593", # include/uapi/linux/sctp.h:593:1: warning: alignment 4 of ‘struct sctp_prim’ is less than 8 [-Wpacked-not-aligned]
    "sctp.h:592", # include/uapi/linux/sctp.h:592:26: warning: ‘ssp_addr’ offset 4 in ‘struct sctp_prim’ isn’t aligned to 8 [-Wpacked-not-aligned]
    "sctp.h:640", # include/uapi/linux/sctp.h:640:1: warning: alignment 4 of ‘struct sctp_paddrparams’ is less than 8 [-Wpacked-not-aligned]
    "sctp.h:634", # include/uapi/linux/sctp.h:634:26: warning: ‘spp_address’ offset 4 in ‘struct sctp_paddrparams’ isn’t aligned to 8 [-Wpacked-not-aligned]
    "sctp.h:747", # include/uapi/linux/sctp.h:747:1: warning: alignment 4 of ‘struct sctp_paddrinfo’ is less than 8 [-Wpacked-not-aligned]
    "sctp.h:741", # include/uapi/linux/sctp.h:741:26: warning: ‘spinfo_address’ offset 4 in ‘struct sctp_paddrinfo’ isn’t aligned to 8 [-Wpacked-not-aligned]
    "compat.c:518", # net/compat.c:518:1: warning: alignment 4 of ‘struct compat_group_req’ is less than 8 [-Wpacked-not-aligned]
    "compat.c:516", # net/compat.c:516:35: warning: ‘gr_group’ offset 4 in ‘struct compat_group_req’ isn’t aligned to 8 [-Wpacked-not-aligned]
    "compat.c:526", # net/compat.c:526:1: warning: alignment 4 of ‘struct compat_group_source_req’ is less than 8 [-Wpacked-not-aligned]
    "compat.c:522", # net/compat.c:522:35: warning: ‘gsr_group’ offset 4 in ‘struct compat_group_source_req’ isn’t aligned to 8 [-Wpacked-not-aligned]
    "compat.c:524", # net/compat.c:524:35: warning: ‘gsr_source’ offset 132 in ‘struct compat_group_source_req’ isn’t aligned to 8 [-Wpacked-not-aligned]
    "compat.c:536", # net/compat.c:536:1: warning: alignment 4 of ‘struct compat_group_filter’ is less than 8 [-Wpacked-not-aligned]
    "compat.c:530", # net/compat.c:530:35: warning: ‘gf_group’ offset 4 in ‘struct compat_group_filter’ isn’t aligned to 8 [-Wpacked-not-aligned]
    "halphyrf_8188e_ce.c:2208", # drivers/net/wireless/rockchip_wlan/rtl8189es/hal/phydm/rtl8188e/halphyrf_8188e_ce.c:2208:1: warning: the frame size of 1056 bytes is larger than 1024 bytes
    "halphyrf_8723b_ce.c:2879", # drivers/net/wireless/rockchip_wlan/rtl8723bu/hal/phydm/rtl8723b/halphyrf_8723b_ce.c:2879:1: warning: the frame size of 1056 bytes is larger than 1024 bytes
 ])

# Capture the name of the object file, can find it.
ofile = None

do_exit = False;

warning_re = re.compile(r'''(.*/|)([^/]+\.[a-z]+:\d+):(\d+:)? warning:''')
def interpret_warning(line):
    """Decode the message from gcc.  The messages we care about have a filename, and a warning"""
    line = line.rstrip('\n')
    m = warning_re.match(line)
    if m and m.group(2) not in allowed_warnings:
        print ("error, forbidden warning:" + m.group(2))

        # If there is a warning, remove any object if it exists.
        if ofile:
            try:
                os.remove(ofile)
            except OSError:
                pass
        global do_exit
        do_exit = True;

def run_gcc():
    args = sys.argv[1:]
    # Look for -o
    try:
        i = args.index('-o')
        global ofile
        ofile = args[i+1]
    except (ValueError, IndexError):
        pass

    compiler = sys.argv[0]

    try:
        env = os.environ.copy()
        env['LC_ALL'] = 'C'
        proc = subprocess.Popen(args, stderr=subprocess.PIPE, env=env)
        for line in proc.stderr:
            print (line.decode("utf-8"), end="")
            interpret_warning(line.decode("utf-8"))
        if do_exit:
            sys.exit(1)

        result = proc.wait()
    except OSError as e:
        result = e.errno
        if result == errno.ENOENT:
            print (args[0] + ':' + e.strerror)
            print ('Is your PATH set correctly?')
        else:
            print (' '.join(args) + str(e))

    return result

if __name__ == '__main__':
    status = run_gcc()
    sys.exit(status)
