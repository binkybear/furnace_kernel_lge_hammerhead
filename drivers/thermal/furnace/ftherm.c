/*
 * Copyright (c) 2012-2013, The Linux Foundation. All rights reserved.
 * Copyright (c) 2014 Savoca - adeddo27@gmail.com
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 and
 * only version 2 as published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 */

#include <linux/init.h>
#include <linux/device.h>
#include <linux/miscdevice.h>
#include <linux/stat.h>
#include <linux/export.h>
#include <linux/ftherm.h>

#define DEFAULT_BATT_MAX	55
#define DEFAULT_BATT_MIN	0
/* Potentially create a system using DEFAULT_BATT_MIN
 * to boost the cpu in an instance where the battery
 * has reached a very low temperature.
 */

static int battery_temp_max = DEFAULT_BATT_MAX;

static ssize_t ftherm_btm_read(struct device * dev, struct device_attribute * attr, char * buf)
{
    return sprintf(buf, "%u\n", battery_temp_max);
}

static ssize_t ftherm_btm_write(struct device * dev, struct device_attribute * attr, const char * buf, size_t size)
{
    unsigned int data;

    if(sscanf(buf, "%u\n", &data) == 1) 
	{
	    if (data >= DEFAULT_BATT_MIN && data <= DEFAULT_BATT_MAX)
		{
		    battery_temp_max = data;

		    pr_info("Battery temp max: %u\n", battery_temp_max);
		}
	    else
		{
		    pr_info("%s: Invalid input range %u\n", __FUNCTION__, data);
		}
	} 
    else 
	{
	    pr_info("%s: Invalid input\n", __FUNCTION__);
	}

    return size;
}

static DEVICE_ATTR(battery_temp_max, S_IRUGO | S_IWUGO, ftherm_btm_read, ftherm_btm_write);

static struct attribute *ftherm_attributes[] = 
    {
	&dev_attr_battery_temp_max.attr,
	NULL
    };

static struct attribute_group ftherm_group = 
    {
	.attrs  = ftherm_attributes,
    };

static struct miscdevice ftherm_device = 
    {
	.minor = MISC_DYNAMIC_MINOR,
	.name = "furnace_thermal_control",
    };

int get_battery_temp_max(void)
{
    return battery_temp_max;
}
EXPORT_SYMBOL(get_battery_temp_max);

static int __init ftherm_init(void)
{
    int ret;

    pr_info("%s misc_register(%s)\n", __FUNCTION__, ftherm_device.name);

    ret = misc_register(&ftherm_device);

    if (ret) 
	{
	    pr_err("%s misc_register(%s) fail\n", __FUNCTION__, ftherm_device.name);

	    return 1;
	}

    if (sysfs_create_group(&ftherm_device.this_device->kobj, &ftherm_group) < 0) 
	{
	    pr_err("%s sysfs_create_group fail\n", __FUNCTION__);
	    pr_err("Failed to create sysfs group for device (%s)!\n", ftherm_device.name);
	}

    return 0;
}

device_initcall(ftherm_init);
