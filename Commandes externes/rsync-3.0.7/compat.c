/*
 * Compatibility routines for older rsync protocol versions.
 *
 * Copyright (C) Andrew Tridgell 1996
 * Copyright (C) Paul Mackerras 1996
 * Copyright (C) 2004-2009 Wayne Davison
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, visit the http://fsf.org website.
 */

#include "rsync.h"

#ifdef SUPPORT_HFS_COMPRESSION
// For getattrlist()
#include <sys/attr.h>
// For statfs():
#include <sys/param.h>
#include <sys/mount.h>
// For dirname()
#include <libgen.h>
#endif

#ifdef SUPPORT_FORCE_CHANGE
#include <sys/types.h>
#include <sys/sysctl.h>
#endif

int remote_protocol = 0;
int file_extra_cnt = 0; /* count of file-list extras that everyone gets */
int inc_recurse = 0;
int use_safe_inc_flist = 0;

extern int verbose;
extern int am_server;
extern int am_sender;
extern int local_server;
extern int inplace;
extern int recurse;
extern int use_qsort;
extern int allow_inc_recurse;
extern int append_mode;
extern int fuzzy_basis;
extern int read_batch;
extern int delay_updates;
extern int checksum_seed;
extern int basis_dir_cnt;
extern int prune_empty_dirs;
extern int protocol_version;
extern int force_change;
extern int protect_args;
extern int preserve_uid;
extern int preserve_gid;
extern int preserve_crtimes;
extern int preserve_fileflags;
extern int preserve_acls;
extern int preserve_xattrs;
extern int preserve_hfs_compression;
int fs_supports_hfs_compression = 0;
extern int need_messages_from_generator;
extern int delete_mode, delete_before, delete_during, delete_after;
extern char *shell_cmd;
extern char *partial_dir;
extern char *dest_option;
extern char *files_from;
extern char *filesfrom_host;
extern struct filter_list_struct filter_list;
extern int need_unsorted_flist;
#ifdef ICONV_OPTION
extern iconv_t ic_send, ic_recv;
extern char *iconv_opt;
#endif

/* These index values are for the file-list's extra-attribute array. */
int uid_ndx, gid_ndx, crtimes_ndx, fileflags_ndx, acls_ndx, xattrs_ndx, unsort_ndx;

int receiver_symlink_times = 0; /* receiver can set the time on a symlink */
int sender_symlink_iconv = 0;	/* sender should convert symlink content */

#ifdef ICONV_OPTION
int filesfrom_convert = 0;
#endif

#define CF_INC_RECURSE	 (1<<0)
#define CF_SYMLINK_TIMES (1<<1)
#define CF_SYMLINK_ICONV (1<<2)
#define CF_SAFE_FLIST	 (1<<3)
#define CF_HFS_COMPRESSION (1<<4)

static const char *client_info;

/* The server makes sure that if either side only supports a pre-release
 * version of a protocol, that both sides must speak a compatible version
 * of that protocol for it to be advertised as available. */
static void check_sub_protocol(void)
{
	char *dot;
	int their_protocol, their_sub;
#if SUBPROTOCOL_VERSION != 0
	int our_sub = protocol_version < PROTOCOL_VERSION ? 0 : SUBPROTOCOL_VERSION;
#else
	int our_sub = 0;
#endif

	/* client_info starts with VER.SUB string if client is a pre-release. */
	if (!(their_protocol = atoi(client_info))
	 || !(dot = strchr(client_info, '.'))
	 || !(their_sub = atoi(dot+1))) {
#if SUBPROTOCOL_VERSION != 0
		if (our_sub)
			protocol_version--;
#endif
		return;
	}

	if (their_protocol < protocol_version) {
		if (their_sub)
			protocol_version = their_protocol - 1;
		return;
	}

	if (their_protocol > protocol_version)
		their_sub = 0; /* 0 == final version of older protocol */
	if (their_sub != our_sub)
		protocol_version--;
}

