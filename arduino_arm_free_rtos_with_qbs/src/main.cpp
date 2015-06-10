/*
  main.cpp - Main loop for Arduino sketches
  Copyright (c) 2005-2013 Arduino Team.  All right reserved.

  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 2.1 of the License, or (at your option) any later version.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  Lesser General Public License for more details.

  You should have received a copy of the GNU Lesser General Public
  License along with this library; if not, write to the Free Software
  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
*/

#define ARDUINO_MAIN
#include "Arduino.h"
#include <FreeRTOS_ARM.h>
// Redefine AVR Flash string macro as nop for ARM
#undef F
#define F(str) str
/*
 * Cortex-M3 Systick IT handler
 */
// The LED is attached to pin 13 on Arduino.
const uint8_t LED_PIN = 13;

// Declare a semaphore handle.
SemaphoreHandle_t sem;
/*
extern void SysTick_Handler( void )
{
  // Increment tick count each ms
  TimeTick_Increment() ;
}
*/

// Weak empty variant initialization function.
// May be redefined by variant files.
void initVariant() __attribute__((weak));
void initVariant() { }

/*
 * \brief Main entry point of Arduino application
 */
int main( void )
{
        init();

        initVariant();

        delay(1);

#if defined(USBCON)
        USBDevice.attach();
#endif

        setup();

        for (;;)
        {
                loop();
                if (serialEventRun) serialEventRun();
        }

        return 0;
}
/*
 * Example to demonstrate thread definition, semaphores, and thread sleep.
 */
//------------------------------------------------------------------------------
/*
 * Thread 1, turn the LED off when signalled by thread 2.
 */
// Declare the thread function for thread 1.
static void Thread1(void* arg) {
  while (1) {

    // Wait for signal from thread 2.
    xSemaphoreTake(sem, portMAX_DELAY);

    // Turn LED off.
    digitalWrite(LED_PIN, LOW);
  }
}
//------------------------------------------------------------------------------
/*
 * Thread 2, turn the LED on and signal thread 1 to turn the LED off.
 */
// Declare the thread function for thread 2.
static void Thread2(void* arg) {

  pinMode(LED_PIN, OUTPUT);

  while (1) {
    // Turn LED on.
    digitalWrite(LED_PIN, HIGH);

    // Sleep for 200 milliseconds.
    vTaskDelay((500L * configTICK_RATE_HZ) / 1000L);

    // Signal thread 1 to turn LED off.
    xSemaphoreGive(sem);

    // Sleep for 200 milliseconds.
    vTaskDelay((500L * configTICK_RATE_HZ) / 1000L);
  }
}
//------------------------------------------------------------------------------
void setup() {
  portBASE_TYPE s1, s2;

  Serial.begin(9600);

  // initialize fifoData semaphore to no data available
  sem = xSemaphoreCreateCounting(1, 0);

  // create sensor task at priority two
  s1 = xTaskCreate(Thread1, NULL, configMINIMAL_STACK_SIZE, NULL, 2, NULL);

  // create SD write task at priority one
  s2 = xTaskCreate(Thread2, NULL, configMINIMAL_STACK_SIZE, NULL, 1, NULL);

  // check for creation errors
  if (sem== NULL || s1 != pdPASS || s2 != pdPASS ) {
    Serial.println(F("Creation problem"));
    while(1);
  }
  // start scheduler
  vTaskStartScheduler();
  Serial.println(F("Insufficient RAM"));
  while(1);
}
//------------------------------------------------------------------------------
// WARNING idle loop has a very small stack (configMINIMAL_STACK_SIZE)
// loop must never block
void loop() {
  // Not used.
}
