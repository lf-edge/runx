package main

import (
	"fmt"
	"time"
	"net"
	"os"
	"github.com/opencontainers/runc/libcontainer/utils"
)

func main() {

	//socket_file, err := os.Open(os.Args[1])
	socket_conn, err := net.Dial("unix", os.Args[1])
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}

	socket_fd, ok := socket_conn.(*net.UnixConn)
	if !ok {
		fmt.Errorf("failed to cast to fd")
		os.Exit(1)
	}

	socket_file, err := socket_fd.File()
	if err != nil {
		fmt.Errorf("failed to cast to file")
		os.Exit(1)
	}

	xen_file, err := os.OpenFile(os.Args[2], os.O_RDWR, 0755)
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
	xen_fd := xen_file.Fd()

	//need FD? Name?

	err = utils.SendFd(socket_file, os.Args[2], xen_fd);
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}

	//give containerd enough to get the info and then exit
	time.Sleep(20 * time.Second)

	return
}
