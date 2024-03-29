/*
 * Syscall wrappers to ensure that nothing gets done in dry_run mode
 * and to handle system peculiarities.
 *
 * Copyright (C) 1998 Andrew Tridgell
 * Copyright (C) 2002 Martin Pool
 * Copyright (C) 2003-2009 Wayne Davison
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

#if !defined MKNOD_CREATES_SOCKETS && defined HAVE_SYS_UN_H
#include <sys/un.h>
#endif
#ifdef HAVE_SYS_ATTR_H
#include <sys/attr.h>
#endif

extern int dry_run;
extern int am_root;
extern int read_only;
extern int list_only;
extern int force_change;
extern int preserve_perms;
extern int preserve_executability;

#define RETURN_ERROR_IF(x,e) \
	do { \
		if (x) { \
			errno = (e); \
			return -1; \
		} \
	} while (0)

#define RETURN_ERROR_IF_RO_OR_LO RETURN_ERROR_IF(read_only || list_only, EROFS)

int do_unlink(const char *fname)
{
	if (dry_run) return 0;
	RETURN_ERROR_IF_RO_OR_LO;
	if (unlink(fname) == 0)
		return 0;
#ifdef SUPPORT_FORCE_CHANGE
	if (force_change && errno == EPERM) {
		STRUCT_STAT st;

		if (x_lstat(fname, &st, NULL) == 0
		 && make_mutable(fname, st.st_mode, st.st_flags, force_change) > 0) {
			if (unlink(fname) == 0)
				return 0;
			undo_make_mutable(fname, st.st_flags);
		}
		/* TODO: handle immutable directories */
		errno = EPERM;
	}
#endif
	return -1;
}

int do_symlink(const char *fname1, const char *fname2)
{
	if (dry_run) return 0;
	RETURN_ERROR_IF_RO_OR_LO;
	return symlink(fname1, fname2);
}

#ifdef HAVE_LINK
int do_link(const char *fname1, const char *fname2)
{
	if (dry_run) return 0;
	RETURN_ERROR_IF_RO_OR_LO;
	return link(fname1, fname2);
}
#endif

int do_lchown(const char *path, uid_t owner, gid_t group, mode_t mode, uint32 fileflags)
{
	if (dry_run) return 0;
	RETURN_ERROR_IF_RO_OR_LO;
#ifndef HAVE_LCHOWN
#define lchown chown
#endif
	if (lchown(path, owner, group) == 0)
		return 0;
#ifdef SUPPORT_FORCE_CHANGE
	if (force_change && errno == EPERM) {
		if (fileflags == NO_FFLAGS) {
			STRUCT_STAT st;
			if (x_lstat(path, &st, NULL) == 0) {
				mode = st.st_mode;
				fileflags = st.st_flags;
			}
		}
		if (fileflags != NO_FFLAGS
		 && make_mutable(path, mode, fileflags, force_change) > 0) {
			int ret = lchown(path, owner, group);
			undo_make_mutable(path, fileflags);
			if (ret == 0)
				return 0;
		}
		errno = EPERM;
	}
#else
	mode = fileflags = 0; /* avoid compiler warning */
#endif
	return -1;
}

int do_mknod(const char *pathname, mode_t mode, dev_t dev)
{
	if (dry_run) return 0;
	RETURN_ERROR_IF_RO_OR_LO;

	/* For --fake-super, we create a normal file with mode 0600. */
	if (am_root < 0) {
		int fd = open(pathname, O_WRONLY|O_CREAT|O_TRUNC, S_IWUSR|S_IRUSR);
		if (fd < 0 || close(fd) < 0)
			return -1;
		return 0;
	}

#if !defined MKNOD_CREATES_FIFOS && defined HAVE_MKFIFO
	if (S_ISFIFO(mode))
		return mkfifo(pathname, mode);
#endif
#if !defined MKNOD_CREATES_SOCKETS && defined HAVE_SYS_UN_H
	if (S_ISSOCK(mode)) {
		int sock;
		struct sockaddr_un saddr;
#ifdef HAVE_SOCKADDR_UN_LEN
		unsigned int len =
#endif
		    strlcpy(saddr.sun_path, pathname, sizeof saddr.sun_path);
#ifdef HAVE_SOCKADDR_UN_LEN
		saddr.sun_len = len >= sizeof saddr.sun_path
			      ? sizeof saddr.sun_path : len + 1;
#endif
		saddr.sun_family = AF_UNIX;

		if ((sock = socket(PF_UNIX, SOCK_STREAM, 0)) < 0
		    || (unlink(pathname) < 0 && errno != ENOENT)
		    || (bind(sock, (struct sockaddr*)&saddr, sizeof saddr)) < 0)
			return -1;
		close(sock);
#ifdef HAVE_CHMOD
		return do_chmod(pathname, mode, 0);
#else
		return 0;
#endif
	}
#endif
#ifdef HAVE_MKNOD
	return mknod(pathname, mode, dev);
#else
	return -1;
#endif
}