void set_allow_inc_recurse(void)
{
	client_info = shell_cmd ? shell_cmd : "";

	if (!recurse || use_qsort)
		allow_inc_recurse = 0;
	else if (!am_sender
	 && (delete_before || delete_after
	  || delay_updates || prune_empty_dirs))
		allow_inc_recurse = 0;
	else if (am_server && !local_server
	 && (strchr(client_info, 'i') == NULL))
		allow_inc_recurse = 0;
}

void setup_protocol(int f_out,int f_in)
{
	if (am_sender)
		file_extra_cnt += PTR_EXTRA_CNT;
	else
		file_extra_cnt++;
	if (preserve_uid)
		uid_ndx = ++file_extra_cnt;
	if (preserve_gid)
		gid_ndx = ++file_extra_cnt;
	if (preserve_crtimes)
		crtimes_ndx = (file_extra_cnt += TIME_EXTRA_CNT);
	if (preserve_fileflags || (force_change && !am_sender))
		fileflags_ndx = ++file_extra_cnt;
	if (preserve_acls && !am_sender)
		acls_ndx = ++file_extra_cnt;
	if (preserve_xattrs)
		xattrs_ndx = ++file_extra_cnt;

	if (am_server)
		set_allow_inc_recurse();

	if (remote_protocol == 0) {
		if (am_server && !local_server)
			check_sub_protocol();
		if (!read_batch)
			write_int(f_out, protocol_version);
		remote_protocol = read_int(f_in);
		if (protocol_version > remote_protocol)
			protocol_version = remote_protocol;
	}
	if (read_batch && remote_protocol > protocol_version) {
		rprintf(FERROR, "ERR : The protocol version in the batch file is too new (%d > %d).\n",
			remote_protocol, protocol_version);
		exit_cleanup(RERR_PROTOCOL);
	}

	if (verbose > 3) {
		rprintf(FINFO, "INF : (%s) Protocol versions: remote=%d, negotiated=%d\n",
			am_server? "Server" : "Client", remote_protocol, protocol_version);
	}
	if (remote_protocol < MIN_PROTOCOL_VERSION
	 || remote_protocol > MAX_PROTOCOL_VERSION) {
		rprintf(FERROR,"ERR : protocol version mismatch -- is your shell clean?\n");
		rprintf(FERROR,"ERR : (see the rsync man page for an explanation)\n");
		exit_cleanup(RERR_PROTOCOL);
	}
	if (remote_protocol < OLD_PROTOCOL_VERSION) {
		rprintf(FINFO,"INF : %s is very old version of rsync, upgrade recommended.\n",
			am_server? "Client" : "Server");
	}
	if (protocol_version < MIN_PROTOCOL_VERSION) {
		rprintf(FERROR, "ERR : --protocol must be at least %d on the %s.\n",
			MIN_PROTOCOL_VERSION, am_server? "Server" : "Client");
		exit_cleanup(RERR_PROTOCOL);
	}
	if (protocol_version > PROTOCOL_VERSION) {
		rprintf(FERROR, "ERR : --protocol must be no more than %d on the %s.\n",
			PROTOCOL_VERSION, am_server? "Server" : "Client");
		exit_cleanup(RERR_PROTOCOL);
	}
	if (read_batch)
		check_batch_flags();

	if (protocol_version < 30) {
		if (append_mode == 1)
			append_mode = 2;
		if (preserve_acls && !local_server) {
			rprintf(FERROR,
			    "ERR : --acls requires protocol 30 or higher"
			    " (negotiated %d).\n",
			    protocol_version);
			exit_cleanup(RERR_PROTOCOL);
		}
		if (preserve_xattrs && !local_server) {
			rprintf(FERROR,
			    "ERR : --xattrs requires protocol 30 or higher"
			    " (negotiated %d).\n",
			    protocol_version);
			exit_cleanup(RERR_PROTOCOL);
		}
	}

	if (delete_mode && !(delete_before+delete_during+delete_after)) {
		if (protocol_version < 30)
			delete_before = 1;
		else
			delete_during = 1;
	}

	if (protocol_version < 29) {
		if (fuzzy_basis) {
			rprintf(FERROR,
			    "ERR : --fuzzy requires protocol 29 or higher"
			    " (negotiated %d).\n",
			    protocol_version);
			exit_cleanup(RERR_PROTOCOL);
		}

		if (basis_dir_cnt && inplace) {
			rprintf(FERROR,
			    "ERR : %s with --inplace requires protocol 29 or higher"
			    " (negotiated %d).\n",
			    dest_option, protocol_version);
			exit_cleanup(RERR_PROTOCOL);
		}

		if (basis_dir_cnt > 1) {
			rprintf(FERROR,
			    "ERR : Using more than one %s option requires protocol"
			    " 29 or higher (negotiated %d).\n",
			    dest_option, protocol_version);
			exit_cleanup(RERR_PROTOCOL);
		}

		if (prune_empty_dirs) {
			rprintf(FERROR,
			    "ERR : --prune-empty-dirs requires protocol 29 or higher"
			    " (negotiated %d).\n",
			    protocol_version);
			exit_cleanup(RERR_PROTOCOL);
		}
	} else if (protocol_version >= 30) {
		int compat_flags;
		if (am_server) {
			compat_flags = allow_inc_recurse ? CF_INC_RECURSE : 0;
#if defined HAVE_LUTIMES && defined HAVE_UTIMES
			compat_flags |= CF_SYMLINK_TIMES;
#endif
#ifdef ICONV_OPTION
			compat_flags |= CF_SYMLINK_ICONV;
#endif
			if (local_server || strchr(client_info, 'f') != NULL)
				compat_flags |= CF_SAFE_FLIST;
#ifdef SUPPORT_HFS_COMPRESSION
			if (preserve_hfs_compression)
				compat_flags |= CF_HFS_COMPRESSION;
#endif
			write_byte(f_out, compat_flags);
		} else
			compat_flags = read_byte(f_in);
		/* The inc_recurse var MUST be set to 0 or 1. */
		inc_recurse = compat_flags & CF_INC_RECURSE ? 1 : 0;
		if (am_sender) {
			receiver_symlink_times = am_server
			    ? strchr(client_info, 'L') != NULL
			    : !!(compat_flags & CF_SYMLINK_TIMES);
#ifdef SUPPORT_HFS_COMPRESSION
			// CF_HFS_COMPRESSION will be set on the remote side as long as preserve_hfs_compression > 1
			if (preserve_hfs_compression && !(compat_flags & CF_HFS_COMPRESSION))
				preserve_hfs_compression = 0;

#endif
		}
#if defined HAVE_LUTIMES && defined HAVE_UTIMES
		else
			receiver_symlink_times = 1;
#endif
#ifdef ICONV_OPTION
		sender_symlink_iconv = iconv_opt && (am_server
		    ? local_server || strchr(client_info, 's') != NULL
		    : !!(compat_flags & CF_SYMLINK_ICONV));
#endif
		if (inc_recurse && !allow_inc_recurse) {
			/* This should only be able to happen in a batch. */
			fprintf(stderr,
			    "ERR : Incompatible options specified for inc-recursive %s.\n",
			    read_batch ? "batch file" : "connection");
			exit_cleanup(RERR_SYNTAX);
		}
		use_safe_inc_flist = !!(compat_flags & CF_SAFE_FLIST);
		need_messages_from_generator = 1;
#if defined HAVE_LUTIMES && defined HAVE_UTIMES
	} else if (!am_sender) {
		receiver_symlink_times = 1;
#endif
	}

	if (need_unsorted_flist && (!am_sender || inc_recurse))
		unsort_ndx = ++file_extra_cnt;

	if (partial_dir && *partial_dir != '/' && (!am_server || local_server)) {
		int flags = MATCHFLG_NO_PREFIXES | MATCHFLG_DIRECTORY;
		if (!am_sender || protocol_version >= 30)
			flags |= MATCHFLG_PERISHABLE;
		parse_rule(&filter_list, partial_dir, flags, 0);
	}


#ifdef ICONV_OPTION
	if (protect_args && files_from) {
		if (am_sender)
			filesfrom_convert = filesfrom_host && ic_send != (iconv_t)-1;
		else
			filesfrom_convert = !filesfrom_host && ic_recv != (iconv_t)-1;
	}
#endif

	if (am_server) {
		if (!checksum_seed)
			checksum_seed = time(NULL);
		write_int(f_out, checksum_seed);
	} else {
		checksum_seed = read_int(f_in);
	}
}

