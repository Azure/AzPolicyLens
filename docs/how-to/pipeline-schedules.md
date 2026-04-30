# How to Setup Pipeline and Workflow Schedules

The Policy Documentation pipelines are designed to run on a schedule based on your organization's requirements. This document provides instructions on how to set up pipeline schedules in both Azure DevOps Pipelines and GitHub Actions.

Both Azure DevOps and GitHub use cron expressions to define the schedule for pipeline runs.

A cron expression is a string consisting of five fields separated by spaces that represent the minute, hour, day of month, month, and day of week when the pipeline should run.

```text
mm HH DD MM DW
 \  \  \  \  \__ Days of week
  \  \  \  \____ Months
   \  \  \______ Days
    \  \________ Hours
     \__________ Minutes
```

If you are using Microsoft-hosted Azure DevOps agents or GitHub hosted Action Runners, the time set on the agent computers are UTC. so you need to adjust the cron expression accordingly if you want the pipeline to run at a specific local time.

i.e. for Melbourne / Sydney Australia time zone (UTC+10), the cron expression `'30 1,5,21 * * *'` translates to 1:30 AM (UTC), 5:30 AM (UTC), and 9:30 PM (UTC) every day, which is 11:30 AM, 3:30 PM, and 7:30 AM local time.

The Cron syntax is explained in this the official documentations:

- Azure DevOps: [Configure Schedules for Pipelines](https://learn.microsoft.com/en-us/azure/devops/pipelines/process/scheduled-triggers?view=azure-devops&pivots=pipelines-yaml)
- GitHub Actions [Events that trigger workflows - schedule](https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows#schedule)