int do_rmdir(const char *pathname)
{
	if (dry_run) return 0;
	RETURN_ERROR_IF_RO_OR_LO;
	if (rmdir(pathname) == 0)
		return 0;
#ifdef SUPPORT_FORCE_CHANGE
	if (force_change && errno == EPERM) {
		STRUCT_STAT st;

		if (x_lstat(pathname, &st, NULL) == 0
		 && make_mutable(pathname, st.st_mode, st.st_flags, force_change) > 0) {
			if (rmdir(pathname) == 0)
				return 0;
			undo_make_mutable(pathname, st.st_flags);
		}
		errno = EPERM;
	}
#endif
	return -1;
}

int do_open(const char *pathname, int flags, mode_t mode)
{
	if (flags != O_RDONLY) {
		RETURN_ERROR_IF(dry_run, 0);
		RETURN_ERROR_IF_RO_OR_LO;
	}

	return open(pathname, flags | O_BINARY, mode);
}

#ifdef HAVE_CHMOD
int do_chmod(const char *path, mode_t mode, uint32 fileflags)
{
	int code;
	if (dry_run) return 0;
	RETURN_ERROR_IF_RO_OR_LO;
	if (S_ISLNK(mode)) {
#ifdef HAVE_LCHMOD
		code = lchmod(path, mode & CHMOD_BITS);
#elif defined HAVE_SETATTRLIST
		struct attrlist attrList;
		uint32_t m = mode & CHMOD_BITS; /* manpage is wrong: not mode_t! */

		memset(&attrList, 0, sizeof attrList);
		attrList.bitmapcount = ATTR_BIT_MAP_COUNT;
		attrList.commonattr = ATTR_CMN_ACCESSMASK;
		code = setattrlist(path, &attrList, &m, sizeof m, FSOPT_NOFOLLOW);
#else
		code = 1;
#endif
	} else
		code = chmod(path, mode & CHMOD_BITS); /* DISCOURAGED FUNCTION */
#ifdef SUPPORT_FORCE_CHANGE
	if (code < 0 && force_change && errno == EPERM && !S_ISLNK(mode)) {
		if (fileflags == NO_FFLAGS) {
			STRUCT_STAT st;
			if (x_lstat(path, &st, NULL) == 0)
				fileflags = st.st_flags;
		}
		if (fileflags != NO_FFLAGS
		 && make_mutable(path, mode, fileflags, force_change) > 0) {
			code = chmod(path, mode & CHMOD_BITS);
			undo_make_mutable(path, fileflags);
			if (code == 0)
				return 0;
		}
		errno = EPERM;
	}
#else
	fileflags = 0; /* avoid compiler warning */
#endif
	if (code != 0 && (preserve_perms || preserve_executability))
		return code;
	return 0;
}
#endif

#ifdef HAVE_CHFLAGS
int do_chflags(const char *path, uint32 fileflags)
{
	if (dry_run) return 0;
	RETURN_ERROR_IF_RO_OR_LO;
	return chflags(path, fileflags);
}
#endif

int do_rename(const char *fname1, const char *fname2)
{
	if (dry_run) return 0;
	RETURN_ERROR_IF_RO_OR_LO;
	if (rename(fname1, fname2) == 0)
		return 0;
#ifdef SUPPORT_FORCE_CHANGE
	if (force_change && errno == EPERM) {
		STRUCT_STAT st1, st2;
		int became_mutable;

		if (x_lstat(fname1, &st1, NULL) != 0)
			goto failed;
		became_mutable = make_mutable(fname1, st1.st_mode, st1.st_flags, force_change) > 0;
		if (became_mutable && rename(fname1, fname2) == 0)
			goto success;
		if (x_lstat(fname2, &st2, NULL) == 0
		 && make_mutable(fname2, st2.st_mode, st2.st_flags, force_change) > 0) {
			if (rename(fname1, fname2) == 0) {
			  success:
				if (became_mutable) /* Yes, use fname2 and st1! */
					undo_make_mutable(fname2, st1.st_flags);
				return 0;
			}
			undo_make_mutable(fname2, st2.st_flags);
		}
		/* TODO: handle immutable directories */
		if (became_mutable)
			undo_make_mutable(fname1, st1.st_flags);
	  failed:
		errno = EPERM;
	}
#endif
	return -1;
}

