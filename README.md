# Automated Azure Policy Documentation

## Introduction

Azure Policy can feel overwhelming due to its complexity and the sheer volume of policies that need to be managed. Organizations often struggle with:

- **Lack of Visibility**: Difficulty in understanding which policies are in place and their impact on resources.
- **Lack of Reporting and Compliance Monitoring**: Challenges in tracking compliance status and generating reports for audits.
- **Incorrect policy configurations**: It is common to have inconsistent, overlapping or incorrect policy definitions that can lead to security vulnerabilities.
- **No Clear Documentation**: Policies are often poorly documented, making it hard for teams to understand their purpose and implementation.
- **Lack of Security Control Mapping**: Inconsistent and lack of clarity in mapping policies to specific security controls or frameworks, leading to gaps in compliance.

> **Without reporting and collaboration, managing Azure policies at scale is error-prone, time-consuming, and lacks clarity across teams.**

This repository contains scripts and tools to automatically generate documentation for Azure Policy implementation as well as current compliance status and security posture of your Azure environment.

## Overview

**`AzPolicyLens` is an end–to-end automated solution that transform your Azure Policy data into Structured, security-aligned documentation and reports – ready to integrate into your DevOps ecosystem.**

The goal is to ensure that all policies are well-documented, as well as providing accurate reporting on the resource compliance posture.

It assists the following teams within the organization:

- **Azure cloud engineering teams**:
  - Ensure that all policies are well-documented and easily accessible for reference.
  - Assist in the creation of new policies by providing references for security control requirements.
  - Help to identity potential gaps and misconfigurations in existing policies.
  - Facilitate the review and update of policies to ensure they remain relevant and effective.
  - Assist in the management of policies by providing a centralized repository for all policy documentation.

- **Cyber Security teams**:
  - Provide visibility into the current policy landscape.
  - Provide a clear picture of current security posture in the Azure environment.
  - Assist in the identification of potential security risks and compliance issues.
  - Help to ensure all required security controls are implemented through policies.

- **Application teams**:
  - A version of the documentation can be created tailored for application teams.
  - Creating visibility into the security requirements for the Azure Landing Zones for the application teams.
  - Assist in the understanding of how policies impact their applications and workloads.
  - Help to manage the compliance of their applications with organizational policies.
  - Help to manage the policy exemptions that may be required for their applications.

## Features

| Feature | Description |
| :------ | :---------- |
| Detailed Wikis | Auto-generated technical documentation for cloud engineering & security teams |
| Security Control Catalog | CMaps both built-in & custom controls and report on its compliance |
| Team-Specific Views | Tailored for each application |
| CI/CD Integration | Seamlessly integrates into existing DevOps pipelines |
| Analytics & Recommendations | Analyse data and provide recommendations for areas of improvements |

## Documentation

The documentation for this repository can be found in the [docs](./docs) folder.