void do_filesystem_compatibility_checks(const char *path)
{
#ifdef SUPPORT_HFS_COMPRESSION
	fs_supports_hfs_compression = filesystem_supports_hfs_compression(path);
	if (preserve_hfs_compression > 0) {
		// If the filesystem doesn't support compression and 
		// decmpfs protection wasn't requested, disable support for compression
		if (!fs_supports_hfs_compression && preserve_hfs_compression < 2) {
			preserve_hfs_compression = 0;
			rprintf(FINFO, "INF : Disabling HFS compression support, %s doesn't support it (use --protect-decmpfs to force protection of the com.apple.decmpfs extended attribute).\n", path);
		}
	}
#endif

#ifdef SUPPORT_FORCE_CHANGE
	if (force_change & SYS_IMMUTABLE) {
		// determine whether we'll be able to unlock a system immutable item
		int mib[2];
		int securityLevel = 0;
		size_t len = sizeof(securityLevel);

		mib[0] = CTL_KERN;
		mib[1] = KERN_SECURELVL;
		if (sysctl(mib, 2, &securityLevel, &len, NULL, 0) == 0 && securityLevel > 0) {
			//rprintf(FINFO, "System security level is too high to force mutability on system immutable files and directories.\n");
			force_change = force_change & USR_IMMUTABLE ? USR_IMMUTABLE : 0;
		}
	}
#endif

// TODO: ACLs and xattrs
}

