/*
 * timer.c
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
#include <fcntl.h>
#include <stdint.h>
#include <string.h>
#include <sys/timerfd.h>
#include <pthread.h>
#include <poll.h>
#include <stdio.h>
#include <unistd.h>

#include "timer.h"

#define MAX_TIMER_COUNT 1000

struct timer_node
{
	int                 fd;
	timer_handler       callback;
	void *              user_data;
	unsigned int        interval;
	struct timer_node * next;
};

static void * _timer_thread(void * data);
static pthread_t g_thread_id;
static struct timer_node *g_head = NULL;

int timer_init()
{
	if(pthread_create(&g_thread_id, NULL, _timer_thread, NULL))
	{
		/*Thread creation failed*/
		return 0;
	}

	return 1;
}

void timer_finalize()
{
	while(g_head) timer_stop((size_t)g_head);

	pthread_cancel(g_thread_id);
	pthread_join(g_thread_id, NULL);
}

size_t timer_start(unsigned int interval,
		   timer_handler handler,
		   void * user_data)
{
	struct timer_node * new_node = NULL;
	struct itimerspec new_value;

	new_node = (struct timer_node *)malloc(sizeof(struct timer_node));

	if(new_node == NULL) return 0;

	new_node->callback  = handler;
	new_node->user_data = user_data;
	new_node->interval  = interval;

	new_node->fd = timerfd_create(CLOCK_REALTIME, 0);

	if (new_node->fd == -1)
	{
		free(new_node);
		return 0;
	}

	new_value.it_value.tv_sec  = interval / 1000;
	new_value.it_value.tv_nsec = (interval % 1000) * 1000 * 1000;
	new_value.it_interval.tv_sec = 0;
	new_value.it_interval.tv_nsec = 0;

	timerfd_settime(new_node->fd, 0, &new_value, NULL);

	/*Inserting the timer node into the list*/
	new_node->next = g_head;
	g_head = new_node;

	return (size_t)new_node;
}

void timer_stop(size_t timer_id)
{
	struct timer_node * tmp = NULL;
	struct timer_node * node = (struct timer_node *)timer_id;

	if (node == NULL) return;

	close(node->fd);

	if(node == g_head)
	{
		g_head = g_head->next;
	}

	tmp = g_head;

	while(tmp && tmp->next != node) tmp = tmp->next;

	if(tmp && tmp->next)
	{
		tmp->next = tmp->next->next;
	}

	if(node) free(node);
}

struct timer_node * _get_timer_from_fd(int fd)
{
	struct timer_node * tmp = g_head;

	while(tmp)
	{
		if(tmp->fd == fd) return tmp;

		tmp = tmp->next;
	}
	return NULL;
}

void * _timer_thread(void * data)
{
	struct pollfd ufds[MAX_TIMER_COUNT] = {{0}};
	int iMaxCount = 0;
	struct timer_node * tmp = NULL;
	int read_fds = 0, i, s;
	uint64_t exp;

	while(1)
	{
		pthread_setcancelstate(PTHREAD_CANCEL_ENABLE, NULL);
		pthread_testcancel();
		pthread_setcancelstate(PTHREAD_CANCEL_DISABLE, NULL);

		iMaxCount = 0;
		tmp = g_head;

		memset(ufds, 0, sizeof(struct pollfd)*MAX_TIMER_COUNT);
		while(tmp)
		{
			ufds[iMaxCount].fd = tmp->fd;
			ufds[iMaxCount].events = POLLIN;
			iMaxCount++;

			tmp = tmp->next;
		}
		read_fds = poll(ufds, iMaxCount, 100);

		if (read_fds <= 0) continue;

		for (i = 0; i < iMaxCount; i++)
		{
			if (ufds[i].revents & POLLIN)
			{
				s = read(ufds[i].fd, &exp, sizeof(uint64_t));

				if (s != sizeof(uint64_t)) continue;

				tmp = _get_timer_from_fd(ufds[i].fd);

				if(tmp && tmp->callback) tmp->callback((size_t)tmp, tmp->user_data);
			}
		}
	}

	return NULL;
}
