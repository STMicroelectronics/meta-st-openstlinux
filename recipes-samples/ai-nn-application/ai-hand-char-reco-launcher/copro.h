/*
 * copro.h
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

#ifndef __COPRO_H__
#define __COPRO_H__

#include <stdint.h>
#include <sys/cdefs.h>
#include <sys/types.h>

int copro_isFwRunning(void);
int copro_stopFw(void);
int copro_startFw(void);
int copro_getFwPath(char* pathStr);
int copro_setFwPath(char* pathStr);
int copro_getFwName(char* pathStr);
int copro_setFwName(char* nameStr);
int copro_openTtyRpmsg(int modeRaw);
int copro_closeTtyRpmsg(void);
int copro_writeTtyRpmsg(int len, char* pData);
int copro_readTtyRpmsg(int len, char* pData);
char copro_computeCRC(char *bb, int size);

#endif /* __COPRO_H__ */
