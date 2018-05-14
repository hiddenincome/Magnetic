/*

The MIT License (MIT)

Copyright (c) 2018 Anders Holmberg - hiddenincome.com

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

*/

#include <string.h>
#include <stdio.h>
#include <pthread.h>

#include "bridge.h"

pthread_mutex_t lock;

#define INPUT_BUFFER_SIZE 128
char input_buffer[INPUT_BUFFER_SIZE];
int input_buffer_front = 0;
int input_buffer_back = 0;

#define OUTPUT_BUFFER_SIZE 16384
unsigned char output_buffer[OUTPUT_BUFFER_SIZE];
int output_buffer_front = 0;
int output_buffer_back = 0;

void bridge_init(const char *story_file)
{
    ms_init(story_file, "", "", "");

    /* Use this mutex to hold the engine when it calls the ms_getchar function */
    pthread_mutex_init(&lock, NULL);
    pthread_mutex_lock(&lock);
}

void bridge_input(unsigned char c)
{
    if (input_buffer_back == input_buffer_front) {
        input_buffer_back = 0;
        input_buffer_front = 0;
    }

    if (c == '\x08') {
        if (input_buffer_front > input_buffer_back) {
            input_buffer_front--;
        }
    } else if (input_buffer_back < INPUT_BUFFER_SIZE) {
        input_buffer[input_buffer_front] = c;
        input_buffer_front++;
        
        /* Release the ms_getchar function when we got a complete
           sentence */
        if (c == '\n') {
            pthread_mutex_unlock(&lock);
        }
    } else {
        input_buffer_front = 0;
        input_buffer_back = 0;
    }
}

void ms_putchar(type8 c)
{
    if (output_buffer_front == output_buffer_back) {
        output_buffer_back = 0;
        output_buffer_front = 0;
    }

    if (output_buffer_front < OUTPUT_BUFFER_SIZE) {
        output_buffer[output_buffer_front++] = c;
    }
    
    /* Easier to read with some extra lines */
    if (c == '\n' && output_buffer_front < OUTPUT_BUFFER_SIZE) {
        output_buffer[output_buffer_front++] = c;
    }
}

unsigned char bridge_output(void)
{
    if (output_buffer_back != output_buffer_front) {
        return output_buffer[output_buffer_back++];
    }

    return '\0';
}

type8 ms_load_file(type8s * name, type8 * ptr, type16 size)
{
    return 0;
}

type8 ms_save_file(type8s * name, type8 * ptr, type16 size)
{
    return 0;
}

void ms_statuschar(type8 c)
{
    
}

void ms_flush(void)
{
    output_buffer_back = 0;
    output_buffer_front = 0;
}

type8 ms_getchar(type8 trans)
{
    while (1) {
        if (input_buffer_front > input_buffer_back) {
            char c = input_buffer[input_buffer_back];
            input_buffer_back++;
            return c;
        }
    
        pthread_mutex_lock(&lock);
    }

    return 0;
}

void ms_showpic(type32 c, type8 mode)
{
    
}

void ms_fatal(type8s * txt)
{
    
}

type8 ms_showhints(struct ms_hint * hints)
{
    return 0;
}

void ms_playmusic(type8 * midi_data, type32 length, type16 tempo)
{
    
}