void trim_trailing_slashes(char *name)
{
	int l;
	/* Some BSD systems cannot make a directory if the name
	 * contains a trailing slash.
	 * <http://www.opensource.apple.com/bugs/X/BSD%20Kernel/2734739.html> */

	/* Don't change empty string; and also we can't improve on
	 * "/" */

	l = strlen(name);
	while (l > 1) {
		if (name[--l] != '/')
			break;
		name[l] = '\0';
	}
}

int do_mkdir(char *fname, mode_t mode)
{
	if (dry_run) return 0;
	RETURN_ERROR_IF_RO_OR_LO;
	trim_trailing_slashes(fname);
	return mkdir(fname, mode);
}

/* like mkstemp but forces permissions */
int do_mkstemp(char *template, mode_t perms)
{
	RETURN_ERROR_IF(dry_run, 0);
	RETURN_ERROR_IF(read_only, EROFS);
	perms |= S_IWUSR;

#if defined HAVE_SECURE_MKSTEMP && defined HAVE_FCHMOD && (!defined HAVE_OPEN64 || defined HAVE_MKSTEMP64)
	{
		int fd = mkstemp(template);
		if (fd == -1)
			return -1;
		if (fchmod(fd, perms) != 0 && preserve_perms) {
			int errno_save = errno;
			close(fd);
			unlink(template);
			errno = errno_save;
			return -1;
		}
#if defined HAVE_SETMODE && O_BINARY
		setmode(fd, O_BINARY);
#endif
		return fd;
	}
#else
	if (!mktemp(template))
		return -1;
	return do_open(template, O_RDWR|O_EXCL|O_CREAT, perms);
#endif
}

int do_stat(const char *fname, STRUCT_STAT *st)
{
#ifdef USE_STAT64_FUNCS
	return stat64(fname, st);
#else
	return stat(fname, st);
#endif
}

int do_lstat(const char *fname, STRUCT_STAT *st)
{
#ifdef SUPPORT_LINKS
# ifdef USE_STAT64_FUNCS
	return lstat64(fname, st);
# else
	return lstat(fname, st);
# endif
#else
	return do_stat(fname, st);
#endif
}

int do_fstat(int fd, STRUCT_STAT *st)
{
#ifdef USE_STAT64_FUNCS
	return fstat64(fd, st);
#else
	return fstat(fd, st);
#endif
}

OFF_T do_lseek(int fd, OFF_T offset, int whence)
{
#ifdef HAVE_LSEEK64
#if !SIZEOF_OFF64_T
	OFF_T lseek64();
#else
	off64_t lseek64();
#endif
	return lseek64(fd, offset, whence);
#else
	return lseek(fd, offset, whence);
#endif
}

time_t get_create_time(const char *path)
{
	static char attrBuf[sizeof(u_int32_t) + sizeof(struct timespec)];
	static struct timespec  *crtime = (struct timespec*)&attrBuf[sizeof(u_int32_t)];
	struct attrlist attrList;

	memset(&attrList, 0, sizeof attrList);
	attrList.bitmapcount = ATTR_BIT_MAP_COUNT;
	attrList.commonattr = ATTR_CMN_CRTIME;
	if (getattrlist(path, &attrList, &attrBuf, sizeof attrBuf, FSOPT_NOFOLLOW) < 0)
		return 0;
	return crtime->tv_sec;
}

int set_create_time(const char *path, time_t crtime)
{
	struct attrlist attrList;
	struct timespec ts;

	if (dry_run) return 0;
	RETURN_ERROR_IF_RO_OR_LO;

	ts.tv_sec = crtime;
	ts.tv_nsec = 0;

	memset(&attrList, 0, sizeof attrList);
	attrList.bitmapcount = ATTR_BIT_MAP_COUNT;
	attrList.commonattr = ATTR_CMN_CRTIME;
	return setattrlist(path, &attrList, &ts, sizeof ts, FSOPT_NOFOLLOW);
}