#ifdef SUPPORT_HFS_COMPRESSION
int filesystem_supports_hfs_compression(const char *path)
{
	struct statfs fsb;
	char *parent;
	int statfs_ret, saved_err;
	
	statfs_ret = statfs(path, &fsb);
	if (statfs_ret != 0) {
		saved_err = errno;
		if ((parent = (char *)dirname((char *)path)) != NULL)
			statfs_ret = statfs(parent, &fsb);
		errno = saved_err;
	}
	
	if (statfs_ret == 0) {
		struct attrlist attrs;
		struct {
			int32_t len;
			vol_capabilities_set_t caps;
		} attrData;
		
		bzero(&attrs, sizeof(attrs));
		attrs.bitmapcount = ATTR_BIT_MAP_COUNT;
		attrs.volattr = ATTR_VOL_CAPABILITIES;
		
		bzero(&attrData, sizeof(attrData));
		attrData.len = sizeof(attrData);
		
		int ret = getattrlist(fsb.f_mntonname, &attrs, &attrData, sizeof(attrData), 0);
		if (ret == 0) {
			if (attrData.caps[VOL_CAPABILITIES_FORMAT] & VOL_CAP_FMT_DECMPFS_COMPRESSION) {
				// Compression is supported
				return 1;
			}
		} else {
			rprintf(FERROR, "ERR : Failure in getattrlist while determining HFS compression support on %s (%s): %s\n", path, who_am_i(), strerror(errno));
		}
	} else {
		rprintf(FERROR, "ERR : Failure in statfs while determining HFS compression support on %s (%s): %s\n", path, who_am_i(), strerror(errno));
	}
	return 0;
}
#endif
