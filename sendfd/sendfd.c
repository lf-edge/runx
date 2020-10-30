/*
 * Copyright (c) 2020, Wind River Systems, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Written by Rob Woolley <rob.woolley@windriver.com>
 */

#include <sys/types.h>
#include <sys/stat.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <fcntl.h>
#include "passfd.h"

#define BUFSIZE 100

int main(int argc, char** argv) {
    struct sockaddr_un addr;
    char *socket_path = NULL;
    char buf[BUFSIZE];
    int sockfd, filefd, rc;

    if (argc != 3) {
        printf("Usage: sendfd <unix socket> <file>\n");
        exit(-1);
    }

    socket_path = argv[1];

    if ((sockfd = socket(AF_UNIX, SOCK_STREAM, 0)) == -1 ) {
        perror("socket error");
        exit(-1);
    }

    memset(&addr, 0, sizeof(addr));
    addr.sun_family = AF_UNIX;
    strncpy(addr.sun_path, socket_path, sizeof(addr.sun_path)-1);

    if (connect(sockfd, (struct sockaddr*)&addr, sizeof(addr)) == -1) {
        perror("connect error");
        exit(-1);
    }

    filefd = open(argv[2], O_RDWR);

    if ((rc = sendfd(sockfd, filefd, argv[2])) == -1) {
        perror("sendfd failed");
        exit(-1);
    }

    return 0;
}
