/*
 * timer.h
 * Implements timer services
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

#ifndef __TIMER_H
#define __TIMER_H

#include <stdlib.h>

typedef void (*timer_handler)(size_t timer_id, void * user_data);

int timer_init();
void timer_finalize();
size_t timer_start(unsigned int interval, timer_handler handler, void * user_data);
void timer_stop(size_t timer_id);

#endif
