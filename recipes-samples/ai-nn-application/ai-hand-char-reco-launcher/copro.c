/*
 * copro.c
 * Implements Copro's abstraction layer
 *
 * Copyright (C) 2018, STMicroelectronics - All Rights Reserved
 * Author: Vincent Abriou <vincent.abriou@st.com> for STMicroelectronics.
 *
 * License type: GPLv2
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 2 as published by
 * the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 * or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see
 * <http://www.gnu.org/licenses/>.
 */

#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <stdlib.h>
#include <sys/ioctl.h>
#include <termios.h>
#include <unistd.h>
#include <errno.h>
#include <fcntl.h>
#include <string.h>

#include "copro.h"

#define MAX_BUF 80

/* The file descriptor used to manage our TTY over RPMSG */
static int mFdRpmsg = -1;

int copro_isFwRunning(void)
{
	int fd;
	size_t byte_read;
	int result = 0;
	unsigned char bufRead[MAX_BUF];
	fd = open("/sys/class/remoteproc/remoteproc0/state", O_RDWR);
	if (fd < 0) {
		printf("Error opening remoteproc0/state, err=-%d\n", errno);
		return (errno * -1);
	}
	byte_read = (size_t) read (fd, bufRead, MAX_BUF);
	if (byte_read >= strlen("running")) {
		char* pos = strstr((char*)bufRead, "running");
		if(pos) {
			result = 1;
		}
	}
	close(fd);
	return result;
}

int copro_stopFw(void)
{
	int fd;
	fd = open("/sys/class/remoteproc/remoteproc0/state", O_RDWR);
	if (fd < 0) {
		printf("Error opening remoteproc0/state, err=-%d\n", errno);
		return (errno * -1);
	}
	write(fd, "stop", strlen("stop"));
	close(fd);
	return 0;
}

int copro_startFw(void)
{
	int fd;
	fd = open("/sys/class/remoteproc/remoteproc0/state", O_RDWR);
	if (fd < 0) {
		printf("Error opening remoteproc0/state, err=-%d\n", errno);
		return (errno * -1);
	}
	write(fd, "start", strlen("start"));
	close(fd);
	return 0;
}

int copro_getFwPath(char* pathStr)
{
	int fd;
	int byte_read;
	fd = open("/sys/module/firmware_class/parameters/path", O_RDWR);
	if (fd < 0) {
		printf("Error opening firmware_class/parameters/path, err=-%d\n", errno);
		return (errno * -1);
	}
	byte_read = read (fd, pathStr, MAX_BUF);
	close(fd);
	return byte_read;
}

int copro_setFwPath(char* pathStr)
{
	int fd;
	int result = 0;
	fd = open("/sys/module/firmware_class/parameters/path", O_RDWR);
	if (fd < 0) {
		printf("Error opening firmware_class/parameters/path, err=-%d\n", errno);
		return (errno * -1);
	}
	result = write(fd, pathStr, strlen(pathStr));
	close(fd);
	return result;
}

int copro_getFwName(char* name)
{
	int fd;
	int byte_read;
	fd = open("/sys/class/remoteproc/remoteproc0/firmware", O_RDWR);
	if (fd < 0) {
		printf("Error opening remoteproc0/firmware, err=-%d\n", errno);
		return (errno * -1);
	}
	byte_read = read (fd, name, MAX_BUF);
	close(fd);
	/*  remove \n from the read character */
	return byte_read - 1;
}

int copro_setFwName(char* nameStr)
{
	int fd;
	int result = 0;
	fd = open("/sys/class/remoteproc/remoteproc0/firmware", O_RDWR);
	if (fd < 0) {
		printf("Error opening remoteproc0/firmware, err=-%d\n", errno);
		return (errno * -1);
	}
	result = write(fd, nameStr, strlen(nameStr));
	close(fd);
	return result;
}

int copro_openTtyRpmsg(int modeRaw)
{
	struct termios tiorpmsg;
	mFdRpmsg = open("/dev/ttyRPMSG0", O_RDWR |  O_NOCTTY | O_NONBLOCK);
	if (mFdRpmsg < 0) {
		printf("Error opening ttyRPMSG0, err=-%d\n", errno);
		return (errno * -1);
	}
	/* get current port settings */
	tcgetattr(mFdRpmsg,&tiorpmsg);
	if (modeRaw) {
		tiorpmsg.c_iflag &= ~(IGNBRK | BRKINT | PARMRK | ISTRIP
				      | INLCR | IGNCR | ICRNL | IXON);
		tiorpmsg.c_oflag &= ~OPOST;
		tiorpmsg.c_lflag &= ~(ECHO | ECHONL | ICANON | ISIG | IEXTEN);
		tiorpmsg.c_cflag &= ~(CSIZE | PARENB);
		tiorpmsg.c_cflag |= CS8;
	} else {
		/* ECHO off, other bits unchanged */
		tiorpmsg.c_lflag &= ~ECHO;
		/*do not convert LF to CR LF */
		tiorpmsg.c_oflag &= ~ONLCR;
	}
	tcsetattr(mFdRpmsg, TCSANOW, &tiorpmsg);
	return 0;
}

int copro_closeTtyRpmsg(void)
{
	close(mFdRpmsg);
	mFdRpmsg = -1;
	return 0;
}

int copro_writeTtyRpmsg(int len, char* pData)
{
	int result = 0;
	if (mFdRpmsg < 0) {
		printf("Error writing ttyRPMSG0, fileDescriptor is not set\n");
		return mFdRpmsg;
	}
	result = write(mFdRpmsg, pData, len);
	return result;
}

int copro_readTtyRpmsg(int len, char* pData)
{
	int byte_rd, byte_avail;
	int result = 0;
	if (mFdRpmsg < 0) {
		printf("Error reading ttyRPMSG0, fileDescriptor is not set\n");
		return mFdRpmsg;
	}
	ioctl(mFdRpmsg, FIONREAD, &byte_avail);
	if (byte_avail > 0) {
		if (byte_avail >= len) {
			byte_rd = read (mFdRpmsg, pData, len);
		} else {
			byte_rd = read (mFdRpmsg, pData, byte_avail);
		}
		/*printf("copro_readTtyRpmsg, read successfully %d bytes to %p, [0]=0x%x\n", byte_rd, pData, pData[0]);*/
		result = byte_rd;
	} else {
		result = 0;
	}
	return result;
}

char copro_computeCRC(char *bb, int size)
{
	short sum = 0;

	for (int i = 0; i < size - 1; i++)
		sum += (bb[i] & 0xFF);

	char res = (char) (sum & 0xFF);
	res += (char) (sum >> 8);
	return res;
}
