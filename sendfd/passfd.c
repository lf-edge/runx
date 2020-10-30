/*
 * Copyright (c) 2005 Robert N. M. Watson
 * Copyright (c) 2015 Mark Johnston
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

#include <sys/socket.h>
#include <sys/types.h>
#include <sys/un.h>
#include <string.h>
#include <stdlib.h>
#include <errno.h>
#include <assert.h>
#include <unistd.h>
#include <linux/limits.h>
#include "passfd.h"

#define SCM_CREDS SCM_CREDENTIALS

#define MAXNAMELEN	4096	/* maximum length of the name of fd being sent by sendfd */

static void putfds(char *buf, int fd, int nfds)
{
    struct cmsghdr *cm;
    int *fdp, i;

    cm = (struct cmsghdr *)buf;
    cm->cmsg_len = CMSG_LEN(nfds * sizeof(int));
    cm->cmsg_level = SOL_SOCKET;
    cm->cmsg_type = SCM_RIGHTS;
    for (fdp = (int *)CMSG_DATA(cm), i = 0; i < nfds; i++)
        *fdp++ = fd;
}

static size_t sendfd_payload(int sockfd, int send_fd,
                             void *payload, size_t paylen)
{
    struct iovec iovec;
    char message[CMSG_SPACE(sizeof(int))];
    struct msghdr msghdr;
    ssize_t len;

    bzero(&msghdr, sizeof(msghdr));
    bzero(&message, sizeof(message));

    msghdr.msg_control = message;
    msghdr.msg_controllen = sizeof(message);

    iovec.iov_base = payload;
    iovec.iov_len = paylen;

    msghdr.msg_iov = &iovec;
    msghdr.msg_iovlen = 1;

    putfds(message, send_fd, 1);
    len = sendmsg(sockfd, &msghdr, 0);
    return ((size_t)len);
}

int sendfd(int sockfd, int send_fd, char *filepath)
{
    size_t len;
    char *ch = NULL;
    size_t namelen;

    namelen = strnlen(filepath, PATH_MAX);

    if ((namelen == 0) || (namelen > MAXNAMELEN)) {
        return -1;
    }

    len = sendfd_payload(sockfd, send_fd, filepath, namelen);
    return len;
}
